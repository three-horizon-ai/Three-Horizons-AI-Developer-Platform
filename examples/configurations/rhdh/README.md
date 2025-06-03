# Red Hat Developer Hub Configuration Examples

This directory contains example configuration files for setting up Red Hat Developer Hub (RHDH) with various authentication and deployment options.

## Configuration Files

### Authentication
- **auth-config.yaml** - Basic authentication configuration for RHDH
- **github-auth-direct.yaml** - GitHub authentication setup with direct integration

### Deployment
- **backstage-instance.yaml** - Basic Backstage instance configuration
- **backstage-with-config.yaml** - Backstage instance with integrated configuration
- **developer-hub-route.yaml** - OpenShift route configuration for Developer Hub
- **operator-group.yaml** - Operator Group configuration for RHDH deployment
- **rhdh-subscription.yaml** - Subscription configuration for RHDH operator

## Usage

These files are meant to be used as examples and templates. Copy and modify them according to your specific requirements:

```bash
# Example: Deploy RHDH operator
oc apply -f operator-group.yaml
oc apply -f rhdh-subscription.yaml

# Example: Configure authentication
oc apply -f github-auth-direct.yaml
```

## Related Documentation

- [Complete Integration Tutorial](../../../docs/complete-integration-tutorial/index.md)
- [Developer Hub Deployment Guide](../../../docs/documentation/guides/developer-hub-deployment.md) 