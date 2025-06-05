---
title: "Developer Guide"
description: "Comprehensive guide for developers using the Three Horizons Platform"
position_in_journey: "3. Development"
last_updated: "June 2025"
---

# <span style="color: #0366d6;">👨‍💻 Developer Guide</span>

Welcome to the Three Horizons Platform Developer Guide. This guide provides comprehensive information for developers using the platform to build, deploy, and maintain applications.

## <span style="color: #0366d6;">📋 Table of Contents</span>

- [Getting Started](#getting-started)
- [Platform Overview](#platform-overview)
- [Development Workflow](#development-workflow)
- [Using Red Hat Developer Hub](#using-red-hat-developer-hub)
- [GitHub Integration](#github-integration)
- [CI/CD Pipelines](#cicd-pipelines)
- [Application Templates](#application-templates)
- [Monitoring and Observability](#monitoring-and-observability)
- [Security Best Practices](#security-best-practices)
- [Troubleshooting](#troubleshooting)

## <span style="color: #0366d6;">🚀 Getting Started</span>

### Prerequisites

Before you begin development on the Three Horizons Platform, ensure you have:

1. **Developer Account Access**:
   - GitHub Enterprise account in your organization
   - Microsoft Entra ID credentials
   - Access to Red Hat Developer Hub
   - Kubernetes cluster access (if required)

2. **Development Tools**:
   - Git (latest version)
   - Docker Desktop or Podman
   - VS Code or your preferred IDE
   - GitHub CLI (`gh`)
   - Azure CLI (`az`)
   - Kubernetes CLI (`kubectl`)
   - Optional: GitHub Copilot license

3. **Platform Access**:
   - Developer Hub URL: `https://devhub.example.com`
   - GitHub Organization: `your-org-name`
   - Container Registry: `threehorizonsregistry.azurecr.io`

### First-Time Setup

```bash
# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your.email@company.com"

# Authenticate with GitHub
gh auth login

# Configure Azure CLI
az login

# Get Kubernetes credentials (if needed)
az aks get-credentials --resource-group three-horizons-platform --name three-horizons-aks

# Login to container registry
az acr login --name threehorizonsregistry
```

## <span style="color: #0366d6;">🏗️ Platform Overview</span>

The Three Horizons Platform provides an integrated development experience combining:

### Core Components

1. **Red Hat Developer Hub**: Central portal for all development activities
2. **GitHub Enterprise**: Source control and collaboration
3. **Azure Kubernetes Service (AKS)**: Container orchestration
4. **Azure Container Registry**: Container image storage
5. **GitHub Actions**: CI/CD automation
6. **Prometheus & Grafana**: Monitoring and observability

### Development Zones

The platform organizes development into four distinct zones:

1. **Development Zone** (Inner Loop):
   - Local development environment
   - Code writing and testing
   - Immediate feedback loops

2. **Integration Zone** (CI/CD):
   - Automated builds and tests
   - Security scanning
   - Container image creation

3. **Runtime Zone** (Outer Loop):
   - Deployment to Kubernetes
   - Application runtime
   - Production workloads

4. **Operations Zone**:
   - Monitoring and logging
   - Performance tracking
   - Incident management

## <span style="color: #0366d6;">🔄 Development Workflow</span>

### Standard Development Flow

1. **Create New Application**:
   ```
   Developer Hub → Create → Select Template → Fill Details → Repository Created
   ```

2. **Local Development**:
   ```bash
   # Clone the repository
   git clone https://github.com/your-org/your-app.git
   cd your-app
   
   # Create feature branch
   git checkout -b feature/my-feature
   
   # Make changes and test locally
   docker build -t your-app:local .
   docker run -p 8080:8080 your-app:local
   ```

3. **Push Changes**:
   ```bash
   # Commit changes
   git add .
   git commit -m "feat: add new feature"
   
   # Push to GitHub
   git push origin feature/my-feature
   ```

4. **Create Pull Request**:
   ```bash
   # Using GitHub CLI
   gh pr create --title "Add new feature" --body "Description of changes"
   ```

5. **Automated CI/CD**:
   - GitHub Actions runs automatically
   - Tests execute
   - Security scans complete
   - Container image builds
   - Deployment to dev environment

6. **Review and Merge**:
   - Code review by peers
   - Automated checks pass
   - Merge to main branch
   - Automatic deployment to production

## <span style="color: #0366d6;">📱 Using Red Hat Developer Hub</span>

> 🎯 **Platform Architecture:** For a comprehensive view of the Developer Hub components and their integration with Azure AI services and GitHub Copilot, see our [Three Horizons Developer Hub Architecture](../images/developer-hub-architecture.svg).

### Accessing Developer Hub

1. Navigate to `https://devhub.example.com`
2. Login with GitHub credentials
3. You'll see the home dashboard with:
   - Your components
   - Recent activities
   - Quick actions

### Key Features

#### Software Catalog

Browse and discover all applications, services, and resources:

- **Components**: Applications and services
- **APIs**: Available APIs and specifications
- **Resources**: Infrastructure components
- **Systems**: Logical groupings of components
- **Domains**: Business domains

#### Creating Applications

1. Click **Create** in the navigation
2. Choose a template:
   - **Web Application**: React/Node.js applications
   - **API Service**: RESTful API services
   - **Kubernetes Application**: Containerized services
   - **Database**: PostgreSQL/MongoDB instances

3. Fill in the template form:
   ```yaml
   name: my-awesome-app
   description: A fantastic new application
   owner: team-alpha
   repository: github.com/your-org/my-awesome-app
   ```

4. Review and create
5. Access your new repository with all scaffolding complete

#### Technical Documentation (TechDocs)

Access and contribute to documentation:

1. Navigate to **Docs** in the navigation
2. Browse available documentation
3. Search for specific topics
4. Contribute by editing markdown files in repositories

#### API Documentation

View and test APIs:

1. Navigate to **APIs** in the catalog
2. Select an API to view its specification
3. Use the built-in API explorer
4. Download OpenAPI specifications

## <span style="color: #0366d6;">🐙 GitHub Integration</span>

### Repository Structure

Standard repository structure for Three Horizons applications:

```
my-app/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml          # CI pipeline
│   │   └── cd.yml          # CD pipeline
│   └── CODEOWNERS          # Code ownership
├── src/                    # Application source code
├── tests/                  # Test files
├── kubernetes/             # Kubernetes manifests
│   ├── base/              # Base configurations
│   └── overlays/          # Environment-specific configs
├── Dockerfile             # Container definition
├── catalog-info.yaml      # Developer Hub metadata
├── mkdocs.yml            # TechDocs configuration
└── README.md             # Project documentation
```

### Catalog Info File

Every repository must include `catalog-info.yaml`:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-app
  description: My awesome application
  annotations:
    github.com/project-slug: your-org/my-app
    backstage.io/techdocs-ref: dir:.
spec:
  type: service
  lifecycle: production
  owner: team-alpha
  system: customer-portal
  dependsOn:
    - resource:default/my-database
  providesApis:
    - my-app-api
```

### Branch Protection

Main branches are protected with:
- Required pull request reviews
- Passing status checks
- Up-to-date branches
- CODEOWNERS approval
- No force pushes

## <span style="color: #0366d6;">🚀 CI/CD Pipelines</span>

### GitHub Actions Workflow

Standard CI pipeline (`.github/workflows/ci.yml`):

```yaml
name: CI Pipeline
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run tests
        run: npm test
        
      - name: Run linting
        run: npm run lint

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          
  build:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
        
      - name: Login to ACR
        uses: docker/login-action@v3
        with:
          registry: threehorizonsregistry.azurecr.io
          username: ${{ secrets.ACR_USERNAME }}
          password: ${{ secrets.ACR_PASSWORD }}
          
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          push: true
          tags: |
            threehorizonsregistry.azurecr.io/${{ github.repository }}:${{ github.sha }}
            threehorizonsregistry.azurecr.io/${{ github.repository }}:latest
```

### Deployment Pipeline

CD pipeline for automatic deployments:

```yaml
name: CD Pipeline
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Update Kubernetes manifests
        run: |
          sed -i "s|IMAGE_TAG|${{ github.sha }}|g" kubernetes/overlays/production/kustomization.yaml
          
      - name: Commit and push to GitOps repo
        run: |
          git config --global user.email "bot@company.com"
          git config --global user.name "Deploy Bot"
          git clone https://github.com/your-org/gitops-repo.git
          cp -r kubernetes/* gitops-repo/apps/my-app/
          cd gitops-repo
          git add .
          git commit -m "Deploy ${{ github.repository }}:${{ github.sha }}"
          git push
```

## <span style="color: #0366d6;">📋 Application Templates</span>

### Available Templates

1. **Web Application Template**:
   - React frontend
   - Node.js backend
   - Docker configuration
   - Kubernetes manifests
   - GitHub Actions workflows

2. **API Service Template**:
   - Express.js or Spring Boot
   - OpenAPI specification
   - Database migrations
   - Health checks
   - Monitoring integration

3. **Microservice Template**:
   - gRPC or REST
   - Service mesh ready
   - Distributed tracing
   - Circuit breakers
   - Rate limiting

### Creating Custom Templates

1. Fork the templates repository
2. Create your template structure:
   ```
   resources/
   └── my-template/
       ├── template.yaml      # Template definition
       ├── skeleton/         # Template files
       └── docs/            # Template documentation
   ```

3. Define template in `template.yaml`:
   ```yaml
   apiVersion: scaffolder.backstage.io/v1beta3
   kind: Template
   metadata:
     name: my-template
     title: My Custom Template
     description: Template for specific use case
   spec:
     owner: platform-team
     type: service
     parameters:
       - title: Basic Information
         required:
           - name
           - description
         properties:
           name:
             title: Name
             type: string
             pattern: '^[a-z0-9-]+$'
           description:
             title: Description
             type: string
     steps:
       - id: fetch
         name: Fetch Skeleton
         action: fetch:template
         input:
           url: ./skeleton
           values:
             name: ${{ parameters.name }}
   ```

## <span style="color: #0366d6;">📊 Monitoring and Observability</span>

### Application Metrics

Expose metrics in Prometheus format:

```javascript
// Node.js example
const prometheus = require('prom-client');
const register = new prometheus.Registry();

// Default metrics
prometheus.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});
```

### Logging Best Practices

Use structured logging:

```javascript
const winston = require('winston');

const logger = winston.createLogger({
  format: winston.format.json(),
  defaultMeta: { 
    service: 'my-app',
    version: process.env.APP_VERSION 
  },
  transports: [
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});

// Log with context
logger.info('Processing request', {
  userId: user.id,
  action: 'purchase',
  amount: 99.99
});
```

### Distributed Tracing

Implement OpenTelemetry:

```javascript
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');

const sdk = new NodeSDK({
  instrumentations: [
    getNodeAutoInstrumentations()
  ]
});

sdk.start();
```

### Accessing Dashboards

1. **Grafana**: `https://grafana.example.com`
   - Application metrics
   - Infrastructure metrics
   - Custom dashboards

2. **Prometheus**: `https://prometheus.example.com`
   - Query metrics
   - Alert rules
   - Targets status

## <span style="color: #0366d6;">🔒 Security Best Practices</span>

### Code Security

1. **Dependency Management**:
   ```json
   // package.json
   {
     "scripts": {
       "audit": "npm audit",
       "audit:fix": "npm audit fix"
     }
   }
   ```

2. **Secret Management**:
   - Never commit secrets
   - Use GitHub Secrets for CI/CD
   - Use Kubernetes Secrets for runtime
   - Rotate secrets regularly

3. **Security Scanning**:
   - Automated vulnerability scanning in CI
   - Container image scanning
   - SAST/DAST integration
   - Dependency updates

### Container Security

```dockerfile
# Use specific versions
FROM node:18-alpine@sha256:abcdef...

# Run as non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001
USER nodejs

# Copy only necessary files
COPY --chown=nodejs:nodejs package*.json ./
RUN npm ci --only=production
COPY --chown=nodejs:nodejs . .

# Use security headers
ENV NODE_ENV=production
EXPOSE 8080
CMD ["node", "server.js"]
```

### Kubernetes Security

```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        fsGroup: 1001
      containers:
      - name: app
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
            - ALL
        resources:
          limits:
            cpu: "1"
            memory: "512Mi"
          requests:
            cpu: "100m"
            memory: "128Mi"
```

## <span style="color: #0366d6;">🔧 Troubleshooting</span>

### Common Issues

1. **Build Failures**:
   ```bash
   # Check GitHub Actions logs
   gh run list
   gh run view <run-id>
   
   # Debug locally
   docker build -t test:local .
   ```

2. **Deployment Issues**:
   ```bash
   # Check pod status
   kubectl get pods -n my-namespace
   kubectl describe pod <pod-name> -n my-namespace
   kubectl logs <pod-name> -n my-namespace
   ```

3. **Developer Hub Issues**:
   - Clear browser cache
   - Check GitHub permissions
   - Verify catalog-info.yaml syntax

### Getting Help

1. **Documentation**:
   - This guide
   - [Complete Integration Tutorial](../complete-integration-tutorial/index.md)
   - Platform runbooks

2. **Support Channels**:
   - Slack: #three-horizons-support
   - GitHub Issues: platform repository
   - Office Hours: Thursdays 2-3 PM

3. **Debugging Tools**:
   ```bash
   # Port forwarding for debugging
   kubectl port-forward pod/<pod-name> 8080:8080 -n my-namespace
   
   # Execute commands in pod
   kubectl exec -it <pod-name> -n my-namespace -- /bin/sh
   
   # View recent events
   kubectl get events -n my-namespace --sort-by='.lastTimestamp'
   ```

## <span style="color: #0366d6;">📚 Additional Resources</span>

### Learning Path

1. **Beginner**:
   - Complete the platform onboarding
   - Deploy your first application
   - Understand the CI/CD flow

2. **Intermediate**:
   - Create custom templates
   - Implement monitoring
   - Optimize deployments

3. **Advanced**:
   - Contribute to platform tools
   - Create Developer Hub plugins
   - Implement advanced patterns

### External Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Backstage Documentation](https://backstage.io/docs)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)

---

<footer>
  <p align="center">🔄 Last updated: June 2025 | Contribute to this guide through <a href="../../../.github/CONTRIBUTING.md">Pull Requests</a></p>
</footer> 