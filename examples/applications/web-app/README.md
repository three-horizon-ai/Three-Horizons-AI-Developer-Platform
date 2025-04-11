# Web Application Examples

This directory contains example web applications built using the Three Horizons Platform's Web Application Golden Path. These examples demonstrate best practices for front-end development, integration with backend services, and deployment to Azure.

## Examples

- [**React SPA**](./react-spa/): A single-page application built with React and TypeScript
- [**Angular Dashboard**](./angular-dashboard/): An analytics dashboard built with Angular
- [**.NET MVC Application**](./dotnet-mvc/): A server-rendered web application using .NET Core MVC

## React Single Page Application

The React SPA example demonstrates:

- Modern React with functional components and hooks
- TypeScript for type safety
- Integration with Microsoft Authentication Library (MSAL)
- Responsive design using Tailwind CSS
- API consumption with Axios
- State management with React Context and/or Redux
- Unit testing with Jest and React Testing Library
- E2E testing with Cypress

### Getting Started with React SPA

```bash
# Clone the repository
git clone https://github.com/your-org/three-horizons-platform.git
cd three-horizons-platform/examples/applications/web-app/react-spa

# Install dependencies
npm install

# Start the development server
npm start

# Run tests
npm test

# Build for production
npm run build
```

## Angular Dashboard

The Angular Dashboard example demonstrates:

- Angular 15+ with NgRx for state management
- Interactive data visualizations with D3.js
- Real-time data updates with SignalR
- Theme customization and enterprise design system integration
- Accessibility (WCAG 2.1 AA compliance)
- Lazy-loaded modules for performance

## .NET MVC Application

The .NET MVC Application example demonstrates:

- .NET Core 7+ MVC architecture
- Integration with Azure AD B2C for authentication
- Server-side rendering with Razor views
- API controllers for AJAX operations
- Entity Framework Core for data access
- Dependency injection and service architecture

## Deployment

Each example includes GitHub Actions workflows for CI/CD:

- `ci.yml` - Builds and tests the application on PR
- `cd.yml` - Deploys to Azure on merge to main

The examples are configured to deploy to:

- **Development**: Azure Static Web Apps (React, Angular) or App Service (.NET)
- **Production**: Azure Static Web Apps with CDN or App Service with Traffic Manager

## Infrastructure as Code

The `infrastructure/` directory in each example contains:

- ARM templates or Bicep files for Azure resources
- Terraform configurations (alternative option)
- GitHub Actions workflow files

## Best Practices Demonstrated

These examples showcase the following best practices:

- **Security**: HTTPS, CSP, authentication, CSRF protection
- **Performance**: Code splitting, lazy loading, caching strategies
- **Accessibility**: ARIA attributes, keyboard navigation, screen reader support
- **DevOps**: CI/CD pipelines, infrastructure as code, environment configuration
- **Testing**: Unit, integration, and E2E testing

## Next Steps

After exploring these examples, you can:

1. Use the Developer Hub to create a new application based on these templates
2. Customize the templates for your specific requirements
3. Contribute improvements back to the platform 