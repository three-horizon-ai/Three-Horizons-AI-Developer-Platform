---
title: Outer Loop Deployment Guide
description: CI/CD pipelines and deployment workflows for the Three Horizons Platform
position_in_journey: 16
previous_doc: /docs/3-developer-guide/inner-loop-development.md
next_doc: /docs/3-developer-guide/golden-paths.md
last_updated: 2025-04-10
---

# Outer Loop Deployment Guide

This guide explains the continuous integration and delivery processes in the Three Horizons Platform. The outer loop refers to the automated workflows that occur after code is pushed to a shared repository, including building, testing, and deploying applications across environments.

## Table of Contents

- [Introduction to Outer Loop Development](#introduction-to-outer-loop-development)
- [CI/CD Pipeline Overview](#cicd-pipeline-overview)
- [GitHub Actions Workflows](#github-actions-workflows)
- [Deployment Environments](#deployment-environments)
- [Securing Your Deployment Pipeline](#securing-your-deployment-pipeline)
- [Monitoring Deployments](#monitoring-deployments)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Introduction to Outer Loop Development

The outer development loop encompasses all activities that occur after a developer commits code:

1. Code integration
2. Automated testing
3. Security scanning
4. Building deployment artifacts
5. Deployment to environments
6. Release management

The Three Horizons Platform standardizes these processes to ensure consistent, secure, and auditable deployments.

## CI/CD Pipeline Overview

Our CI/CD pipeline is built using GitHub Actions with integrations to Azure and Red Hat services. The standard pipeline includes:

![Workflow Diagram](../documentation/architecture/workflow-diagram.svg)

### Pipeline Stages

1. **Continuous Integration**
   - Triggered on PR creation and commits
   - Builds application
   - Runs unit and integration tests
   - Performs code quality and security scans
   - Updates PR with results

2. **Continuous Deployment**
   - Triggered on merge to main branch
   - Builds production-ready artifacts
   - Deploys to progression of environments
   - Runs automated validations
   - Promotes or rolls back based on health checks

## GitHub Actions Workflows

The Three Horizons Platform provides standardized GitHub Actions workflows for different application types:

### Standard Workflow Files

| Workflow | Purpose | Trigger |
|----------|---------|---------|
| `ci.yml` | Build and test code | PR events, pushes to feature branches |
| `cd.yml` | Deploy to environments | Pushes to main branch, manual dispatch |
| `security-scan.yml` | Security vulnerability scanning | Scheduled, PR events |
| `compliance.yml` | Policy and compliance checks | PR events, scheduled |

### Example CI Workflow

```yaml
name: CI Pipeline

on:
  pull_request:
    branches: [ main, develop ]
  push:
    branches: [ feature/*, bugfix/* ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up build environment
        uses: ./.github/actions/setup-build-env
      - name: Build application
        run: npm ci && npm run build
      - name: Run tests
        run: npm test
      - name: Run linting
        run: npm run lint
```

## Deployment Environments

The Three Horizons Platform defines a standard progression of environments:

### Environment Structure

1. **Development**
   - Purpose: Integration testing
   - Deployment: Automatic on PR merge
   - Data: Non-sensitive test data

2. **Staging/QA**
   - Purpose: Pre-production validation
   - Deployment: Automatic or manual approval
   - Data: Anonymized production-like data

3. **Production**
   - Purpose: Live system
   - Deployment: Manual approval required
   - Data: Production data with full security controls

### Environment Configuration

Environment-specific configurations are managed using:

1. **Azure Key Vault** for secrets
2. **GitHub Environment Secrets** for CI/CD parameters
3. **Kubernetes ConfigMaps** for non-sensitive configuration

## Securing Your Deployment Pipeline

The Three Horizons Platform incorporates security throughout the deployment process:

1. **Supply Chain Security**
   - Dependency scanning
   - SBOM (Software Bill of Materials) generation
   - Image signing and verification

2. **Infrastructure as Code Security**
   - Template validation
   - Policy compliance checking
   - Drift detection

3. **Deployment Safeguards**
   - Required approvals for production
   - Deployment rate limiting
   - Automated rollback on failure

## Monitoring Deployments

### Deployment Health Metrics

Monitor key metrics during and after deployments:

- Application availability
- Error rates
- Response times
- Deployment duration
- Rollback frequency

### Integration with Azure Monitor

Deployments are automatically tagged in Azure Monitor to correlate deployments with operational metrics:

```
deployment_id: ${GITHUB_RUN_ID}
commit_sha: ${GITHUB_SHA}
version: ${APP_VERSION}
```

## Best Practices

### Deployment Strategy

- Use immutable infrastructure patterns
- Implement progressive deployment techniques (blue/green, canary)
- Automate rollbacks based on health metrics
- Keep deployment units small and focused

### Pipeline Efficiency

- Cache dependencies between workflow runs
- Parallelize independent test suites
- Use matrix builds for multi-platform testing
- Implement test splitting for large test suites

### Compliance and Governance

- Maintain deployment audit trails
- Enforce approval workflows for sensitive environments
- Implement compliance scanning in pipelines
- Automate security policy enforcement

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Pipeline failures | Check workflow logs in GitHub Actions |
| Deployment rejections | Verify compliance with security policies |
| Environment connectivity | Check network security groups and firewall rules |
| Configuration issues | Verify environment variables and secrets |

### Rollback Procedure

In case of failed deployments:

1. Identify the failure in monitoring dashboards
2. Run the rollback workflow:
   ```bash
   gh workflow run rollback.yml -f version=<previous-version>
   ```
3. Verify system health after rollback

## Next Steps

After understanding the deployment processes, explore the [Golden Paths Guide](golden-paths.md) to learn about standardized workflows for different application types.

---

<footer>
  <p align="center">🔄 Last updated: April 10, 2025 | Contribute to this document through <a href="../../.github/CONTRIBUTING.md">Pull Requests</a></p>
</footer> 