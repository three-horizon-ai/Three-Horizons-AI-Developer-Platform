---
title: "GitHub Actions Examples"
description: "Comprehensive examples of GitHub Actions workflows for the Three Horizons Platform"
position_in_journey: "4.2 CI/CD Implementation"
previous_doc: "../../documentation/guides/ci-cd-integration.md"
next_doc: "../logic-apps/README.md"
last_updated: "April 10, 2025"
---

# GitHub Actions Examples

**Navigation:** [Home](../../../README.md) > [Documentation Map](../../DOCUMENTATION_MAP.md) > [Examples](../README.md) > GitHub Actions Examples

## Your CI/CD Journey

Implementing continuous integration and continuous deployment (CI/CD) is a critical part of the Three Horizons Platform. This collection of GitHub Actions examples provides ready-to-use templates that accelerate your CI/CD implementation journey.

Each example is designed to address specific scenarios you'll encounter while implementing the platform, from basic builds to complex deployment patterns across different environments.

## Overview

These examples demonstrate proven patterns for implementing CI/CD pipelines using GitHub Actions within the Three Horizons Platform. Each example includes complete workflow definitions, explanations, and customization guidance.

## Prerequisites

Before using these GitHub Actions examples:

- Ensure you have a GitHub repository set up for your application
- Configure necessary secrets in your GitHub repository settings
- Set up appropriate permissions for GitHub Actions in your organization
- Review the [CI/CD Integration Guide](../../documentation/guides/ci-cd-integration.md)

## Example Workflows

| Example | Description | Use Case |
|---------|-------------|----------|
| [Web App CI Pipeline](web-app-ci.md) | Basic CI workflow for web applications | Frontend applications |
| [Container Build and Push](container-build-push.md) | Build and push container images to registry | Containerized applications |
| [Multi-Environment Deployment](multi-env-deployment.md) | Progressive deployment across environments | Production applications |
| [Infrastructure Deployment](infra-deployment.md) | Infrastructure as Code deployment | Platform infrastructure |
| [Security Scanning](security-scanning.md) | Security vulnerability scanning | All applications |

## Implementation Path

Follow this recommended sequence when implementing GitHub Actions:

1. Start with the basic **Web App CI Pipeline** to validate your application builds
2. Add **Security Scanning** to ensure code quality and security
3. Implement **Container Build and Push** for containerization
4. Set up **Multi-Environment Deployment** for production readiness
5. Incorporate **Infrastructure Deployment** for complete automation

This progressive approach allows you to build confidence and expertise with each step.

## Example Usage

Each workflow example includes:

1. Complete YAML definition
2. Step-by-step explanation
3. Customization guidance
4. Best practices
5. Security considerations

To use an example:

1. Navigate to the specific example file
2. Copy the YAML definition to your repository's `.github/workflows/` directory
3. Customize the workflow for your specific requirements
4. Commit and push to test the workflow

## Integration with Other Tools

These GitHub Actions examples integrate with other Three Horizons Platform components:

- Azure resources for deployment targets
- Container registries for image storage
- Kubernetes clusters for application hosting
- Developer Hub for workflow visibility

## Related Resources

- [GitHub Workflow Documentation](../../GITHUB_WORKFLOWS_DOCUMENTATION.md)
- [CI/CD Integration Guide](../../documentation/guides/ci-cd-integration.md)
- [Security Policies](../../documentation/guides/security-policies.md)
- [GitHub Copilot Integration](../../getting-started/github-copilot-integration.md)

---

<footer>
  <p align="center">Last updated: April 10, 2025 | <a href="../../../.github/CONTRIBUTING.md">Contribute to this document</a></p>
</footer>
