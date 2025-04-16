---
title: "Developer Guide"
description: "Comprehensive guide for developers working with the Three Horizons Platform"
position_in_journey: "3. Development"
previous_doc: "../2-implementation-guide/README.md"
next_doc: "../4-operations-guide/README.md"
last_updated: "April 10, 2025"
---

# <span style="color: #0366d6;">👨‍💻 Developer Guide</span>

**Navigation:** [Home](../../README.md) > [Documentation Map](../DOCUMENTATION_MAP.md) > Developer Guide

![Developer Experience Overview](../documentation/architecture/workflow-diagram.svg)

> 🔍 **Developer Experience:** This diagram illustrates the developer experience within the Three Horizons Platform, showing how developers interact with the platform to build, test, and deploy applications.

Welcome to the Developer Guide for the Three Horizons Platform. This guide is designed to help developers understand how to effectively use the platform to build, test, and deploy applications.

## <span style="color: #0366d6;">📚 Core Developer Documentation</span>

The following guides provide comprehensive documentation for developers working on the Three Horizons Platform:

- [Inner Loop Development Guide](../documentation/guides/inner-loop-development.md) - Local development workflows and best practices
- [Outer Loop Deployment Guide](../documentation/guides/outer-loop-deployment.md) - CI/CD and deployment workflows
- [Golden Paths Guide](../documentation/guides/golden-paths.md) - Standardized application development templates

## <span style="color: #0366d6;">🧭 Getting Started as a Developer</span>

If you're new to the Three Horizons Platform, start here to quickly become productive:

### <span style="color: #0366d6;">Environment Setup</span>

Before you begin working with the Three Horizons Platform, ensure your development environment is properly configured:

1. **IDE Setup**: Install Visual Studio Code or JetBrains IDE with the following extensions:
   - GitHub Copilot
   - Git Integration
   - Kubernetes Tools
   - Remote Development

2. **CLI Tools**: Install these command-line tools:
   - Azure CLI
   - GitHub CLI
   - Kubernetes CLI (kubectl)
   - Helm
   - DevHub CLI

3. **Authentication**: Configure authentication for:
   - Azure using `az login`
   - GitHub using `gh auth login`
   - Kubernetes/OpenShift cluster

For detailed setup instructions, refer to the [Environment Setup Guide](../getting-started/README.md).

### <span style="color: #0366d6;">First Application</span>

Follow these steps to create your first application on the Three Horizons Platform:

1. Access the Developer Hub at `https://devhub.yourdomain.com`
2. Navigate to the **Create** section
3. Select an appropriate Golden Path template for your application type
4. Fill in the required information and create your application
5. Clone the repository to your local environment
6. Follow the README instructions to start development

## <span style="color: #0366d6;">🔄 Development Workflow</span>

The Three Horizons Platform supports a modern development workflow divided into two main phases:

![Development Workflow](../documentation/architecture/integration-workflow.svg)

> 🔄 **Workflow Overview:** This diagram shows the complete development workflow from inner loop development through to production deployment, highlighting the role of each component in the process.

### <span style="color: #0366d6;">Inner Loop Development</span>

The Inner Loop represents the development workflow that happens on your local machine:

1. **Write Code**: Develop features and fix bugs
2. **Build**: Compile and package your application
3. **Run**: Execute your application locally
4. **Test**: Validate functionality with automated tests
5. **Debug**: Identify and fix issues

For detailed guidance on optimizing your Inner Loop development process, see the [Inner Loop Development Guide](../documentation/guides/inner-loop-development.md).

### <span style="color: #0366d6;">Outer Loop Deployment</span>

The Outer Loop handles the CI/CD process that begins after you push your code:

1. **Continuous Integration**: Automated building and testing
2. **Validation**: Code quality checks and security scanning
3. **Deployment**: Automated deployment to various environments
4. **Monitoring**: Tracking application performance and health

For complete information on the Outer Loop process, refer to the [Outer Loop Deployment Guide](../documentation/guides/outer-loop-deployment.md).

## <span style="color: #0366d6;">🤖 GitHub Copilot Integration</span>

The Three Horizons Platform includes AI-assisted development through GitHub Copilot:

- **Code Completion**: Get intelligent code suggestions as you type
- **Function Generation**: Generate complete functions based on comments
- **Bug Finding**: Identify potential issues before they cause problems
- **Documentation**: Generate documentation for your code

To make the most of GitHub Copilot in your development workflow, follow these best practices:

1. Write clear comments describing your intent
2. Use GitHub Copilot Chat for complex queries
3. Review suggestions carefully before accepting them
4. Provide feedback to help Copilot learn your preferences

## <span style="color: #0366d6;">🛣️ Golden Paths</span>

Golden Paths provide standardized, well-supported workflows for common development scenarios:

![Golden Paths Overview](../documentation/architecture/web-application-standard.svg)

> 🛣️ **Golden Paths:** These templated application patterns provide standardized, well-supported workflows that accelerate development while ensuring best practices.

- **Web Application Path**: For building web frontends and backends
- **Microservice Path**: For building backend services and APIs
- **Data Processing Path**: For data-intensive applications
- **DevOps Extension Path**: For building platform and automation tools

For detailed information on available Golden Paths and how to use them, see the [Golden Paths Guide](../documentation/guides/golden-paths.md).

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
