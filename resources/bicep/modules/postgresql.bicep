@description('The name of the PostgreSQL server')
param serverName string

@description('Location for all resources')
param location string

@description('Tags to apply to resources')
param tags object = {}

@description('Administrator username')
param administratorLogin string = 'backstage'

@description('Administrator password')
@secure()
param administratorPassword string

@description('PostgreSQL version')
@allowed(['11', '12', '13', '14', '15', '16'])
param version string = '14'

@description('SKU name')
param skuName string = 'Standard_D2s_v3'

@description('Storage size in GB')
@minValue(32)
@maxValue(16384)
param storageSizeGB int = 32

@description('Enable high availability')
param enableHA bool = true

@description('Database name')
param databaseName string = 'backstage'

@description('Backup retention days')
@minValue(7)
@maxValue(35)
param backupRetentionDays int = 7

// PostgreSQL Flexible Server
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: serverName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: 'GeneralPurpose'
  }
  properties: {
    version: version
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorPassword
    storage: {
      storageSizeGB: storageSizeGB
    }
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: 'Enabled'
    }
    highAvailability: {
      mode: enableHA ? 'ZoneRedundant' : 'Disabled'
    }
    availabilityZone: '1'
  }
}

// Database
resource database 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
  parent: postgresServer
  name: databaseName
  properties: {
    charset: 'UTF8'
    collation: 'en_US.utf8'
  }
}

// Firewall rule to allow Azure services
resource firewallRuleAzure 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2022-12-01' = {
  parent: postgresServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Outputs
output serverId string = postgresServer.id
output serverName string = postgresServer.name
output serverFqdn string = postgresServer.properties.fullyQualifiedDomainName
output databaseName string = database.name
output connectionString string = 'host=${postgresServer.properties.fullyQualifiedDomainName} port=5432 dbname=${databaseName} user=${administratorLogin}@${serverName} sslmode=require' 
