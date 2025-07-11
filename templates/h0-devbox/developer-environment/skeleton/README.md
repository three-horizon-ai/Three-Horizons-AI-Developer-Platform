# Three Horizons AI Platform - Developer Environment

Welcome to your personalized Three Horizons AI Platform development environment! This devbox is pre-configured with all the tools, SDKs, and dependencies needed to develop across all three horizons.

## 👋 Welcome, ${{ values.developer_name }}!

This environment has been customized for **${{ values.team }}** team and includes:

### 🛠️ Pre-installed Tools & SDKs

#### Programming Languages
{% for lang in values.languages %}
- **{{ lang }}**: Latest stable version with package managers and development tools
{% endfor %}

#### Cloud & Infrastructure Tools
{% for tool in values.cloud_tools %}
- **{{ tool }}**: Latest version with authentication configured
{% endfor %}

#### AI/ML Development Tools
{% for tool in values.ai_tools %}
- **{{ tool }}**: Ready for AI/ML development and experimentation
{% endfor %}

#### VS Code Extensions
{% for ext in values.vscode_extensions %}
- **{{ ext }}**: Pre-installed and configured
{% endfor %}

## 🚀 Quick Start Guide

### 1. Environment Setup

#### Option A: GitHub Codespaces (Recommended)
```bash
# Click the "Open in GitHub Codespaces" link above
# Everything is automatically configured!
```

#### Option B: VS Code Devcontainer
```bash
# Click the "Open in VS Code Devcontainer" link above
# Or clone and open in VS Code:
git clone https://github.com/three-horizon-ai/${{ values.repo_name }}.git
cd ${{ values.repo_name }}
code .
# VS Code will prompt to reopen in container
```

#### Option C: Local Development
```bash
git clone https://github.com/three-horizon-ai/${{ values.repo_name }}.git
cd ${{ values.repo_name }}
./scripts/setup.sh
```

### 2. Azure Authentication Setup
{% if values.setup_azure_auth %}
```bash
# Azure CLI authentication
az login

# Set default subscription
{% if values.azure_subscription_id %}
az account set --subscription ${{ values.azure_subscription_id }}
{% else %}
az account set --subscription "your-subscription-id"
{% endif %}

# Verify authentication
az account show
```
{% endif %}

### 3. Kubernetes Access Setup
{% if values.setup_aks_access %}
```bash
# Get AKS credentials
az aks get-credentials --resource-group your-rg --name your-aks-cluster

# Verify kubectl access
kubectl get nodes

# Install useful aliases
source ~/.bashrc  # or ~/.zshrc for zsh users
```
{% endif %}

### 4. Verify Installation
```bash
# Run the verification script
./scripts/verify-setup.sh

# This will check all installed tools and configurations
```

## 📁 Project Structure

```
${{ values.repo_name }}/
├── .devcontainer/          # VS Code devcontainer configuration
├── .vscode/               # VS Code workspace settings
├── scripts/               # Setup and utility scripts
├── samples/               # Sample code for each horizon
│   ├── h1-foundation/     # H1 sample projects
│   ├── h2-optimization/   # H2 sample projects
│   └── h3-innovation/     # H3 sample projects
├── docs/                  # Development documentation
├── tools/                 # Additional development tools
└── README.md             # This file
```

## 🏗️ Working with Three Horizons

### H1 - Foundation Development
```bash
cd samples/h1-foundation/
./run-samples.sh
```

### H2 - Optimization Development
```bash
cd samples/h2-optimization/
./run-samples.sh
```

### H3 - Innovation Development
```bash
cd samples/h3-innovation/
./run-samples.sh
```

## 🔧 Environment Customization

### Adding New Tools
```bash
# Edit the devcontainer configuration
vi .devcontainer/devcontainer.json

# Rebuild the container
Ctrl+Shift+P -> "Dev Containers: Rebuild Container"
```

### Updating VS Code Settings
```bash
# Edit workspace settings
vi .vscode/settings.json

# Settings are automatically applied
```

### Shell Configuration (${{ values.preferred_shell }})
```bash
# Your preferred shell (${{ values.preferred_shell }}) is configured with:
# - Custom aliases for Three Horizons development
# - Auto-completion for Azure CLI, kubectl, etc.
# - Customized prompt with environment indicators
```

## 🎯 Development Workflows

### 1. Starting a New H1 Project
```bash
# Use the Three Horizons templates
cd samples/h1-foundation/
./create-new-project.sh microservices-starter my-new-service
```

### 2. Working with GitOps (H2)
```bash
# Setup GitOps environment
cd samples/h2-optimization/gitops-advanced/
./setup-argocd.sh
```

### 3. AI Development (H3)
```bash
# Start AI development environment
cd samples/h3-innovation/ai-powered-app/
./setup-ai-env.sh
```

## 🔐 Security & Authentication

### Azure Authentication
- Azure CLI configured with device code flow
- Service Principal authentication for CI/CD
- Managed Identity support for Azure services

### GitHub Authentication
- GitHub CLI configured
- SSH keys setup for repository access
- GitHub Copilot authentication

### Kubernetes Authentication
- kubectl configured for AKS clusters
- RBAC permissions setup
- Namespace isolation configured

## 📊 Monitoring & Observability

### Development Metrics
- VS Code telemetry (anonymized)
- Development environment health checks
- Tool usage analytics

### Health Checks
```bash
# Check environment health
./scripts/health-check.sh

# View logs
./scripts/view-logs.sh
```

## 🆘 Troubleshooting

### Common Issues

#### Authentication Problems
```bash
# Reset Azure authentication
az logout
az login

# Reset GitHub authentication
gh auth logout
gh auth login
```

#### Container Issues
```bash
# Rebuild devcontainer
Ctrl+Shift+P -> "Dev Containers: Rebuild Container"

# Reset to clean state
./scripts/reset-environment.sh
```

#### Tool Conflicts
```bash
# Check tool versions
./scripts/check-versions.sh

# Update all tools
./scripts/update-tools.sh
```

### Getting Help
- 📚 [Documentation](./docs/README.md)
- 🐛 [Report Issues](https://github.com/three-horizon-ai/${{ values.repo_name }}/issues)
- 💬 [Team Chat](https://teams.microsoft.com/l/team/...)
- 📧 Email: ${{ values.team }}@company.com

## 🔄 Keeping Updated

### Auto-Updates
The environment checks for updates daily and will prompt you to update when new versions are available.

### Manual Updates
```bash
# Update all tools and dependencies
./scripts/update-environment.sh

# Update VS Code extensions
./scripts/update-vscode-extensions.sh

# Update devcontainer
./scripts/update-devcontainer.sh
```

## 🤝 Contributing

### Improving the DevBox
1. Fork this repository
2. Make your improvements
3. Test in a clean environment
4. Submit a pull request

### Sharing Configurations
Share useful configurations with your team by creating pull requests to the shared configuration repository.

## 📝 License

This development environment is licensed under the MIT License. See [LICENSE](./LICENSE) for details.

---

**Happy Coding with Three Horizons AI Platform! 🚀**

*Generated for ${{ values.developer_name }} on ${{ values.team }} team*

For more information about the Three Horizons AI Platform, visit our [main documentation](https://github.com/three-horizon-ai/Three-Horizons-AI-Developer-Platform).
