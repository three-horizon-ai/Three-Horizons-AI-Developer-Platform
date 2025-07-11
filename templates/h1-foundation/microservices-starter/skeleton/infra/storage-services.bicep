// Three Horizons AI Platform - Storage Services Configuration
// This template configures blob services with retention policies and security features

targetScope = 'resourceGroup'

// ================================================================================================
// METADATA
// ================================================================================================

metadata name = 'Three Horizons AI Platform - Storage Services'
metadata description = 'Configures blob services with retention policies and security features'
metadata version = '1.0.0'
metadata author = 'Three Horizons Platform Team'

// ================================================================================================
// PARAMETERS
// ================================================================================================

@description('Storage Account name')
param storageAccountName string

@description('Environment name (dev, staging, prod)')
@allowed(['dev', 'staging', 'prod'])
param environment string = 'dev'

@description('Enable blob versioning')
param enableVersioning bool = false

@description('Enable blob change feed')
param enableChangeFeed bool = false

@description('Delete retention policy days')
param deleteRetentionDays int = 7

@description('Container delete retention policy days')
param containerDeleteRetentionDays int = 7

@description('Point-in-time restore days (Premium tier only)')
param restorePolicyDays int = 0

// ================================================================================================
// EXISTING RESOURCES
// ================================================================================================

// Reference to existing storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// ================================================================================================
// BLOB SERVICES CONFIGURATION
// ================================================================================================

// Blob Service with advanced features
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    // CORS configuration for web applications
    cors: {
      corsRules: [
        {
          allowedOrigins: ['https://*.azure.com', 'https://*.microsoft.com']
          allowedMethods: ['GET', 'HEAD', 'POST', 'PUT']
          allowedHeaders: ['*']
          exposedHeaders: ['*']
          maxAgeInSeconds: 3600
        }
      ]
    }
    
    // Delete retention policy
    deleteRetentionPolicy: {
      enabled: true
      days: deleteRetentionDays
    }
    
    // Container delete retention policy
    containerDeleteRetentionPolicy: {
      enabled: true
      days: containerDeleteRetentionDays
    }
    
    // Versioning configuration
    isVersioningEnabled: enableVersioning
    
    // Change feed configuration
    changeFeed: {
      enabled: enableChangeFeed
      retentionInDays: enableChangeFeed ? 7 : null
    }
    
    // Point-in-time restore (requires Premium tier)
    restorePolicy: restorePolicyDays > 0 ? {
      enabled: true
      days: restorePolicyDays
    } : null
    
    // Default service version
    defaultServiceVersion: '2023-01-03'
    
    // Last access time tracking (for lifecycle management)
    lastAccessTimeTrackingPolicy: {
      enable: true
      name: 'AccessTimeTracking'
      trackingGranularityInDays: 1
      blobType: ['blockBlob']
    }
  }
}

// ================================================================================================
// BLOB CONTAINERS
// ================================================================================================

// Application data container
resource appDataContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobServices
  name: 'app-data'
  properties: {
    publicAccess: 'None'
    metadata: {
      purpose: 'Application data storage'
      environment: environment
    }
  }
}

// Configuration container
resource configContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobServices
  name: 'configuration'
  properties: {
    publicAccess: 'None'
    metadata: {
      purpose: 'Application configuration files'
      environment: environment
    }
  }
}

// Backup container
resource backupContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobServices
  name: 'backups'
  properties: {
    publicAccess: 'None'
    metadata: {
      purpose: 'Data backups and archives'
      environment: environment
    }
  }
}

// Logs container
resource logsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobServices
  name: 'logs'
  properties: {
    publicAccess: 'None'
    metadata: {
      purpose: 'Application and audit logs'
      environment: environment
    }
  }
}

// ================================================================================================
// LIFECYCLE MANAGEMENT POLICY
// ================================================================================================

// Lifecycle management policy to optimize costs
resource lifecyclePolicy 'Microsoft.Storage/storageAccounts/managementPolicies@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    policy: {
      rules: [
        {
          enabled: true
          name: 'MoveOldLogsToArchive'
          type: 'Lifecycle'
          definition: {
            filters: {
              blobTypes: ['blockBlob']
              prefixMatch: ['logs/']
            }
            actions: {
              baseBlob: {
                tierToCool: {
                  daysAfterModificationGreaterThan: 30
                }
                tierToArchive: {
                  daysAfterModificationGreaterThan: 90
                }
                delete: {
                  daysAfterModificationGreaterThan: environment == 'prod' ? 2555 : 365 // 7 years for prod, 1 year for dev/staging
                }
              }
              version: enableVersioning ? {
                tierToCool: {
                  daysAfterCreationGreaterThan: 30
                }
                tierToArchive: {
                  daysAfterCreationGreaterThan: 90
                }
                delete: {
                  daysAfterCreationGreaterThan: 365
                }
              } : null
            }
          }
        }
        {
          enabled: true
          name: 'MoveOldBackupsToArchive'
          type: 'Lifecycle'
          definition: {
            filters: {
              blobTypes: ['blockBlob']
              prefixMatch: ['backups/']
            }
            actions: {
              baseBlob: {
                tierToCool: {
                  daysAfterModificationGreaterThan: 7
                }
                tierToArchive: {
                  daysAfterModificationGreaterThan: 30
                }
                delete: {
                  daysAfterModificationGreaterThan: environment == 'prod' ? 2555 : 730 // 7 years for prod, 2 years for dev/staging
                }
              }
            }
          }
        }
        {
          enabled: true
          name: 'OptimizeAppDataStorage'
          type: 'Lifecycle'
          definition: {
            filters: {
              blobTypes: ['blockBlob']
              prefixMatch: ['app-data/']
            }
            actions: {
              baseBlob: {
                tierToCool: {
                  daysAfterLastAccessTimeGreaterThan: 30
                }
                tierToArchive: {
                  daysAfterLastAccessTimeGreaterThan: 90
                }
              }
            }
          }
        }
      ]
    }
  }
}

// ================================================================================================
// OUTPUTS
// ================================================================================================

@description('Storage Account name')
output storageAccountName string = storageAccount.name

@description('Blob service endpoint')
output blobServiceEndpoint string = storageAccount.properties.primaryEndpoints.blob

@description('App data container name')
output appDataContainerName string = appDataContainer.name

@description('Configuration container name')
output configContainerName string = configContainer.name

@description('Backup container name')
output backupContainerName string = backupContainer.name

@description('Logs container name')
output logsContainerName string = logsContainer.name

@description('Blob service properties')
output blobServiceProperties object = {
  versioningEnabled: enableVersioning
  changeFeedEnabled: enableChangeFeed
  deleteRetentionDays: deleteRetentionDays
  containerDeleteRetentionDays: containerDeleteRetentionDays
  restorePolicyEnabled: restorePolicyDays > 0
}
