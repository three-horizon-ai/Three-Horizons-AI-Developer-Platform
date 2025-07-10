# Three Horizons Demo Execution Guide

This guide provides step-by-step instructions for executing the demo templates successfully, following the best practices and ensuring proper integration with Azure, GitHub, and MCP.

## Pre-Execution Checklist

### Azure Requirements
- [ ] Azure subscription with owner/contributor permissions
- [ ] Azure CLI installed and authenticated (`az login`)
- [ ] ARO cluster running and accessible (`oc login`)
- [ ] Red Hat Developer Hub deployed and configured
- [ ] Azure OpenAI service deployed (for H3 demos)
- [ ] Key Vault with necessary secrets configured

### GitHub Requirements
- [ ] Access to three-horizon-ai GitHub organization
- [ ] GitHub token with appropriate permissions
- [ ] Repository creation permissions
- [ ] GitHub Copilot access (for H3 demos)

### Developer Hub Requirements
- [ ] Backstage instance accessible and configured
- [ ] GitHub integration working
- [ ] Azure integration configured
- [ ] Catalog registration functional

## Demo Execution Order

### Phase 1: Foundation (H1) - Execute First
Start with H1 demos to establish the foundational platform capabilities.

#### 1. Azure Infrastructure Demo
```bash
# Navigate to Developer Hub
# Select "Create Component" -> "H1: Azure Infrastructure Foundation"
# Fill parameters:
- Infrastructure Name: h1-demo-infra
- Azure Subscription: [your-subscription-id]
- Azure Location: eastus
- Kubernetes Version: 1.30
- Node Count: 3
- VM Size: Standard_D2s_v3
```

**Expected Results:**
- AKS cluster deployed
- Azure Container Registry created
- Key Vault configured
- Monitoring workspace established
- Network security groups configured

**Validation:**
```bash
az aks list --resource-group rg-h1-demo-infra
az acr list --resource-group rg-h1-demo-infra
kubectl get nodes
```

#### 2. Basic CI/CD Demo
```bash
# In Developer Hub, select "H1: Basic CI/CD Pipeline"
# Fill parameters:
- Pipeline Name: h1-cicd-demo
- Target Type: web-app
- Build Tool: npm
- Deployment Target: app-service
- Enable Testing: true
- Enable Security: true
```

**Expected Results:**
- GitHub repository created with workflow
- Azure App Service deployed
- CI/CD pipeline configured
- Security scanning enabled

**Validation:**
- Check GitHub Actions tab for successful runs
- Verify app service is running
- Test the deployed application

#### 3. E-commerce Demo
```bash
# In Developer Hub, select "H1: E-commerce Demo Application"
# Fill parameters:
- Application Name: h1-ecommerce-demo
- Frontend Framework: react
- Backend Framework: node-js
- Database: cosmos-db
- Payment Provider: stripe
- Enable Authentication: true
```

**Expected Results:**
- Complete e-commerce application deployed
- Frontend and backend services running
- Database configured and seeded
- Payment integration functional

**Validation:**
- Access the web application
- Test product browsing and cart functionality
- Verify order processing workflow

#### 4. Microservices Starter
```bash
# In Developer Hub, select "H1: Microservices Starter"
# Fill parameters:
- Application Name: h1-microservices-demo
- Language: typescript
- Database: postgresql
- Authentication Provider: azure-ad
- Enable Service Mesh: true
```

**Expected Results:**
- Microservices architecture deployed
- Service mesh configured (Istio)
- API gateway functional
- Distributed tracing enabled

**Validation:**
```bash
kubectl get pods -n microservices-demo
kubectl get svc -n istio-system
curl -H "Authorization: Bearer [token]" https://api.h1-microservices-demo.local/health
```

### Phase 2: Optimization (H2) - Execute After H1

#### 1. Advanced GitOps Demo
```bash
# In Developer Hub, select "H2: Advanced GitOps Workflow"
# Fill parameters:
- GitOps Application Name: h2-gitops-demo
- GitOps Strategy: app-of-apps
- Environments: [dev, staging, prod]
- Enable Canary: true
- Sync Policy: automated
```

**Expected Results:**
- ArgoCD configured with applications
- Multi-environment deployment setup
- Canary deployment configured
- GitOps workflow operational

**Validation:**
```bash
kubectl get applications -n argocd
argocd app list
argocd app sync h2-gitops-demo
```

#### 2. Monitoring Stack Demo
```bash
# In Developer Hub, select "H2: Comprehensive Monitoring Stack"
# Fill parameters:
- Stack Name: h2-monitoring-demo
- Enable Prometheus: true
- Enable Grafana: true
- Enable Jaeger: true
- Enable Azure Monitor: true
- Storage Class: managed-premium
```

**Expected Results:**
- Prometheus collecting metrics
- Grafana dashboards available
- Jaeger tracing functional
- Azure Monitor integration active

**Validation:**
- Access Grafana: https://grafana.h2-monitoring-demo.local
- Check Prometheus targets: https://prometheus.h2-monitoring-demo.local/targets
- Verify distributed traces in Jaeger

#### 3. Security Pipeline Demo
```bash
# In Developer Hub, select "H2: Enhanced Security Pipeline"
# Fill parameters:
- Pipeline Name: h2-security-demo
- Security Level: high
- Enable SAST: true
- Enable DAST: true
- Enable OPA: true
- Scan Tools: [sonarqube, snyk, trivy]
```

**Expected Results:**
- Security scanning pipeline configured
- Policy enforcement with OPA
- Vulnerability scanning operational
- Compliance monitoring active

**Validation:**
- Review security scan results
- Test policy enforcement
- Check compliance dashboard

#### 4. Performance Testing Demo
```bash
# In Developer Hub, select "H2: Performance Testing Suite"
# Fill parameters:
- Suite Name: h2-performance-demo
- Load Testing Tool: k6
- Max Users: 1000
- Test Duration: 10m
- Enable Azure Load Testing: true
```

**Expected Results:**
- Performance testing suite deployed
- Load testing scenarios configured
- Performance monitoring active
- Azure Load Testing integrated

**Validation:**
- Execute load test scenarios
- Review performance reports
- Analyze bottlenecks and optimizations

### Phase 3: Innovation (H3) - Execute After H2 Completion

H3 demos showcase advanced AI and autonomous capabilities. Ensure Azure OpenAI access is configured before proceeding.

#### 1. AI-Powered Application Demo (Enhanced)
```bash
# Navigate to Developer Hub
# Select "Create Component" -> "H3: AI-Powered Application"
# Fill parameters:
- Application Name: ai-powered-app-demo
- Azure Subscription: [your-subscription-id]
- Azure Resource Group: rg-ai-powered-app-demo
- Azure Location: eastus
- OpenAI Model: gpt-4o
- OpenAI API Version: 2024-02-01
- Enable Vector Search: true
- Enable Document Intelligence: true
- Enable Computer Vision: true
- Owner Team: ai-team
```

**Pre-Deployment Requirements:**
```bash
# Verify Azure OpenAI access
az cognitiveservices account list-models \
  --name [openai-resource-name] \
  --resource-group [resource-group]

# Check quota availability
az cognitiveservices account list-usage \
  --name [openai-resource-name] \
  --resource-group [resource-group]
```

**Deployment Steps:**
1. **Initialize AI Infrastructure**
   ```bash
   # Clone generated repository
   git clone [generated-repo-url]
   cd ai-powered-app-demo
   
   # Deploy AI services
   azd provision --preview  # Review AI service configurations
   azd up                  # Deploy all resources
   ```

2. **Configure AI Models**
   ```bash
   # Deploy OpenAI models
   az cognitiveservices account deployment create \
     --name [openai-resource-name] \
     --resource-group rg-ai-powered-app-demo \
     --deployment-name gpt-4o \
     --model-name gpt-4o \
     --model-version 2024-05-13 \
     --sku-capacity 30 \
     --sku-name Standard
   
   # Setup AI Search index
   python scripts/setup-search-index.py --config search.yaml
   ```

3. **Initialize Knowledge Base**
   ```bash
   # Upload sample documents
   python scripts/upload-documents.py --source ./sample-docs --index ai-knowledge
   
   # Build embeddings
   python scripts/build-embeddings.py --model text-embedding-3-small
   ```

**Expected Results:**
- Azure OpenAI service deployed with GPT-4o model
- Azure AI Search service with vector search capabilities
- Azure Cosmos DB for scalable document storage
- Document Intelligence service for file processing
- Computer Vision service for image analysis
- Web application with AI chat interface
- Semantic search functionality
- Document upload and analysis pipeline

**Post-Deployment Validation:**
```bash
# Test OpenAI integration
curl -X POST "https://[webapp-name].azurewebsites.net/api/ai/chat" \
  -H "Content-Type: application/json" \
  -d '{"message": "Analyze the uploaded documents and provide insights"}'

# Test semantic search
curl -X POST "https://[webapp-name].azurewebsites.net/api/search/semantic" \
  -H "Content-Type: application/json" \
  -d '{"query": "business intelligence insights", "top": 5}'

# Test document processing
curl -X POST "https://[webapp-name].azurewebsites.net/api/documents/analyze" \
  -F "file=@sample-document.pdf" \
  -F "analysis_type=content_extraction"

# Verify AI metrics
az monitor app-insights metrics show \
  --app [app-insights-name] \
  --resource-group rg-ai-powered-app-demo \
  --metric customMetrics/AI.TokensUsed
```

**AI Feature Testing:**
```bash
# Test conversational AI
python tests/ai_integration/test_chat.py --endpoint [webapp-url]

# Test document intelligence
python tests/ai_integration/test_document_processing.py --upload-path ./test-files

# Load test AI endpoints
python tests/performance/ai_load_test.py --concurrent-users 10 --duration 300
```

#### 2. GitHub Copilot Agent Demo (Enhanced)
```bash
# In Developer Hub, select "H3: GitHub Copilot Agent"
# Fill parameters:
- Agent Name: h3-copilot-agent-demo
- Agent Type: development-assistant
- Enable MCP: true
- MCP Servers: [azure-mcp-server, github-mcp-server]
- Primary Model: gpt-4o
- Target IDEs: [vscode]
```

**Expected Results:**
- Custom Copilot agent deployed
- MCP integration functional
- Development assistance capabilities active
- IDE integration working

**Validation:**
- Test agent in VS Code
- Verify MCP tool access
- Check code generation capabilities

#### 3. Autonomous DevOps Demo
```bash
# In Developer Hub, select "H3: Autonomous DevOps System"
# Fill parameters:
- System Name: h3-autonomous-demo
- Autonomy Level: high
- Enable Self-Healing: true
- Enable AI Decision Making: true
- AI Models: [gpt-4o, anomaly-detection-model]
- Decision Threshold: 0.8
```

**Expected Results:**
- Autonomous operations system deployed
- Self-healing capabilities active
- AI decision-making functional
- Predictive analytics operational

**Validation:**
- Test self-healing scenarios
- Monitor AI decision logs
- Verify autonomous scaling

#### 4. MCP Integration Platform Demo (Enhanced)

```bash
# Navigate to Developer Hub
# Select "Create Component" -> "H3: MCP Integration Platform"
# Fill parameters:
- Platform Name: mcp-platform-demo
- Azure Subscription: [your-subscription-id]
- Azure Resource Group: rg-mcp-platform-demo
- Azure Location: eastus
- MCP Version: 1.0
- Enable Service Bus: true
- Enable Cosmos DB: true
- Max Concurrent Tools: 10
- Integration Scope: enterprise
- Owner Team: ai-platform-team
```

**Pre-Deployment Setup:**

```bash
# Install MCP tools
pip install model-context-protocol mcp-client mcp-server

# Verify MCP CLI
mcp --version

# Validate MCP configuration
mcp validate --config ./config/mcp.yaml
```

**Deployment Steps:**

1. **Deploy MCP Infrastructure**

   ```bash
   # Clone generated repository
   git clone [generated-repo-url]
   cd mcp-platform-demo
   
   # Deploy MCP platform
   azd provision --preview  # Review MCP infrastructure
   azd up                  # Deploy all resources
   ```

2. **Configure MCP Tools Registry**

   ```bash
   # Register core tools
   python scripts/register-tools.py --config tools/core-tools.yaml
   
   # Register Azure-specific tools
   python scripts/register-tools.py --config tools/azure-tools.yaml
   
   # Register custom tools
   python scripts/register-tools.py --config tools/custom-tools.yaml
   ```

3. **Initialize MCP Server**

   ```bash
   # Start MCP server
   python src/mcp_server/main.py --port 8080 --config config/server.yaml
   
   # Verify server health
   curl -X GET "https://[mcp-gateway].azurewebsites.net/health"
   
   # Test tool discovery
   curl -X GET "https://[mcp-gateway].azurewebsites.net/api/tools"
   ```

**Expected Results:**
- MCP server deployed with tool registry
- Azure Service Bus for async tool execution
- Cosmos DB for conversation state management
- Protocol gateway for MCP communication
- Tool orchestration service
- Real-time monitoring and observability
- SDK generation for multiple languages

**Post-Deployment Validation:**

```bash
# Test MCP protocol compliance
python tests/mcp/test_protocol_compliance.py --server-url [mcp-server-url]

# Test tool execution
python tests/mcp/test_tool_execution.py --tool-name "azure_resource_query"

# Test multi-step workflows
python tests/mcp/test_workflow_orchestration.py --workflow-file workflows/sample.yaml

# Load test MCP platform
python tests/performance/mcp_load_test.py --concurrent-clients 50 --duration 300
```

**MCP Integration Testing:**

```bash
# Test with OpenAI models
python examples/openai_mcp_integration.py --model gpt-4o --tools "[file_analyzer, data_query]"

# Test with Claude models
python examples/claude_mcp_integration.py --model claude-3-sonnet --tools "[web_search, email_sender]"

# Test cross-model workflows
python examples/multi_model_workflow.py --primary-model gpt-4o --fallback-model claude-3-haiku
```

## Advanced Validation and Testing

### End-to-End Integration Testing

```bash
# Test complete platform integration
python tests/integration/test_e2e_platform.py --include-all-horizons

# Test cross-horizon workflows
python tests/integration/test_cross_horizon_workflows.py --h1-infra --h2-gitops --h3-ai

# Performance benchmarking
python tests/performance/benchmark_platform.py --duration 3600 --report-format json
```

### Security and Compliance Validation

```bash
# Security scanning across all demos
python scripts/security_scan.py --scope all-horizons --output security-report.json

# Compliance checking
python scripts/compliance_check.py --standards "[SOC2, GDPR, HIPAA]" --scope platform

# Vulnerability assessment
python scripts/vulnerability_assessment.py --deep-scan --remediation-suggestions
```

### AI Model Performance Testing

```bash
# Test AI model response times
python tests/ai_performance/test_model_latency.py --models "[gpt-4o, text-embedding-3-small]"

# Test token usage optimization
python tests/ai_performance/test_token_efficiency.py --optimization-targets "[cost, speed, quality]"

# Test AI accuracy and bias
python tests/ai_quality/test_model_accuracy.py --test-datasets ./ai-test-data/
```

## Troubleshooting Guide

### Common H1 Issues

1. **Infrastructure Deployment Failures**
   ```bash
   # Check resource quotas
   az vm list-usage --location eastus --output table
   
   # Verify permissions
   az role assignment list --assignee [user-principal-id] --scope /subscriptions/[subscription-id]
   ```

2. **E-Commerce Application Issues**
   ```bash
   # Check app service logs
   az webapp log tail --name [webapp-name] --resource-group [rg-name]
   
   # Verify database connection
   az sql db show-connection-string --server [server-name] --name [db-name] --client ado.net
   ```

### Common H2 Issues

1. **GitOps Pipeline Failures**
   ```bash
   # Check ArgoCD application status
   argocd app get [app-name] --output yaml
   
   # Sync application manually
   argocd app sync [app-name] --force
   ```

2. **Monitoring Stack Issues**
   ```bash
   # Check Prometheus targets
   kubectl get servicemonitors -n monitoring
   
   # Verify Grafana deployment
   kubectl get pods -n monitoring -l app=grafana
   ```

### Common H3 Issues

1. **AI Service Access Problems**
   ```bash
   # Verify OpenAI deployment
   az cognitiveservices account deployment list --name [openai-name] --resource-group [rg-name]
   
   # Check AI service quotas
   az cognitiveservices account list-usage --name [openai-name] --resource-group [rg-name]
   ```

2. **MCP Integration Issues**
   ```bash
   # Test MCP server connectivity
   python scripts/test_mcp_connectivity.py --server-url [mcp-server-url]
   
   # Validate tool registry
   python scripts/validate_tool_registry.py --registry-endpoint [registry-url]
   ```

## Demo Cleanup and Resource Management

### Automated Cleanup

```bash
# Clean up all demo resources
python scripts/cleanup_demos.py --scope all --confirm

# Clean up specific horizon
python scripts/cleanup_demos.py --scope h3 --resource-groups "[rg-ai-powered-app-demo, rg-mcp-platform-demo]"

# Preserve data and remove compute resources only
python scripts/cleanup_demos.py --scope compute-only --preserve-data
```

### Manual Cleanup Verification

```bash
# Verify resource group deletion
az group list --query "[?contains(name, 'demo')]" --output table

# Check for orphaned resources
az resource list --query "[?contains(resourceGroup, 'demo')]" --output table

# Verify Key Vault purge (if needed)
az keyvault list-deleted --query "[?contains(name, 'demo')]" --output table
```

This comprehensive demo execution guide ensures successful deployment and validation of all Three Horizons templates with proper Azure, GitHub, and MCP integration following best practices.
