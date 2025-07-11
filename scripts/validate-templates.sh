#!/bin/bash
#
# Three Horizons AI Platform - Template Validation Script
# Validates all Bicep templates against Azure best practices
#

set -e

echo "🔍 Three Horizons AI Platform - Template Validation"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_FILES=0
PASSED_FILES=0
FAILED_FILES=0

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
        PASSED_FILES=$((PASSED_FILES + 1))
    else
        echo -e "${RED}❌ $2${NC}"
        FAILED_FILES=$((FAILED_FILES + 1))
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if Azure CLI is available
if ! command -v az &> /dev/null; then
    echo -e "${RED}Azure CLI not found. Please install Azure CLI first.${NC}"
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}Please login to Azure CLI first: az login${NC}"
    exit 1
fi

echo ""
echo "🔧 Bicep Template Validation"
echo "----------------------------"

# Find all Bicep files
BICEP_FILES=$(find . -name "*.bicep" -type f | grep -v node_modules | sort)

if [ -z "$BICEP_FILES" ]; then
    echo -e "${YELLOW}No Bicep files found in the repository.${NC}"
    exit 0
fi

echo "Found Bicep files:"
for file in $BICEP_FILES; do
    echo "  $file"
    TOTAL_FILES=$((TOTAL_FILES + 1))
done

echo ""

# Validate each Bicep file
for bicep_file in $BICEP_FILES; do
    echo "Validating: $bicep_file"
    
    # 1. Bicep linting
    if az bicep lint --file "$bicep_file" &> /dev/null; then
        print_status 0 "Bicep linting passed for $bicep_file"
    else
        print_status 1 "Bicep linting failed for $bicep_file"
        echo "Run: az bicep lint --file $bicep_file"
    fi
    
    # 2. Check naming conventions
    echo "  Checking naming conventions..."
    
    # Check for camelCase in parameters and variables
    if grep -E "param [a-z][a-zA-Z0-9]*[A-Z]" "$bicep_file" &> /dev/null; then
        print_status 0 "Parameter naming follows camelCase"
    else
        print_warning "Consider using camelCase for parameters in $bicep_file"
    fi
    
    # Check for uniqueString usage for global resources
    if grep -E "(storageAccount|keyVault|containerRegistry)" "$bicep_file" &> /dev/null; then
        if grep "uniqueString" "$bicep_file" &> /dev/null; then
            print_status 0 "Uses uniqueString for global resource naming"
        else
            print_warning "Consider using uniqueString() for global resources in $bicep_file"
        fi
    fi
    
    # 3. Check for security best practices
    echo "  Checking security practices..."
    
    # Check for managed identity usage
    if grep -i "managedidentity\|systemassigned" "$bicep_file" &> /dev/null; then
        print_status 0 "Uses managed identity authentication"
    else
        print_warning "Consider using managed identity for authentication in $bicep_file"
    fi
    
    # Check for RBAC enablement
    if grep -i "enablerbac\|rbacauthorization" "$bicep_file" &> /dev/null; then
        print_status 0 "RBAC configuration found"
    else
        print_warning "Consider enabling RBAC in $bicep_file"
    fi
    
    # 4. Check documentation
    echo "  Checking documentation..."
    
    # Check for parameter descriptions
    param_count=$(grep -c "^param " "$bicep_file" || true)
    description_count=$(grep -c "@description" "$bicep_file" || true)
    
    if [ $param_count -eq $description_count ] && [ $param_count -gt 0 ]; then
        print_status 0 "All parameters have descriptions"
    elif [ $param_count -gt 0 ]; then
        print_warning "Some parameters missing descriptions in $bicep_file"
    fi
    
    # Check for English comments
    if grep -E "//.*[áàâãéèêíìîóòôõúùûç]" "$bicep_file" &> /dev/null; then
        print_status 1 "Non-English characters found in comments"
    else
        print_status 0 "Comments are in English"
    fi
    
    # 5. Check for resource organization
    echo "  Checking resource organization..."
    
    # Check for proper module usage
    if grep "module " "$bicep_file" &> /dev/null; then
        print_status 0 "Uses modular architecture"
    else
        print_warning "Consider using modules for better organization in $bicep_file"
    fi
    
    # Check for tags usage
    if grep -i "tags" "$bicep_file" &> /dev/null; then
        print_status 0 "Includes resource tagging"
    else
        print_warning "Consider adding tags for resource management in $bicep_file"
    fi
    
    echo ""
done

# Validate template structure
echo "🏗️  Template Structure Validation"
echo "--------------------------------"

# Check for required directories
required_dirs=("templates/h0-devbox" "templates/h1-foundation" "templates/h2-optimization" "templates/h3-innovation")
for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        print_status 0 "Directory exists: $dir"
    else
        print_status 1 "Missing directory: $dir"
    fi
done

# Check for infra directories in templates
echo ""
echo "📁 Infrastructure Directory Structure"
echo "------------------------------------"

for template_dir in templates/*/; do
    if [ -d "$template_dir" ]; then
        template_name=$(basename "$template_dir")
        echo "Checking template: $template_name"
        
        # Check for skeleton directory
        if [ -d "${template_dir}skeleton" ]; then
            print_status 0 "Skeleton directory exists"
        else
            print_status 1 "Missing skeleton directory in $template_name"
        fi
        
        # Check for infra directory (except H0 devbox)
        if [ "$template_name" != "h0-devbox" ]; then
            if [ -d "${template_dir}skeleton/infra" ] || [ -d "${template_dir}skeleton/infrastructure" ]; then
                print_status 0 "Infrastructure directory exists"
            else
                print_status 1 "Missing infra/infrastructure directory in $template_name"
            fi
        fi
        
        # Check for template.yaml
        if [ -f "${template_dir}template.yaml" ]; then
            print_status 0 "Template definition exists"
        else
            print_status 1 "Missing template.yaml in $template_name"
        fi
        
        # Check for README.md
        if [ -f "${template_dir}README.md" ]; then
            print_status 0 "Documentation exists"
        else
            print_status 1 "Missing README.md in $template_name"
        fi
    fi
done

# Check for Azure naming compliance
echo ""
echo "🏷️  Azure Naming Convention Compliance"
echo "-------------------------------------"

# Find parameter files
PARAM_FILES=$(find . -name "*.parameters.json" -o -name "parameters*.json" | grep -v node_modules)

for param_file in $PARAM_FILES; do
    echo "Checking parameter file: $param_file"
    
    # Check for proper naming patterns
    if jq -e '.parameters | to_entries[] | select(.key | test("Name$")) | .value.value | test("^[a-z]+-[a-z]+-[a-z]+-[a-z]+-[0-9]+$")' "$param_file" &> /dev/null; then
        print_status 0 "Follows Azure CAF naming convention"
    else
        print_warning "Consider following Azure CAF naming convention: {resource-type}-{workload}-{environment}-{region}-{instance}"
    fi
done

# Validate CI/CD pipeline files
echo ""
echo "🔄 CI/CD Pipeline Validation"
echo "----------------------------"

# Check for GitHub Actions
WORKFLOW_FILES=$(find .github/workflows -name "*.yml" -o -name "*.yaml" 2>/dev/null || true)
for workflow_file in $WORKFLOW_FILES; do
    echo "Checking workflow: $workflow_file"
    
    # Check for Azure authentication
    if grep -i "azure/login\|AZURE_CREDENTIALS" "$workflow_file" &> /dev/null; then
        print_status 0 "Azure authentication configured"
    else
        print_warning "Consider adding Azure authentication to $workflow_file"
    fi
    
    # Check for Bicep deployment
    if grep -i "bicep\|az deployment" "$workflow_file" &> /dev/null; then
        print_status 0 "Bicep deployment configured"
    else
        print_warning "Consider adding Bicep deployment to $workflow_file"
    fi
done

# Summary
echo ""
echo "📊 Validation Summary"
echo "===================="

echo "Total Bicep files checked: $TOTAL_FILES"
echo -e "Passed validations: ${GREEN}$PASSED_FILES${NC}"
echo -e "Failed validations: ${RED}$FAILED_FILES${NC}"

if [ $FAILED_FILES -eq 0 ]; then
    echo -e "${GREEN}🎉 All templates pass validation!${NC}"
    echo ""
    echo "Templates are ready for deployment with confidence."
else
    echo -e "${YELLOW}⚠️  Some issues were found. Please review the output above.${NC}"
    echo ""
    echo "Common fixes:"
    echo "1. Add @description annotations to all parameters"
    echo "2. Use uniqueString() for globally unique resource names"
    echo "3. Enable managed identity authentication"
    echo "4. Add proper resource tagging"
    echo "5. Follow Azure CAF naming conventions"
fi

# Return appropriate exit code
if [ $FAILED_FILES -gt 0 ]; then
    exit 1
else
    exit 0
fi
