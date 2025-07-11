# Three Horizons AI Developer Platform - Development Guide

Welcome to your personalized Three Horizons AI development environment! This guide will help you get started and make the most of your DevBox.

## 🌟 Quick Start

### Authentication Setup
```bash
# Authenticate with Azure (required for all Azure services)
azlogin

# Authenticate with GitHub (required for GitHub integrations)
gh auth login

# Configure Git (if not already done)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Azure Setup
```bash
# List available subscriptions
az account list --output table

# Set default subscription
az account set --subscription "Your Subscription Name"

# Get AKS credentials (replace with your cluster details)
az aks get-credentials --resource-group your-rg --name your-cluster

# Verify Kubernetes connection
kubectl get nodes
```

## 🏗️ Three Horizons Architecture

### H0 - DevBox (Foundation)
**Current Environment** - This is your development foundation
- **Purpose**: Consistent development environment across all horizons
- **Tools**: VS Code, Multi-language SDKs, Azure CLI, Kubernetes tools
- **Usage**: Starting point for all development work

### H1 - Foundation Templates
Navigate: `h1` or `cd /workspace/templates/h1-foundation`
- **microservices-starter**: Production-ready Node.js microservice template
- **Infrastructure**: Kubernetes manifests, Helm charts
- **CI/CD**: GitHub Actions with Azure integration

### H2 - Optimization Templates  
Navigate: `h2` or `cd /workspace/templates/h2-optimization`
- **gitops-advanced**: Multi-environment GitOps with ArgoCD
- **Scaling**: HPA, resource optimization
- **Monitoring**: Prometheus, Grafana integration

### H3 - Innovation Templates
Navigate: `h3` or `cd /workspace/templates/h3-innovation`
- **AI/ML**: Azure OpenAI integration
- **Experimentation**: A/B testing frameworks
- **Advanced**: Cutting-edge technology adoption

## 🔧 Development Workflows

### Creating a New Microservice (H1)
```bash
# Navigate to H1 templates
h1

# Create new service from template
# (This will be done through Developer Hub in production)
cp -r microservices-starter/skeleton my-new-service
cd my-new-service

# Install dependencies
npm install

# Run locally
npm run dev

# Build Docker image
docker build -t my-new-service .

# Deploy to Kubernetes
kubectl apply -f k8s/
```

### Setting up GitOps (H2)
```bash
# Navigate to H2 templates
h2

# Explore GitOps structure
ls -la gitops-advanced/skeleton/

# Apply ArgoCD configurations
kubectl apply -f gitops-advanced/skeleton/argocd/

# Configure environment overlays
cd gitops-advanced/skeleton/environments/dev
kustomize build .
```

### Working with AI Features (H3)
```bash
# Navigate to H3 templates
h3

# Start Jupyter for AI experimentation
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root

# Access at: http://localhost:8888
```

## 🛠️ Available Tools & Commands

### Container Orchestration
- `k` - kubectl shorthand
- `kgp` - Get pods
- `kgs` - Get services  
- `kgd` - Get deployments

### Azure Tools
- `az` - Azure CLI
- `azlogin` - Quick Azure login
- `azctx` - Show current Azure context

### Development
- `node`, `npm`, `yarn` - Node.js development
- `python3`, `pip3` - Python development
- `dotnet` - .NET development
- `java`, `mvn` - Java development
- `go` - Go development

### Container & Docker
- `d` - Docker shorthand
- `dc` - Docker Compose
- `dps` - Docker ps
- `di` - Docker images

### Git & GitHub
- `git` - Git version control
- `gh` - GitHub CLI
- `gs` - Git status
- `ga` - Git add
- `gc` - Git commit
- `gp` - Git push

### Utilities
- `jq` - JSON processor
- `yq` - YAML processor
- `curl`, `wget` - HTTP tools
- `tree` - Directory structure
- `htop` - Process monitor

## 📁 Workspace Structure

```
/workspace/
├── templates/           # Three Horizons templates
│   ├── h0-devbox/      # This DevBox template
│   ├── h1-foundation/  # Core microservices
│   ├── h2-optimization/# GitOps and scaling
│   └── h3-innovation/  # AI and experimentation
├── playground/         # Your sandbox area
├── projects/          # Your active projects
├── scripts/           # Utility scripts
└── docs/             # Documentation
```

## 🔐 Security Best Practices

### Environment Variables
```bash
# View current environment
env | grep THREE_HORIZONS
env | grep AZURE

# Set additional variables as needed
export MY_CUSTOM_VAR="value"
```

### Secrets Management
- Use Azure Key Vault for production secrets
- Keep sensitive data out of Git repositories
- Use `.env` files for local development (already in .gitignore)

### Container Security
- All containers run as non-root user (`vscode`)
- Docker socket mounted securely
- Privileged access only when necessary

## 🚀 Deployment Workflows

### Local Development
1. Make changes in your preferred language
2. Test locally using built-in tools
3. Commit to feature branch
4. Create pull request

### CI/CD Pipeline
1. Push triggers GitHub Actions
2. Automated testing and building
3. Container image pushed to Azure Container Registry
4. Deployment to AKS via GitOps

### Environment Promotion
- **Development**: Automatic deployment from main branch
- **Staging**: Manual promotion with approvals
- **Production**: Controlled release with rollback capability

## 🔍 Troubleshooting

### Common Issues

**Container won't start**
```bash
# Check container logs
docker logs <container-id>

# Restart container
docker restart <container-id>
```

**Azure authentication fails**
```bash
# Clear Azure cache
az account clear

# Re-authenticate
az login --use-device-code
```

**Kubernetes connection issues**
```bash
# Check current context
kubectl config current-context

# List available contexts
kubectl config get-contexts

# Switch context
kubectl config use-context <context-name>
```

**Git authentication problems**
```bash
# Check GitHub CLI status
gh auth status

# Re-authenticate
gh auth login
```

### Performance Optimization

**Container Performance**
- Minimum 4 CPU cores, 8GB RAM recommended
- Use SSD storage for better I/O performance
- Close unused extensions to save memory

**Network Issues**
- Check port forwarding configuration
- Verify firewall settings
- Use `curl` to test connectivity

## 📚 Additional Resources

### Documentation
- [Three Horizons Architecture Guide](/workspace/docs/guides/README.md)
- [Azure DevOps Best Practices](https://docs.microsoft.com/en-us/azure/devops/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

### Learning Paths
- Azure Fundamentals
- Kubernetes Administration
- DevOps Engineering
- AI/ML Development

### Support Channels
- Internal Developer Hub documentation
- Team Slack channels
- Azure Support (for infrastructure issues)

## 🎯 Next Steps

1. **Explore Templates**: Navigate through H1, H2, H3 to understand available patterns
2. **Create Your First Service**: Start with H1 microservices-starter
3. **Set Up GitOps**: Configure H2 for your team's deployment workflow
4. **Experiment with AI**: Use H3 for machine learning and AI features
5. **Customize**: Adapt templates to your team's specific needs

---

**Happy Coding!** 🚀

For more help, reach out to your platform team or check the documentation at `/workspace/docs/`.
