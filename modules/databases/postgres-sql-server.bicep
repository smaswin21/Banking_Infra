// Define deployment location parameter
@description('Deployment location for the resource group')
param location string = resourceGroup().location

// Define environment type
@description('Environment type for deployment (e.g., nonprod, prod)')
param environmentType string = 'nonprod'

// Define PostgreSQL server name
@description('The name of the PostgreSQL server')
param postgresSQLServerName string = 'ie-bank-db-server-dev'

// Define PostgreSQL Admin Service Principal Object ID
@description('The object ID of the service principal for PostgreSQL admin access')
param postgreSQLAdminServicePrincipalObjectId string

// Define PostgreSQL Admin Service Principal Name
@description('The name of the service principal for PostgreSQL admin access')
param postgreSQLAdminServicePrincipalName string

// Define Log Analytics Workspace ID
@description('The ID of the Log Analytics Workspace for monitoring')
param logAnalyticsWorkspaceId string

// based on prod non prod change the sku
var skuName = environmentType == 'prod' ? 'Standard_B1ms' : 'Standard_B1ms'

resource postgresSQLServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: postgresSQLServerName
  location: location
  sku: {
    name: skuName
    tier: 'Burstable'
  }
  properties: {
    administratorLogin: 'iebankdbadmin'
    administratorLoginPassword: 'IE.Bank.DB.Admin.Pa$$'
    createMode: 'Default'
    highAvailability: {
      mode: 'Disabled'
      standbyAvailabilityZone: ''
    }
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    version: '15'
    authConfig: { activeDirectoryAuth: 'Enabled', passwordAuth: 'Enabled', tenantId: subscription().tenantId }

  }

  resource postgresSQLServerFirewallRules 'firewallRules@2022-12-01' = {
    name: 'AllowAllAzureServicesAndResourcesWithinAzureIps'
    properties: {
      endIpAddress: '0.0.0.0'
      startIpAddress: '0.0.0.0'
    }
  }

  resource postgreSQLAdministrators 'administrators@2022-12-01' = {
    name: postgreSQLAdminServicePrincipalObjectId
    properties: {
      principalName: postgreSQLAdminServicePrincipalName
      principalType: 'ServicePrincipal'
      tenantId: subscription().tenantId
    }
    dependsOn: [
      postgresSQLServerFirewallRules
    ]
  }

}


resource postgreSQLDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'PostgreSQLServerDiagnostic'
  scope: postgresSQLServer
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    logs: [
      {
        category: 'PostgreSQLLogs'
        enabled: true
      }
      {
        category: 'PostgreSQLFlexSessions'
        enabled: true
      }
      {
        category: 'PostgreSQLFlexQueryStoreRuntime'
        enabled: true
      }
      {
        category: 'PostgreSQLFlexQueryStoreWaitStats'
        enabled: true
      }
      {
        category: 'PostgreSQLFlexTableStats'
        enabled: true
      }
      {
        category: 'PostgreSQLFlexDatabaseXacts'
        enabled: true
      }
    ]
  }
}




output postgresSQLServerName string = postgresSQLServer.name
output resourceOutput object = postgresSQLServer
