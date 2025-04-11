---
title: "Monitoring Dashboards"
description: "Dashboard templates for monitoring the Three Horizons Platform"
position_in_journey: "4.4 Monitoring Resources"
previous_doc: "../logic-apps/README.md"
next_doc: "../kql-queries/README.md"
last_updated: "April 10, 2025"
---

# Monitoring Dashboard Examples

**Navigation:** [Home](../../../README.md) > [Documentation Map](../../DOCUMENTATION_MAP.md) > [Examples](../README.md) > Monitoring Dashboards

## Your Observability Journey

Effective monitoring is crucial for maintaining the health and performance of the Three Horizons Platform. This collection of dashboard examples demonstrates how to implement comprehensive monitoring across your platform components, providing immediate visibility into system health, performance metrics, and potential issues.

Each dashboard example addresses specific monitoring needs throughout your platform implementation, from basic infrastructure monitoring to advanced application insights.

## Overview

These examples showcase proven patterns for implementing monitoring dashboards using Azure Monitor, Grafana, and other tools within the Three Horizons Platform ecosystem. Each example includes complete dashboard definitions, visualization configurations, and implementation guidance.

## Prerequisites

Before implementing these dashboard examples:

- Ensure you have appropriate monitoring tools deployed (Azure Monitor, Log Analytics, Grafana, etc.)
- Configure necessary data sources and collection agents
- Review the [Operations Guide](../../4-operations-guide/README.md) for monitoring context
- Understand the [Architecture Overview](../../1-architecture/README.md)

## Example Dashboards

| Example | Description | Use Case |
|---------|-------------|----------|
| [Platform Overview](platform-overview.md) | Holistic view of platform health | Executive view |
| [Kubernetes Cluster Monitoring](kubernetes-monitoring.md) | AKS/ARO cluster metrics and health | Cluster operations |
| [Golden Paths Dashboard](golden-paths-dashboard.md) | Developer experience and Golden Path adoption | Platform teams |
| [Application Performance](application-performance.md) | Application-level metrics and insights | Development teams |
| [Security Compliance](security-compliance.md) | Security posture and compliance status | Security teams |
| [Cost Management](cost-management.md) | Resource utilization and cost tracking | Finance/Operations |

## Implementation Path

Follow this recommended sequence when implementing dashboards:

1. Start with the **Platform Overview** for a holistic view
2. Add **Kubernetes Cluster Monitoring** for infrastructure visibility
3. Implement the **Golden Paths Dashboard** to track developer experience
4. Add **Application Performance** for service-level insights
5. Configure **Security Compliance** for security visibility
6. Implement **Cost Management** for resource optimization

This progressive approach builds your monitoring capabilities in layers, starting with foundational visibility and adding deeper insights over time.

## Dashboard Components

Each dashboard example includes:

1. **Dashboard Definition** - JSON or YAML configuration to import directly
2. **Data Sources Configuration** - Setup for necessary data connections
3. **Visualization Details** - Charts, graphs, and indicators with explanations
4. **Alert Configuration** - Recommended thresholds and alert rules
5. **Customization Guidance** - How to adapt for your environment

## Integration with Three Horizons Platform

These dashboard examples integrate with other Three Horizons Platform components:

- AKS and ARO clusters for infrastructure metrics
- Application Insights for application telemetry
- Azure Security Center for security posture
- Log Analytics for centralized logging
- Azure Cost Management for resource utilization

## Common Dashboard Elements

Across all dashboard examples, you'll find these consistent elements:

### Status Overview Panels

```json
{
  "gridPos": {
    "h": 4,
    "w": 24,
    "x": 0,
    "y": 0
  },
  "id": 2,
  "panels": [],
  "title": "Platform Status",
  "type": "row"
}
```

### Time Range Selectors

```json
{
  "description": "",
  "fieldConfig": {
    "defaults": {},
    "overrides": []
  },
  "gridPos": {
    "h": 3,
    "w": 24,
    "x": 0,
    "y": 4
  },
  "id": 3,
  "options": {
    "timezones": [],
    "visibility": {}
  },
  "title": "Time Range",
  "type": "timeseries"
}
```

### Health Status Indicators

```json
{
  "datasource": "${datasource}",
  "fieldConfig": {
    "defaults": {
      "color": {
        "mode": "thresholds"
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
            "value": 1
          }
        ]
      }
    },
    "overrides": []
  },
  "gridPos": {
    "h": 5,
    "w": 4,
    "x": 0,
    "y": 7
  },
  "id": 4,
  "options": {
    "colorMode": "value",
    "graphMode": "area",
    "justifyMode": "auto",
    "orientation": "auto",
    "reduceOptions": {
      "calcs": [
        "lastNotNull"
      ],
      "fields": "",
      "values": false
    },
    "textMode": "auto"
  },
  "pluginVersion": "9.3.6",
  "title": "Component Health",
  "type": "stat"
}
```

## Related Resources

- [KQL Query Examples](../kql-queries/README.md)
- [Logic Apps Examples](../logic-apps/README.md)
- [Operations Guide](../../4-operations-guide/README.md)
- [Architecture Overview](../../1-architecture/README.md)

---

<footer>
  <p align="center">Last updated: April 10, 2025 | <a href="../../../.github/CONTRIBUTING.md">Contribute to this document</a></p>
</footer>