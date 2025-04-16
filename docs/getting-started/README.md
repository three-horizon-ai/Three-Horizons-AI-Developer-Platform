---
title: "Getting Started Guide"
description: "Introduction and initial setup for the Three Horizons Platform"
position_in_journey: "1. Getting Started"
next_doc: "installation.md"
last_updated: "April 10, 2025"
---

# <span style="color: #0366d6;">🚀 Getting Started with Three Horizons Platform</span>

**Navigation:** [Home](../../README.md) > [Documentation Map](../DOCUMENTATION_MAP.md) > Getting Started

![Three Horizons Platform Overview](../documentation/architecture/overview-diagram.svg)

> 🔍 **Overview Note:** This diagram illustrates the core components of the Three Horizons Platform and how they work together to create a unified developer experience.

## <span style="color: #0366d6;">🔄 Your Three Horizons Journey Begins Here</span>

Welcome to the Three Horizons Platform! This guide marks the beginning of your journey toward a modern, efficient application delivery capability. Whether you're a platform engineer setting up the infrastructure, a developer building applications, or an operations specialist managing deployments, this guide will help you take your first steps with confidence.

The Three Horizons Platform is designed to accelerate your cloud-native adoption journey by providing standardized patterns, tooling, and practices that have been proven in enterprise environments. As you progress through this documentation, you'll build a comprehensive understanding of the platform and how it can transform your organization's software delivery process.

## <span style="color: #0366d6;">📚 What's Inside</span>

This directory contains essential documentation to get you up and running:

- [Installation Guide](installation.md): Step-by-step instructions for installing the platform
- [GitHub Copilot Integration](github-copilot-integration.md): Guide for integrating GitHub Copilot with Three Horizons
- [Architecture Overview](../1-architecture/README.md): Understand the platform architecture
- [Implementation Guide](../2-implementation-guide/README.md): Guidance for implementing the platform

## <span style="color: #0366d6;">🧭 Your Learning Path</span>

We recommend following this path to get the most out of your Three Horizons journey:

1. **Understand**: First, review the [Architecture Overview](../1-architecture/README.md) to understand the platform's components and how they work together
2. **Install**: Follow the [Installation Guide](installation.md) to set up your environment with the necessary components
3. **Enhance**: Set up [GitHub Copilot Integration](github-copilot-integration.md) to boost developer productivity with AI assistance
4. **Implement**: Use the [Implementation Guide](../2-implementation-guide/README.md) to configure and customize your implementation
5. **Explore**: Examine [Example Configurations](../../examples/configurations/README.md) for reference implementations and patterns

![Learning Path Diagram](../documentation/architecture/integration-workflow.svg)

> 🧭 **Learning Journey:** This diagram illustrates the recommended path for learning and implementing the Three Horizons Platform, showing how each stage builds on the previous one.

This progressive approach ensures you build a solid foundation before moving on to more advanced topics. Each step builds on the previous, creating a comprehensive understanding of the platform's capabilities.

## <span style="color: #0366d6;">⚡ Quick Start for Experienced Users</span>

If you're experienced with Kubernetes, Azure, and GitHub and want to get started quickly:

```bash
# Clone the repository
git clone https://github.com/your-org/three-horizons-platform.git
cd three-horizons-platform

# Run the automated installer
./scripts/setup/quickstart.sh --aks --resource-group your-resource-group --location eastus
```

This quick start option will deploy a standard configuration of the Three Horizons Platform, which you can then customize based on your specific requirements.

## <span style="color: #0366d6;">💻 System Requirements</span>

Before starting your installation, ensure you have the following prerequisites:

- **Azure subscription** with Contributor access
- **Kubernetes cluster** (AKS or ARO) with:
  - Kubernetes 1.22+
  - 3+ worker nodes (Standard_D4s_v3 or equivalent)
  - 30GB+ available storage
- **GitHub account** with:
  - Organization admin access
  - Ability to create GitHub Apps

These requirements ensure you have the necessary infrastructure and permissions to successfully deploy and operate the platform.

## <span style="color: #0366d6;">🧩 Platform Components Overview</span>

The Three Horizons Platform consists of several integrated components:

1. **Developer Hub**: Central portal for developers to access documentation, templates, and tools
2. **CI/CD Pipelines**: Automated workflows for building, testing, and deploying applications
3. **GitOps Engine**: Declarative, version-controlled deployment system
4. **Template Catalog**: Pre-built application and infrastructure templates
5. **Security Controls**: Integrated security scanning and policy enforcement
6. **Monitoring & Observability**: Comprehensive monitoring and logging capabilities

![Platform Components](../documentation/architecture/three-horizons-diagram.svg)

> 🧩 **Component Architecture:** This diagram shows how the platform components are organized across the three horizons, with each component building on the foundation provided by those below it.

Each component is designed to work seamlessly together, creating a cohesive platform experience that supports your entire application lifecycle.

## <span style="color: #0366d6;">🔍 Next Steps in Your Journey</span>

After completing the getting started guides, continue your journey with these resources:

- [Developer Guide](../3-developer-guide/README.md): Learn how to build applications on the platform
- [Operations Guide](../4-operations-guide/README.md): Discover how to operate and maintain the platform
- [Implementation Guides](../documentation/guides/inner-loop-development.md): Explore specific implementation scenarios

Each guide builds on the knowledge you've gained in the getting started section, providing deeper insights into specific aspects of the platform.

## <span style="color: #0366d6;">📊 Diagram Key</span>

The diagrams in this guide use the following color coding and symbols:

| Color | Component | Description |
|-------|-----------|-------------|
| <span style="color: #0078D4;">■</span> Azure | Azure services and infrastructure | Cloud resources hosting the platform |
| <span style="color: #EE0000;">■</span> Red Hat | Developer Hub components | Developer experience and portal |
| <span style="color: #24292E;">■</span> GitHub | Source control and CI/CD | Code repositories and automation |
| <span style="color: #2188ff;">■</span> Horizon 1 | Foundation capabilities | Core platform elements |
| <span style="color: #f9c513;">■</span> Horizon 2 | Enhancement capabilities | Optimized features |
| <span style="color: #6f42c1;">■</span> Horizon 3 | Innovation capabilities | Advanced and transformative features |

> 🔍 **Note on Diagrams**: All architecture diagrams in this documentation reflect the latest Three Horizons Platform architecture as of April 2025, using a consistent styling and nomenclature.

---

<footer>
  <p align="center">Last updated: April 10, 2025 | <a href="../../.github/CONTRIBUTING.md">Contribute to this document</a></p>
</footer>