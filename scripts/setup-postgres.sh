#!/bin/bash
# Three Horizons Platform - PostgreSQL Setup Script
# This script automates the creation and configuration of an Azure PostgreSQL Flexible Server
# for use with the Three Horizons Platform.

set -e

# Display banner
echo "
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║   Three Horizons Platform - PostgreSQL Database Setup          ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
"

# Check prerequisites
command -v az >/dev/null 2>&1 || { echo "Error: Azure CLI is required but not installed. Please install it first."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "Error: kubectl is required but not installed. Please install it first."; exit 1; }

# Check if logged into Azure
if ! az account show &>/dev/null; then
  echo "You are not logged into Azure. Please log in now."
  az login
fi

# Default values
DEFAULT_RESOURCE_GROUP="three-horizons-shared"
# Add timestamp to database name for uniqueness
TIMESTAMP=$(date +"%m%d%H%M")
DEFAULT_DB_NAME="backstagedb-${TIMESTAMP}"
DEFAULT_LOCATION="centralus"
DEFAULT_ADMIN_USER="backstage"
DEFAULT_DATABASE_NAME="backstage"
DEFAULT_KEY_VAULT_NAME=""

# Get configuration from user
echo "Please enter the following information (or press Enter to use defaults):"

read -p "Resource Group [$DEFAULT_RESOURCE_GROUP]: " RESOURCE_GROUP
RESOURCE_GROUP=${RESOURCE_GROUP:-$DEFAULT_RESOURCE_GROUP}

read -p "PostgreSQL Server Name [$DEFAULT_DB_NAME]: " DB_SERVER_NAME
DB_SERVER_NAME=${DB_SERVER_NAME:-$DEFAULT_DB_NAME}

read -p "Location [$DEFAULT_LOCATION]: " LOCATION
LOCATION=${LOCATION:-$DEFAULT_LOCATION}

read -p "Admin Username [$DEFAULT_ADMIN_USER]: " ADMIN_USER
ADMIN_USER=${ADMIN_USER:-$DEFAULT_ADMIN_USER}

read -p "Database Name [$DEFAULT_DATABASE_NAME]: " DATABASE_NAME
DATABASE_NAME=${DATABASE_NAME:-$DEFAULT_DATABASE_NAME}

read -sp "Admin Password (leave empty for auto-generated): " ADMIN_PASSWORD
echo ""
if [ -z "$ADMIN_PASSWORD" ]; then
  ADMIN_PASSWORD=$(openssl rand -base64 16)
  echo "Generated password: $ADMIN_PASSWORD"
  echo "Please save this password in a secure location!"
fi

read -p "Key Vault Name (leave empty to skip Key Vault storage): " KEY_VAULT_NAME
KEY_VAULT_NAME=${KEY_VAULT_NAME:-$DEFAULT_KEY_VAULT_NAME}

read -p "Kubernetes Namespace for secret [developer-hub]: " K8S_NAMESPACE
K8S_NAMESPACE=${K8S_NAMESPACE:-"developer-hub"}

# Confirm configuration
echo ""
echo "Configuration Summary:"
echo "======================"
echo "Resource Group: $RESOURCE_GROUP"
echo "PostgreSQL Server Name: $DB_SERVER_NAME"
echo "Location: $LOCATION"
echo "Admin Username: $ADMIN_USER"
echo "Database Name: $DATABASE_NAME"
if [ -n "$KEY_VAULT_NAME" ]; then
  echo "Key Vault Name: $KEY_VAULT_NAME"
fi
echo "Kubernetes Namespace: $K8S_NAMESPACE"
echo ""

read -p "Do you want to proceed with this configuration? (y/n): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Setup cancelled."
  exit 0
fi

# Check if resource group exists, create if not
if ! az group show --name "$RESOURCE_GROUP" &>/dev/null; then
  echo "Resource group '$RESOURCE_GROUP' does not exist. Creating it now..."
  az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
fi

# Create PostgreSQL Flexible Server
echo -e "\n[1/4] Creating Azure PostgreSQL Flexible Server..."
az postgres flexible-server create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$DB_SERVER_NAME" \
  --admin-user "$ADMIN_USER" \
  --admin-password "$ADMIN_PASSWORD" \
  --sku-name Standard_D2s_v3 \
  --tier GeneralPurpose \
  --storage-size 32 \
  --version 14 \
  --high-availability ZoneRedundant \
  --location "$LOCATION" \
  --database-name "$DATABASE_NAME" \
  --tags Environment=Production Project=ThreeHorizons \
  --yes

echo -e "\n[2/4] Configuring firewall rules..."
az postgres flexible-server firewall-rule create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$DB_SERVER_NAME" \
  --rule-name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# Store in Key Vault if specified
if [ -n "$KEY_VAULT_NAME" ]; then
  echo -e "\n[3/4] Storing credentials in Key Vault..."
  
  # Check if Key Vault exists
  if ! az keyvault show --name "$KEY_VAULT_NAME" &>/dev/null; then
    echo "Key Vault '$KEY_VAULT_NAME' does not exist. Creating it now..."
    az keyvault create --name "$KEY_VAULT_NAME" --resource-group "$RESOURCE_GROUP" --location "$LOCATION"
  fi
  
  # Check RBAC permissions and assign if needed
  if ! az keyvault secret show --name "test-permission" --vault-name "$KEY_VAULT_NAME" &>/dev/null; then
    # Failed to read a secret, might not exist or might be permission issue
    echo "Checking Key Vault permissions..."
    
    # Try to set a test secret to verify permissions
    if ! az keyvault secret set --name "test-permission" --vault-name "$KEY_VAULT_NAME" --value "test" &>/dev/null; then
      echo "You don't have sufficient permissions to store secrets in this Key Vault."
      echo "Attempting to assign Key Vault Secrets Officer role to your account..."
      
      CURRENT_USER=$(az account show --query user.name -o tsv)
      KEYVAULT_SCOPE=$(az keyvault show --name "$KEY_VAULT_NAME" --resource-group "$RESOURCE_GROUP" --query id -o tsv)
      
      az role assignment create \
        --role "Key Vault Secrets Officer" \
        --assignee "$CURRENT_USER" \
        --scope "$KEYVAULT_SCOPE"
      
      echo "Role assigned successfully. Note that it may take 5-15 minutes for the permissions to fully propagate."
      echo "You can proceed with the script, but if you encounter permission errors,"
      echo "you may need to wait and run the script again later."
      sleep 5 # Give user a chance to read the message
    else
      echo "Permissions verified successfully."
      # Clean up the test secret
      az keyvault secret delete --name "test-permission" --vault-name "$KEY_VAULT_NAME" &>/dev/null
    fi
  fi
  
  # Store credentials
  echo "Storing database password in Key Vault..."
  if ! az keyvault secret set \
    --name db-password \
    --vault-name "$KEY_VAULT_NAME" \
    --value "$ADMIN_PASSWORD" &>/dev/null; then
    
    echo "Warning: Unable to store password in Key Vault. This is likely a permission issue."
    echo "RBAC permissions can take 5-15 minutes to propagate after assignment."
    echo "Continuing deployment, but you may need to manually store the password later."
  else
    echo "Credentials stored in Key Vault successfully."
  fi
else
  echo -e "\n[3/4] Skipping Key Vault storage."
fi

# Get the database host
DB_HOST=$(az postgres flexible-server show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$DB_SERVER_NAME" \
  --query fullyQualifiedDomainName \
  --output tsv)

echo -e "\n[4/4] Creating Kubernetes secret..."
# Check if namespace exists
if ! kubectl get namespace "$K8S_NAMESPACE" &>/dev/null; then
  echo "Kubernetes namespace '$K8S_NAMESPACE' does not exist. Creating it now..."
  kubectl create namespace "$K8S_NAMESPACE"
fi

# Create Kubernetes secret
kubectl create secret generic developer-hub-postgres \
  --namespace "$K8S_NAMESPACE" \
  --from-literal=postgres-password="$ADMIN_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

echo -e "\n====================================================================="
echo "PostgreSQL Setup Completed Successfully!"
echo "====================================================================="
echo ""
echo "PostgreSQL Server: $DB_HOST"
echo "Admin Username: $ADMIN_USER"
echo "Admin Password: $ADMIN_PASSWORD"
echo "Database Name: $DATABASE_NAME"
echo ""
echo "Configuration:"
echo "- Resource Group: $RESOURCE_GROUP"
echo "- Server Name: $DB_SERVER_NAME"
echo "- Kubernetes Secret: developer-hub-postgres (in namespace $K8S_NAMESPACE)"
if [ -n "$KEY_VAULT_NAME" ]; then
  echo "- Key Vault Secret: db-password (in $KEY_VAULT_NAME)"
fi
echo ""
echo "Next Steps:"
echo "1. Use the DB_HOST value in your Developer Hub configuration."
echo "2. The Kubernetes secret 'developer-hub-postgres' has been created and can be referenced in your deployment."
echo ""
echo "Important: Save these credentials in a secure location!"
echo "=====================================================================" 