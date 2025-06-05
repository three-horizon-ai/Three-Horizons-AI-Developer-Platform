# Three Horizons Platform - Bicep Templates

This directory contains Bicep templates for provisioning the complete Three Horizons Platform infrastructure on Azure.

## 📁 Structure

```
bicep/
├── main/                    # Main templates
│   └── complete-infrastructure.bicep
├── modules/                 # Reusable modules
│   ├── aks-cluster.bicep   # Azure Kubernetes Service
│   ├── aro-cluster.bicep   # Azure Red Hat OpenShift
│   ├── containerregistry.bicep
│   ├── keyvault.bicep
│   ├── loganalytics.bicep
│   ├── managedidentity.bicep
│   ├── network.bicep
│   ├── postgresql.bicep
│   └── storageaccount.bicep
└── parameters/             # Parameter files
    ├── dev.parameters.json
    └── prod.parameters.json
```

## 🚀 Quick Deploy

### Prerequisites

1. Azure CLI installed and configured
2. Contributor permissions on the subscription
3. Secure password for PostgreSQL

### Complete Deployment

```bash
# Login to Azure
az login

# Set subscription
az account set --subscription "<your-subscription-id>"

# Deploy to development environment
az deployment sub create \
  --location centralus \
  --template-file main/complete-infrastructure.bicep \
  --parameters parameters/dev.parameters.json \
  --parameters postgresAdminPassword="<secure-password>" \
  --name "threehorizons-dev-$(date +%Y%m%d%H%M%S)"

# Deploy to production
az deployment sub create \
  --location centralus \
  --template-file main/complete-infrastructure.bicep \
  --parameters parameters/prod.parameters.json \
  --parameters postgresAdminPassword="<secure-password>" \
  --parameters aroPullSecret="<pull-secret>" \
  --parameters aroClientId="<sp-client-id>" \
  --parameters aroClientSecret="<sp-client-secret>" \
  --name "threehorizons-prod-$(date +%Y%m%d%H%M%S)"
```

## 📋 Resources Created

### Resource Groups
- **Platform**: Network and cluster resources
- **Shared**: Shared resources (ACR, Key Vault, etc)
- **DevBox**: Development resources

### Main Resources

| Resource | Module | Description |
|---------|---------|-----------|
| Virtual Network | network.bicep | Network with subnets for AKS, ARO, services, and endpoints |
| AKS Cluster | aks-cluster.bicep | Kubernetes with OIDC, Workload Identity, and Azure RBAC |
| ARO Cluster | aro-cluster.bicep | Managed OpenShift 4 (optional) |
| Container Registry | containerregistry.bicep | Registry with geo-replication |
| Key Vault | keyvault.bicep | Secure secrets storage |
| PostgreSQL | postgresql.bicep | Database for Backstage |
| Log Analytics | loganalytics.bicep | Centralized monitoring |
| Storage Account | storageaccount.bicep | Storage for DevBox and scripts |
| Managed Identities | managedidentity.bicep | Identities for workload identity |

## 🔧 Customization

### Main Parameters

| Parameter | Description | Default |
|-----------|-----------|---------|
| baseName | Base name for resources | threehorizons |
| environment | Environment (dev/test/prod) | prod |
| location | Primary region | centralus |
| secondaryLocation | Secondary region (replication) | eastus2 |
| deployAKS | Deploy AKS cluster | true |
| deployARO | Deploy ARO cluster | false |

### Tags

All resources are automatically tagged:
- Environment
- Project
- ManagedBy
- CostCenter (customizable)
- BusinessUnit (customizable)
- SLA (production)

## 🔒 Security

### Implemented Security Features

1. **Network Security**
   - Isolated subnets by function
   - Service endpoints enabled
   - Private endpoints for critical resources

2. **Identity & Access**
   - Managed identities for all services
   - RBAC on AKS and Key Vault
   - Workload Identity for pods

3. **Data Protection**
   - Encryption at rest enabled
   - Key Vault with soft delete and purge protection
   - PostgreSQL with geo-redundant backup

4. **Compliance**
   - Azure Policy enabled on AKS
   - Microsoft Defender for containers
   - Log Analytics for auditing

## 📊 Monitoring

### Logs and Metrics

- **Log Analytics Workspace**: Centralizes logs from all resources
- **Container Insights**: AKS monitoring
- **Azure Monitor**: Metrics and alerts

### Recommended Dashboards

1. Create Azure Portal dashboard with:
   - Cluster health
   - Resource usage
   - Costs by resource group
   - Application metrics

## 🔄 CI/CD Integration

### GitHub Actions

```yaml
- name: Deploy Infrastructure
  uses: azure/arm-deploy@v1
  with:
    subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
    scope: subscription
    region: centralus
    template: ./resources/bicep/main/complete-infrastructure.bicep
    parameters: ./resources/bicep/parameters/${{ env.ENVIRONMENT }}.parameters.json
    deploymentName: threehorizons-${{ env.ENVIRONMENT }}-${{ github.run_number }}
```

### Azure DevOps

```yaml
- task: AzureResourceManagerTemplateDeployment@3
  inputs:
    deploymentScope: 'Subscription'
    azureResourceManagerConnection: 'Azure Service Connection'
    subscriptionId: '$(subscriptionId)'
    location: 'centralus'
    templateLocation: 'Linked artifact'
    csmFile: '$(Build.SourcesDirectory)/resources/bicep/main/complete-infrastructure.bicep'
    csmParametersFile: '$(Build.SourcesDirectory)/resources/bicep/parameters/$(environment).parameters.json'
    deploymentMode: 'Incremental'
```

## 🛠️ Troubleshooting

### Common Issues

1. **Unique name error**
   - Solution: Template uses uniqueString() to generate unique names

2. **Quota exceeded**
   - Check quotas: `az vm list-usage --location centralus`
   - Request increase if needed

3. **Subnet conflicts**
   - Verify IP ranges don't conflict
   - Adjust in network.bicep module if needed

### Validation

```bash
# Validate template before deployment
az deployment sub validate \
  --location centralus \
  --template-file main/complete-infrastructure.bicep \
  --parameters parameters/dev.parameters.json
```

## 📚 References

- [Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
- [Three Horizons Complete Integration Tutorial](../../docs/complete-integration-tutorial/index.md)
- [Azure Architecture Center](https://docs.microsoft.com/azure/architecture/)

## 🤝 Contributing

1. Always test in dev environment first
2. Use parameter files for different environments
3. Document significant changes
4. Follow Azure naming conventions

## 📝 Next Steps

After infrastructure deployment:

1. Configure GitHub integration
2. Deploy Red Hat Developer Hub
3. Configure CI/CD pipelines
4. Implement sample applications

For more details, see the [Complete Integration Tutorial](../../docs/complete-integration-tutorial/index.md). 