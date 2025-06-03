# Deploying Developer Hub on Azure Kubernetes Service (AKS)

This guide provides step-by-step instructions for deploying the Three Horizons Platform's Developer Hub on Azure Kubernetes Service.

## Prerequisites

- Azure subscription with Owner or Contributor access
- Azure CLI installed and configured
- Kubernetes CLI (kubectl) installed
- Helm 3 installed
- GitHub account with administrative access to your organization

## Architecture

The deployment uses the following Azure resources:

- Azure Kubernetes Service (AKS) cluster
- Azure Container Registry (ACR)
- Azure Key Vault
- Azure Monitor
- Microsoft Entra ID
- Azure Virtual Network and Subnets

## Deployment Steps

### 1. Set up Environment Variables

```bash
# Set environment variables
RESOURCE_GROUP="three-horizons-devhub"
LOCATION="centralus"
AKS_CLUSTER_NAME="devhub-aks"
ACR_NAME="devhubacr$(date +%s)"
KEYVAULT_NAME="th3horizons$(date +%s)"
VNET_NAME="devhub-vnet"
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
  --address-prefixes 10.0.0.0/16 \
  --subnet-name aks-subnet \
  --subnet-prefix 10.0.0.0/24

# Create a separate subnet for pods if using Azure CNI
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name pod-subnet \
  --address-prefixes 10.0.1.0/24
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

### 6. Deploy AKS Cluster

```bash
# Get subnet ID
SUBNET_ID=$(az network vnet subnet show \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name aks-subnet \
  --query id -o tsv)

# Create AKS cluster
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_CLUSTER_NAME \
  --node-count 3 \
  --node-vm-size Standard_D4s_v3 \
  --vnet-subnet-id $SUBNET_ID \
  --network-plugin azure \
  --network-policy calico \
  --attach-acr $ACR_NAME \
  --enable-managed-identity \
  --enable-addons monitoring \
  --generate-ssh-keys
```

### 7. Configure kubectl to Connect to Your Cluster

```bash
# Get credentials for the AKS cluster
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_CLUSTER_NAME \
  --overwrite-existing
```

### 8. Install Developer Hub

```bash
# Create namespace for Developer Hub
kubectl create namespace developer-hub

# Install Red Hat Developer Hub Operator using OLM
# First, install OLM if not already installed
curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.26.0/install.sh | bash -s v0.26.0

# Add Red Hat Operators catalog
kubectl apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: redhat-operators
  namespace: olm
spec:
  displayName: Red Hat Operators
  publisher: Red Hat
  sourceType: grpc
  image: registry.redhat.io/redhat/redhat-operator-index:v4.13
  updateStrategy:
    registryPoll:
      interval: 30m
EOF

# Create OperatorGroup
kubectl apply -f - <<EOF
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: developer-hub-operatorgroup
  namespace: developer-hub
spec:
  targetNamespaces:
  - developer-hub
EOF

# Install RHDH Operator v1.5
kubectl apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: rhdh-operator
  namespace: developer-hub
spec:
  channel: stable
  name: rhdh-operator
  source: redhat-operators
  sourceNamespace: olm
  startingCSV: rhdh-operator.v1.5.0
EOF

# Wait for the operator to be ready
kubectl wait --for=condition=ready pod -l name=rhdh-operator -n developer-hub --timeout=300s

# Deploy RHDH instance
kubectl apply -f - <<EOF
apiVersion: rhdh.redhat.com/v1alpha1
kind: Backstage
metadata:
  name: developer-hub
  namespace: developer-hub
spec:
  application:
    replicas: 1
    resources:
      requests:
        cpu: "500m"
        memory: "1Gi"
      limits:
        cpu: "1"
        memory: "2Gi"
  database:
    enableLocalPostgres: true
  rbac:
    enabled: true
  extraEnvs:
    - name: RHDH_CONFIG_APP_CONFIG_app_baseUrl
      value: "https://devhub.example.com"
    - name: RHDH_DYNAMIC_PLUGINS_BACKEND_DYNAMIC_PLUGINS
      value: "true"
EOF
```

### 9. Configure Microsoft Entra ID Integration

```bash
# Register an application in Microsoft Entra ID for Developer Hub
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
  --reply-urls "https://devhub.example.com/api/auth/callback/azure-ad"
```

### 10. Configure GitHub Integration

```bash
# Register a GitHub App
# Follow the instructions at https://docs.github.com/en/developers/apps/creating-a-github-app

# Store GitHub App credentials in Key Vault
az keyvault secret set \
  --vault-name $KEYVAULT_NAME \
  --name "github-app-id" \
  --value "your-github-app-id"

az keyvault secret set \
  --vault-name $KEYVAULT_NAME \
  --name "github-app-private-key" \
  --value "your-github-app-private-key"

# Update Developer Hub configuration
kubectl create secret generic github-app-credentials \
  --namespace developer-hub \
  --from-literal=app-id=your-github-app-id \
  --from-literal=private-key="your-github-app-private-key"

# Apply updated configuration
kubectl apply -f developer-hub-github-integration.yaml
```

### 11. Configure Ingress

```bash
# Install nginx ingress controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace

# Create TLS certificate
# (For production, use Let's Encrypt or your certificate provider)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout devhub-tls.key -out devhub-tls.crt \
  -subj "/CN=devhub.example.com"

kubectl create secret tls devhub-tls \
  --namespace developer-hub \
  --key devhub-tls.key \
  --cert devhub-tls.crt

# Apply ingress configuration
kubectl apply -f developer-hub-ingress.yaml
```

### 12. Verify Installation

```bash
# Check all pods are running
kubectl get pods -n developer-hub

# Check ingress is configured correctly
kubectl get ingress -n developer-hub
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
**Solution**: Check the logs with `kubectl logs -n developer-hub [pod-name]`

#### Issue: Cannot access Developer Hub UI
**Solution**: Verify ingress configuration and DNS settings

#### Issue: GitHub integration not working
**Solution**: Check GitHub App credentials and permissions

## Next Steps

- [Configure Monitoring and Alerts](monitoring-guide.md)
- [Set Up CI/CD Pipelines](cicd-pipeline-guide.md)
- [Configure User Management](user-management-guide.md)
- [Customize Developer Hub](customization-guide.md)

## References

- [AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Developer Hub Documentation](https://developer-hub-docs.example.com)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)