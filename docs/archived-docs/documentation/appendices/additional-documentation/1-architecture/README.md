---
title: "Three Horizons Architecture"
description: "Comprehensive architecture documentation for the Three Horizons Platform"
position_in_journey: "1. Architecture"
next_doc: "../../getting-started/README.md"
last_updated: "April 9, 2025"
---

# Three Horizons Platform Architecture

**Navigation:** [Home](../../../README.md) > [Documentation Map](../../DOCUMENTATION_MAP.md) > Architecture

This directory contains comprehensive architecture documentation for the Three Horizons Platform, detailing the integration between Microsoft Azure, Red Hat Developer Hub, and GitHub Enterprise.

## Architecture Overview

The Three Horizons Platform uses a multi-layer architecture designed with the following principles:

- **Modularity**: Components can be deployed and scaled independently
- **Security**: Defense-in-depth approach with multiple security layers
- **Observability**: Comprehensive monitoring and logging
- **Automation**: Infrastructure as Code and GitOps methodologies
- **Resilience**: Fault tolerance and disaster recovery capabilities

![Three Horizons Architecture Overview](overview-diagram.svg)

## Key Components

### Microsoft Azure

- **Azure Red Hat OpenShift (ARO)**: Enterprise Kubernetes platform
- **Azure Kubernetes Service (AKS)**: Alternative Kubernetes platform
- **Azure Active Directory**: Identity management
- **Azure Monitor**: Monitoring and observability
- **Azure Network Security**: Network policies and protections

### Red Hat Developer Hub

- **Developer Portal**: Central interface for developers
- **Service Catalog**: Repository of available services and resources
- **Golden Paths**: Standardized workflows for common tasks
- **Scaffolder**: Template-based project generation
- **Tech Docs**: Integrated documentation

### GitHub Enterprise

- **Source Control**: Code repository management
- **GitHub Actions**: CI/CD workflows
- **GitHub Copilot**: AI-assisted development
  - Integrated code suggestions across development environments
  - Platform-specific knowledge models for Three Horizons
  - Integration with developer workflows and templates
  - Productivity enhancements for infrastructure and application code
- **Pull Requests**: Code review and collaboration
- **GitHub Advanced Security**: Security scanning and analysis

## Developer Experience Architecture

The Three Horizons Platform places special emphasis on developer experience, incorporating:

### Developer Portals and Tools

- **Red Hat Developer Hub**: Central interface providing access to resources, services, and documentation
- **Service Catalog**: Self-service deployments of platform components
- **GitHub Copilot Integration**: AI-assisted development experience across the platform
  - **Copilot for Editors**: Intelligent code completion in VS Code, IntelliJ, and other IDEs
  - **Copilot in GitHub.com**: Suggestions directly in the web interface
  - **Copilot Chat**: Conversational AI assistance for coding questions

### Developer Workflows

The platform architecture supports key developer workflows:

1. **Project Creation**: Templated project scaffolding with built-in best practices
2. **Local Development**: Containerized development with hot reloading capabilities
3. **Testing & Validation**: Automated testing integrated with CI/CD
4. **Deployment**: Continuous deployment across environments
5. **Monitoring & Feedback**: Real-time feedback on application performance

### AI-Enhanced Development

The platform integrates artificial intelligence throughout the development lifecycle:

- **Code Generation**: GitHub Copilot suggests code based on context and comments
- **Code Review**: AI-assisted reviews highlight potential issues
- **Documentation**: Automated generation and validation of documentation
- **Testing**: Intelligent test generation based on code changes
- **Debugging**: Enhanced debugging with AI-powered suggestions

## Architecture Diagrams

This directory contains the following architectural diagrams:

- [Integration Architecture](integration-diagram.svg) - Integration between components
- [Network Architecture](network-diagram.svg) - Network topology and connectivity
- [Security Architecture](security-architecture.svg) - Security controls and integration
- [Developer Hub Architecture](developer-hub-architecture.svg) - Developer Hub components
- [Workflow Architecture](workflow-diagram.svg) - Development workflow visualization
- [Three Horizons Architecture](three-horizons-architecture.svg) - Complete platform architecture

## Implementation Considerations

When implementing the Three Horizons Platform architecture:

1. **Sizing**: Size your clusters based on expected workloads and growth projections
2. **Network Design**: Plan network topology carefully, especially for hybrid environments
3. **Identity Integration**: Configure AAD integration early in the implementation
4. **Security Controls**: Implement security at each layer of the architecture
5. **Monitoring Strategy**: Design monitoring and alerting before deployment

## Reference Architectures

The repository includes reference architectures for common scenarios:

- **Enterprise Deployment**: Large organization with multiple teams
- **Hybrid Connectivity**: On-premises to cloud integration
- **Multi-Region Setup**: Distributed architecture across regions
- **High Compliance**: Architecture for highly regulated industries

## Related Topics

- [Installation Guide](../../getting-started/installation.md) - Step-by-step installation instructions
- [GitHub Copilot Integration](../../getting-started/github-copilot-integration.md) - Optimize development with GitHub Copilot
- [Implementation Guide](../../2-implementation-guide/README.md) - Implementation guidelines and practices
- [Network Configuration](../../4-operations-guide/README.md) - Network setup and configuration

---

<footer>
  <p align="center">Last updated: April 9, 2025 | <a href="../../../.github/CONTRIBUTING.md">Contribute to this document</a></p>
</footer>
