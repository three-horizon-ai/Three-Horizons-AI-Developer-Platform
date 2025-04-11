---
title: "Frequently Asked Questions"
description: "Common questions about the Three Horizons Platform"
position_in_journey: "Reference"
last_updated: "April 9, 2025"
---

# Frequently Asked Questions

**Navigation:** [Home](../../../README.md) > [Documentation Map](../../DOCUMENTATION_MAP.md) > [Reference](./index.md) > FAQ

This document addresses common questions about the Three Horizons Platform. If you can't find an answer to your question here, please check our [Troubleshooting Guide](../developer/troubleshooting.md) or [raise an issue](https://github.com/your-org/three-horizons-platform/issues).

## General Questions

### What is the Three Horizons Platform?

The Three Horizons Platform is a comprehensive developer experience ecosystem that integrates Microsoft Azure, Red Hat Developer Hub, and GitHub Enterprise to create a unified platform for developers. It streamlines the entire software development lifecycle, from code creation to deployment and operations.

### What are the key components of the platform?

The platform consists of three main technology pillars:
1. **Microsoft Azure**: Provides cloud infrastructure and services
2. **Red Hat Developer Hub**: Serves as the developer portal and experience platform
3. **GitHub Enterprise**: Handles source control and collaboration

### How does the platform improve developer productivity?

The platform improves productivity through:
- Standardized development environments
- Golden Paths that guide developers through common tasks
- GitHub Copilot integration for AI-assisted development
- Streamlined CI/CD workflows
- Unified documentation and resources

### Is the platform suitable for my organization?

The Three Horizons Platform is designed for organizations of various sizes, from small development teams to large enterprises. It's particularly valuable for organizations that:
- Use Microsoft Azure for cloud infrastructure
- Need to improve developer onboarding and productivity
- Want to implement standardized development practices
- Need to meet enterprise security and compliance requirements
- Are looking to optimize their software development lifecycle

## Installation and Setup

### What are the minimum requirements for installing the platform?

Minimum requirements include:
- Azure subscription with Contributor access
- Kubernetes cluster (AKS or ARO) with Kubernetes 1.22+
- 3+ worker nodes (Standard_D4s_v3 or equivalent)
- 30GB+ available storage
- GitHub Enterprise account or GitHub.com organization with admin access

### Can I deploy the platform in a hybrid environment?

Yes, the Three Horizons Platform supports hybrid deployment scenarios. You can deploy components across cloud and on-premises environments while maintaining a unified experience. See the [Hybrid Deployment Guide](../guides/hybrid-deployment.md) for details.

### How long does installation typically take?

A basic installation can be completed in 1-2 hours. A complete enterprise implementation with all components and customizations typically takes 1-3 days, depending on your specific requirements and environment.

### Can I customize the platform to fit my organization's needs?

Yes, the platform is highly customizable. You can:
- Select which components to implement
- Create custom golden paths for your specific workflows
- Integrate with existing tools and services
- Add custom documentation and resources
- Apply your organization's branding and standards

## GitHub Copilot Integration

### How does GitHub Copilot enhance the platform?

GitHub Copilot is integrated throughout the platform to:
- Accelerate development with AI-assisted code suggestions
- Help improve code quality and consistency
- Assist with documentation generation
- Support developers in understanding complex code and systems
- Aid in testing and troubleshooting

### How should I set up GitHub Copilot for my team?

To set up GitHub Copilot for your team:
1. Subscribe to GitHub Copilot for Business or Enterprise
2. Assign licenses to your developers
3. Install the GitHub Copilot extension in your IDEs
4. Review the [GitHub Copilot Integration Guide](../../getting-started/github-copilot-integration.md) for optimization tips

### How can developers get the most out of GitHub Copilot?

To maximize the benefits of GitHub Copilot:
- Provide detailed comments to guide Copilot's suggestions
- Review all code suggestions before accepting them
- Use Copilot for code generation and documentation
- Leverage Copilot to help understand complex codebases
- Consult our [GitHub Copilot Best Practices](../../getting-started/github-copilot-integration.md#best-practices) guide

## Development and Operations

### How does the platform support CI/CD workflows?

The platform includes:
- Pre-configured GitHub Actions workflows for common scenarios
- Integration with Azure DevOps pipelines
- Automated testing and validation workflows
- Deployment automation for Kubernetes and OpenShift
- Environment promotion workflows

### How do I integrate my existing applications?

To integrate existing applications:
1. Follow the [Application Migration Guide](../guides/application-migration.md)
2. Use our provided templates to adapt your application to the platform
3. Implement the platform's CI/CD workflows
4. Register your application in the Developer Hub service catalog

### How do I monitor applications running on the platform?

The platform includes comprehensive monitoring capabilities:
- Azure Monitor integration for resource monitoring
- Prometheus and Grafana for application metrics
- Application Insights for detailed telemetry
- Custom dashboards for specific use cases
- Alerting and notification workflows

### What security measures does the platform implement?

The platform includes multiple security layers:
- Role-based access control (RBAC)
- Network policies and segmentation
- Secret management and rotation
- Vulnerability scanning and management
- Compliance controls and reporting

## Troubleshooting

### How do I troubleshoot deployment failures?

For deployment failures:
1. Check the logs of the failing component
2. Verify Azure resource permissions
3. Ensure all prerequisites are met
4. Consult the [Troubleshooting Guide](../developer/troubleshooting.md)
5. Review the [Known Issues](../reference/known-issues.md) documentation

### What should I do if GitHub Copilot provides incorrect suggestions?

If GitHub Copilot provides incorrect suggestions:
1. Provide more detailed comments to guide Copilot
2. Reference similar code in your repository to help Copilot understand patterns
3. Review and test all code before committing
4. Report issues to the GitHub Copilot team if problems persist

### How do I resolve Kubernetes deployment issues?

For Kubernetes deployment issues:
1. Check pod status and logs
2. Verify network policies and service accounts
3. Ensure resource quotas are sufficient
4. Consult the [Kubernetes Troubleshooting Guide](../operations/kubernetes-troubleshooting.md)
5. Use the provided diagnostics scripts in `scripts/validation/`

### How can I get additional help?

If you need additional help:
1. Check the [Documentation Map](../../DOCUMENTATION_MAP.md) for relevant documentation
2. Search existing [GitHub Issues](https://github.com/your-org/three-horizons-platform/issues)
3. Create a new issue for unresolved problems
4. Reach out to your Microsoft or Red Hat representative for enterprise support

## Related Topics

- [Glossary](../../GLOSSARY.md) - Definitions of platform terminology
- [Troubleshooting Guide](../developer/troubleshooting.md) - Common issues and solutions
- [Implementation Guide](../implementation/) - Platform implementation details
- [GitHub Copilot Integration](../../getting-started/github-copilot-integration.md) - GitHub Copilot setup and optimization

---

<footer>
  <p align="center">Last updated: April 9, 2025 | <a href="../../../.github/CONTRIBUTING.md">Contribute to this document</a></p>
</footer>
