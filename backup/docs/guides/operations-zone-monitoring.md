# 📊 Operations Zone - Monitoring & Observability Guide

## 🎯 Overview

The Operations Zone provides comprehensive monitoring, observability, and operational intelligence for the Three Horizons Platform. This zone enables proactive monitoring, incident detection, and performance optimization across all platform components, supporting cloud-native (Prometheus/Grafana), enterprise multi-cloud (Datadog), and AI-powered incident response with Azure SRE Agent.

![Operations Zone Architecture](../images/security-architecture.svg)

> 🔍 **Note:** The Operations Zone integrates multiple monitoring solutions including Azure Monitor, Prometheus, Grafana, Datadog, and Azure SRE Agent to provide full-stack observability and automated incident response.

## 🤔 What is the Operations Zone?

The Operations Zone encompasses:

- **Infrastructure Monitoring**: Resource utilization, health checks, and availability
- **Application Performance Monitoring (APM)**: Transaction tracing, error tracking, and performance metrics
- **Log Management**: Centralized logging, search, and analysis
- **Alerting & Incident Management**: Proactive alerting and incident response workflows
- **Business Metrics**: Custom KPIs and business intelligence dashboards

## 📋 Prerequisites

Before configuring the Operations Zone, ensure you have:

- **Kubernetes Cluster Access**: Administrative access to AKS/ARO clusters
- **Azure Monitor**: Enabled for your Azure subscription
- **Datadog Account**: For multi-cloud monitoring (if using)
- **Network Access**: Proper firewall rules for metrics collection
- **Storage**: Persistent volumes for metrics retention

## 🏗️ Architecture Options

### Option 1: Cloud-Native Stack (Prometheus + Grafana)

Best for:
- Kubernetes-native environments
- Open-source preference
- Cost-conscious deployments

### Option 2: Enterprise Multi-Cloud (Datadog + Azure Monitor)

Best for:
- Multi-cloud environments
- Enterprise support requirements
- Advanced APM features
- Unified monitoring across cloud providers

## 🚀 Cloud-Native Monitoring Setup

### Deploy Prometheus Stack

```bash
# Add Prometheus community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create monitoring namespace
kubectl create namespace monitoring

# Install kube-prometheus-stack
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.retention=30d \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName=managed-premium \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=100Gi \
  --set grafana.persistence.enabled=true \
  --set grafana.persistence.size=10Gi \
  --set grafana.adminPassword=SecurePassword123! \
  --values prometheus-values.yaml
```

### Prometheus Configuration

Create `prometheus-values.yaml`:

```yaml
prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
    ruleSelectorNilUsesHelmValues: false
    
    additionalScrapeConfigs:
    - job_name: 'kubernetes-pods'
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
        
    - job_name: 'developer-hub'
      static_configs:
      - targets: ['developer-hub.developer-hub.svc.cluster.local:9090']
      metrics_path: /metrics
      
alertmanager:
  config:
    global:
      slack_api_url: 'YOUR_SLACK_WEBHOOK_URL'
    route:
      group_by: ['alertname', 'cluster', 'service']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 12h
      receiver: 'default-receiver'
      routes:
      - match:
          severity: critical
        receiver: 'critical-receiver'
    receivers:
    - name: 'default-receiver'
      slack_configs:
      - channel: '#alerts'
        title: 'Three Horizons Platform Alert'
    - name: 'critical-receiver'
      slack_configs:
      - channel: '#critical-alerts'
        title: '🚨 CRITICAL: Three Horizons Platform'
        
grafana:
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
      cert-manager.io/cluster-issuer: letsencrypt-prod
    hosts:
      - grafana.example.com
    tls:
      - secretName: grafana-tls
        hosts:
          - grafana.example.com
```

### Custom Metrics for Developer Hub

```yaml
# developer-hub-servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: developer-hub
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: developer-hub
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
  namespaceSelector:
    matchNames:
    - developer-hub
```

## 🌐 Enterprise Multi-Cloud Monitoring with Datadog

### Datadog Agent Installation

```bash
# Set Datadog API and APP keys
export DD_API_KEY="your-datadog-api-key"
export DD_APP_KEY="your-datadog-app-key"
export DD_SITE="datadoghq.com"  # or datadoghq.eu for EU

# Add Datadog Helm repository
helm repo add datadog https://helm.datadoghq.com
helm repo update

# Install Datadog agent
helm install datadog datadog/datadog \
  --namespace monitoring \
  --set datadog.apiKey=$DD_API_KEY \
  --set datadog.appKey=$DD_APP_KEY \
  --set datadog.site=$DD_SITE \
  --set datadog.logs.enabled=true \
  --set datadog.logs.containerCollectAll=true \
  --set datadog.apm.portEnabled=true \
  --set datadog.processAgent.processCollection=true \
  --set datadog.networkMonitoring.enabled=true \
  --set datadog.clusterChecks.enabled=true \
  --set clusterChecksRunner.enabled=true \
  --set datadog.kubelet.tlsVerify=false \
  --values datadog-values.yaml
```

### Datadog Configuration

Create `datadog-values.yaml`:

```yaml
datadog:
  tags:
    - "environment:production"
    - "platform:three-horizons"
    - "cloud:azure"
  
  # Enable integrations
  confd:
    kubernetes_state_core.yaml: |-
      ad_identifiers:
        - kube-state-metrics
      init_config:
      instances:
        - kube_state_url: http://prometheus-kube-state-metrics.monitoring:8080/metrics
    
    azure.yaml: |-
      init_config:
      instances:
        - tenant_id: "YOUR_AZURE_TENANT_ID"
          client_id: "YOUR_AZURE_CLIENT_ID"
          client_secret: "YOUR_AZURE_CLIENT_SECRET"
          subscription_id: "YOUR_AZURE_SUBSCRIPTION_ID"
          
  # APM configuration
  apm:
    enabled: true
    port: 8126
    useSocketVolume: true
    socketPath: /var/run/datadog/apm.socket
    hostSocketPath: /var/run/datadog/
    
  # Log collection
  logs:
    enabled: true
    containerCollectAll: true
    containerCollectUsingFiles: true
    
  # Custom metrics
  dogstatsd:
    useHostPort: true
    port: 8125
    nonLocalTraffic: true
    
agents:
  image:
    tag: "latest"
  rbac:
    create: true
  tolerations:
    - operator: Exists
```

### Azure Monitor Integration with Datadog

```bash
# Create Azure AD Service Principal for Datadog
az ad sp create-for-rbac --name "DatadogIntegration" \
  --role "Monitoring Reader" \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID"

# Configure Azure integration in Datadog
curl -X POST "https://api.datadoghq.com/api/v1/integration/azure" \
  -H "Content-Type: application/json" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
  -d '{
    "tenant_name": "YOUR_AZURE_TENANT_ID",
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET",
    "host_filters": "environment:production,platform:three-horizons"
  }'
```

### Datadog Dashboards

Create custom dashboards via Terraform:

```hcl
# datadog-dashboards.tf
resource "datadog_dashboard" "three_horizons_overview" {
  title       = "Three Horizons Platform Overview"
  description = "Executive dashboard for Three Horizons Platform"
  layout_type = "ordered"

  widget {
    group_definition {
      title       = "Platform Health"
      layout_type = "ordered"

      widget {
        query_value_definition {
          title = "Cluster CPU Usage"
          request {
            q = "avg:kubernetes.cpu.usage.total{cluster_name:three-horizons-prod}"
            aggregator = "avg"
          }
          precision = 2
        }
      }

      widget {
        query_value_definition {
          title = "Active Deployments"
          request {
            q = "sum:kubernetes.deployments.available{cluster_name:three-horizons-prod}"
          }
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Request Rate by Service"
      request {
        q = "sum:trace.servlet.request.hits{env:production} by {service}.as_rate()"
        display_type = "bars"
        style {
          palette = "dog_classic"
        }
      }
    }
  }
}
```

## 📊 Unified Monitoring Strategy

### Metrics Collection Architecture

```yaml
# metrics-collection-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: metrics-collection-strategy
  namespace: monitoring
data:
  strategy.yaml: |
    sources:
      - type: kubernetes
        collectors:
          - prometheus
          - datadog-agent
        metrics:
          - cpu_usage
          - memory_usage
          - network_io
          - disk_io
          
      - type: application
        collectors:
          - datadog-apm
          - application-insights
        metrics:
          - response_time
          - error_rate
          - throughput
          - custom_business_metrics
          
      - type: cloud_provider
        collectors:
          - azure-monitor
          - datadog-azure-integration
        metrics:
          - resource_utilization
          - cost_metrics
          - compliance_status
```

### Multi-Cloud Monitoring Federation

```bash
# Configure Prometheus federation for multi-cloud
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-federation-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      external_labels:
        cluster: 'azure-prod'
        region: 'eastus'
        
    scrape_configs:
    - job_name: 'federate-aws'
      scrape_interval: 15s
      honor_labels: true
      metrics_path: '/federate'
      params:
        'match[]':
          - '{job=~".*"}'
      static_configs:
        - targets:
          - 'prometheus-aws.example.com:9090'
          
    - job_name: 'federate-gcp'
      scrape_interval: 15s
      honor_labels: true
      metrics_path: '/federate'
      params:
        'match[]':
          - '{job=~".*"}'
      static_configs:
        - targets:
          - 'prometheus-gcp.example.com:9090'
EOF
```

## 🚨 Alerting Configuration

### Critical Alerts Definition

```yaml
# alerts-rules.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: three-horizons-alerts
  namespace: monitoring
spec:
  groups:
  - name: platform.rules
    interval: 30s
    rules:
    - alert: HighCPUUsage
      expr: |
        (sum(rate(container_cpu_usage_seconds_total{namespace="three-horizons"}[5m])) by (pod) / 
         sum(container_spec_cpu_quota{namespace="three-horizons"}/container_spec_cpu_period{namespace="three-horizons"}) by (pod)) > 0.8
      for: 5m
      labels:
        severity: warning
        team: platform
      annotations:
        summary: "High CPU usage detected"
        description: "Pod {{ $labels.pod }} is using {{ $value | humanizePercentage }} of CPU"
        
    - alert: PodCrashLooping
      expr: |
        rate(kube_pod_container_status_restarts_total{namespace="three-horizons"}[5m]) > 0
      for: 5m
      labels:
        severity: critical
        team: platform
      annotations:
        summary: "Pod is crash looping"
        description: "Pod {{ $labels.pod }} is crash looping"
        
    - alert: DeveloperHubDown
      expr: |
        up{job="developer-hub"} == 0
      for: 1m
      labels:
        severity: critical
        team: platform
      annotations:
        summary: "Developer Hub is down"
        description: "Developer Hub has been down for more than 1 minute"
```

### Datadog Monitors

```python
# datadog-monitors.py
from datadog_api_client import ApiClient, Configuration
from datadog_api_client.v1.api.monitors_api import MonitorsApi
from datadog_api_client.v1.model.monitor import Monitor

configuration = Configuration()
configuration.api_key["apiKeyAuth"] = "YOUR_API_KEY"
configuration.api_key["appKeyAuth"] = "YOUR_APP_KEY"

with ApiClient(configuration) as api_client:
    api_instance = MonitorsApi(api_client)
    
    # APM Service Monitor
    apm_monitor = Monitor(
        name="Three Horizons - Service Error Rate",
        type="query alert",
        query="avg(last_5m):avg:trace.servlet.request.errors{env:production} by {service} / avg:trace.servlet.request.hits{env:production} by {service} > 0.05",
        message="Service {{service.name}} error rate is {{value}}% @slack-three-horizons-alerts",
        tags=["team:platform", "env:production"],
        options={
            "thresholds": {"critical": 0.05, "warning": 0.03},
            "notify_no_data": True,
            "no_data_timeframe": 10
        }
    )
    
    # Cost Anomaly Monitor
    cost_monitor = Monitor(
        name="Three Horizons - Azure Cost Anomaly",
        type="query alert",
        query="avg(last_1h):anomalies(avg:azure.cost.actual{subscription_id:YOUR_SUB_ID}, 'basic', 2) >= 1",
        message="Azure cost anomaly detected! Current spend is unusual. @slack-three-horizons-finance",
        tags=["team:finance", "cloud:azure"],
        options={
            "threshold_windows": {
                "trigger_window": "last_1h",
                "recovery_window": "last_15m"
            }
        }
    )
    
    api_instance.create_monitor(body=apm_monitor)
    api_instance.create_monitor(body=cost_monitor)
```

## 📈 Observability Best Practices

### 1. Structured Logging

```javascript
// Example structured logging for Node.js applications
const winston = require('winston');
const { DatadogWinston } = require('datadog-winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.Console(),
    new DatadogWinston({
      apiKey: process.env.DD_API_KEY,
      hostname: process.env.HOSTNAME,
      service: 'three-horizons-api',
      ddsource: 'nodejs',
      tags: ['env:production', 'version:' + process.env.APP_VERSION]
    })
  ]
});

// Usage
logger.info('API request processed', {
  user_id: req.user.id,
  endpoint: req.path,
  duration_ms: responseTime,
  status_code: res.statusCode
});
```

### 2. Distributed Tracing

```yaml
# Application deployment with tracing
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
spec:
  template:
    spec:
      containers:
      - name: app
        env:
        - name: DD_AGENT_HOST
          valueFrom:
            fieldRef:
              fieldPath: status.hostIP
        - name: DD_TRACE_ENABLED
          value: "true"
        - name: DD_SERVICE
          value: "three-horizons-api"
        - name: DD_ENV
          value: "production"
        - name: DD_VERSION
          valueFrom:
            fieldRef:
              fieldPath: metadata.labels['version']
        - name: DD_LOGS_INJECTION
          value: "true"
```

### 3. SLO Configuration

```yaml
# slo-configuration.yaml
apiVersion: sloth.slok.dev/v1
kind: PrometheusServiceLevel
metadata:
  name: three-horizons-api-slo
  namespace: monitoring
spec:
  service: "three-horizons-api"
  labels:
    team: "platform"
  slos:
    - name: "requests-availability"
      objective: 99.9
      sli:
        events:
          error_query: |
            sum(rate(http_requests_total{job="three-horizons-api",code=~"5.."}[5m]))
          total_query: |
            sum(rate(http_requests_total{job="three-horizons-api"}[5m]))
      alerting:
        name: ThreeHorizonsAPIAvailability
        page_alert:
          disable: false
        ticket_alert:
          disable: false
```

## 🔄 Integration with Developer Hub

### Developer Hub Metrics Plugin

```yaml
# developer-hub-metrics-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: developer-hub-metrics
  namespace: developer-hub
data:
  app-config.production.yaml: |
    proxy:
      '/prometheus':
        target: 'http://prometheus-server.monitoring:9090'
        headers:
          Authorization: 'Bearer ${PROMETHEUS_TOKEN}'
      '/grafana':
        target: 'http://prometheus-grafana.monitoring'
        headers:
          Authorization: 'Bearer ${GRAFANA_TOKEN}'
          
    techdocs:
      metrics:
        enabled: true
        endpoints:
          - name: 'Platform Metrics'
            url: '/prometheus'
          - name: 'Dashboards'
            url: '/grafana'
```

## 🤖 Azure SRE Agent Integration

### Overview

Azure SRE Agent is an AI-powered tool that revolutionizes incident response and infrastructure management. It leverages Large Language Models (LLMs) to provide automated incident detection, root cause analysis, and remediation capabilities.

### Key Benefits

- **80% Faster MTTR**: Reduces Mean Time To Recovery through automated investigation
- **60% Less False Alerts**: Intelligent alert correlation and noise reduction
- **40% Cost Reduction**: Proactive optimization and automated remediation
- **24/7 Monitoring**: Continuous learning and monitoring of Azure resources

### SRE Agent Setup

```bash
# Prerequisites
az extension add --name sre-agent

# Create SRE Agent instance
az sre-agent create \
  --name three-horizons-sre \
  --resource-group three-horizons-platform \
  --location eastus \
  --sku standard

# Configure SRE Agent with Azure Monitor
az sre-agent config set \
  --name three-horizons-sre \
  --resource-group three-horizons-platform \
  --azure-monitor-workspace $(az monitor log-analytics workspace show \
    --resource-group three-horizons-platform \
    --workspace-name three-horizons-logs \
    --query id -o tsv)

# Enable Kubernetes integration
az sre-agent integration create \
  --agent-name three-horizons-sre \
  --resource-group three-horizons-platform \
  --integration-type kubernetes \
  --cluster-resource-id $(az aks show \
    --resource-group three-horizons-platform \
    --name three-horizons-aks \
    --query id -o tsv)
```

### Configure SRE Agent Capabilities

```yaml
# sre-agent-config.yaml
apiVersion: sre.azure.com/v1
kind: SREAgentConfiguration
metadata:
  name: three-horizons-sre-config
spec:
  capabilities:
    # Automated incident response
    incidentResponse:
      enabled: true
      autoRemediation:
        enabled: true
        requiresApproval: true
        allowedActions:
          - restart-pod
          - scale-deployment
          - rollback-deployment
          - clear-cache
          - rotate-credentials
      
    # Proactive security scanning
    securityScanning:
      enabled: true
      checks:
        - tls-version-compliance
        - managed-identity-enabled
        - network-exposure
        - vulnerability-scanning
      autoRemediation: true
    
    # Performance optimization
    performanceOptimization:
      enabled: true
      metrics:
        - cpu-utilization
        - memory-usage
        - request-latency
        - error-rate
      thresholds:
        cpuUtilization: 80
        memoryUsage: 85
        requestLatency: 500ms
        errorRate: 5
    
    # Integration with external tools
    integrations:
      github:
        enabled: true
        organization: "your-org"
        createIssues: true
        linkToIncidents: true
      
      pagerduty:
        enabled: true
        apiKey: "${PAGERDUTY_API_KEY}"
        escalationPolicy: "platform-team"
      
      slack:
        enabled: true
        webhookUrl: "${SLACK_WEBHOOK_URL}"
        channels:
          alerts: "#platform-alerts"
          incidents: "#platform-incidents"
```

### SRE Agent Prompts and Use Cases

```bash
# Example interactions with SRE Agent

# 1. Investigate performance issues
az sre-agent query \
  --agent-name three-horizons-sre \
  --prompt "What changed in my AKS cluster in the last day that could affect performance?"

# 2. Set up proactive monitoring
az sre-agent query \
  --agent-name three-horizons-sre \
  --prompt "What alerts should I set up for my web applications?"

# 3. Visualize metrics
az sre-agent query \
  --agent-name three-horizons-sre \
  --prompt "Visualize CPU usage and memory consumption for my developer-hub namespace over the last week"

# 4. Security audit
az sre-agent query \
  --agent-name three-horizons-sre \
  --prompt "Check all my resources for TLS compliance and managed identity configuration"

# 5. Incident investigation
az sre-agent query \
  --agent-name three-horizons-sre \
  --prompt "Investigate the root cause of 500 errors in the API gateway service"
```

### Automated Incident Response Workflow

```yaml
# incident-response-workflow.yaml
apiVersion: sre.azure.com/v1
kind: IncidentResponseWorkflow
metadata:
  name: automated-incident-response
spec:
  triggers:
    - type: alert
      source: azure-monitor
      severity: [critical, high]
    
    - type: metric-threshold
      metrics:
        - name: error_rate
          threshold: 10
          duration: 5m
  
  workflow:
    - name: initial-investigation
      action: investigate
      parameters:
        depth: comprehensive
        includeMetrics: true
        includeLogs: true
        includeChanges: true
    
    - name: notification
      action: notify
      channels:
        - slack
        - pagerduty
      includeInvestigation: true
    
    - name: auto-remediation
      condition: "severity == 'critical' && confidence > 0.8"
      actions:
        - type: restart-pod
          requireApproval: false
          maxRetries: 3
        
        - type: scale-out
          requireApproval: true
          parameters:
            increment: 2
            maxReplicas: 10
    
    - name: create-github-issue
      action: create-issue
      repository: "three-horizons-platform"
      template: incident-report
      includeRCA: true
```

## 🌐 Azure Arc for Containers - Multi-Cloud Strategy

### Overview

Azure Arc for Containers enables unified management and monitoring across multi-cloud and on-premises Kubernetes clusters, providing a single control plane for all container workloads.

### Arc-enabled Kubernetes Setup

```bash
# Prerequisites
az extension add --name connectedk8s
az extension add --name k8s-configuration
az extension add --name k8s-extension

# Connect non-Azure Kubernetes clusters
# For AWS EKS
aws eks update-kubeconfig --name production-cluster --region us-west-2
az connectedk8s connect \
  --name aws-production-cluster \
  --resource-group three-horizons-multicloud \
  --location eastus

# For GCP GKE
gcloud container clusters get-credentials production-cluster --zone us-central1-a
az connectedk8s connect \
  --name gcp-production-cluster \
  --resource-group three-horizons-multicloud \
  --location eastus

# For on-premises clusters
az connectedk8s connect \
  --name onprem-production-cluster \
  --resource-group three-horizons-multicloud \
  --location eastus \
  --proxy-https "http://proxy.company.com:8080"
```

### Deploy Azure Monitor Container Insights to Arc Clusters

```bash
# Enable Container Insights on Arc-enabled clusters
az k8s-extension create \
  --name azuremonitor-containers \
  --cluster-name aws-production-cluster \
  --resource-group three-horizons-multicloud \
  --cluster-type connectedClusters \
  --extension-type Microsoft.AzureMonitor.Containers \
  --configuration-settings \
    "logAnalyticsWorkspaceResourceID=$(az monitor log-analytics workspace show \
      --resource-group three-horizons-platform \
      --workspace-name three-horizons-logs \
      --query id -o tsv)"

# Deploy Prometheus collector for Arc clusters
az k8s-extension create \
  --name azuremonitor-metrics \
  --cluster-name aws-production-cluster \
  --resource-group three-horizons-multicloud \
  --cluster-type connectedClusters \
  --extension-type Microsoft.AzureMonitor.Containers.Metrics \
  --configuration-settings \
    "azure-monitor-workspace-resource-id=$(az monitor account show \
      --name three-horizons-metrics \
      --resource-group three-horizons-platform \
      --query id -o tsv)"
```

### Multi-Cloud GitOps with Arc

```yaml
# arc-gitops-config.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: arc-multicloud-apps
  namespace: flux-system
spec:
  interval: 10m
  path: ./clusters/arc-enabled
  prune: true
  sourceRef:
    kind: GitRepository
    name: three-horizons-gitops
  postBuild:
    substitute:
      cluster_type: "arc-enabled"
      monitoring_enabled: "true"
  patches:
    - patch: |
        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: cluster-config
          namespace: default
        data:
          azure_arc_enabled: "true"
          monitoring_workspace: "${AZURE_MONITOR_WORKSPACE}"
```

### Arc Policy Engine for Compliance

```bash
# Apply Azure Policy to Arc-enabled clusters
az policy assignment create \
  --name "arc-kubernetes-compliance" \
  --display-name "Arc Kubernetes Compliance Standards" \
  --policy-set-definition "/providers/Microsoft.Authorization/policySetDefinitions/42b8ef37-b724-4e24-bbc8-7a7708edfe00" \
  --scope "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/three-horizons-multicloud" \
  --params '{
    "effect": {"value": "audit"},
    "excludedNamespaces": {"value": ["kube-system", "kube-public", "flux-system"]}
  }'
```

## 🎯 Developer Hub Azure Monitor Integration

### Add Azure Monitor Dashboard Tab

Create a custom Developer Hub plugin to display Azure Monitor dashboards:

```typescript
// plugins/azure-monitor-dashboard/src/components/AzureMonitorDashboard.tsx
import React from 'react';
import { InfoCard, Progress } from '@backstage/core-components';
import { useApi, configApiRef } from '@backstage/core-plugin-api';
import { Grid } from '@material-ui/core';

export const AzureMonitorDashboard = () => {
  const config = useApi(configApiRef);
  const dashboardUrl = config.getString('azureMonitor.dashboardUrl');
  const workspaceId = config.getString('azureMonitor.workspaceId');

  return (
    <Grid container spacing={3}>
      <Grid item xs={12}>
        <InfoCard title="Platform Health Overview">
          <iframe
            src={`${dashboardUrl}?workspaceId=${workspaceId}`}
            width="100%"
            height="600"
            frameBorder="0"
          />
        </InfoCard>
      </Grid>
      <Grid item xs={12} md={6}>
        <InfoCard title="SRE Agent Insights">
          <SREAgentMetrics />
        </InfoCard>
      </Grid>
      <Grid item xs={12} md={6}>
        <InfoCard title="Multi-Cloud Status">
          <MultiCloudStatus />
        </InfoCard>
      </Grid>
    </Grid>
  );
};
```

### Configure Dashboard Plugin

```yaml
# app-config.yaml additions for Developer Hub
azureMonitor:
  dashboardUrl: https://portal.azure.com/#dashboard
  workspaceId: ${AZURE_MONITOR_WORKSPACE_ID}
  subscriptionId: ${AZURE_SUBSCRIPTION_ID}
  resourceGroup: three-horizons-platform
  
  dashboards:
    - id: platform-overview
      name: "Platform Overview"
      embedded: true
      permissions:
        - type: role
          role: platform-engineer
    
    - id: sre-operations
      name: "SRE Operations"
      embedded: true
      permissions:
        - type: role
          role: sre-team
    
    - id: developer-metrics
      name: "Developer Metrics"
      embedded: true
      permissions:
        - type: role
          role: developer

# Register the plugin
catalog:
  rules:
    - allow: [Component, API, Location, Template, User, Group]
  processors:
    - AzureMonitorDashboardProcessor

plugins:
  - package: '@internal/plugin-azure-monitor-dashboard'
    disabled: false
```

### Create Unified Monitoring API

```typescript
// plugins/azure-monitor-dashboard/src/api/MonitoringAPI.ts
import { createApiRef } from '@backstage/core-plugin-api';

export const monitoringApiRef = createApiRef<MonitoringAPI>({
  id: 'plugin.monitoring.api',
});

export interface MonitoringAPI {
  getMetrics(query: MetricQuery): Promise<MetricResult[]>;
  getAlerts(severity?: string): Promise<Alert[]>;
  getSREAgentInsights(): Promise<SREInsight[]>;
  getMultiCloudStatus(): Promise<CloudStatus[]>;
}

export class UnifiedMonitoringClient implements MonitoringAPI {
  constructor(
    private readonly azureMonitorClient: AzureMonitorClient,
    private readonly prometheusClient: PrometheusClient,
    private readonly datadogClient: DatadogClient,
  ) {}

  async getMetrics(query: MetricQuery): Promise<MetricResult[]> {
    const results = await Promise.all([
      this.azureMonitorClient.query(query),
      this.prometheusClient.query(query),
      this.datadogClient.query(query),
    ]);
    
    return this.mergeResults(results);
  }

  async getSREAgentInsights(): Promise<SREInsight[]> {
    const response = await fetch('/api/sre-agent/insights', {
      headers: {
        'Authorization': `Bearer ${await this.getToken()}`,
      },
    });
    
    return response.json();
  }
}
```

## 🛠️ Troubleshooting

### Common Issues

#### Metrics Not Appearing
- Verify ServiceMonitor/PodMonitor labels match selector
- Check prometheus operator logs
- Ensure network policies allow scraping

#### High Cardinality Issues
- Review metric labels for unbounded values
- Implement metric relabeling to drop unnecessary labels
- Use recording rules for frequently queried metrics

#### Datadog Agent Issues
- Check agent status: `kubectl exec -it <datadog-pod> -- agent status`
- Verify API keys are correct
- Review agent logs for connection issues

## 📚 Related Documentation

- [Integration Zone CI/CD Guide](./integration-zone-cicd.md)
- [Complete Integration Tutorial](../complete-integration-tutorial/index.md)
- [Datadog Kubernetes Integration](https://docs.datadoghq.com/integrations/kubernetes/)
- [Azure Monitor Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/)
- [Prometheus Operator](https://prometheus-operator.dev/) 