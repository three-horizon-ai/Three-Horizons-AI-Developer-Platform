# <span style="color: #0366d6;">🔧 Red Hat Developer Hub Troubleshooting Guide</span>

This guide provides solutions to common issues you might encounter when implementing and operating the Red Hat Developer Hub in the Three Horizons Platform.

## <span style="color: #0366d6;">🚀 Installation Issues</span>

### <span style="color: #0366d6;">Installation Fails on Kubernetes</span>

#### Symptoms
- Deployment pods fail to start
- Installation manifests show errors
- Timeouts during Helm chart installation

#### Solutions
1. **Resource Constraints**
   - Verify your cluster has enough resources (CPU/memory)
   - Check if resource quotas are preventing pod creation
   - Increase resource requests/limits if necessary

2. **Permission Issues**
   - Ensure the service account has appropriate RBAC permissions
   - Verify namespace permissions for resource creation
   - Check for missing role bindings

3. **Network Issues**
   - Verify network policies allow required communication
   - Check if outbound internet access is available (if needed)
   - Ensure DNS resolution is working properly

### <span style="color: #0366d6;">PostgreSQL Database Connection Issues</span>

#### Symptoms
- Developer Hub backend fails to connect to PostgreSQL
- Database connection errors in logs
- Intermittent connectivity issues

#### Solutions
1. **Connection Configuration**
   - Verify database connection string in configuration
   - Check PostgreSQL service and endpoint are correctly defined
   - Ensure database credentials are correct

2. **Database Availability**
   - Check if PostgreSQL pods are running
   - Verify persistent volume claims are bound
   - Monitor PostgreSQL logs for errors

3. **Network Policies**
   - Ensure network policies allow traffic between Developer Hub and PostgreSQL
   - Check if PostgreSQL service is correctly defined

## <span style="color: #0366d6;">🔧 Catalog Issues</span>

### <span style="color: #0366d6;">Software Catalog Shows No Components</span>

#### Symptoms
- Empty catalog despite importing repositories
- Components not appearing after import
- Errors during catalog import

#### Solutions
1. **Catalog Configuration**
   - Check the catalog import configuration
   - Verify catalog-info.yaml files exist in repositories
   - Ensure catalog import jobs have appropriate permissions

2. **GitHub Integration Issues**
   - Verify GitHub token permissions include repo access
   - Check GitHub API rate limits
   - Ensure GitHub integration is properly configured

3. **Processing Errors**
   - Check processor logs for errors
   - Verify catalog-info.yaml file syntax
   - Increase log verbosity to debug processing issues

### <span style="color: #0366d6;">Catalog Entity Relationships Not Showing</span>

#### Symptoms
- Missing relationships between components
- Ownership or dependency links not visible
- Incomplete system diagrams

#### Solutions
1. **Entity Definitions**
   - Check for properly defined relations in catalog-info.yaml files
   - Verify both sides of relationships are defined correctly
   - Ensure relation targets exist in the catalog

2. **Processing Issues**
   - Check catalog processor logs for relationship errors
   - Verify relationship syntax follows Backstage specification
   - Refresh catalog to force relationship reprocessing

## <span style="color: #0366d6;">🔧 Template Issues</span>

### <span style="color: #0366d6;">Templates Not Showing in Catalog</span>

#### Symptoms
- Templates missing from template list
- Template entities visible in catalog but not as templates
- Template discovery fails

#### Solutions
1. **Template Definition**
   - Verify template has correct apiVersion and kind
   - Ensure template is registered with proper annotations
   - Check template entity exists in the catalog

2. **Permission Issues**
   - Verify permissions for accessing template sources
   - Check if template source repositories are accessible
   - Ensure template discovery has appropriate token permissions

3. **Configuration Issues**
   - Verify scaffolder configuration includes template locations
   - Check for template discovery configuration errors
   - Validate template catalog-info.yaml format

### <span style="color: #0366d6;">Template Execution Failures</span>

#### Symptoms
- Template starts but fails to complete
- Errors during template execution
   - GitHub repository creation fails
   - Failed to fetch template content

#### Solutions
1. **GitHub Issues**
   - Check GitHub token permissions
   - Verify GitHub organization access
   - Ensure GitHub rate limits aren't exceeded

2. **Action Issues**
   - Identify which action is failing
   - Check action parameters and configuration
   - Verify external services required by actions are available

3. **Parameter Issues**
   - Verify all required parameters are provided
   - Check parameter validation rules
   - Ensure parameter formats match expected inputs

## <span style="color: #0366d6;">🔧 Plugin Issues</span>

### <span style="color: #0366d6;">Plugins Not Loading</span>

#### Symptoms
- Plugin features missing from UI
- Console errors related to plugin loading
- Blank pages where plugin content should appear

#### Solutions
1. **Plugin Registration**
   - Verify plugin is registered in app-config.yaml
   - Check plugin package is installed correctly
   - Ensure plugin ID is correctly specified

2. **Compatibility Issues**
   - Verify plugin is compatible with your Developer Hub version
   - Check for plugin dependency conflicts
   - Update plugin to a compatible version

3. **Frontend Issues**
   - Check browser console for JavaScript errors
   - Verify frontend builds include plugin
   - Clear browser cache to load updated plugin code

### <span style="color: #0366d6;">Custom Plugin Development Issues</span>

#### Symptoms
- Custom plugin fails to build
- Plugin loads but doesn't function correctly
- TypeScript/compilation errors

#### Solutions
1. **Development Environment**
   - Verify development dependencies are installed
   - Check for version compatibility with core packages
   - Ensure plugin follows recommended project structure

2. **API Usage Issues**
   - Verify correct usage of Developer Hub/Backstage APIs
   - Check for API changes between versions
   - Follow plugin development best practices

## <span style="color: #0366d6;">🔧 Authentication Issues</span>

### <span style="color: #0366d6;">SSO Integration Problems</span>

#### Symptoms
- Unable to login with SSO
- Redirect loops during authentication
- Authentication successful but authorization fails

#### Solutions
1. **OAuth Configuration**
   - Verify client ID and secret are correctly configured
   - Check redirect URIs are properly registered
   - Ensure scopes include necessary permissions

2. **Identity Mapping**
   - Verify identity mapping between SSO provider and Developer Hub
   - Check user attribute mapping configuration
   - Ensure group membership information is properly propagated

3. **Session Management**
   - Check session cookie configuration
   - Verify session storage is properly configured
   - Ensure session timeouts are appropriately set

## <span style="color: #0366d6;">🔧 Performance Issues</span>

### <span style="color: #0366d6;">Slow UI Response</span>

#### Symptoms
- Pages take long time to load
- UI feels sluggish during interaction
- Timeouts when accessing certain features

#### Solutions
1. **Resource Allocation**
   - Increase CPU/memory for frontend pods
   - Check for resource contention on nodes
   - Monitor resource utilization during peak usage

2. **Backend Performance**
   - Check database query performance
   - Monitor API response times
   - Optimize backend resource allocation

3. **Caching Issues**
   - Verify cache configuration
   - Check if caching is working properly
   - Increase cache size for frequently accessed data

### <span style="color: #0366d6;">Slow Catalog Processing</span>

#### Symptoms
- Catalog takes long time to refresh
- High CPU usage during catalog processing
- Timeouts during large catalog imports

#### Solutions
1. **Processing Configuration**
   - Adjust processing intervals
   - Optimize number of concurrent processors
   - Configure processing timeouts appropriately

2. **Database Performance**
   - Check database indexes
   - Monitor query performance
   - Increase database resources if needed

## <span style="color: #0366d6;">🔹 Getting Help</span>

If you continue to experience issues after following this troubleshooting guide:

1. Check the [Red Hat Developer Hub documentation](https://developers.redhat.com/rhdh)
2. Review the [Developer Hub configuration guide](configuration.md)
3. Consult the [Three Horizons GitHub Discussions](https://github.com/your-org/three-horizons-playbook/discussions) for community assistance

---

<footer>
  <p align="center">🔄 Last updated: April 2025 | Contribute to this document through <a href="../../.github/CONTRIBUTING.md">Pull Requests</a></p>
</footer>
