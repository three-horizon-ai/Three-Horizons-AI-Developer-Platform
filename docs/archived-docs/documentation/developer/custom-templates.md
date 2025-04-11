# <span style="color: #0366d6;">🔹 Creating Custom Templates for Red Hat Developer Hub</span>

This guide explains how to create, customize, and publish your own software templates for the Red Hat Developer Hub, tailored to your organization's needs and standards.

## <span style="color: #0366d6;">🔍 Overview</span>

Custom templates in Red Hat Developer Hub enable platform teams to create standardized, pre-configured project scaffolds that developers can use to quickly start new projects. These templates can incorporate your organization's best practices, security standards, and integration points with your existing toolchain.

## <span style="color: #0366d6;">🔹 Prerequisites</span>

- Access to Red Hat Developer Hub
- Git repository for storing templates
- Basic understanding of YAML and your target programming languages
- Familiarity with Backstage Software Templates concepts

## <span style="color: #0366d6;">🏗️ Template Structure</span>

A basic Developer Hub template consists of:

1. **Template Metadata**: Information about the template itself
2. **Parameters**: Inputs that the developer will provide when using the template
3. **Steps**: The actions to perform during template execution
4. **Output**: The resulting resources created by the template

### <span style="color: #0366d6;">Basic Template Structure</span>

```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: basic-service
  title: Basic Microservice
  description: Create a basic microservice with standardized structure
  tags:
    - recommended
    - java
    - spring
spec:
  owner: platform-team
  type: service
  
  parameters:
    - title: Basic Information
      required:
        - name
        - owner
      properties:
        name:
          title: Name
          type: string
          description: Unique name of the component
          ui:autofocus: true
          pattern: '^[a-z0-9]([-a-z0-9]*[a-z0-9])?$'
        owner:
          title: Owner
          type: string
          description: Owner of the component
          ui:field: OwnerPicker
          ui:options:
            allowedKinds:
              - Group
    
    - title: Technical Configuration
      required:
        - language
      properties:
        language:
          title: Language
          type: string
          description: Programming language
          default: java
          enum:
            - java
            - python
            - nodejs
  
  steps:
    - id: fetch-template
      name: Fetch Base Template
      action: fetch:template
      input:
        url: ./skeleton
        values:
          name: ${{ parameters.name }}
          owner: ${{ parameters.owner }}
          language: ${{ parameters.language }}
    
    - id: publish
      name: Publish to GitHub
      action: publish:github
      input:
        repoUrl: github.com?owner=my-org&repo=${{ parameters.name }}
        defaultBranch: main
        protectDefaultBranch: true
        access: 'organization'
    
    - id: register
      name: Register in Catalog
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps.publish.output.repoContentsUrl }}
        catalogInfoPath: '/catalog-info.yaml'
  
  output:
    links:
      - title: Repository
        url: ${{ steps.publish.output.remoteUrl }}
      - title: Open in catalog
        icon: catalog
        entityRef: ${{ steps.register.output.entityRef }}
```

## <span style="color: #0366d6;">🔄 Template Creation Process</span>

### <span style="color: #0366d6;">1. Create a Skeleton Project</span>

First, create a skeleton project that will serve as the base for your template:

1. Create a directory structure for your project
2. Add template files with variables (using Handlebars syntax `{{ variable }}`)
3. Include essential files such as:
   - `catalog-info.yaml`: For registering with the Developer Hub catalog
   - `README.md`: Documentation for developers
   - Build configuration files (e.g., `pom.xml`, `package.json`)
   - Deployment configuration (Kubernetes manifests, Helm charts)
   - CI/CD pipeline configuration (GitHub Actions, etc.)

### <span style="color: #0366d6;">2. Create the Template Definition</span>

Create a template YAML file that defines:

1. Metadata about your template
2. Parameters to collect from users
3. Steps to execute when the template is selected
4. Output links to direct users after template creation

### <span style="color: #0366d6;">3. Test Your Template Locally</span>

Test your template using the Backstage CLI:

```bash
# <span style="color: #0366d6;">🚀 Install the Backstage CLI if you haven't already</span>
npm install -g @backstage/cli

# <span style="color: #0366d6;">🔹 Create a test project from your template</span>
backstage-cli create --template-path /path/to/your/template --destination /tmp/test-output
```

### <span style="color: #0366d6;">4. Publish Your Template</span>

Add your template to your organization's template registry:

1. Create a Git repository for your templates
2. Add your template files to the repository
3. Register the template location in Developer Hub:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: org-templates
  description: Organization templates
spec:
  type: url
  targets:
    - https://github.com/your-org/templates/blob/main/all-templates.yaml
```

## <span style="color: #0366d6;">✨ Advanced Template Features</span>

### <span style="color: #0366d6;">Custom Actions</span>

You can create custom actions for your templates:

```typescript
// In your Developer Hub plugins directory
export const createCustomAction = () => createTemplateAction({
  id: 'custom:action',
  schema: {
    input: {
      required: ['parameter1'],
      properties: {
        parameter1: {
          type: 'string',
          title: 'Parameter 1',
          description: 'First parameter for the action',
        },
      },
    },
  },
  async handler(ctx) {
    const { parameter1 } = ctx.input;
    // Perform custom logic here
    ctx.output('result', 'Success!');
  },
});
```

### <span style="color: #0366d6;">Conditional Template Logic</span>

Use Handlebars conditionals for template logic:

```yaml
{{#if (eq parameters.language 'java')}}
# <span style="color: #0366d6;">🔹 Java-specific configuration</span>
{{else if (eq parameters.language 'python')}}
# <span style="color: #0366d6;">🔹 Python-specific configuration</span>
{{else}}
# <span style="color: #0366d6;">🔹 Default configuration</span>
{{/if}}
```

### <span style="color: #0366d6;">Integration with External Systems</span>

Templates can integrate with external systems using API calls:

```yaml
steps:
  - id: create-jira-project
    name: Create Jira Project
    action: http:request
    input:
      url: https://jira.example.com/api/projects
      method: POST
      headers:
        Authorization: Bearer ${{ secrets.JIRA_TOKEN }}
        Content-Type: application/json
      body:
        key: ${{ parameters.name | uppercase }}
        name: ${{ parameters.displayName }}
        projectTypeKey: SOFTWARE
```

## <span style="color: #0366d6;">🔹 Template Categories</span>

Consider creating templates for different types of components:

### <span style="color: #0366d6;">Backend Service Templates</span>

- Microservice templates (Spring Boot, Quarkus, FastAPI, etc.)
- API gateway templates
- Database service templates

### <span style="color: #0366d6;">Frontend Application Templates</span>

- Web application templates (React, Angular, Vue)
- Mobile application templates
- Desktop application templates

### <span style="color: #0366d6;">Infrastructure Templates</span>

- Kubernetes resource templates
- Monitoring and observability templates
- Security scanning templates

## <span style="color: #0366d6;">🔹 Best Practices</span>

- **Start Simple**: Begin with basic templates and add complexity gradually
- **Use Variables Consistently**: Establish naming conventions for template variables
- **Document Everything**: Include comprehensive README files in your templates
- **Include Validation**: Add validation rules for template parameters
- **Use Template Composition**: Break down complex templates into reusable pieces
- **Test Templates Thoroughly**: Verify templates work in all target environments
- **Maintain Version Compatibility**: Ensure templates work with your Developer Hub version
- **Collect Feedback**: Regularly gather input from developers using your templates

## <span style="color: #0366d6;">🔧 Troubleshooting</span>

Common template issues and solutions:

- **Template Not Appearing**: Verify the template location is properly registered
- **Variable Rendering Issues**: Check for correct Handlebars syntax `{{ variable }}`
- **Action Failures**: Review action logs and ensure required inputs are provided
- **Git Integration Problems**: Verify credentials and permissions

## <span style="color: #0366d6;">📚 Additional Resources</span>

- [Backstage Software Templates Documentation](https://backstage.io/docs/features/software-templates/)
- [Red Hat Developer Hub Template Guide](https://developers.redhat.com/developer-hub/templates)
- [Handlebars Template Language](https://handlebarsjs.com/guide/)

---

<footer>
  <p align="center">🔄 Last updated: April 2025 | Contribute to this document through <a href="../../.github/CONTRIBUTING.md">Pull Requests</a></p>
</footer>
