#!/bin/bash
# validate-checklist.sh - A script to validate checklist implementations
# This script verifies that steps in documentation checklists have been properly implemented

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default values
COMPONENT=""
TYPE="implementation"
VERBOSE=false
CHECK_ALL=false

# Display usage information
function show_usage {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --type TYPE          Type of checklist to validate (implementation, validation, troubleshooting, migration)"
    echo "  --component COMP     Component to validate (e.g., developer-hub, infrastructure, github-integration)"
    echo "  --verbose            Display detailed output for each check"
    echo "  --all                Validate all components"
    echo "  --help               Display this help message"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --type)
            TYPE="$2"
            shift
            shift
            ;;
        --component)
            COMPONENT="$2"
            shift
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --all)
            CHECK_ALL=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Validate arguments
if [[ -z "$COMPONENT" && "$CHECK_ALL" == "false" ]]; then
    echo -e "${RED}Error: Either --component or --all must be specified${NC}"
    show_usage
    exit 1
fi

if [[ ! "$TYPE" =~ ^(implementation|validation|troubleshooting|migration)$ ]]; then
    echo -e "${RED}Error: Type must be one of: implementation, validation, troubleshooting, migration${NC}"
    show_usage
    exit 1
fi

# Function to validate a component
function validate_component {
    local component=$1
    echo -e "${YELLOW}Validating $TYPE checklist for $component...${NC}"
    
    # Map components to actual validation functions
    case $component in
        developer-hub)
            validate_developer_hub
            ;;
        infrastructure)
            validate_infrastructure
            ;;
        github-integration)
            validate_github_integration
            ;;
        *)
            echo -e "${RED}Warning: No specific validation for component '$component', performing generic checks${NC}"
            validate_generic "$component"
            ;;
    esac
}

# Generic validation that uses command existence
function validate_generic {
    local component=$1
    local fail_count=0
    local pass_count=0
    
    # Simple validation based on command availability and basic checks
    if [[ "$component" == *"kubernetes"* || "$component" == *"aks"* || "$component" == *"openshift"* || "$component" == *"aro"* ]]; then
        if command -v kubectl &> /dev/null || command -v oc &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} Kubernetes CLI tools installed"
            ((pass_count++))
        else
            echo -e "  ${RED}✗${NC} Kubernetes CLI tools not found"
            ((fail_count++))
        fi
    fi
    
    if [[ "$component" == *"azure"* ]]; then
        if command -v az &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} Azure CLI installed"
            ((pass_count++))
        else
            echo -e "  ${RED}✗${NC} Azure CLI not found"
            ((fail_count++))
        fi
    fi
    
    if [[ "$component" == *"github"* ]]; then
        if command -v gh &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} GitHub CLI installed"
            ((pass_count++))
        else
            echo -e "  ${RED}✗${NC} GitHub CLI not found"
            ((fail_count++))
        fi
    fi
    
    echo -e "${YELLOW}Generic validation for '$component' completed: $pass_count passed, $fail_count failed${NC}"
}

# Developer Hub specific validation
function validate_developer_hub {
    local fail_count=0
    local pass_count=0
    
    # Check kubectl or oc command
    if command -v kubectl &> /dev/null || command -v oc &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Kubernetes CLI tools installed"
        ((pass_count++))
        
        # Check for namespace
        if kubectl get namespace developer-hub &> /dev/null || oc get project developer-hub &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} Developer Hub namespace exists"
            ((pass_count++))
            
            # Check for deployments
            if kubectl get deployments -n developer-hub &> /dev/null || oc get deployments -n developer-hub &> /dev/null; then
                echo -e "  ${GREEN}✓${NC} Developer Hub deployments exist"
                ((pass_count++))
            else
                echo -e "  ${RED}✗${NC} No deployments found in Developer Hub namespace"
                ((fail_count++))
            fi
        else
            echo -e "  ${RED}✗${NC} Developer Hub namespace not found"
            ((fail_count++))
        fi
    else
        echo -e "  ${RED}✗${NC} Kubernetes CLI tools not found"
        ((fail_count++))
    fi
    
    # Database connection check
    if kubectl get secrets -n developer-hub -o json | grep -q "postgresql-credentials" || \
       oc get secrets -n developer-hub -o json | grep -q "postgresql-credentials"; then
        echo -e "  ${GREEN}✓${NC} PostgreSQL credentials secret exists"
        ((pass_count++))
    else
        echo -e "  ${RED}✗${NC} PostgreSQL credentials secret not found"
        ((fail_count++))
    fi
    
    echo -e "${YELLOW}Developer Hub validation completed: $pass_count passed, $fail_count failed${NC}"
}

# Infrastructure validation
function validate_infrastructure {
    local fail_count=0
    local pass_count=0
    
    # Check Azure CLI
    if command -v az &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Azure CLI installed"
        ((pass_count++))
        
        # Check if logged in to Azure
        if az account show &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} Logged in to Azure"
            ((pass_count++))
            
            # Check resource group existence
            if az group list --query "[?contains(name, 'three') || contains(name, 'horizon')].name" -o tsv | grep -q .; then
                echo -e "  ${GREEN}✓${NC} Three Horizons resource group(s) exist"
                ((pass_count++))
            else
                echo -e "  ${RED}✗${NC} No Three Horizons resource groups found"
                ((fail_count++))
            fi
        else
            echo -e "  ${RED}✗${NC} Not logged in to Azure"
            ((fail_count++))
        fi
    else
        echo -e "  ${RED}✗${NC} Azure CLI not found"
        ((fail_count++))
    fi
    
    echo -e "${YELLOW}Infrastructure validation completed: $pass_count passed, $fail_count failed${NC}"
}

# GitHub integration validation
function validate_github_integration {
    local fail_count=0
    local pass_count=0
    
    # Check GitHub CLI
    if command -v gh &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} GitHub CLI installed"
        ((pass_count++))
        
        # Check if logged in to GitHub
        if gh auth status &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} Authenticated with GitHub"
            ((pass_count++))
        else
            echo -e "  ${RED}✗${NC} Not authenticated with GitHub"
            ((fail_count++))
        fi
    else
        echo -e "  ${RED}✗${NC} GitHub CLI not found"
        ((fail_count++))
    fi
    
    echo -e "${YELLOW}GitHub integration validation completed: $pass_count passed, $fail_count failed${NC}"
}

# Main execution
echo -e "${YELLOW}Starting $TYPE checklist validation...${NC}"

if [[ "$CHECK_ALL" == "true" ]]; then
    # Validate all components
    validate_component "developer-hub"
    validate_component "infrastructure"
    validate_component "github-integration"
else
    # Validate specific component
    validate_component "$COMPONENT"
fi

echo -e "${GREEN}Checklist validation complete!${NC}" 