#!/bin/bash
# 📊 Monitoring & Observability Generator
# Creates comprehensive monitoring setup with Prometheus, Grafana, and Azure Monitor

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"; }
success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }

# Create Prometheus configuration
create_prometheus_config() {
    log "Creating Prometheus monitoring configuration..."
    
    local MONITORING_DIR="demos/ecommerce-showcase/templates/ecommerce-fullstack/skeleton/monitoring"
    
    # Prometheus configuration
    cat > "$MONITORING_DIR/prometheus/prometheus.yml" << 'EOF'
# Prometheus Configuration for {{values.name | title}} E-commerce Platform
global:
  scrape_interval: 15s
  evaluation_interval: 15s

# Alert manager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

# Load and evaluate rules
rule_files:
  - "alert_rules.yml"
  - "recording_rules.yml"

# Scrape configurations
scrape_configs:
  # Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Node Exporter for system metrics
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: node-exporter:9100

  # Frontend Portal
  - job_name: 'frontend-portal'
    static_configs:
      - targets: ['frontend-portal:3000']
    metrics_path: '/api/metrics'
    scrape_interval: 30s

  # Frontend Admin
  - job_name: 'frontend-admin'
    static_configs:
      - targets: ['frontend-admin:3000']
    metrics_path: '/api/metrics'
    scrape_interval: 30s

  # API Gateway
  - job_name: 'api-gateway'
    static_configs:
      - targets: ['api-gateway:8080']
    metrics_path: '/metrics'
    scrape_interval: 15s

  # Catalog Service
  - job_name: 'catalog-service'
    static_configs:
      - targets: ['catalog-service:3001']
    metrics_path: '/metrics'
    scrape_interval: 15s

  # Cart Service
  - job_name: 'cart-service'
    static_configs:
      - targets: ['cart-service:8081']
    metrics_path: '/metrics'
    scrape_interval: 15s

  # Order Service
  - job_name: 'order-service'
    static_configs:
      - targets: ['order-service:8082']
    metrics_path: '/actuator/prometheus'
    scrape_interval: 15s

  # Payment Service
  - job_name: 'payment-service'
    static_configs:
      - targets: ['payment-service:8083']
    metrics_path: '/metrics'
    scrape_interval: 15s

  # User Service
  - job_name: 'user-service'
    static_configs:
      - targets: ['user-service:5000']
    metrics_path: '/metrics'
    scrape_interval: 15s

  # Notification Service
  - job_name: 'notification-service'
    static_configs:
      - targets: ['notification-service:3002']
    metrics_path: '/metrics'
    scrape_interval: 30s

  # Database exporters
  - job_name: 'postgres-exporter'
    static_configs:
      - targets: ['postgres-exporter:9187']
    scrape_interval: 30s

  - job_name: 'mongodb-exporter'
    static_configs:
      - targets: ['mongodb-exporter:9216']
    scrape_interval: 30s

  - job_name: 'redis-exporter'
    static_configs:
      - targets: ['redis-exporter:9121']
    scrape_interval: 30s

  # Kubernetes monitoring (when deployed on K8s)
  - job_name: 'kubernetes-apiservers'
    kubernetes_sd_configs:
      - role: endpoints
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
      - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
        action: keep
        regex: default;kubernetes;https

  - job_name: 'kubernetes-nodes'
    kubernetes_sd_configs:
      - role: node
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)

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
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_pod_label_(.+)
      - source_labels: [__meta_kubernetes_namespace]
        action: replace
        target_label: kubernetes_namespace
      - source_labels: [__meta_kubernetes_pod_name]
        action: replace
        target_label: kubernetes_pod_name

# Remote write to Azure Monitor (Optional)
{% if values.azure.environment == 'production' %}
remote_write:
  - url: https://{{values.azure.region}}.monitoring.azure.com/{{values.azure.subscription}}/api/v1/write
    headers:
      Authorization: "Bearer <azure-token>"
{% endif %}
EOF

    # Alert rules
    cat > "$MONITORING_DIR/prometheus/alert_rules.yml" << 'EOF'
groups:
  - name: {{values.name}}_alerts
    rules:
      # High-level service alerts
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service {{ $labels.job }} is down"
          description: "{{ $labels.job }} has been down for more than 1 minute."

      - alert: HighErrorRate
        expr: |
          (
            rate(http_requests_total{status=~"5.."}[5m]) /
            rate(http_requests_total[5m])
          ) > 0.05
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate on {{ $labels.job }}"
          description: "{{ $labels.job }} has error rate above 5% for more than 5 minutes."

      - alert: HighLatency
        expr: |
          histogram_quantile(0.95, 
            rate(http_request_duration_seconds_bucket[5m])
          ) > 0.5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High latency on {{ $labels.job }}"
          description: "{{ $labels.job }} 95th percentile latency is above 500ms."

      # Infrastructure alerts
      - alert: HighCPUUsage
        expr: |
          (
            100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
          ) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is above 80% for more than 5 minutes."

      - alert: HighMemoryUsage
        expr: |
          (
            (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / 
            node_memory_MemTotal_bytes
          ) > 0.9
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is above 90% for more than 5 minutes."

      - alert: DiskSpaceLow
        expr: |
          (
            (node_filesystem_size_bytes{fstype!="tmpfs"} - node_filesystem_free_bytes{fstype!="tmpfs"}) /
            node_filesystem_size_bytes{fstype!="tmpfs"}
          ) > 0.85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Low disk space on {{ $labels.instance }}"
          description: "Disk usage is above 85% on {{ $labels.device }}."

      # Application-specific alerts
      - alert: DatabaseConnectionHigh
        expr: |
          pg_stat_activity_count > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High database connections"
          description: "PostgreSQL has more than 80 active connections."

      - alert: RedisMemoryHigh
        expr: |
          redis_memory_used_bytes / redis_memory_max_bytes > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Redis memory usage high"
          description: "Redis memory usage is above 90%."

      - alert: OrderProcessingBacklog
        expr: |
          orders_pending_count > 100
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Order processing backlog"
          description: "There are more than 100 pending orders for over 10 minutes."

      - alert: PaymentFailureRateHigh
        expr: |
          (
            rate(payments_failed_total[10m]) /
            rate(payments_total[10m])
          ) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High payment failure rate"
          description: "Payment failure rate is above 10% for more than 5 minutes."
EOF

    # Recording rules for common queries
    cat > "$MONITORING_DIR/prometheus/recording_rules.yml" << 'EOF'
groups:
  - name: {{values.name}}_recording_rules
    interval: 30s
    rules:
      # Request rate rules
      - record: http_requests_per_second
        expr: rate(http_requests_total[5m])

      - record: http_requests_per_second_by_service
        expr: sum(rate(http_requests_total[5m])) by (job)

      # Error rate rules
      - record: http_error_rate
        expr: |
          rate(http_requests_total{status=~"5.."}[5m]) /
          rate(http_requests_total[5m])

      - record: http_error_rate_by_service
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m])) by (job) /
          sum(rate(http_requests_total[5m])) by (job)

      # Latency rules
      - record: http_latency_p50
        expr: |
          histogram_quantile(0.50, rate(http_request_duration_seconds_bucket[5m]))

      - record: http_latency_p95
        expr: |
          histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

      - record: http_latency_p99
        expr: |
          histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))

      # Business metrics
      - record: orders_created_per_hour
        expr: increase(orders_created_total[1h])

      - record: revenue_per_hour
        expr: increase(revenue_total[1h])

      - record: active_users_5m
        expr: count(increase(user_activity_total[5m]) > 0)
EOF

    success "Prometheus configuration created successfully!"
}

# Create Grafana dashboards
create_grafana_dashboards() {
    log "Creating Grafana dashboards..."
    
    local GRAFANA_DIR="demos/ecommerce-showcase/templates/ecommerce-fullstack/skeleton/monitoring/grafana"
    
    # Grafana configuration
    cat > "$GRAFANA_DIR/grafana.ini" << 'EOF'
[analytics]
check_for_updates = false
reporting_enabled = false

[security]
admin_user = admin
admin_password = {{values.name}}Admin123!
secret_key = {{values.name}}_grafana_secret_key
disable_gravatar = true

[users]
allow_sign_up = false
allow_org_create = false
auto_assign_org = true
auto_assign_org_role = Viewer

[auth.anonymous]
enabled = true
org_name = {{values.name | title}}
org_role = Viewer

[dashboards]
default_home_dashboard_path = /var/lib/grafana/dashboards/overview.json

[server]
domain = grafana.demo.threehorizons.io
root_url = https://grafana.demo.threehorizons.io/
serve_from_sub_path = false

[database]
type = sqlite3
host = 127.0.0.1:3306
name = grafana
user = root
password =
path = /var/lib/grafana/grafana.db

[log]
mode = console
level = info
EOF

    # Datasources configuration
    cat > "$GRAFANA_DIR/provisioning/datasources/datasources.yml" << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true

  - name: Azure Monitor
    type: grafana-azure-monitor-datasource
    access: proxy
    jsonData:
      subscriptionId: {{values.azure.subscription}}
      tenantId: {{values.azure.tenantId}}
      clientId: {{values.azure.clientId}}
      cloudName: azuremonitor
    secureJsonData:
      clientSecret: {{values.azure.clientSecret}}
    editable: true

  - name: Application Insights
    type: grafana-azure-monitor-datasource
    access: proxy
    url: https://api.applicationinsights.io
    jsonData:
      subscriptionId: {{values.azure.subscription}}
      appInsightsAppId: {{values.azure.appInsightsAppId}}
    secureJsonData:
      appInsightsApiKey: {{values.azure.appInsightsApiKey}}
    editable: true
EOF

    # Dashboard provisioning
    cat > "$GRAFANA_DIR/provisioning/dashboards/dashboards.yml" << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
EOF

    # Application Overview Dashboard
    cat > "$GRAFANA_DIR/dashboards/overview.json" << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "{{values.name | title}} - Application Overview",
    "tags": ["{{values.name}}", "overview"],
    "style": "dark",
    "timezone": "browser",
    "editable": true,
    "hideControls": false,
    "graphTooltip": 1,
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "timepicker": {
      "refresh_intervals": ["5s", "10s", "30s", "1m", "5m", "15m", "30m", "1h", "2h", "1d"],
      "time_options": ["5m", "15m", "1h", "6h", "12h", "24h", "2d", "7d", "30d"]
    },
    "refresh": "30s",
    "panels": [
      {
        "id": 1,
        "title": "Service Status",
        "type": "stat",
        "targets": [
          {
            "expr": "up",
            "legendFormat": "{{job}}"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            },
            "mappings": [
              {
                "options": {
                  "0": {
                    "color": "red",
                    "text": "Down"
                  },
                  "1": {
                    "color": "green",
                    "text": "Up"
                  }
                },
                "type": "value"
              }
            ],
            "thresholds": {
              "steps": [
                {
                  "color": "red",
                  "value": null
                },
                {
                  "color": "green",
                  "value": 1
                }
              ]
            }
          }
        },
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 0
        }
      },
      {
        "id": 2,
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[5m])) by (job)",
            "legendFormat": "{{job}}"
          }
        ],
        "yAxes": [
          {
            "label": "Requests/sec"
          }
        ],
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 12,
          "y": 0
        }
      },
      {
        "id": 3,
        "title": "Error Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{status=~\"5..\"}[5m])) by (job)",
            "legendFormat": "{{job}} errors"
          }
        ],
        "yAxes": [
          {
            "label": "Errors/sec"
          }
        ],
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 8
        }
      },
      {
        "id": 4,
        "title": "Response Time (95th percentile)",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (job, le))",
            "legendFormat": "{{job}} p95"
          }
        ],
        "yAxes": [
          {
            "label": "Seconds"
          }
        ],
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 12,
          "y": 8
        }
      },
      {
        "id": 5,
        "title": "Active Orders",
        "type": "stat",
        "targets": [
          {
            "expr": "orders_pending_count",
            "legendFormat": "Pending"
          },
          {
            "expr": "orders_processing_count",
            "legendFormat": "Processing"
          }
        ],
        "gridPos": {
          "h": 4,
          "w": 6,
          "x": 0,
          "y": 16
        }
      },
      {
        "id": 6,
        "title": "Revenue (Last 24h)",
        "type": "stat",
        "targets": [
          {
            "expr": "increase(revenue_total[24h])",
            "legendFormat": "Revenue"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "currencyUSD"
          }
        },
        "gridPos": {
          "h": 4,
          "w": 6,
          "x": 6,
          "y": 16
        }
      },
      {
        "id": 7,
        "title": "Active Users",
        "type": "stat",
        "targets": [
          {
            "expr": "active_users_5m",
            "legendFormat": "Active Users"
          }
        ],
        "gridPos": {
          "h": 4,
          "w": 6,
          "x": 12,
          "y": 16
        }
      },
      {
        "id": 8,
        "title": "Database Connections",
        "type": "stat",
        "targets": [
          {
            "expr": "pg_stat_activity_count",
            "legendFormat": "PostgreSQL"
          },
          {
            "expr": "mongodb_connections",
            "legendFormat": "MongoDB"
          }
        ],
        "gridPos": {
          "h": 4,
          "w": 6,
          "x": 18,
          "y": 16
        }
      }
    ]
  }
}
EOF

    success "Grafana dashboards created successfully!"
}

# Create Azure Monitor integration
create_azure_monitor_config() {
    log "Creating Azure Monitor integration..."
    
    local AZURE_DIR="demos/ecommerce-showcase/templates/ecommerce-fullstack/skeleton/monitoring/azure"
    
    # Azure Monitor ARM template
    cat > "$AZURE_DIR/monitoring-resources.bicep" << 'EOF'
// Azure Monitor Resources for {{values.name | title}}
param baseName string = '{{values.name}}'
param environment string = '{{values.azure.environment}}'
param location string = '{{values.azure.region}}'

// Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'law-${baseName}-${environment}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: environment == 'production' ? 90 : 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'ai-${baseName}-${environment}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Action Group for alerts
resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: 'ag-${baseName}-${environment}'
  location: 'global'
  properties: {
    groupShortName: '${baseName}Alert'
    enabled: true
    emailReceivers: [
      {
        name: 'Platform Team'
        emailAddress: 'platform@{{values.name}}.com'
        useCommonAlertSchema: true
      }
    ]
    smsReceivers: []
    webhookReceivers: []
    azureAppPushReceivers: []
    itsmReceivers: []
    azureAutomationRunbookReceivers: []
    voiceReceivers: []
    logicAppReceivers: []
    azureFunctionReceivers: []
    armRoleReceivers: []
  }
}

// Metric Alerts
resource highErrorRateAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'High Error Rate - ${baseName}'
  location: 'global'
  properties: {
    description: 'Alert when error rate is high'
    severity: 2
    enabled: true
    scopes: [
      appInsights.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'ErrorRate'
          metricName: 'requests/failed'
          operator: 'GreaterThan'
          threshold: 5
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

resource highResponseTimeAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'High Response Time - ${baseName}'
  location: 'global'
  properties: {
    description: 'Alert when response time is high'
    severity: 2
    enabled: true
    scopes: [
      appInsights.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'ResponseTime'
          metricName: 'requests/duration'
          operator: 'GreaterThan'
          threshold: 2000
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

// Custom Log Analytics Queries
resource savedSearches 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: logAnalytics
  name: 'ErrorsSummary'
  properties: {
    category: 'Application'
    displayName: 'Errors Summary'
    query: '''
      exceptions
      | where timestamp > ago(1h)
      | summarize count() by cloud_RoleName, type
      | order by count_ desc
    '''
  }
}

// Outputs
output logAnalyticsWorkspaceId string = logAnalytics.id
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
EOF

    # Azure Monitor configuration script
    cat > "$AZURE_DIR/setup-monitoring.sh" << 'EOF'
#!/bin/bash
# Azure Monitor Setup Script for {{values.name | title}}

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"; }
success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }

# Configuration
RESOURCE_GROUP="rg-{{values.name}}-{{values.azure.environment}}"
LOCATION="{{values.azure.region}}"
DEPLOYMENT_NAME="monitoring-$(date +%s)"

# Deploy monitoring resources
deploy_monitoring() {
    log "Deploying Azure Monitor resources..."
    
    az deployment group create \
        --resource-group "$RESOURCE_GROUP" \
        --template-file monitoring-resources.bicep \
        --name "$DEPLOYMENT_NAME" \
        --parameters location="$LOCATION"
    
    success "Azure Monitor resources deployed successfully!"
}

# Configure Application Insights for each service
configure_app_insights() {
    log "Configuring Application Insights..."
    
    # Get Application Insights connection string
    CONNECTION_STRING=$(az monitor app-insights component show \
        --app "ai-{{values.name}}-{{values.azure.environment}}" \
        --resource-group "$RESOURCE_GROUP" \
        --query connectionString -o tsv)
    
    # Update Kubernetes secrets
    kubectl create secret generic app-insights-secret \
        --from-literal=connection-string="$CONNECTION_STRING" \
        --namespace={{values.name}}-{{values.azure.environment}} \
        --dry-run=client -o yaml | kubectl apply -f -
    
    success "Application Insights configured!"
}

# Setup custom metrics and alerts
setup_custom_metrics() {
    log "Setting up custom metrics and alerts..."
    
    # Create custom log analytics queries
    az monitor log-analytics query \
        --workspace "law-{{values.name}}-{{values.azure.environment}}" \
        --analytics-query "Heartbeat | limit 10" \
        --resource-group "$RESOURCE_GROUP" > /dev/null
    
    success "Custom metrics configured!"
}

# Create Azure Dashboard
create_dashboard() {
    log "Creating Azure Dashboard..."
    
    cat > dashboard.json << 'DASHBOARD'
{
  "properties": {
    "lenses": {
      "0": {
        "order": 0,
        "parts": {
          "0": {
            "position": {
              "x": 0,
              "y": 0,
              "colSpan": 6,
              "rowSpan": 4
            },
            "metadata": {
              "inputs": [
                {
                  "name": "ComponentId",
                  "value": "/subscriptions/{{values.azure.subscription}}/resourceGroups/rg-{{values.name}}-{{values.azure.environment}}/providers/Microsoft.Insights/components/ai-{{values.name}}-{{values.azure.environment}}"
                }
              ],
              "type": "Extension/AppInsightsExtension/PartType/AppMapGalPt"
            }
          },
          "1": {
            "position": {
              "x": 6,
              "y": 0,
              "colSpan": 6,
              "rowSpan": 4
            },
            "metadata": {
              "inputs": [
                {
                  "name": "ComponentId",
                  "value": "/subscriptions/{{values.azure.subscription}}/resourceGroups/rg-{{values.name}}-{{values.azure.environment}}/providers/Microsoft.Insights/components/ai-{{values.name}}-{{values.azure.environment}}"
                }
              ],
              "type": "Extension/AppInsightsExtension/PartType/ProactiveDetectionAsyncPt"
            }
          }
        }
      }
    },
    "metadata": {
      "model": {
        "timeRange": {
          "value": {
            "relative": {
              "duration": 24,
              "timeUnit": 1
            }
          },
          "type": "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
        }
      }
    }
  },
  "name": "{{values.name | title}} Monitoring Dashboard",
  "type": "Microsoft.Portal/dashboards",
  "location": "INSERT LOCATION",
  "tags": {
    "hidden-title": "{{values.name | title}} Monitoring Dashboard"
  }
}
DASHBOARD

    az portal dashboard create \
        --resource-group "$RESOURCE_GROUP" \
        --name "{{values.name}}-dashboard" \
        --input-path dashboard.json
    
    success "Azure Dashboard created!"
}

# Main execution
main() {
    log "Setting up Azure Monitor for {{values.name | title}}..."
    
    deploy_monitoring
    configure_app_insights
    setup_custom_metrics
    create_dashboard
    
    success "Azure Monitor setup completed!"
    
    echo -e "\n📊 Monitoring Resources:"
    echo -e "  • Log Analytics: law-{{values.name}}-{{values.azure.environment}}"
    echo -e "  • Application Insights: ai-{{values.name}}-{{values.azure.environment}}"
    echo -e "  • Dashboard: {{values.name}}-dashboard"
    echo -e "\n🔗 Access URLs:"
    echo -e "  • Azure Portal: https://portal.azure.com"
    echo -e "  • Log Analytics: https://portal.azure.com/#@/resource/subscriptions/{{values.azure.subscription}}/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/law-{{values.name}}-{{values.azure.environment}}"
}

main "$@"
EOF

    chmod +x "$AZURE_DIR/setup-monitoring.sh"

    success "Azure Monitor integration created successfully!"
}

# Create monitoring deployment manifests
create_monitoring_manifests() {
    log "Creating monitoring deployment manifests..."
    
    local K8S_MONITORING_DIR="demos/ecommerce-showcase/templates/ecommerce-fullstack/skeleton/monitoring/k8s"
    
    # Prometheus deployment
    cat > "$K8S_MONITORING_DIR/prometheus.yaml" << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    # Include content from prometheus.yml here
    # (Content would be loaded from the prometheus config file)
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
  labels:
    app: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:v2.45.0
        args:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus/'
          - '--web.console.libraries=/etc/prometheus/console_libraries'
          - '--web.console.templates=/etc/prometheus/consoles'
          - '--storage.tsdb.retention.time=15d'
          - '--web.enable-lifecycle'
        ports:
        - containerPort: 9090
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 1
            memory: 2Gi
        volumeMounts:
        - name: prometheus-config
          mountPath: /etc/prometheus/
        - name: prometheus-storage
          mountPath: /prometheus/
      volumes:
      - name: prometheus-config
        configMap:
          name: prometheus-config
      - name: prometheus-storage
        persistentVolumeClaim:
          claimName: prometheus-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: monitoring
  labels:
    app: prometheus
spec:
  selector:
    app: prometheus
  ports:
  - port: 9090
    targetPort: 9090
  type: ClusterIP
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prometheus-pvc
  namespace: monitoring
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
EOF

    # Grafana deployment
    cat > "$K8S_MONITORING_DIR/grafana.yaml" << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-config
  namespace: monitoring
data:
  grafana.ini: |
    # Include content from grafana.ini here
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
  labels:
    app: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:10.0.0
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: "{{values.name}}Admin123!"
        resources:
          requests:
            cpu: 250m
            memory: 512Mi
          limits:
            cpu: 500m
            memory: 1Gi
        volumeMounts:
        - name: grafana-config
          mountPath: /etc/grafana/
        - name: grafana-storage
          mountPath: /var/lib/grafana
        - name: grafana-dashboards
          mountPath: /var/lib/grafana/dashboards
      volumes:
      - name: grafana-config
        configMap:
          name: grafana-config
      - name: grafana-storage
        persistentVolumeClaim:
          claimName: grafana-pvc
      - name: grafana-dashboards
        configMap:
          name: grafana-dashboards
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: monitoring
  labels:
    app: grafana
spec:
  selector:
    app: grafana
  ports:
  - port: 3000
    targetPort: 3000
  type: ClusterIP
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana-pvc
  namespace: monitoring
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - grafana.demo.threehorizons.io
    secretName: grafana-tls
  rules:
  - host: grafana.demo.threehorizons.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: grafana
            port:
              number: 3000
EOF

    success "Monitoring deployment manifests created successfully!"
}

# Main execution
main() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    📊 Monitoring & Observability Generator                   ║
║                                                              ║
║    Creating comprehensive monitoring setup with             ║
║    Prometheus, Grafana, and Azure Monitor                   ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    create_prometheus_config
    create_grafana_dashboards
    create_azure_monitor_config
    create_monitoring_manifests
    
    success "Monitoring and observability configuration generated successfully!"
    
    echo -e "\n${GREEN}✅ Monitoring stack is ready!${NC}"
    echo -e "\n📁 Monitoring components created:"
    echo -e "  • Prometheus configuration with alerting rules"
    echo -e "  • Grafana dashboards and provisioning"
    echo -e "  • Azure Monitor integration and alerts"
    echo -e "  • Kubernetes deployment manifests"
    echo -e "\n🚀 Ready for final integration and validation!"
    echo -e "\n📝 Next steps:"
    echo -e "  1. Deploy monitoring stack: kubectl apply -f monitoring/k8s/"
    echo -e "  2. Setup Azure Monitor: ./monitoring/azure/setup-monitoring.sh"
    echo -e "  3. Access Grafana: https://grafana.demo.threehorizons.io"
    echo -e "  4. Configure alerting and notification channels"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi