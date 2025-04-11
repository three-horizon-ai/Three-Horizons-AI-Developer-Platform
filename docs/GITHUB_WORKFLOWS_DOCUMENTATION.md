---
title: GitHub Workflows Documentation
description: Detailed guide to using GitHub Actions workflows in the Three Horizons Platform
position_in_journey: 35
previous_doc: /docs/DOCUMENTATION_MAP.md
next_doc: /docs/GLOSSARY.md
last_updated: 2025-04-10
---

# GitHub Workflows Documentation

Welcome to your GitHub Actions journey with the Three Horizons Platform. This document guides you through the workflows that automate and streamline your implementation experience.

## Your Automation Journey

As you progress through your Three Horizons implementation, you'll leverage these powerful GitHub Actions workflows to automate critical tasks:

1. **Create Implementation Checklist** - Track your implementation progress with interactive checklists
2. **Documentation Check** - Ensure your documentation remains accurate and high-quality
3. **Security Scan** - Protect your platform with automated security scanning
4. **CI/CD Pipeline Examples** - Accelerate delivery with proven CI/CD patterns

## Create Implementation Checklist

The "Create Implementation Checklist" workflow helps teams track their implementation progress by generating standardized checklists as GitHub issues.

### Usage

1. Navigate to the **Actions** tab in your repository
2. Click on **Create Implementation Checklist** from the list of workflows
3. Click on **Run workflow**
4. In the form:
   - Select the type of implementation (AKS, ARO, or DevHub)
   - Enter a title for the issue
5. Click **Run workflow**

The workflow will create a new issue with an interactive checklist that team members can use to track implementation progress.

### Workflow Details

The workflow is defined in `.github/workflows/create-checklist.yml` and performs the following steps:

1. Checks out the repository code
2. Creates a new GitHub issue using the appropriate checklist template based on the selected implementation type
3. Adds relevant labels to the issue for filtering and organization

### Available Checklists

- **Azure Kubernetes Service (AKS)** - For AKS-based implementations
- **Azure Red Hat OpenShift (ARO)** - For ARO-based implementations
- **Developer Hub** - For standalone Developer Hub implementations

### Customizing Checklists

To create additional checklists or modify existing ones:

1. Create a new template in `.github/checklist-templates/`
2. Follow the format of the existing templates
3. Update the workflow file to include your new checklist type

## Documentation Check

The "Documentation Check" workflow ensures the quality and integrity of documentation throughout the repository.

### Features

- **Link Validation** - Checks for broken links in all Markdown files
- **Language Check** - Verifies adherence to language guidelines
- **SVG Validation** - Ensures SVG files follow the established standards

### Workflow Details

The workflow is defined in `.github/workflows/documentation-check.yml` and runs:

1. On push or pull request to the main branch when documentation files change
2. When manually triggered

The workflow generates reports that are available as artifacts in the GitHub Actions interface.

## Security Scan

The "Security Scan" workflow performs comprehensive security scans of the codebase.

### Features

- **Dependency Scanning** - Checks for vulnerabilities in npm packages
- **Code Analysis** - Uses CodeQL to detect security issues in the code
- **Compliance Checks** - Ensures adherence to security best practices

### Workflow Details

The workflow is defined in `.github/workflows/security-scan.yml` and runs:

1. On push to the main branch
2. On pull requests to the main branch
3. Weekly on a schedule
4. When manually triggered

## CI/CD Pipeline Examples

The repository includes example CI/CD workflows in the `examples/pipelines/github-actions/` directory:

### Web Application CI Pipeline

The sample CI pipeline for web applications (`examples/pipelines/github-actions/web-app/ci.yml`) includes:

1. **Linting**: Checks code style and quality
2. **Testing**: Runs unit tests with coverage reporting
3. **Building**: Builds the application
4. **Security Scanning**: Checks for vulnerabilities
5. **Preview Deployment**: Deploys a preview environment for pull requests

### Continuous Deployment Workflows

For deployments to staging and production environments, see:

- `examples/pipelines/github-actions/web-app/cd-staging.yml`
- `examples/pipelines/github-actions/web-app/cd-production.yml`

These workflows handle automated deployments with approval gates for production.

### Security Scanning Example

The security scanning workflow (`examples/pipelines/github-actions/web-app/security-scan.yml`) provides:

1. Dependency vulnerability scanning using Snyk
2. Static Application Security Testing (SAST) with CodeQL
3. Container image scanning
4. Security reports

## Implementing Workflows

To implement these workflows in your project:

1. Copy the relevant workflow files to your `.github/workflows/` directory
2. Customize the workflows for your application's specific needs
3. Configure required secrets in your repository settings:
   - `AZURE_CREDENTIALS`: Azure service principal credentials
   - `SNYK_TOKEN`: API token for Snyk vulnerability scanning
   - Other deployment-specific secrets

## Best Practices

1. Enable branch protection rules for main and production branches
2. Require status checks to pass before merging
3. Use environments for deployment approvals
4. Store sensitive information in GitHub Secrets
5. Use workflow matrices to test across multiple configurations
6. Leverage caching to speed up builds
7. Set reasonable timeout limits for workflow steps

## Troubleshooting

If you encounter issues with the workflows:

1. Check the workflow runs in the Actions tab for detailed logs
2. Verify all required secrets are properly configured
3. Ensure the repository has appropriate permissions
4. For complex workflows, consider testing steps locally first

---

<footer>
  <p align="center">🔄 Last updated: April 2025 | Contribute to this document through <a href="../.github/CONTRIBUTING.md">Pull Requests</a></p>
</footer>