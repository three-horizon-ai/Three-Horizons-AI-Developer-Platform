# ${{values.name}}

${{values.description}}

This web application was created using the Three Horizons web application template and follows all standardized practices for the Three Horizons platform.

## Technology Stack

- Frontend Framework: ${{values.framework}}
- State Management: ${{values.stateManagement}}
- Testing: ${{values.testingFramework}}
- CI/CD: ${{values.cicdPipeline}}
${{#if values.containerize}}
- Containerization: Docker
${{/if}}

## Getting Started

### Prerequisites

- Node.js 16+
- npm 7+
${{#if values.containerize}}
- Docker
${{/if}}

### Installation

```bash
# Install dependencies
npm install

# Start development server
npm run dev
```

${{#if values.containerize}}
### Docker

```bash
# Build the container
docker build -t ${{values.name}} .

# Run the container
docker run -p 3000:3000 ${{values.name}}
```
${{/if}}

## Development Guidelines

This project follows the Three Horizons coding standards and best practices:

- Follow the established project structure
- Create unit tests for all new functionality
- Submit changes via pull requests
- Ensure CI passes before merging

## Deployment

This application follows the standard Three Horizons deployment pipeline. Check the `.github/workflows` directory for CI/CD configuration.

## Documentation

For more information about Three Horizons platform development:

- [Developer Hub Documentation](https://devhub.threehorizons.example)
- [Three Horizons Web Development Guidelines](https://github.com/ThreeHorizonsOrg/development-guidelines) 