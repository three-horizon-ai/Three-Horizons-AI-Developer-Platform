# Three Horizons GitHub Copilot Instructions

This document provides guidance for GitHub Copilot integration with the Three Horizons platform, helping streamline development workflows and improve code quality.

## Table of Contents
- [Initial Setup](#initial-setup)
- [OpenShift Cluster Creation](#openshift-cluster-creation)
- [GitHub Integration](#github-integration)
- [Development Workflows](#development-workflows)
- [Monitoring and Scaling](#monitoring-and-scaling)
- [Security and Compliance](#security-and-compliance)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Initial Setup

Before using GitHub Copilot with Three Horizons, ensure you have:

1. **Azure Permissions**: 
   - Azure subscription with Contributor or Owner role
   - Access to the Azure portal
   - Permission to create resource groups and deploy resources

2. **GitHub Enterprise Cloud Integration**:
   ```bash
   # Log in to Azure
   az login

   # Create a service principal for GitHub integration
   az ad sp create-for-rbac --name "github-enterprise-integration" --role contributor \
       --scopes /subscriptions/<subscription-id> \
       --sdk-auth

   # Copy the JSON output to GitHub Secrets as AZURE_CREDENTIALS
   ```

3. **Configure Environment Variables**:
   - Add all required secrets to GitHub repository settings
   - Configure Copilot to recognize Three Horizons platform components

## OpenShift Cluster Creation

Create an Azure Red Hat OpenShift (ARO) cluster:

1. **Using Azure CLI**:
   ```bash
   # Create resource group
   az group create --name rg-threehorizons-dev --location eastus2

   # Create ARO cluster
   az aro create --resource-group rg-threehorizons-dev \
       --name aro-threehorizons \
       --vnet-name vnet-threehorizons \
       --master-subnet master-subnet \
       --worker-subnet worker-subnet
   ```

2. **Using Azure Portal**:
   - Navigate to the Azure Marketplace
   - Search for "Azure Red Hat OpenShift"
   - Follow the creation wizard, specifying:
     - Node count (minimum 3 for production)
     - Region (select based on latency requirements)
     - Resource group for organization

3. **Using Infrastructure as Code**:
   - Leverage existing templates in `deployment/arm-templates` or `deployment/bicep`
   - GitHub Copilot can help optimize these templates based on your requirements

## GitHub Integration

Set up GitHub Copilot for the Three Horizons platform:

1. **Enable GitHub Copilot**:
   - Navigate to GitHub Marketplace
   - Subscribe to GitHub Copilot
   - Install the GitHub Copilot extension in your IDE

2. **Azure DevOps Integration**:
   - Connect your GitHub repository to Azure DevOps
   - Configure service connections in Azure DevOps
   - Set up build and release pipelines

3. **GitHub Actions for CI/CD**:
   - Use the example workflows in `.github/workflows`
   - Copilot can help modify these workflows for your specific needs
   - Set up branch protection rules to enforce CI/CD checks

## Development Workflows

Use GitHub Copilot to enhance development productivity:

1. **Code Assistance**:
   - Let Copilot suggest code completions for platform-specific patterns
   - Use comments to guide Copilot for complex implementations
   - Request explanations of platform-specific code with inline comments

2. **Code Reviews**:
   - Ask Copilot to help identify potential issues in pull requests
   - Use Copilot to explain complex code changes during reviews
   - Generate comprehensive commit messages with Copilot's help

3. **Documentation**:
   - Use Copilot to generate or improve code documentation
   - Request examples of proper documentation standards
   - Ensure documentation follows Three Horizons standards

4. **Testing**:
   - Generate unit and integration tests with Copilot
   - Ask Copilot to suggest test cases based on code functionality
   - Use Copilot to optimize test coverage

## Monitoring and Scaling

Configure monitoring and scaling with Copilot's assistance:

1. **OpenShift Monitoring**:
   - Set up Prometheus and Grafana for monitoring
   - Configure alerting rules for critical metrics
   - Create custom dashboards for application-specific metrics

2. **Application Scaling**:
   - Implement horizontal pod autoscaling (HPA)
   - Configure cluster autoscaling for dynamic workloads
   - Use Copilot to optimize scaling parameters

3. **Performance Optimization**:
   - Analyze application performance with monitoring tools
   - Use Copilot to suggest performance improvements
   - Implement resource limits and requests for optimal resource usage

## Security and Compliance

Enforce security standards with GitHub Copilot:

1. **Network Policies**:
   - Implement and test network policies to restrict traffic
   - Use Copilot to generate secure network configurations
   - Validate network policy effectiveness

2. **Access Controls**:
   - Configure RBAC for Kubernetes resources
   - Implement Azure AD integration for identity management
   - Use Copilot to generate secure access control configurations

3. **Security Updates**:
   - Maintain up-to-date dependencies
   - Configure Dependabot for automated security updates
   - Use Copilot to review and implement security patches

4. **Compliance Checks**:
   - Implement policy controls with OPA/Gatekeeper
   - Configure compliance scanning in CI/CD pipelines
   - Use Copilot to generate compliance documentation

## Best Practices

Follow these best practices when using GitHub Copilot with Three Horizons:

1. **Review All Suggestions**: Always review and understand code suggested by Copilot before committing
2. **Provide Context**: Use detailed comments to guide Copilot's suggestions
3. **Reference Templates**: Point Copilot to existing templates in the repository when asking for similar code
4. **Security First**: Validate security implications of any code suggestions
5. **Iterative Refinement**: Ask Copilot to refine its suggestions until they match requirements
6. **Document Intentions**: Clearly document what you want to achieve so Copilot can provide more relevant suggestions

## Troubleshooting

Common issues and their solutions:

| Issue | Solution | 
|-------|----------|
| **Inaccurate Code Suggestions** | Provide more detailed comments and context to guide Copilot |
| **Missing Platform-Specific Knowledge** | Reference similar code in the repository to help Copilot understand patterns |
| **Security Concerns in Suggestions** | Always review code for security issues and ask Copilot to explain security implications |
| **Performance Issues** | Use Copilot to optimize resource configurations based on monitoring data |
| **Integration Failures** | Check service principal permissions and secret configurations |
