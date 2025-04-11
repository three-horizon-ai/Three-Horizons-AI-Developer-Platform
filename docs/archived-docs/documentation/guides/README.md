---
title: Three Horizons Deployment Guides
description: Comprehensive documentation for deploying and implementing the Three Horizons platform
position_in_journey: 15
previous_doc: /docs/getting-started/README.md
next_doc: /docs/documentation/guides/inner-loop-development.md
last_updated: 2025-04-10
---

# Three Horizons Deployment Documentation

Welcome to your deployment journey with the Three Horizons platform. This section guides you through implementation patterns that accelerate your platform adoption across all three horizons of innovation.

## Your Deployment Journey

As you progress through the Three Horizons model, your deployment capabilities will evolve. This journey follows GitOps principles to provide:

- **Horizon 1**: Establish declarative infrastructure and application deployment foundations
- **Horizon 2**: Enhance with version-controlled configurations and automated reconciliation
- **Horizon 3**: Achieve self-healing capabilities with sophisticated audit trails and observability

## Your Implementation Path

Follow these key guides on your Three Horizons implementation journey:

1. **Start with Platform Foundations**: 
   - [Azure Red Hat OpenShift (ARO) deployment](../implementation/aro-deployment.md)
   - [Azure Kubernetes Service (AKS) deployment](../implementation/aks-deployment.md)

2. **Establish Developer Experience**:
   - [Red Hat Developer Hub deployment](../implementation/developer-hub-deployment.md)
   - [GitHub integration setup](../implementation/github-integration.md)
   
3. **Implement Delivery Workflows**:
   - [Inner-loop development](inner-loop-development.md)
   - [Outer-loop deployment](outer-loop-deployment.md)

## Technologies in Your Deployment Journey

Your Three Horizons implementation leverages these powerful technologies:

**Horizon 1: Foundation**
- **Azure Bicep/ARM Templates**: Create consistent, repeatable infrastructure 
- **OpenShift GitOps (ArgoCD)**: Establish declarative application deployment

**Horizon 2: Optimization**
- **GitHub Actions**: Build automated CI/CD workflows
- **Helm Charts**: Package applications for consistent deployment

**Horizon 3: Innovation**
- **Policy as Code**: Implement governance at scale
- **Progressive Delivery**: Enable feature flags and canary deployments

Continue your journey with [Inner-loop Development](inner-loop-development.md) to understand the developer experience.