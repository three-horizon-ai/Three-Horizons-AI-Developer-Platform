# Golden Paths Guide

## Overview

Golden Paths are curated, well-supported development workflows that enable developers to build, deploy, and operate applications efficiently on the Three Horizons Platform. They represent the organization's recommended practices and provide streamlined experiences for common development scenarios.

This guide explains the concept of Golden Paths, the available paths in the Three Horizons Platform, and how to use them to accelerate your development process.

## What are Golden Paths?

Golden Paths (sometimes called "paved roads") provide:

- **Pre-configured Templates**: Standardized application templates with best practices built-in
- **Automated Scaffolding**: Quick creation of new projects with the right structure
- **Integrated Toolchains**: CI/CD pipelines, testing frameworks, and operational tooling
- **Consistent Patterns**: Standard approaches to common development challenges
- **Reduced Cognitive Load**: Less decision fatigue for developers

While Golden Paths are recommended, they are not mandatory—developers maintain flexibility to make technology choices based on specific requirements.

## Benefits of Golden Paths

- **Accelerated Onboarding**: New team members can start contributing quickly
- **Reduced Toil**: Less time spent on configuration and setup
- **Improved Quality**: Built-in best practices for security, testing, and performance
- **Operational Consistency**: Easier to support applications built on standard patterns
- **Focus on Business Logic**: Developers concentrate on creating value, not infrastructure

## Available Golden Paths

The Three Horizons Platform offers several Golden Paths designed for different application types and use cases:

### Web Application Path

Designed for building web applications and frontends.

**Technology Stack:**
- React/TypeScript frontend
- Node.js/Express backend (optional)
- Azure Container Apps hosting
- GitHub Actions for CI/CD

**Features:**
- Authentication integration with Azure AD
- Responsive UI components
- Accessibility compliance
- End-to-end testing setup

**Usage:**
```bash
# Create a new web application
devhub create --template web-application --name mywebapp
```

### Microservice Path

Designed for building backend services and APIs.

**Technology Stack:**
- Node.js, Java (Spring Boot), or .NET Core
- OpenAPI/Swagger for API documentation
- Containerized with Docker
- Kubernetes deployment via AKS

**Features:**
- API versioning
- Health check endpoints
- Structured logging
- Metrics collection

**Usage:**
```bash
# Create a new microservice
devhub create --template microservice --language java --name myservice
```

### Data Processing Path

Designed for building data processing and analytics applications.

**Technology Stack:**
- Python with data science libraries
- Azure Data Factory integration
- Azure Functions for event processing
- Cosmos DB or Azure SQL for storage

**Features:**
- Data validation schemas
- Batch and stream processing
- Monitoring and alerting setup
- Data lineage tracking

**Usage:**
```bash
# Create a new data processing application
devhub create --template data-processing --name mydataapp
```

### DevOps Extension Path

Designed for creating tooling and automation extensions.

**Technology Stack:**
- Terraform or Bicep for IaC
- Bash or PowerShell scripting
- GitHub Actions for automation
- Azure DevOps extensions

**Features:**
- Testing frameworks for infrastructure
- Security scanning integration
- Documentation generation
- Cross-platform compatibility

**Usage:**
```bash
# Create a new DevOps extension
devhub create --template devops-extension --name mytool
```

## Using Golden Paths

### Getting Started

1. Log in to the Red Hat Developer Hub
2. Navigate to the "Create" section
3. Browse available Golden Paths
4. Select the appropriate path for your project
5. Configure project parameters
6. Generate and download/clone your project

### Template Customization

While Golden Paths provide a standard starting point, you can customize them:

```bash
# View customization options
devhub template info --template microservice

# Create with custom parameters
devhub create --template microservice --parameters ./my-custom-params.json
```

### Version Control Integration

Golden Path templates are automatically set up with GitHub Enterprise integration:

```bash
# Initialize Git repository with template
devhub create --template web-application --name mywebapp --git-init

# Push to GitHub Enterprise
cd mywebapp
git remote add origin https://github.com/enterprise/mywebapp.git
git push -u origin main
```

## Golden Path Lifecycle

### Inner Loop Development

Each Golden Path includes tooling for efficient local development:

- Pre-configured dev containers
- Hot-reload capabilities
- Local testing frameworks
- Documentation generation

See the [Inner Loop Development Guide](./inner-loop-development.md) for more information.

### Outer Loop Integration

Golden Paths come with CI/CD pipeline configurations:

- GitHub Actions workflows
- Build and test automation
- Security scanning integration
- Deployment to Azure environments

See the [Outer Loop Deployment Guide](./outer-loop-deployment.md) for more information.

## Contributing to Golden Paths

The Three Horizons Platform encourages contributions to improve the Golden Paths:

### Feedback Process

1. Use the feedback button in the Developer Hub
2. Create GitHub issues with the `golden-path` label
3. Join the monthly Golden Path review meetings

### Proposing New Templates

To propose a new Golden Path template:

1. Fork the template repository
2. Develop your template following the contribution guidelines
3. Submit a pull request with comprehensive documentation
4. Participate in the review process

## Governance and Support

### Maintenance

Golden Paths are maintained by the Platform Engineering team with:

- Regular security updates
- Dependency reviews
- Quarterly technology refreshes
- Documentation updates

### Support Channels

For issues with Golden Paths:

- **Chat**: #golden-paths channel in Teams
- **Office Hours**: Wednesdays, 1:00 PM - 3:00 PM
- **GitHub Issues**: Use the `support` label for template issues

## Best Practices

- **Start Simple**: Choose the most appropriate Golden Path for your needs
- **Follow Conventions**: Adhere to the patterns established in the templates
- **Extend Thoughtfully**: Add custom functionality without breaking core patterns
- **Contribute Improvements**: Share enhancements that could benefit others
- **Stay Updated**: Regularly update to the latest template versions

## FAQ

### When should I NOT use a Golden Path?

Golden Paths may not be appropriate when:
- You have unique technology requirements not supported by existing templates
- You're working on a prototype or proof-of-concept with a short lifespan
- You're migrating a legacy application with incompatible architecture

### How often are Golden Paths updated?

Major updates occur quarterly, while security patches and minor improvements are released as needed. All changes are documented in the changelog.

### Can I migrate between Golden Paths?

While possible, migration between paths can be challenging. It's best to select the appropriate path at the beginning of your project.

## Related Documentation

- [Inner Loop Development Guide](./inner-loop-development.md)
- [Outer Loop Deployment Guide](./outer-loop-deployment.md)
- [Architecture Decision Records](../architecture/adrs.md)
- [Platform Engineering Strategy](../architecture/platform-engineering.md) 