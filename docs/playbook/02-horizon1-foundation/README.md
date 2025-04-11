---
title: "Horizon 1: Foundation"
description: "Implementing the core foundation components of the Three Horizons Platform"
position_in_journey: "3. Horizon 1"
previous_doc: "../01-getting-started/environment-setup.md"
next_doc: "azure-setup.md"
last_updated: "May 2024"
---

# Horizon 1: Foundation

**Navigation**: [Home](../README.md) > Horizon 1: Foundation

The first horizon establishes the fundamental foundation of your development platform. This section guides you through implementing the core infrastructure, services, and integrations that form the basis of the Three Horizons Platform.

## What You'll Build in Horizon 1

![Horizon 1 Components](../../../assets/diagrams/horizon1/horizon1-components.svg)

In Horizon 1, you will implement:

1. **Azure Infrastructure** - Kubernetes (AKS/ARO), networking, and security foundation
2. **GitHub Enterprise Setup** - Organization, repositories, and basic CI/CD
3. **Developer Hub Installation** - Developer portal deployment and configuration
4. **Core Integrations** - Basic connectivity between all components

## Implementation Approach

The Foundation horizon follows a structured implementation sequence:

1. **Infrastructure Provisioning** - Set up the cloud infrastructure using Terraform
2. **Platform Installation** - Deploy and configure the core platform components
3. **Integration Configuration** - Establish connectivity between components
4. **Validation & Testing** - Verify the foundation implementation

## Expected Outcomes

By completing Horizon 1, you will achieve:

- A functioning Kubernetes platform (AKS or ARO) with proper security controls
- GitHub Enterprise environment with basic organizational structure
- Developer Hub portal accessible to users with initial catalog
- Authentication and authorization across all components
- Observability setup for platform monitoring

## Key Architectural Decisions

During Horizon 1 implementation, you'll need to make several key architectural decisions:

| Decision Point | Options | Considerations |
|----------------|---------|----------------|
| Kubernetes Platform | AKS vs ARO | Operational model, OpenShift requirements |
| Network Architecture | Hub-spoke vs flat | Complexity, security boundaries |
| Identity Provider | Azure AD vs GitHub | SSO requirements, existing identity infrastructure |
| Deployment Strategy | Terraform vs ARM | Team skills, infrastructure-as-code preferences |
| Monitoring Approach | Azure Monitor vs custom | Operational capabilities, existing investments |

## Implementation Checklist

Use this high-level checklist to track your Horizon 1 implementation progress:

- [ ] Azure infrastructure deployed
- [ ] Kubernetes platform operational
- [ ] GitHub Enterprise organization configured
- [ ] Developer Hub deployed and accessible
- [ ] Core integrations established
- [ ] Security controls implemented
- [ ] Monitoring and observability configured
- [ ] Initial validation completed

## Next Steps

Start implementing Horizon 1 by setting up the Azure infrastructure:

👉 [**Azure Setup**](azure-setup.md)

---

<footer>
  <p align="center">🔄 Last updated: May 2024 | <a href="../../../.github/CONTRIBUTING.md">Contribute to this documentation</a></p>
</footer> 