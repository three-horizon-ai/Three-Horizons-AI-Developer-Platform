# H0 DevBox - Developer Environment Template

## Overview

The H0 DevBox template provides a comprehensive, pre-configured development environment that serves as the foundation for all Three Horizons AI Platform development work. This template creates a consistent, reproducible development experience across all team members and ensures everyone has access to the same tools, configurations, and best practices.

## Template Contents

### Core Configuration
- **`template.yaml`** - Backstage template definition with comprehensive input parameters
- **`catalog-info.yaml`** - Service catalog registration for Developer Hub
- **`README.md`** - Detailed setup and usage instructions

### DevContainer Configuration
- **`.devcontainer/devcontainer.json`** - Complete VS Code DevContainer setup
- **`.devcontainer/initialize.sh`** - Pre-container setup script
- **`.devcontainer/post-create.sh`** - Post-creation environment setup
- **`.devcontainer/post-start.sh`** - Startup verification and status checks
- **`.devcontainer/DEVELOPMENT-GUIDE.md`** - Comprehensive development guide

### Development Tools
- **`package.json`** - Node.js project configuration with helpful scripts
- **`.env.template`** - Environment variable template
- **`.gitignore`** - Comprehensive ignore rules for all supported languages
- **`.prettierrc`** - Code formatting configuration
- **`.eslintrc.json`** - Linting rules and standards

### Utility Scripts
- **`scripts/setup-environment.js`** - Interactive environment setup
- **`scripts/verify-environment.sh`** - Environment verification and health checks

### VS Code Integration
- **`three-horizons-devbox.code-workspace`** - Multi-root workspace configuration
- Pre-configured tasks for common operations
- Debug configurations for multiple languages
- Recommended extensions for optimal development experience

## Key Features

### 🌐 Multi-Language Support
- **Node.js/TypeScript** - Full ecosystem with npm, yarn, popular frameworks
- **Python** - Python 3.11+ with pip, virtual environments, data science libraries
- **.NET** - .NET 8.0 with entity framework and code generation tools
- **Java** - OpenJDK 17 with Maven and Gradle
- **Go** - Latest Go compiler and tools

### ☁️ Azure Integration
- **Azure CLI** - Latest version with Bicep support
- **Authentication** - Seamless Azure AD integration
- **Resource Management** - Pre-configured for subscription access
- **Key Vault** - Secure secrets management integration

### ⚓ Kubernetes & Container Tools
- **kubectl** - Kubernetes command-line tool
- **Helm** - Package manager for Kubernetes
- **Docker** - Container runtime with Docker-in-Docker support
- **Container Registry** - Azure Container Registry integration

### 🤖 AI/ML Development
- **Azure AI CLI** - Command-line tools for Azure AI services
- **Jupyter** - Interactive notebook environment
- **Python Data Science** - pandas, numpy, scikit-learn, matplotlib
- **Azure OpenAI** - Integration with Azure OpenAI services

### 🔧 Development Experience
- **VS Code** - Fully configured with extensions and settings
- **GitHub Integration** - GitHub CLI and Copilot support
- **Git Configuration** - Pre-configured with best practices
- **Terminal** - Choice of bash/zsh with oh-my-zsh

### 🔐 Security & Best Practices
- **Non-root User** - Secure container execution
- **Secrets Management** - Proper environment variable handling
- **Code Quality** - ESLint, Prettier, and formatting rules
- **Security Scanning** - Built-in security best practices

## Usage Workflow

### 1. Template Scaffolding
```bash
# Via Developer Hub
# Select H0 DevBox template
# Fill in configuration parameters
# Generate new repository
```

### 2. Local Development
```bash
# Clone the generated repository
git clone <generated-repo-url>
cd <repo-name>

# Open in VS Code with DevContainers
code .
# VS Code will prompt to reopen in container
```

### 3. Initial Setup
```bash
# Run setup script
npm run setup

# Verify environment
./scripts/verify-environment.sh

# Authenticate with services
npm run azure:login
gh auth login
```

### 4. Development
```bash
# Navigate to horizon templates
h1  # Go to H1 Foundation
h2  # Go to H2 Optimization  
h3  # Go to H3 Innovation

# Use workspace commands
three-horizons-help  # View development guide
npm run azure:status  # Check Azure auth
npm run k8s:status   # Check Kubernetes
```

## Template Parameters

### Required Inputs
- **`project_name`** - Name for the DevBox project
- **`developer_name`** - Developer's full name
- **`team`** - Team or organization name
- **`azure_subscription_id`** - Azure subscription for resources

### Optional Configurations
- **`languages`** - Programming languages to include
- **`cloud_tools`** - Additional cloud tool selection
- **`ai_tools`** - AI/ML development tools
- **`databases`** - Database client tools
- **`vscode_extensions`** - Additional VS Code extensions
- **`preferred_shell`** - Terminal shell preference
- **`workspace_settings`** - VS Code workspace customizations

## Integration Points

### Developer Hub Integration
- Registered in service catalog
- Available through template scaffolding
- Linked to documentation and guides

### H1 Foundation Integration
- Pre-configured for microservices development
- Ready for Node.js/TypeScript projects
- Kubernetes deployment preparation

### H2 Optimization Integration
- GitOps workflow preparation
- ArgoCD and Kustomize support
- Multi-environment configuration

### H3 Innovation Integration
- AI/ML development environment
- Jupyter notebook support
- Azure AI services integration

## Customization Options

### Team-Specific Extensions
```json
"vscode_extensions": [
  "your-org.custom-extension",
  "team-specific.tools"
]
```

### Additional Language Support
```yaml
# Add to devcontainer.json features
"ghcr.io/devcontainers/features/ruby:1": {
  "version": "latest"
}
```

### Custom Scripts
```bash
# Add to scripts/ directory
scripts/team-setup.sh
scripts/custom-verification.sh
```

### Environment Variables
```bash
# Add to .env.template
TEAM_SPECIFIC_VAR=value
CUSTOM_API_ENDPOINT=https://api.team.com
```

## Best Practices

### 🏗️ Infrastructure as Code
- All configurations are version controlled
- Reproducible across environments
- Automated setup and verification

### 🔧 Tool Standardization
- Consistent tool versions across team
- Centralized configuration management
- Automated dependency installation

### 📚 Documentation
- Comprehensive development guides
- Interactive help commands
- Context-aware assistance

### 🚀 Developer Experience
- Fast startup and setup
- Integrated debugging and testing
- Seamless service integration

## Troubleshooting

### Common Issues
- **Container startup failures** - Check Docker resources and permissions
- **Authentication problems** - Verify environment variables and tokens
- **Network connectivity** - Check firewall and proxy settings
- **Tool installation** - Review DevContainer feature configuration

### Support Resources
- Run `three-horizons-help` for comprehensive guidance
- Check `./scripts/verify-environment.sh` for health status
- Review VS Code DevContainer logs
- Consult team documentation and Slack channels

## Roadmap

### Upcoming Features
- **IDE Support** - JetBrains IDEs integration
- **Performance Optimization** - Faster container startup
- **Team Templates** - Organization-specific customizations
- **Monitoring** - Development environment analytics

### Feedback and Contributions
- Submit feature requests through Developer Hub
- Contribute improvements via pull requests
- Share customizations with the platform team

---

The H0 DevBox template is the foundation of the Three Horizons AI Platform development experience, providing a consistent, powerful, and secure environment for all your development needs. 🚀
