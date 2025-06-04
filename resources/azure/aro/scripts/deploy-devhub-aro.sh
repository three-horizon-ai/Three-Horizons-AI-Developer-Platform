#!/bin/bash
set -e

# Three Horizons - DevHub on ARO Deployment Script
# This script automates the deployment of Red Hat Developer Hub on Azure Red Hat OpenShift

echo "
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║   Three Horizons - Developer Hub on ARO Deployment Script      ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
"

# Check prerequisites
command -v az >/dev/null 2>&1 || { echo "Azure CLI is not installed. Please install it."; exit 1; }
command -v oc >/dev/null 2>&1 || { echo "OpenShift CLI (oc) is not installed. Please install it."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is not installed. Please install it."; exit 1; }

# Make sure the user is logged in to Azure
if ! az account show &>/dev/null; then
  echo "Please log in to your Azure account"
  az login
fi

# Function to prompt for confirmation
function confirm() {
  read -r -p "$1 [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY]) 
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# Configuration - Default values
DEFAULT_RESOURCE_GROUP="rg-threehorizons-dev"
DEFAULT_LOCATION="centralus"
DEFAULT_ARO_NAME="aro-threehorizons-dev"
DEFAULT_VNET_NAME="vnet-threehorizons"
DEFAULT_MASTER_SUBNET_NAME="master-subnet"
DEFAULT_WORKER_SUBNET_NAME="worker-subnet"
DEFAULT_ACR_NAME="acrthreehorizons"
DEFAULT_PSQL_NAME="psql-threehorizons"
DEFAULT_DOMAIN="yourdomain.com"

# Get user input or use defaults
echo "Please enter the following information (or press Enter to use the default):"
read -p "Resource Group [$DEFAULT_RESOURCE_GROUP]: " RESOURCE_GROUP
RESOURCE_GROUP=${RESOURCE_GROUP:-$DEFAULT_RESOURCE_GROUP}

read -p "Location [$DEFAULT_LOCATION]: " LOCATION
LOCATION=${LOCATION:-$DEFAULT_LOCATION}

read -p "ARO Cluster Name [$DEFAULT_ARO_NAME]: " ARO_NAME
ARO_NAME=${ARO_NAME:-$DEFAULT_ARO_NAME}

read -p "Virtual Network Name [$DEFAULT_VNET_NAME]: " VNET_NAME
VNET_NAME=${VNET_NAME:-$DEFAULT_VNET_NAME}

read -p "Master Subnet Name [$DEFAULT_MASTER_SUBNET_NAME]: " MASTER_SUBNET_NAME
MASTER_SUBNET_NAME=${MASTER_SUBNET_NAME:-$DEFAULT_MASTER_SUBNET_NAME}

read -p "Worker Subnet Name [$DEFAULT_WORKER_SUBNET_NAME]: " WORKER_SUBNET_NAME
WORKER_SUBNET_NAME=${WORKER_SUBNET_NAME:-$DEFAULT_WORKER_SUBNET_NAME}

read -p "Container Registry Name [$DEFAULT_ACR_NAME]: " ACR_NAME
ACR_NAME=${ACR_NAME:-$DEFAULT_ACR_NAME}

read -p "PostgreSQL Server Name [$DEFAULT_PSQL_NAME]: " PSQL_NAME
PSQL_NAME=${PSQL_NAME:-$DEFAULT_PSQL_NAME}

read -p "Domain for Developer Hub [$DEFAULT_DOMAIN]: " DOMAIN
DOMAIN=${DOMAIN:-$DEFAULT_DOMAIN}

# Get Red Hat Pull Secret path
read -p "Path to Red Hat Pull Secret file: " PULL_SECRET_PATH
if [ ! -f "$PULL_SECRET_PATH" ]; then
  echo "Pull Secret file does not exist at $PULL_SECRET_PATH"
  exit 1
fi

# Define a secure password for PostgreSQL
POSTGRES_PASSWORD=$(openssl rand -base64 16)

echo ""
echo "Summary of deployment parameters:"
echo "=================================="
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "ARO Cluster Name: $ARO_NAME"
echo "Virtual Network Name: $VNET_NAME"
echo "Master Subnet Name: $MASTER_SUBNET_NAME"
echo "Worker Subnet Name: $WORKER_SUBNET_NAME"
echo "Container Registry Name: $ACR_NAME"
echo "PostgreSQL Server Name: $PSQL_NAME"
echo "Developer Hub Domain: $DOMAIN"
echo "Pull Secret Path: $PULL_SECRET_PATH"
echo ""

if ! confirm "Do you want to proceed with the deployment?"; then
  echo "Deployment cancelled."
  exit 0
fi

echo -e "\n[1/10] Creating Resource Group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

echo -e "\n[2/10] Creating Virtual Network..."
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME \
  --address-prefixes 10.0.0.0/8

az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $MASTER_SUBNET_NAME \
  --address-prefixes 10.0.0.0/23 \
  --service-endpoints Microsoft.ContainerRegistry

az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $WORKER_SUBNET_NAME \
  --address-prefixes 10.0.2.0/23 \
  --service-endpoints Microsoft.ContainerRegistry

az network vnet subnet update \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $MASTER_SUBNET_NAME \
  --disable-private-link-service-network-policies true

echo -e "\n[3/10] Creating Service Principal..."
SP_JSON=$(az ad sp create-for-rbac --name "sp-$ARO_NAME" --role Contributor)
SP_ID=$(echo $SP_JSON | jq -r .appId)
SP_SECRET=$(echo $SP_JSON | jq -r .password)

echo "Service Principal ID: $SP_ID"
echo "Service Principal Secret: $SP_SECRET"

echo -e "\n[4/10] Creating ARO Cluster..."
az aro create \
  --resource-group $RESOURCE_GROUP \
  --name $ARO_NAME \
  --vnet $VNET_NAME \
  --master-subnet $MASTER_SUBNET_NAME \
  --worker-subnet $WORKER_SUBNET_NAME \
  --pull-secret @$PULL_SECRET_PATH \
  --client-id $SP_ID \
  --client-secret $SP_SECRET

echo -e "\n[5/10] Creating Azure Container Registry..."
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Premium

echo -e "\n[6/10] Creating PostgreSQL Flexible Server..."
az postgres flexible-server create \
  --resource-group $RESOURCE_GROUP \
  --name $PSQL_NAME \
  --location $LOCATION \
  --admin-user devhubadmin \
  --admin-password "$POSTGRES_PASSWORD" \
  --sku-name Standard_D2s_v3 \
  --tier GeneralPurpose \
  --version 14 \
  --storage-size 128 \
  --yes

echo -e "\n[7/10] Creating DevHub database..."
az postgres flexible-server db create \
  --resource-group $RESOURCE_GROUP \
  --server-name $PSQL_NAME \
  --database-name backstagedb

echo -e "\n[8/10] Configure PostgreSQL Firewall..."
az postgres flexible-server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --name $PSQL_NAME \
  --rule-name "AllowAll" \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 255.255.255.255

echo -e "\n[9/10] Connect to ARO Cluster..."
ARO_API_SERVER=$(az aro show --name $ARO_NAME --resource-group $RESOURCE_GROUP --query apiserverProfile.url -o tsv)
ARO_ADMIN_USERNAME=$(az aro list-credentials --name $ARO_NAME --resource-group $RESOURCE_GROUP --query kubeadminUsername -o tsv)
ARO_ADMIN_PASSWORD=$(az aro list-credentials --name $ARO_NAME --resource-group $RESOURCE_GROUP --query kubeadminPassword -o tsv)

echo "ARO API Server: $ARO_API_SERVER"
echo "ARO Admin Username: $ARO_ADMIN_USERNAME"
echo "ARO Admin Password: $ARO_ADMIN_PASSWORD"

# Log in to the ARO cluster
oc login $ARO_API_SERVER -u $ARO_ADMIN_USERNAME -p $ARO_ADMIN_PASSWORD --insecure-skip-tls-verify=true

echo -e "\n[10/10] Installing Red Hat Developer Hub Operator..."
# Create Developer Hub Operator subscription
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: rhoscopilot-operator
  namespace: openshift-operators
spec:
  channel: stable
  name: rhoscopilot-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

echo "Waiting for the Red Hat Developer Hub Operator to be installed..."
sleep 60  # Initial wait for operator to start installing

# Create a project for Developer Hub
oc new-project developer-hub

# Create secret for PostgreSQL connection
oc create secret generic postgresql-credentials \
  --namespace developer-hub \
  --from-literal=POSTGRES_USER=devhubadmin \
  --from-literal=POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  --from-literal=POSTGRES_HOST="$PSQL_NAME.postgres.database.azure.com" \
  --from-literal=POSTGRES_PORT=5432 \
  --from-literal=POSTGRES_DATABASE=backstagedb

# Create a Developer Hub custom resource
cat <<EOF | oc apply -f -
apiVersion: redhat.developers/v1alpha1
kind: DeveloperHub
metadata:
  name: developer-hub
  namespace: developer-hub
spec:
  database:
    enableLocalPostgres: false
    externalPostgresCreds: postgresql-credentials
  rbac:
    enabled: true
  route:
    enabled: true
    host: devhub.$DOMAIN
    tls:
      insecureEdgeTerminationPolicy: Redirect
      termination: edge
  capacityConfig:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 2
      memory: 4Gi
EOF

echo "Waiting for Developer Hub to start deploying..."
sleep 30

# Installation complete
echo -e "\n====================================================================="
echo "Installation completed successfully!"
echo "====================================================================="
echo ""
echo "To access your Developer Hub, you need to set up GitHub OAuth and complete configuration."
echo "Please follow the remaining steps in the documentation:"
echo "https://github.com/three-horizon/Three-Horizons-Playbook/blob/main/templates/arm/docs/devhub-aro-guide.md"
echo ""
echo "Important information:"
echo "---------------------"
echo "ARO Console URL: https://$ARO_API_SERVER/console"
echo "ARO Admin Username: $ARO_ADMIN_USERNAME"
echo "ARO Admin Password: $ARO_ADMIN_PASSWORD"
echo ""
echo "PostgreSQL Server: $PSQL_NAME.postgres.database.azure.com"
echo "PostgreSQL Username: devhubadmin"
echo "PostgreSQL Password: $POSTGRES_PASSWORD"
echo "PostgreSQL Database: backstagedb"
echo ""
echo "Developer Hub URL will be available at: https://devhub.$DOMAIN"
echo ""
echo "Make sure to save these credentials in a secure location!"
echo "=====================================================================" 