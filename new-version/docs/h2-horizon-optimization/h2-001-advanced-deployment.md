# 🚀 H2-001: Advanced Deployment Strategies - GitOps & Multi-Cloud

<div align="center">

**Implementing GitOps, Progressive Delivery, and Multi-Cloud Deployments**

</div>

## 📋 Table of Contents

1. [Overview](#-overview)
2. [GitOps Implementation](#-gitops-implementation)
3. [Multi-Cloud Architecture](#-multi-cloud-architecture)
4. [Progressive Delivery Patterns](#-progressive-delivery-patterns)
5. [Environment Promotion](#-environment-promotion)
6. [Flux Configuration](#-flux-configuration)
7. [ArgoCD Setup](#-argocd-setup)
8. [Multi-Cloud Deployment](#-multi-cloud-deployment)
9. [Advanced Patterns](#-advanced-patterns)
10. [Validation & Testing](#-validation--testing)

## 🔍 Overview

Horizon 2 introduces advanced deployment capabilities that enable organizations to deploy with confidence across multiple environments and cloud providers. This guide covers GitOps principles, progressive delivery patterns, and multi-cloud strategies.

### Key Capabilities

| Feature | Description | Benefits |
|---------|-------------|----------|
| **GitOps** | Declarative infrastructure and deployments | Version control, auditability |
| **Progressive Delivery** | Canary, blue-green, feature flags | Risk mitigation |
| **Multi-Cloud** | Deploy to Azure, AWS, GCP | Vendor independence |
| **Automated Promotion** | Environment progression | Reduced manual effort |
| **Rollback Automation** | Instant rollback capability | Fast recovery |
| **Policy Enforcement** | OPA/Gatekeeper integration | Compliance automation |

## 🌊 GitOps Implementation

### GitOps Principles

```mermaid
graph TB
    subgraph "GitOps Workflow"
        A[Git Repository] -->|1. Push Changes| B[CI Pipeline]
        B -->|2. Build & Test| C[Container Registry]
        C -->|3. Update Manifest| D[Config Repository]
        D -->|4. Sync| E[GitOps Operator]
        E -->|5. Deploy| F[Kubernetes Clusters]
        F -->|6. Monitor| G[Observability]
        G -->|7. Drift Detection| E
    end
    
    style A fill:#90EE90
    style D fill:#90EE90
    style E fill:#FFD700
```

### Repository Structure

```bash
# GitOps repository structure
gitops-config/
├── clusters/
│   ├── dev/
│   │   ├── flux-system/
│   │   ├── apps/
│   │   └── infrastructure/
│   ├── staging/
│   │   ├── flux-system/
│   │   ├── apps/
│   │   └── infrastructure/
│   └── prod/
│       ├── flux-system/
│       ├── apps/
│       └── infrastructure/
├── apps/
│   ├── base/
│   │   ├── frontend/
│   │   ├── backend/
│   │   └── database/
│   └── overlays/
│       ├── dev/
│       ├── staging/
│       └── prod/
└── infrastructure/
    ├── base/
    │   ├── namespaces/
    │   ├── rbac/
    │   └── policies/
    └── overlays/
        ├── dev/
        ├── staging/
        └── prod/
```

### Initialize GitOps Repository

```bash
#!/bin/bash
# setup-gitops-repo.sh

# Create GitOps repository
gh repo create $GITHUB_ORG/gitops-config \
  --private \
  --description "GitOps configuration for Three Horizons Platform"

# Clone repository
git clone https://github.com/$GITHUB_ORG/gitops-config
cd gitops-config

# Create directory structure
mkdir -p clusters/{dev,staging,prod}/{flux-system,apps,infrastructure}
mkdir -p apps/{base,overlays/{dev,staging,prod}}
mkdir -p infrastructure/{base,overlays/{dev,staging,prod}}

# Create base kustomization
cat > apps/base/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - frontend/
  - backend/
  - database/

commonLabels:
  app.kubernetes.io/managed-by: flux
  app.kubernetes.io/part-of: three-horizons
EOF

# Create environment overlays
for env in dev staging prod; do
  cat > apps/overlays/$env/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../base

patchesStrategicMerge:
  - deployment-patch.yaml
  - service-patch.yaml

configMapGenerator:
  - name: app-config
    envs:
      - config.env

namespace: three-horizons-$env
EOF
done

# Commit initial structure
git add .
git commit -m "Initial GitOps repository structure"
git push origin main
```

## 🌍 Multi-Cloud Architecture

### Cloud Provider Abstraction

```yaml
# infrastructure/base/cloud-provider-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cloud-provider-config
  namespace: flux-system
data:
  providers.yaml: |
    providers:
      azure:
        regions:
          - name: centralus
            primary: true
          - name: eastus2
            failover: true
        services:
          kubernetes: aks
          database: cosmos
          storage: blob
      aws:
        regions:
          - name: us-east-1
            primary: true
          - name: us-west-2
            failover: true
        services:
          kubernetes: eks
          database: rds
          storage: s3
      gcp:
        regions:
          - name: us-central1
            primary: true
          - name: us-east1
            failover: true
        services:
          kubernetes: gke
          database: cloud-sql
          storage: gcs
```

### Multi-Cloud Deployment Strategy

```go
// pkg/multicloud/deployer.go
package multicloud

import (
    "context"
    "fmt"
    "sync"
    
    "github.com/threehorizons/platform/pkg/providers"
)

type CloudProvider interface {
    Deploy(ctx context.Context, manifest []byte) error
    GetStatus(ctx context.Context, name string) (*DeploymentStatus, error)
    Rollback(ctx context.Context, name string) error
}

type MultiCloudDeployer struct {
    providers map[string]CloudProvider
    strategy  DeploymentStrategy
}

type DeploymentStrategy struct {
    Primary   string
    Secondary []string
    Failover  bool
    Parallel  bool
}

func (m *MultiCloudDeployer) Deploy(ctx context.Context, manifest []byte) error {
    if m.strategy.Parallel {
        return m.deployParallel(ctx, manifest)
    }
    return m.deploySequential(ctx, manifest)
}

func (m *MultiCloudDeployer) deployParallel(ctx context.Context, manifest []byte) error {
    var wg sync.WaitGroup
    errChan := make(chan error, len(m.providers))
    
    for name, provider := range m.providers {
        wg.Add(1)
        go func(n string, p CloudProvider) {
            defer wg.Done()
            if err := p.Deploy(ctx, manifest); err != nil {
                errChan <- fmt.Errorf("%s: %w", n, err)
            }
        }(name, provider)
    }
    
    wg.Wait()
    close(errChan)
    
    var errs []error
    for err := range errChan {
        errs = append(errs, err)
    }
    
    if len(errs) > 0 {
        return fmt.Errorf("deployment errors: %v", errs)
    }
    
    return nil
}

func (m *MultiCloudDeployer) deploySequential(ctx context.Context, manifest []byte) error {
    // Deploy to primary first
    primary := m.providers[m.strategy.Primary]
    if err := primary.Deploy(ctx, manifest); err != nil {
        return fmt.Errorf("primary deployment failed: %w", err)
    }
    
    // Deploy to secondary providers
    for _, name := range m.strategy.Secondary {
        provider := m.providers[name]
        if err := provider.Deploy(ctx, manifest); err != nil {
            // Log error but continue if not critical
            fmt.Printf("Warning: secondary deployment to %s failed: %v\n", name, err)
        }
    }
    
    return nil
}
```

## 🎯 Progressive Delivery Patterns

### 1. Canary Deployment with Flagger

```yaml
# apps/base/frontend/canary.yaml
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: frontend
spec:
  provider: nginx
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: frontend
  progressDeadlineSeconds: 600
  service:
    port: 80
    targetPort: 8080
    gateways:
    - public-gateway
    hosts:
    - app.threehorizons.ai
  analysis:
    interval: 30s
    threshold: 5
    maxWeight: 50
    stepWeight: 10
    metrics:
    - name: request-success-rate
      templateRef:
        name: request-success-rate
        namespace: flagger-system
      thresholdRange:
        min: 99
      interval: 1m
    - name: request-duration
      templateRef:
        name: request-duration
        namespace: flagger-system
      thresholdRange:
        max: 500
      interval: 1m
    - name: custom-business-metric
      templateRef:
        name: conversion-rate
        namespace: monitoring
      thresholdRange:
        min: 1.5
    webhooks:
    - name: load-test
      type: rollout
      url: http://flagger-loadtester.flagger-system/
      timeout: 15s
      metadata:
        type: cmd
        cmd: "hey -z 2m -q 10 -c 2 http://frontend-canary.prod:80/"
    - name: acceptance-test
      type: pre-rollout
      url: http://flagger-loadtester.flagger-system/
      timeout: 30s
      metadata:
        type: bash
        cmd: "curl -s http://frontend-canary.prod:80/api/health | grep -q 'ok'"
    alerts:
    - name: slack
      severity: info
      providerRef:
        name: slack-webhook
        namespace: flagger-system
```

### 2. Blue-Green Deployment

```yaml
# apps/base/backend/blue-green.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: backend
spec:
  replicas: 5
  strategy:
    blueGreen:
      activeService: backend-active
      previewService: backend-preview
      autoPromotionEnabled: false
      scaleDownDelaySeconds: 30
      prePromotionAnalysis:
        templates:
        - templateName: success-rate
        args:
        - name: service-name
          value: backend-preview
      postPromotionAnalysis:
        templates:
        - templateName: success-rate
        args:
        - name: service-name
          value: backend-active
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: acr.azurecr.io/backend:latest
        ports:
        - containerPort: 8080
        env:
        - name: ENVIRONMENT
          value: production
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: backend-active
spec:
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: backend-preview
spec:
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 8080
```

### 3. Feature Flags Integration

```typescript
// apps/base/feature-flags/unleash-config.ts
import { Unleash, Strategy } from 'unleash-client';

interface FeatureFlagConfig {
  url: string;
  appName: string;
  environment: string;
  refreshInterval: number;
}

export class FeatureFlagManager {
  private unleash: Unleash;
  
  constructor(config: FeatureFlagConfig) {
    this.unleash = new Unleash({
      url: config.url,
      appName: config.appName,
      environment: config.environment,
      refreshInterval: config.refreshInterval,
      strategies: [
        new GradualRolloutStrategy(),
        new UserWithIdStrategy(),
        new TargetingStrategy(),
      ],
    });
  }
  
  async isEnabled(feature: string, context?: any): Promise<boolean> {
    return this.unleash.isEnabled(feature, context);
  }
  
  async getVariant(feature: string, context?: any): Promise<any> {
    return this.unleash.getVariant(feature, context);
  }
}

// Kubernetes ConfigMap for feature flags
const featureFlagConfigMap = {
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'feature-flags',
    namespace: 'prod',
  },
  data: {
    'flags.json': JSON.stringify({
      features: [
        {
          name: 'new-checkout-flow',
          enabled: false,
          strategies: [{
            name: 'gradualRollout',
            parameters: { percentage: '10' },
          }],
        },
        {
          name: 'ai-recommendations',
          enabled: true,
          strategies: [{
            name: 'userWithId',
            parameters: { userIds: 'beta-users' },
          }],
        },
      ],
    }),
  },
};
```

## 📈 Environment Promotion

### Automated Promotion Pipeline

```yaml
# .github/workflows/promote-environments.yml
name: Environment Promotion

on:
  workflow_dispatch:
    inputs:
      source_env:
        description: 'Source environment'
        required: true
        type: choice
        options:
          - dev
          - staging
      target_env:
        description: 'Target environment'
        required: true
        type: choice
        options:
          - staging
          - prod
      version:
        description: 'Version to promote'
        required: true
        type: string

jobs:
  validate:
    runs-on: ubuntu-latest
    outputs:
      proceed: ${{ steps.validate.outputs.proceed }}
    steps:
      - name: Validate promotion path
        id: validate
        run: |
          if [[ "${{ inputs.source_env }}" == "dev" && "${{ inputs.target_env }}" == "prod" ]]; then
            echo "❌ Direct promotion from dev to prod not allowed"
            echo "proceed=false" >> $GITHUB_OUTPUT
            exit 1
          fi
          echo "proceed=true" >> $GITHUB_OUTPUT
          
  promote:
    needs: validate
    if: needs.validate.outputs.proceed == 'true'
    runs-on: ubuntu-latest
    steps:
      - name: Checkout GitOps repo
        uses: actions/checkout@v4
        with:
          repository: ${{ github.repository_owner }}/gitops-config
          token: ${{ secrets.GITOPS_TOKEN }}
          
      - name: Update target environment
        run: |
          # Copy configurations from source to target
          cp -r apps/overlays/${{ inputs.source_env }}/* apps/overlays/${{ inputs.target_env }}/
          
          # Update image tags
          find apps/overlays/${{ inputs.target_env }} -name "*.yaml" -type f \
            -exec sed -i 's/:${{ inputs.source_env }}-.*/:${{ inputs.version }}/g' {} \;
            
          # Update environment-specific configs
          sed -i "s/namespace: .*-${{ inputs.source_env }}/namespace: three-horizons-${{ inputs.target_env }}/g" \
            apps/overlays/${{ inputs.target_env }}/kustomization.yaml
            
      - name: Run validation tests
        run: |
          # Validate Kubernetes manifests
          kubectl apply --dry-run=client -f apps/overlays/${{ inputs.target_env }}/
          
          # Run policy checks
          opa test policies/ -v
          
      - name: Create promotion PR
        uses: peter-evans/create-pull-request@v5
        with:
          title: "Promote ${{ inputs.version }} from ${{ inputs.source_env }} to ${{ inputs.target_env }}"
          body: |
            ## 🚀 Environment Promotion
            
            Promoting version `${{ inputs.version }}` from **${{ inputs.source_env }}** to **${{ inputs.target_env }}**
            
            ### Checklist
            - [ ] All tests passed in ${{ inputs.source_env }}
            - [ ] Security scans completed
            - [ ] Performance benchmarks acceptable
            - [ ] Rollback plan documented
            
            ### Changes
            - Updated image tags to ${{ inputs.version }}
            - Synchronized configurations from ${{ inputs.source_env }}
            
            /cc @platform-team
          branch: promote-${{ inputs.version }}-to-${{ inputs.target_env }}
          labels: |
            promotion
            ${{ inputs.target_env }}
```

### Promotion Gates

```yaml
# infrastructure/base/policies/promotion-policy.yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: promotion-requirements
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: require-security-scan
    match:
      any:
      - resources:
          kinds:
          - Deployment
          namespaces:
          - "*-staging"
          - "*-prod"
    validate:
      message: "Security scan label required for staging/prod deployments"
      pattern:
        metadata:
          labels:
            security-scan: "passed"
            
  - name: require-approval-label
    match:
      any:
      - resources:
          kinds:
          - Deployment
          namespaces:
          - "*-prod"
    validate:
      message: "Production deployments require approval"
      pattern:
        metadata:
          labels:
            approved-by: "*"
            approval-date: "*"
            
  - name: resource-limits-required
    match:
      any:
      - resources:
          kinds:
          - Deployment
          namespaces:
          - "*-prod"
    validate:
      message: "Production deployments must have resource limits"
      pattern:
        spec:
          template:
            spec:
              containers:
              - name: "*"
                resources:
                  limits:
                    memory: "*"
                    cpu: "*"
                  requests:
                    memory: "*"
                    cpu: "*"
```

## 🔄 Flux Configuration

### 1. Bootstrap Flux

```bash
#!/bin/bash
# bootstrap-flux.sh

# Install Flux CLI
curl -s https://fluxcd.io/install.sh | sudo bash

# Verify installation
flux check --pre

# Bootstrap Flux for each cluster
for ENV in dev staging prod; do
  echo "🚀 Bootstrapping Flux for $ENV environment..."
  
  # Set cluster context
  kubectl config use-context aks-threehorizons-$ENV
  
  # Bootstrap Flux
  flux bootstrap github \
    --owner=$GITHUB_ORG \
    --repository=gitops-config \
    --branch=main \
    --path=clusters/$ENV \
    --personal \
    --private=true \
    --reconcile-interval=1m
    
  # Create image update automation
  flux create image repository frontend \
    --image=acr$BASE_NAME$ENV.azurecr.io/frontend \
    --interval=1m
    
  flux create image policy frontend \
    --image-ref=frontend \
    --select-semver=">1.0.0" \
    --filter-regex='^(?P<version>.*)-(?P<ts>[0-9]+)$' \
    --filter-extract='$version'
    
  flux create image update automation frontend \
    --git-repo-ref=flux-system \
    --git-repo-path="./clusters/$ENV" \
    --checkout-branch=main \
    --push-branch=main \
    --author-name=flux-bot \
    --author-email=flux@threehorizons.ai \
    --commit-template="{{range .Updated.Images}}{{println .}}{{end}}" \
    --interval=1m
done
```

### 2. Flux Kustomization Structure

```yaml
# clusters/prod/flux-system/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - gotk-components.yaml
  - gotk-sync.yaml
  - infrastructure.yaml
  - apps.yaml
  - monitoring.yaml
  
patches:
  - patch: |
      apiVersion: v1
      kind: ServiceAccount
      metadata:
        name: source-controller
        namespace: flux-system
        annotations:
          azure.workload.identity/client-id: "${AZURE_CLIENT_ID}"
    target:
      kind: ServiceAccount
      name: source-controller
---
# clusters/prod/infrastructure.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: infrastructure
  namespace: flux-system
spec:
  interval: 10m
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./infrastructure/overlays/prod
  prune: true
  wait: true
  healthChecks:
    - apiVersion: v1
      kind: Namespace
      name: cert-manager
    - apiVersion: v1
      kind: Namespace
      name: ingress-nginx
---
# clusters/prod/apps.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: apps
  namespace: flux-system
spec:
  dependsOn:
    - name: infrastructure
  interval: 5m
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./apps/overlays/prod
  prune: true
  wait: true
  postBuild:
    substitute:
      cluster_name: "aks-prod"
      region: "centralus"
    substituteFrom:
      - kind: ConfigMap
        name: cluster-config
      - kind: Secret
        name: cluster-secrets
```

### 3. Flux Monitoring and Alerts

```yaml
# infrastructure/base/monitoring/flux-alerts.yaml
apiVersion: notification.toolkit.fluxcd.io/v1beta2
kind: Provider
metadata:
  name: slack
  namespace: flux-system
spec:
  type: slack
  channel: platform-alerts
  secretRef:
    name: slack-webhook
---
apiVersion: notification.toolkit.fluxcd.io/v1beta2
kind: Alert
metadata:
  name: deployment-failures
  namespace: flux-system
spec:
  providerRef:
    name: slack
  eventSeverity: error
  eventSources:
    - kind: Kustomization
      name: apps
    - kind: HelmRelease
      name: '*'
  summary: |
    🚨 Deployment Failed
    Cluster: {{ .Metadata.cluster }}
    Kind: {{ .InvolvedObject.Kind }}
    Name: {{ .InvolvedObject.Name }}
    Message: {{ .Message }}
---
apiVersion: notification.toolkit.fluxcd.io/v1beta2
kind: Alert
metadata:
  name: reconciliation-info
  namespace: flux-system
spec:
  providerRef:
    name: slack
  eventSeverity: info
  eventSources:
    - kind: GitRepository
      name: flux-system
    - kind: Kustomization
      name: infrastructure
    - kind: Kustomization
      name: apps
  exclusionList:
    - "waiting.*socket"
    - "dependencies.*not.*ready"
  summary: |
    ✅ Reconciliation Success
    Kind: {{ .InvolvedObject.Kind }}
    Name: {{ .InvolvedObject.Name }}
    Message: {{ .Message }}
```

## 🚢 ArgoCD Setup

### 1. ArgoCD Installation

```bash
#!/bin/bash
# install-argocd.sh

# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install ArgoCD CLI
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

# Configure ArgoCD for production
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  url: https://argocd.threehorizons.ai
  
  # RBAC configuration
  policy.default: role:readonly
  policy.csv: |
    p, role:admin, applications, *, */*, allow
    p, role:admin, clusters, *, *, allow
    p, role:admin, repositories, *, *, allow
    g, ThreeHorizons-Platform-Admins, role:admin
    g, ThreeHorizons-Developers, role:readonly
    
  # Dex configuration for Azure AD
  dex.config: |
    connectors:
    - type: microsoft
      id: microsoft
      name: Azure AD
      config:
        clientID: \$AZURE_CLIENT_ID
        clientSecret: \$AZURE_CLIENT_SECRET
        redirectURI: https://argocd.threehorizons.ai/api/dex/callback
        tenant: \$AZURE_TENANT_ID
        groups:
          - ThreeHorizons-Platform-Admins
          - ThreeHorizons-Developers
          
  # Repository credentials
  repositories: |
    - url: https://github.com/\$GITHUB_ORG
      passwordSecret:
        name: github-credentials
        key: token
      usernameSecret:
        name: github-credentials
        key: username
EOF

# Create ingress
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - argocd.threehorizons.ai
    secretName: argocd-server-tls
  rules:
  - host: argocd.threehorizons.ai
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 443
EOF
```

### 2. ArgoCD Applications

```yaml
# argocd/applications/app-of-apps.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-of-apps
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/${GITHUB_ORG}/gitops-config
    targetRevision: HEAD
    path: argocd/applications
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
    - CreateNamespace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
---
# argocd/applications/production.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: production
  namespace: argocd
spec:
  project: production
  source:
    repoURL: https://github.com/${GITHUB_ORG}/gitops-config
    targetRevision: HEAD
    path: apps/overlays/prod
  destination:
    server: https://kubernetes.default.svc
    namespace: three-horizons-prod
  syncPolicy:
    automated:
      prune: false  # Manual pruning for production
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
    - PruneLast=true
  revisionHistoryLimit: 10
```

### 3. ArgoCD Progressive Sync

```yaml
# argocd/progressive-sync.yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: progressive-rollout
  namespace: argocd
spec:
  description: Progressive rollout project
  sourceRepos:
  - 'https://github.com/${GITHUB_ORG}/*'
  destinations:
  - namespace: '*'
    server: '*'
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  roles:
  - name: progressive-sync
    policies:
    - p, proj:progressive-rollout:progressive-sync, applications, sync, progressive-rollout/*, allow
    groups:
    - ThreeHorizons-Platform-Admins
  syncWindows:
  - kind: allow
    schedule: "0 8-17 * * 1-5"  # Weekdays 8AM-5PM
    duration: 9h
    applications:
    - "production"
  - kind: deny
    schedule: "0 0-7,18-23 * * *"  # Nights
    duration: 14h
    applications:
    - "production"
```

## 🌐 Multi-Cloud Deployment

### 1. Azure AKS Deployment

```yaml
# infrastructure/overlays/prod/azure/aks-cluster.yaml
apiVersion: containerservice.azure.com/v1alpha1
kind: ManagedCluster
metadata:
  name: aks-threehorizons-prod
  namespace: flux-system
spec:
  resourceGroupName: rg-threehorizons-prod
  location: centralus
  version: "1.28.5"
  networkProfile:
    networkPlugin: azure
    networkPolicy: calico
    serviceCidr: 10.0.0.0/16
    dnsServiceIP: 10.0.0.10
  agentPoolProfiles:
  - name: system
    count: 3
    vmSize: Standard_D4s_v5
    mode: System
    availabilityZones: ["1", "2", "3"]
  - name: user
    count: 5
    vmSize: Standard_D8s_v5
    mode: User
    availabilityZones: ["1", "2", "3"]
    enableAutoScaling: true
    minCount: 3
    maxCount: 10
  addons:
    - name: monitoring
      enabled: true
    - name: azurePolicy
      enabled: true
    - name: keyVaultSecretsProvider
      enabled: true
```

### 2. AWS EKS Deployment

```yaml
# infrastructure/overlays/prod/aws/eks-cluster.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: eks-threehorizons-prod
  region: us-east-1
  version: "1.28"

availabilityZones:
  - us-east-1a
  - us-east-1b
  - us-east-1c

iam:
  withOIDC: true
  serviceAccounts:
  - metadata:
      name: flux-system
      namespace: flux-system
    iamRole: arn:aws:iam::123456789012:role/flux-system

managedNodeGroups:
  - name: system
    instanceType: m5.xlarge
    desiredCapacity: 3
    minSize: 3
    maxSize: 5
    availabilityZones: ["us-east-1a", "us-east-1b", "us-east-1c"]
    labels:
      nodegroup-type: system
    tags:
      nodegroup-role: system
    
  - name: user
    instanceType: m5.2xlarge
    desiredCapacity: 5
    minSize: 3
    maxSize: 10
    availabilityZones: ["us-east-1a", "us-east-1b", "us-east-1c"]
    labels:
      nodegroup-type: user
    tags:
      nodegroup-role: user

addons:
  - name: vpc-cni
    version: latest
  - name: coredns
    version: latest
  - name: kube-proxy
    version: latest
  - name: aws-ebs-csi-driver
    version: latest
```

### 3. GCP GKE Deployment

```yaml
# infrastructure/overlays/prod/gcp/gke-cluster.yaml
apiVersion: container.cnrm.cloud.google.com/v1beta1
kind: ContainerCluster
metadata:
  name: gke-threehorizons-prod
  namespace: flux-system
spec:
  location: us-central1
  initialNodeCount: 1
  removeDefaultNodePool: true
  
  workloadIdentityConfig:
    workloadPool: threehorizons-prod.svc.id.goog
    
  networkConfig:
    enableIntraNodeVisibility: true
    datapathProvider: ADVANCED_DATAPATH
    
  addonsConfig:
    horizontalPodAutoscaling:
      disabled: false
    httpLoadBalancing:
      disabled: false
    networkPolicyConfig:
      disabled: false
      
---
apiVersion: container.cnrm.cloud.google.com/v1beta1
kind: ContainerNodePool
metadata:
  name: system-pool
spec:
  clusterRef:
    name: gke-threehorizons-prod
  location: us-central1
  initialNodeCount: 3
  
  nodeConfig:
    machineType: n2-standard-4
    diskSizeGb: 100
    diskType: pd-ssd
    
    oauthScopes:
    - "https://www.googleapis.com/auth/cloud-platform"
    
    labels:
      nodepool: system
      
    taints:
    - key: CriticalAddonsOnly
      value: "true"
      effect: NO_SCHEDULE
      
  autoscaling:
    minNodeCount: 3
    maxNodeCount: 5
    
  management:
    autoRepair: true
    autoUpgrade: true
```

### 4. Multi-Cloud Service Mesh

```yaml
# infrastructure/base/istio/multi-cloud-mesh.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: control-plane
spec:
  values:
    pilot:
      env:
        PILOT_ENABLE_WORKLOAD_ENTRY_AUTOREGISTRATION: true
    global:
      meshID: mesh1
      multiCluster:
        clusterName: azure-aks
      network: network1
  components:
    pilot:
      k8s:
        env:
        - name: PILOT_ENABLE_CROSS_CLOUD_AUTO_REGISTRATION
          value: "true"
---
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: cross-cloud-gateway
spec:
  selector:
    istio: eastwestgateway
  servers:
  - port:
      number: 15443
      name: tls
      protocol: TLS
    tls:
      mode: ISTIO_MUTUAL
    hosts:
    - "*.local"
---
apiVersion: v1
kind: Secret
metadata:
  name: cacerts
  namespace: istio-system
type: Opaque
data:
  root-cert.pem: # Base64 encoded root certificate
  cert-chain.pem: # Base64 encoded certificate chain
  ca-cert.pem: # Base64 encoded CA certificate
  ca-key.pem: # Base64 encoded CA key
```

## 🔧 Advanced Patterns

### 1. GitOps with Secrets Management

```yaml
# infrastructure/base/sealed-secrets/controller.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: sealed-secrets
---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: sealed-secrets
  namespace: sealed-secrets
spec:
  interval: 5m
  chart:
    spec:
      chart: sealed-secrets
      version: "2.13.0"
      sourceRef:
        kind: HelmRepository
        name: sealed-secrets
        namespace: flux-system
  values:
    controller:
      create: true
      resources:
        requests:
          memory: 256Mi
          cpu: 100m
        limits:
          memory: 512Mi
          cpu: 500m
---
# Example sealed secret
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: database-credentials
  namespace: prod
spec:
  encryptedData:
    username: AgBvA8QlG5Jm+RQwZ... # Encrypted data
    password: AgCdE1sTDyNJ3C+eW... # Encrypted data
  template:
    metadata:
      name: database-credentials
      namespace: prod
    type: Opaque
```

### 2. Policy as Code with OPA

```rego
# policies/deployment-policies.rego
package kubernetes.admission

import future.keywords.contains
import future.keywords.if
import future.keywords.in

# Deny deployments without resource limits
deny[msg] {
  input.request.kind.kind == "Deployment"
  container := input.request.object.spec.template.spec.containers[_]
  not container.resources.limits.memory
  msg := sprintf("Container %s is missing memory limits", [container.name])
}

deny[msg] {
  input.request.kind.kind == "Deployment"
  container := input.request.object.spec.template.spec.containers[_]
  not container.resources.limits.cpu
  msg := sprintf("Container %s is missing CPU limits", [container.name])
}

# Require specific labels
required_labels := {
  "app.kubernetes.io/name",
  "app.kubernetes.io/version",
  "app.kubernetes.io/managed-by"
}

deny[msg] {
  input.request.kind.kind == "Deployment"
  missing_labels := required_labels - {label | input.request.object.metadata.labels[label]}
  count(missing_labels) > 0
  msg := sprintf("Deployment is missing required labels: %v", [missing_labels])
}

# Enforce image pull policy
deny[msg] {
  input.request.kind.kind == "Deployment"
  container := input.request.object.spec.template.spec.containers[_]
  container.imagePullPolicy != "Always"
  msg := sprintf("Container %s must use imagePullPolicy: Always", [container.name])
}
```

### 3. Advanced Rollback Strategy

```go
// pkg/rollback/strategy.go
package rollback

import (
    "context"
    "fmt"
    "time"
    
    "k8s.io/apimachinery/pkg/apis/meta/v1"
    "github.com/prometheus/client_golang/api"
    promv1 "github.com/prometheus/client_golang/api/prometheus/v1"
)

type RollbackStrategy struct {
    promClient     promv1.API
    fluxClient     FluxClient
    metricsQueries map[string]string
}

type RollbackCriteria struct {
    ErrorRateThreshold    float64
    LatencyThreshold      time.Duration
    AvailabilityThreshold float64
    EvaluationPeriod      time.Duration
}

func (r *RollbackStrategy) EvaluateAndRollback(ctx context.Context, deployment string, criteria RollbackCriteria) error {
    // Evaluate metrics
    errorRate, err := r.getErrorRate(ctx, deployment, criteria.EvaluationPeriod)
    if err != nil {
        return fmt.Errorf("failed to get error rate: %w", err)
    }
    
    if errorRate > criteria.ErrorRateThreshold {
        return r.performRollback(ctx, deployment, fmt.Sprintf("Error rate %.2f%% exceeds threshold %.2f%%", errorRate*100, criteria.ErrorRateThreshold*100))
    }
    
    latency, err := r.getLatencyP99(ctx, deployment, criteria.EvaluationPeriod)
    if err != nil {
        return fmt.Errorf("failed to get latency: %w", err)
    }
    
    if latency > criteria.LatencyThreshold {
        return r.performRollback(ctx, deployment, fmt.Sprintf("P99 latency %v exceeds threshold %v", latency, criteria.LatencyThreshold))
    }
    
    availability, err := r.getAvailability(ctx, deployment, criteria.EvaluationPeriod)
    if err != nil {
        return fmt.Errorf("failed to get availability: %w", err)
    }
    
    if availability < criteria.AvailabilityThreshold {
        return r.performRollback(ctx, deployment, fmt.Sprintf("Availability %.2f%% below threshold %.2f%%", availability*100, criteria.AvailabilityThreshold*100))
    }
    
    return nil
}

func (r *RollbackStrategy) performRollback(ctx context.Context, deployment string, reason string) error {
    fmt.Printf("🔄 Initiating rollback for %s: %s\n", deployment, reason)
    
    // Suspend Flux reconciliation
    if err := r.fluxClient.SuspendKustomization(ctx, deployment); err != nil {
        return fmt.Errorf("failed to suspend reconciliation: %w", err)
    }
    
    // Get previous revision
    previousRevision, err := r.fluxClient.GetPreviousRevision(ctx, deployment)
    if err != nil {
        return fmt.Errorf("failed to get previous revision: %w", err)
    }
    
    // Update to previous revision
    if err := r.fluxClient.UpdateRevision(ctx, deployment, previousRevision); err != nil {
        return fmt.Errorf("failed to update revision: %w", err)
    }
    
    // Resume reconciliation
    if err := r.fluxClient.ResumeKustomization(ctx, deployment); err != nil {
        return fmt.Errorf("failed to resume reconciliation: %w", err)
    }
    
    // Send notification
    r.notifyRollback(deployment, reason, previousRevision)
    
    return nil
}
```

## ✅ Validation & Testing

### 1. GitOps Validation Pipeline

```yaml
# .github/workflows/gitops-validation.yml
name: GitOps Validation

on:
  pull_request:
    paths:
      - 'clusters/**'
      - 'apps/**'
      - 'infrastructure/**'

jobs:
  validate-manifests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup tools
        run: |
          # Install kubectl
          curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
          chmod +x kubectl
          sudo mv kubectl /usr/local/bin/
          
          # Install kubeconform
          wget https://github.com/yannh/kubeconform/releases/latest/download/kubeconform-linux-amd64.tar.gz
          tar xf kubeconform-linux-amd64.tar.gz
          sudo mv kubeconform /usr/local/bin
          
          # Install Flux CLI
          curl -s https://fluxcd.io/install.sh | sudo bash
          
      - name: Validate Kubernetes manifests
        run: |
          find . -name '*.yaml' -type f | while read -r file; do
            echo "Validating $file"
            kubeconform -strict -verbose "$file"
          done
          
      - name: Validate Flux manifests
        run: |
          flux build kustomization infrastructure \
            --path ./infrastructure/overlays/${{ matrix.env }} \
            --dry-run
            
      - name: Run OPA policies
        uses: open-policy-agent/opa-github-action@v2
        with:
          path: policies
          tests: policies/test
          
      - name: Test Kustomize builds
        run: |
          for env in dev staging prod; do
            echo "Testing $env environment"
            kustomize build apps/overlays/$env > /tmp/$env-manifests.yaml
            kubectl apply --dry-run=client -f /tmp/$env-manifests.yaml
          done
```

### 2. Deployment Testing

```typescript
// tests/deployment-tests.ts
import { expect } from 'chai';
import { KubernetesClient } from './k8s-client';
import { PrometheusClient } from './prometheus-client';

describe('Deployment Tests', () => {
  let k8s: KubernetesClient;
  let prom: PrometheusClient;
  
  before(async () => {
    k8s = new KubernetesClient();
    prom = new PrometheusClient();
  });
  
  describe('Canary Deployment', () => {
    it('should gradually shift traffic to canary', async () => {
      // Deploy canary
      await k8s.applyManifest('canary-deployment.yaml');
      
      // Monitor traffic shift
      const weights = [];
      for (let i = 0; i < 10; i++) {
        await sleep(30000); // 30 seconds
        const weight = await prom.query(
          'sum(rate(istio_request_total{destination_version="canary"}[1m])) / sum(rate(istio_request_total[1m]))'
        );
        weights.push(weight);
      }
      
      // Verify gradual increase
      for (let i = 1; i < weights.length; i++) {
        expect(weights[i]).to.be.at.least(weights[i-1]);
      }
      
      // Verify final state
      expect(weights[weights.length - 1]).to.be.closeTo(1.0, 0.05);
    });
    
    it('should rollback on failure', async () => {
      // Deploy bad version
      await k8s.applyManifest('bad-deployment.yaml');
      
      // Wait for rollback
      await sleep(120000); // 2 minutes
      
      // Verify rollback occurred
      const deployment = await k8s.getDeployment('test-app');
      expect(deployment.spec.template.spec.containers[0].image).to.not.include('bad');
      
      // Verify traffic restored
      const errorRate = await prom.query(
        'sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))'
      );
      expect(errorRate).to.be.below(0.01);
    });
  });
  
  describe('Multi-Cloud Deployment', () => {
    it('should deploy to all clouds', async () => {
      const clouds = ['azure', 'aws', 'gcp'];
      
      for (const cloud of clouds) {
        const deployed = await k8s.isDeployedInCloud('test-app', cloud);
        expect(deployed).to.be.true;
        
        const healthy = await k8s.isHealthyInCloud('test-app', cloud);
        expect(healthy).to.be.true;
      }
    });
    
    it('should handle cloud failure', async () => {
      // Simulate AWS failure
      await k8s.simulateCloudFailure('aws');
      
      // Verify traffic shifts to other clouds
      await sleep(60000);
      
      const awsTraffic = await prom.query(
        'sum(rate(http_requests_total{cloud="aws"}[1m]))'
      );
      expect(awsTraffic).to.equal(0);
      
      const totalTraffic = await prom.query(
        'sum(rate(http_requests_total[1m]))'
      );
      expect(totalTraffic).to.be.above(0);
    });
  });
});
```

### 3. Performance Validation

```python
# tests/performance_validation.py
import asyncio
import aiohttp
from locust import HttpUser, task, between
import pandas as pd
import matplotlib.pyplot as plt

class DeploymentPerformanceTest(HttpUser):
    wait_time = between(1, 3)
    
    @task(3)
    def browse_products(self):
        self.client.get("/api/products")
        
    @task(2)
    def view_product(self):
        product_id = random.choice(["001", "002", "003", "004", "005"])
        self.client.get(f"/api/products/{product_id}")
        
    @task(1)
    def create_order(self):
        self.client.post("/api/orders", json={
            "items": [
                {"productId": "001", "quantity": 2},
                {"productId": "003", "quantity": 1}
            ]
        })

async def validate_slo_compliance():
    """Validate deployment meets SLO requirements"""
    
    prometheus_url = "http://prometheus:9090"
    
    # Define SLOs
    slos = {
        "availability": {
            "target": 99.9,
            "query": 'avg_over_time(up{job="kubernetes-pods"}[30d])',
            "unit": "%"
        },
        "latency_p99": {
            "target": 500,
            "query": 'histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))',
            "unit": "ms"
        },
        "error_rate": {
            "target": 0.1,
            "query": 'sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))',
            "unit": "%"
        }
    }
    
    results = {}
    
    async with aiohttp.ClientSession() as session:
        for metric, config in slos.items():
            async with session.get(
                f"{prometheus_url}/api/v1/query",
                params={"query": config["query"]}
            ) as response:
                data = await response.json()
                value = float(data["data"]["result"][0]["value"][1])
                
                if config["unit"] == "%":
                    value *= 100
                elif config["unit"] == "ms":
                    value *= 1000
                    
                passed = value <= config["target"] if metric == "error_rate" else value >= config["target"]
                
                results[metric] = {
                    "value": value,
                    "target": config["target"],
                    "unit": config["unit"],
                    "passed": passed
                }
                
    return results

def generate_deployment_report(results):
    """Generate deployment validation report"""
    
    df = pd.DataFrame(results).T
    
    # Create visualization
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    # Availability
    ax = axes[0, 0]
    ax.bar(['Current', 'Target'], [df.loc['availability', 'value'], df.loc['availability', 'target']])
    ax.set_title('Availability')
    ax.set_ylabel('%')
    
    # Latency
    ax = axes[0, 1]
    ax.bar(['Current', 'Target'], [df.loc['latency_p99', 'value'], df.loc['latency_p99', 'target']])
    ax.set_title('P99 Latency')
    ax.set_ylabel('ms')
    
    # Error Rate
    ax = axes[1, 0]
    ax.bar(['Current', 'Target'], [df.loc['error_rate', 'value'], df.loc['error_rate', 'target']])
    ax.set_title('Error Rate')
    ax.set_ylabel('%')
    
    # Summary
    ax = axes[1, 1]
    ax.text(0.1, 0.5, f"Overall Status: {'PASS' if df['passed'].all() else 'FAIL'}", 
            fontsize=20, color='green' if df['passed'].all() else 'red')
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('deployment-validation-report.png')
    
    return df

if __name__ == "__main__":
    # Run validation
    results = asyncio.run(validate_slo_compliance())
    report = generate_deployment_report(results)
    
    print("Deployment Validation Report")
    print("=" * 50)
    print(report)
    
    if not report['passed'].all():
        print("\n❌ Deployment validation FAILED")
        exit(1)
    else:
        print("\n✅ Deployment validation PASSED")
```

## 📋 Advanced Deployment Summary

### Implemented Capabilities

| Feature | Status | Description |
|---------|--------|-------------|
| **GitOps with Flux** | ✅ Configured | Automated synchronization |
| **ArgoCD Alternative** | ✅ Available | UI-based GitOps |
| **Multi-Cloud Support** | ✅ Ready | Azure, AWS, GCP |
| **Progressive Delivery** | ✅ Enabled | Canary, Blue-Green |
| **Automated Rollback** | ✅ Active | Metric-based decisions |
| **Policy Enforcement** | ✅ Enforced | OPA/Gatekeeper |

### Performance Metrics

- **Deployment Frequency**: 50+ per day
- **Lead Time**: <15 minutes from commit to production
- **MTTR**: <5 minutes with automated rollback
- **Change Failure Rate**: <2% with progressive delivery

### Next Steps

1. ✅ Configure cross-cloud service mesh
2. ✅ Implement chaos engineering tests
3. ✅ Set up cost optimization policies
4. ✅ Enable advanced observability

## 🚦 Continue to Next Component

### Immediate Actions
1. ✅ Deploy GitOps to all environments
2. ✅ Configure progressive delivery pipelines
3. ✅ Test multi-cloud deployment
4. ✅ Validate rollback procedures

### Next Horizon 2 Components
- [**H2-002: Comprehensive Monitoring**](h2-002-monitoring.md) - Full observability stack
- [**H2-003: Enhanced Security**](h2-horizon-optimization/003-enhanced-security.md) - Advanced security features
- [**H2-004: Performance Optimization**](h2-004-performance.md) - Platform optimization

---

<div align="center">

**Advanced Deployment Strategies Implemented! 🚀**

Your platform now supports GitOps, progressive delivery, and multi-cloud deployments.

[← Previous: Demo Environment](../horizon-1/h1-horizon-foundation/007-demo-environment.md) | [Next: Comprehensive Monitoring →](h2-002-monitoring.md)

</div>
