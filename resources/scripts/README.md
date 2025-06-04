# Three Horizons Platform - Automation Scripts

This directory contains automation scripts to help deploy and manage the Three Horizons Platform infrastructure and applications.

## 📋 Available Scripts

### 🚀 deploy-developer-hub.sh
Complete end-to-end deployment script for Red Hat Developer Hub on AKS or ARO.

**Features:**
- Validates prerequisites and Azure environment
- Deploys complete infrastructure using Bicep templates
- Installs and configures Developer Hub
- Sets up ingress, SSL certificates, and DNS
- Configures all necessary integrations

**Usage:**
```bash
# Deploy to development on AKS
./deploy-developer-hub.sh -e dev -p aks -l centralus

# Deploy to production on ARO
./deploy-developer-hub.sh -e prod -p aro -l eastus

# Deploy only Developer Hub (infrastructure already exists)
./deploy-developer-hub.sh --skip-infra

# Dry run to see what would be deployed
./deploy-developer-hub.sh --dry-run
```

**Options:**
- `-e, --environment`: Environment (dev/test/prod)
- `-p, --platform`: Platform (aks/aro)
- `-l, --location`: Azure region
- `-n, --name`: Base name for resources
- `--skip-infra`: Skip infrastructure deployment
- `--skip-validation`: Skip prerequisite validation
- `--dry-run`: Show what would be deployed

### ✅ validate-deployment.sh
Validates Azure environment readiness before deployment.

**Checks:**
- Required tools installation and versions
- Azure authentication and permissions
- Location availability and services
- Resource provider registration
- Quota availability
- Network configuration
- Cost estimation

**Usage:**
```bash
# Validate default location (centralus)
./validate-deployment.sh

# Validate specific location
./validate-deployment.sh eastus
```

**Output:**
- Detailed validation report
- Warnings for non-critical issues
- Errors that must be fixed
- Cost estimates
- Next steps

### 🔧 configure-integrations.sh
Post-deployment configuration for Developer Hub integrations.

**Configures:**
- GitHub OAuth authentication
- GitHub integration token
- Software catalog import
- Azure integration
- Template configuration
- TechDocs storage

**Usage:**
```bash
# Run after Developer Hub deployment
./configure-integrations.sh
```

**Interactive prompts for:**
- GitHub OAuth credentials
- GitHub Personal Access Token
- Azure Service Principal creation
- Storage account configuration

### 🔄 update_templates_to_resources.py
Updates all references from old "templates" directory to new "resources" directory.

**Usage:**
```bash
python update_templates_to_resources.py
```

### 🔀 arm-to-bicep.sh
Converts ARM templates to Bicep format.

**Features:**
- Validates Bicep installation
- Converts JSON ARM templates to Bicep
- Shows conversion warnings
- Optional validation after conversion

**Usage:**
```bash
# Convert single ARM template
./arm-to-bicep.sh template.json

# Result: creates template.bicep
```

## 🏗️ Infrastructure Deployment Flow

### 1. Preparation
```bash
# Check prerequisites
./validate-deployment.sh centralus

# Review validation results and fix any errors
```

### 2. Full Platform Deployment
```bash
# Deploy complete platform with Developer Hub
./deploy-developer-hub.sh -e dev -p aks -l centralus

# Save the PostgreSQL password shown!
```

### 3. Post-Deployment Configuration
```bash
# Configure integrations
./configure-integrations.sh

# Follow prompts to set up:
# - GitHub OAuth App
# - GitHub Personal Access Token
# - Azure integration
```

## 🔑 Required Credentials

### GitHub Requirements
1. **GitHub Personal Access Token**
   - Scopes: `repo`, `workflow`, `read:org`, `read:user`
   - Used for: Repository access, catalog import

2. **GitHub OAuth App**
   - Create at: GitHub Settings > Developer settings > OAuth Apps
   - Callback URL: `https://<devhub-url>/api/auth/github/handler/frame`

### Azure Requirements
1. **Azure Subscription**
   - Role: Contributor or Owner
   - Resource providers must be registered

2. **Service Principal (created by script)**
   - For Developer Hub Azure integration
   - Contributor role on subscription

## 📊 Deployment Outputs

After successful deployment, you'll receive:

1. **deployment-info.json**
   - Resource group names
   - Cluster details
   - Service URLs
   - Resource identifiers

2. **devhub-config-summary.txt**
   - Developer Hub URL
   - Configuration status
   - Troubleshooting commands
   - Next steps

## 🛠️ Troubleshooting

### Common Issues

1. **Authentication Errors**
   ```bash
   az login
   az account set --subscription <subscription-id>
   ```

2. **Quota Exceeded**
   ```bash
   # Check quotas
   az vm list-usage --location centralus -o table
   ```

3. **Developer Hub Not Accessible**
   ```bash
   # Check pod status
   kubectl get pods -n rhdh
   
   # Check logs
   kubectl logs -n rhdh -l app=developer-hub
   ```

4. **SSL Certificate Issues**
   ```bash
   # Check cert-manager
   kubectl get certificates -n rhdh
   kubectl describe certificate developer-hub-tls -n rhdh
   ```

### Useful Commands

```bash
# Get cluster credentials
az aks get-credentials --resource-group <rg> --name <cluster>

# Check Developer Hub status
kubectl get all -n rhdh

# View Developer Hub logs
kubectl logs -n rhdh deployment/developer-hub -f

# Restart Developer Hub
kubectl rollout restart deployment/developer-hub -n rhdh

# Check ingress IP
kubectl get svc -n ingress-nginx
```

## 📚 Additional Resources

- [Red Hat Developer Hub Documentation](https://developers.redhat.com/products/red-hat-developer-hub)
- [Backstage.io Documentation](https://backstage.io/docs)
- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Azure Red Hat OpenShift Documentation](https://docs.microsoft.com/en-us/azure/openshift/)

## 🤝 Contributing

When adding new scripts:
1. Follow the existing naming convention
2. Add comprehensive help/usage information
3. Include error handling and validation
4. Update this README with documentation
5. Test on both AKS and ARO platforms 