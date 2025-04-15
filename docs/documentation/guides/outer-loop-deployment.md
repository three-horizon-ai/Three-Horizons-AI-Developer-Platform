# <span style="color: #0366d6;">🚀 Outer Loop Deployment Guide</span>

## <span style="color: #0366d6;">🔄 Overview</span>

The Outer Loop Deployment process is a critical component of the Three Horizons Platform that handles the continuous integration and delivery of code from development to production environments. This guide explains the outer loop concepts, workflows, and best practices to ensure reliable deployments.

![Outer Loop Deployment Workflow](../architecture/integration-workflow.svg)

> 🔍 **Architecture Note:** The diagram above illustrates the complete Outer Loop deployment workflow, showing how code moves from development through testing, staging, and into production environments.

## <span style="color: #0366d6;">🤔 What is the Outer Loop?</span>

The Outer Loop refers to the CI/CD workflow that begins after developers push their code to the shared repository. It encompasses:

1. Continuous Integration: Building, testing, and validating code changes
2. Continuous Delivery: Automating deployments through various environments
3. Continuous Monitoring: Tracking deployment health and performance

Unlike the Inner Loop (which is developer-centric), the Outer Loop focuses on the team's collective codebase and its journey to production.

## <span style="color: #0366d6;">📋 Prerequisites</span>

Before interacting with the Outer Loop deployment process, ensure you have:

- **Access Permissions**: Appropriate GitHub Enterprise and Azure DevOps permissions
- **Understanding of Inner Loop**: Familiarity with the [Inner Loop Development Guide](./inner-loop-development.md)
- **Required Tokens/Credentials**: Service connection details for deployments if needed
- **Environment Knowledge**: Understanding of the target environments (dev, test, stage, prod)

## <span style="color: #0366d6;">🔄 Outer Loop Workflow</span>

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

## <span style="color: #0366d6;">🔄 GitOps and Infrastructure as Code</span>

The Three Horizons Platform leverages GitOps principles for infrastructure and deployment:

![GitOps Workflow for Infrastructure](../architecture/cicd-pipeline.svg)

> 🔄 **GitOps Principle:** Infrastructure changes follow the same workflow as application code, with Git as the single source of truth and automated deployments triggered by commits.

### Infrastructure Templates

- Azure Resource Manager (ARM) templates or Bicep files
- Terraform configurations
- Kubernetes manifests

### Configuration Management

- Environment-specific configurations in Azure Key Vault
- Configuration as Code with versioning
- Secrets management with tight access controls

## <span style="color: #0366d6;">📊 Monitoring and Observability</span>

The Outer Loop includes comprehensive monitoring:

![Monitoring and Observability](../architecture/overview-diagram.svg)

> 📈 **Monitoring Architecture:** This diagram shows how monitoring and observability components integrate with the deployment pipeline to provide real-time insights into application health and performance.

### Deployment Metrics

- Deployment frequency
- Lead time for changes
- Change failure rate
- Mean time to restore (MTTR)

### Application Monitoring

- Azure Application Insights integration
- Log Analytics for centralized logging
- Custom dashboards for service health

## <span style="color: #0366d6;">🔒 Security and Compliance</span>

Security is integrated throughout the deployment pipeline:

- Container image scanning
- Dependency vulnerability checking
- Compliance verification against regulatory standards
- Security testing automation

## <span style="color: #0366d6;">✅ Best Practices</span>

- **Environment Parity**: Keep environments as similar as possible
- **Immutable Artifacts**: Deploy the same artifacts across environments
- **Infrastructure as Code**: Never make manual infrastructure changes
- **Automated Testing**: Invest in comprehensive test suites
- **Feature Flags**: Use flags to control feature enablement
- **Monitoring**: Implement thorough monitoring and alerting
- **Documentation**: Keep deployment documentation updated

## <span style="color: #0366d6;">🛠️ Troubleshooting</span>

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

## <span style="color: #0366d6;">📚 Related Documentation</span>

- [Inner Loop Development Guide](./inner-loop-development.md)
- [Golden Paths Guide](./golden-paths.md)
- [Continuous Integration Strategies](../implementation/continuous-integration.md)
- [Deployment Strategy](../implementation/deployment-strategy.md) 

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