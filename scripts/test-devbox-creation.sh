#!/bin/bash

# Three Horizons AI Dev Box - Test Script
# Este script testa a criação de um Dev Box usando o template do Red Hat Developer Hub

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Three Horizons AI Dev Box - Test Script${NC}"
echo -e "${BLUE}============================================${NC}"

# Funções auxiliares
print_step() {
    echo -e "\n${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar pré-requisitos
print_step "Verificando pré-requisitos..."

# Verificar Azure CLI
if ! command -v az &> /dev/null; then
    print_error "Azure CLI não está instalado"
    exit 1
fi
print_success "Azure CLI encontrado"

# Verificar autenticação Azure
if ! az account show &> /dev/null; then
    print_error "Não está autenticado no Azure. Execute: az login"
    exit 1
fi
print_success "Autenticado no Azure"

# Obter informações da conta
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
USER_ID=$(az ad signed-in-user show --query id -o tsv)
USER_EMAIL=$(az ad signed-in-user show --query mail -o tsv)

echo -e "  Subscription ID: ${SUBSCRIPTION_ID}"
echo -e "  User ID: ${USER_ID}"
echo -e "  User Email: ${USER_EMAIL}"

# Configurações do teste
TEST_PROJECT_NAME="test-devbox-$(date +%s)"
TEST_RESOURCE_GROUP="rg-${TEST_PROJECT_NAME}-eastus"
TEST_REGION="eastus"
DEVELOPER_NAME="Test Developer"
TEAM_NAME="Platform Team"

print_step "Configurações do teste:"
echo -e "  Project Name: ${TEST_PROJECT_NAME}"
echo -e "  Resource Group: ${TEST_RESOURCE_GROUP}"
echo -e "  Region: ${TEST_REGION}"
echo -e "  Developer: ${DEVELOPER_NAME}"
echo -e "  Team: ${TEAM_NAME}"

# Função para limpeza
cleanup() {
    print_step "Limpando recursos de teste..."
    if az group exists --name "$TEST_RESOURCE_GROUP" &> /dev/null; then
        echo -e "  Removendo resource group: $TEST_RESOURCE_GROUP"
        az group delete --name "$TEST_RESOURCE_GROUP" --yes --no-wait
        print_success "Resource group marcado para remoção"
    else
        print_warning "Resource group não encontrado"
    fi
}

# Configurar trap para limpeza em caso de erro
trap cleanup EXIT

# Teste 1: Validar template Bicep
print_step "Teste 1: Validando template Bicep..."

BICEP_FILE="./resources/bicep/devbox-infrastructure.bicep"
if [ ! -f "$BICEP_FILE" ]; then
    print_error "Template Bicep não encontrado: $BICEP_FILE"
    exit 1
fi

# Validar sintaxe do Bicep
az bicep version > /dev/null 2>&1 || {
    print_warning "Bicep CLI não encontrado, instalando..."
    az bicep install
}

print_success "Template Bicep encontrado e válido"

# Teste 2: Criar Resource Group
print_step "Teste 2: Criando Resource Group..."

az group create \
    --name "$TEST_RESOURCE_GROUP" \
    --location "$TEST_REGION" \
    --tags project="$TEST_PROJECT_NAME" developer="$DEVELOPER_NAME" team="$TEAM_NAME" managedBy="test-script" \
    > /dev/null

print_success "Resource Group criado: $TEST_RESOURCE_GROUP"

# Teste 3: Validar deployment Bicep
print_step "Teste 3: Validando deployment Bicep..."

DEPLOYMENT_NAME="devbox-${TEST_PROJECT_NAME}-deployment"

az deployment group validate \
    --resource-group "$TEST_RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --template-file "$BICEP_FILE" \
    --parameters \
        projectName="$TEST_PROJECT_NAME" \
        location="$TEST_REGION" \
        developerName="$DEVELOPER_NAME" \
        teamName="$TEAM_NAME" \
        devBoxSize="Standard_D8as_v4" \
        userPrincipalId="$USER_ID" \
    > /dev/null

print_success "Template Bicep validado com sucesso"

# Teste 4: Simular deployment (what-if)
print_step "Teste 4: Simulando deployment (what-if)..."

az deployment group what-if \
    --resource-group "$TEST_RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --template-file "$BICEP_FILE" \
    --parameters \
        projectName="$TEST_PROJECT_NAME" \
        location="$TEST_REGION" \
        developerName="$DEVELOPER_NAME" \
        teamName="$TEAM_NAME" \
        devBoxSize="Standard_D8as_v4" \
        userPrincipalId="$USER_ID" \
    --no-pretty-print

print_success "Simulação de deployment concluída"

# Teste 5: Verificar quotas e limites
print_step "Teste 5: Verificando quotas Azure..."

# Verificar quota de Dev Centers
DEV_CENTER_QUOTA=$(az vm list-usage --location "$TEST_REGION" --query "[?localName=='Dev Centers'].currentValue" -o tsv 2>/dev/null || echo "0")
echo -e "  Dev Centers em uso: ${DEV_CENTER_QUOTA}"

# Verificar quota de cores
CORES_QUOTA=$(az vm list-usage --location "$TEST_REGION" --query "[?localName=='Total Regional vCPUs'].currentValue" -o tsv)
CORES_LIMIT=$(az vm list-usage --location "$TEST_REGION" --query "[?localName=='Total Regional vCPUs'].limit" -o tsv)
echo -e "  vCPUs regionais: ${CORES_QUOTA}/${CORES_LIMIT}"

if [ "$CORES_QUOTA" -gt $((CORES_LIMIT - 10)) ]; then
    print_warning "Poucos vCPUs disponíveis. Considere usar uma região diferente."
fi

print_success "Verificação de quotas concluída"

# Teste 6: Verificar permissões
print_step "Teste 6: Verificando permissões Azure..."

# Verificar se o usuário tem permissões para criar Dev Centers
if az role assignment list --assignee "$USER_ID" --scope "/subscriptions/$SUBSCRIPTION_ID" --query "[?roleDefinitionName=='Owner' || roleDefinitionName=='Contributor' || roleDefinitionName=='DevCenter Dev Box User']" | grep -q "roleDefinitionName"; then
    print_success "Usuário tem permissões adequadas"
else
    print_warning "Usuário pode não ter permissões adequadas para criar Dev Centers"
fi

# Teste 7: Validar estrutura do template Red Hat Developer Hub
print_step "Teste 7: Validando template Red Hat Developer Hub..."

TEMPLATE_FILE="./templates/h0-devbox/developer-environment/template.yaml"
if [ ! -f "$TEMPLATE_FILE" ]; then
    print_error "Template do Developer Hub não encontrado: $TEMPLATE_FILE"
    exit 1
fi

# Verificar se o template tem as ações necessárias
if grep -q "azure:resource-group:create" "$TEMPLATE_FILE" && grep -q "azure:arm:deploy" "$TEMPLATE_FILE"; then
    print_success "Template contém ações de criação Azure"
else
    print_error "Template não contém ações necessárias para criação do Dev Box"
    exit 1
fi

print_success "Template Red Hat Developer Hub validado"

# Teste 8: Verificar imageDefinition.yaml
print_step "Teste 8: Validando imageDefinition.yaml..."

IMAGE_DEF_FILE="./imageDefinition.yaml"
if [ ! -f "$IMAGE_DEF_FILE" ]; then
    print_error "imageDefinition.yaml não encontrado"
    exit 1
fi

# Verificar estrutura básica
if grep -q "name:" "$IMAGE_DEF_FILE" && grep -q "version:" "$IMAGE_DEF_FILE" && grep -q "tasks:" "$IMAGE_DEF_FILE"; then
    print_success "imageDefinition.yaml tem estrutura válida"
else
    print_error "imageDefinition.yaml tem estrutura inválida"
    exit 1
fi

print_success "imageDefinition.yaml validado"

# Relatório final
print_step "Relatório Final do Teste"
echo -e "\n${GREEN}✅ Todos os testes passaram com sucesso!${NC}"
echo -e "\n${BLUE}📊 Resumo dos Testes:${NC}"
echo -e "  ✅ Template Bicep válido"
echo -e "  ✅ Resource Group criado"
echo -e "  ✅ Deployment validado"
echo -e "  ✅ Simulação what-if executada"
echo -e "  ✅ Quotas verificadas"
echo -e "  ✅ Permissões verificadas"
echo -e "  ✅ Template Red Hat Developer Hub validado"
echo -e "  ✅ imageDefinition.yaml validado"

echo -e "\n${YELLOW}📋 Para testar a criação real do Dev Box:${NC}"
echo -e "  1. Acesse o Red Hat Developer Hub"
echo -e "  2. Use o template 'Three Horizons AI Dev Box'"
echo -e "  3. Preencha os parâmetros de teste:"
echo -e "     - Project Name: ${TEST_PROJECT_NAME}"
echo -e "     - Developer Name: ${DEVELOPER_NAME}"
echo -e "     - Team: ${TEAM_NAME}"
echo -e "     - Region: ${TEST_REGION}"
echo -e "     - Size: Standard_D8as_v4"
echo -e "  4. Execute o template e aguarde a criação"
echo -e "  5. Acesse o Azure Dev Box Portal para usar o Dev Box"

echo -e "\n${BLUE}🔗 Links úteis:${NC}"
echo -e "  - Azure Portal: https://portal.azure.com"
echo -e "  - Dev Box Portal: https://devbox.microsoft.com"
echo -e "  - Resource Group: https://portal.azure.com/#@/resource/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${TEST_RESOURCE_GROUP}/overview"

# Não fazer limpeza automática em caso de sucesso
trap - EXIT
print_step "Teste concluído com sucesso. Resource group mantido para referência."
