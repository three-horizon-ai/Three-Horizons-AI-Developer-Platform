#!/bin/bash

# Quick Validation Script para o Template Three Horizons AI Dev Box
# Use este script para uma validação rápida antes de usar no Red Hat Developer Hub

set -e

echo "🔍 Validação Rápida - Three Horizons AI Dev Box Template"
echo "===================================================="

# Verificar arquivos essenciais
echo "📁 Verificando arquivos essenciais..."

FILES=(
    "./templates/h0-devbox/developer-environment/template.yaml"
    "./resources/bicep/devbox-infrastructure.bicep"
    "./imageDefinition.yaml"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file - ARQUIVO NÃO ENCONTRADO"
        exit 1
    fi
done

# Verificar Azure CLI e autenticação
echo -e "\n🔐 Verificando Azure CLI..."
if command -v az &> /dev/null; then
    echo "  ✅ Azure CLI instalado"
    if az account show &> /dev/null; then
        echo "  ✅ Autenticado no Azure"
        SUBSCRIPTION_ID=$(az account show --query id -o tsv)
        echo "  📋 Subscription: $SUBSCRIPTION_ID"
    else
        echo "  ❌ Não autenticado no Azure. Execute: az login"
        exit 1
    fi
else
    echo "  ❌ Azure CLI não instalado"
    exit 1
fi

# Verificar sintaxe do template YAML
echo -e "\n📋 Verificando template YAML..."
if command -v python3 &> /dev/null; then
    python3 -c "
import yaml
import sys
try:
    with open('./templates/h0-devbox/developer-environment/template.yaml', 'r') as f:
        yaml.safe_load(f)
    print('  ✅ Template YAML válido')
except Exception as e:
    print(f'  ❌ Erro no template YAML: {e}')
    sys.exit(1)
"
else
    echo "  ⚠️  Python3 não encontrado, pulando validação YAML"
fi

# Verificar template Bicep
echo -e "\n🏗️  Verificando template Bicep..."
if az bicep version &> /dev/null; then
    if az bicep build --file ./resources/bicep/devbox-infrastructure.bicep --stdout > /dev/null; then
        echo "  ✅ Template Bicep compila corretamente"
    else
        echo "  ❌ Erro na compilação do template Bicep"
        exit 1
    fi
else
    echo "  ⚠️  Bicep CLI não encontrado, instalando..."
    az bicep install
fi

# Verificar imageDefinition.yaml
echo -e "\n🖥️  Verificando imageDefinition.yaml..."
if grep -q "name:\|version:\|tasks:" ./imageDefinition.yaml; then
    echo "  ✅ imageDefinition.yaml tem estrutura básica"
else
    echo "  ❌ imageDefinition.yaml com estrutura incorreta"
    exit 1
fi

# Verificar Service Principal (se disponível)
echo -e "\n👤 Verificando Service Principal..."
SP_ID="62ac47b7-e8ea-4ee0-a05a-1a5af8e48cd8"
if az ad sp show --id "$SP_ID" &> /dev/null; then
    echo "  ✅ Service Principal encontrado: $SP_ID"
    
    # Verificar roles principais
    ROLES=$(az role assignment list --assignee "$SP_ID" --query "[].roleDefinitionName" -o tsv)
    if echo "$ROLES" | grep -q "Owner\|Contributor"; then
        echo "  ✅ Service Principal tem permissões adequadas"
    else
        echo "  ⚠️  Service Principal pode não ter permissões suficientes"
    fi
else
    echo "  ⚠️  Service Principal não encontrado ou sem acesso"
fi

echo -e "\n✅ Validação concluída com sucesso!"
echo -e "\n📋 Próximos passos:"
echo "  1. Acesse o Red Hat Developer Hub"
echo "  2. Use o template 'Three Horizons AI Dev Box'"
echo "  3. Preencha os parâmetros conforme o guia de teste"
echo "  4. Execute o template"
echo "  5. Monitore a criação no Azure Portal"
echo -e "\n🔗 Links úteis:"
echo "  - Azure Portal: https://portal.azure.com"
echo "  - Dev Box Portal: https://devbox.microsoft.com"
echo "  - Subscription: https://portal.azure.com/#@/resource/subscriptions/$SUBSCRIPTION_ID/overview"
