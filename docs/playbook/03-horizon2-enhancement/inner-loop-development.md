---
title: "Inner-Loop Development"
description: "Optimizing the local development cycle for developers using the Three Horizons Platform"
position_in_journey: "4.1 Horizon 2"
previous_doc: "README.md"
next_doc: "outer-loop-deployment.md"
last_updated: "May 2024"
---

# Inner-Loop Development Guide

**Navigation**: [Home](../README.md) > [Horizon 2: Enhancement](README.md) > Inner-Loop Development

This guide focuses on optimizing the "inner loop" development experience for developers using the Three Horizons Platform. The inner loop refers to the local development cycle where developers write, build, run, and test code on their own development environments before committing changes to a shared repository.

## What is Inner-Loop Development?

![Inner Loop Diagram](../../../assets/diagrams/horizon2/inner-loop-diagram.svg)

The inner loop is the development workflow that individual developers perform locally multiple times per day:

1. Write code
2. Build the application
3. Run the application
4. Test changes
5. Repeat

An optimized inner loop is crucial for developer productivity and satisfaction. It minimizes waiting time, reduces context switching, and enables rapid experimentation.

## Inner-Loop Components in the Three Horizons Platform

The Three Horizons Platform provides several components to optimize the inner loop:

### 1. Azure DevBox

Azure DevBox provides consistent, cloud-based development environments:

- Pre-configured with all required tools and dependencies
- Accessible from anywhere via browser or Remote Desktop
- Scalable compute resources for intensive development tasks
- Managed centrally with consistent policies

### 2. GitHub Codespaces

For teams preferring a browser-based development environment:

- GitHub Codespaces provides a complete VS Code experience in the browser
- Dev container configurations ensure consistency across all developers
- Pre-configured with extensions and tools for your specific technology stack
- Seamless GitHub integration for quick access to repositories

### 3. Local Development Tools

For traditional local development:

- Standardized tool configurations via dotfiles repositories
- Containerized development environments using Docker or Podman
- Automated setup scripts and bootstrap configurations
- IDE configurations and extension recommendations

## Optimizing the Inner Loop

### Reducing Build Times

```yaml
# .dockerignore example to reduce build context
node_modules
.git
.github
*.log
coverage
```

Strategies to minimize build times:
- Layer caching in container builds
- Optimized Dockerfiles for your specific language/framework
- Incremental builds where supported
- Dependency caching

### Local Running and Debugging

Configure debugging tools for efficient troubleshooting:

```json
// .vscode/launch.json example for Node.js
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Launch Program",
      "skipFiles": ["<node_internals>/**"],
      "program": "${workspaceFolder}/src/index.js",
      "env": {
        "NODE_ENV": "development"
      }
    }
  ]
}
```

### Local Testing

Implement efficient testing strategies:
- Fast-running unit test suites
- Selective test running based on changes
- Mocked external dependencies
- Test watches for continuous feedback

## Inner-Loop Best Practices

### 1. Environment Consistency

Ensure consistent development environments:
- Use dev containers or Azure DevBox
- Maintain configuration as code
- Document environment requirements

### 2. Fast Feedback Cycles

Minimize the time between code changes and feedback:
- Configure hot reloading where possible
- Implement watch modes for tests and builds
- Use incremental builds and partial testing

### 3. Local Service Dependencies

Manage external service dependencies:
- Containerize dependencies with Docker Compose
- Use service mocks or emulators
- Implement feature toggles for optional components

### 4. Developer Tooling

Provide productivity-enhancing tools:
- Code generators and scaffolding tools
- Linting with automated fixes
- IDE extensions and configurations
- GitHub Copilot for AI-assisted development

## Sample Inner-Loop Configurations

### Docker Compose Setup

```yaml
# docker-compose.yaml
version: '3.8'
services:
  app:
    build: .
    volumes:
      - ./src:/app/src
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    depends_on:
      - db
  
  db:
    image: postgres:14
    environment:
      - POSTGRES_PASSWORD=devpassword
      - POSTGRES_USER=devuser
      - POSTGRES_DB=devdb
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
```

### Dev Container Configuration

```json
// .devcontainer/devcontainer.json
{
  "name": "Development Environment",
  "dockerComposeFile": "../docker-compose.yaml",
  "service": "app",
  "workspaceFolder": "/app",
  "customizations": {
    "vscode": {
      "extensions": [
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode",
        "github.copilot"
      ]
    }
  }
}
```

## Implementation Checklist

Use this checklist to optimize your team's inner-loop development:

- [ ] Development environment standardization (DevBox or Codespaces)
- [ ] Build optimization for rapid iterations
- [ ] Local dependency management (Docker Compose, etc.)
- [ ] Debugging configurations for common scenarios
- [ ] Testing strategy for quick feedback
- [ ] Documentation for development workflows
- [ ] Developer tooling recommendations

## Next Steps

Once you've optimized the inner-loop development experience, continue to the outer-loop deployment guide:

👉 [**Outer-Loop Deployment**](outer-loop-deployment.md)

---

<footer>
  <p align="center">🔄 Last updated: May 2024 | <a href="../../../.github/CONTRIBUTING.md">Contribute to this documentation</a></p>
</footer> 