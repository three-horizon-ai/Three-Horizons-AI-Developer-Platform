#!/bin/bash
set -e

# Three Horizons - DevHub on AKS Deployment Script
# This script automates the deployment of Red Hat Developer Hub on AKS

echo "
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║   Three Horizons - Developer Hub on AKS Deployment Script      ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
"

# Check prerequisites
command -v az >/dev/null 2>&1 || { echo "Azure CLI is not installed. Please install it."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl is not installed. Please install it."; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "Helm is not installed. Please install it."; exit 1; }

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
DEFAULT_AKS_NAME="aks-threehorizons-dev"
DEFAULT_VNET_NAME="vnet-threehorizons"
DEFAULT_SUBNET_NAME="aks-subnet"
DEFAULT_ACR_NAME="acrthreehorizons"
DEFAULT_PSQL_NAME="psql-threehorizons"
DEFAULT_DOMAIN="yourdomain.com"

# Get user input or use defaults
echo "Please enter the following information (or press Enter to use the default):"
read -p "Resource Group [$DEFAULT_RESOURCE_GROUP]: " RESOURCE_GROUP
RESOURCE_GROUP=${RESOURCE_GROUP:-$DEFAULT_RESOURCE_GROUP}

read -p "Location [$DEFAULT_LOCATION]: " LOCATION
LOCATION=${LOCATION:-$DEFAULT_LOCATION}

read -p "AKS Cluster Name [$DEFAULT_AKS_NAME]: " AKS_NAME
AKS_NAME=${AKS_NAME:-$DEFAULT_AKS_NAME}

read -p "Virtual Network Name [$DEFAULT_VNET_NAME]: " VNET_NAME
VNET_NAME=${VNET_NAME:-$DEFAULT_VNET_NAME}

read -p "Subnet Name [$DEFAULT_SUBNET_NAME]: " SUBNET_NAME
SUBNET_NAME=${SUBNET_NAME:-$DEFAULT_SUBNET_NAME}

read -p "Container Registry Name [$DEFAULT_ACR_NAME]: " ACR_NAME
ACR_NAME=${ACR_NAME:-$DEFAULT_ACR_NAME}

read -p "PostgreSQL Server Name [$DEFAULT_PSQL_NAME]: " PSQL_NAME
PSQL_NAME=${PSQL_NAME:-$DEFAULT_PSQL_NAME}

read -p "Domain for Developer Hub [$DEFAULT_DOMAIN]: " DOMAIN
DOMAIN=${DOMAIN:-$DEFAULT_DOMAIN}

# Define a secure password for PostgreSQL
POSTGRES_PASSWORD=$(openssl rand -base64 16)

echo ""
echo "Summary of deployment parameters:"
echo "=================================="
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "AKS Cluster Name: $AKS_NAME"
echo "Virtual Network Name: $VNET_NAME"
echo "Subnet Name: $SUBNET_NAME"
echo "Container Registry Name: $ACR_NAME"
echo "PostgreSQL Server Name: $PSQL_NAME"
echo "Developer Hub Domain: $DOMAIN"
echo ""

if ! confirm "Do you want to proceed with the deployment?"; then
  echo "Deployment cancelled."
  exit 0
fi

echo -e "\n[1/8] Creating Resource Group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

echo -e "\n[2/8] Creating Virtual Network..."
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME \
  --address-prefixes 10.0.0.0/8

az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $SUBNET_NAME \
  --address-prefixes 10.0.0.0/16

echo -e "\n[3/8] Creating AKS Cluster..."
SUBNET_ID=$(az network vnet subnet show \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $SUBNET_NAME \
  --query id -o tsv)

az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --vnet-subnet-id $SUBNET_ID \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 \
  --enable-addons monitoring \
  --network-plugin azure

echo -e "\n[4/8] Creating Azure Container Registry..."
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Premium

echo -e "\n[5/8] Creating PostgreSQL Flexible Server..."
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

echo -e "\n[6/8] Creating DevHub database..."
az postgres flexible-server db create \
  --resource-group $RESOURCE_GROUP \
  --server-name $PSQL_NAME \
  --database-name backstagedb

echo -e "\n[7/8] Configure PostgreSQL Firewall..."
az postgres flexible-server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --name $PSQL_NAME \
  --rule-name "AllowAll" \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 255.255.255.255

echo -e "\n[8/8] Deploy Developer Hub..."
# Get AKS credentials
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --overwrite-existing

# Create namespace for Developer Hub
kubectl create namespace developer-hub

# Create secrets for PostgreSQL
kubectl create secret generic postgresql-credentials \
  --namespace developer-hub \
  --from-literal=POSTGRES_USER=devhubadmin \
  --from-literal=POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  --from-literal=POSTGRES_HOST="$PSQL_NAME.postgres.database.azure.com" \
  --from-literal=POSTGRES_PORT=5432 \
  --from-literal=POSTGRES_DATABASE=backstagedb

# Deploy Backstage with Helm
helm repo add backstage https://backstage.github.io/charts
helm repo update

helm install developer-hub backstage/backstage \
  --namespace developer-hub \
  --set postgresql.enabled=false \
  --set backend.databaseConnectionSecretName=postgresql-credentials

# Installation complete
echo -e "\n====================================================================="
echo "Installation completed successfully!"
echo "====================================================================="
echo ""
echo "To access your Developer Hub, you need to set up GitHub OAuth and configure ingress."
echo "Please follow the remaining steps in the documentation:"
echo "https://github.com/three-horizon/Three-Horizons-Playbook/blob/main/templates/arm/docs/devhub-aks-guide.md"
echo ""
echo "Important information:"
echo "---------------------"
echo "PostgreSQL Server: $PSQL_NAME.postgres.database.azure.com"
echo "PostgreSQL Username: devhubadmin"
echo "PostgreSQL Password: $POSTGRES_PASSWORD"
echo "PostgreSQL Database: backstagedb"
echo ""
echo "Make sure to save these credentials in a secure location!"
echo "=====================================================================" 