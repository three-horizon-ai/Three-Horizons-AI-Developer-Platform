# ${{values.name}} Kubernetes Configuration

${{values.description}}

This repository contains Kubernetes manifests for deploying and managing the ${{values.name}} service in the Three Horizons platform.

## Components

This deployment includes:

- **Deployment**: Defines the ${{values.name}} application with ${{values.replicas}} replicas
- **Service**: ClusterIP service exposing port 80
{{#if values.ingress}}
- **Ingress**: Exposes the service at https://${{values.ingressHost}}
{{/if}}
{{#if values.networkPolicy}}
- **Network Policy**: Restricts traffic to/from the application
{{/if}}

## Resource Configuration

The service is configured with the following resource requirements:

| Resource | Requests | Limits |
|----------|----------|--------|
| CPU | ${{values.resources.requestsCpu}} | ${{values.resources.limitsCpu}} |
| Memory | ${{values.resources.requestsMemory}} | ${{values.resources.limitsMemory}} |

## Deployment

### Prerequisites

- Kubernetes cluster with RBAC enabled
- Namespace "${{values.namespace}}" created
- Required secrets:
  - Image pull secrets (if using private registry)
  - TLS secrets (if using HTTPS)

### Deployment Instructions

Deploy using kubectl:

```bash
# Apply all manifests
kubectl apply -f kubernetes/

# Verify deployment
kubectl get all -n ${{values.namespace}} -l app=${{values.name}}
```

### Deployment with ArgoCD/Flux

This repository is designed to be used with GitOps tools. Configure your CD tool to sync this repository with your cluster.

## Monitoring

The service exposes the following endpoints for monitoring:

- **Readiness probe**: HTTP GET /health
- **Liveness probe**: HTTP GET /health
- **Metrics**: HTTP GET /metrics (Prometheus format)

## Additional Documentation

For more information:

- [Three Horizons Platform Overview](https://github.com/ThreeHorizonsOrg/documentation)
- [Kubernetes Best Practices](https://github.com/ThreeHorizonsOrg/kubernetes-guidelines)
- [Service Dependencies](https://github.com/ThreeHorizonsOrg/service-catalog) 