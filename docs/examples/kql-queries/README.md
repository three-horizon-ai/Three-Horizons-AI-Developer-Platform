---
title: "KQL Query Examples"
description: "Kusto Query Language (KQL) examples for monitoring the Three Horizons Platform"
position_in_journey: "4.5 Monitoring Resources"
previous_doc: "../dashboards/README.md"
next_doc: "../../4-operations-guide/README.md"
last_updated: "April 10, 2025"
---

# KQL Query Examples

**Navigation:** [Home](../../../README.md) > [Documentation Map](../../DOCUMENTATION_MAP.md) > [Examples](../README.md) > KQL Query Examples

## Your Log Analytics Journey

Effective log analysis is essential for troubleshooting, monitoring, and securing the Three Horizons Platform. This collection of Kusto Query Language (KQL) examples demonstrates how to extract valuable insights from your platform logs, helping you identify issues, track performance, and maintain security.

Each KQL example addresses specific monitoring needs you'll encounter during your platform operations, from basic operational queries to advanced security and performance analysis.

## Overview

These examples showcase proven KQL queries for Azure Log Analytics and other monitoring tools within the Three Horizons Platform ecosystem. Each example includes the complete query, explanation of its purpose, and guidance on interpreting results.

## Prerequisites

Before using these KQL examples:

- Configure Log Analytics workspaces for your environments
- Set up data collection from all platform components
- Review the [Operations Guide](../../4-operations-guide/README.md) for logging context
- Understand the [Architecture Overview](../../1-architecture/README.md)

## Example Query Categories

### Infrastructure Monitoring

| Example | Description | Use Case |
|---------|-------------|----------|
| [Cluster Node Status](infra-node-status.md) | Monitor AKS/ARO node health and resource usage | Node scaling |
| [Network Traffic Analysis](infra-network.md) | Analyze network flows and detect anomalies | Connectivity issues |
| [Resource Utilization Trends](infra-resource-trends.md) | Track resource usage patterns over time | Capacity planning |

### Application Monitoring

| Example | Description | Use Case |
|---------|-------------|----------|
| [Error Rate Analysis](app-error-rates.md) | Track application errors by service | Troubleshooting |
| [Performance Bottlenecks](app-performance.md) | Identify slow operations and requests | Performance tuning |
| [Dependency Mapping](app-dependencies.md) | Map service dependencies and failures | Architecture analysis |
| [Developer Experience](developer-experience.md) | Monitor developer productivity and golden path adoption | Platform teams |

### Security Monitoring

| Example | Description | Use Case |
|---------|-------------|----------|
| [Authentication Failures](security-auth-failures.md) | Detect unusual authentication patterns | Security incidents |
| [Privilege Escalation](security-priv-escalation.md) | Monitor for suspicious privilege changes | Threat detection |
| [Network Security Rules](security-network-rules.md) | Analyze network security group activity | Compliance |

## Implementation Guidance

### How to Use These Queries

1. Copy the query from the example page
2. Navigate to your Log Analytics workspace in the Azure portal
3. Paste the query into the query editor
4. Modify parameters as needed for your environment (e.g., workspace name, time range)
5. Run the query and analyze the results

### Creating Alerts from Queries

Many of these queries can be converted into alerts:

```kql
// Example alert query for high error rates
AppEvents
| where TimeGenerated > ago(15m)
| where EventType == "Error"
| summarize ErrorCount = count() by AppName, bin(TimeGenerated, 5m)
| where ErrorCount > 100
```

To create an alert:
1. Run your query in Log Analytics
2. Click "New alert rule"
3. Configure conditions, action groups, and alert details
4. Save and activate the alert

## Common KQL Patterns

These building blocks are used throughout our examples:

### Time Filtering

```kql
// Last 24 hours of data
| where TimeGenerated > ago(24h)

// Specific time range
| where TimeGenerated between (datetime('2025-04-01') .. datetime('2025-04-10'))

// Time bucketing for trend analysis
| summarize count() by bin(TimeGenerated, 1h)
```

### Data Transformation

```kql
// Group and count events
| summarize EventCount = count() by Category, EventType

// Calculate percentiles for performance analysis
| summarize 
    p50 = percentile(Duration, 50),
    p95 = percentile(Duration, 95),
    p99 = percentile(Duration, 99)
    by OperationName

// Join data from multiple sources
AppEvents
| join kind=inner (
    AppTraces
) on OperationId
```

### Visualization Preparation

```kql
// Format data for time series chart
| summarize count() by bin(TimeGenerated, 1h), AppName
| render timechart

// Format data for pie chart
| summarize count() by Category
| render piechart

// Format data for bar chart
| top 10 by Count desc
| render columnchart
```

## Integration with Three Horizons Platform

These KQL examples integrate with other Three Horizons Platform components:

- AKS and ARO logs for infrastructure insights
- Application Insights for application telemetry
- Azure AD logs for identity and security
- Azure Firewall and NSG logs for network security
- Azure Activity Logs for control plane operations

## Related Resources

- [Dashboard Examples](../dashboards/README.md)
- [Logic Apps Examples](../logic-apps/README.md)
- [Operations Guide](../../4-operations-guide/README.md)
- [Security Documentation](../../documentation/architecture/security-architecture.svg)

---

<footer>
  <p align="center">Last updated: April 10, 2025 | <a href="../../../.github/CONTRIBUTING.md">Contribute to this document</a></p>
</footer>