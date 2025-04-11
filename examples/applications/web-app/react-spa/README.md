# React Single Page Application Example

This example demonstrates a modern React single-page application built according to the Three Horizons Platform's Web Application Golden Path. It showcases best practices for front-end development, integration with backend services, and deployment to Azure.

## Features

- Modern React with functional components and hooks
- TypeScript for type safety
- Authentication with Microsoft Authentication Library (MSAL)
- API integration with Axios
- State management with React Context API
- UI components using Tailwind CSS
- Unit testing with Jest and React Testing Library
- E2E testing with Cypress

## Project Structure

```
.
├── .github/              # GitHub Actions workflows
├── public/               # Static assets
├── src/
│   ├── assets/           # Images, fonts, etc.
│   ├── components/       # Reusable UI components
│   ├── contexts/         # React context providers
│   ├── hooks/            # Custom React hooks
│   ├── pages/            # Page components
│   ├── services/         # API and external service integrations
│   ├── types/            # TypeScript type definitions
│   ├── utils/            # Utility functions
│   ├── App.tsx           # Main application component
│   ├── index.tsx         # Application entry point
│   └── router.tsx        # Application routing
├── infrastructure/       # IaC templates for Azure
├── .env.example          # Example environment variables
├── package.json          # Dependencies and scripts
├── tsconfig.json         # TypeScript configuration
└── README.md             # Project documentation
```

## Getting Started

### Prerequisites

- Node.js 16+
- npm or yarn
- Azure subscription (for deployment)
- GitHub account (for CI/CD)

### Local Development

1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/three-horizons-platform.git
   cd three-horizons-platform/examples/applications/web-app/react-spa
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Copy the example environment file and configure it:
   ```bash
   cp .env.example .env.local
   ```

4. Start the development server:
   ```bash
   npm start
   ```

5. Open [http://localhost:3000](http://localhost:3000) to view the application

### Testing

Run unit tests:
```bash
npm test
```

Run E2E tests with Cypress:
```bash
npm run cypress:open
```

### Building for Production

```bash
npm run build
```

The built application will be in the `build/` directory.

## Deployment

This example includes CI/CD pipelines for automated deployment:

### Development Environment

The application is automatically deployed to Azure Static Web Apps when pull requests are created:

```yaml
name: Deploy to Development

on:
  pull_request:
    branches: [ main ]
    types: [ opened, synchronize ]

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '16'
      - name: Install dependencies
        run: npm ci
      - name: Run tests
        run: npm test
      - name: Build
        run: npm run build
      - name: Deploy to Azure Static Web Apps
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN_DEV }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "build"
          api_location: "api"
          output_location: ""
```

### Production Environment

The application is deployed to production when changes are merged to the main branch:

```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '16'
      - name: Install dependencies
        run: npm ci
      - name: Run tests
        run: npm test
      - name: Build
        run: npm run build
      - name: Deploy to Azure Static Web Apps
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN_PROD }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "build"
          api_location: "api"
          output_location: ""
```

## Infrastructure

The application's infrastructure is defined using Azure Bicep in the `infrastructure/` directory:

- `main.bicep` - Main infrastructure definition
- `staticWebApp.bicep` - Static Web App configuration
- `cdn.bicep` - CDN configuration for production

To deploy the infrastructure manually:

```bash
az deployment group create \
  --resource-group myResourceGroup \
  --template-file infrastructure/main.bicep \
  --parameters environment=dev
```

## Learn More

For more information on the technologies used in this example:

- [React Documentation](https://reactjs.org/docs/getting-started.html)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
- [Azure Static Web Apps](https://docs.microsoft.com/en-us/azure/static-web-apps/)
- [GitHub Actions](https://docs.github.com/en/actions)

## Next Steps

After exploring this example, you can:

1. Create your own application based on this template using the Developer Hub
2. Customize the template for your specific requirements
3. Learn about backend integration by exploring the [API Service Examples](../../api-service/) 