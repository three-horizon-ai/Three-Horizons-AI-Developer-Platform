# React TypeScript Application Example

This example demonstrates a React TypeScript application built using the Three Horizons Platform Web Application Golden Path. It showcases best practices for frontend development, authentication, API integration, and deployment.

## Features

- **React 18 with TypeScript**: Modern frontend development with type safety
- **Azure AD Authentication**: Secure user authentication and authorization
- **Responsive Design**: Mobile-friendly UI with Tailwind CSS
- **API Integration**: Consumption of backend services
- **CI/CD Pipeline**: Automated build, test, and deployment workflows
- **Monitoring**: Application insights integration

## Prerequisites

- Node.js 18.x or later
- npm 9.x or later
- Access to the Three Horizons Developer Hub
- Azure AD account for authentication

## Getting Started

### Installation

```bash
# Clone the repository (if not already done)
git clone https://github.com/your-organization/three-horizons-platform.git

# Navigate to the example directory
cd examples/applications/react-typescript-app

# Install dependencies
npm install
```

### Configuration

1. Create a `.env.local` file in the root directory:

```
REACT_APP_API_BASE_URL=https://api.example.com
REACT_APP_AUTH_CLIENT_ID=your-azure-ad-client-id
REACT_APP_AUTH_TENANT_ID=your-azure-ad-tenant-id
```

2. Update the configuration values with your specific settings.

### Running Locally

```bash
# Start the development server
npm start

# The application will be available at http://localhost:3000
```

### Running Tests

```bash
# Run unit tests
npm test

# Run end-to-end tests
npm run test:e2e
```

### Building for Production

```bash
# Create optimized production build
npm run build
```

## Project Structure

```
react-typescript-app/
├── .github/workflows/     # GitHub Actions workflows
├── public/                # Static assets
├── src/
│   ├── assets/            # Images, fonts, etc.
│   ├── components/        # Reusable UI components
│   ├── contexts/          # React context providers
│   ├── hooks/             # Custom React hooks
│   ├── pages/             # Page components
│   ├── services/          # API and service integrations
│   ├── types/             # TypeScript type definitions
│   ├── utils/             # Utility functions
│   ├── App.tsx            # Main application component
│   ├── index.tsx          # Application entry point
│   └── routes.tsx         # Application routes
├── .env.example           # Example environment variables
├── package.json           # Dependencies and scripts
├── tailwind.config.js     # Tailwind CSS configuration
├── tsconfig.json          # TypeScript configuration
└── README.md              # Project documentation
```

## Key Components

### Authentication

Authentication is implemented using Microsoft Authentication Library (MSAL) for React, which provides integration with Azure AD:

```typescript
// src/contexts/AuthContext.tsx
import { MsalProvider, useMsal } from '@azure/msal-react';
import { PublicClientApplication } from '@azure/msal-browser';

const msalConfig = {
  auth: {
    clientId: process.env.REACT_APP_AUTH_CLIENT_ID || '',
    authority: `https://login.microsoftonline.com/${process.env.REACT_APP_AUTH_TENANT_ID}`,
    redirectUri: window.location.origin,
  }
};

const msalInstance = new PublicClientApplication(msalConfig);

export const AuthProvider: React.FC = ({ children }) => {
  return (
    <MsalProvider instance={msalInstance}>
      {children}
    </MsalProvider>
  );
};
```

### API Integration

API calls are handled through an axios-based service:

```typescript
// src/services/api.ts
import axios from 'axios';
import { getToken } from './auth';

const api = axios.create({
  baseURL: process.env.REACT_APP_API_BASE_URL,
});

// Add auth token to all requests
api.interceptors.request.use(async (config) => {
  const token = await getToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;
```

## Deployment

This application can be deployed to Azure using the included GitHub Actions workflow:

```yaml
# .github/workflows/deploy.yml
name: Deploy React Application

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run tests
        run: npm test
        
      - name: Build
        run: npm run build
        
      - name: Deploy to Azure
        if: github.event_name == 'push'
        uses: azure/webapps-deploy@v2
        with:
          app-name: 'your-webapp-name'
          publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
          package: './build'
```

## Monitoring

Application monitoring is configured using Azure Application Insights:

```typescript
// src/utils/monitoring.ts
import { ApplicationInsights } from '@microsoft/applicationinsights-web';

export const initMonitoring = () => {
  const appInsights = new ApplicationInsights({
    config: {
      connectionString: process.env.REACT_APP_APPINSIGHTS_CONNECTION_STRING,
      disableFetchTracking: false,
    }
  });
  
  appInsights.loadAppInsights();
  appInsights.trackPageView();
  
  return appInsights;
};
```

## Best Practices

This example follows several best practices:

- **Component Structure**: Separation of concerns with focused components
- **State Management**: Context API for global state
- **Type Safety**: TypeScript interfaces and types for all components
- **Performance Optimization**: Code splitting, memoization of expensive components
- **Accessibility**: ARIA attributes and keyboard navigation
- **Testing**: Unit tests with Jest and React Testing Library

## Next Steps

After exploring this example, you can:

1. Modify the application to fit your specific needs
2. Expand functionality by adding new features
3. Customize styling and branding
4. Integrate with additional services
5. Deploy to your own Azure environment

## Related Resources

- [Web Application Golden Path](../../docs/documentation/guides/golden-paths.md)
- [Inner Loop Development Guide](../../docs/documentation/guides/inner-loop-development.md)
- [Outer Loop Deployment Guide](../../docs/documentation/guides/outer-loop-deployment.md)
- [React Documentation](https://reactjs.org/docs/getting-started.html)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/) 