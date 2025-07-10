# Three Horizons AI Platform Demo Templates

This directory contains comprehensive demo templates for each horizon of the Three Horizons AI Platform, designed to showcase the capabilities and implementation patterns for each stage of the transformation journey.

## Overview

The templates are organized by horizon and follow best practices for Azure, GitHub, and MCP integration. Each template is a complete, executable demo that demonstrates specific capabilities and can be used as a foundation for real-world implementations.

## Template Organization

### 🏗️ Horizon 1: Foundation Templates

Foundation templates establish the core infrastructure and basic capabilities needed to begin your AI transformation journey.

#### [H1: E-commerce Demo](./h1-foundation/ecommerce-demo/)
**Purpose**: Complete e-commerce application demonstrating microservices architecture  
**Technologies**: React, Node.js, Azure Container Apps, Cosmos DB  
**Features**: Product catalog, shopping cart, order processing, payment integration  
**Demo Scenario**: End-to-end e-commerce platform with modern architecture

#### [H1: Microservices Starter](./h1-foundation/microservices-starter/)
**Purpose**: Starter template for microservices-based applications  
**Technologies**: Configurable (Node.js/Python/C#), Docker, Kubernetes  
**Features**: Service mesh, API gateway, distributed tracing  
**Demo Scenario**: Scalable microservices foundation with observability

#### [H1: Azure Infrastructure](./h1-foundation/azure-infrastructure/)
**Purpose**: Deploy foundational Azure infrastructure  
**Technologies**: Bicep, AKS, Azure Monitor, Key Vault  
**Features**: Secure networking, RBAC, monitoring foundation  
**Demo Scenario**: Production-ready infrastructure setup

#### [H1: Basic CI/CD](./h1-foundation/basic-cicd/)
**Purpose**: Establish basic continuous integration and deployment  
**Technologies**: GitHub Actions, Azure DevOps, Azure App Service  
**Features**: Automated testing, security scanning, deployment  
**Demo Scenario**: Reliable software delivery pipeline

### ⚡ Horizon 2: Optimization Templates

Optimization templates introduce advanced capabilities that enhance performance, security, and developer experience.

#### [H2: Advanced GitOps](./h2-optimization/gitops-advanced/)
**Purpose**: Implement advanced GitOps workflows with ArgoCD  
**Technologies**: ArgoCD, Helm, Kubernetes, Multi-environment management  
**Features**: App-of-apps pattern, canary deployments, promotion workflows  
**Demo Scenario**: Sophisticated deployment automation and management

#### [H2: Monitoring Stack](./h2-optimization/monitoring-stack/)
**Purpose**: Comprehensive monitoring and observability  
**Technologies**: Prometheus, Grafana, Jaeger, Azure Monitor, Application Insights  
**Features**: Distributed tracing, SLO monitoring, intelligent alerting  
**Demo Scenario**: Full-stack observability with AI-powered insights

#### [H2: Security Pipeline](./h2-optimization/security-pipeline/)
**Purpose**: Advanced security scanning and policy enforcement  
**Technologies**: SAST/DAST tools, OPA Gatekeeper, Falco, Azure Security Center  
**Features**: Vulnerability scanning, policy enforcement, compliance monitoring  
**Demo Scenario**: Zero-trust security with automated compliance

#### [H2: Performance Testing](./h2-optimization/performance-testing/)
**Purpose**: Comprehensive performance testing and optimization  
**Technologies**: K6, JMeter, Azure Load Testing, Application Insights  
**Features**: Load testing, stress testing, performance analytics  
**Demo Scenario**: Performance optimization with AI-driven insights

### 🤖 Horizon 3: Innovation Templates

Innovation templates implement cutting-edge AI capabilities and autonomous operations.

#### [H3: AI-Powered Application](./h3-innovation/ai-powered-app/)
**Purpose**: AI-native application with advanced ML capabilities  
**Technologies**: Azure OpenAI, Semantic Kernel, Vector Search, RAG  
**Features**: Intelligent chatbots, document analysis, multi-modal AI  
**Demo Scenario**: Intelligent application with conversational AI

#### [H3: GitHub Copilot Agent](./h3-innovation/copilot-agent/)
**Purpose**: Custom Copilot agent with MCP integration  
**Technologies**: GitHub Copilot, MCP, Azure AI, Custom AI models  
**Features**: Code generation, review automation, intelligent assistance  
**Demo Scenario**: AI-powered development assistant

#### [H3: Autonomous DevOps](./h3-innovation/autonomous-devops/)
**Purpose**: Self-healing, intelligent operations system  
**Technologies**: AI decision engines, Predictive analytics, Azure Automation  
**Features**: Self-healing, predictive maintenance, autonomous scaling  
**Demo Scenario**: Fully autonomous platform operations

#### [H3: MCP Integration Platform](./h3-innovation/mcp-integration/)
**Purpose**: Comprehensive Model Context Protocol integration  
**Technologies**: MCP servers, AI orchestration, Multi-model support  
**Features**: Tool discovery, context sharing, intelligent routing  
**Demo Scenario**: Seamless AI tool orchestration and connectivity

## Getting Started

### Prerequisites

Before using these templates, ensure you have:

1. **Azure Subscription** with appropriate permissions
2. **GitHub Account** with access to three-horizon-ai organization
3. **Red Hat Developer Hub** deployed and configured
4. **Required CLI Tools**: `az`, `kubectl`, `oc`, `git`

### Template Execution Process

1. **Select Template**: Choose a template based on your horizon and use case
2. **Fill Parameters**: Provide required configuration parameters
3. **Deploy Infrastructure**: Use the generated Bicep/Terraform files
4. **Configure Services**: Set up integrations and connections
5. **Run Demo**: Execute the demo scenario
6. **Monitor Results**: Use monitoring dashboards to observe behavior

### Demo Execution Guidelines

Each template includes:
- **Parameter Configuration**: Required and optional parameters
- **Infrastructure Files**: Bicep/Terraform for Azure resources
- **Application Code**: Sample applications and services
- **Documentation**: Setup instructions and demo scenarios
- **Monitoring**: Dashboards and alerts for observability

## Template Features

### 🔐 Security
- Azure Key Vault integration for secrets management
- RBAC and identity management
- Security scanning and vulnerability assessment
- Compliance framework implementation

### 🚀 Performance
- Auto-scaling capabilities
- Performance monitoring and optimization
- Load testing and stress testing
- Resource optimization recommendations

### 🔄 DevOps
- CI/CD pipeline automation
- GitOps deployment patterns
- Infrastructure as Code (IaC)
- Automated testing and quality gates

### 🤖 AI Integration
- Azure OpenAI and AI Foundry integration
- Model Context Protocol (MCP) support
- Intelligent automation and decision making
- Multi-modal AI capabilities

## Configuration Management

### Environment Variables
Templates use environment-specific configuration:
- `AZURE_SUBSCRIPTION_ID`: Azure subscription
- `AZURE_LOCATION`: Deployment region
- `GITHUB_TOKEN`: GitHub access token
- `OPENAI_API_KEY`: Azure OpenAI key

### Secret Management
All sensitive data is managed through:
- Azure Key Vault for cloud secrets
- GitHub Secrets for CI/CD
- Kubernetes Secrets for runtime configuration

### Parameter Files
Each template includes parameter files for different environments:
- `parameters-dev.json`: Development environment
- `parameters-staging.json`: Staging environment
- `parameters-prod.json`: Production environment

## Best Practices Implementation

### Infrastructure as Code
- Modular Bicep templates with reusable components
- Parameterized configurations for environment flexibility
- Secure default configurations with least privilege access
- Comprehensive resource tagging and organization

### Application Development
- Container-first architecture with Docker
- Microservices patterns with service mesh
- API-first design with OpenAPI specifications
- Event-driven architecture with Azure Service Bus

### Monitoring and Observability
- Structured logging with correlation IDs
- Distributed tracing across all services
- Custom metrics and dashboards
- Intelligent alerting with noise reduction

### Security and Compliance
- Zero-trust network architecture
- Continuous security scanning
- Policy-as-code with OPA
- Audit trails and compliance reporting

## Demo Scenarios

Each template includes specific demo scenarios:

### H1 Foundation Demos
- **E-commerce Platform**: Complete shopping experience
- **Microservices Setup**: Service communication and resilience
- **Infrastructure Deployment**: Azure resource provisioning
- **CI/CD Pipeline**: Code to production automation

### H2 Optimization Demos
- **GitOps Workflow**: Multi-environment deployment
- **Monitoring Dashboard**: Full-stack observability
- **Security Scanning**: Vulnerability detection and remediation
- **Performance Testing**: Load testing and optimization

### H3 Innovation Demos
- **AI Application**: Intelligent chatbot with RAG
- **Copilot Agent**: AI-powered development assistance
- **Autonomous Operations**: Self-healing system demonstration
- **MCP Integration**: Multi-tool AI orchestration

## Troubleshooting

### Common Issues
1. **Authentication Failures**: Verify Azure and GitHub credentials
2. **Resource Conflicts**: Check for existing resource names
3. **Permission Errors**: Ensure proper RBAC assignments
4. **Network Issues**: Verify connectivity and firewall rules

### Debug Tools
- Azure CLI for resource inspection
- kubectl for Kubernetes debugging
- Application Insights for application issues
- GitHub Actions logs for CI/CD troubleshooting

### Support Resources
- [Documentation](../docs/README.md)
- [Troubleshooting Guide](../docs/guides/troubleshooting.md)
- [GitHub Issues](https://github.com/three-horizon-ai/Three-Horizons-AI-Developer-Platform/issues)
- [Community Discussions](https://github.com/three-horizon-ai/Three-Horizons-AI-Developer-Platform/discussions)

## Contributing

### Template Development
1. Fork the repository
2. Create a new template in the appropriate horizon directory
3. Follow the template structure and naming conventions
4. Include comprehensive documentation and demo scenarios
5. Test the template in multiple environments
6. Submit a pull request with detailed description

### Quality Standards
- All templates must be fully functional
- Include proper error handling and logging
- Implement security best practices
- Provide clear documentation and examples
- Support multiple deployment environments

---

## Next Steps

1. **Choose Your Horizon**: Start with H1 if you're beginning your journey
2. **Select Demo Template**: Pick the template that best matches your use case
3. **Follow Setup Guide**: Use the detailed setup instructions
4. **Execute Demo**: Run the complete demo scenario
5. **Customize**: Adapt the template for your specific needs
6. **Scale Up**: Move to the next horizon when ready

For detailed instructions on each template, navigate to the specific template directory and follow the README.md file.

---

*The Three Horizons AI Platform demonstrates the evolution from foundational capabilities (H1) through optimization (H2) to innovation (H3), providing a clear path for AI transformation at enterprise scale.*
