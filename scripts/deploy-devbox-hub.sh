#!/bin/bash

# Azure Dev Box Deployment Script - Hub-Spoke Architecture
# Deploys complete hub-spoke infrastructure in a single resource group
# Following Azure best practices for Dev Box management

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration variables
ORGANIZATION_NAME="three-horizons"
PROJECT_NAME="developer-hub"
LOCATION="eastus2"
ENVIRONMENT="dev"
DEVELOPER_NAME=""
TEAM_NAME=""
NETWORK_TYPE="microsoft-hosted"
DEVBOX_DEFINITION="standard-dev-workstation"
USER_PRINCIPAL_ID=""
MAX_DEVBOXES_PER_USER=3
AUTO_STOP_ENABLED=true
AUTO_STOP_GRACE_PERIOD=60

# Generate unique instance ID with timestamp
INSTANCE_ID=$(date +%Y%m%d-%H%M)
UNIQUE_SUFFIX=$(echo $RANDOM | md5sum | head -c 6)
FULL_INSTANCE_ID="${INSTANCE_ID}-${UNIQUE_SUFFIX}"

# Resource Group name following Azure CAF
RESOURCE_GROUP_NAME="rg-${ORGANIZATION_NAME}-devbox-${ENVIRONMENT}-${LOCATION}-${FULL_INSTANCE_ID}"

print_status "Starting Azure Dev Box Hub-Spoke Architecture Deployment"
echo "=================================================="
echo "Organization: ${ORGANIZATION_NAME}"
echo "Project: ${PROJECT_NAME}"
echo "Environment: ${ENVIRONMENT}"
echo "Location: ${LOCATION}"
echo "Instance ID: ${FULL_INSTANCE_ID}"
echo "Resource Group: ${RESOURCE_GROUP_NAME}"
echo "=================================================="

# Function to check if user is logged in to Azure
check_azure_login() {
    print_status "Checking Azure login status..."
    if ! az account show &> /dev/null; then
        print_error "Not logged in to Azure. Please run 'az login' first."
        exit 1
    fi
    
    CURRENT_USER=$(az account show --query "user.name" --output tsv)
    SUBSCRIPTION_NAME=$(az account show --query "name" --output tsv)
    print_success "Logged in as: ${CURRENT_USER}"
    print_success "Using subscription: ${SUBSCRIPTION_NAME}"
}

# Function to get user principal ID if not provided
get_user_principal_id() {
    if [ -z "$USER_PRINCIPAL_ID" ]; then
        print_status "Getting current user principal ID..."
        USER_PRINCIPAL_ID=$(az ad signed-in-user show --query "id" --output tsv)
        if [ -z "$USER_PRINCIPAL_ID" ]; then
            print_error "Could not retrieve user principal ID. Please provide it manually."
            read -p "Enter your User Principal ID: " USER_PRINCIPAL_ID
        fi
    fi
    print_success "User Principal ID: ${USER_PRINCIPAL_ID}"
}

# Function to get developer and team names if not provided
get_developer_info() {
    if [ -z "$DEVELOPER_NAME" ]; then
        read -p "Enter developer name: " DEVELOPER_NAME
    fi
    
    if [ -z "$TEAM_NAME" ]; then
        read -p "Enter team name: " TEAM_NAME
    fi
    
    print_success "Developer: ${DEVELOPER_NAME}, Team: ${TEAM_NAME}"
}

# Function to create resource group
create_resource_group() {
    print_status "Creating resource group: ${RESOURCE_GROUP_NAME}"
    
    if az group show --name "$RESOURCE_GROUP_NAME" &> /dev/null; then
        print_warning "Resource group already exists"
    else
        az group create \
            --name "$RESOURCE_GROUP_NAME" \
            --location "$LOCATION" \
            --tags \
                Organization="$ORGANIZATION_NAME" \
                Environment="$ENVIRONMENT" \
                Project="$PROJECT_NAME" \
                CreatedBy="DevBox-Script" \
                InstanceId="$FULL_INSTANCE_ID" \
                CreatedDate="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
        
        print_success "Resource group created successfully"
    fi
}

# Function to validate Bicep template
validate_template() {
    print_status "Validating Bicep template..."
    
    local template_path="./devbox-complete.bicep"
    if [ ! -f "$template_path" ]; then
        print_error "Template file not found: $template_path"
        exit 1
    fi
    
    az deployment group validate \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --template-file "$template_path" \
        --parameters \
            organizationName="$ORGANIZATION_NAME" \
            projectName="$PROJECT_NAME" \
            location="$LOCATION" \
            developerName="$DEVELOPER_NAME" \
            teamName="$TEAM_NAME" \
            environment="$ENVIRONMENT" \
            instanceId="$FULL_INSTANCE_ID" \
            networkType="$NETWORK_TYPE" \
            devBoxDefinition="$DEVBOX_DEFINITION" \
            userPrincipalId="$USER_PRINCIPAL_ID" \
            maxDevBoxesPerUser="$MAX_DEVBOXES_PER_USER" \
            autoStopEnabled="$AUTO_STOP_ENABLED" \
            autoStopGracePeriodMinutes="$AUTO_STOP_GRACE_PERIOD"
    
    print_success "Template validation passed"
}

# Function to deploy the infrastructure
deploy_infrastructure() {
    print_status "Deploying Azure Dev Box infrastructure..."
    
    local deployment_name="devbox-complete-${FULL_INSTANCE_ID}"
    
    az deployment group create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$deployment_name" \
        --template-file "./devbox-complete.bicep" \
        --parameters \
            organizationName="$ORGANIZATION_NAME" \
            projectName="$PROJECT_NAME" \
            location="$LOCATION" \
            developerName="$DEVELOPER_NAME" \
            teamName="$TEAM_NAME" \
            environment="$ENVIRONMENT" \
            instanceId="$FULL_INSTANCE_ID" \
            networkType="$NETWORK_TYPE" \
            devBoxDefinition="$DEVBOX_DEFINITION" \
            userPrincipalId="$USER_PRINCIPAL_ID" \
            maxDevBoxesPerUser="$MAX_DEVBOXES_PER_USER" \
            autoStopEnabled="$AUTO_STOP_ENABLED" \
            autoStopGracePeriodMinutes="$AUTO_STOP_GRACE_PERIOD" \
        --output table
    
    print_success "Infrastructure deployment completed"
}

# Function to get deployment outputs
get_deployment_outputs() {
    print_status "Retrieving deployment information..."
    
    local deployment_name="devbox-complete-${FULL_INSTANCE_ID}"
    
    # Get outputs
    local outputs=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$deployment_name" \
        --query "properties.outputs" \
        --output json)
    
    echo "$outputs" > "./deployment-outputs-${FULL_INSTANCE_ID}.json"
    
    # Extract key information
    local dev_center_name=$(echo "$outputs" | jq -r '.hubInfrastructure.value.devCenterName')
    local project_name=$(echo "$outputs" | jq -r '.initialProject.value.projectName')
    local developer_portal_url=$(echo "$outputs" | jq -r '.initialProject.value.developerPortalUrl')
    
    print_success "Deployment outputs saved to: deployment-outputs-${FULL_INSTANCE_ID}.json"
    echo
    echo "=================================================="
    echo "DEPLOYMENT SUMMARY"
    echo "=================================================="
    echo "Dev Center: ${dev_center_name}"
    echo "Initial Project: ${project_name}"
    echo "Developer Portal: ${developer_portal_url}"
    echo "Resource Group: ${RESOURCE_GROUP_NAME}"
    echo "Instance ID: ${FULL_INSTANCE_ID}"
    echo "=================================================="
}

# Function to display next steps
show_next_steps() {
    print_success "Deployment completed successfully!"
    echo
    echo "Next Steps:"
    echo "1. Access the developer portal: https://devbox.microsoft.com/"
    echo "2. Create your first dev box using the available definitions"
    echo "3. For additional projects, use: devbox-project.bicep"
    echo "4. Monitor resources in Azure Portal"
    echo
    echo "Additional Projects:"
    echo "To create additional projects for other teams, run:"
    echo "az deployment group create \\"
    echo "  --resource-group $RESOURCE_GROUP_NAME \\"
    echo "  --template-file ./devbox-project.bicep \\"
    echo "  --parameters \\"
    echo "    projectName=\"new-project-name\" \\"
    echo "    devCenterId=\"/subscriptions/\$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.DevCenter/devcenters/${dev_center_name}\" \\"
    echo "    ..."
}

# Main execution
main() {
    check_azure_login
    get_user_principal_id
    get_developer_info
    create_resource_group
    validate_template
    deploy_infrastructure
    get_deployment_outputs
    show_next_steps
}

# Run main function
main "$@"
