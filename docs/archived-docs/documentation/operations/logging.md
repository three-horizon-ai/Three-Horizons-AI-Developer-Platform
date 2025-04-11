# <span style="color: #0366d6;">🔹 Logging Strategy</span>

## <span style="color: #0366d6;">🔍 Overview</span>

This document outlines the comprehensive logging strategy for the Three Horizons platform. Effective logging is critical for troubleshooting, security monitoring, compliance, and operational insights. This guide covers log collection, processing, storage, and analysis across the platform.

## <span style="color: #0366d6;">🏗️ Logging Architecture</span>

### <span style="color: #0366d6;">High-Level Architecture</span>

The Three Horizons logging architecture consists of:

- **Log Sources**: Applications, infrastructure, security systems
- **Log Collection**: Agents and forwarding mechanisms
- **Log Processing**: Parsing, enrichment, and normalization
- **Log Storage**: Short-term and long-term retention
- **Log Analysis**: Query tools and visualization

### <span style="color: #0366d6;">Log Flow</span>

1. Logs are generated at source (application, infrastructure, etc.)
2. Logs are collected via agents or direct integration
3. Logs are processed and normalized to standard format
4. Logs are stored in appropriate storage tiers
5. Logs are indexed for fast querying
6. Logs are made available for analysis and alerting

## <span style="color: #0366d6;">🔹 Log Categories</span>

### <span style="color: #0366d6;">Infrastructure Logs</span>

| Source | Log Types | Collection Method | Retention |
|--------|-----------|-------------------|-----------|
| Azure Resources | Activity Logs, Resource Logs | Azure Monitor | 90 days |
| VMs | OS Logs, Event Logs | Log Analytics Agent | 30 days |
| Network Devices | Flow Logs, Security Events | Azure NSG Flow Logs | 30 days |
| Kubernetes | API Server, Scheduler, Controller Logs | Azure Monitor for Containers | 30 days |

### <span style="color: #0366d6;">Application Logs</span>

| Source | Log Types | Collection Method | Retention |
|--------|-----------|-------------------|-----------|
| Web Applications | Access Logs, Error Logs | Application Insights, Custom Logging | 30 days |
| APIs | Request/Response, Performance | Application Insights | 30 days |
| Background Services | Process Logs, Task Logs | Custom Logging, Log Analytics | 30 days |
| Databases | Query Logs, Error Logs | Azure Diagnostics | 14 days |

### <span style="color: #0366d6;">Security Logs</span>

| Source | Log Types | Collection Method | Retention |
|--------|-----------|-------------------|-----------|
| Identity Systems | Authentication, Authorization | Azure AD Logs | 90 days |
| Firewalls | Traffic Logs, Threat Logs | Azure Firewall Logs | 90 days |
| WAF | Request Logs, Violation Logs | Azure Application Gateway | 90 days |
| Security Services | Alerts, Audit Logs | Azure Security Center | 90 days |

### <span style="color: #0366d6;">Audit Logs</span>

| Source | Log Types | Collection Method | Retention |
|--------|-----------|-------------------|-----------|
| User Activity | Login, Access, Changes | Azure AD, Application Logs | 365 days |
| Admin Activity | Configuration Changes, Privilege Use | Azure Activity Logs | 365 days |
| Data Access | Read/Write Operations | Custom Logging | 180 days |
| Compliance | Policy, Configuration Changes | Azure Policy | 365 days |

## <span style="color: #0366d6;">🚀 Log Collection Implementation</span>

### <span style="color: #0366d6;">Azure Monitor and Log Analytics</span>

Configure Azure Monitor for centralized log collection:

```bash
# <span style="color: #0366d6;">📚 Enable diagnostic settings for a resource</span>
az monitor diagnostic-settings create \
  --name "send-to-log-analytics" \
  --resource "<resource-id>" \
  --workspace "<log-analytics-workspace-id>" \
  --logs '[{"category": "all", "enabled": true}]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'
```

### <span style="color: #0366d6;">Kubernetes Logging</span>

Configure log collection for Kubernetes:

```yaml
# <span style="color: #0366d6;">🔹 fluent-bit.yaml for Kubernetes log collection</span>
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluent-bit
  namespace: logging
spec:
  selector:
    matchLabels:
      app: fluent-bit
  template:
    metadata:
      labels:
        app: fluent-bit
    spec:
      containers:
      - name: fluent-bit
        image: fluent/fluent-bit:1.9
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: fluent-bit-config
          mountPath: /fluent-bit/etc/
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: fluent-bit-config
        configMap:
          name: fluent-bit-config
```

### <span style="color: #0366d6;">Application Logging</span>

#### .NET Applications

```csharp
// Configure Serilog for structured logging
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .Enrich.FromLogContext()
    .Enrich.WithProperty("Application", "ServiceName")
    .Enrich.WithProperty("Environment", "Production")
    .WriteTo.Console(outputTemplate: "{Timestamp:yyyy-MM-dd HH:mm:ss.fff} [{Level:u3}] {Message:lj} {Properties:j}{NewLine}{Exception}")
    .WriteTo.ApplicationInsights(telemetryClient, TelemetryConverter.Traces)
    .CreateLogger();
```

#### Node.js Applications

```javascript
// Configure Winston for structured logging
const winston = require('winston');
const { format } = winston;

const logger = winston.createLogger({
  level: 'info',
  format: format.combine(
    format.timestamp(),
    format.json()
  ),
  defaultMeta: { service: 'service-name', environment: 'production' },
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'application.log' })
  ]
});
```

## <span style="color: #0366d6;">🔹 Log Format Standards</span>

### <span style="color: #0366d6;">Standard Log Fields</span>

All logs should include these standard fields:

| Field | Description | Example |
|-------|-------------|---------|
| timestamp | Time of the event | `2023-10-15T14:32:10.456Z` |
| level | Log severity | `ERROR`, `INFO`, `DEBUG` |
| service | Service/component name | `payment-api` |
| environment | Deployment environment | `production` |
| traceId | Correlation ID for distributed tracing | `4c7d93f1-5a59-4a2c-889d-a25e49c3e209` |
| message | Human-readable description | `Payment processing failed` |
| data | Contextual information (JSON) | `{"orderId": "12345", "amount": 99.99}` |

### <span style="color: #0366d6;">Log Levels</span>

Use consistent log levels across all systems:

| Level | Usage | Examples |
|-------|-------|----------|
| ERROR | Failures requiring immediate attention | System crashes, data loss, service unavailability |
| WARN | Potential issues or unexpected behavior | Failed retries, deprecated API usage, resource constraints |
| INFO | Normal operational events | Service start/stop, user actions, significant state changes |
| DEBUG | Detailed information for troubleshooting | Function entry/exit, variable values, configuration details |
| TRACE | Highly detailed diagnostic information | Low-level function calls, loop iterations, detailed data flows |

### <span style="color: #0366d6;">JSON Structured Logging</span>

Implement structured logging with JSON format:

```json
{
  "timestamp": "2023-10-15T14:32:10.456Z",
  "level": "ERROR",
  "service": "payment-api",
  "environment": "production",
  "traceId": "4c7d93f1-5a59-4a2c-889d-a25e49c3e209",
  "message": "Payment processing failed",
  "data": {
    "orderId": "12345",
    "amount": 99.99,
    "paymentMethod": "credit_card",
    "errorCode": "GATEWAY_TIMEOUT",
    "attemptCount": 3
  },
  "host": "payment-api-pod-789abc",
  "userId": "user_123",
  "requestPath": "/api/payments",
  "requestMethod": "POST",
  "statusCode": 500,
  "duration": 1532
}
```

## <span style="color: #0366d6;">🔹 Log Storage and Retention</span>

### <span style="color: #0366d6;">Storage Strategy</span>

Implement a tiered storage approach:

1. **Hot Storage**: Recent logs (0-30 days)
   - Log Analytics Workspace
   - Elasticsearch
   - High query performance

2. **Warm Storage**: Medium-term logs (31-90 days)
   - Azure Storage Accounts (with indexing)
   - Medium query performance

3. **Cold Storage**: Long-term logs (91+ days)
   - Azure Archive Storage
   - Azure Data Lake
   - Batch query access

### <span style="color: #0366d6;">Retention Policy</span>

| Log Category | Hot Storage | Warm Storage | Cold Storage | Total Retention |
|--------------|-------------|--------------|--------------|-----------------|
| Infrastructure | 30 days | 60 days | 275 days | 365 days |
| Application | 30 days | 60 days | - | 90 days |
| Security | 30 days | 60 days | 275 days | 365 days |
| Audit | 30 days | 90 days | 610 days | 730 days |

### <span style="color: #0366d6;">Archiving Process</span>

```bash
# <span style="color: #0366d6;">🔹 Example script to archive logs to cold storage</span>
#!/bin/bash

# <span style="color: #0366d6;">🔹 Set variables</span>
DATE=$(date -d "90 days ago" +%Y-%m-%d)
CONTAINER="log-archive"
ACCOUNT_NAME="companystorage"

# <span style="color: #0366d6;">🔹 Export logs to Azure Blob Storage</span>
az monitor log-analytics data-export create \
  --name "archive-logs" \
  --resource-group "monitoring-rg" \
  --workspace-name "production-workspace" \
  --destination "storageAccount:/subscriptions/sub-id/resourceGroups/monitoring-rg/providers/Microsoft.Storage/storageAccounts/$ACCOUNT_NAME/blobServices/default/containers/$CONTAINER" \
  --table-names "SecurityEvent" "AzureActivity" "AuditLogs" \
  --enable true
```

## <span style="color: #0366d6;">🔹 Log Analysis</span>

### <span style="color: #0366d6;">Log Analytics Workspace</span>

Configure centralized Log Analytics Workspace:

```bash
# <span style="color: #0366d6;">🔹 Create Log Analytics workspace</span>
az monitor log-analytics workspace create \
  --resource-group "monitoring-rg" \
  --workspace-name "production-workspace" \
  --location "eastus" \
  --sku PerGB2018 \
  --retention-time 30
```

### <span style="color: #0366d6;">Common KQL Queries</span>

```kusto
// Find errors across all applications
AppEvents
| where TimeGenerated > ago(24h)
| where Level == "Error"
| summarize count() by Application, bin(TimeGenerated, 1h)
| render timechart

// Check failed authentications
AzureActivity
| where TimeGenerated > ago(7d)
| where OperationName has "LISTKEYS"
| project TimeGenerated, Caller, OperationName, Resource
| order by TimeGenerated desc

// Analyze API performance
requests
| where timestamp > ago(1h)
| where name startswith "GET /api/"
| summarize count(), avg(duration), percentiles(duration, 50, 95, 99) by name
| sort by percentile_duration_99 desc
```

### <span style="color: #0366d6;">Visualization Tools</span>

- **Azure Portal**: Built-in Log Analytics visualizations
- **Grafana**: Advanced dashboards with Log Analytics data source
- **Power BI**: Business-focused log analysis and reporting
- **Kibana**: If using Elasticsearch for log storage

## <span style="color: #0366d6;">🛡️ Security and Compliance</span>

### <span style="color: #0366d6;">Sensitive Data Handling</span>

- Implement PII/PHI detection and masking in logs
- Create log field classification (sensitive vs. non-sensitive)
- Configure data loss prevention for logging systems
- Audit log access and usage

```javascript
// Example of log sanitization in a Node.js application
function sanitizeLog(logData) {
  // Create a deep copy of the log data
  const sanitized = JSON.parse(JSON.stringify(logData));
  
  // Define patterns for sensitive data
  const patterns = {
    creditCard: /\b(?:\d{4}[-\s]?){3}\d{4}\b/g,
    ssn: /\b\d{3}[-\s]?\d{2}[-\s]?\d{4}\b/g,
    email: /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/g
  };
  
  // Recursive function to sanitize object properties
  function sanitizeObject(obj) {
    for (const key in obj) {
      if (typeof obj[key] === 'string') {
        // Check if the value matches any sensitive pattern
        for (const patternName in patterns) {
          if (patterns[patternName].test(obj[key])) {
            // Mask sensitive data
            obj[key] = obj[key].replace(patterns[patternName], `[REDACTED_${patternName.toUpperCase()}]`);
          }
        }
      } else if (typeof obj[key] === 'object' && obj[key] !== null) {
        // Recursively sanitize nested objects
        sanitizeObject(obj[key]);
      }
    }
  }
  
  sanitizeObject(sanitized);
  return sanitized;
}

// Use the sanitized log data
logger.info('User profile updated', sanitizeLog(userData));
```

### <span style="color: #0366d6;">Access Controls</span>

- Implement RBAC for log access
- Configure log data encryption at rest and in transit
- Create separate roles for log administrators and auditors
- Monitor privileged access to logging systems

## <span style="color: #0366d6;">🔧 Troubleshooting with Logs</span>

### <span style="color: #0366d6;">Log-Based Troubleshooting Methodology</span>

1. **Identify the Issue Scope**:
   - Determine affected services, timeframe, and users
   - Correlate with reported symptoms

2. **Search for Error Patterns**:
   - Start with ERROR level logs in the affected timeframe
   - Look for increased error rates or unusual patterns
   - Identify correlation IDs for affected transactions

3. **Trace Transaction Flow**:
   - Use correlation IDs to follow transaction across services
   - Establish sequence of events leading to failure
   - Identify first error in the chain

4. **Analyze Root Cause**:
   - Review detailed log data around the initial error
   - Examine environmental factors at the time of failure
   - Check for recent changes or unusual conditions

5. **Verify Resolution**:
   - Implement fix and verify error pattern disappears
   - Monitor for regression or related issues

### <span style="color: #0366d6;">Advanced Techniques</span>

- Use distributed tracing to analyze complex transactions
- Implement log-based anomaly detection
- Create failure patterns library for common issues
- Build playbooks for log-based troubleshooting scenarios

## <span style="color: #0366d6;">🔹 Related Documentation</span>

For related information, see other operations documentation.

## <span style="color: #0366d6;">🔹 Contact</span>


---

<footer>
  <p align="center">🔄 Last updated: April 2025 | Contribute to this document through <a href="../../.github/CONTRIBUTING.md">Pull Requests</a></p>
</footer>
