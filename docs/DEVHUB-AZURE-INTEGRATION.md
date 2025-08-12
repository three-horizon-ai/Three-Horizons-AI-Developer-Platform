# Red Hat Developer Hub - Azure Integration Configuration

## ✅ Service Principal Setup Complete

A Service Principal **three-horizon-platform** foi configurada com sucesso e tem todas as permissões necessárias para provisionar recursos Azure através do Red Hat Developer Hub.

### 🔑 Credenciais (Para configurar no Developer Hub)

```bash
# Environment Variables para Red Hat Developer Hub
export AZURE_CLIENT_ID="62ac47b7-e8ea-4ee0-a05a-1a5af8e48cd8"
export AZURE_CLIENT_SECRET="_D28Q~cZ6.BQa1ZJc-AiPzJqX3OttESQ5przodfG"
export AZURE_TENANT_ID="2a156722-5941-4c63-b535-f5370769efc7"
export AZURE_SUBSCRIPTION_ID="aca2dc4a-9d62-4b64-82d4-11e152d98f02"
```

### 🛡️ Permissões Configuradas

| Role | Scope | Status |
|------|-------|---------|
| **Owner** | Subscription | ✅ Configurado |
| **Azure AI Administrator** | Subscription | ✅ Configurado |
| **Cognitive Services Contributor** | Subscription | ✅ Configurado |
| **DevCenter Dev Box User** | Subscription | ✅ Configurado |
| **Cognitive Services OpenAI Contributor** | Subscription | ✅ Configurado |

### 🎯 Capacidades Habilitadas

Com essas permissões, a Service Principal pode provisionar:

- ✅ **Dev Boxes** - Criação e gestão completa
- ✅ **Azure OpenAI** - Deploy de modelos e endpoints
- ✅ **Azure AI Services** - Cognitive Services, AI Search, etc.
- ✅ **Container Apps** - Para microserviços
- ✅ **App Services** - Para aplicações web
- ✅ **AKS (Azure Kubernetes Service)** - Para orchestração
- ✅ **Storage Accounts** - Para dados e arquivos
- ✅ **Key Vault** - Para gerenciamento de secrets
- ✅ **Resource Groups** - Organização de recursos
- ✅ **Virtual Networks** - Para networking
- ✅ **Load Balancers** - Para distribuição de carga
- ✅ **Databases** - SQL, CosmosDB, PostgreSQL, etc.

## 🔧 Configuração do Red Hat Developer Hub

### 1. app-config.yaml

```yaml
azure:
  # Service Principal Configuration
  subscriptionId: ${AZURE_SUBSCRIPTION_ID}
  tenantId: ${AZURE_TENANT_ID}
  clientId: ${AZURE_CLIENT_ID}
  clientSecret: ${AZURE_CLIENT_SECRET}
  
  # Default Values for Templates
  defaults:
    location: "eastus"
    resourceGroupPrefix: "rg-devhub"
    tags:
      managedBy: "red-hat-developer-hub"
      project: "three-horizons-ai-platform"

scaffolder:
  defaultValues:
    azure:
      subscription: ${AZURE_SUBSCRIPTION_ID}
      resourceGroupPrefix: "rg-devhub"
      location: "eastus"
      devbox:
        imageDefinition: "three-horizons-ai-devbox"
        defaultSize: "Standard_D8as_v4"
```

### 2. Environment Variables (Secret)

No Red Hat Developer Hub, configure estas variáveis como secrets:

```bash
# No OpenShift/Kubernetes
kubectl create secret generic azure-credentials \
  --from-literal=AZURE_CLIENT_ID="62ac47b7-e8ea-4ee0-a05a-1a5af8e48cd8" \
  --from-literal=AZURE_CLIENT_SECRET="_D28Q~cZ6.BQa1ZJc-AiPzJqX3OttESQ5przodfG" \
  --from-literal=AZURE_TENANT_ID="2a156722-5941-4c63-b535-f5370769efc7" \
  --from-literal=AZURE_SUBSCRIPTION_ID="aca2dc4a-9d62-4b64-82d4-11e152d98f02"
```

### 3. Scaffolder Actions

O Developer Hub agora pode usar estas actions para Azure:

```yaml
# Template steps example
steps:
  - id: create-azure-resources
    name: Create Azure Resources
    action: azure:resource-group:create
    input:
      name: "rg-${{ parameters.projectName }}"
      location: ${{ parameters.azureLocation }}
      
  - id: create-devbox
    name: Create Dev Box
    action: azure:devbox:create
    input:
      resourceGroup: "rg-${{ parameters.projectName }}"
      projectName: "${{ parameters.projectName }}-devbox"
      imageDefinition: "three-horizons-ai-devbox"
      size: "${{ parameters.devboxSize }}"
```

## 🧪 Teste de Validação

### Validação Manual

```bash
# 1. Teste de autenticação
az login --service-principal \
  --username "62ac47b7-e8ea-4ee0-a05a-1a5af8e48cd8" \
  --password "_D28Q~cZ6.BQa1ZJc-AiPzJqX3OttESQ5przodfG" \
  --tenant "2a156722-5941-4c63-b535-f5370769efc7"

# 2. Teste de criação de recursos
az group create --name "test-validation" --location "eastus"

# 3. Teste de AI Services
az cognitiveservices account list

# 4. Limpeza
az group delete --name "test-validation" --yes
```

### Status de Validação

- ✅ **Autenticação** - Service Principal autenticada com sucesso
- ✅ **Criação de Resource Group** - Testado e funcionando
- ✅ **Permissões Azure AI** - Configuradas
- ✅ **Permissões Dev Box** - Configuradas
- ✅ **Escopo de Subscription** - Cobertura completa

## 🚀 Próximos Passos

1. **Configurar Developer Hub** com as credenciais da Service Principal
2. **Testar templates** de Dev Box através da interface
3. **Implementar workflows** de CI/CD para provisioning
4. **Configurar monitoring** e auditing de recursos
5. **Estabelecer governance** e policies de segurança

## 🔐 Segurança e Governança

### Rotação de Secrets
- Secret atual válido até: **Não especificado** (recomenda-se rotação em 90 dias)
- Próxima rotação: **Novembro 2025**

### Monitoramento
- Activity Logs habilitados para auditoria
- Alertas configurados para uso indevido
- Review trimestral de permissões

### Compliance
- Permissões seguem princípio de least privilege onde aplicável
- Owner role justificada para scenarios de platform engineering
- Todas as ações auditadas via Azure Activity Logs

---

**Status: ✅ PRONTO PARA PRODUÇÃO**

A Service Principal está completamente configurada e pronta para uso no Red Hat Developer Hub para provisionar recursos do Three Horizons AI Platform.
