# E-Commerce Demo - H1 Foundation

## Overview

This template creates a complete e-commerce application using Azure services, demonstrating foundational cloud patterns and best practices for modern web applications.

## Architecture

- **Frontend**: React application with TypeScript
- **Backend**: .NET 8 Web API
- **Database**: Azure SQL Database
- **Storage**: Azure Storage Account for product images
- **Hosting**: Azure App Service
- **CI/CD**: GitHub Actions

## Features

- Product catalog management
- Shopping cart functionality
- User authentication with Azure AD B2C
- Payment processing integration
- Order management
- Admin dashboard

## Prerequisites

- Azure subscription with appropriate permissions
- GitHub repository access
- Developer Hub access
- .NET 8 SDK
- Node.js 18+

## Template Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `name` | Application name | `ecommerce-demo` |
| `description` | Application description | `E-commerce demo application` |
| `owner` | Owner/Team name | `platform-team` |
| `azureSubscriptionId` | Azure subscription ID | Required |
| `azureResourceGroup` | Azure resource group | `rg-ecommerce-demo` |
| `azureLocation` | Azure region | `East US` |
| `databaseSku` | SQL Database SKU | `S1` |
| `appServicePlan` | App Service Plan SKU | `B1` |

## Deployment Steps

1. **Initialize Template**

   ```bash
   # From Developer Hub UI - Software Templates
   # Select "E-Commerce Demo" template
   # Fill in required parameters
   ```

2. **Review Generated Code**
   - Check the generated repository structure
   - Review configuration files
   - Validate infrastructure definitions

3. **Deploy Infrastructure**

   ```bash
   cd infra
   azd provision --preview  # Review changes
   azd up                  # Deploy resources
   ```

4. **Deploy Application**

   ```bash
   # CI/CD pipeline will automatically deploy on push to main
   git push origin main
   ```

## Local Development

1. **Prerequisites**

   ```bash
   # Install dependencies
   dotnet restore
   cd frontend && npm install
   ```

2. **Database Setup**

   ```bash
   # Run database migrations
   dotnet ef database update
   ```

3. **Start Development Servers**

   ```bash
   # Backend API
   dotnet run --project src/ECommerce.API

   # Frontend
   cd frontend && npm start
   ```

## Monitoring & Observability

- **Application Insights**: Automatic performance monitoring
- **Health Checks**: Built-in health endpoints
- **Logging**: Structured logging with Serilog
- **Metrics**: Custom business metrics

## Security Features

- **Authentication**: Azure AD B2C integration
- **Authorization**: Role-based access control
- **Data Protection**: Encryption at rest and in transit
- **Secrets Management**: Azure Key Vault integration
- **Network Security**: Private endpoints and firewall rules

## Testing

- **Unit Tests**: xUnit for backend, Jest for frontend
- **Integration Tests**: API and database testing
- **E2E Tests**: Playwright for user scenarios
- **Performance Tests**: Load testing with Azure Load Testing

## Troubleshooting

### Common Issues

1. **Database Connection Issues**
   - Verify connection strings in configuration
   - Check firewall rules and network access

2. **Authentication Problems**
   - Verify Azure AD B2C configuration
   - Check redirect URIs and app registrations

3. **Performance Issues**
   - Review Application Insights metrics
   - Check database query performance
   - Validate caching configuration

### Support

- Review logs in Application Insights
- Check Azure portal for resource health
- Consult the Developer Hub documentation

## Next Steps

After successful deployment:

1. **Configure Domain**: Set up custom domain and SSL
2. **Monitoring**: Set up alerts and dashboards
3. **Security**: Review security recommendations
4. **Performance**: Optimize based on usage patterns
5. **Scaling**: Configure auto-scaling rules

## Related Templates

- **H2 Optimization**: GitOps Advanced, Monitoring Stack
- **H3 Innovation**: AI-Powered App, Autonomous DevOps
