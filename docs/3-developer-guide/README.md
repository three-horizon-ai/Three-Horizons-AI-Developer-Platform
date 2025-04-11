---
title: "Developer Guide"
description: "Comprehensive developer guide for the Three Horizons Platform"
position_in_journey: "4. Development"
previous_doc: "../2-implementation-guide/README.md"
next_doc: "../4-operations-guide/README.md"
last_updated: "April 9, 2025"
---

# Three Horizons Platform Developer Guide

**Navigation:** [Home](../../README.md) > [Documentation Map](../DOCUMENTATION_MAP.md) > Developer Guide

This guide provides comprehensive information for developers working with the Three Horizons Platform. It covers development workflows, best practices, and platform-specific guidance to help you build applications efficiently.

## Getting Started as a Developer

### Environment Setup

Configure your development environment for the Three Horizons Platform:

1. **IDE Configuration**:
   - Install VS Code or JetBrains IDE
   - Set up recommended extensions:
     - GitHub Copilot
     - Kubernetes
     - Docker
     - Azure Tools
     - Red Hat Developer Tools

2. **Local Development Environment**:
   - Install Docker Desktop
   - Install Kubernetes tools (kubectl, helm, etc.)
   - Configure Azure CLI
   - Set up GitHub CLI

3. **Access and Permissions**:
   - Request access to the Developer Hub
   - Set up your GitHub account with correct team permissions
   - Configure Azure AD authentication

## GitHub Copilot Integration

Leverage GitHub Copilot to enhance your development workflow:

### Setting up GitHub Copilot

1. Install the GitHub Copilot extension in your IDE
2. Configure settings for optimal suggestions:
   ```json
   {
     "github.copilot.enable": {
       "*": true,
       "plaintext": true,
       "markdown": true,
       "yaml": true
     },
     "github.copilot.advanced": {
       "inlineSuggest.enable": true
     }
   }
   ```

### Effective Use of GitHub Copilot

- **Code Generation**: Use comments to guide Copilot for generating complex code blocks
- **Code Explanations**: Ask Copilot to explain confusing code sections
- **Documentation**: Let Copilot help generate documentation and comments
- **Test Creation**: Generate unit and integration tests with Copilot's assistance

### Platform-Specific Patterns

Help Copilot understand Three Horizons patterns by:

- Referencing similar code in your repository
- Using consistent naming conventions
- Including detailed comments about platform components
- Creating code snippets for common patterns

For more information, see the [GitHub Copilot Integration Guide](../getting-started/github-copilot-integration.md).

## Golden Paths

The Three Horizons Platform provides several Golden Paths to accelerate development:

### Available Golden Paths

1. **Create Web Application**:
   - React/Angular/Vue frontend
   - API backend
   - CI/CD pipeline
   - Deployment configuration

2. **Create API Service**:
   - RESTful API scaffold
   - API documentation
   - Monitoring integration
   - Security controls

3. **Create Database Service**:
   - Database configuration
   - Migration scripts
   - Backup policies
   - Data access layer

### Using Golden Paths

1. Navigate to the Developer Hub
2. Select "Create" from the main menu
3. Choose a Golden Path template
4. Follow the guided creation process
5. Customize as needed for your specific requirements

## Development Workflow

### Inner Loop Development

The local development workflow:

1. **Clone Repository**:
   ```bash
   git clone https://github.com/your-org/your-project.git
   cd your-project
   ```

2. **Branch Creation**:
   ```bash
   git checkout -b feature/new-feature
   ```

3. **Local Development**:
   - Make code changes
   - Use GitHub Copilot for assistance
   - Run local tests

4. **Code Submission**:
   ```bash
   git add .
   git commit -m "Implement new feature"
   git push origin feature/new-feature
   ```

5. **Pull Request**:
   - Create a PR via GitHub
   - Address review comments
   - Ensure CI checks pass

### Outer Loop Deployment

The CI/CD deployment workflow:

1. **Continuous Integration**:
   - Automated testing
   - Code quality checks
   - Security scanning

2. **Continuous Deployment**:
   - Automated deployment to dev/test
   - Manual approval for production
   - GitOps-based promotion

## Service Integration

### Accessing Platform Services

Connect your application to platform services:

1. **Azure Services**:
   - Managed Identities
   - Storage
   - Databases
   - Messaging

2. **Third-Party Services**:
   - Authentication providers
   - API gateways
   - Monitoring tools

### Service Discovery

Discover available services in the Developer Hub:

1. Browse the service catalog
2. View documentation for each service
3. Request access to required services
4. Follow integration guides

## API Development

### API Standards

Follow these standards when developing APIs:

1. **REST Design Principles**:
   - Use proper HTTP methods
   - Implement consistent error handling
   - Version your APIs
   - Use plural resource names

2. **Documentation**:
   - Use OpenAPI/Swagger
   - Document all endpoints
   - Include example responses
   - Document error codes

3. **Security**:
   - Implement authentication
   - Apply rate limiting
   - Validate inputs
   - Use HTTPS

## Observability

### Logging

Implement effective logging:

```javascript
// Example structured logging
logger.info('User authenticated', {
  userId: user.id,
  authMethod: 'oauth',
  correlationId: request.correlationId
});
```

### Metrics

Export application metrics:

1. Use Prometheus client libraries
2. Define custom metrics for business logic
3. Set up alerts for critical thresholds

### Distributed Tracing

Implement distributed tracing:

1. Use OpenTelemetry instrumentation
2. Propagate trace context between services
3. Add span attributes for detailed analysis

## Security Best Practices

### Secure Coding

Follow secure coding practices:

1. Input validation
2. Output encoding
3. Authentication and authorization
4. Secure data handling

### Dependency Management

Manage dependencies securely:

```bash
# Scan dependencies for vulnerabilities
npm audit
# or
yarn audit

# Set up Dependabot for automated updates
# Configure in .github/dependabot.yml
```

## Testing Strategy

### Unit Testing

Write effective unit tests:

```javascript
// Example unit test with Jest
describe('UserService', () => {
  it('should authenticate valid users', async () => {
    const service = new UserService(mockRepo);
    const result = await service.authenticate('user', 'pass');
    expect(result.isAuthenticated).toBe(true);
  });
});
```

### Integration Testing

Set up integration tests:

1. Test service interactions
2. Use test containers for dependencies
3. Mock external services

### End-to-End Testing

Implement E2E testing:

1. Use Cypress or Playwright
2. Test critical user journeys
3. Run in pipeline before deployment

## Troubleshooting

Common development issues and solutions:

| Issue | Solution |
|-------|----------|
| **Local environment issues** | Run `./scripts/setup/dev-env-setup.sh` to reset environment |
| **Auth token errors** | Check AAD permissions and token expiration |
| **CI pipeline failures** | Check action logs and validate branch configuration |
| **Deployment issues** | Verify Kubernetes resource definitions |

## Related Topics

- [GitHub Copilot Integration](../getting-started/github-copilot-integration.md)
- [Architecture Overview](../1-architecture/README.md)
- [Implementation Guide](../2-implementation-guide/README.md)
- [API Reference](../5-reference/README.md)

---

<footer>
  <p align="center">Last updated: April 9, 2025 | <a href="../../.github/CONTRIBUTING.md">Contribute to this document</a></p>
</footer>
