#!/bin/bash
#
# Three Horizons AI Platform - Verification Script
# Verifies that all tools and configurations are working correctly
#

set -e

echo "🔍 Three Horizons AI Platform - Environment Verification"
echo "======================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check environment variables
echo ""
echo "🔧 Environment Variables"
echo "------------------------"

required_vars=("AZURE_SUBSCRIPTION_ID" "DEVELOPER_NAME" "TEAM")
all_vars_set=true

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        print_status 1 "$var is not set"
        all_vars_set=false
    else
        print_status 0 "$var is set"
    fi
done

# Check optional but recommended variables
optional_vars=("GITHUB_TOKEN" "AZURE_TENANT_ID" "PREFERRED_SHELL")
for var in "${optional_vars[@]}"; do
    if [ -z "${!var}" ]; then
        print_warning "$var is not set (optional)"
    else
        print_status 0 "$var is set"
    fi
done

# Check tools availability
echo ""
echo "🛠️  Tool Availability"
echo "--------------------"

tools=(
    "az:Azure CLI"
    "kubectl:Kubernetes CLI"
    "docker:Docker"
    "gh:GitHub CLI"
    "node:Node.js"
    "npm:NPM"
    "python3:Python 3"
    "git:Git"
    "jq:JSON processor"
    "curl:HTTP client"
)

for tool_info in "${tools[@]}"; do
    tool=$(echo $tool_info | cut -d: -f1)
    name=$(echo $tool_info | cut -d: -f2)
    
    if command -v $tool &> /dev/null; then
        version=$($tool --version 2>/dev/null | head -n1 || echo "version unknown")
        print_status 0 "$name ($version)"
    else
        print_status 1 "$name not found"
    fi
done

# Check authentication status
echo ""
echo "🔐 Authentication Status"
echo "------------------------"

# Azure CLI
if az account show &> /dev/null; then
    account_name=$(az account show --query name -o tsv)
    subscription_id=$(az account show --query id -o tsv)
    print_status 0 "Azure CLI authenticated ($account_name)"
    print_info "Subscription: $subscription_id"
else
    print_status 1 "Azure CLI not authenticated"
    print_warning "Run 'az login' to authenticate"
fi

# GitHub CLI
if gh auth status &> /dev/null; then
    username=$(gh api user --jq .login 2>/dev/null || echo "unknown")
    print_status 0 "GitHub CLI authenticated ($username)"
else
    print_status 1 "GitHub CLI not authenticated"
    print_warning "Run 'gh auth login' to authenticate"
fi

# Git configuration
echo ""
echo "📝 Git Configuration"
echo "--------------------"

git_name=$(git config --global user.name 2>/dev/null || echo "")
git_email=$(git config --global user.email 2>/dev/null || echo "")

if [ -n "$git_name" ]; then
    print_status 0 "Git user.name: $git_name"
else
    print_status 1 "Git user.name not configured"
fi

if [ -n "$git_email" ]; then
    print_status 0 "Git user.email: $git_email"
else
    print_status 1 "Git user.email not configured"
fi

# Check Kubernetes connection
echo ""
echo "⚓ Kubernetes Connection"
echo "-----------------------"

if kubectl cluster-info &> /dev/null; then
    current_context=$(kubectl config current-context)
    print_status 0 "Kubernetes cluster connected"
    print_info "Current context: $current_context"
    
    # Check if we can list nodes
    if kubectl get nodes &> /dev/null; then
        node_count=$(kubectl get nodes --no-headers | wc -l)
        print_status 0 "Can access cluster nodes ($node_count nodes)"
    else
        print_warning "Cannot access cluster nodes (permission issue?)"
    fi
else
    print_status 1 "Kubernetes cluster not accessible"
    print_warning "Configure cluster access with 'az aks get-credentials'"
fi

# Check Docker
echo ""
echo "🐳 Docker Status"
echo "---------------"

if docker info &> /dev/null; then
    print_status 0 "Docker daemon is running"
    
    # Check if we can run a simple container
    if docker run --rm hello-world &> /dev/null; then
        print_status 0 "Can run Docker containers"
    else
        print_warning "Cannot run Docker containers (permission issue?)"
    fi
else
    print_status 1 "Docker daemon not accessible"
fi

# Check file permissions
echo ""
echo "📁 File Permissions"
echo "------------------"

# Check workspace permissions
if [ -w "/workspace" ]; then
    print_status 0 "Workspace directory is writable"
else
    print_status 1 "Workspace directory is not writable"
fi

# Check home directory
if [ -w "$HOME" ]; then
    print_status 0 "Home directory is writable"
else
    print_status 1 "Home directory is not writable"
fi

# Check network connectivity
echo ""
echo "🌐 Network Connectivity"
echo "----------------------"

# Check internet connectivity
if curl -s --max-time 5 https://www.google.com > /dev/null; then
    print_status 0 "Internet connectivity"
else
    print_status 1 "No internet connectivity"
fi

# Check Azure endpoints
if curl -s --max-time 5 https://management.azure.com > /dev/null; then
    print_status 0 "Azure management endpoint accessible"
else
    print_status 1 "Azure management endpoint not accessible"
fi

# Check GitHub
if curl -s --max-time 5 https://api.github.com > /dev/null; then
    print_status 0 "GitHub API accessible"
else
    print_status 1 "GitHub API not accessible"
fi

# Three Horizons specific checks
echo ""
echo "🌟 Three Horizons Platform"
echo "-------------------------"

# Check template directories
templates_dir="/workspace/templates"
horizons=("h0-devbox" "h1-foundation" "h2-optimization" "h3-innovation")

for horizon in "${horizons[@]}"; do
    if [ -d "$templates_dir/$horizon" ]; then
        print_status 0 "$horizon template directory exists"
    else
        print_status 1 "$horizon template directory missing"
    fi
done

# Check for development guide
if [ -f "/workspace/.devcontainer/DEVELOPMENT-GUIDE.md" ]; then
    print_status 0 "Development guide available"
else
    print_status 1 "Development guide missing"
fi

# Summary
echo ""
echo "📊 Verification Summary"
echo "======================"

# Count successful checks (this is a simplified approach)
if $all_vars_set && command -v az &> /dev/null && command -v kubectl &> /dev/null; then
    echo -e "${GREEN}🎉 Your Three Horizons DevBox is ready for development!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Run 'three-horizons-help' for detailed guidance"
    echo "2. Navigate to templates with 'h1', 'h2', or 'h3'"
    echo "3. Start building amazing applications!"
else
    echo -e "${YELLOW}⚠️  Some issues were found. Please review the output above.${NC}"
    echo ""
    echo "Common fixes:"
    echo "1. Set missing environment variables in .env file"
    echo "2. Authenticate with Azure: az login"
    echo "3. Authenticate with GitHub: gh auth login"
    echo "4. Configure Kubernetes access: az aks get-credentials"
fi

echo ""
echo "For help, run: three-horizons-help"
echo ""
