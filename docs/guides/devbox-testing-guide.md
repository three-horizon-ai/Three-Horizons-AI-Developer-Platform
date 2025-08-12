# Guia de Teste: Three Horizons AI Dev Box Template

Este guia detalha como testar a criação de Azure Dev Box através do template do Red Hat Developer Hub.

## 📋 Pré-requisitos

### 1. Azure
- ✅ Conta Azure ativa
- ✅ Subscription com permissões de Owner/Contributor
- ✅ Azure CLI instalado e autenticado
- ✅ Service Principal configurado (three-horizon-platform)

### 2. Red Hat Developer Hub
- ✅ Instance do Red Hat Developer Hub configurada
- ✅ Integração Azure configurada
- ✅ Template Three Horizons AI Dev Box importado

### 3. Ferramentas Locais
- ✅ Azure CLI (`az --version`)
- ✅ Bicep CLI (`az bicep version`)
- ✅ Git
- ✅ Bash/Zsh

## 🧪 Testes Automatizados

### Executar Script de Validação

```bash
# Navegar para o diretório do projeto
cd /Users/paulasilva/Documents/paulasilvatech/GH-Repos/Three-Horizons-AI-Developer-Platform

# Executar script de teste
./scripts/test-devbox-creation.sh
```

### O que o script testa:

1. **Validação do Template Bicep**
   - ✅ Sintaxe correta
   - ✅ Parâmetros válidos
   - ✅ Recursos definidos

2. **Criação de Resource Group**
   - ✅ Permissões adequadas
   - ✅ Naming convention
   - ✅ Tags aplicadas

3. **Validação de Deployment**
   - ✅ Template válido
   - ✅ Parâmetros corretos
   - ✅ What-if analysis

4. **Verificação de Quotas**
   - ✅ vCPUs disponíveis
   - ✅ Dev Centers quota
   - ✅ Regional limits

5. **Validação de Permissões**
   - ✅ User permissions
   - ✅ Service Principal roles
   - ✅ RBAC assignments

6. **Template Red Hat Developer Hub**
   - ✅ Estrutura YAML válida
   - ✅ Ações Azure definidas
   - ✅ Parâmetros corretos

7. **ImageDefinition.yaml**
   - ✅ Syntax válida
   - ✅ Tasks configuradas
   - ✅ Tools incluídas

## 🚀 Teste Manual no Red Hat Developer Hub

### Passo 1: Acessar o Developer Hub

1. Faça login no Red Hat Developer Hub
2. Navegue para **Create** → **Templates**
3. Localize **Three Horizons AI Dev Box - Complete Development Environment**

### Passo 2: Configurar Parâmetros de Teste

#### Azure Dev Box Configuration
- **Dev Box Size**: `Standard_D8as_v4` (Medium)
- **Azure Region**: `East US`
- **Use Three Horizons Image Definition**: `✅ Enabled`

#### Developer Information
- **Developer Name**: `Test Developer`
- **Team**: `Platform Team`
- **Preferred Shell**: `zsh`

#### Development Stack
- **Programming Languages**: 
  - ✅ nodejs
  - ✅ python
  - ✅ dotnet

- **Cloud Tools**:
  - ✅ azure-cli
  - ✅ kubectl
  - ✅ helm
  - ✅ docker
  - ✅ bicep

- **AI/ML Tools**:
  - ✅ azure-ai-cli
  - ✅ jupyter
  - ✅ langchain

#### VS Code Configuration
- **VS Code Extensions**:
  - ✅ github.copilot
  - ✅ github.copilot-chat
  - ✅ ms-azuretools.vscode-azureresourcegroups
  - ✅ ms-kubernetes-tools.vscode-kubernetes-tools

- **Custom Workspace Settings**: `✅ Enabled`

#### Azure Configuration
- **Setup Azure Authentication**: `✅ Enabled`
- **Azure Subscription ID**: `[Seu Subscription ID]`
- **Setup AKS Access**: `✅ Enabled`

#### Repository Settings
- **Repository Name**: `test-three-horizons-devbox`
- **Include Sample Code**: `✅ Enabled`

### Passo 3: Executar Template

1. Clique em **Create**
2. Aguarde o processamento (pode levar 5-10 minutos)
3. Monitore o progresso através dos logs

### Passo 4: Verificar Criação

#### No Azure Portal
1. Acesse [Azure Portal](https://portal.azure.com)
2. Navegue para Resource Groups
3. Localize: `rg-testthreehorizonsdevbox-eastus`
4. Verifique recursos criados:
   - ✅ Dev Center
   - ✅ Dev Box Project
   - ✅ Network Connection
   - ✅ Virtual Network
   - ✅ Dev Box Pool

#### No Dev Box Portal
1. Acesse [Azure Dev Box Portal](https://devbox.microsoft.com)
2. Verifique se o projeto aparece
3. Crie um novo Dev Box usando o pool criado
4. Aguarde provisionamento (10-15 minutos)

## 🔍 Verificação de Funcionalidades

### Depois de conectar ao Dev Box:

1. **Verificar Tools Instaladas**
   ```powershell
   # Verificar Azure CLI
   az --version
   
   # Verificar Node.js
   node --version
   npm --version
   
   # Verificar Python
   python --version
   pip --version
   
   # Verificar .NET
   dotnet --version
   
   # Verificar Docker
   docker --version
   
   # Verificar Kubectl
   kubectl version --client
   
   # Verificar Bicep
   az bicep version
   ```

2. **Verificar VS Code Extensions**
   ```powershell
   # Abrir VS Code
   code .
   
   # Verificar extensions instaladas
   code --list-extensions
   ```

3. **Verificar Repository Clonado**
   ```powershell
   # Verificar se repositório foi clonado
   Get-ChildItem C:\Workspaces\Three-Horizons-AI-Developer-Platform
   ```

4. **Verificar Configurações Azure**
   ```powershell
   # Verificar autenticação (se configurada)
   az account show
   
   # Verificar subscription
   az account list
   ```

## 📊 Critérios de Sucesso

### ✅ Template Execution
- [ ] Template executa sem erros
- [ ] Todas as ações completam com sucesso
- [ ] Resource Group criado
- [ ] Recursos Azure provisionados

### ✅ Dev Box Creation
- [ ] Dev Box aparece no portal
- [ ] Connection funciona
- [ ] RDP/Browser access disponível
- [ ] Performance adequada

### ✅ Tools Installation
- [ ] Todas as tools especificadas instaladas
- [ ] VS Code extensions funcionando
- [ ] Repository clonado corretamente
- [ ] Scripts de setup executados

### ✅ Azure Integration
- [ ] Autenticação Azure funciona
- [ ] Subscription correta configurada
- [ ] Permissions adequadas
- [ ] AKS access (se configurado)

## 🐛 Troubleshooting

### Problemas Comuns

#### 1. "Insufficient permissions"
```bash
# Verificar permissions do Service Principal
az role assignment list --assignee 62ac47b7-e8ea-4ee0-a05a-1a5af8e48cd8 --all
```

#### 2. "Quota exceeded"
```bash
# Verificar quotas regionais
az vm list-usage --location eastus --output table
```

#### 3. "Network connection failed"
```bash
# Verificar network configuration
az network vnet list --resource-group rg-testthreehorizonsdevbox-eastus
```

#### 4. "Dev Box provisioning failed"
```bash
# Verificar logs de deployment
az deployment group show --resource-group rg-testthreehorizonsdevbox-eastus --name devbox-test-three-horizons-devbox-deployment
```

### Logs e Debugging

#### Azure Activity Log
```bash
# Ver activity logs
az monitor activity-log list --resource-group rg-testthreehorizonsdevbox-eastus --max-events 50
```

#### Red Hat Developer Hub Logs
1. Acesse interface do Developer Hub
2. Navegue para Task execution logs
3. Verifique cada step individualmente

## 🧹 Cleanup

### Após Teste Bem-sucedido
```bash
# Remover recursos de teste
az group delete --name rg-testthreehorizonsdevbox-eastus --yes --no-wait
```

### Limpeza Completa
```bash
# Script de cleanup automático
./scripts/test-devbox-creation.sh --cleanup
```

## 📞 Suporte

### Em caso de problemas:

1. **Verificar documentação**: [Three Horizons Docs](../docs/)
2. **Logs de deployment**: Azure Portal → Resource Group → Deployments
3. **Service Principal**: Verificar roles e permissions
4. **Quotas**: Verificar limits regionais
5. **Network**: Verificar conectividade e DNS

### Contatos:
- **Platform Team**: platform-team@three-horizons.ai
- **Azure Support**: Via Azure Portal
- **Red Hat Support**: Via Red Hat Customer Portal

---

Este guia garante que todos os aspectos do template sejam testados adequadamente antes da disponibilização para desenvolvedores.
