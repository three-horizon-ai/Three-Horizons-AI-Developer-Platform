#!/bin/bash
#
# Three Horizons AI Developer Platform - DevBox Post-Start
# This script runs every time the devcontainer starts
#

set -e

echo "🌟 Three Horizons AI Platform - Starting development session..."

# Display welcome message
if [ -f /workspace/welcome.sh ]; then
    /workspace/welcome.sh
fi

# Check Azure CLI authentication status
if command -v az &> /dev/null; then
    echo "🔐 Checking Azure authentication..."
    if ! az account show &> /dev/null; then
        echo "⚠️  Azure CLI not authenticated. Run 'azlogin' to authenticate."
    else
        echo "✅ Azure CLI authenticated"
        CURRENT_ACCOUNT=$(az account show --query name -o tsv)
        echo "   Current subscription: $CURRENT_ACCOUNT"
    fi
fi

# Check Kubernetes context
if command -v kubectl &> /dev/null; then
    echo "⚓ Checking Kubernetes context..."
    if kubectl config current-context &> /dev/null; then
        CURRENT_CONTEXT=$(kubectl config current-context)
        echo "✅ Kubernetes context: $CURRENT_CONTEXT"
    else
        echo "⚠️  No Kubernetes context set. Configure with 'kubectl config set-context'"
    fi
fi

# Check Git configuration
echo "📝 Checking Git configuration..."
if [ -z "$(git config --global user.name)" ]; then
    echo "⚠️  Git user.name not configured"
else
    echo "✅ Git user: $(git config --global user.name)"
fi

# Check GitHub CLI authentication
if command -v gh &> /dev/null; then
    echo "🐙 Checking GitHub CLI authentication..."
    if gh auth status &> /dev/null; then
        echo "✅ GitHub CLI authenticated"
    else
        echo "⚠️  GitHub CLI not authenticated. Run 'gh auth login' to authenticate."
    fi
fi

# Update PATH to include local bin directories
export PATH="$HOME/.local/bin:$PATH"

echo ""
echo "🚀 Ready for Three Horizons development!"
echo "   Type 'three-horizons-help' for detailed guidance"
echo ""
