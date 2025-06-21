# Deploying Developer Hub on Azure Red Hat OpenShift (ARO)

This guide provides step-by-step instructions for deploying the Three Horizons Platform's Developer Hub on Azure Red Hat OpenShift, aligned with the [Complete Integration Tutorial](../complete-integration-tutorial/index.md).

## Prerequisites

- Azure subscription with Owner or Contributor access
- Red Hat account with appropriate entitlements and pull secret
- Azure CLI v2.53.0 or later installed and configured
- OpenShift CLI (oc) v4.13 or later installed
- GitHub account with administrative access to your organization
- Basic understanding of OpenShift and Azure concepts

> 📘 **Note:** This guide follows the same infrastructure patterns as the [Complete Integration Tutorial](../complete-integration-tutorial/index.md). For a full platform deployment, refer to that comprehensive guide.

## Architecture Overview

The deployment uses the following Azure resources following Three Horizons Platform standards:

- **Azure Red Hat OpenShift (ARO)** cluster with managed services
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
ARO_CLUSTER_NAME="three-horizons-aro"

# Generate unique names to avoid conflicts
TIMESTAMP=$(date +%s)
ACR_NAME="threehorizonsreg${TIMESTAMP}"
KEY_VAULT_NAME="th3horizons${TIMESTAMP}"
VNET_NAME="three-horizons-vnet"
MASTER_SUBNET="aro-master-subnet"
WORKER_SUBNET="aro-worker-subnet"
ARO_DOMAIN="three-horizons-aro"

echo "Resource Group (Platform): $RESOURCE_GROUP_PLATFORM"
echo "Resource Group (Shared): $RESOURCE_GROUP_SHARED"
echo "ARO Cluster: $ARO_CLUSTER_NAME"
echo "Container Registry: $ACR_NAME"
echo "Key Vault: $KEY_VAULT_NAME"
echo "ARO Domain: $ARO_DOMAIN"
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

### Step 1.3: Register Resource Providers

```bash
# Register required resource providers for ARO
az provider register --namespace Microsoft.RedHatOpenShift --wait
az provider register --namespace Microsoft.Compute --wait
az provider register --namespace Microsoft.Storage --wait
az provider register --namespace Microsoft.Authorization --wait
az provider register --namespace Microsoft.Network --wait

echo "Resource providers registered successfully"
```

### Step 1.4: Deploy Network Infrastructure

```bash
# Create virtual network with properly sized subnets for ARO
az network vnet create \
  --resource-group $RESOURCE_GROUP_PLATFORM \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16 \
  --tags Environment=Production Project=ThreeHorizons

# Create master subnet (minimum /27 required for ARO)
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP_PLATFORM \
  --vnet-name $VNET_NAME \
  --name $MASTER_SUBNET \
  --address-prefix 10.0.8.0/23 \
  --service-endpoints Microsoft.ContainerRegistry

# Create worker subnet (minimum /27 required for ARO)
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP_PLATFORM \
  --vnet-name $VNET_NAME \
  --name $WORKER_SUBNET \
  --address-prefix 10.0.10.0/23 \
  --service-endpoints Microsoft.ContainerRegistry

# Disable private link service network policies on master subnet
az network vnet subnet update \
  --name $MASTER_SUBNET \
  --resource-group $RESOURCE_GROUP_PLATFORM \
  --vnet-name $VNET_NAME \
  --private-link-service-network-policies Disabled

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

### Step 1.5: Deploy Azure Container Registry

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

### Step 1.6: Deploy Key Vault

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

### Step 1.7: Create Managed Identity

```bash
# Create user-assigned managed identity
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

## Phase 2: ARO Cluster Deployment

### Step 2.1: Prepare ARO Pull Secret

```bash
# Download your pull secret from https://cloud.redhat.com/openshift/install/azure/aro-provisioned
# Save it as pull-secret.txt in your current directory
echo "Please ensure you have downloaded your Red Hat pull secret and saved it as 'pull-secret.txt'"
echo "You can download it from: https://cloud.redhat.com/openshift/install/azure/aro-provisioned"

# Verify the pull secret file exists
if [ ! -f "pull-secret.txt" ]; then
  echo "Error: pull-secret.txt not found. Please download it from Red Hat Cloud Console."
  exit 1
fi

echo "Pull secret verified successfully"
```

### Step 2.2: Deploy ARO Cluster

```bash
# Get subnet IDs for ARO
MASTER_SUBNET_ID=$(az network vnet subnet show \
  --resource-group $RESOURCE_GROUP_PLATFORM \
  --vnet-name $VNET_NAME \
  --name $MASTER_SUBNET \
  --query id -o tsv)

WORKER_SUBNET_ID=$(az network vnet subnet show \
  --resource-group $RESOURCE_GROUP_PLATFORM \
  --vnet-name $VNET_NAME \
  --name $WORKER_SUBNET \
  --query id -o tsv)

# Create ARO cluster with current OpenShift version
az aro create \
  --resource-group $RESOURCE_GROUP_PLATFORM \
  --name $ARO_CLUSTER_NAME \
  --vnet $VNET_NAME \
  --master-subnet $MASTER_SUBNET_ID \
  --worker-subnet $WORKER_SUBNET_ID \
  --apiserver-visibility Public \
  --ingress-visibility Public \
  --pull-secret @pull-secret.txt \
  --worker-count 3 \
  --worker-vm-size Standard_D4s_v3 \
  --domain $ARO_DOMAIN \
  --tags Environment=Production Project=ThreeHorizons

echo "ARO cluster creation initiated. This may take 30-45 minutes..."
```

### Step 2.3: Connect to ARO Cluster

```bash
# Get ARO cluster credentials
ARO_CREDENTIALS=$(az aro list-credentials \
  --resource-group $RESOURCE_GROUP_PLATFORM \
  --name $ARO_CLUSTER_NAME)

ARO_USERNAME=$(echo $ARO_CREDENTIALS | jq -r .kubeadminUsername)
ARO_PASSWORD=$(echo $ARO_CREDENTIALS | jq -r .kubeadminPassword)

# Get ARO API server URL
API_SERVER=$(az aro show \
  --resource-group $RESOURCE_GROUP_PLATFORM \
  --name $ARO_CLUSTER_NAME \
  --query apiserverProfile.url -o tsv)

# Get ARO console URL
CONSOLE_URL=$(az aro show \
  --resource-group $RESOURCE_GROUP_PLATFORM \
  --name $ARO_CLUSTER_NAME \
  --query consoleProfile.url -o tsv)

echo "ARO API Server: $API_SERVER"
echo "ARO Console: $CONSOLE_URL"
echo "Username: $ARO_USERNAME"
echo "Password: $ARO_PASSWORD"

# Login with oc CLI
oc login "$API_SERVER" -u "$ARO_USERNAME" -p "$ARO_PASSWORD" --insecure-skip-tls-verify=true

# Verify connection
oc get nodes
oc get clusterversion
```

### Step 2.4: Configure Storage Classes

```bash
# Create additional storage class for RWX volumes (if needed)
oc apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azure-file-rwx
provisioner: kubernetes.io/azure-file
parameters:
  skuName: Premium_ZRS
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
mountOptions:
  - dir_mode=0777
  - file_mode=0777
  - uid=0
  - gid=0
EOF

# Verify storage classes
oc get storageclass
```

## Phase 3: Red Hat Developer Hub Deployment

### Step 3.1: Configure PostgreSQL Database

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

### Step 3.2: Install Red Hat Developer Hub Operator

```bash
# Create project for Developer Hub
oc new-project developer-hub

# Install the Red Hat Developer Hub Operator v1.6 from OperatorHub
oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: rhdh-operator
  namespace: openshift-operators
spec:
  channel: fast-1.6
  name: rhdh
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  installPlanApproval: Automatic
EOF

# Wait for the operator to be installed
echo "Waiting for Red Hat Developer Hub Operator to be ready..."
oc wait --for=condition=ready pod -l app=rhdh-operator -n openshift-operators --timeout=600s

# Verify operator installation
oc get csv -n openshift-operators | grep rhdh
```

### Step 3.3: Deploy Developer Hub Instance

```bash
# Create database secret
oc create secret generic developer-hub-postgres \
  --namespace developer-hub \
  --from-literal=postgres-password="$DB_PASSWORD"

# Deploy Red Hat Developer Hub instance v1.6
oc apply -f - <<EOF
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
      value: "https://devhub-developer-hub.apps.${ARO_DOMAIN}.${LOCATION}.aroapp.io"
    - name: RHDH_DYNAMIC_PLUGINS_BACKEND_DYNAMIC_PLUGINS
      value: "true"
EOF

# Wait for Developer Hub to be ready
echo "Waiting for Developer Hub to be ready..."
oc wait --for=condition=ready pod -l rhdh.redhat.com/app=backstage-developer-hub -n developer-hub --timeout=600s
```

### Step 3.4: Configure Route

```bash
# Create a route for Developer Hub (OpenShift automatically creates routes)
# oc expose service developer-hub -n developer-hub

# Get the route URL
DEVHUB_URL=$(oc get route backstage-developer-hub -n developer-hub -o jsonpath='{.spec.host}')
echo "Developer Hub URL: https://$DEVHUB_URL"

# Verify route is working
curl -k https://$DEVHUB_URL
```

## Phase 4: GitHub Integration

### Step 4.1: Create GitHub App

Follow the [Complete Integration Tutorial GitHub section](../complete-integration-tutorial/index.md#phase-4-github-integration) to create a GitHub App with the following settings:

1. **GitHub App name**: `ThreeHorizons-RHDH-ARO-<GUID>`
2. **Homepage URL**: Your Developer Hub URL
3. **Callback URL**: `https://<devhub-route>/api/auth/github/handler/frame`
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

# Create OpenShift secrets
oc create secret generic github-app-credentials \
  --namespace developer-hub \
  --from-literal=app-id="your-github-app-id" \
  --from-literal=client-id="your-github-client-id" \
  --from-literal=client-secret="your-github-client-secret" \
  --from-literal=private-key="$(cat your-private-key.pem)"
```

### Step 4.3: Configure Microsoft Entra ID Integration (Optional)

```bash
# Register an application in Microsoft Entra ID for Developer Hub
APP_ID=$(az ad app create \
  --display-name "Three Horizons Developer Hub ARO" \
  --query appId -o tsv)

# Get the tenant ID
TENANT_ID=$(az account show --query tenantId -o tsv)

# Configure the OAuth settings
az ad app update \
  --id $APP_ID \
  --web-redirect-uris "https://$DEVHUB_URL/api/auth/callback/azure-ad"

# Create client secret
CLIENT_SECRET=$(az ad app credential reset --id $APP_ID --query password -o tsv)

# Configure identity provider in OpenShift
oc apply -f - <<EOF
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: EntraID
    mappingMethod: claim
    type: OpenID
    openID:
      clientID: $APP_ID
      clientSecret: 
        name: entraid-client-secret
      extraScopes: 
      - email
      - profile
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

# Create the client secret
oc create secret generic entraid-client-secret \
  --from-literal=clientSecret="$CLIENT_SECRET" \
  -n openshift-config
```

## Validation and Testing

### Infrastructure Validation

```bash
# Check all resource groups
az group list --query "[?contains(name, 'three-horizons')]" -o table

# Check ARO cluster status
az aro show --name $ARO_CLUSTER_NAME --resource-group $RESOURCE_GROUP_PLATFORM --query "{name:name,provisioningState:provisioningState,consoleProfile:consoleProfile.url}" -o table

# Verify cluster operators status
oc get clusteroperators

# Check ARO cluster version
oc get clusterversion

# Verify nodes
oc get nodes -o wide

# Check Developer Hub pods
oc get pods -n developer-hub
```

### Application Validation

```bash
# Test Developer Hub accessibility
curl -k https://$DEVHUB_URL/api/health

# Check Developer Hub logs
oc logs -n developer-hub -l app=backstage --tail=50

# Verify database connection
oc exec -it -n developer-hub $(oc get pods -n developer-hub -l app=backstage -o jsonpath='{.items[0].metadata.name}') -- wget -qO- http://localhost:7007/api/health

# Check route status
oc get route -n developer-hub
```

### Storage Validation

```bash
# Test persistent volume claims
cat <<EOF | oc apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: validation-pvc
  namespace: developer-hub
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: managed-csi
EOF

# Check PVC status (should show Bound after a moment)
oc get pvc validation-pvc -n developer-hub

# Clean up test PVC
oc delete pvc validation-pvc -n developer-hub
```

## Post-Installation Configuration

### 1. Configure SSL/TLS

OpenShift automatically provides SSL/TLS certificates for routes. For custom certificates:

```bash
# Create a custom certificate (if needed)
oc create route edge developer-hub-secure \
  --service=developer-hub \
  --hostname=devhub.yourdomain.com \
  --cert=path/to/tls.crt \
  --key=path/to/tls.key \
  -n developer-hub
```

### 2. Configure Monitoring

Enable additional monitoring for the Developer Hub:

```bash
# Verify OpenShift monitoring is enabled
oc get pods -n openshift-monitoring

# Check if user workload monitoring is enabled
oc get configmap cluster-monitoring-config -n openshift-monitoring -o yaml

# Enable user workload monitoring (if not already enabled)
oc apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
data:
  config.yaml: |
    enableUserWorkload: true
EOF
```

### 3. Configure Resource Quotas

Set up resource quotas for the developer-hub project:

```bash
oc apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: developer-hub-quota
  namespace: developer-hub
spec:
  hard:
    requests.cpu: "8"
    requests.memory: 16Gi
    limits.cpu: "16"
    limits.memory: 32Gi
    persistentvolumeclaims: "10"
EOF
```

## Troubleshooting

### Common Issues and Solutions

#### Issue: ARO cluster creation fails
**Solution**: Check Azure quotas and ensure proper permissions
```bash
az vm list-usage --location $LOCATION -o table
# Ensure you have at least 40 vCPUs available
```

#### Issue: Pull secret authentication fails
**Solution**: Verify your Red Hat subscription and pull secret
```bash
# Verify pull secret format
cat pull-secret.txt | jq .
# Download a fresh pull secret from https://cloud.redhat.com/openshift/install/azure/aro-provisioned
```

#### Issue: Developer Hub pods are pending
**Solution**: Check node resources and storage classes
```bash
oc describe pod -n developer-hub
oc get storageclass
oc get nodes -o wide
```

#### Issue: Cannot access Developer Hub UI
**Solution**: Verify route and DNS configuration
```bash
oc get route -n developer-hub
oc describe route developer-hub -n developer-hub
curl -k https://$DEVHUB_URL/api/health
```

#### Issue: Database connection failures
**Solution**: Check firewall rules and connectivity
```bash
# Test connectivity from cluster
oc run test-pod --image=postgres:14 --rm -it -- psql -h $DB_HOST -U backstage -d backstage
```

#### Issue: OpenShift operators not installing
**Solution**: Check operator hub and subscription status
```bash
oc get packagemanifest | grep rhdh
oc get subscription -n openshift-operators
oc get csv -n openshift-operators
```

## Next Steps

- [Configure Monitoring and Alerts](troubleshooting.md)
- [Set Up CI/CD Pipelines](../complete-integration-tutorial/index.md#ci-cd-pipeline-setup)
- [Configure User Management](../complete-integration-tutorial/index.md#authentication-and-authorization)
- [Customize Developer Hub](../complete-integration-tutorial/index.md#red-hat-developer-hub-rhdh-setup)

## References

- [Complete Integration Tutorial](../complete-integration-tutorial/index.md)
- [Azure Red Hat OpenShift Documentation](https://learn.microsoft.com/en-us/azure/openshift/)
- [OpenShift Container Platform Documentation](https://docs.openshift.com/container-platform/4.13/)
- [Red Hat Developer Hub 1.6 Documentation](https://access.redhat.com/documentation/en-us/red_hat_developer_hub/1.6)
- [ARO Network Requirements](https://learn.microsoft.com/en-us/azure/openshift/tutorial-create-cluster#before-you-begin)
- [OpenShift Operator Lifecycle Manager](https://docs.openshift.com/container-platform/4.13/operators/understanding/olm/olm-understanding-olm.html)
- [Azure Database for PostgreSQL](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/)

---

> 📝 **Note:** This guide is aligned with the [Complete Integration Tutorial](../complete-integration-tutorial/index.md). For a comprehensive multi-service deployment, refer to that guide for the complete Three Horizons Platform setup.
