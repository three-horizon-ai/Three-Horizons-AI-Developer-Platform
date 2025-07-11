# 📚 Three Horizons Platform - Guides

Welcome to the comprehensive guide collection for the Three Horizons Platform. These guides provide detailed instructions for implementing, operating, and optimizing your platform deployment.

## 🗂️ Guide Categories

### 🚀 Deployment Guides

#### [Developer Hub on AKS Guide](./devhub-aks-guide.md)
Complete guide for deploying Red Hat Developer Hub on Azure Kubernetes Service (AKS). This guide covers:
- Infrastructure provisioning with Terraform
- AKS cluster deployment and configuration
- Red Hat Developer Hub installation
- GitHub integration setup
- Monitoring and security configuration

#### [Developer Hub on ARO Guide](./devhub-aro-guide.md)
Comprehensive guide for deploying Red Hat Developer Hub on Azure Red Hat OpenShift (ARO). This guide includes:
- ARO cluster provisioning
- OpenShift-specific configurations
- Developer Hub deployment on OpenShift
- Integration with OpenShift security features
- GitOps implementation with OpenShift

### 🔄 Zone-Based Architecture Guides

The Three Horizons Platform is organized into four operational zones:

#### [Development Zone - Inner Loop](./inner-loop-development.md)
Local development workflows and best practices:
- Local development environment setup
- Integration with Developer Hub templates
- Testing and debugging strategies
- Code quality tools and practices
- Pre-commit hooks and validation

#### [Integration Zone - CI/CD Pipeline](./integration-zone-cicd.md)
Comprehensive CI/CD implementation guide:
- GitHub Actions configuration
- Azure DevOps integration
- GitOps with Flux/ArgoCD
- Security scanning and quality gates
- Progressive delivery strategies
- DORA metrics collection

#### [Runtime Zone - Outer Loop](./outer-loop-deployment.md)
Production deployment and runtime management:
- Continuous deployment workflows
- Environment promotion strategies
- Deployment verification tests
- Rollback procedures
- Blue/Green and Canary deployments

#### [Operations Zone - Monitoring](./operations-zone-monitoring.md)
Complete monitoring and observability setup:
- Prometheus/Grafana stack deployment
- Datadog multi-cloud monitoring
- Azure Monitor integration
- SLO/SLI configuration
- Alerting and incident management
- APM and distributed tracing

### 📖 Development Guides

#### [Golden Paths Guide](./golden-paths.md)
Standardized development workflows and templates:
- Understanding Golden Paths concept
- Available templates and their use cases
- Creating custom Golden Path templates
- Best practices for template development
- Template governance and versioning

#### [Developer Guide](./developer-guide.md)
Comprehensive guide for developers using the Three Horizons Platform:
- Getting started with the platform
- Using Developer Hub effectively
- Integrating with platform services
- Development best practices
- Common development patterns

### 🛠️ Troubleshooting

#### [ARO Troubleshooting Guide](./troubleshooting.md)
Specific troubleshooting for Azure Red Hat OpenShift deployments:
- Common ARO issues and solutions
- Network troubleshooting
- Developer Hub on ARO issues
- Performance optimization

#### [Complete Integration Troubleshooting & FAQ](../complete-integration-tutorial/troubleshooting-faq.md)
Comprehensive troubleshooting for the entire platform:
- Common error messages and solutions
- Infrastructure troubleshooting
- CI/CD pipeline issues
- Monitoring problems
- Performance optimization
- Frequently asked questions

## 🚦 Getting Started

If you're new to the Three Horizons Platform, we recommend following this path:

1. Start with the [Complete Integration Tutorial](../complete-integration-tutorial/index.md)
2. Choose your deployment path:
   - [AKS Deployment](./devhub-aks-guide.md) for Kubernetes-native approach
   - [ARO Deployment](./devhub-aro-guide.md) for OpenShift platform
3. Set up your development workflow:
   - [Inner Loop Development](./inner-loop-development.md)
   - [Golden Paths](./golden-paths.md)
4. Configure CI/CD:
   - [Integration Zone Guide](./integration-zone-cicd.md)
   - [Outer Loop Deployment](./outer-loop-deployment.md)
5. Set up monitoring:
   - [Operations Zone Guide](./operations-zone-monitoring.md)

## 📊 Architecture Overview

The Three Horizons Platform follows a zone-based architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                    Three Horizons Platform                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐                 │
│  │ Development Zone│  │ Integration Zone │                 │
│  │   (Inner Loop)  │  │    (CI/CD)      │                 │
│  └────────┬────────┘  └────────┬────────┘                 │
│           │                     │                           │
│  ┌────────▼────────┐  ┌────────▼────────┐                 │
│  │  Runtime Zone   │  │ Operations Zone  │                 │
│  │  (Outer Loop)   │  │  (Monitoring)    │                 │
│  └─────────────────┘  └─────────────────┘                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Version Compatibility

| Component | Version | Notes |
|-----------|---------|-------|
| Red Hat Developer Hub | 1.6+ | Required for all features |
| Azure Kubernetes Service | 1.28+ | Latest stable version recommended |
| Azure Red Hat OpenShift | 4.14+ | ARO deployment option |
| GitHub Enterprise | Latest | GitHub.com also supported |
| Prometheus | 2.45+ | For monitoring stack |
| Grafana | 10.0+ | For visualization |
| Datadog Agent | 7.45+ | For multi-cloud monitoring |

## 📝 Contributing

We welcome contributions to improve these guides! Please:

1. Fork the repository
2. Create a feature branch
3. Make your improvements
4. Submit a pull request

See our [Contributing Guide](../../.github/CONTRIBUTING.md) for detailed instructions.

## 📞 Support

If you encounter issues:

1. Check the [Troubleshooting Guide](./troubleshooting.md)
2. Review the [FAQ](../complete-integration-tutorial/troubleshooting-faq.md)
3. Open an issue in the GitHub repository
4. Contact platform support

---

<footer>
  <p align="center">🔄 Last updated: June 2025 | Platform Version: 1.6</p>
</footer> 