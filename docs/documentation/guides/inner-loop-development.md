# Inner Loop Development Guide

## Overview

The Inner Loop Development process is a core component of the Three Horizons Platform, providing developers with a streamlined workflow for local development, testing, and validation before code is integrated into the main codebase. This guide explains the inner loop concepts, tools, and best practices to help you become productive quickly.

## What is the Inner Loop?

The Inner Loop refers to the development workflow that happens locally on a developer's machine. It encompasses the cycle of:

1. Code writing
2. Building
3. Running
4. Testing
5. Debugging

This cycle is repeated frequently as you develop features or fix bugs, all before committing code to the shared repository.

## Prerequisites

Before starting with the inner loop development process, ensure you have:

- **Developer Hub Access**: Authenticated access to the Red Hat Developer Hub
- **Local Development Environment**: Configured according to the standards (see [Environment Setup](../getting-started/environment-setup.md))
- **Required CLI Tools**: 
  - Git
  - Azure CLI
  - DevHub CLI
  - Language-specific tools (Node.js, Java, Python, etc.)
- **IDE**: Visual Studio Code with recommended extensions or JetBrains IDEs

## Inner Loop Workflow

### 1. Project Initialization

#### Starting a New Project

1. Log in to the Red Hat Developer Hub portal
2. Navigate to the "Create" section
3. Select an appropriate template from the Golden Paths catalog
4. Configure project parameters (name, description, initial setup)
5. Generate the project skeleton

#### Working with Existing Projects

```bash
# Clone the repository
git clone https://github.com/enterprise/your-project.git

# Navigate to project directory
cd your-project

# Install dependencies
# For Node.js
npm install

# For Python
pip install -r requirements.txt

# For Java
./mvnw install
```

### 2. Local Development

#### Running the Application Locally

Each project includes scripts for local development:

```bash
# Start development server
npm run dev

# Or for Python applications
python manage.py runserver

# Or for Java applications
./mvnw spring-boot:run
```

#### Local Containerization (Optional)

For testing in a container environment that mirrors production:

```bash
# Build container image
docker build -t your-project:dev .

# Run container
docker run -p 8080:8080 your-project:dev
```

### 3. Code Validation

Before submitting your changes, run local validations:

#### Running Tests

```bash
# Unit tests
npm test

# Integration tests
npm run test:integration
```

#### Code Quality Checks

```bash
# Linting
npm run lint

# Type checking (TypeScript)
npm run type-check

# Security scan
npm run security-scan
```

#### Pre-commit Hooks

The Three Horizons Platform includes pre-configured Git hooks to ensure quality:

- Format checking
- Lint validation
- Test running
- Conventional commit message enforcement

### 4. Local Preview of Documentation

For projects with documentation:

```bash
# Generate and serve documentation
npm run docs:dev
```

### 5. Prepare for Pull Request

Once your local changes are ready:

```bash
# Check status
git status

# Add changed files
git add .

# Commit with conventional commit messages
git commit -m "feat: add new user authentication flow"

# Push to your branch
git push origin feature/user-auth
```

## Integration with the Outer Loop

The Inner Loop connects to the Outer Loop (CI/CD) workflow when:

1. You create a Pull Request in GitHub Enterprise
2. The CI pipeline validates your changes
3. Code is reviewed and approved
4. Changes are merged and deployed through the CD pipeline

See the [Outer Loop Deployment Guide](./outer-loop-deployment.md) for more information on what happens after your code leaves the Inner Loop.

## Troubleshooting

### Common Issues and Solutions

#### Build Failures

- Ensure all dependencies are installed
- Check for compatible versions of libraries
- Verify environment variables are set correctly

#### Runtime Errors

- Check logs using `npm run logs` or equivalent command
- Verify configuration settings
- Ensure required services (databases, APIs) are accessible

#### Test Failures

- Run tests with `--verbose` flag for more details
- Update test fixtures if APIs or models have changed
- Check for environment-specific issues

## Best Practices

- **Commit Often**: Make small, focused commits that address a single concern
- **Use Feature Branches**: Always develop in feature branches, not directly in main
- **Follow Coding Standards**: Adhere to the project's coding conventions
- **Write Tests**: Include tests for new functionality and bug fixes
- **Document Changes**: Update documentation alongside code changes
- **Peer Review**: Consider informal peer reviews before creating a PR

## Tools and Resources

### Recommended Extensions

- **VS Code**:
  - ESLint
  - Prettier
  - GitLens
  - DevHub Companion

### CLI Tools

- **DevHub CLI**: For interacting with the Developer Hub (`devhub --help`)
- **Project-specific tools**: Documented in each project's README

## Support

For issues related to Inner Loop development:

- **Chat**: #developer-support channel in Teams
- **Knowledge Base**: [DevHub Documentation](https://devhub.example.com/docs)
- **Office Hours**: Tuesdays and Thursdays, 10:00 AM - 12:00 PM

## Related Documentation

- [Golden Paths Guide](./golden-paths.md)
- [Outer Loop Deployment Guide](./outer-loop-deployment.md)
- [Environment Setup](../getting-started/environment-setup.md)
- [Coding Standards](../reference/coding-standards.md) 