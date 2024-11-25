param location string = resourceGroup().location
param environmentType string = 'nonprod'
param postgresSQLServerName string = 'ie-bank-db-server-dev'
param postgreSQLAdminServicePrincipalObjectId string
param postgreSQLAdminServicePrincipalName string

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




output postgresSQLServerName string = postgresSQLServer.name
output resourceOutput object = postgresSQLServer
