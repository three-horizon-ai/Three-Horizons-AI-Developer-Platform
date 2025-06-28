# 📋 Templates Directory - Three Horizons AI Platform

<div align="center">

**Infrastructure and Configuration Templates Organized by Implementation Horizon**

</div>

## 📁 Directory Structure

```text
templates/
├── README.md                        # This file
├── shared/                          # Shared Templates & Common Resources
│   ├── document-template.md             # Standard documentation template
│   ├── bicep-common/                    # Shared Bicep modules
│   │   ├── network-module.bicep         # Common networking resources
│   │   ├── security-module.bicep        # Security baseline
│   │   └── monitoring-module.bicep      # Basic monitoring setup
│   ├── kubernetes/                      # Common K8s manifests
│   │   ├── namespace-template.yaml      # Standard namespace template
│   │   ├── rbac-template.yaml           # RBAC configuration
│   │   └── networkpolicy-template.yaml  # Network policy template
│   └── github/                          # GitHub template configurations
│       ├── workflow-template.yml        # Basic CI/CD workflow
│       ├── dependabot-template.yml      # Dependency management
│       └── security-template.yml        # Security scanning workflow
├── h1-foundation/                   # Horizon 1 Foundation Templates
│   ├── infrastructure/                  # Infrastructure as Code
│   │   ├── main.bicep                   # Main infrastructure template
│   │   ├── parameters.json              # Default parameters
│   │   ├── aks-cluster.bicep            # AKS cluster configuration
│   │   ├── key-vault.bicep              # Azure Key Vault setup
│   │   └── storage-account.bicep        # Storage account template
│   ├── devhub/                          # Developer Hub configurations
│   │   ├── app-config.yaml              # Basic Developer Hub config
│   │   ├── catalog-info.yaml            # Service catalog template
│   │   └── techdocs.yaml                # Documentation configuration
│   ├── security/                        # Security templates
│   │   ├── entra-id-config.json         # Entra ID configuration
│   │   ├── rbac-assignments.json        # Role assignments
│   │   └── network-security.bicep       # Network security rules
│   └── demo/                            # Demo application templates
│       ├── sample-app/                  # Sample application
│       ├── demo-pipeline.yml            # Demo CI/CD pipeline
│       └── monitoring-dashboard.json    # Basic monitoring dashboard
├── h2-optimization/                 # Horizon 2 Optimization Templates
│   ├── gitops/                          # GitOps configurations
│   │   ├── flux-system/                 # Flux configuration
│   │   ├── argocd/                      # ArgoCD setup
│   │   └── policies/                    # OPA/Gatekeeper policies
│   ├── monitoring/                      # Advanced monitoring
│   │   ├── prometheus/                  # Prometheus configuration
│   │   ├── grafana/                     # Grafana dashboards
│   │   └── alertmanager/                # Alert configurations
│   ├── security/                        # Enhanced security
│   │   ├── defender-config.json         # Microsoft Defender setup
│   │   ├── sentinel-rules/              # Sentinel detection rules
│   │   └── compliance-policies/         # Compliance policy templates
│   ├── performance/                     # Performance optimization
│   │   ├── hpa-templates/               # Horizontal Pod Autoscaler
│   │   ├── vpa-templates/               # Vertical Pod Autoscaler
│   │   └── resource-quotas/             # Resource quota templates
│   └── golden-paths/                    # Golden Path templates
│       ├── microservice-template/       # Microservice scaffold
│       ├── api-template/                # API service template
│       └── frontend-template/           # Frontend application template
└── h3-innovation/                   # Horizon 3 Innovation Templates
    ├── ai-services/                     # AI service templates
    │   ├── copilot-enterprise/          # GitHub Copilot Enterprise setup
    │   ├── azure-ai-foundry/            # Azure AI Foundry configuration
    │   └── custom-models/               # Custom AI model templates
    ├── autonomous-ops/                  # Autonomous operations
    │   ├── self-healing/                # Self-healing configurations
    │   ├── auto-scaling/                # Intelligent auto-scaling
    │   └── predictive-maintenance/      # Predictive maintenance
    ├── mcp/                             # Multi-Cloud Protocol
    │   ├── server-configs/              # MCP server configurations
    │   ├── client-templates/            # MCP client templates
    │   └── integration-samples/         # Integration examples
    └── analytics/                       # Advanced analytics
        ├── data-pipelines/              # Data pipeline templates
        ├── ml-workflows/                # ML workflow templates
        └── reporting-dashboards/        # Advanced reporting dashboards
```

## 🎯 Template Categories

### 🏗️ Infrastructure Templates

**Purpose**: Standardized Infrastructure as Code (IaC) templates for consistent deployments.

- **Bicep Templates**: Azure resource definitions with best practices
- **Kubernetes Manifests**: Production-ready Kubernetes configurations
- **Terraform Modules**: Multi-cloud infrastructure provisioning

### 🔄 CI/CD Templates

**Purpose**: Standardized pipeline templates for automated deployments.

- **GitHub Actions**: Workflow templates for various scenarios
- **Azure DevOps**: Pipeline templates and task groups
- **GitOps**: Flux and ArgoCD configuration templates

### 🛡️ Security Templates

**Purpose**: Security-first configurations with compliance built-in.

- **Zero Trust Network**: Network security templates
- **Identity Management**: Entra ID and RBAC configurations
- **Compliance**: Policy templates for various standards

### 🤖 AI & Automation Templates

**Purpose**: AI-powered development and autonomous operations.

- **GitHub Copilot**: Enterprise configuration templates
- **Azure AI Foundry**: Model deployment and management
- **Autonomous Operations**: Self-healing and intelligent scaling

## 📋 Usage Guidelines

### 🏗️ Using Horizon 1 Foundation Templates

```bash
# Deploy core infrastructure
az deployment sub create \
  --location "East US 2" \
  --template-file templates/h1-foundation/infrastructure/main.bicep \
  --parameters @templates/h1-foundation/infrastructure/parameters.json

# Configure Developer Hub
kubectl apply -f templates/h1-foundation/devhub/
```

### ⚡ Using Horizon 2 Optimization Templates

```bash
# Setup GitOps with Flux
kubectl apply -k templates/h2-optimization/gitops/flux-system/

# Deploy monitoring stack
helm install monitoring templates/h2-optimization/monitoring/prometheus/ \
  --namespace monitoring --create-namespace
```

### 🤖 Using Horizon 3 Innovation Templates

```bash
# Configure AI services
kubectl apply -f templates/h3-innovation/ai-services/azure-ai-foundry/

# Setup autonomous operations
kubectl apply -k templates/h3-innovation/autonomous-ops/
```

## 🔧 Template Customization

### 📝 Parameter Files

Each template includes customizable parameter files:

```json
{
  "parameters": {
    "environmentName": {
      "value": "dev"
    },
    "location": {
      "value": "East US 2"
    },
    "organizationName": {
      "value": "your-org"
    }
  }
}
```

### 🔄 Variable Substitution

Templates support environment variable substitution:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  environment: "${ENVIRONMENT_NAME}"
  organization: "${ORG_NAME}"
```

### 📋 Validation Scripts

Each template includes validation scripts:

```bash
# Validate template syntax
./templates/h1-foundation/validate-template.sh

# Test deployment (dry-run)
./templates/h1-foundation/test-deployment.sh --dry-run
```

## 🛡️ Security & Compliance

### 🔐 Secret Management

- No hardcoded secrets in templates
- Azure Key Vault integration for secret retrieval
- Service principal authentication patterns

### 📋 Compliance Standards

Templates include configurations for:

- **SOC 2 Type II**: Security controls and monitoring
- **ISO 27001**: Information security management
- **PCI DSS**: Payment card industry compliance
- **HIPAA**: Healthcare data protection

### 🔍 Security Scanning

All templates are scanned for:

- Security misconfigurations
- Compliance violations
- Best practice adherence
- Vulnerability assessments

## 📊 Template Versioning

### 🏷️ Version Strategy

Templates follow semantic versioning:

- **Major**: Breaking changes requiring migration
- **Minor**: New features, backward compatible
- **Patch**: Bug fixes and security updates

### 📋 Change Management

```bash
# View template versions
git tag -l "template-v*"

# Use specific template version
git checkout template-v2.1.0 -- templates/h1-foundation/
```

## 🔄 Template Development

### 🛠️ Creating New Templates

1. **Follow Naming Convention**: Use descriptive, consistent names
2. **Include Documentation**: README with usage instructions
3. **Add Validation**: Include syntax and deployment validation
4. **Security Review**: Ensure security best practices
5. **Test Thoroughly**: Validate in multiple environments

### 📋 Template Standards

```bash
template-name/
├── README.md                    # Usage documentation
├── template.yaml               # Main template file
├── parameters.yaml             # Parameter definitions
├── validate.sh                 # Validation script
├── test.sh                     # Testing script
└── examples/                   # Usage examples
    ├── basic-example/
    └── advanced-example/
```

## 🚨 Prerequisites

### 🔧 Required Tools

```bash
# Azure CLI
az version

# Kubernetes CLI
kubectl version --client

# Helm
helm version

# Bicep CLI
az bicep version
```

### 📋 Required Permissions

- **Azure**: Subscription Contributor or Owner
- **Kubernetes**: Cluster Admin
- **GitHub**: Organization Admin (for Enterprise features)
- **Red Hat**: Subscription Admin (for Developer Hub)

## 🆘 Support & Troubleshooting

### 📞 Getting Help

1. **Template Issues**: Check template-specific README files
2. **Validation Errors**: Run validation scripts with verbose output
3. **Deployment Failures**: Review Azure Activity Log and Kubernetes events
4. **Community Support**: Access community forums and documentation

### 🔧 Common Issues

- **Parameter Validation**: Ensure all required parameters are provided
- **Permission Errors**: Verify appropriate role assignments
- **Resource Conflicts**: Check for existing resources with same names
- **Quota Limits**: Ensure adequate Azure subscription quotas

---

<div align="center">

**📋 Ready to Standardize Your Deployments? 📋**

[🏗️ Start with H1 Templates](h1-foundation/) | [⚡ Explore H2 Templates](h2-optimization/) | [🤖 Discover H3 Templates](h3-innovation/)

</div>
