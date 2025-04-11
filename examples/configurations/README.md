---
title: Configuration Examples
description: Ready-to-use configuration examples for Three Horizons Platform components
position_in_journey: 30
previous_doc: /docs/documentation/implementation/index.md
next_doc: /examples/applications/README.md
last_updated: 2025-04-10
---

# Three Horizons Platform - Configuration Examples

This directory contains example configurations for various components of the Three Horizons Platform. These configuration examples provide templates that you can adapt for your specific implementation needs.

## Available Configurations

### Infrastructure Configurations

- [**azure-infrastructure**](./azure-infrastructure): ARM templates and Bicep files for Azure resources
- [**aks-cluster**](./aks-cluster): Kubernetes configurations for AKS clusters

### Application Configurations

- [**api-gateway**](./api-gateway): Application Gateway configurations
- [**dev-containers**](./dev-containers): Development container configurations

### CI/CD Configurations

- [**github-actions**](./github-actions): GitHub Actions workflow templates
- [**azure-pipelines**](./azure-pipelines): Azure DevOps pipeline configurations

### Security Configurations

- [**key-vault**](./key-vault): Azure Key Vault setup and access policies
- [**policy-as-code**](./policy-as-code): Policy definitions for governance

## Using the Configurations

Each configuration example includes:

1. **README.md**: Detailed documentation about the configuration
2. **Template files**: Actual configuration files that can be adapted
3. **Parameters**: Example parameter files with explanations
4. **Validation**: Scripts to validate configurations before application

## Getting Started

To use these configurations:

1. Review the documentation in the specific configuration directory
2. Copy the relevant templates to your project
3. Customize parameters for your environment
4. Validate the configurations using provided scripts
5. Apply the configurations using appropriate tools

## Configuration Best Practices

When using and adapting these configurations, follow these best practices:

- **Parameter Management**: Store sensitive parameters in secure locations
- **Version Control**: Keep configurations in version control
- **Environment Separation**: Maintain separate parameter files for each environment
- **Documentation**: Document all customizations and configuration choices
- **Testing**: Test configurations in non-production environments first
- **Automation**: Use automation tools to apply configurations consistently

## Contributing Configurations

We encourage contributions of new configurations and improvements to existing ones. To contribute:

1. Fork the repository
2. Create your configuration in a new directory under `examples/configurations/`
3. Include comprehensive documentation
4. Ensure the configuration follows platform best practices
5. Submit a pull request

For more information on contribution guidelines, see the [Contribution Guide](../../docs/documentation/contribution/contributing.md).

## Support

If you have questions about these configurations or encounter issues:

- Open an issue in the GitHub repository
- Contact the Platform Engineering team on Teams (#platform-engineering)
- Attend the weekly office hours (Tuesdays, 10:00 AM - 12:00 PM)

## Related Resources

- [Infrastructure as Code Guide](../../docs/documentation/implementation/infrastructure-as-code.md)
- [Security Architecture](../../docs/documentation/architecture/security-architecture.svg)
- [Network Architecture](../../docs/documentation/architecture/network-diagram.svg)

# Your Configuration Journey

Welcome to your configuration journey for the Three Horizons Platform. This collection of proven configuration examples will accelerate your implementation by providing ready-to-use templates for all platform components.

## Configuration Building Blocks

These ready-to-use configurations are organized by the Three Horizons model to guide your implementation journey:

### Horizon 1: Foundation Configurations
- **AKS Configurations**: Build reliable Azure Kubernetes Service foundations
- **ARO Configurations**: Deploy enterprise-grade Azure Red Hat OpenShift platforms

### Horizon 2: Experience Configurations
- **Developer Hub Configurations**: Create intuitive developer portals with optimized workflows
- **CI/CD Configurations**: Implement production-grade delivery pipelines

### Horizon 3: Innovation Configurations
- **Advanced Policy Configurations**: Implement governance at scale
- **Feature Flag Configurations**: Enable progressive delivery patterns

## Implementing These Configurations

Apply these examples in your Three Horizons journey to accelerate your platform implementation:

1. **Understand**: Review the configuration examples to understand the structure and options
2. **Customize**: Adapt the examples to your specific organizational requirements
3. **Apply**: Implement the configurations in your environment using our provided scripts
4. **Validate**: Test the configurations to ensure proper functionality
5. **Extend**: Enhance the configurations with additional features as your maturity grows

## Configuration Resources

Navigate to these directories to find specific configuration examples:

- `/developer-hub/`: Developer experience portals and catalogs
- `/azure-kubernetes/`: Enterprise-grade AKS implementations
- `/azure-openshift/`: Production-ready ARO deployments
- `/cicd/`: GitHub Actions and pipeline configurations
- `/policies/`: Advanced policy configurations
- `/feature-flags/`: Progressive delivery patterns

## Continue Your Journey

After implementing these configurations, continue your journey with practical [Implementation Guides](/docs/documentation/guides/index.md) to bring your platform to life.
