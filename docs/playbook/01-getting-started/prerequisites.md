---
title: "Platform Prerequisites"
description: "Technical and business requirements for implementing the Three Horizons Platform"
position_in_journey: "2.1 Getting Started"
previous_doc: "README.md"
next_doc: "environment-setup.md"
last_updated: "May 2024"
---

# Platform Prerequisites

**Navigation**: [Home](../README.md) > [Getting Started](README.md) > Prerequisites

This document outlines the technical and business prerequisites required to successfully implement the Three Horizons Platform. Ensuring these requirements are met before beginning the implementation will streamline the process and maximize your chances of success.

## Technical Prerequisites

### Azure Requirements

| Requirement | Description | Required/Optional |
|-------------|-------------|------------------|
| Azure Subscription | Enterprise-level subscription with appropriate access | Required |
| Azure RBAC Permissions | Permissions to create resource groups, networking, and AKS/ARO clusters | Required |
| Azure Virtual Network | Existing or ability to create new virtual networks | Required |
| Quota Limits | Sufficient quota for VMs, IP addresses, and other resources | Required |
| Express Route / VPN | For hybrid connectivity to on-premises (if applicable) | Optional |

### GitHub Requirements

| Requirement | Description | Required/Optional |
|-------------|-------------|------------------|
| GitHub Enterprise Cloud | Organization with enterprise features | Required |
| GitHub Advanced Security | For security scanning and analysis | Recommended |
| GitHub Copilot | For AI-assisted development | Recommended |
| GitHub Actions | For workflow automation | Required |
| GitHub API Access | For integration with Developer Hub | Required |

### Red Hat Requirements

| Requirement | Description | Required/Optional |
|-------------|-------------|------------------|
| Red Hat OpenShift | For Azure Red Hat OpenShift (ARO) deployment | Required for ARO option |
| Red Hat Developer Hub License | Access to Backstage-based developer portal | Required |
| Red Hat Container Registry Access | Access to container images | Required |
| Red Hat Customer Portal Access | For support and subscription management | Required |

### Network Requirements

| Requirement | Description | Required/Optional |
|-------------|-------------|------------------|
| Outbound Internet Access | For accessing container registries and services | Required |
| DNS Configuration | Ability to configure DNS for custom domains | Required |
| TLS Certificates | Wildcard or SAN certificates for secure access | Required |
| Firewall Rules | Ability to configure firewall rules for platform services | Required |

## Business Prerequisites

### Organizational Requirements

- Executive sponsorship for the platform initiative
- Dedicated implementation team with appropriate skills
- Budget approval for cloud resources and licensing
- Change management process for organizational adoption
- Developer community engagement strategy

### Skills Requirements

| Role | Responsibilities | Required Skills |
|------|-----------------|----------------|
| Platform Engineer | Infrastructure and platform setup | Azure, Kubernetes, Terraform |
| DevOps Engineer | CI/CD and automation | GitHub Actions, Scripting, Containers |
| Developer Experience Lead | User experience and adoption | Developer workflows, UX design |
| Security Engineer | Platform security | Cloud security, RBAC, Network security |
| Project Manager | Implementation coordination | Agile methodologies, Technical PM |

### Governance Requirements

- Clear ownership of the platform
- Defined RACI matrix for platform operations
- Policy framework for platform usage
- Compliance requirements documentation
- Success metrics and KPIs

## Readiness Checklist

Use this checklist to ensure you're ready to begin implementation:

- [ ] Azure subscription is set up with appropriate access
- [ ] GitHub Enterprise organization is configured
- [ ] Red Hat subscriptions and access are in place
- [ ] Network prerequisites are configured or planned
- [ ] Implementation team is assembled with required skills
- [ ] Business approvals and executive sponsorship are secured
- [ ] Success metrics and KPIs are defined
- [ ] Initial platform users/teams are identified
- [ ] Security and compliance requirements are documented

## Next Steps

Once you've confirmed that all prerequisites are met, proceed to the environment setup:

👉 [**Environment Setup**](environment-setup.md)

---

<footer>
  <p align="center">🔄 Last updated: May 2024 | <a href="../../../.github/CONTRIBUTING.md">Contribute to this documentation</a></p>
</footer> 