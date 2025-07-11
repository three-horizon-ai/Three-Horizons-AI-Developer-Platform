# Azure Infrastructure Setup - Horizon 1 Foundation

This template creates basic Azure infrastructure components for Horizon 1 Foundation applications.

## What gets deployed

### Core Infrastructure
- **Resource Group**: Container for all resources
- **Azure Container Registry (ACR)**: For storing container images
- **Azure Key Vault**: For secure storage of secrets and certificates
- **Log Analytics Workspace**: For centralized logging and monitoring

### Optional Kubernetes Platforms
- **Azure Kubernetes Service (AKS)**: Managed Kubernetes cluster (optional)
- **Azure Red Hat OpenShift (ARO)**: Enterprise Kubernetes platform (optional)

## Prerequisites

- Azure subscription with appropriate permissions
- GitHub repository for the infrastructure code
- Azure CLI or Azure PowerShell (for deployment)

## Parameters

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `name` | Base name for all resources | - | Yes |
| `environment` | Environment (dev/test/prod) | dev | Yes |
| `azureLocation` | Primary Azure region | - | Yes |
| `secondaryLocation` | Secondary Azure region | - | No |
| `subscriptionId` | Azure subscription ID | - | Yes |
| `deployAKS` | Deploy AKS cluster | false | No |
| `deployARO` | Deploy ARO cluster | false | No |

## Usage

1. **Create from Backstage**: Use the "H1: Azure Infrastructure Setup" template
2. **Fill parameters**: Provide the required configuration
3. **Deploy**: The template will create a GitHub repository with infrastructure code
4. **Run deployment**: Execute the Bicep templates to create Azure resources

## Deployment

After the template creates your repository, deploy the infrastructure:

```bash
# Login to Azure
az login

# Set subscription
az account set --subscription "your-subscription-id"

# Deploy infrastructure
az deployment sub create \
  --location "your-location" \
  --template-file infrastructure/main.bicep \
  --parameters name="your-app-name" environment="dev"
```

## Security Considerations

- Key Vault uses RBAC authorization by default
- AKS cluster has Azure Policy and monitoring enabled
- Container Registry allows admin access (disable in production)
- All resources are tagged for governance

## Monitoring

- Log Analytics workspace collects logs from AKS
- Azure Monitor provides metrics and alerting
- Container insights enabled for AKS cluster

## Next Steps

1. Configure authentication and access policies
2. Set up CI/CD pipelines for applications
3. Configure monitoring and alerting rules
4. Implement backup and disaster recovery

## Support

For issues or questions about this template, please create an issue in the repository or contact the platform team.
