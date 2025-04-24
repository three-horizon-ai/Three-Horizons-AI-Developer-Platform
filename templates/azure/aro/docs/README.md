# Deploying Developer Hub on Azure Red Hat OpenShift (ARO)

This guide provides step-by-step instructions for deploying the Three Horizons Platform's Developer Hub on Azure Red Hat OpenShift.

## Prerequisites

- Azure subscription with Owner or Contributor access
- Red Hat account with appropriate entitlements
- Azure CLI installed and configured
- OpenShift CLI (oc) installed
- GitHub account with administrative access to your organization

## Architecture

The deployment uses the following Azure resources:

- Azure Red Hat OpenShift cluster
- Azure Container Registry (ACR)
- Azure Key Vault
- Azure Monitor
- Azure Active Directory
- Azure Virtual Network and Subnets

## Deployment Steps

### 1. Set up Environment Variables

```bash
# Set environment variables
RESOURCE_GROUP="three-horizons-devhub"
LOCATION="centralus"
ARO_CLUSTER_NAME="devhub-aro"
ACR_NAME="devhubacr$(date +%s)"
KEYVAULT_NAME="th3horizons$(date +%s)"
VNET_NAME="devhub-vnet"
MASTER_SUBNET="master-subnet"
WORKER_SUBNET="worker-subnet"
ARO_DOMAIN="devhub.example.com"
```

### 2. Create Resource Group

```bash
# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION
```

### 3. Deploy Network Infrastructure

```bash
# Create virtual network and subnets
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME \
  --address-prefixes 10.0.0.0/16

# Create master subnet
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $MASTER_SUBNET \
  --address-prefixes 10.0.0.0/24 \
  --service-endpoints Microsoft.ContainerRegistry

# Create worker subnet
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $WORKER_SUBNET \
  --address-prefixes 10.0.1.0/24 \
  --service-endpoints Microsoft.ContainerRegistry
```

### 4. Deploy Azure Container Registry

```bash
# Create container registry
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Standard \
  --admin-enabled false
```

### 5. Deploy Key Vault

```bash
# Create key vault
az keyvault create \
  --resource-group $RESOURCE_GROUP \
  --name $KEYVAULT_NAME \
  --location $LOCATION \
  --enable-rbac-authorization true
```

### 6. Register the ARO Resource Provider

```bash
# Register resource providers if not already registered
az provider register -n Microsoft.RedHatOpenShift --wait
az provider register -n Microsoft.Compute --wait
az provider register -n Microsoft.Storage --wait
az provider register -n Microsoft.Network --wait
```

### 7. Create Service Principal for ARO

```bash
# Create service principal
SP=$(az ad sp create-for-rbac --name "devhub-aro-sp" --output json)
SP_ID=$(echo $SP | jq -r .appId)
SP_SECRET=$(echo $SP | jq -r .password)

# Store service principal credentials in Key Vault
az keyvault secret set \
  --vault-name $KEYVAULT_NAME \
  --name "aro-sp-id" \
  --value "$SP_ID"

az keyvault secret set \
  --vault-name $KEYVAULT_NAME \
  --name "aro-sp-secret" \
  --value "$SP_SECRET"
```

### 8. Deploy ARO Cluster

```bash
# Get master subnet ID
MASTER_SUBNET_ID=$(az network vnet subnet show \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $MASTER_SUBNET \
  --query id -o tsv)

# Get worker subnet ID
WORKER_SUBNET_ID=$(az network vnet subnet show \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $WORKER_SUBNET \
  --query id -o tsv)

# Create ARO cluster
az aro create \
  --resource-group $RESOURCE_GROUP \
  --name $ARO_CLUSTER_NAME \
  --master-subnet $MASTER_SUBNET_ID \
  --worker-subnet $WORKER_SUBNET_ID \
  --pull-secret @pull-secret.txt \
  --domain $ARO_DOMAIN
```

### 9. Get Cluster Credentials

```bash
# Get ARO cluster credentials
az aro list-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $ARO_CLUSTER_NAME \
  --query "{username: kubeadminUsername, password: kubeadminPassword}" -o json

# Get ARO API server URL
API_SERVER=$(az aro show \
  --resource-group $RESOURCE_GROUP \
  --name $ARO_CLUSTER_NAME \
  --query apiserverProfile.url -o tsv)

# Login with oc CLI
oc login $API_SERVER -u kubeadmin -p <password>
```

### 10. Install Developer Hub Operator

```bash
# Create project for Developer Hub
oc new-project developer-hub

# Install the Red Hat Developer Hub Operator v1.5 from OperatorHub
oc apply -f - << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: rhdh-operator
  namespace: openshift-operators
spec:
  channel: stable
  name: rhdh-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: rhdh-operator.v1.5.0
EOF

# Wait for the operator to be installed
oc wait --for=condition=ready pod -l name=rhdh-operator-controller-manager -n openshift-operators --timeout=300s
```

### 11. Deploy Developer Hub

```bash
# Create Developer Hub instance v1.5
oc apply -f - << EOF
apiVersion: rhdh.redhat.com/v1alpha1
kind: Backstage
metadata:
  name: developer-hub
  namespace: developer-hub
spec:
  application:
    replicas: 2
    resources:
      requests:
        memory: 1Gi
        cpu: 500m
      limits:
        memory: 2Gi
        cpu: 1
  database:
    enableLocalPostgres: true
  rbac:
    enabled: true
  route:
    enabled: true
    host: devhub.$ARO_DOMAIN
    tls:
      insecureEdgeTerminationPolicy: Redirect
      termination: edge
  extraEnvs:
    - name: RHDH_CONFIG_APP_CONFIG_app_baseUrl
      value: "https://devhub.$ARO_DOMAIN"
    - name: RHDH_DYNAMIC_PLUGINS_BACKEND_DYNAMIC_PLUGINS
      value: "true"
EOF

# Wait for the deployment to be ready
oc wait --for=condition=ready pod -l app=developer-hub -n developer-hub --timeout=300s
```

### 12. Configure Azure AD Integration

```bash
# Register an application in Azure AD for Developer Hub
APP_ID=$(az ad app create \
  --display-name "Developer Hub" \
  --available-to-other-tenants false \
  --query appId -o tsv)

# Create a service principal
az ad sp create --id $APP_ID

# Get the tenant ID
TENANT_ID=$(az account show --query tenantId -o tsv)

# Configure the OAuth settings
az ad app update \
  --id $APP_ID \
  --reply-urls "https://devhub.$ARO_DOMAIN/api/auth/callback/azure-ad"

# Configure identity provider in OpenShift
oc apply -f - << EOF
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: AAD
    mappingMethod: claim
    type: OpenID
    openID:
      clientID: $APP_ID
      clientSecret: 
        name: aad-client-secret
      extraScopes: 
      - email
      - profile
      extraAuthorizeParameters:
        include_granted_scopes: "true"
      claims:
        preferredUsername:
        - preferred_username
        - email
        name:
        - name
        email:
        - email
      issuer: https://login.microsoftonline.com/$TENANT_ID/v2.0
EOF
```

### 13. Configure GitHub Integration

```bash
# Register a GitHub App
# Follow the instructions at https://docs.github.com/en/developers/apps/creating-a-github-app

# Store GitHub App credentials as a secret
oc create secret generic github-app-credentials \
  --namespace developer-hub \
  --from-literal=app-id=your-github-app-id \
  --from-literal=private-key="your-github-app-private-key"

# Update Developer Hub configuration to use GitHub integration
oc apply -f - << EOF
apiVersion: rhdh.redhat.com/v1alpha1
kind: DynamicPlugin
metadata:
  name: github-catalog-plugin
  namespace: developer-hub
spec:
  disabled: false
  package:
    name: '@backstage/plugin-catalog-backend-module-github'
    version: '0.3.9'
  pluginConfig:
  - name: catalog.providers.github
    data: |
      {
        "allowedInstances": ["github.com"],
        "organization": "your-github-org",
        "schedule": {
          "frequency": { "minutes": 30 },
          "timeout": { "minutes": 3 }
        },
        "catalogPath": "/catalog-info.yaml",
        "visibilityLevel": "all"
      }
EOF
```

### 14. Verify Installation

```bash
# Check Developer Hub deployment status
oc get pods -n developer-hub

# Get the Developer Hub URL
oc get route -n developer-hub
```

## Post-Installation Configuration

### Set Up Golden Paths

1. Navigate to the Developer Hub admin interface
2. Go to Scaffolder > Templates
3. Create new templates for your golden paths:
   - Web Application Template
   - API Service Template
   - Kubernetes Deployment Template
   - CI/CD Pipeline Template

### Configure Service Catalog

1. Navigate to the Developer Hub admin interface
2. Go to Catalog > Settings
3. Configure the catalog with your organization's services and components

### Set Up Documentation

1. Configure TechDocs backend
2. Set up documentation sources
3. Import existing documentation

## Troubleshooting

### Common Issues

#### Issue: Pods are in CrashLoopBackOff
**Solution**: Check the logs with `oc logs -n developer-hub [pod-name]`

#### Issue: Cannot access Developer Hub UI
**Solution**: Verify route configuration and DNS settings

#### Issue: GitHub integration not working
**Solution**: Check GitHub App credentials and permissions

## Next Steps

- [Configure Monitoring and Alerts](monitoring-guide.md)
- [Set Up CI/CD Pipelines](cicd-pipeline-guide.md)
- [Configure User Management](user-management-guide.md)
- [Customize Developer Hub](customization-guide.md)

## References

- [ARO Documentation](https://docs.microsoft.com/en-us/azure/openshift/)
- [OpenShift Documentation](https://docs.openshift.com/)
- [Developer Hub Documentation](https://developer-hub-docs.example.com)