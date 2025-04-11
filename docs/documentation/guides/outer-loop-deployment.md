# Outer Loop Deployment Guide

## Overview

The Outer Loop Deployment process is a critical component of the Three Horizons Platform that handles the continuous integration and delivery of code from development to production environments. This guide explains the outer loop concepts, workflows, and best practices to ensure reliable deployments.

## What is the Outer Loop?

The Outer Loop refers to the CI/CD workflow that begins after developers push their code to the shared repository. It encompasses:

1. Continuous Integration: Building, testing, and validating code changes
2. Continuous Delivery: Automating deployments through various environments
3. Continuous Monitoring: Tracking deployment health and performance

Unlike the Inner Loop (which is developer-centric), the Outer Loop focuses on the team's collective codebase and its journey to production.

## Prerequisites

Before interacting with the Outer Loop deployment process, ensure you have:

- **Access Permissions**: Appropriate GitHub Enterprise and Azure DevOps permissions
- **Understanding of Inner Loop**: Familiarity with the [Inner Loop Development Guide](./inner-loop-development.md)
- **Required Tokens/Credentials**: Service connection details for deployments if needed
- **Environment Knowledge**: Understanding of the target environments (dev, test, stage, prod)

## Outer Loop Workflow

### 1. Code Integration

#### Pull Request Process

1. Developer creates a Pull Request (PR) in GitHub Enterprise
2. Required reviewers are automatically assigned based on CODEOWNERS
3. PR triggers initial CI validation (builds, tests, code quality)
4. After approval and successful checks, code is merged to the main branch

#### Branch Protection Rules

The Three Horizons Platform enforces these branch protection rules:

- Require minimum number of reviewers (typically 2)
- Require successful status checks before merging
- Prevent force pushes to protected branches
- Require signed commits

### 2. Continuous Integration (CI)

Upon PR creation and after merging to main, the CI pipeline performs:

#### Automated Checks

```yaml
# Example CI Pipeline checks
stages:
  - build
  - test
  - validate

build:
  script:
    - npm ci
    - npm run build

unit-tests:
  script:
    - npm test

integration-tests:
  script:
    - npm run test:integration

code-quality:
  script:
    - npm run lint
    - npm run security-scan
    - npm run sonar-analysis
```

#### Artifact Generation

Successful CI builds create versioned artifacts:

- Container images published to Azure Container Registry
- Application packages stored in Azure Artifacts
- Infrastructure templates validated and prepared

### 3. Continuous Delivery (CD)

#### Environment Promotion

The Three Horizons Platform uses a progressive deployment model through environments:

1. **Development**: Automatic deployment after successful CI
2. **Testing/QA**: Scheduled or manual promotion
3. **Staging**: Manual promotion with approval gates
4. **Production**: Manual promotion with strict approval gates

#### Deployment Strategies

Different strategies are used depending on the environment and application type:

- **Blue/Green Deployment**: For zero-downtime updates
- **Canary Releases**: For gradual rollout with health monitoring
- **Feature Flags**: For controlled feature enablement

Example deployment command:

```bash
# Using Azure DevOps CLI for a manual promotion
az pipelines run --name "Deploy-To-Stage" --branch main --parameters environment=staging version=$(Build.BuildNumber)
```

### 4. Deployment Verification Tests (DVTs)

After deployment, automated tests verify the environment health:

- Smoke tests to ensure basic functionality
- Endpoint availability checks
- Integration point validation
- Performance benchmark tests

### 5. Rollback Procedures

If issues are detected post-deployment:

```bash
# Example rollback command
az pipelines run --name "Rollback-Deployment" --branch main --parameters environment=staging version=$(LastStableVersion)
```

Rollbacks are automatically triggered if health checks fail, or can be manually initiated.

## GitOps and Infrastructure as Code

The Three Horizons Platform leverages GitOps principles for infrastructure and deployment:

### Infrastructure Templates

- Azure Resource Manager (ARM) templates or Bicep files
- Terraform configurations
- Kubernetes manifests

### Configuration Management

- Environment-specific configurations in Azure Key Vault
- Configuration as Code with versioning
- Secrets management with tight access controls

## Monitoring and Observability

The Outer Loop includes comprehensive monitoring:

### Deployment Metrics

- Deployment frequency
- Lead time for changes
- Change failure rate
- Mean time to restore (MTTR)

### Application Monitoring

- Azure Application Insights integration
- Log Analytics for centralized logging
- Custom dashboards for service health

## Security and Compliance

Security is integrated throughout the deployment pipeline:

- Container image scanning
- Dependency vulnerability checking
- Compliance verification against regulatory standards
- Security testing automation

## Best Practices

- **Environment Parity**: Keep environments as similar as possible
- **Immutable Artifacts**: Deploy the same artifacts across environments
- **Infrastructure as Code**: Never make manual infrastructure changes
- **Automated Testing**: Invest in comprehensive test suites
- **Feature Flags**: Use flags to control feature enablement
- **Monitoring**: Implement thorough monitoring and alerting
- **Documentation**: Keep deployment documentation updated

## Troubleshooting

### Common Issues and Solutions

#### Failed Deployments

- Check pipeline logs for specific errors
- Verify service dependencies are available
- Ensure configuration values are correct for the environment

#### Performance Problems

- Review application insights for bottlenecks
- Check resource allocation in Azure
- Verify network configurations

#### Security Alerts

- Investigate vulnerability reports
- Update dependencies if security issues are detected
- Review access controls if unauthorized access is suspected

## Support

For issues related to Outer Loop deployments:

- **Chat**: #deployment-support channel in Teams
- **On-call Support**: Platform engineering team rotation
- **Escalation Path**: See [Escalation Process](../operations/escalation-process.md)

## Related Documentation

- [Inner Loop Development Guide](./inner-loop-development.md)
- [Golden Paths Guide](./golden-paths.md)
- [Infrastructure as Code Guide](../implementation/infrastructure-as-code.md)
- [Monitoring Strategy](../operations/monitoring.md) 