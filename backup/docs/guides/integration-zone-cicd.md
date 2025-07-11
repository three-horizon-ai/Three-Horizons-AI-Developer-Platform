# 🔧 Integration Zone - CI/CD Pipeline Guide

## 🎯 Overview

The Integration Zone is where code from multiple developers converges, is validated, built, and prepared for deployment. This zone represents the critical bridge between development (Inner Loop) and runtime (Outer Loop), ensuring code quality, security, and reliability through automated CI/CD pipelines.

![Integration Zone Architecture](../images/integration-architecture-corrected.png)

> 🔍 **Note:** The Integration Zone acts as the quality gate and automation hub, orchestrating the flow from source code to deployable artifacts.

## 🤔 What is the Integration Zone?

The Integration Zone encompasses:

- **Continuous Integration (CI)**: Automated building, testing, and validation of code changes
- **Continuous Delivery (CD)**: Automated deployment preparation and artifact generation
- **Quality Gates**: Security scanning, code analysis, and compliance checks
- **Artifact Management**: Container images, packages, and deployment manifests

## 📋 Prerequisites

Before configuring the Integration Zone, ensure you have:

- **GitHub Enterprise** access with appropriate permissions
- **Azure DevOps** project configured (if using hybrid approach)
- **Azure Container Registry** for storing container images
- **Service Principals** with necessary permissions
- **Red Hat Developer Hub** with CI/CD plugins enabled

## 🔄 CI/CD Architecture

### Core Components

```yaml
# Integration Zone Components
components:
  source_control:
    - GitHub Enterprise
    - Branch protection rules
    - Webhooks configuration
  
  ci_systems:
    - GitHub Actions (primary)
    - Azure DevOps Pipelines (enterprise features)
    
  artifact_stores:
    - Azure Container Registry
    - Azure Artifacts
    - GitHub Packages
    
  quality_tools:
    - SonarQube/SonarCloud
    - Snyk/Trivy security scanning
    - OWASP dependency check
```

## 🚀 GitHub Actions Configuration

### Basic CI Pipeline

Create `.github/workflows/ci.yml`:

```yaml
name: CI Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
      
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Set up Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Run linting
      run: npm run lint
      
    - name: Run tests
      run: npm test -- --coverage
      
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        token: ${{ secrets.CODECOV_TOKEN }}
        
  security-scan:
    runs-on: ubuntu-latest
    needs: build-and-test
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        format: 'sarif'
        output: 'trivy-results.sarif'
        
    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'
        
  build-container:
    runs-on: ubuntu-latest
    needs: [build-and-test, security-scan]
    if: github.event_name == 'push'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
      
    - name: Log in to Container Registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
        
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=semver,pattern={{version}}
          type=sha,prefix={{branch}}-
          
    - name: Build and push container image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
```

### Advanced CD Pipeline

Create `.github/workflows/cd.yml`:

```yaml
name: CD Pipeline

on:
  workflow_run:
    workflows: ["CI Pipeline"]
    types:
      - completed
    branches: [main]

jobs:
  deploy-dev:
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    runs-on: ubuntu-latest
    environment: development
    
    steps:
    - name: Checkout GitOps repository
      uses: actions/checkout@v4
      with:
        repository: ${{ github.repository_owner }}/gitops-configs
        token: ${{ secrets.GITOPS_TOKEN }}
        
    - name: Update deployment manifests
      run: |
        # Update Kubernetes manifests with new image tag
        export NEW_TAG="${{ github.sha }}"
        sed -i "s|image:.*|image: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${NEW_TAG}|g" environments/dev/deployment.yaml
        
    - name: Commit and push changes
      run: |
        git config --global user.name 'GitHub Actions'
        git config --global user.email 'actions@github.com'
        git add .
        git commit -m "Deploy ${{ github.sha }} to development"
        git push
```

## 🔧 Azure DevOps Integration

### Hybrid Pipeline Approach

For enterprises requiring Azure DevOps features:

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
    - main
    - release/*

pool:
  vmImage: 'ubuntu-latest'

variables:
  - group: three-horizons-vars
  - name: dockerRegistryServiceConnection
    value: 'three-horizons-acr'

stages:
- stage: Build
  displayName: 'Build and Test'
  jobs:
  - job: BuildJob
    displayName: 'Build Application'
    steps:
    - task: NodeTool@0
      inputs:
        versionSpec: '18.x'
        
    - script: |
        npm ci
        npm run build
        npm test
      displayName: 'Build and Test'
      
    - task: PublishTestResults@2
      inputs:
        testResultsFiles: '**/test-results.xml'
        testRunTitle: 'Unit Tests'
        
    - task: PublishCodeCoverageResults@1
      inputs:
        codeCoverageTool: 'Cobertura'
        summaryFileLocation: '$(System.DefaultWorkingDirectory)/**/*coverage.xml'
        
- stage: SecurityScan
  displayName: 'Security Scanning'
  dependsOn: Build
  jobs:
  - job: SecurityJob
    displayName: 'Run Security Scans'
    steps:
    - task: WhiteSource@21
      inputs:
        cwd: '$(System.DefaultWorkingDirectory)'
        
    - task: SonarCloudPrepare@1
      inputs:
        SonarCloud: 'three-horizons-sonarcloud'
        organization: 'three-horizons'
        scannerMode: 'CLI'
        
    - task: SonarCloudAnalyze@1
    
    - task: SonarCloudPublish@1
      inputs:
        pollingTimeoutSec: '300'
        
- stage: Package
  displayName: 'Package and Publish'
  dependsOn: SecurityScan
  jobs:
  - job: PackageJob
    displayName: 'Build Container Image'
    steps:
    - task: Docker@2
      inputs:
        containerRegistry: $(dockerRegistryServiceConnection)
        repository: '$(imageRepository)'
        command: 'buildAndPush'
        Dockerfile: '**/Dockerfile'
        tags: |
          $(Build.BuildId)
          latest
```

## 🔄 GitOps Configuration

### Flux CD Integration

Configure Flux for automated deployments:

```yaml
# flux-system/gotk-sync.yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: GitRepository
metadata:
  name: three-horizons-gitops
  namespace: flux-system
spec:
  interval: 1m
  ref:
    branch: main
  url: https://github.com/your-org/gitops-configs
  secretRef:
    name: github-credentials
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: three-horizons-apps
  namespace: flux-system
spec:
  interval: 10m
  path: ./clusters/production
  prune: true
  sourceRef:
    kind: GitRepository
    name: three-horizons-gitops
  validation: client
  postBuild:
    substituteFrom:
    - kind: ConfigMap
      name: cluster-vars
```

### ArgoCD Alternative

For ArgoCD users:

```yaml
# argocd/application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: three-horizons-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/gitops-configs
    targetRevision: HEAD
    path: environments/production
  destination:
    server: https://kubernetes.default.svc
    namespace: three-horizons
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

## 🔐 Security Integration

### Container Scanning Pipeline

```yaml
# .github/workflows/container-security.yml
name: Container Security Scan

on:
  push:
    tags:
      - 'v*'

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
    - name: Run Grype vulnerability scanner
      uses: anchore/scan-action@v3
      with:
        image: "${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.ref_name }}"
        fail-build: true
        severity-cutoff: high
        
    - name: Run Syft SBOM generator
      uses: anchore/sbom-action@v0
      with:
        image: "${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.ref_name }}"
        format: spdx-json
        
    - name: Upload SBOM to dependency track
      run: |
        curl -X POST https://dependency-track.example.com/api/v1/bom \
          -H "X-Api-Key: ${{ secrets.DEPENDENCY_TRACK_KEY }}" \
          -H "Content-Type: application/json" \
          -d @sbom.json
```

## 📊 Quality Gates

### SonarQube Integration

```yaml
# sonar-project.properties
sonar.projectKey=three-horizons-app
sonar.organization=three-horizons
sonar.sources=src
sonar.tests=tests
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.exclusions=**/*.test.js,**/node_modules/**

# Quality Gate thresholds
sonar.qualitygate.wait=true
```

### Pull Request Checks

Configure branch protection rules:

```json
{
  "required_status_checks": {
    "strict": true,
    "checks": [
      {
        "context": "build-and-test",
        "app_id": null
      },
      {
        "context": "security-scan",
        "app_id": null
      },
      {
        "context": "sonarcloud",
        "app_id": null
      }
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismissal_restrictions": {},
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 2
  }
}
```

## 🚀 Progressive Delivery

### Feature Flags Integration

```yaml
# .github/workflows/feature-flag-sync.yml
name: Sync Feature Flags

on:
  push:
    branches: [main]
    paths:
      - 'feature-flags.yaml'

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v4
      
    - name: Sync with LaunchDarkly
      run: |
        ld-cli flags sync \
          --file feature-flags.yaml \
          --project three-horizons \
          --environment production
      env:
        LD_API_TOKEN: ${{ secrets.LAUNCHDARKLY_TOKEN }}
```

## 📈 Metrics and Monitoring

### DORA Metrics Collection

Track key metrics:

- **Deployment Frequency**: How often code is deployed
- **Lead Time**: Time from commit to production
- **MTTR**: Mean time to restore service
- **Change Failure Rate**: Percentage of deployments causing failures

```yaml
# Example metrics collection
- name: Record deployment metrics
  run: |
    curl -X POST https://metrics.example.com/api/deployments \
      -H "Authorization: Bearer ${{ secrets.METRICS_TOKEN }}" \
      -d '{
        "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
        "environment": "production",
        "version": "${{ github.sha }}",
        "duration": "${{ job.duration }}",
        "status": "${{ job.status }}"
      }'
```

## ✅ Best Practices

1. **Pipeline as Code**: Store all pipeline configurations in version control
2. **Fail Fast**: Run quick checks (linting, unit tests) before expensive operations
3. **Parallel Execution**: Run independent jobs in parallel to reduce build time
4. **Caching**: Cache dependencies and build artifacts to speed up pipelines
5. **Secrets Management**: Use GitHub Secrets or Azure Key Vault for sensitive data
6. **Artifact Versioning**: Use semantic versioning for releases
7. **Environment Promotion**: Use GitOps for promoting between environments
8. **Monitoring**: Implement comprehensive pipeline monitoring and alerting

## 🛠️ Troubleshooting

### Common Issues

#### Pipeline Failures
- Check job logs for specific error messages
- Verify all secrets and variables are correctly configured
- Ensure service connections have appropriate permissions

#### Slow Builds
- Review and optimize Docker layer caching
- Parallelize test execution
- Use build matrices for multi-platform builds

#### Security Scan Failures
- Review vulnerability reports for false positives
- Update base images and dependencies regularly
- Configure appropriate severity thresholds

## 📚 Related Documentation

- [Inner Loop Development Guide](./inner-loop-development.md)
- [Outer Loop Deployment Guide](./outer-loop-deployment.md)
- [Operations Zone Guide](./operations-zone-monitoring.md)
- [Complete Integration Tutorial](../complete-integration-tutorial/index.md) 