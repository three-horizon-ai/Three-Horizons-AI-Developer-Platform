---
title: "Outer-Loop Deployment"
description: "Implementing continuous deployment workflows in the Three Horizons Platform"
position_in_journey: "4.2 Horizon 2"
previous_doc: "inner-loop-development.md"
next_doc: "golden-paths.md"
last_updated: "May 2024"
---

# Outer-Loop Deployment Guide

**Navigation**: [Home](../README.md) > [Horizon 2: Enhancement](README.md) > Outer-Loop Deployment

This guide focuses on the "outer loop" deployment processes within the Three Horizons Platform. The outer loop encompasses all activities that occur after code is committed to a shared repository, including continuous integration, testing, deployment, and release management.

## What is Outer-Loop Deployment?

![Outer Loop Diagram](../../../assets/diagrams/horizon2/outer-loop-diagram.svg)

The outer loop is the set of automated processes that move code from a developer's commit to production deployment:

1. Continuous Integration (CI)
2. Automated Testing
3. Build & Packaging
4. Deployment to Environments
5. Release Management
6. Monitoring & Feedback

An effective outer loop ensures reliable, consistent deployments while maintaining quality and security standards.

## Outer-Loop Components in the Three Horizons Platform

The Three Horizons Platform provides a comprehensive set of components for outer-loop processes:

### 1. GitHub Actions CI/CD

GitHub Actions serves as the primary workflow engine:

- Pipeline-as-code defined in repository
- Integrated with GitHub security features
- Built-in secret management
- Rich ecosystem of community actions

### 2. Container Registry

Azure Container Registry (ACR) for container image storage:

- Integrated with AKS/ARO
- Image vulnerability scanning
- Geo-replication for global deployments
- Image signing and verification

### 3. GitOps with Flux/ArgoCD

The platform uses GitOps principles for declarative deployments:

- Infrastructure and application configuration stored in Git
- Automated reconciliation between desired and actual state
- Self-healing and drift detection
- Deployment history and auditability

### 4. Environment Management

Structured promotion through multiple environments:

- Development → Testing → Staging → Production
- Consistent configuration across environments
- Environment-specific overrides
- Isolated security boundaries

## Implementing Outer-Loop Workflows

### GitHub Actions Workflow

```yaml
# .github/workflows/ci-cd.yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to Azure Container Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ secrets.ACR_REGISTRY }}
          username: ${{ secrets.ACR_USERNAME }}
          password: ${{ secrets.ACR_PASSWORD }}
      
      - name: Build and Push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ secrets.ACR_REGISTRY }}/myapp:${{ github.sha }}
  
  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Tests
        run: |
          npm install
          npm test
  
  deploy-dev:
    if: github.event_name != 'pull_request'
    needs: test
    runs-on: ubuntu-latest
    environment: development
    steps:
      - uses: actions/checkout@v3
      
      - name: Update Kubernetes Resources
        run: |
          sed -i "s/IMAGE_TAG/${{ github.sha }}/g" kubernetes/deployment.yaml
      
      - name: Commit to GitOps Repository
        uses: peter-evans/create-pull-request@v4
        with:
          token: ${{ secrets.REPO_TOKEN }}
          repository: your-org/gitops-repo
          branch: update-dev-${{ github.sha }}
          commit-message: "Update development deployment to ${{ github.sha }}"
          title: "Deploy to development"
          body: "Updates the development environment to the latest version"
```

### Deployment Configuration

```yaml
# kubernetes/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: development
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: ${{ secrets.ACR_REGISTRY }}/myapp:IMAGE_TAG
        ports:
        - containerPort: 8080
        resources:
          limits:
            cpu: "1"
            memory: "512Mi"
          requests:
            cpu: "0.5"
            memory: "256Mi"
        env:
        - name: NODE_ENV
          value: "development"
```

### GitOps Configuration

```yaml
# gitops-repo/clusters/development/myapp.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: myapp
  namespace: flux-system
spec:
  interval: 5m0s
  path: ./apps/myapp/overlays/development
  prune: true
  sourceRef:
    kind: GitRepository
    name: myapp
  validation: client
```

## Progressive Delivery Strategies

The Three Horizons Platform supports progressive delivery methods:

### Blue/Green Deployments

Deploy new version alongside existing version and switch traffic:

```yaml
# blue-green-deployment.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: myapp-rollout
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: ${{ secrets.ACR_REGISTRY }}/myapp:IMAGE_TAG
  strategy:
    blueGreen:
      activeService: myapp-active
      previewService: myapp-preview
      autoPromotionEnabled: false
```

### Canary Deployments

Gradually shift traffic to new version:

```yaml
# canary-deployment.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: myapp-rollout
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: ${{ secrets.ACR_REGISTRY }}/myapp:IMAGE_TAG
  strategy:
    canary:
      steps:
      - setWeight: 20
      - pause: {duration: 1h}
      - setWeight: 40
      - pause: {duration: 1h}
      - setWeight: 60
      - pause: {duration: 1h}
      - setWeight: 80
      - pause: {duration: 1h}
```

## Outer-Loop Best Practices

### 1. Environment Parity

Ensure consistency across environments:
- Use the same container images across all environments
- Manage environment-specific configuration separately
- Implement infrastructure as code for all environments

### 2. Automated Testing

Comprehensive testing strategy:
- Unit tests for component validation
- Integration tests for system interactions
- End-to-end tests for critical user journeys
- Performance and security testing

### 3. Security Integration

Build security into the pipeline:
- Container image scanning
- Dependency vulnerability checking
- Infrastructure-as-code security validation
- Secret scanning and management

### 4. Deployment Approvals

Implement appropriate controls:
- Automated approvals for lower environments
- Manual approvals for production
- Quality gate enforcement
- Compliance validation

## Implementation Checklist

Use this checklist to implement your outer-loop deployment process:

- [ ] CI/CD workflows configured in GitHub Actions
- [ ] Container registry integrated and secured
- [ ] GitOps implementation for all environments
- [ ] Progressive delivery strategy defined
- [ ] Testing automation across all levels
- [ ] Security scanning integrated into pipeline
- [ ] Approval workflows for production deployments
- [ ] Monitoring and alerting for deployment health

## Next Steps

After establishing your outer-loop deployment processes, explore implementing standardized developer workflows:

👉 [**Golden Paths**](golden-paths.md)

---

<footer>
  <p align="center">🔄 Last updated: May 2024 | <a href="../../../.github/CONTRIBUTING.md">Contribute to this documentation</a></p>
</footer> 