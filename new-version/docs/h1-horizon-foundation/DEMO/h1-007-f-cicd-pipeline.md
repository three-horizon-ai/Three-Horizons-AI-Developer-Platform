# 🚀 H1-007-F: Guia Completo de Configuração CI/CD Pipeline

## 📋 Índice

1. [🎯 Visão Geral](#visao-geral)
2. [🔧 Configuração GitHub Actions](#configuracao-github-actions)
3. [🏗️ Pipeline Principal](#pipeline-principal)
4. [🐳 Build de Containers](#build-containers)
5. [🧪 Pipelines de Teste](#pipelines-teste)
6. [🔒 Segurança no Pipeline](#seguranca-pipeline)
7. [📊 Quality Gates](#quality-gates)
8. [🚀 Deploy Automatizado](#deploy-automatizado)
9. [📈 Métricas e Relatórios](#metricas-relatorios)
10. [🔄 Integração com Developer Hub](#integracao-hub)

## 🎯 Visão Geral {#visao-geral}

Este guia fornece a configuração completa de CI/CD para a demonstração Three Horizons, incluindo todos os workflows necessários.

### 📊 Componentes do Pipeline

```mermaid
graph LR
    subgraph "Source"
        GH[GitHub Repository]
        DH[Developer Hub]
    end
    
    subgraph "CI Pipeline"
        Build[Build & Test]
        Scan[Security Scan]
        Quality[Quality Gates]
        Package[Package]
    end
    
    subgraph "CD Pipeline"
        ACR[Container Registry]
        GitOps[ArgoCD Sync]
        Deploy[Deploy to AKS]
    end
    
    subgraph "Monitoring"
        Metrics[Pipeline Metrics]
        Alerts[Alerts]
    end
    
    GH --> Build
    DH --> GH
    Build --> Scan
    Scan --> Quality
    Quality --> Package
    Package --> ACR
    ACR --> GitOps
    GitOps --> Deploy
    Build & Deploy --> Metrics
    Metrics --> Alerts
```

## 🔧 Configuração GitHub Actions {#configuracao-github-actions}

### Estrutura de Workflows

```bash
# Criar estrutura de workflows
mkdir -p .github/workflows/{ci,cd,security,quality}
```

### Workflow Principal - CI/CD Completo

```yaml
# .github/workflows/main-pipeline.yml
name: 🚀 Main CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        default: 'dev'
        type: choice
        options:
          - dev
          - staging
          - prod

env:
  REGISTRY: acrthreehorizonsdemo.azurecr.io
  AKS_CLUSTER: threehorizons-aks
  RESOURCE_GROUP: rg-threehorizons-demo

jobs:
  # 🔍 Análise inicial
  analyze:
    name: 📊 Analyze Changes
    runs-on: ubuntu-latest
    outputs:
      frontend-changed: ${{ steps.filter.outputs.frontend }}
      backend-changed: ${{ steps.filter.outputs.backend }}
      infra-changed: ${{ steps.filter.outputs.infra }}
      services: ${{ steps.detect.outputs.services }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: dorny/paths-filter@v2
        id: filter
        with:
          filters: |
            frontend:
              - 'frontend/**'
              - 'package.json'
              - 'package-lock.json'
            backend:
              - 'backend/**'
              - 'go.mod'
              - 'go.sum'
            infra:
              - 'infrastructure/**'
              - 'k8s/**'

      - name: 🔍 Detect Services
        id: detect
        run: |
          SERVICES=$(find backend -maxdepth 1 -type d -name "*-service" | xargs -n1 basename | jq -R -s -c 'split("\n")[:-1]')
          echo "services=$SERVICES" >> $GITHUB_OUTPUT
          echo "Detected services: $SERVICES"

  # 🏗️ Build Frontend
  build-frontend:
    name: 🎨 Build Frontend
    needs: analyze
    if: needs.analyze.outputs.frontend-changed == 'true'
    runs-on: ubuntu-latest
    strategy:
      matrix:
        app: [portal, admin]
    steps:
      - uses: actions/checkout@v4

      - name: 🔧 Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: frontend/${{ matrix.app }}/package-lock.json

      - name: 📦 Install Dependencies
        working-directory: frontend/${{ matrix.app }}
        run: npm ci

      - name: 🧪 Run Tests
        working-directory: frontend/${{ matrix.app }}
        run: |
          npm run lint
          npm run test:ci
          npm run test:e2e:ci

      - name: 🏗️ Build Application
        working-directory: frontend/${{ matrix.app }}
        run: npm run build
        env:
          NEXT_PUBLIC_API_URL: https://api.demo.threehorizons.io

      - name: 📊 SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        with:
          projectBaseDir: frontend/${{ matrix.app }}

      - name: 🐳 Build & Push Docker Image
        uses: docker/build-push-action@v5
        with:
          context: frontend/${{ matrix.app }}
          push: true
          tags: |
            ${{ env.REGISTRY }}/frontend-${{ matrix.app }}:${{ github.sha }}
            ${{ env.REGISTRY }}/frontend-${{ matrix.app }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

  # 🏗️ Build Backend Services
  build-backend:
    name: ⚙️ Build Backend Services
    needs: analyze
    if: needs.analyze.outputs.backend-changed == 'true'
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: ${{ fromJson(needs.analyze.outputs.services) }}
    steps:
      - uses: actions/checkout@v4

      - name: 🔍 Detect Language
        id: detect-lang
        working-directory: backend/${{ matrix.service }}
        run: |
          if [ -f "go.mod" ]; then echo "lang=go" >> $GITHUB_OUTPUT
          elif [ -f "package.json" ]; then echo "lang=node" >> $GITHUB_OUTPUT
          elif [ -f "pom.xml" ]; then echo "lang=java" >> $GITHUB_OUTPUT
          elif [ -f "requirements.txt" ]; then echo "lang=python" >> $GITHUB_OUTPUT
          elif [ -f "*.csproj" ]; then echo "lang=dotnet" >> $GITHUB_OUTPUT
          fi

      - name: 🔧 Setup Language Environment
        uses: ./.github/actions/setup-language
        with:
          language: ${{ steps.detect-lang.outputs.lang }}

      - name: 🧪 Run Tests
        working-directory: backend/${{ matrix.service }}
        run: |
          case "${{ steps.detect-lang.outputs.lang }}" in
            go) go test -v -race -coverprofile=coverage.out ./... ;;
            node) npm run test:ci ;;
            java) mvn test ;;
            python) pytest --cov=. --cov-report=xml ;;
            dotnet) dotnet test --collect:"XPlat Code Coverage" ;;
          esac

      - name: 🔒 Security Scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: 'backend/${{ matrix.service }}'
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: 📤 Upload Security Results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results.sarif'

      - name: 🐳 Build & Push Docker Image
        uses: docker/build-push-action@v5
        with:
          context: backend/${{ matrix.service }}
          push: true
          tags: |
            ${{ env.REGISTRY }}/${{ matrix.service }}:${{ github.sha }}
            ${{ env.REGISTRY }}/${{ matrix.service }}:latest
          build-args: |
            VERSION=${{ github.sha }}
            BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

  # 🚀 Deploy
  deploy:
    name: 🚀 Deploy to ${{ github.event.inputs.environment || 'dev' }}
    needs: [build-frontend, build-backend]
    if: always() && (needs.build-frontend.result == 'success' || needs.build-backend.result == 'success')
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment || 'dev' }}
    steps:
      - uses: actions/checkout@v4

      - name: 🔐 Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: 🔧 Setup Kubernetes
        uses: azure/setup-kubectl@v3
        with:
          version: 'v1.28.3'

      - name: 🔑 Get AKS Credentials
        run: |
          az aks get-credentials \
            --resource-group ${{ env.RESOURCE_GROUP }} \
            --name ${{ env.AKS_CLUSTER }} \
            --overwrite-existing

      - name: 📝 Update Manifests
        run: |
          ENV=${{ github.event.inputs.environment || 'dev' }}
          kustomize edit set image *:${{ github.sha }}
        working-directory: k8s/overlays/${{ github.event.inputs.environment || 'dev' }}

      - name: 🚀 Deploy to Kubernetes
        run: |
          kubectl apply -k k8s/overlays/${{ github.event.inputs.environment || 'dev' }}
          kubectl rollout status deployment -n ecommerce-${{ github.event.inputs.environment || 'dev' }} --timeout=10m

      - name: 🧪 Run Smoke Tests
        run: |
          npm install -g newman
          newman run tests/postman/smoke-tests.json \
            --env-var "baseUrl=https://api-${{ github.event.inputs.environment || 'dev' }}.demo.threehorizons.io"

      - name: 📊 Update Developer Hub
        uses: ./.github/actions/update-backstage
        with:
          entity: ${{ github.repository }}
          annotations: |
            github.com/last-deployment: ${{ github.sha }}
            github.com/deployment-status: success
            github.com/deployment-env: ${{ github.event.inputs.environment || 'dev' }}
```

## 🏗️ Pipeline Principal {#pipeline-principal}

### Configuração de Branches e Ambientes

```yaml
# .github/workflows/environment-promotion.yml
name: 🔄 Environment Promotion

on:
  workflow_dispatch:
    inputs:
      from_env:
        description: 'Source environment'
        required: true
        type: choice
        options:
          - dev
          - staging
      to_env:
        description: 'Target environment'
        required: true
        type: choice
        options:
          - staging
          - prod

jobs:
  validate:
    name: ✅ Validate Promotion
    runs-on: ubuntu-latest
    steps:
      - name: 🔍 Check Promotion Rules
        run: |
          if [[ "${{ inputs.from_env }}" == "dev" && "${{ inputs.to_env }}" != "staging" ]]; then
            echo "❌ Can only promote from dev to staging"
            exit 1
          fi
          if [[ "${{ inputs.from_env }}" == "staging" && "${{ inputs.to_env }}" != "prod" ]]; then
            echo "❌ Can only promote from staging to prod"
            exit 1
          fi

      - name: 🧪 Verify Source Environment Health
        run: |
          # Check deployment status
          kubectl get deployments -n ecommerce-${{ inputs.from_env }}
          
          # Run health checks
          curl -f https://api-${{ inputs.from_env }}.demo.threehorizons.io/health

  promote:
    name: 🚀 Promote to ${{ inputs.to_env }}
    needs: validate
    runs-on: ubuntu-latest
    environment: ${{ inputs.to_env }}
    steps:
      - uses: actions/checkout@v4

      - name: 📋 Get Current Version
        id: version
        run: |
          VERSION=$(kubectl get deployment api-gateway -n ecommerce-${{ inputs.from_env }} -o jsonpath='{.spec.template.spec.containers[0].image}' | cut -d: -f2)
          echo "version=$VERSION" >> $GITHUB_OUTPUT

      - name: 📝 Update Target Manifests
        run: |
          cd k8s/overlays/${{ inputs.to_env }}
          kustomize edit set image *:${{ steps.version.outputs.version }}
          
          git config --global user.name 'Three Horizons Bot'
          git config --global user.email 'bot@threehorizons.ai'
          git add .
          git commit -m "chore: promote version ${{ steps.version.outputs.version }} to ${{ inputs.to_env }}"
          git push

      - name: 🔄 Trigger ArgoCD Sync
        run: |
          argocd app sync ecommerce-${{ inputs.to_env }} --force
          argocd app wait ecommerce-${{ inputs.to_env }} --health
```

## 🐳 Build de Containers {#build-containers}

### Multi-stage Dockerfile Otimizado

```dockerfile
# backend/api-gateway/Dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci --only=production

# Copy source
COPY . .

# Build TypeScript
RUN npm run build

# Production stage
FROM node:20-alpine AS runtime
WORKDIR /app

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy built application
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./

# Security hardening
RUN npm prune --production && \
    npm cache clean --force && \
    rm -rf /tmp/*

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node dist/health-check.js || exit 1

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 8080

# Start with dumb-init
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]
```

### Build Matrix para Múltiplas Arquiteturas

```yaml
# .github/workflows/docker-build.yml
name: 🐳 Docker Build Matrix

on:
  workflow_call:
    inputs:
      service_path:
        required: true
        type: string
      service_name:
        required: true
        type: string

jobs:
  build:
    name: Build ${{ inputs.service_name }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: 🔧 Set up QEMU
        uses: docker/setup-qemu-action@v3

      - name: 🔧 Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: 🔐 Login to ACR
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ secrets.ACR_USERNAME }}
          password: ${{ secrets.ACR_PASSWORD }}

      - name: 📝 Docker metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ inputs.service_name }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,prefix={{branch}}-

      - name: 🐳 Build and push
        uses: docker/build-push-action@v5
        with:
          context: ${{ inputs.service_path }}
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          build-args: |
            BUILDKIT_INLINE_CACHE=1
            VERSION=${{ github.sha }}
```

## 🧪 Pipelines de Teste {#pipelines-teste}

### Pipeline de Testes Completo

```yaml
# .github/workflows/test-suite.yml
name: 🧪 Test Suite

on:
  workflow_call:
    inputs:
      service:
        required: true
        type: string

jobs:
  unit-tests:
    name: 🧪 Unit Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: 🔧 Setup Test Environment
        uses: ./.github/actions/setup-test-env
        with:
          service: ${{ inputs.service }}

      - name: 🧪 Run Unit Tests
        run: |
          cd ${{ inputs.service }}
          npm run test:unit -- --coverage --reporters=default --reporters=jest-junit

      - name: 📊 Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./${{ inputs.service }}/coverage/lcov.info
          flags: unit-${{ inputs.service }}

  integration-tests:
    name: 🔗 Integration Tests
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: testpass
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v4

      - name: 🧪 Run Integration Tests
        run: |
          cd ${{ inputs.service }}
          npm run test:integration
        env:
          DATABASE_URL: postgresql://postgres:testpass@localhost:5432/test
          REDIS_URL: redis://localhost:6379

  e2e-tests:
    name: 🎭 E2E Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: 🎭 Install Playwright
        run: npx playwright install --with-deps

      - name: 🚀 Start Services
        run: docker-compose -f docker-compose.test.yml up -d

      - name: ⏳ Wait for Services
        run: |
          npx wait-on http://localhost:3000 http://localhost:8080/health -t 60000

      - name: 🎭 Run E2E Tests
        run: |
          cd tests/e2e
          npm run test:e2e

      - name: 📸 Upload Screenshots
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-screenshots
          path: tests/e2e/screenshots/

  performance-tests:
    name: 🚀 Performance Tests
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4

      - name: 🔥 Run Load Tests
        run: |
          npm install -g k6
          k6 run tests/performance/load-test.js \
            --out cloud \
            --quiet

      - name: 📊 Analyze Results
        run: |
          # Check if performance thresholds are met
          k6 inspect tests/performance/results.json
```

### Testes de Contrato com Pact

```yaml
# .github/workflows/contract-tests.yml
name: 📄 Contract Tests

on:
  pull_request:
    paths:
      - 'backend/**'
      - 'frontend/**'

jobs:
  consumer-tests:
    name: Consumer Contract Tests
    runs-on: ubuntu-latest
    strategy:
      matrix:
        consumer: [frontend-portal, frontend-admin]
    steps:
      - uses: actions/checkout@v4

      - name: 🧪 Run Consumer Tests
        run: |
          cd ${{ matrix.consumer }}
          npm run test:pact

      - name: 📤 Publish Pacts
        run: |
          npx pact-broker publish pacts \
            --consumer-app-version=${{ github.sha }} \
            --broker-base-url=${{ secrets.PACT_BROKER_URL }} \
            --broker-token=${{ secrets.PACT_BROKER_TOKEN }}

  provider-tests:
    name: Provider Contract Tests
    needs: consumer-tests
    runs-on: ubuntu-latest
    strategy:
      matrix:
        provider: [api-gateway, catalog-service, user-service]
    steps:
      - uses: actions/checkout@v4

      - name: 🧪 Verify Provider Contracts
        run: |
          cd backend/${{ matrix.provider }}
          npm run test:pact:verify
        env:
          PACT_BROKER_URL: ${{ secrets.PACT_BROKER_URL }}
          PACT_BROKER_TOKEN: ${{ secrets.PACT_BROKER_TOKEN }}
```

## 🔒 Segurança no Pipeline {#seguranca-pipeline}

### Pipeline de Segurança Completo

```yaml
# .github/workflows/security-scan.yml
name: 🔒 Security Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  # 🔍 Static Analysis
  sast:
    name: 🔍 SAST Scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: 🔒 Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: javascript, typescript, go, java, python, csharp

      - name: 🏗️ Build Code
        run: |
          npm ci
          npm run build

      - name: 🔍 Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3

      - name: 🔍 Semgrep Scan
        uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/security-audit
            p/secrets
            p/owasp-top-ten

  # 🐳 Container Scanning
  container-scan:
    name: 🐳 Container Security
    runs-on: ubuntu-latest
    strategy:
      matrix:
        image: [frontend-portal, api-gateway, catalog-service]
    steps:
      - uses: actions/checkout@v4

      - name: 🔍 Trivy Container Scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: '${{ env.REGISTRY }}/${{ matrix.image }}:latest'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'

      - name: 📤 Upload Trivy Results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results.sarif'

      - name: 🔍 Grype Scan
        uses: anchore/scan-action@v3
        with:
          image: '${{ env.REGISTRY }}/${{ matrix.image }}:latest'
          severity-cutoff: high

  # 📦 Dependency Scanning
  dependency-scan:
    name: 📦 Dependency Security
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: 🔍 NPM Audit
        run: |
          find . -name package.json -not -path "*/node_modules/*" -execdir sh -c '
            echo "Scanning $(pwd)"
            npm audit --audit-level=moderate
          ' \;

      - name: 🔍 OWASP Dependency Check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: 'three-horizons-demo'
          path: '.'
          format: 'ALL'

      - name: 📤 Upload OWASP Results
        uses: actions/upload-artifact@v3
        with:
          name: dependency-check-results
          path: reports/

  # 🔑 Secret Scanning
  secret-scan:
    name: 🔑 Secret Detection
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: 🔍 TruffleHog OSS
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: ${{ github.event.repository.default_branch }}
          head: HEAD
          extra_args: --debug --only-verified

      - name: 🔍 GitLeaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  # 🌐 DAST Scan
  dast:
    name: 🌐 DAST Scan
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4

      - name: 🌐 OWASP ZAP Scan
        uses: zaproxy/action-full-scan@v0.7.0
        with:
          target: 'https://demo.threehorizons.io'
          rules_file_name: '.zap/rules.tsv'
          cmd_options: '-a -j'

      - name: 📤 Upload ZAP Results
        uses: actions/upload-artifact@v3
        with:
          name: zap-scan-results
          path: report_html.html
```

## 📊 Quality Gates {#quality-gates}

### Configuração de Quality Gates

```yaml
# .github/workflows/quality-gates.yml
name: 📊 Quality Gates

on:
  workflow_call:
    outputs:
      passed:
        description: "Quality gates passed"
        value: ${{ jobs.evaluate.outputs.passed }}

jobs:
  evaluate:
    name: 📊 Evaluate Quality
    runs-on: ubuntu-latest
    outputs:
      passed: ${{ steps.gates.outputs.passed }}
    steps:
      - uses: actions/checkout@v4

      - name: 📊 Check Code Coverage
        id: coverage
        run: |
          COVERAGE=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
          echo "coverage=$COVERAGE" >> $GITHUB_OUTPUT
          
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "❌ Coverage below 80%: $COVERAGE%"
            echo "passed=false" >> $GITHUB_OUTPUT
          else
            echo "✅ Coverage: $COVERAGE%"
          fi

      - name: 📊 Check Code Quality
        id: quality
        run: |
          # SonarQube metrics
          QUALITY_GATE=$(curl -s -u ${{ secrets.SONAR_TOKEN }}: \
            "${{ secrets.SONAR_HOST }}/api/qualitygates/project_status?projectKey=${{ github.repository }}" \
            | jq -r '.projectStatus.status')
          
          if [ "$QUALITY_GATE" != "OK" ]; then
            echo "❌ SonarQube quality gate failed"
            echo "passed=false" >> $GITHUB_OUTPUT
          else
            echo "✅ SonarQube quality gate passed"
          fi

      - name: 🔒 Check Security Issues
        id: security
        run: |
          CRITICAL=$(cat security-report.json | jq '.vulnerabilities | map(select(.severity == "CRITICAL")) | length')
          HIGH=$(cat security-report.json | jq '.vulnerabilities | map(select(.severity == "HIGH")) | length')
          
          if [ "$CRITICAL" -gt 0 ] || [ "$HIGH" -gt 5 ]; then
            echo "❌ Security issues found: $CRITICAL critical, $HIGH high"
            echo "passed=false" >> $GITHUB_OUTPUT
          else
            echo "✅ No critical security issues"
          fi

      - name: 🚀 Check Performance
        id: performance
        run: |
          # Lighthouse scores
          PERFORMANCE=$(cat lighthouse-report.json | jq '.categories.performance.score * 100')
          
          if (( $(echo "$PERFORMANCE < 90" | bc -l) )); then
            echo "❌ Performance score below 90: $PERFORMANCE"
            echo "passed=false" >> $GITHUB_OUTPUT
          else
            echo "✅ Performance score: $PERFORMANCE"
          fi

      - name: 📋 Quality Gate Summary
        id: gates
        run: |
          if [ "${{ steps.coverage.outputs.passed }}" == "false" ] || \
             [ "${{ steps.quality.outputs.passed }}" == "false" ] || \
             [ "${{ steps.security.outputs.passed }}" == "false" ] || \
             [ "${{ steps.performance.outputs.passed }}" == "false" ]; then
            echo "passed=false" >> $GITHUB_OUTPUT
            echo "❌ Quality gates failed"
            exit 1
          else
            echo "passed=true" >> $GITHUB_OUTPUT
            echo "✅ All quality gates passed"
          fi
```

## 🚀 Deploy Automatizado {#deploy-automatizado}

### Deploy com Helm

```yaml
# .github/workflows/helm-deploy.yml
name: 🚀 Helm Deploy

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      version:
        required: true
        type: string

jobs:
  deploy:
    name: 🚀 Deploy to ${{ inputs.environment }}
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    steps:
      - uses: actions/checkout@v4

      - name: 🔧 Setup Helm
        uses: azure/setup-helm@v3
        with:
          version: 'v3.13.0'

      - name: 🔐 Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: 🔑 Get AKS Credentials
        run: |
          az aks get-credentials \
            --resource-group ${{ env.RESOURCE_GROUP }} \
            --name ${{ env.AKS_CLUSTER }}

      - name: 📦 Add Helm Repos
        run: |
          helm repo add bitnami https://charts.bitnami.com/bitnami
          helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
          helm repo update

      - name: 🚀 Deploy Application
        run: |
          helm upgrade --install ecommerce ./charts/ecommerce \
            --namespace ecommerce-${{ inputs.environment }} \
            --create-namespace \
            --values ./charts/ecommerce/values.yaml \
            --values ./charts/ecommerce/values-${{ inputs.environment }}.yaml \
            --set image.tag=${{ inputs.version }} \
            --set ingress.hostname=${{ inputs.environment }}.demo.threehorizons.io \
            --atomic \
            --timeout 10m

      - name: 🧪 Verify Deployment
        run: |
          kubectl wait --for=condition=ready pod \
            -l app.kubernetes.io/instance=ecommerce \
            -n ecommerce-${{ inputs.environment }} \
            --timeout=300s

      - name: 🔍 Run Health Checks
        run: |
          INGRESS_IP=$(kubectl get ingress ecommerce -n ecommerce-${{ inputs.environment }} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
          
          for i in {1..30}; do
            if curl -f -s "http://$INGRESS_IP/health"; then
              echo "✅ Health check passed"
              break
            fi
            echo "⏳ Waiting for application to be ready... ($i/30)"
            sleep 10
          done
```

### Blue-Green Deployment

```yaml
# .github/workflows/blue-green-deploy.yml
name: 🔵🟢 Blue-Green Deploy

on:
  workflow_dispatch:
    inputs:
      environment:
        required: true
        type: choice
        options: [staging, prod]

jobs:
  deploy:
    name: 🔵🟢 Blue-Green Deploy
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    steps:
      - uses: actions/checkout@v4

      - name: 🔍 Determine Active Color
        id: active
        run: |
          ACTIVE=$(kubectl get service ecommerce-active -n ecommerce-${{ inputs.environment }} \
            -o jsonpath='{.spec.selector.color}' || echo "blue")
          INACTIVE=$([ "$ACTIVE" = "blue" ] && echo "green" || echo "blue")
          
          echo "active=$ACTIVE" >> $GITHUB_OUTPUT
          echo "inactive=$INACTIVE" >> $GITHUB_OUTPUT
          echo "Active: $ACTIVE, Deploying to: $INACTIVE"

      - name: 🚀 Deploy to Inactive
        run: |
          helm upgrade --install ecommerce-${{ steps.active.outputs.inactive }} \
            ./charts/ecommerce \
            --namespace ecommerce-${{ inputs.environment }} \
            --values ./charts/ecommerce/values-${{ inputs.environment }}.yaml \
            --set deployment.color=${{ steps.active.outputs.inactive }} \
            --set service.selector.color=${{ steps.active.outputs.inactive }}

      - name: 🧪 Test Inactive Deployment
        run: |
          kubectl port-forward \
            service/ecommerce-${{ steps.active.outputs.inactive }} \
            8080:80 \
            -n ecommerce-${{ inputs.environment }} &
          
          sleep 5
          ./scripts/smoke-test.sh http://localhost:8080

      - name: 🔄 Switch Traffic
        run: |
          kubectl patch service ecommerce-active \
            -n ecommerce-${{ inputs.environment }} \
            -p '{"spec":{"selector":{"color":"${{ steps.active.outputs.inactive }}"}}}'

      - name: 🧪 Verify Switch
        run: |
          ./scripts/verify-deployment.sh ${{ inputs.environment }}

      - name: 🗑️ Cleanup Old Deployment
        if: success()
        run: |
          sleep 300  # Wait 5 minutes
          helm uninstall ecommerce-${{ steps.active.outputs.active }} \
            -n ecommerce-${{ inputs.environment }}
```

## 📈 Métricas e Relatórios {#metricas-relatorios}

### Pipeline Metrics Dashboard

```yaml
# .github/workflows/pipeline-metrics.yml
name: 📈 Pipeline Metrics

on:
  workflow_run:
    workflows: ["Main CI/CD Pipeline"]
    types: [completed]

jobs:
  collect-metrics:
    name: 📊 Collect Metrics
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: 📊 Calculate Metrics
        run: |
          # Lead Time
          COMMIT_TIME=$(git show -s --format=%ct ${{ github.sha }})
          DEPLOY_TIME=$(date +%s)
          LEAD_TIME=$((($DEPLOY_TIME - $COMMIT_TIME) / 60))
          
          # Deployment Frequency
          DEPLOYS_TODAY=$(gh run list --workflow "main-pipeline.yml" \
            --created "$(date -u +%Y-%m-%d)" --json conclusion \
            | jq '[.[] | select(.conclusion == "success")] | length')
          
          # MTTR (Mock data for demo)
          MTTR=30
          
          # Change Failure Rate
          TOTAL_DEPLOYS=$(gh run list --workflow "main-pipeline.yml" \
            --limit 100 --json conclusion | jq length)
          FAILED_DEPLOYS=$(gh run list --workflow "main-pipeline.yml" \
            --limit 100 --json conclusion \
            | jq '[.[] | select(.conclusion == "failure")] | length')
          FAILURE_RATE=$(echo "scale=2; $FAILED_DEPLOYS * 100 / $TOTAL_DEPLOYS" | bc)
          
          echo "📊 DORA Metrics:"
          echo "- Lead Time: ${LEAD_TIME} minutes"
          echo "- Deployment Frequency: ${DEPLOYS_TODAY} today"
          echo "- MTTR: ${MTTR} minutes"
          echo "- Change Failure Rate: ${FAILURE_RATE}%"

      - name: 📤 Send to DataDog
        run: |
          curl -X POST "https://api.datadoghq.com/api/v1/series" \
            -H "Content-Type: application/json" \
            -H "DD-API-KEY: ${{ secrets.DATADOG_API_KEY }}" \
            -d @- << EOF
          {
            "series": [{
              "metric": "pipeline.lead_time",
              "points": [[$(date +%s), $LEAD_TIME]],
              "type": "gauge",
              "tags": ["env:${{ inputs.environment }}", "repo:${{ github.repository }}"]
            }]
          }
          EOF

      - name: 📋 Generate Report
        uses: actions/github-script@v7
        with:
          script: |
            const report = `## 📊 Pipeline Metrics Report
            
            **Run:** ${{ github.run_number }}
            **Commit:** ${{ github.sha }}
            
            ### DORA Metrics
            | Metric | Value | Target | Status |
            |--------|-------|--------|--------|
            | Lead Time | ${process.env.LEAD_TIME} min | < 60 min | ${process.env.LEAD_TIME < 60 ? '✅' : '❌'} |
            | Deploy Frequency | ${process.env.DEPLOYS_TODAY}/day | > 1/day | ${process.env.DEPLOYS_TODAY >= 1 ? '✅' : '❌'} |
            | MTTR | ${process.env.MTTR} min | < 60 min | ✅ |
            | Change Failure Rate | ${process.env.FAILURE_RATE}% | < 15% | ${process.env.FAILURE_RATE < 15 ? '✅' : '❌'} |
            `;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: report
            });
```

## 🔄 Integração com Developer Hub {#integracao-hub}

### Atualização Automática do Catálogo

```yaml
# .github/workflows/update-backstage.yml
name: 🔄 Update Developer Hub

on:
  workflow_call:
    inputs:
      entity:
        required: true
        type: string
      status:
        required: true
        type: string

jobs:
  update:
    name: 📝 Update Catalog
    runs-on: ubuntu-latest
    steps:
      - name: 🔄 Update Entity
        run: |
          curl -X PATCH \
            "https://backstage-rhdh.apps.threehorizons.io/api/catalog/entities/by-name/component/default/${{ inputs.entity }}" \
            -H "Authorization: Bearer ${{ secrets.BACKSTAGE_TOKEN }}" \
            -H "Content-Type: application/json" \
            -d '{
              "metadata": {
                "annotations": {
                  "github.com/project-slug": "${{ github.repository }}",
                  "github.com/last-build": "${{ github.sha }}",
                  "github.com/build-status": "${{ inputs.status }}",
                  "github.com/build-url": "${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}",
                  "threehorizons.io/deployment-status": "${{ inputs.status }}",
                  "threehorizons.io/last-deployed": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
                }
              }
            }'

      - name: 📊 Send TechInsights
        run: |
          curl -X POST \
            "https://backstage-rhdh.apps.threehorizons.io/api/tech-insights/fact-schemas/deployment-frequency/facts" \
            -H "Authorization: Bearer ${{ secrets.BACKSTAGE_TOKEN }}" \
            -H "Content-Type: application/json" \
            -d '{
              "entity": "component:default/${{ inputs.entity }}",
              "facts": {
                "deploymentCount": 1,
                "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
              }
            }'
```

### Custom Actions para Backstage

```typescript
// .github/actions/update-backstage/action.yml
name: 'Update Backstage Catalog'
description: 'Updates entity in Backstage catalog with deployment info'
inputs:
  entity:
    description: 'Entity name'
    required: true
  annotations:
    description: 'Annotations to update (YAML format)'
    required: true
  backstage-url:
    description: 'Backstage URL'
    default: 'https://backstage-rhdh.apps.threehorizons.io'
  token:
    description: 'Backstage API token'
    required: true

runs:
  using: 'composite'
  steps:
    - name: Parse and Update
      shell: bash
      run: |
        # Convert YAML to JSON
        ANNOTATIONS=$(echo "${{ inputs.annotations }}" | yq -o=json '.')
        
        # Update entity
        curl -X PATCH \
          "${{ inputs.backstage-url }}/api/catalog/entities/by-name/${{ inputs.entity }}" \
          -H "Authorization: Bearer ${{ inputs.token }}" \
          -H "Content-Type: application/json" \
          -d "{
            \"metadata\": {
              \"annotations\": $ANNOTATIONS
            }
          }"
```

---

## 🎯 Próximos Passos

Com o CI/CD configurado, siga para:

1. **[H1-007-G: GitOps Deployment](./H1-007-G-gitops-deployment.md)** - Implementar GitOps
2. **[H1-007-H: Monitoring Setup](./H1-007-H-monitoring-setup.md)** - Configurar monitoramento

---

**📝 Checklist CI/CD**

- [ ] GitHub Actions workflows criados
- [ ] Build de containers otimizado
- [ ] Testes automatizados configurados
- [ ] Segurança integrada no pipeline
- [ ] Quality gates implementados
- [ ] Deploy automatizado funcionando
- [ ] Métricas sendo coletadas
- [ ] Integração com Developer Hub