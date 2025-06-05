# Deploying Developer Hub on Azure Kubernetes Service (AKS)

This guide provides step-by-step instructions for deploying the Three Horizons Platform's Developer Hub on Azure Kubernetes Service, aligned with the [Complete Integration Tutorial](../complete-integration-tutorial/index.md).

## Prerequisites

- Azure subscription with Owner or Contributor access
- Azure CLI v2.53.0 or later installed and configured
- Kubernetes CLI (kubectl) v1.28.0 or later installed
- Helm 3 installed
- GitHub account with administrative access to your organization
- Basic understanding of Kubernetes and Azure concepts

> 📘 **Note:** This guide follows the same infrastructure patterns as the [Complete Integration Tutorial](../complete-integration-tutorial/index.md). For a full platform deployment, refer to that comprehensive guide.

## Architecture Overview

The deployment uses the following Azure resources following Three Horizons Platform standards:

- **Azure Kubernetes Service (AKS)** cluster with Workload Identity
- **Azure Container Registry (ACR)** with geo-replication
- **Azure Key Vault** with RBAC enabled
- **Azure Monitor** with Container Insights
- **Azure Virtual Network** with dedicated subnets
- **Managed Identities** for secure authentication

## Phase 1: Infrastructure Setup

### Step 1.1: Set up Environment Variables

```bash
# Set environment variables following Three Horizons naming convention
RESOURCE_GROUP_PLATFORM="three-horizons-platform"
RESOURCE_GROUP_SHARED="three-horizons-shared"
LOCATION="centralus"
SECONDARY_LOCATION="eastus2"
AKS_CLUSTER_NAME="three-horizons-aks"

# Generate unique names to avoid conflicts
TIMESTAMP=$(date +%s)
ACR_NAME="threehorizonsreg${TIMESTAMP}"
KEY_VAULT_NAME="th3horizons${TIMESTAMP}"
VNET_NAME="three-horizons-vnet"

echo "Resource Group (Platform): $RESOURCE_GROUP_PLATFORM"
echo "Resource Group (Shared): $RESOURCE_GROUP_SHARED"
echo "AKS Cluster: $AKS_CLUSTER_NAME"
echo "Container Registry: $ACR_NAME"
echo "Key Vault: $KEY_VAULT_NAME"
```

### Step 1.2: Create Resource Groups

```bash
# Create resource groups with proper tagging
az group create \
  --name $RESOURCE_GROUP_PLATFORM \
  --location $LOCATION \
  --tags Environment=Production Project=ThreeHorizons Owner=PlatformTeam

az group create \
  --name $RESOURCE_GROUP_SHARED \
  --location $LOCATION \
  --tags Environment=Production Project=ThreeHorizons Owner=PlatformTeam
```

### Step 1.3: Deploy Network Infrastructure

```bash
# Create virtual network with properly sized subnets
az network vnet create \
  --resource-group $RESOURCE_GROUP_PLATFORM \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16 \
  --subnet-name aks-subnet \
  --subnet-prefix 10.0.0.0/22 \
  --tags Environment=Production Project=ThreeHorizons

# Create subnet for Azure services
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP_PLATFORM \
  --vnet-name $VNET_NAME \
  --name services-subnet \
  --address-prefix 10.0.4.0/24

# Create subnet for private endpoints
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP_PLATFORM \
  --vnet-name $VNET_NAME \
  --name endpoint-subnet \
  --address-prefix 10.0.5.0/24 \
  --disable-private-endpoint-network-policies true
```

### Step 1.4: Deploy Azure Container Registry

```bash
# Create container registry with geo-replication
az acr create \
  --name $ACR_NAME \
  --resource-group $RESOURCE_GROUP_SHARED \
  --location $LOCATION \
  --sku Premium \
  --admin-enabled false \
  --tags Environment=Production Project=ThreeHorizons

echo "Container Registry created: $ACR_NAME"

# Enable geo-replication for production workloads
az acr replication create \
  --registry $ACR_NAME \
  --location $SECONDARY_LOCATION

# Enable Microsoft Defender for containers
az security pricing create \
  --name ContainerRegistry \
  --tier 'standard'
```

### Step 1.5: Deploy Key Vault

```bash
# Create key vault with RBAC authorization
az keyvault create \
  --name $KEY_VAULT_NAME \
  --resource-group $RESOURCE_GROUP_SHARED \
  --location $LOCATION \
  --sku standard \
  --enable-rbac-authorization true \
  --tags Environment=Production Project=ThreeHorizons

# Assign yourself Key Vault Secrets Officer role
az role assignment create \
  --role "Key Vault Secrets Officer" \
  --assignee "$(az account show --query user.name -o tsv)" \
  --scope "$(az keyvault show --name "$KEY_VAULT_NAME" --resource-group $RESOURCE_GROUP_SHARED --query id -o tsv)"

echo "Key Vault created: $KEY_VAULT_NAME"
echo "Waiting 5 minutes for RBAC permissions to propagate..."
sleep 300
```

### Step 1.6: Create Managed Identity

```bash
# Create user-assigned managed identity for workload identity
az identity create \
  --name three-horizons-identity \
  --resource-group $RESOURCE_GROUP_SHARED \
  --tags Environment=Production Project=ThreeHorizons

# Get identity client ID and principal ID
IDENTITY_CLIENT_ID=$(az identity show --name three-horizons-identity --resource-group $RESOURCE_GROUP_SHARED --query clientId -o tsv)
IDENTITY_PRINCIPAL_ID=$(az identity show --name three-horizons-identity --resource-group $RESOURCE_GROUP_SHARED --query principalId -o tsv)

# Grant access to Key Vault
az role assignment create \
  --assignee-object-id $IDENTITY_PRINCIPAL_ID \
  --assignee-principal-type ServicePrincipal \
  --role "Key Vault Secrets User" \
  --scope $(az keyvault show --name "$KEY_VAULT_NAME" --resource-group $RESOURCE_GROUP_SHARED --query id -o tsv)

echo "Managed Identity created with Key Vault access"
```

## Phase 2: AKS Cluster Deployment

### Step 2.1: Deploy AKS Cluster

```bash
# Get subnet ID for AKS
AKS_SUBNET_ID=$(az network vnet subnet show \
  --resource-group $RESOURCE_GROUP_PLATFORM \
  --vnet-name $VNET_NAME \
  --name aks-subnet \
  --query id -o tsv)

# Create AKS cluster with modern features
az aks create \
  --resource-group $RESOURCE_GROUP_PLATFORM \
  --name $AKS_CLUSTER_NAME \
  --node-count 3 \
  --enable-managed-identity \
  --enable-workload-identity \
  --enable-oidc-issuer \
  --enable-addons monitoring \
  --network-plugin azure \
  --network-plugin-mode overlay \
  --vnet-subnet-id $AKS_SUBNET_ID \
  --docker-bridge-address 172.17.0.1/16 \
  --dns-service-ip 10.2.0.10 \
  --service-cidr 10.2.0.0/24 \
  --node-vm-size Standard_D4s_v3 \
  --kubernetes-version 1.28.3 \
  --attach-acr $ACR_NAME \
  --tags Environment=Production Project=ThreeHorizons \
  --generate-ssh-keys

echo "AKS cluster created successfully"
```

### Step 2.2: Connect to AKS Cluster

```bash
# Get AKS credentials
az aks get-credentials \
  --resource-group $RESOURCE_GROUP_PLATFORM \
  --name $AKS_CLUSTER_NAME \
  --overwrite-existing

# Verify connection
kubectl get nodes
kubectl get namespaces
```

### Step 2.3: Configure Workload Identity

```bash
# Get AKS OIDC issuer URL
AKS_OIDC_ISSUER="$(az aks show -n $AKS_CLUSTER_NAME -g $RESOURCE_GROUP_PLATFORM --query "oidcIssuerProfile.issuerUrl" -o tsv)"

# Create a Kubernetes service account
kubectl create namespace three-horizons-system

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: $IDENTITY_CLIENT_ID
  name: workload-identity-sa
  namespace: three-horizons-system
EOF

# Create federated identity credential
az identity federated-credential create \
  --name three-horizons-federated-credential \
  --identity-name three-horizons-identity \
  --resource-group $RESOURCE_GROUP_SHARED \
  --issuer $AKS_OIDC_ISSUER \
  --subject system:serviceaccount:three-horizons-system:workload-identity-sa

echo "Workload Identity configured successfully"
```

### Step 2.4: Install Ingress Controller

```bash
# Install NGINX Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace three-horizons-system \
  --create-namespace \
  --set controller.replicaCount=2 \
  --set controller.nodeSelector."kubernetes\.io/os"=linux \
  --set controller.admissionWebhooks.patch.nodeSelector."kubernetes\.io/os"=linux \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-internal"="false" \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"="/healthz"

# Wait for ingress controller to be ready
kubectl wait --namespace three-horizons-system \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s
```

## Phase 3: Red Hat Developer Hub Deployment

### Step 3.1: Install Operator Lifecycle Manager

```bash
# Install OLM for AKS
curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.26.0/install.sh | bash -s v0.26.0

# Wait for OLM to be ready
kubectl wait --for=condition=ready pod -l app=olm-operator -n olm --timeout=300s
kubectl wait --for=condition=ready pod -l app=catalog-operator -n olm --timeout=300s
```

### Step 3.2: Configure PostgreSQL Database

```bash
# Generate unique timestamp for database server name
DB_TIMESTAMP=$(date +"%m%d%H%M")
DB_SERVER_NAME="backstagedb-${DB_TIMESTAMP}"
DB_PASSWORD="StrongPassword123!"

# Create Azure Database for PostgreSQL flexible server
az postgres flexible-server create \
  --resource-group $RESOURCE_GROUP_SHARED \
  --name ${DB_SERVER_NAME} \
  --admin-user backstage \
  --admin-password "$DB_PASSWORD" \
  --sku-name Standard_D2s_v3 \
  --tier GeneralPurpose \
  --storage-size 32 \
  --version 14 \
  --high-availability ZoneRedundant \
  --location $LOCATION \
  --database-name backstage \
  --tags Environment=Production Project=ThreeHorizons

# Configure firewall rule
az postgres flexible-server firewall-rule create \
  --resource-group $RESOURCE_GROUP_SHARED \
  --name ${DB_SERVER_NAME} \
  --rule-name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# Store credentials in Key Vault
az keyvault secret set \
  --name db-password \
  --vault-name "$KEY_VAULT_NAME" \
  --value "$DB_PASSWORD"

# Get database host
DB_HOST=$(az postgres flexible-server show \
  --resource-group $RESOURCE_GROUP_SHARED \
  --name ${DB_SERVER_NAME} \
  --query fullyQualifiedDomainName \
  --output tsv)

echo "Database Host: $DB_HOST"
```

### Step 3.3: Install Developer Hub Operator

```bash
# Create namespace
kubectl create namespace developer-hub

# Install OLM Catalog Sources for Red Hat Operators
cat <<EOF | kubectl apply -f -
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
cat <<EOF | kubectl apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: developer-hub-operatorgroup
  namespace: developer-hub
spec: {}
EOF

# Deploy Red Hat Developer Hub Operator v1.6
cat <<EOF | kubectl apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: rhdh-operator
  namespace: developer-hub
spec:
      channel: fast-1.6
  name: rhdh
  source: redhat-operators
  sourceNamespace: olm
EOF

# Wait for the operator to be installed
kubectl wait --for=condition=ready pod -l name=rhdh-operator -n developer-hub --timeout=600s
```

### Step 3.4: Deploy Developer Hub Instance

```bash
# Create database secret
kubectl create secret generic developer-hub-postgres \
  --namespace developer-hub \
  --from-literal=postgres-password="$DB_PASSWORD"

# Deploy Red Hat Developer Hub instance v1.6
cat <<EOF | kubectl apply -f -
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
        cpu: "1"
        memory: "2Gi"
      limits:
        cpu: "2"
        memory: "4Gi"
  database:
    host: "${DB_HOST}"
    port: 5432
    name: "backstage"
    user: "backstage"
    passwordSecret:
      name: "developer-hub-postgres"
      key: "postgres-password"
  rbac:
    enabled: true
  extraEnvs:
    - name: RHDH_CONFIG_APP_CONFIG_app_baseUrl
      value: "https://devhub.example.com"
    - name: RHDH_DYNAMIC_PLUGINS_BACKEND_DYNAMIC_PLUGINS
      value: "true"
EOF

# Wait for Developer Hub to be ready
kubectl wait --for=condition=ready pod -l app=backstage -n developer-hub --timeout=600s
```

### Step 3.5: Configure Ingress

```bash
# Create ingress for Developer Hub
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: developer-hub
  namespace: developer-hub
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  rules:
  - host: devhub.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: developer-hub
            port:
              number: 7007
EOF
```

## Phase 4: GitHub Integration

### Step 4.1: Create GitHub App

Follow the [Complete Integration Tutorial GitHub section](../complete-integration-tutorial/index.md#phase-4-github-integration) to create a GitHub App with the following settings:

1. **GitHub App name**: `ThreeHorizons-RHDH-AKS-<GUID>`
2. **Homepage URL**: Your Developer Hub URL
3. **Callback URL**: `https://devhub.example.com/api/auth/github/handler/frame`
4. **Repository permissions**: Read access to Contents, Issues, Pull Requests
5. **Organization permissions**: Read access to Members

### Step 4.2: Configure GitHub Integration

```bash
# Store GitHub App credentials in Key Vault
az keyvault secret set \
  --vault-name "$KEY_VAULT_NAME" \
  --name "github-app-id" \
  --value "your-github-app-id"

az keyvault secret set \
  --vault-name "$KEY_VAULT_NAME" \
  --name "github-app-private-key" \
  --value "$(cat your-private-key.pem)"

az keyvault secret set \
  --vault-name "$KEY_VAULT_NAME" \
  --name "github-client-secret" \
  --value "your-github-client-secret"

# Create Kubernetes secrets
kubectl create secret generic github-app-credentials \
  --namespace developer-hub \
  --from-literal=app-id="your-github-app-id" \
  --from-literal=client-id="your-github-client-id" \
  --from-literal=client-secret="your-github-client-secret" \
  --from-literal=private-key="$(cat your-private-key.pem)"
```

## Validation and Testing

### Infrastructure Validation

```bash
# Check all resource groups
az group list --query "[?contains(name, 'three-horizons')]" -o table

# Check AKS cluster
az aks show --name $AKS_CLUSTER_NAME --resource-group $RESOURCE_GROUP_PLATFORM --query "{name:name,status:powerState.code,version:kubernetesVersion}" -o table

# Check nodes
kubectl get nodes -o wide

# Check system pods
kubectl get pods -n three-horizons-system
kubectl get pods -n developer-hub

# Check ingress
kubectl get ingress -n developer-hub
kubectl get services -n three-horizons-system
```

### Application Validation

```bash
# Test Developer Hub accessibility
curl -k https://devhub.example.com/api/health

# Check Developer Hub logs
kubectl logs -n developer-hub -l app=backstage --tail=50

# Verify database connection
kubectl exec -it -n developer-hub $(kubectl get pods -n developer-hub -l app=backstage -o jsonpath='{.items[0].metadata.name}') -- wget -qO- http://localhost:7007/api/health
```

## Post-Installation Configuration

### 1. Set Up DNS

Configure your DNS to point `devhub.example.com` to the ingress controller's external IP:

```bash
# Get the external IP
kubectl get services -n three-horizons-system ingress-nginx-controller

# Create an A record in your DNS provider pointing to this IP
```

### 2. Configure SSL/TLS

For production environments, configure Let's Encrypt or your certificate provider:

```bash
# Example with cert-manager (install cert-manager first)
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

### 3. Configure Monitoring

Enable additional monitoring for the Developer Hub:

```bash
# Verify Azure Monitor is collecting metrics
kubectl get pods -n kube-system -l component=oms-agent

# Check if Container Insights is enabled
az aks show --name $AKS_CLUSTER_NAME --resource-group $RESOURCE_GROUP_PLATFORM --query addonProfiles.omsAgent.enabled
```

## Troubleshooting

### Common Issues and Solutions

#### Issue: AKS cluster creation fails
**Solution**: Check Azure quotas and ensure proper permissions
```bash
az vm list-usage --location $LOCATION -o table
```

#### Issue: Developer Hub pods are pending
**Solution**: Check node resources and storage classes
```bash
kubectl describe pod -n developer-hub
kubectl get storageclass
```

#### Issue: Cannot access Developer Hub UI
**Solution**: Verify ingress and DNS configuration
```bash
kubectl get ingress -n developer-hub
kubectl logs -n three-horizons-system -l app.kubernetes.io/component=controller
```

#### Issue: Database connection failures
**Solution**: Check firewall rules and connectivity
```bash
# Test connectivity from cluster
kubectl run test-pod --image=postgres:14 --rm -it -- psql -h $DB_HOST -U backstage -d backstage
```

## Next Steps

- [Configure Monitoring and Alerts](troubleshooting.md)
- [Set Up CI/CD Pipelines](../complete-integration-tutorial/index.md#ci-cd-pipeline-setup)
- [Configure User Management](../complete-integration-tutorial/index.md#authentication-and-authorization)
- [Customize Developer Hub](../complete-integration-tutorial/index.md#red-hat-developer-hub-rhdh-setup)

## References

- [Complete Integration Tutorial](../complete-integration-tutorial/index.md)
- [AKS Documentation](https://learn.microsoft.com/en-us/azure/aks/)
- [Red Hat Developer Hub 1.6 Documentation](https://developers.redhat.com/rhdh/1.6/getting_started)
- [Azure Workload Identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)

---

> 📝 **Note:** This guide is aligned with the [Complete Integration Tutorial](../complete-integration-tutorial/index.md). For a comprehensive multi-service deployment, refer to that guide for the complete Three Horizons Platform setup.