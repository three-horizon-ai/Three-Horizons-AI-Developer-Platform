---
title: "Golden Paths"
description: "Implementing standardized developer workflows in the Three Horizons Platform"
position_in_journey: "4.3 Horizon 2"
previous_doc: "outer-loop-deployment.md"
next_doc: "devops-improvements.md"
last_updated: "May 2024"
---

# Golden Paths Guide

**Navigation**: [Home](../README.md) > [Horizon 2: Enhancement](README.md) > Golden Paths

This guide covers the implementation of Golden Paths in the Three Horizons Platform. Golden Paths provide standardized, well-supported workflows for common development scenarios, reducing cognitive load for developers while maintaining organizational standards.

## What are Golden Paths?

![Golden Paths Concept](../../../assets/diagrams/horizon2/golden-paths-concept.svg)

Golden Paths are opinionated, well-documented development workflows that provide:

- Pre-configured templates for common application types
- End-to-end guidance from initialization to production
- Built-in best practices and organizational standards
- Automated scaffolding and bootstrapping

These paths reduce cognitive load by eliminating unnecessary decision-making while maintaining flexibility for developers to innovate where it matters.

## Golden Paths in the Three Horizons Platform

The Three Horizons Platform implements Golden Paths through:

### 1. Developer Hub Templates

Red Hat Developer Hub provides a template catalog:

- Backstage-based software templates
- Self-service provisioning through web UI
- Configuration as code with customization options
- Integrated with GitHub and CI/CD

### 2. GitHub Template Repositories

GitHub template repositories for common application types:

- One-click repository creation
- Pre-configured CI/CD workflows
- Default security and quality checks
- Language-specific best practices

### 3. Scaffolding Tools

Command-line tools for scaffolding applications:

- CLI tools for creating new applications
- Interactive prompts for customization
- Consistent project structure
- Local development setup automation

## Implementing Golden Paths

### Template Structure

Golden Path templates follow a consistent structure:

```
template-name/
├── skeleton/                     # Base files for new projects
│   ├── src/                      # Source code structure
│   ├── tests/                    # Test structure
│   ├── .github/                  # GitHub workflow definitions
│   │   └── workflows/            # CI/CD configurations
│   ├── docs/                     # Documentation templates
│   └── kubernetes/               # Kubernetes manifests
├── template.yaml                 # Template definition
└── values.schema.json            # Schema for template parameters
```

### Template Definition

```yaml
# template.yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: spring-boot-service
  title: Spring Boot Microservice
  description: Create a new Spring Boot microservice with standard configuration
  tags:
    - java
    - spring
    - microservice
    - recommended
spec:
  owner: platform-team
  type: service
  parameters:
    - title: Service Information
      required:
        - name
        - description
      properties:
        name:
          title: Name
          type: string
          description: Unique name of the service
          pattern: '^[a-z0-9]([-a-z0-9]*[a-z0-9])?$'
        description:
          title: Description
          type: string
          description: Description of the service
        owner:
          title: Owner
          type: string
          description: Owner of the service
          ui:field: EntityPicker
          ui:options:
            catalogFilter:
              kind: Group
  
  steps:
    - id: template
      name: Fetch Template
      action: fetch:template
      input:
        url: ./skeleton
        values:
          name: ${{ parameters.name }}
          description: ${{ parameters.description }}
          owner: ${{ parameters.owner }}
    
    - id: publish
      name: Publish Repository
      action: publish:github
      input:
        repoUrl: github.com?owner=your-org&repo=${{ parameters.name }}
        description: ${{ parameters.description }}
        access: internal
    
    - id: register
      name: Register Service
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps.publish.output.repoContentsUrl }}
        catalogInfoPath: '/catalog-info.yaml'
```

## Golden Path Types

The platform provides multiple Golden Paths for different application types:

### 1. Web Applications

Templates for web applications using modern frameworks:

- React with TypeScript
- Angular with Material Design
- Vue.js with Vuetify

### 2. Microservices

Templates for backend microservices:

- Spring Boot REST API
- Node.js Express API
- Python FastAPI 
- .NET Core Web API

### 3. Libraries

Templates for shared libraries:

- TypeScript NPM package
- Java library
- Python package
- .NET class library

### 4. Infrastructure Components

Templates for infrastructure components:

- Terraform modules
- Kubernetes operators
- Helm charts
- Azure Bicep modules

## Developer Experience

### Self-Service Portal

The Developer Hub portal provides a web interface for Golden Paths:

1. **Browse Templates** - View available templates by category
2. **Configure Options** - Customize template parameters
3. **Generate Project** - Create repository with scaffolded code
4. **Follow Guidance** - Access documentation for next steps

### CLI Experience

Command-line tools for developer-friendly access:

```bash
# Create a new service using CLI
devhub create --type spring-boot-service \
  --name my-new-service \
  --description "My awesome service" \
  --owner team-a
```

## Best Practices for Golden Paths

### 1. Template Design

Design principles for effective templates:

- Include sensible defaults but allow customization
- Embed security and compliance requirements
- Document extension points clearly
- Keep templates updated with latest best practices

### 2. Developer Adoption

Strategies to encourage adoption:

- Make Golden Paths easier than alternatives
- Demonstrate clear benefits and time savings
- Gather and incorporate feedback
- Celebrate teams using Golden Paths

### 3. Template Governance

Maintain quality and consistency:

- Regular review and updates
- Version control for templates
- Contribution guidelines
- Testing templates in CI/CD

### 4. Custom Extensions

Support for extended functionality:

- Plugin architecture for advanced features
- Custom template actions
- Integration with existing tools
- Team-specific template variants

## Implementation Checklist

Use this checklist to implement Golden Paths:

- [ ] Identify common application patterns
- [ ] Create template repositories for each pattern
- [ ] Configure Developer Hub software templates
- [ ] Document usage and customization options
- [ ] Train development teams on Golden Paths
- [ ] Establish governance process for templates
- [ ] Collect metrics on template usage
- [ ] Implement feedback mechanism for improvements

## Next Steps

With Golden Paths established, explore additional DevOps improvements to enhance developer productivity:

👉 [**DevOps Improvements**](devops-improvements.md)

---

<footer>
  <p align="center">🔄 Last updated: May 2024 | <a href="../../../.github/CONTRIBUTING.md">Contribute to this documentation</a></p>
</footer> 