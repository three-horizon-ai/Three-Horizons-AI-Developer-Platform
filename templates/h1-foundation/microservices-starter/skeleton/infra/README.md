# Three Horizons AI Platform - Infrastructure Templates

This directory contains Azure Bicep templates that follow Microsoft Cloud Adoption Framework (CAF) best practices and implement security-by-default configurations for enterprise deployments.

## 📋 Overview

The infrastructure templates are designed following these principles:

- **Security by Default**: All resources are configured with enhanced security settings
- **Azure CAF Compliance**: Resource naming follows Cloud Adoption Framework standards
- **Zero Trust Architecture**: Network security with principle of least privilege
- **Managed Identity Authentication**: No shared keys or connection strings
- **Comprehensive Monitoring**: Integrated logging and diagnostics
- **Cost Optimization**: Lifecycle policies and appropriate SKUs per environment

## 🏗️ Template Architecture

### Core Infrastructure (`main.bicep`)

Deploys the foundational Azure infrastructure including:

- **Compute**: Azure Kubernetes Service (AKS) with security hardening
- **Networking**: Virtual Network with segmented subnets and Network Security Groups
- **Security**: Key Vault with RBAC and network restrictions
- **Storage**: Azure Container Registry and Storage Account with enhanced security
- **Monitoring**: Log Analytics Workspace and Application Insights
- **Identity**: User-assigned Managed Identity for secure service-to-service authentication

### Storage Services (`storage-services.bicep`)

Configures advanced storage features including:

- **Blob Services**: Versioning, change feed, and retention policies
- **Lifecycle Management**: Automatic data tiering and cleanup policies
- **Security**: CORS configuration and access controls
- **Containers**: Pre-configured containers for application data, configuration, backups, and logs

## 🚀 Deployment Guide

### Prerequisites

1. **Azure CLI** installed and configured
2. **Bicep CLI** installed (`az bicep install`)
3. **Azure subscription** with appropriate permissions
4. **Azure AD Object ID** for Key Vault administrator access

### Step 1: Prepare Parameters

1. Copy the parameter file template:
   ```bash
   cp main.parameters.json main.parameters.dev.json
   ```

2. Update the parameters file with your specific values:
   ```json
   {
     "administratorObjectId": {
       "value": "YOUR_AZURE_AD_OBJECT_ID"
     },
     "resourceBaseName": {
       "value": "th3horiz"
     },
     "environment": {
       "value": "dev"
     }
   }
   ```

### Step 2: Get Your Azure AD Object ID

```bash
# Get your current user's object ID
az ad signed-in-user show --query id -o tsv

# Or get object ID for a specific user
az ad user show --id "user@domain.com" --query id -o tsv
```

### Step 3: Deploy Infrastructure

1. **Create Resource Group**:
   ```bash
   az group create \
     --name "rg-th3horiz-dev-eastus-001" \
     --location "East US" \
     --tags project=three-horizons-ai environment=dev
   ```

2. **Validate Template**:
   ```bash
   az deployment group validate \
     --resource-group "rg-th3horiz-dev-eastus-001" \
     --template-file main.bicep \
     --parameters @main.parameters.dev.json
   ```

3. **Deploy Core Infrastructure**:
   ```bash
   az deployment group create \
     --resource-group "rg-th3horiz-dev-eastus-001" \
     --template-file main.bicep \
     --parameters @main.parameters.dev.json \
     --name "three-horizons-infra-$(date +%Y%m%d-%H%M%S)"
   ```

4. **Deploy Storage Services** (after core infrastructure):
   ```bash
   # Get storage account name from previous deployment
   STORAGE_ACCOUNT_NAME=$(az deployment group show \
     --resource-group "rg-th3horiz-dev-eastus-001" \
     --name "three-horizons-infra-TIMESTAMP" \
     --query "properties.outputs.storageAccountName.value" -o tsv)

   # Deploy storage services
   az deployment group create \
     --resource-group "rg-th3horiz-dev-eastus-001" \
     --template-file storage-services.bicep \
     --parameters storageAccountName=$STORAGE_ACCOUNT_NAME environment=dev \
     --name "three-horizons-storage-$(date +%Y%m%d-%H%M%S)"
   ```

## 🔧 Configuration Options

### Environment-Specific Settings

| Parameter | Development | Staging | Production |
|-----------|-------------|---------|------------|
| `environment` | `dev` | `staging` | `prod` |
| AKS Node Count | 2 | 2 | 3 |
| VM Size | Standard_D2s_v5 | Standard_D2s_v5 | Standard_D4s_v5 |
| Storage Redundancy | LRS | LRS | ZRS |
| Key Vault SKU | Standard | Standard | Premium |
| Log Retention | 30 days | 30 days | 90 days |
| Availability Zones | Single | Single | Multi |

### Network Configuration

Default network configuration uses RFC 1918 private address space:

- **VNet CIDR**: `10.0.0.0/16`
- **AKS Subnet**: `10.0.1.0/24`
- **Services Subnet**: `10.0.2.0/24`
- **Private Endpoints**: `10.0.3.0/24`

Update these in the parameters file if you need different addressing.

### Security Features

- **Network Security Groups**: Restrictive rules with deny-all default
- **Private Networking**: Service endpoints for secure connectivity
- **Key Vault**: RBAC-enabled with network restrictions
- **Storage Account**: Shared key access disabled, Azure AD only
- **AKS**: Azure Policy enabled, RBAC with Azure AD integration
- **Container Registry**: Admin user disabled, managed identity access

## 📊 Monitoring & Observability

### Diagnostic Settings

All resources are configured with diagnostic settings that forward logs and metrics to Log Analytics:

- **Key Vault**: Audit logs and metrics
- **Container Registry**: Login, repository, and pull events
- **Storage Account**: Transaction metrics
- **AKS**: Container insights and audit logs

### Application Insights

Application performance monitoring is configured with:

- **Workspace-based**: Connected to Log Analytics for centralized logging
- **Sampling**: Optimized for cost and performance
- **Instrumentation**: Ready for application integration

## 🔐 Security Best Practices

### Identity & Access Management

1. **Managed Identity**: All inter-service authentication uses managed identities
2. **RBAC**: Role-based access control with principle of least privilege
3. **Key Vault**: Centralized secrets management with audit logging
4. **Network Security**: Multi-layered network security with NSGs and service endpoints

### Data Protection

1. **Encryption**: All data encrypted in transit (TLS 1.2+) and at rest
2. **Backup**: Automated backup with configurable retention
3. **Versioning**: Blob versioning enabled for production environments
4. **Lifecycle Management**: Automatic data tiering and cleanup

### Compliance

- **Azure Policy**: Compliance monitoring and enforcement
- **Audit Logging**: Comprehensive audit trail for all resource activities
- **Network Isolation**: Private networking with restricted public access
- **Access Reviews**: Regular RBAC access reviews recommended

## 🎯 Post-Deployment Steps

### 1. Verify Deployment

```bash
# Check resource deployment status
az deployment group list \
  --resource-group "rg-th3horiz-dev-eastus-001" \
  --query "[].{Name:name, State:properties.provisioningState}" -o table

# Verify AKS cluster
az aks get-credentials \
  --resource-group "rg-th3horiz-dev-eastus-001" \
  --name "aks-th3horiz-dev-eastus-001" \
  --admin

kubectl get nodes
```

### 2. Configure Application Access

```bash
# Get managed identity details
az identity show \
  --resource-group "rg-th3horiz-dev-eastus-001" \
  --name "id-th3horiz-dev-eastus-001" \
  --query "{ClientId:clientId, PrincipalId:principalId}"

# Get Key Vault URI
az keyvault show \
  --resource-group "rg-th3horiz-dev-eastus-001" \
  --name "kv-th3horiz-dev-eastus-001" \
  --query "properties.vaultUri"
```

### 3. Test Connectivity

```bash
# Test Key Vault access
az keyvault secret set \
  --vault-name "kv-th3horiz-dev-eastus-001" \
  --name "test-secret" \
  --value "Hello World"

# Test Container Registry access
az acr login --name "crth3horizdev[unique]"
```

## 🚨 Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure you have Contributor and User Access Administrator roles
2. **Name Conflicts**: Resource names must be globally unique (Storage, Key Vault, ACR)
3. **Quota Limits**: Verify subscription quotas for VM cores and other resources
4. **Network Conflicts**: Ensure VNet CIDR doesn't conflict with existing networks

### Useful Commands

```bash
# View deployment errors
az deployment group list \
  --resource-group "rg-th3horiz-dev-eastus-001" \
  --query "[?properties.provisioningState=='Failed']"

# Check activity logs
az monitor activity-log list \
  --resource-group "rg-th3horiz-dev-eastus-001" \
  --max-events 50

# Validate Bicep template
az deployment group validate \
  --resource-group "rg-th3horiz-dev-eastus-001" \
  --template-file main.bicep \
  --parameters @main.parameters.dev.json
```

## 📚 Additional Resources

- [Azure Cloud Adoption Framework](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/)
- [Azure Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Kubernetes Service Best Practices](https://docs.microsoft.com/en-us/azure/aks/best-practices)
- [Azure Key Vault Security](https://docs.microsoft.com/en-us/azure/key-vault/general/security-features)
- [Azure Storage Security Guide](https://docs.microsoft.com/en-us/azure/storage/common/storage-security-guide)

## 🤝 Contributing

When modifying these templates:

1. Follow the established naming conventions
2. Maintain security-by-default principles
3. Update documentation for any new parameters
4. Test in development environment first
5. Use semantic versioning for template updates

For questions or issues, refer to the platform team documentation or create an issue in the repository.
