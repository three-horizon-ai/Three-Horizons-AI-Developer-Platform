@description('The name of the Managed Identity')
param identityName string

@description('Location for all resources')
param location string

@description('Tags to apply to resources')
param tags object = {}

@description('AKS OIDC Issuer URL for federated credentials')
param aksOidcIssuerUrl string = ''

@description('Kubernetes service account namespace')
param serviceAccountNamespace string = 'default'

@description('Kubernetes service account name')
param serviceAccountName string = 'workload-identity-sa'

// User Assigned Managed Identity
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
  tags: tags
}

// Federated Identity Credential for AKS Workload Identity
resource federatedIdentityCredential 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = if (!empty(aksOidcIssuerUrl)) {
  parent: managedIdentity
  name: '${identityName}-federated-credential'
  properties: {
    audiences: [
      'api://AzureADTokenExchange'
    ]
    issuer: aksOidcIssuerUrl
    subject: 'system:serviceaccount:${serviceAccountNamespace}:${serviceAccountName}'
  }
}

// Outputs
output identityId string = managedIdentity.id
output identityName string = managedIdentity.name
output identityPrincipalId string = managedIdentity.properties.principalId
output identityClientId string = managedIdentity.properties.clientId 
