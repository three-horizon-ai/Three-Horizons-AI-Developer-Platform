---
title: Inner Loop Development Guide
description: Best practices and workflows for local development with Three Horizons Platform
position_in_journey: 15
previous_doc: /docs/3-developer-guide/README.md
next_doc: /docs/3-developer-guide/outer-loop-deployment.md
last_updated: 2025-04-10
---

# Inner Loop Development Guide

This guide provides developers with best practices for efficient local development workflows using the Three Horizons Platform. The inner loop refers to the development process that happens on a developer's local machine, centered around writing, running, and debugging code.

## Table of Contents

- [Introduction to Inner Loop Development](#introduction-to-inner-loop-development)
- [Setting Up Your Development Environment](#setting-up-your-development-environment)
- [Local Development Workflow](#local-development-workflow)
- [Testing Your Code](#testing-your-code)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Introduction to Inner Loop Development

The inner development loop is the cycle of activities developers perform while working locally:

1. Write code
2. Build
3. Run
4. Test
5. Debug
6. Repeat

The Three Horizons Platform optimizes this workflow through integrated tooling and standardized approaches that balance developer productivity with enterprise requirements.

## Setting Up Your Development Environment

### Prerequisites

- Microsoft DevBox configured with Three Horizons Platform template
- GitHub CLI installed and authenticated
- Docker Desktop or equivalent container runtime
- VS Code or preferred IDE with recommended extensions

### Initial Setup

1. **Clone your repository**

   ```bash
   gh repo clone your-org/your-project
   cd your-project
   ```

2. **Set up local configuration**

   ```bash
   # Copy example configuration file
   cp .env.example .env
   
   # Initialize development environment
   ./scripts/setup-dev-environment.sh
   ```

3. **Install dependencies**

   ```bash
   npm install   # For Node.js projects
   # OR
   mvn install   # For Java projects
   # OR
   pip install -r requirements.txt   # For Python projects
   ```

## Local Development Workflow

### Building Your Application

The Three Horizons Platform provides standardized build scripts for various project types:

```bash
# Start local build
npm run build
# OR
mvn package
# OR
make build
```

For containerized workflows:

```bash
# Build container image
docker build -t myapp:dev .
```

### Running Locally

```bash
# Run application
npm start
# OR
mvn spring-boot:run
# OR
python app.py

# For containerized apps
docker run -p 8080:8080 myapp:dev
```

### Using Dev Container

For consistent development environments, we recommend using Dev Containers:

1. In VS Code, install the Dev Containers extension
2. Open Command Palette (Ctrl+Shift+P) and select "Dev Containers: Open Folder in Container"
3. VS Code will build and start the container defined in `.devcontainer/devcontainer.json`

## Testing Your Code

### Running Tests

```bash
# Run all tests
npm test
# OR
mvn test
# OR
pytest

# Run specific tests
npm test -- --testPathPattern=auth
```

### Debugging

1. **Set breakpoints** in your IDE
2. **Start debugging session** using IDE's debugging tools
3. For containerized applications, ensure debug ports are exposed:
   ```bash
   docker run -p 8080:8080 -p 9229:9229 myapp:dev --inspect
   ```

## Best Practices

### Code Consistency

- Follow the project's coding standards and linting rules
- Run linters and formatters before committing:
  ```bash
  npm run lint
  npm run format
  ```

### Efficient Inner Loop

- Use hot reloading for faster iterations
- Implement component-level testing
- Create mock data for API dependencies
- Use feature flags for in-progress work

### Git Workflow

- Create feature branches for all work
- Commit frequently with descriptive messages
- Rebase frequently to stay in sync with main branch
- Link commits to work items using conventional commit messages

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Build failures | Check dependency versions and compatibility |
| Container networking | Verify port mappings and network configurations |
| Authentication errors | Ensure credentials are properly configured in `.env` |
| Git conflicts | Rebase and resolve conflicts locally before pushing |

### Getting Help

- Review project-specific documentation in `docs/` directory
- Consult the Three Horizons Knowledge Base
- Reach out to your team's developer experience champion

## Next Steps

Once you've completed your local development and testing, proceed to the [Outer Loop Deployment Guide](outer-loop-deployment.md) to learn about CI/CD processes and deploying your code to shared environments.

---

<footer>
  <p align="center">🔄 Last updated: April 10, 2025 | Contribute to this document through <a href="../../.github/CONTRIBUTING.md">Pull Requests</a></p>
</footer> 