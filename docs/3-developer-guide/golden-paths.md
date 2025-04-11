---
title: Golden Paths Guide
description: Standardized engineering workflows and patterns for the Three Horizons Platform
position_in_journey: 17
previous_doc: /docs/3-developer-guide/outer-loop-deployment.md
next_doc: /docs/4-operations-guide/README.md
last_updated: 2025-04-10
---

# Golden Paths Guide

This guide introduces the concept of Golden Paths in the Three Horizons Platform—standardized, well-supported patterns that enable developers to efficiently build, deploy, and operate applications while maintaining enterprise compliance and best practices.

## Table of Contents

- [Introduction to Golden Paths](#introduction-to-golden-paths)
- [Available Golden Paths](#available-golden-paths)
- [Web Application Path](#web-application-path)
- [API Service Path](#api-service-path)
- [Data Processing Path](#data-processing-path)
- [Extending Golden Paths](#extending-golden-paths)
- [Creating Custom Paths](#creating-custom-paths)
- [Measuring Path Effectiveness](#measuring-path-effectiveness)

## Introduction to Golden Paths

Golden Paths represent the optimal, well-supported ways of working within the Three Horizons Platform. They provide:

- **Pre-approved technology choices** aligned with enterprise standards
- **Automated scaffolding** for new projects
- **Built-in security and compliance** controls
- **Standardized deployment pipelines** for consistent delivery
- **Integrated observability** for operational excellence

By following a Golden Path, teams can focus on delivering business value rather than solving infrastructure and tooling challenges.

## Available Golden Paths

The Three Horizons Platform offers several Golden Paths tailored to different application types:

| Path | Purpose | Technologies | Templates |
|------|---------|--------------|-----------|
| Web Application | User-facing web applications | React, Angular, .NET, Java | [Web App Templates](../examples/applications/web-app/) |
| API Service | Backend services and APIs | Node.js, .NET, Java, Python | [API Templates](../examples/applications/api-service/) |
| Data Processing | ETL and data analytics | Apache Spark, Azure Data Factory | [Data Templates](../examples/applications/data-processing/) |
| Event-Driven | Event processing applications | Azure Functions, Event Hubs | [Event Templates](../examples/applications/event-driven/) |

## Web Application Path

The Web Application Golden Path provides a standardized approach for building, deploying, and operating web applications.

### Getting Started

To create a new web application using the Web Application Golden Path:

1. Navigate to the Red Hat Developer Hub
2. Select "Create > Web Application" from the catalog
3. Choose your preferred frontend framework
4. Complete the project metadata form
5. Click "Create"

The Developer Hub will generate a new repository with:

- Scaffolded application code
- CI/CD pipelines
- Infrastructure as Code templates
- Documentation

### Key Components

The Web Application Golden Path includes:

- **Frontend Framework**: React or Angular with TypeScript
- **API Integration**: Axios/Fetch with standard auth patterns
- **Testing Framework**: Jest, Cypress for E2E testing
- **Styling**: Tailwind CSS or company design system
- **CI/CD**: GitHub Actions workflows for build, test, deploy
- **Infrastructure**: Azure App Service or AKS deployment

### Path Flow

![Web App Workflow](../documentation/architecture/workflow-diagram.svg)

1. **Develop**: Local development with hot reloading
2. **Test**: Unit, integration, and E2E tests
3. **Build**: Create production build and container image
4. **Deploy**: Progressive deployment across environments
5. **Monitor**: Application performance and user metrics

## API Service Path

The API Service Golden Path provides a standardized approach for building backend services and APIs.

### Getting Started

To create a new API service:

1. Navigate to the Red Hat Developer Hub
2. Select "Create > API Service" from the catalog
3. Choose your preferred backend language/framework
4. Complete the project metadata and API specification
5. Click "Create"

### Key Components

The API Service Golden Path includes:

- **Framework Options**: Express (Node.js), Spring Boot (Java), FastAPI (Python), .NET Core
- **API Documentation**: OpenAPI/Swagger integration
- **Data Access**: ORM templates with migrations
- **Authentication**: OAuth2/OIDC integration
- **CI/CD**: GitHub Actions workflows
- **Infrastructure**: AKS or Azure Container Apps

### Best Practices

1. **API Design**: Follow RESTful or GraphQL best practices
2. **Versioning**: Implement semantic versioning
3. **Rate Limiting**: Configure throttling for API endpoints
4. **Security**: Use the built-in security scanning

## Data Processing Path

The Data Processing Golden Path provides a standardized approach for building data processing applications.

### Getting Started

To create a new data processing application:

1. Navigate to the Red Hat Developer Hub
2. Select "Create > Data Processing" from the catalog
3. Configure data sources and sinks
4. Define processing logic
5. Click "Create"

### Key Components

The Data Processing Golden Path includes:

- **Processing Engines**: Apache Spark, Azure Databricks
- **Orchestration**: Azure Data Factory or Airflow
- **Storage**: Azure Blob Storage, Data Lake
- **Monitoring**: Azure Monitor integration
- **Data Quality**: Great Expectations integration

## Extending Golden Paths

Teams can extend existing Golden Paths to address specific requirements:

### Extension Points

1. **Custom Templates**: Add organization-specific templates
2. **Compliance Rules**: Implement additional policy checks
3. **Integration Points**: Add connections to internal systems
4. **Deployment Targets**: Support additional hosting options

### Extension Process

1. Fork the base Golden Path repository
2. Make necessary modifications and additions
3. Submit a pull request with detailed documentation
4. Architectural review board approval
5. Integration into Developer Hub

## Creating Custom Paths

For unique requirements not addressed by existing paths:

1. **Define the Path Scope**:
   - Target application type
   - Technology boundaries
   - User personas

2. **Develop Path Components**:
   - Project templates
   - CI/CD workflows
   - Documentation
   - Infrastructure templates

3. **Test and Validate**:
   - Validate with pilot teams
   - Measure developer experience
   - Verify compliance

4. **Release and Support**:
   - Publish to Developer Hub
   - Training materials
   - Support channels

## Measuring Path Effectiveness

Golden Paths include built-in metrics to measure their effectiveness:

### Key Metrics

- **Adoption Rate**: Percentage of new projects using paths
- **Time to First Deployment**: Duration from project creation to first deployment
- **Compliance Score**: Adherence to security and compliance policies
- **Developer Satisfaction**: Survey-based feedback
- **Operational Performance**: Production incidents, MTTR

### Metrics Dashboard

Access the Golden Paths Metrics Dashboard in the Developer Hub to view real-time metrics and insights.

## Next Steps

After understanding the available Golden Paths, proceed to:

1. Try creating a sample application using one of the paths
2. Review the [Example Applications](../examples/applications/) for reference implementations
3. Explore the [Operations Guide](../4-operations-guide/README.md) for managing applications in production

---

<footer>
  <p align="center">🔄 Last updated: April 10, 2025 | Contribute to this document through <a href="../../.github/CONTRIBUTING.md">Pull Requests</a></p>
</footer> 