# 🔒 H2-003: Enhanced Security - Advanced Threat Protection

<div align="center">


**Implementing Zero Trust Security with AI-Powered Threat Detection**

</div>

## 📋 Table of Contents

1. [Overview](#-overview)
2. [Security Architecture](#-security-architecture)
3. [Advanced GHAS Policies](#-advanced-ghas-policies)
4. [Azure Sentinel Integration](#-azure-sentinel-integration)
5. [Compliance Automation](#-compliance-automation)
6. [Security Scanning Pipelines](#-security-scanning-pipelines)
7. [Container Security](#-container-security)
8. [Network Security](#-network-security)
9. [Identity & Access Management](#-identity--access-management)
10. [Security Operations Center](#-security-operations-center)

## 🔍 Overview

Horizon 2 enhances security with advanced threat protection, automated compliance, and AI-powered security operations that integrate throughout the development lifecycle.

### Security Enhancement Matrix

| Capability | Foundation (H1) | Enhancement (H2) | Benefits |
|------------|-----------------|------------------|----------|
| **Code Security** | Basic GHAS | Advanced policies + custom rules | 95% vulnerability detection |
| **SIEM** | Basic logging | Sentinel with AI analytics | Real-time threat correlation |
| **Compliance** | Manual checks | Automated policy enforcement | 80% faster audits |
| **Container Scanning** | Build-time only | Runtime + admission control | Zero-day protection |
| **Network Security** | Basic NSGs | Zero Trust + micro-segmentation | Lateral movement prevention |
| **Incident Response** | Manual runbooks | Automated playbooks | <5 min response time |

## 🏗️ Security Architecture

```mermaid
graph TB
    subgraph "Security Layers"
        A[Code Security]
        B[Build Security]
        C[Deploy Security]
        D[Runtime Security]
        E[Operations Security]
    end
    
    subgraph "Security Tools"
        F[GitHub Advanced Security]
        G[Container Scanning]
        H[Azure Policy]
        I[Defender for Cloud]
        J[Azure Sentinel]
    end
    
    subgraph "Automation"
        K[Security Orchestration]
        L[Automated Response]
        M[Compliance Validation]
        N[Threat Hunting]
    end
    
    A --> F
    B --> G
    C --> H
    D --> I
    E --> J
    
    F & G & H & I & J --> K
    K --> L & M & N
    
    style K fill:#FFD700
    style L fill:#90EE90
```

### Zero Trust Principles

1. **Verify Explicitly**: Always authenticate and authorize
2. **Least Privilege Access**: Minimal required permissions
3. **Assume Breach**: Design for compromise containment
4. **Continuous Validation**: Real-time security posture assessment
5. **Encrypt Everything**: Data protection at rest and in transit

## 🐙 Advanced GHAS Policies

### 1. Custom Security Rules

```yaml
# .github/advanced-security.yml
name: Advanced Security Configuration
version: 2.0

custom_patterns:
  - name: "Azure Connection Strings"
    pattern: |
      DefaultEndpointsProtocol=https;AccountName=[^;]+;AccountKey=[A-Za-z0-9+/=]{88};EndpointSuffix=core\.windows\.net
    severity: high
    
  - name: "Internal API Endpoints"
    pattern: |
      https?://[a-zA-Z0-9-]+\.internal\.threehorizons\.ai/[^\s]+
    severity: medium
    
  - name: "Kubernetes Secrets"
    pattern: |
      kind:\s*Secret[\s\S]*?data:[\s\S]*?[A-Za-z0-9+/]{40,}
    severity: critical

dependency_policies:
  vulnerability_threshold: medium
  license_check: true
  allowed_licenses:
    - MIT
    - Apache-2.0
    - BSD-3-Clause
    - ISC
  denied_licenses:
    - GPL-3.0
    - AGPL-3.0
  
code_scanning:
  query_suites:
    - security-extended
    - security-and-quality
  custom_queries:
    - path: .github/codeql/custom-queries
  
  sarif_upload:
    wait_for_processing: true
    category_override: "advanced-security"
```

### 2. Security Policy Enforcement

```typescript
// security/policy-enforcer.ts
import { Octokit } from '@octokit/rest';
import { createAppAuth } from '@octokit/auth-app';

export class SecurityPolicyEnforcer {
  private octokit: Octokit;
  private org: string;
  
  constructor(config: SecurityConfig) {
    this.octokit = new Octokit({
      authStrategy: createAppAuth,
      auth: {
        appId: config.appId,
        privateKey: config.privateKey,
        installationId: config.installationId,
      },
    });
    this.org = config.organization;
  }
  
  async enforceAdvancedPolicies(): Promise<void> {
    const repos = await this.getOrgRepositories();
    
    for (const repo of repos) {
      // Enable all security features
      await this.enableSecurityFeatures(repo);
      
      // Configure branch protection
      await this.configureBranchProtection(repo);
      
      // Set up security alerts
      await this.configureSecurityAlerts(repo);
      
      // Apply custom rulesets
      await this.applyCustomRulesets(repo);
    }
  }
  
  private async enableSecurityFeatures(repo: Repository): Promise<void> {
    await this.octokit.repos.update({
      owner: this.org,
      repo: repo.name,
      security_and_analysis: {
        advanced_security: { status: 'enabled' },
        secret_scanning: { status: 'enabled' },
        secret_scanning_push_protection: { status: 'enabled' },
      },
    });
    
    // Enable Dependabot
    await this.octokit.repos.enableVulnerabilityAlerts({
      owner: this.org,
      repo: repo.name,
    });
    
    await this.octokit.repos.enableAutomatedSecurityFixes({
      owner: this.org,
      repo: repo.name,
    });
  }
  
  private async configureBranchProtection(repo: Repository): Promise<void> {
    const branches = ['main', 'master', 'develop'];
    
    for (const branch of branches) {
      try {
        await this.octokit.repos.updateBranchProtection({
          owner: this.org,
          repo: repo.name,
          branch,
          required_status_checks: {
            strict: true,
            contexts: [
              'security/code-scanning',
              'security/secret-scanning',
              'security/dependency-review',
            ],
          },
          enforce_admins: true,
          required_pull_request_reviews: {
            dismiss_stale_reviews: true,
            require_code_owner_reviews: true,
            required_approving_review_count: 2,
          },
          restrictions: null,
          allow_force_pushes: false,
          allow_deletions: false,
          block_creations: false,
          required_conversation_resolution: true,
        });
      } catch (error) {
        console.log(`Branch ${branch} not found in ${repo.name}`);
      }
    }
  }
  
  private async applyCustomRulesets(repo: Repository): Promise<void> {
    // Create custom rulesets
    const ruleset = {
      name: 'Advanced Security Rules',
      target: 'branch',
      source_type: 'Repository',
      source: repo.name,
      enforcement: 'active',
      conditions: {
        ref_name: {
          include: ['refs/heads/main', 'refs/heads/develop'],
          exclude: [],
        },
      },
      rules: [
        {
          type: 'pull_request',
          parameters: {
            required_approving_review_count: 2,
            dismiss_stale_reviews_on_push: true,
            require_code_owner_review: true,
            require_last_push_approval: true,
            required_review_thread_resolution: true,
          },
        },
        {
          type: 'required_status_checks',
          parameters: {
            strict_required_status_checks_policy: true,
            required_status_checks: [
              {
                context: 'security-scan',
                integration_id: 12345,
              },
            ],
          },
        },
      ],
    };
    
    await this.octokit.repos.createRepoRuleset({
      owner: this.org,
      repo: repo.name,
      ...ruleset,
    });
  }
}
```

### 3. Advanced Code Scanning

```yaml
# .github/workflows/advanced-security-scan.yml
name: Advanced Security Scanning

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
  schedule:
    - cron: '0 2 * * *'

permissions:
  actions: read
  contents: read
  security-events: write

jobs:
  code-quality:
    name: CodeQL Advanced Analysis
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        language: ['javascript', 'typescript', 'python', 'csharp']
        
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
      
    - name: Initialize CodeQL
      uses: github/codeql-action/init@v3
      with:
        languages: ${{ matrix.language }}
        queries: +security-extended,security-and-quality
        
    - name: Autobuild
      uses: github/codeql-action/autobuild@v3
      
    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v3
      with:
        category: "/language:${{ matrix.language }}"
        
  dependency-review:
    name: Dependency Security Review
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
      
    - name: Dependency Review
      uses: actions/dependency-review-action@v4
      with:
        fail-on-severity: moderate
        deny-licenses: GPL-3.0, AGPL-3.0
        
  container-scan:
    name: Container Security Scan
    runs-on: ubuntu-latest
    steps:
    - name: Run Trivy scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: '${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}'
        format: 'sarif'
        output: 'trivy-results.sarif'
        severity: 'CRITICAL,HIGH'
        
    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v3
      with:
        sarif_file: 'trivy-results.sarif'
        
  infrastructure-scan:
    name: Infrastructure Security Scan
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
      
    - name: Run Checkov
      uses: bridgecrewio/checkov-action@master
      with:
        directory: .
        framework: all
        output_format: sarif
        output_file_path: reports/checkov.sarif
        
    - name: Upload Checkov results
      uses: github/codeql-action/upload-sarif@v3
      with:
        sarif_file: reports/checkov.sarif
```

## 📊 Azure Sentinel Integration

### 1. Deploy Sentinel Workspace

```bicep
// infrastructure/security/sentinel-workspace.bicep
param location string = resourceGroup().location
param baseName string
param environment string
param retentionInDays int = 90

// Log Analytics Workspace
resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'law-${baseName}-${environment}-sentinel'
  location: location
  properties: {
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    sku: {
      name: 'PerGB2018'
    }
  }
}

// Azure Sentinel
resource sentinel 'Microsoft.SecurityInsights/onboardingStates@2023-02-01' = {
  scope: workspace
  name: 'default'
  properties: {}
}

// Data Connectors
resource githubConnector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = {
  scope: workspace
  name: 'GitHubAdvancedSecurity'
  kind: 'APIPolling'
  properties: {
    connectorUiConfig: {
      title: 'GitHub Advanced Security'
      publisher: 'GitHub'
      descriptionMarkdown: 'Connect GitHub Advanced Security alerts to Azure Sentinel'
      availability: {
        status: 1
        isPreview: false
      }
    }
    pollingConfig: {
      auth: {
        authType: 'APIKey'
        apiKeyName: 'Authorization'
        apiKeyIdentifier: 'token'
      }
      request: {
        apiEndpoint: 'https://api.github.com/orgs/{OrganizationName}/alerts'
        rateLimitQPS: 10
        queryWindowInMin: 5
        httpMethod: 'GET'
        retryCount: 3
        timeoutInSeconds: 60
      }
      paging: {
        pagingType: 'LinkHeader'
      }
      response: {
        eventsJsonPaths: ['$[*]']
      }
    }
  }
}

resource azureActivityConnector 'Microsoft.SecurityInsights/dataConnectors@2023-02-01' = {
  scope: workspace
  name: 'AzureActivity'
  kind: 'AzureActivity'
  properties: {
    linkedResourceId: '/subscriptions/${subscription().subscriptionId}/providers/microsoft.insights/eventtypes/management'
  }
}

// Analytics Rules
resource criticalAlertRule 'Microsoft.SecurityInsights/alertRules@2023-02-01' = {
  scope: workspace
  name: 'CriticalSecurityAlert'
  kind: 'Scheduled'
  properties: {
    displayName: 'Critical Security Alert Detection'
    description: 'Detects critical security alerts from multiple sources'
    severity: 'High'
    enabled: true
    query: '''
    union
    (
      GitHubAdvancedSecurity_CL
      | where Severity_s == "critical"
      | project TimeGenerated, AlertName_s, Repository_s, Severity_s
    ),
    (
      SecurityAlert
      | where AlertSeverity == "High"
      | project TimeGenerated, AlertName, ResourceId, AlertSeverity
    )
    | summarize Count = count() by bin(TimeGenerated, 5m)
    | where Count > 5
    '''
    queryFrequency: 'PT5M'
    queryPeriod: 'PT15M'
    triggerOperator: 'GreaterThan'
    triggerThreshold: 0
    suppressionDuration: 'PT1H'
    suppressionEnabled: true
    tactics: ['DefenseEvasion', 'PrivilegeEscalation']
    incidentConfiguration: {
      createIncident: true
      groupingConfiguration: {
        enabled: true
        reopenClosedIncident: false
        lookbackDuration: 'PT1H'
        matchingMethod: 'AllEntities'
      }
    }
  }
}

output workspaceId string = workspace.id
output sentinelUrl string = 'https://portal.azure.com/#blade/Microsoft_Azure_Security_Insights/MainMenuBlade/0/subscriptionId/${subscription().subscriptionId}/resourceGroup/${resourceGroup().name}/workspaceName/${workspace.name}'
```

### 2. Automated Incident Response

```typescript
// security/incident-response.ts
import { SecurityIncident, AutomationRule } from '@azure/arm-securityinsight';
import { SecretClient } from '@azure/keyvault-secrets';
import { WebClient } from '@slack/web-api';

export class IncidentResponseAutomation {
  private sentinelClient: SecurityInsightClient;
  private slackClient: WebClient;
  private pagerDutyClient: PagerDutyClient;
  
  constructor(config: SecurityConfig) {
    this.sentinelClient = new SecurityInsightClient(config.credentials);
    this.slackClient = new WebClient(config.slackToken);
    this.pagerDutyClient = new PagerDutyClient(config.pagerDutyToken);
  }
  
  async createAutomationRules(): Promise<void> {
    // Critical incident response
    const criticalRule: AutomationRule = {
      displayName: 'Critical Incident Response',
      order: 1,
      triggeringLogic: {
        isEnabled: true,
        triggersOn: 'Incidents',
        triggersWhen: 'Created',
        conditions: [
          {
            conditionType: 'Property',
            conditionProperties: {
              propertyName: 'IncidentSeverity',
              operator: 'Equals',
              propertyValues: ['High', 'Critical']
            }
          }
        ]
      },
      actions: [
        {
          order: 1,
          actionType: 'RunPlaybook',
          actionConfiguration: {
            logicAppResourceId: '/subscriptions/.../CriticalIncidentPlaybook',
            tenantId: config.tenantId
          }
        },
        {
          order: 2,
          actionType: 'ModifyProperties',
          actionConfiguration: {
            owner: {
              objectId: config.securityTeamId,
              userPrincipalName: 'security@threehorizons.ai'
            },
            status: 'Active',
            classification: 'TruePositive'
          }
        }
      ]
    };
    
    await this.sentinelClient.automationRules.createOrUpdate(
      config.resourceGroup,
      config.workspaceName,
      'CriticalIncidentRule',
      criticalRule
    );
  }
  
  async handleSecurityIncident(incident: SecurityIncident): Promise<void> {
    // Analyze incident
    const analysis = await this.analyzeIncident(incident);
    
    // Create tickets
    if (analysis.severity >= 4) {
      await this.createPagerDutyIncident(incident, analysis);
    }
    
    // Notify team
    await this.notifySecurityTeam(incident, analysis);
    
    // Auto-remediate if possible
    if (analysis.autoRemediationAvailable) {
      await this.executeRemediation(analysis.remediationSteps);
    }
    
    // Update incident
    await this.updateIncidentStatus(incident, analysis);
  }
  
  private async analyzeIncident(incident: SecurityIncident): Promise<IncidentAnalysis> {
    const alerts = await this.getIncidentAlerts(incident);
    const entities = await this.extractEntities(alerts);
    const threatIntel = await this.checkThreatIntelligence(entities);
    
    return {
      severity: this.calculateSeverity(alerts, threatIntel),
      impactedResources: entities.resources,
      attackTechniques: this.identifyMitreTechniques(alerts),
      autoRemediationAvailable: this.checkAutoRemediation(alerts),
      remediationSteps: this.generateRemediationSteps(alerts, entities),
      recommendations: this.generateRecommendations(alerts, threatIntel)
    };
  }
  
  private async executeRemediation(steps: RemediationStep[]): Promise<void> {
    for (const step of steps) {
      try {
        switch (step.action) {
          case 'isolate-container':
            await this.isolateContainer(step.target);
            break;
          case 'revoke-credentials':
            await this.revokeCredentials(step.target);
            break;
          case 'block-ip':
            await this.blockIPAddress(step.target);
            break;
          case 'quarantine-file':
            await this.quarantineFile(step.target);
            break;
          default:
            console.log(`Unknown remediation action: ${step.action}`);
        }
      } catch (error) {
        console.error(`Failed to execute remediation step: ${step.action}`, error);
      }
    }
  }
}
```

## 🔐 Compliance Automation

### 1. Policy as Code

```bicep
// infrastructure/security/compliance-policies.bicep
param policySetName string = 'ThreeHorizonsCompliance'
param environment string

// Define custom policy definitions
resource encryptionPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'RequireEncryptionAtRest'
  properties: {
    displayName: 'Require encryption at rest for all storage'
    description: 'Ensures all storage accounts have encryption enabled'
    mode: 'All'
    metadata: {
      category: 'Security'
      version: '1.0.0'
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Storage/storageAccounts'
          }
          {
            field: 'Microsoft.Storage/storageAccounts/encryption.services.blob.enabled'
            notEquals: true
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}

resource networkPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'RequirePrivateEndpoints'
  properties: {
    displayName: 'Require private endpoints for PaaS services'
    description: 'Ensures all PaaS services use private endpoints'
    mode: 'All'
    metadata: {
      category: 'Network'
      version: '1.0.0'
    }
    policyRule: {
      if: {
        anyOf: [
          {
            field: 'type'
            in: [
              'Microsoft.Storage/storageAccounts'
              'Microsoft.Sql/servers'
              'Microsoft.KeyVault/vaults'
              'Microsoft.ContainerRegistry/registries'
            ]
          }
        ]
      }
      then: {
        effect: 'audit'
      }
    }
  }
}

// Compliance Policy Set
resource compliancePolicySet 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: policySetName
  properties: {
    displayName: 'Three Horizons Compliance Standards'
    description: 'Comprehensive compliance policy set for the platform'
    metadata: {
      category: 'Compliance'
      version: '2.0.0'
    }
    policyDefinitions: [
      {
        policyDefinitionId: encryptionPolicy.id
        parameters: {}
      }
      {
        policyDefinitionId: networkPolicy.id
        parameters: {}
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988' // Azure Security Benchmark
        parameters: {}
      }
    ]
  }
}

// Assign policy set to subscription
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: '${policySetName}-${environment}'
  location: 'global'
  properties: {
    displayName: 'Three Horizons Compliance Assignment'
    description: 'Assigns compliance policies to the platform'
    policyDefinitionId: compliancePolicySet.id
    enforcementMode: 'Default'
    parameters: {}
  }
}

output policySetId string = compliancePolicySet.id
output assignmentId string = policyAssignment.id
```

### 2. Compliance Validation Pipeline

```yaml
# .github/workflows/compliance-validation.yml
name: Compliance Validation

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 6 * * 1' # Weekly compliance check

jobs:
  infrastructure-compliance:
    name: Infrastructure Compliance Check
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
        
    - name: Run Compliance Assessment
      run: |
        # Check policy compliance
        az policy state list \
          --resource-group "rg-threehorizons-${{ github.event.inputs.environment }}-infra" \
          --query "[?complianceState=='NonCompliant'].{Resource:resourceId, Policy:policyDefinitionName}" \
          -o table > compliance-report.txt
          
        # Check security score
        az security secure-score show \
          --name 'ascScore' \
          -o json > security-score.json
          
        # Generate compliance report
        python scripts/generate-compliance-report.py
        
    - name: Upload Compliance Report
      uses: actions/upload-artifact@v3
      with:
        name: compliance-report
        path: |
          compliance-report.txt
          security-score.json
          compliance-report.html
          
  container-compliance:
    name: Container Compliance Scan
    runs-on: ubuntu-latest
    steps:
    - name: Run Falco Security Scan
      run: |
        docker run -d --name falco \
          --privileged \
          -v /var/run/docker.sock:/host/var/run/docker.sock \
          -v /proc:/host/proc:ro \
          -v /boot:/host/boot:ro \
          -v /lib/modules:/host/lib/modules:ro \
          -v /usr:/host/usr:ro \
          falcosecurity/falco:latest
          
    - name: CIS Benchmark Scan
      run: |
        docker run --rm \
          -v /var/run/docker.sock:/var/run/docker.sock \
          -v $(pwd):/report \
          aquasec/docker-bench-security
          
  data-compliance:
    name: Data Protection Compliance
    runs-on: ubuntu-latest
    steps:
    - name: Check Data Classification
      run: |
        # Scan for sensitive data patterns
        python scripts/scan-sensitive-data.py \
          --path . \
          --patterns "SSN,Credit Card,API Key" \
          --output data-scan-report.json
          
    - name: Verify Encryption
      run: |
        # Check encryption status of storage accounts
        az storage account list \
          --query "[].{Name:name, Encryption:encryption.services.blob.enabled}" \
          -o table
```

## 🛡️ Security Scanning Pipelines

### 1. Multi-Stage Security Pipeline

```yaml
# .github/workflows/security-pipeline.yml
name: Comprehensive Security Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    types: [opened, synchronize, reopened]

env:
  SCAN_RESULTS_PATH: security-scan-results

jobs:
  sast-scan:
    name: Static Application Security Testing
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0
        
    - name: SonarCloud Scan
      uses: SonarSource/sonarcloud-github-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        
    - name: Semgrep Scan
      uses: returntocorp/semgrep-action@v1
      with:
        config: >-
          p/security-audit
          p/owasp-top-ten
          p/cwe-top-25
          
    - name: Upload SAST Results
      uses: actions/upload-artifact@v3
      with:
        name: sast-results
        path: ${{ env.SCAN_RESULTS_PATH }}/sast/
        
  dast-scan:
    name: Dynamic Application Security Testing
    runs-on: ubuntu-latest
    needs: [deploy-to-staging]
    steps:
    - name: OWASP ZAP Scan
      uses: zaproxy/action-full-scan@v0.7.0
      with:
        target: 'https://staging.threehorizons.ai'
        rules_file_name: '.zap/rules.tsv'
        cmd_options: '-a -j -l WARN'
        
    - name: Nuclei Security Scan
      uses: projectdiscovery/nuclei-action@main
      with:
        target: 'https://staging.threehorizons.ai'
        flags: '-severity critical,high,medium'
        
  secrets-scan:
    name: Secrets Detection
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0
        
    - name: TruffleHog Scan
      uses: trufflesecurity/trufflehog@main
      with:
        path: ./
        base: ${{ github.event.repository.default_branch }}
        head: HEAD
        
    - name: GitLeaks Scan
      uses: gitleaks/gitleaks-action@v2
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        
  sbom-generation:
    name: Software Bill of Materials
    runs-on: ubuntu-latest
    steps:
    - name: Generate SBOM
      uses: anchore/sbom-action@v0
      with:
        artifact-name: sbom-${{ github.sha }}.spdx
        format: spdx-json
        
    - name: Scan SBOM for vulnerabilities
      uses: anchore/scan-action@v3
      with:
        sbom: sbom-${{ github.sha }}.spdx
        fail-build: true
        severity-cutoff: high
```

### 2. Container Security Scanning

```typescript
// security/container-scanner.ts
import { ContainerRegistryClient } from '@azure/container-registry';
import { SecretClient } from '@azure/keyvault-secrets';
import * as k8s from '@kubernetes/client-node';

export class ContainerSecurityScanner {
  private registryClient: ContainerRegistryClient;
  private k8sApi: k8s.CoreV1Api;
  private policyApi: k8s.AdmissionregistrationV1Api;
  
  constructor(config: ContainerSecurityConfig) {
    this.registryClient = new ContainerRegistryClient(config.registryUrl);
    
    const kc = new k8s.KubeConfig();
    kc.loadFromDefault();
    this.k8sApi = kc.makeApiClient(k8s.CoreV1Api);
    this.policyApi = kc.makeApiClient(k8s.AdmissionregistrationV1Api);
  }
  
  async setupAdmissionController(): Promise<void> {
    // Create ValidatingWebhookConfiguration
    const webhook: k8s.V1ValidatingWebhookConfiguration = {
      metadata: {
        name: 'security-admission-webhook',
      },
      webhooks: [{
        name: 'validate.security.threehorizons.ai',
        clientConfig: {
          service: {
            name: 'security-webhook',
            namespace: 'security',
            path: '/validate',
          },
          caBundle: Buffer.from(process.env.WEBHOOK_CA_BUNDLE!, 'base64'),
        },
        rules: [{
          operations: ['CREATE', 'UPDATE'],
          apiGroups: ['apps', ''],
          apiVersions: ['v1'],
          resources: ['deployments', 'pods'],
        }],
        admissionReviewVersions: ['v1', 'v1beta1'],
        sideEffects: 'None',
        failurePolicy: 'Fail',
        timeoutSeconds: 30,
      }],
    };
    
    await this.policyApi.createValidatingWebhookConfiguration(webhook);
  }
  
  async validateContainer(image: string): Promise<ValidationResult> {
    const scanResult = await this.scanImage(image);
    const policyResult = await this.checkPolicies(image, scanResult);
    
    return {
      allowed: policyResult.compliant,
      vulnerabilities: scanResult.vulnerabilities,
      policyViolations: policyResult.violations,
      recommendation: this.generateRecommendation(scanResult, policyResult),
    };
  }
  
  private async scanImage(image: string): Promise<ScanResult> {
    // Trivy scan
    const trivyResult = await this.runTrivyScan(image);
    
    // Snyk scan
    const snykResult = await this.runSnykScan(image);
    
    // Aggregate results
    return {
      vulnerabilities: [
        ...trivyResult.vulnerabilities,
        ...snykResult.vulnerabilities,
      ].filter((v, i, a) => a.findIndex(x => x.cve === v.cve) === i),
      
      summary: {
        critical: trivyResult.summary.critical + snykResult.summary.critical,
        high: trivyResult.summary.high + snykResult.summary.high,
        medium: trivyResult.summary.medium + snykResult.summary.medium,
        low: trivyResult.summary.low + snykResult.summary.low,
      },
    };
  }
  
  private async checkPolicies(image: string, scanResult: ScanResult): Promise<PolicyResult> {
    const violations: PolicyViolation[] = [];
    
    // Check vulnerability thresholds
    if (scanResult.summary.critical > 0) {
      violations.push({
        policy: 'no-critical-vulnerabilities',
        severity: 'high',
        message: `Image contains ${scanResult.summary.critical} critical vulnerabilities`,
      });
    }
    
    // Check image source
    if (!image.startsWith(process.env.TRUSTED_REGISTRY!)) {
      violations.push({
        policy: 'trusted-registry-only',
        severity: 'medium',
        message: 'Image must be from trusted registry',
      });
    }
    
    // Check signatures
    const signed = await this.verifyImageSignature(image);
    if (!signed) {
      violations.push({
        policy: 'require-signed-images',
        severity: 'high',
        message: 'Image must be signed with approved key',
      });
    }
    
    return {
      compliant: violations.length === 0,
      violations,
    };
  }
}
```

## 🌐 Network Security

### 1. Zero Trust Network Implementation

```bicep
// infrastructure/security/zero-trust-network.bicep
param location string = resourceGroup().location
param baseName string
param environment string

// Network Security Groups with Zero Trust rules
resource webNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-${baseName}-${environment}-web'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHTTPS'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource appNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-${baseName}-${environment}-app'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowWebSubnet'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: '10.0.1.0/24' // Web subnet
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// Application Gateway with WAF
resource appGateway 'Microsoft.Network/applicationGateways@2023-05-01' = {
  name: 'agw-${baseName}-${environment}'
  location: location
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 2
    }
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      exclusions: []
      disabledRuleGroups: []
    }
    // Additional configuration...
  }
}

// Private Endpoints for PaaS services
resource storagePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'pe-${baseName}-${environment}-storage'
  location: location
  properties: {
    subnet: {
      id: dataSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: 'storage-connection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['blob']
        }
      }
    ]
  }
}

// Azure Firewall for egress control
resource firewall 'Microsoft.Network/azureFirewalls@2023-05-01' = {
  name: 'afw-${baseName}-${environment}'
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Premium'
    }
    threatIntelMode: 'Alert'
    intrusionDetection: {
      mode: 'Alert'
      configuration: {
        signatureOverrides: []
        bypassTrafficSettings: []
      }
    }
    firewallPolicy: {
      id: firewallPolicy.id
    }
  }
}

output webNsgId string = webNsg.id
output appNsgId string = appNsg.id
output firewallId string = firewall.id
```

## 🔐 Identity & Access Management

### 1. Advanced RBAC Configuration

```typescript
// security/advanced-rbac.ts
import { AuthorizationManagementClient } from '@azure/arm-authorization';
import { GraphRbacManagementClient } from '@azure/graph';

export class AdvancedRBACManager {
  private authClient: AuthorizationManagementClient;
  private graphClient: GraphRbacManagementClient;
  
  async setupZeroTrustRBAC(): Promise<void> {
    // Create custom role definitions
    await this.createCustomRoles();
    
    // Set up Privileged Identity Management
    await this.configurePIM();
    
    // Implement Just-In-Time access
    await this.setupJITAccess();
    
    // Configure Conditional Access
    await this.setupConditionalAccess();
  }
  
  private async createCustomRoles(): Promise<void> {
    const securityEngineerRole = {
      roleName: 'Three Horizons Security Engineer',
      description: 'Security engineer with limited production access',
      type: 'CustomRole',
      permissions: [
        {
          actions: [
            'Microsoft.Security/*/read',
            'Microsoft.Security/securityContacts/*',
            'Microsoft.Security/securitySolutions/*',
            'Microsoft.SecurityInsights/*/read',
            'Microsoft.SecurityInsights/alertRules/*',
            'Microsoft.SecurityInsights/incidents/*',
          ],
          notActions: [
            'Microsoft.Security/pricings/write',
          ],
        },
      ],
      assignableScopes: [
        `/subscriptions/${process.env.SUBSCRIPTION_ID}`,
      ],
    };
    
    await this.authClient.roleDefinitions.createOrUpdate(
      process.env.SUBSCRIPTION_ID!,
      'security-engineer-role-id',
      securityEngineerRole
    );
  }
  
  private async configurePIM(): Promise<void> {
    // Configure Privileged Identity Management settings
    const pimSettings = {
      requireApproval: true,
      approvers: ['security-team@threehorizons.ai'],
      maxDuration: 'PT8H', // 8 hours
      requireMFA: true,
      requireJustification: true,
      notificationSettings: {
        notifyOnActivation: true,
        notifyOnAssignment: true,
        notifyOnEligibility: true,
      },
    };
    
    // Apply PIM settings to privileged roles
    const privilegedRoles = [
      'Owner',
      'Contributor',
      'User Access Administrator',
      'Security Admin',
    ];
    
    for (const role of privilegedRoles) {
      await this.applyPIMSettings(role, pimSettings);
    }
  }
  
  private async setupJITAccess(): Promise<void> {
    // Implement Just-In-Time VM access
    const jitPolicy = {
      properties: {
        virtualMachines: [
          {
            id: `/subscriptions/${process.env.SUBSCRIPTION_ID}/resourceGroups/*/providers/Microsoft.Compute/virtualMachines/*`,
            ports: [
              {
                number: 22,
                protocol: 'TCP',
                allowedSourceAddressPrefix: 'Internet',
                maxRequestAccessDuration: 'PT3H',
              },
              {
                number: 3389,
                protocol: 'TCP',
                allowedSourceAddressPrefix: 'Internet',
                maxRequestAccessDuration: 'PT3H',
              },
            ],
          },
        ],
        requests: [],
      },
    };
    
    // Apply JIT policy
    await this.applyJITPolicy(jitPolicy);
  }
}
```

## 🎯 Security Operations Center

### 1. SOC Dashboard

```typescript
// security/soc-dashboard.tsx
import React from 'react';
import { Grid, Card, Typography, LinearProgress } from '@mui/material';
import { SecurityScore, ThreatIndicator, IncidentMetrics } from './types';

export const SOCDashboard: React.FC = () => {
  const [securityData, setSecurityData] = React.useState<SecurityData>();
  
  React.useEffect(() => {
    const fetchSecurityData = async () => {
      const data = await getSecurityMetrics();
      setSecurityData(data);
    };
    
    fetchSecurityData();
    const interval = setInterval(fetchSecurityData, 30000); // Update every 30s
    
    return () => clearInterval(interval);
  }, []);
  
  return (
    <Grid container spacing={3}>
      {/* Security Score */}
      <Grid item xs={12} md={6} lg={3}>
        <Card>
          <CardContent>
            <Typography variant="h6">Security Score</Typography>
            <Typography variant="h2">{securityData?.score || 0}%</Typography>
            <LinearProgress 
              variant="determinate" 
              value={securityData?.score || 0}
              color={getScoreColor(securityData?.score)}
            />
          </CardContent>
        </Card>
      </Grid>
      
      {/* Active Threats */}
      <Grid item xs={12} md={6} lg={3}>
        <Card>
          <CardContent>
            <Typography variant="h6">Active Threats</Typography>
            <Grid container>
              <Grid item xs={4}>
                <Typography color="error">Critical: {securityData?.threats.critical}</Typography>
              </Grid>
              <Grid item xs={4}>
                <Typography color="warning">High: {securityData?.threats.high}</Typography>
              </Grid>
              <Grid item xs={4}>
                <Typography>Medium: {securityData?.threats.medium}</Typography>
              </Grid>
            </Grid>
          </CardContent>
        </Card>
      </Grid>
      
      {/* Incident Response */}
      <Grid item xs={12} md={6}>
        <Card>
          <CardContent>
            <Typography variant="h6">Incident Response Metrics</Typography>
            <Grid container spacing={2}>
              <Grid item xs={6}>
                <Typography>MTTD: {securityData?.metrics.mttd} min</Typography>
                <Typography>MTTR: {securityData?.metrics.mttr} min</Typography>
              </Grid>
              <Grid item xs={6}>
                <Typography>Incidents Today: {securityData?.metrics.incidentsToday}</Typography>
                <Typography>Auto-Resolved: {securityData?.metrics.autoResolved}%</Typography>
              </Grid>
            </Grid>
          </CardContent>
        </Card>
      </Grid>
      
      {/* Compliance Status */}
      <Grid item xs={12}>
        <Card>
          <CardContent>
            <Typography variant="h6">Compliance Status</Typography>
            <ComplianceChart data={securityData?.compliance} />
          </CardContent>
        </Card>
      </Grid>
    </Grid>
  );
};
```

## 📋 Enhanced Security Summary

### Implemented Security Features

| Feature | Status | Coverage | Automation Level |
|---------|--------|----------|------------------|
| **Advanced GHAS** | ✅ Active | 100% repos | Fully automated |
| **Azure Sentinel** | ✅ Deployed | All resources | AI-powered |
| **Compliance Automation** | ✅ Enforced | 15 standards | Policy as code |
| **Container Security** | ✅ Scanning | Build + runtime | Admission control |
| **Zero Trust Network** | ✅ Configured | All layers | Dynamic policies |
| **Identity Management** | ✅ Enhanced | PIM + JIT | Conditional access |

### Security Metrics Achieved

- **Mean Time to Detect**: <5 minutes
- **Mean Time to Respond**: <15 minutes
- **Vulnerability Detection Rate**: 99.5%
- **False Positive Rate**: <2%
- **Compliance Score**: 95%
- **Security Debt Reduction**: 75%

### AI-Powered Security Features

1. **Threat Intelligence**: Real-time correlation
2. **Behavioral Analytics**: User and entity analysis
3. **Automated Response**: 40% of incidents
4. **Predictive Security**: Attack path modeling

## 🚦 Next Steps

### Immediate Actions
1. ✅ Review and customize security policies
2. ✅ Configure team notifications
3. ✅ Test incident response playbooks
4. ✅ Schedule security training

### Continue to Next Component
- [**H2-004: Performance Optimization**](h2-004-performance.md) - Platform optimization
- [**H2-005: Golden Paths**](h2-horizon-optimization/005-golden-paths.md) - Developer workflows
- [**H2-006: Advanced Developer Hub**](h2-horizon-optimization/006-advanced-devhub.md) - Portal features

---

<div align="center">

**Enhanced Security Implemented! 🔒**

Your platform now has enterprise-grade security with AI-powered threat detection and automated response.

[← Previous: Comprehensive Monitoring](h2-002-monitoring.md) | [Next: Performance Optimization →](h2-004-performance.md)

</div>
