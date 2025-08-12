# Service Principal Configuration for Red Hat Developer Hub

## Current Service Principal Details

```json
{
  "servicePrincipal": {
    "displayName": "three-horizon-platform",
    "applicationId": "62ac47b7-e8ea-4ee0-a05a-1a5af8e48cd8",
    "objectId": "18580e0b-f681-4cbf-9239-bc374b7db517",
    "tenantId": "2a156722-5941-4c63-b535-f5370769efc7"
  },
  "credentials": {
    "secretValue": "_D28Q~cZ6.BQa1ZJc-AiPzJqX3OttESQ5przodfG",
    "secretId": "f99c3779-4b4d-47a0-9e59-bfb1e4a8154d"
  }
}
```

## Current Permissions

✅ **Owner Role** - Subscription Level
- Scope: `/subscriptions/aca2dc4a-9d62-4b64-82d4-11e152d98f02`
- Permissions: Full access to manage all resources (`*`)
- Status: **CONFIGURED**

## Required Additional Permissions for Dev Hub

### 1. Azure AI Services
Para provisionar recursos de AI/ML através do Developer Hub:

```bash
# Azure AI Administrator role (recommended for full AI capabilities)
az role assignment create \
  --assignee "62ac47b7-e8ea-4ee0-a05a-1a5af8e48cd8" \
  --role "Azure AI Administrator" \
  --scope "/subscriptions/aca2dc4a-9d62-4b64-82d4-11e152d98f02"

# Cognitive Services Contributor (for OpenAI and other AI services)
az role assignment create \
  --assignee "62ac47b7-e8ea-4ee0-a05a-1a5af8e48cd8" \
  --role "Cognitive Services Contributor" \
  --scope "/subscriptions/aca2dc4a-9d62-4b64-82d4-11e152d98f02"
```

### 2. Dev Box Specific Permissions
Para criar e gerenciar Dev Boxes:

```bash
# DevCenter Dev Box User (for Dev Box operations)
az role assignment create \
  --assignee "62ac47b7-e8ea-4ee0-a05a-1a5af8e48cd8" \
  --role "DevCenter Dev Box User" \
  --scope "/subscriptions/aca2dc4a-9d62-4b64-82d4-11e152d98f02"
```

### 3. Microsoft Graph API Permissions
Para integração com Azure AD e Microsoft Graph:

```bash
# Application permissions that may be needed
az ad app permission add \
  --id "62ac47b7-e8ea-4ee0-a05a-1a5af8e48cd8" \
  --api 00000003-0000-0000-c000-000000000000 \
  --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Role

# Grant admin consent
az ad app permission admin-consent --id "62ac47b7-e8ea-4ee0-a05a-1a5af8e48cd8"
```

## Red Hat Developer Hub Configuration

### Environment Variables for Dev Hub

```yaml
# Azure Service Principal Configuration
AZURE_CLIENT_ID: "62ac47b7-e8ea-4ee0-a05a-1a5af8e48cd8"
AZURE_CLIENT_SECRET: "_D28Q~cZ6.BQa1ZJc-AiPzJqX3OttESQ5przodfG"
AZURE_TENANT_ID: "2a156722-5941-4c63-b535-f5370769efc7"
AZURE_SUBSCRIPTION_ID: "aca2dc4a-9d62-4b64-82d4-11e152d98f02"

# Azure Resource Defaults
AZURE_DEFAULT_LOCATION: "eastus"
AZURE_RESOURCE_GROUP_PREFIX: "rg-devhub"
AZURE_DEVBOX_PROJECT_NAME: "three-horizons-devbox"
```

### Backstage app-config.yaml Integration

```yaml
azure:
  subscriptionId: "aca2dc4a-9d62-4b64-82d4-11e152d98f02"
  tenantId: "2a156722-5941-4c63-b535-f5370769efc7"
  clientId: "62ac47b7-e8ea-4ee0-a05a-1a5af8e48cd8"
  clientSecret: "${AZURE_CLIENT_SECRET}"
  
scaffolder:
  defaultValues:
    azure:
      subscription: "aca2dc4a-9d62-4b64-82d4-11e152d98f02"
      resourceGroupPrefix: "rg-devhub"
      location: "eastus"
```

## Security Best Practices

### 1. Secret Management
- ✅ Store client secret in secure key vault
- ✅ Rotate secret regularly (every 90 days)
- ✅ Use managed identities where possible

### 2. Permission Scoping
- ✅ Owner role provides full access (appropriate for platform scenarios)
- ✅ Consider creating custom roles for more restrictive access if needed
- ✅ Regular permission audits

### 3. Monitoring & Auditing
- ✅ Enable Azure Activity Logs
- ✅ Monitor service principal usage
- ✅ Set up alerts for unusual activity

## Validation Commands

### Test Service Principal Authentication
```bash
# Test login with service principal
az login --service-principal \
  --username "62ac47b7-e8ea-4ee0-a05a-1a5af8e48cd8" \
  --password "_D28Q~cZ6.BQa1ZJc-AiPzJqX3OttESQ5przodfG" \
  --tenant "2a156722-5941-4c63-b535-f5370769efc7"

# Test resource creation
az group create --name "test-devhub-rg" --location "eastus"

# Clean up test
az group delete --name "test-devhub-rg" --yes --no-wait
```

### Verify Permissions
```bash
# List all role assignments
az role assignment list --assignee "62ac47b7-e8ea-4ee0-a05a-1a5af8e48cd8" --all

# Test specific operations
az devbox admin project list
az cognitiveservices account list
```

## Status

- ✅ **Service Principal Created**
- ✅ **Owner Role Assigned** 
- ⏳ **AI Services Roles** - Recommended to add
- ⏳ **Dev Box Roles** - Recommended to add
- ⏳ **Graph API Permissions** - May be needed for full integration
- ⏳ **Dev Hub Configuration** - Ready for setup

## Next Steps

1. Run the additional role assignment commands above
2. Configure Red Hat Developer Hub with the service principal details
3. Test Dev Box provisioning through the Developer Hub
4. Monitor and audit service principal usage
