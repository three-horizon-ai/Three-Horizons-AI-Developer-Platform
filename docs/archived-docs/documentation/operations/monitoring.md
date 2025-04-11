---
title: "Platform Monitoring"
description: "Comprehensive guide to monitoring the Three Horizons Platform"
position_in_journey: "5.2 Operations"
previous_doc: "/docs/documentation/operations/index.md"
next_doc: "/docs/documentation/operations/logging.md"
last_updated: "2025-04-10"
---

# <span style="color: #0366d6;">👁️ Your Monitoring Journey</span>

Welcome to your Three Horizons Platform monitoring journey. This comprehensive guide will help you implement effective observability practices across your platform, enabling you to maintain reliability, performance, and security at scale.

## <span style="color: #0366d6;">🔍 Understanding Your Monitoring Foundation</span>

Monitoring is a critical capability that evolves throughout your Three Horizons implementation journey. As your platform matures, your monitoring capabilities progress from basic operational metrics to sophisticated predictive analytics and autonomous operations.

### <span style="color: #0366d6;">Horizon 1: Essential Monitoring</span>

In the initial horizon, focus on establishing foundational monitoring for operational visibility:

- **Platform Health Monitoring**: Core infrastructure and service availability
- **Basic Metrics Collection**: CPU, memory, disk, and network utilization
- **Alert Configuration**: Essential alerting for critical service disruptions
- **Dashboard Creation**: Basic operational dashboards for key components

### <span style="color: #0366d6;">Horizon 2: Enhanced Observability</span>

As your platform matures, implement more sophisticated monitoring capabilities:

- **Application Performance Monitoring**: Detailed application performance insights
- **Distributed Tracing**: End-to-end transaction visibility across services
- **Correlation Analysis**: Connecting events across platform components
- **SLO/SLI Tracking**: Service level objective measurement and reporting

### <span style="color: #0366d6;">Horizon 3: Intelligent Monitoring</span>

In the advanced horizon, implement predictive and autonomous monitoring:

- **AI-Driven Anomaly Detection**: Machine learning-based pattern recognition
- **Predictive Analytics**: Forecasting potential issues before they occur
- **Autonomous Remediation**: Self-healing capabilities for common problems
- **Business Impact Analysis**: Connecting technical metrics to business outcomes

## <span style="color: #0366d6;">🛠️ Implementing Your Monitoring Strategy</span>

### <span style="color: #0366d6;">Azure Monitor Integration</span>

Azure Monitor forms the backbone of your monitoring infrastructure:

```bash
# Enable monitoring for your AKS cluster
az aks enable-addons --resource-group three-horizons-rg \
  --name three-horizons-aks \
  --addons monitoring

# Configure log analytics workspace
az monitor log-analytics workspace create \
  --resource-group three-horizons-rg \
  --workspace-name three-horizons-workspace \
  --location eastus \
  --sku PerGB2018

# Link workspace to your cluster
az aks enable-addons --resource-group three-horizons-rg \
  --name three-horizons-aks \
  --addons monitoring \
  --workspace-resource-id "/subscriptions/{subscription-id}/resourcegroups/three-horizons-rg/providers/microsoft.operationalinsights/workspaces/three-horizons-workspace"
```

### <span style="color: #0366d6;">Prometheus and Grafana Setup</span>

Implement Prometheus and Grafana for detailed Kubernetes and application monitoring:

```bash
# Add Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus Operator
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.enabled=true \
  --set prometheus.prometheusSpec.serviceMonitorSelector.matchLabels.team=platform

# Access Grafana dashboard
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
```

### <span style="color: #0366d6;">Application Insights Integration</span>

For detailed application performance monitoring:

```javascript
// Example Node.js Application Insights integration
const appInsights = require('applicationinsights');
appInsights.setup('your-instrumentation-key')
  .setAutoDependencyCorrelation(true)
  .setAutoCollectRequests(true)
  .setAutoCollectPerformance(true)
  .setAutoCollectExceptions(true)
  .setAutoCollectDependencies(true)
  .setAutoCollectConsole(true)
  .setUseDiskRetryCaching(true)
  .setSendLiveMetrics(true)
  .start();
```

## <span style="color: #0366d6;">📊 Building Effective Dashboards</span>

Create purpose-built dashboards for different stakeholder needs:

### <span style="color: #0366d6;">Platform Overview Dashboard</span>

The Platform Overview Dashboard provides a high-level view of the entire Three Horizons Platform:

- **Key Components**: AKS/ARO status, Developer Hub availability, GitHub integration status
- **Resource Utilization**: CPU, memory, and storage usage across clusters
- **SLA Compliance**: Service availability metrics and SLA tracking
- **Alert Summary**: Overview of active and recent alerts

![Platform Overview Dashboard](../../../assets/images/dashboards/platform-overview.png)

### <span style="color: #0366d6;">Developer Experience Dashboard</span>

The Developer Experience Dashboard focuses on metrics relevant to developers:

- **Golden Path Usage**: Utilization of platform-provided golden paths
- **CI/CD Performance**: Build and deployment success rates and durations
- **Pull Request Metrics**: PR volumes, review times, and approval rates
- **GitHub Copilot Metrics**: Acceptance rates and productivity gains

### <span style="color: #0366d6;">Application Performance Dashboard</span>

The Application Performance Dashboard provides detailed insights into application behavior:

- **Response Times**: P95/P99 latency for key services
- **Error Rates**: Application errors and exceptions
- **Throughput**: Request rates and transaction volumes
- **Dependency Health**: Status of service dependencies

## <span style="color: #0366d6;">⚠️ Implementing Effective Alerting</span>

Design a comprehensive alerting strategy across your platform:

### <span style="color: #0366d6;">Alert Definition Strategy</span>

Follow these principles when defining alerts:

1. **Actionability**: Only alert on conditions that require human intervention
2. **Clarity**: Provide clear context about what triggered the alert
3. **Relevance**: Route alerts to the appropriate teams
4. **Prioritization**: Clearly indicate severity and urgency

### <span style="color: #0366d6;">Essential Platform Alerts</span>

Implement these critical alerts for your Three Horizons Platform:

| Alert Name | Description | Threshold | Severity |
|------------|-------------|-----------|----------|
| **Node CPU High** | High CPU utilization on cluster nodes | >85% for 15 min | Warning |
| **Node Memory High** | High memory utilization on cluster nodes | >85% for 15 min | Warning |
| **Pod Restarts** | Frequent pod restarts indicating stability issues | >3 restarts in 15 min | Warning |
| **API Server Latency** | Slow API server response affecting platform operations | >1s P95 | Critical |
| **Developer Hub Unavailable** | Developer Hub service unavailability | Any downtime | Critical |
| **CI/CD Pipeline Failures** | Consistent failures in CI/CD pipelines | >3 consecutive failures | Warning |

### <span style="color: #0366d6;">Alert Configuration Example</span>

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: three-horizons-alerts
  namespace: monitoring
spec:
  groups:
  - name: three-horizons.rules
    rules:
    - alert: NodeCPUUsageHigh
      expr: (100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)) > 85
      for: 15m
      labels:
        severity: warning
        team: platform
      annotations:
        summary: "High CPU usage on {{ $labels.instance }}"
        description: "CPU usage is above 85% for 15 minutes on {{ $labels.instance }}"
        runbook_url: "https://example.com/runbooks/high-cpu"
```

## <span style="color: #0366d6;">🔄 Implementing Monitoring as Code</span>

Manage your monitoring configuration as code for consistency and version control:

### <span style="color: #0366d6;">Azure Monitor Templates</span>

Use ARM or Bicep templates to define Azure Monitor configurations:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "microsoft.insights/metricAlerts",
      "apiVersion": "2018-03-01",
      "name": "three-horizons-aks-cpu-alert",
      "location": "global",
      "properties": {
        "description": "Alert when AKS cluster CPU exceeds threshold",
        "severity": 2,
        "enabled": true,
        "scopes": [
          "[resourceId('Microsoft.ContainerService/managedClusters', 'three-horizons-aks')]"
        ],
        "evaluationFrequency": "PT5M",
        "windowSize": "PT15M",
        "criteria": {
          "odata.type": "Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria",
          "allOf": [
            {
              "name": "CPU Usage",
              "metricName": "node_cpu_usage_percentage",
              "dimensions": [],
              "operator": "GreaterThan",
              "threshold": 85,
              "timeAggregation": "Average"
            }
          ]
        },
        "actions": [
          {
            "actionGroupId": "[resourceId('Microsoft.Insights/actionGroups', 'three-horizons-ops-team')]"
          }
        ]
      }
    }
  ]
}
```

### <span style="color: #0366d6;">Grafana Dashboard as Code</span>

Maintain Grafana dashboards as code:

```json
{
  "annotations": {
    "list": []
  },
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 0,
  "links": [],
  "liveNow": false,
  "panels": [
    {
      "datasource": {
        "type": "prometheus",
        "uid": "prometheus"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisBorderShow": false,
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "insertNulls": false,
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "percent"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "id": 1,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "list",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "editorMode": "code",
          "expr": "sum(rate(container_cpu_usage_seconds_total{container!=\"\"}[5m])) by (pod)",
          "legendFormat": "__auto",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "Pod CPU Usage",
      "type": "timeseries"
    }
  ],
  "refresh": "",
  "schemaVersion": 38,
  "style": "dark",
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-6h",
    "to": "now"
  },
  "title": "Three Horizons Platform",
  "uid": "three-horizons-platform",
  "version": 0,
  "weekStart": ""
}
```

## <span style="color: #0366d6;">🔄 Continuous Monitoring Improvement</span>

Implement a continuous improvement cycle for your monitoring:

1. **Review Alert Patterns**: Regularly analyze alert patterns for improvement opportunities
2. **Tune Thresholds**: Adjust alert thresholds based on operational experience
3. **Enhance Coverage**: Continuously expand monitoring to cover new components
4. **Automate Remediation**: Develop automated responses for common alert scenarios
5. **Feedback Loop**: Establish regular reviews with platform teams to refine monitoring

## <span style="color: #0366d6;">📚 Related Resources</span>

Continue your monitoring journey with these additional resources:

- [Platform Logging](logging.md) - Implementing comprehensive logging capabilities
- [Scaling Strategy](scaling.md) - Monitoring to support platform scaling
- [Troubleshooting Guide](troubleshooting.md) - Using monitoring for effective troubleshooting
- [Dashboards Guide](dashboards.md) - Detailed dashboard implementation guidance

---

<footer>
  <p align="center">Last updated: April 10, 2025 | <a href="../../../.github/CONTRIBUTING.md">Contribute to this document</a></p>
</footer>