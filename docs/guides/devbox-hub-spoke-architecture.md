# Azure Dev Box Hub-Spoke Architecture Guide

## Visão Geral

Este guia documenta a implementação da arquitetura hub-spoke para Azure Dev Box na Three Horizons AI Platform, seguindo as melhores práticas do Azure e DevBox.

## Arquitetura Hub-Spoke

### Conceitos

A arquitetura hub-spoke é um padrão recomendado pela Microsoft para Azure Dev Box que oferece:

- **Centralização**: Um Dev Center único que gerencia definições e políticas
- **Isolamento**: Projetos separados para diferentes equipes
- **Governança**: Controle centralizado de políticas e recursos
- **Escalabilidade**: Facilita adição de novos projetos e equipes

### Componentes

#### Hub (Centro)
- **Dev Center**: Recurso central que gerencia definições e conexões de rede
- **Network Connection**: Conectividade de rede para os Dev Boxes
- **Dev Box Definitions**: Configurações padronizadas de máquinas virtuais
- **Políticas**: Controles de governança e segurança

#### Spokes (Projetos)
- **Projects**: Recursos específicos por equipe/departamento
- **Pools**: Grupos de Dev Boxes com configurações específicas
- **RBAC**: Controle de acesso por projeto
- **Auto-Stop**: Configurações de economia de custos

## Implementação

### 1. Estrutura de Recursos

```
Resource Group: rg-{organization}-devbox-{env}-{location}-{instanceId}
├── Dev Center (Hub)
│   ├── Network Connection
│   ├── Dev Box Definition 1 (Standard)
│   ├── Dev Box Definition 2 (Power User)
│   └── Dev Box Definition 3 (Data Science)
├── Project 1 (Spoke)
│   ├── Pool 1
│   └── RBAC Assignments
├── Project 2 (Spoke)
│   ├── Pool 2
│   └── RBAC Assignments
└── Additional Projects...
```

### 2. Templates Bicep

#### devbox-complete.bicep
Template orquestrador principal que coordena o deployment:
- Chama `devbox-hub-architecture.bicep` para criar o hub
- Chama `devbox-project.bicep` para criar o projeto inicial
- Gerencia dependências entre recursos

#### devbox-hub-architecture.bicep
Template para infraestrutura central:
- Dev Center com identity gerenciada
- Network Connection (Microsoft-hosted ou Azure VNet)
- Três definições de Dev Box padrão
- Configurações de rede e segurança

#### devbox-project.bicep
Template para projetos individuais:
- Project específico por equipe
- Pool com configurações personalizadas
- RBAC assignments para desenvolvedores
- Configurações de auto-stop

### 3. Script de Deployment

O script `deploy-devbox-hub.sh` automatiza todo o processo:

```bash
./scripts/deploy-devbox-hub.sh
```

#### Funcionalidades do Script:
- Verificação de autenticação Azure
- Criação de Resource Group com naming conventions
- Validação de templates Bicep
- Deployment da infraestrutura hub-spoke
- Geração de outputs com informações de acesso

## Convenções de Nomenclatura

Seguindo Azure Cloud Adoption Framework (CAF):

### Resource Group
```
rg-{organization}-devbox-{environment}-{location}-{instanceId}
Exemplo: rg-three-horizons-devbox-dev-eastus2-20240101-1200-a1b2c3
```

### Dev Center
```
dc-{organization}-{environment}-{location}-{uniqueSuffix}
Exemplo: dc-three-horizons-dev-eastus2-a1b2c3
```

### Projects
```
project-{projectName}-{environment}-{uniqueSuffix}
Exemplo: project-developer-hub-dev-a1b2c3
```

### Pools
```
pool-{projectName}-{environment}-{uniqueSuffix}
Exemplo: pool-developer-hub-dev-a1b2c3
```

## Definições de Dev Box

### 1. Standard Developer Workstation
- **SKU**: Standard_D4as_v4 (4 vCPUs, 16GB RAM)
- **Uso**: Desenvolvimento básico, web, scripting
- **Custo**: Mais econômico

### 2. Power User Workstation
- **SKU**: Standard_D8as_v4 (8 vCPUs, 32GB RAM)
- **Uso**: Desenvolvimento full-stack, containers, CI/CD
- **Custo**: Médio

### 3. Data Science Workstation
- **SKU**: Standard_D16as_v4 (16 vCPUs, 64GB RAM)
- **Uso**: AI/ML, analytics, processamento pesado
- **Custo**: Mais alto

## Red Hat Developer Hub Integration

### Template Atualizado

O template `h0-devbox/developer-environment/template.yaml` foi atualizado para:

1. **Autenticação Azure**: Service Principal com permissões adequadas
2. **Hub-Spoke Deployment**: Deployment sequencial hub → projeto
3. **Configuração Simplificada**: Menos parâmetros, mais automação
4. **Naming Conventions**: Seguindo padrões Azure CAF

### Parâmetros Principais

```yaml
organization_name: "three-horizons"
project_name: "developer-hub"
location: "eastus2"
environment: "dev"
network_type: "microsoft-hosted"
devbox_definition: "standard-dev-workstation"
```

## Melhores Práticas Implementadas

### 1. Segurança
- **Service Principal**: Permissões mínimas necessárias
- **RBAC**: Controle granular por projeto
- **Network Security**: NSG com regras restritivas
- **Identity**: Managed Identity para Dev Center

### 2. Governança
- **Tags Padronizadas**: Organização, ambiente, projeto, equipe
- **Naming Conventions**: Azure CAF compliant
- **Resource Organization**: Single Resource Group approach

### 3. Economia de Custos
- **Auto-Stop**: Configurável por projeto
- **Right-Sizing**: Múltiplas definições de tamanho
- **Scheduled Operations**: Parada automática em horários configurados

### 4. Escalabilidade
- **Hub Centralizado**: Facilita adição de novos projetos
- **Template Modular**: Reutilização para diferentes equipes
- **Resource Sharing**: Network connections compartilhadas

## Deployment Workflow

### 1. Pré-requisitos
```bash
# Service Principal com permissões:
# - Owner ou Contributor + DevCenter Admin
# - Azure AD: User.Read.All, Directory.Read.All

az login --service-principal \
  --username $SERVICE_PRINCIPAL_ID \
  --password $SERVICE_PRINCIPAL_SECRET \
  --tenant $TENANT_ID
```

### 2. Deployment Automático
```bash
# Clone do repositório
git clone https://github.com/three-horizon-ai/Three-Horizons-AI-Developer-Platform.git
cd Three-Horizons-AI-Developer-Platform

# Execute o script de deployment
./scripts/deploy-devbox-hub.sh
```

### 3. Projetos Adicionais
```bash
# Para adicionar novos projetos após o hub estar criado
az deployment group create \
  --resource-group "rg-three-horizons-devbox-dev-eastus2-20240101-1200-a1b2c3" \
  --template-file "./resources/bicep/devbox-project.bicep" \
  --parameters \
    projectName="data-science-team" \
    devCenterId="/subscriptions/.../devcenters/dc-three-horizons-dev-eastus2-a1b2c3" \
    ...
```

## Monitoramento e Manutenção

### 1. Portal do Desenvolvedor
- **URL**: https://devbox.microsoft.com/
- **Funcionalidades**: Criar, conectar, gerenciar Dev Boxes

### 2. Portal Azure
- **Resource Group**: Visualização completa dos recursos
- **Dev Center**: Gerenciamento de definições e políticas
- **Projects**: Monitoramento por equipe

### 3. Logs e Metrics
- **Activity Logs**: Auditoria de operações
- **Metrics**: Utilização e performance
- **Alerts**: Notificações proativas

## Troubleshooting

### Erros Comuns

#### 1. "DevCenter não encontrado"
```bash
# Verificar se o hub foi deployado corretamente
az resource show --ids "/subscriptions/.../devcenters/dc-three-horizons-dev-eastus2-a1b2c3"
```

#### 2. "Permissões insuficientes"
```bash
# Verificar permissões do Service Principal
az ad signed-in-user show
az role assignment list --assignee $SERVICE_PRINCIPAL_ID
```

#### 3. "Network Connection falhou"
```bash
# Verificar status da network connection
az resource show --ids "/subscriptions/.../networkconnections/nc-three-horizons-dev-eastus2-a1b2c3"
```

## Próximos Passos

1. **Teste da Infraestrutura**: Validar deployment completo
2. **Templates Adicionais**: Criar templates para cenários específicos
3. **CI/CD Integration**: Automatizar com Azure DevOps/GitHub Actions
4. **Cost Management**: Implementar alertas e budgets
5. **Backup/DR**: Estratégias de backup e recuperação

## Recursos Adicionais

- [Azure Dev Box Documentation](https://docs.microsoft.com/azure/dev-box/)
- [Azure Cloud Adoption Framework](https://docs.microsoft.com/azure/cloud-adoption-framework/)
- [Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
- [Red Hat Developer Hub](https://developers.redhat.com/products/developer-hub)
