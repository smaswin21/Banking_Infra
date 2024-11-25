param location string = resourceGroup().location
param appServicePlanName string
param appServiceAppName string
param appServiceAPIAppName string
param appServiceAPIEnvVarENV string
param appServiceAPIEnvVarDBHOST string
param appServiceAPIEnvVarDBNAME string
@secure()
param appServiceAPIEnvVarDBPASS string
param appServiceAPIDBHostDBUSER string
param appServiceAPIDBHostFLASK_APP string
param appServiceAPIDBHostFLASK_DEBUG string
@allowed([
  'nonprod'
  'prod'
])
param environmentType string
param containerRegistryName string
param dockerRegistryImageName string
param dockerRegistryImageTag string
param appInsightsInstrumentationKey string
param appInsightsConnectionString string

param keyVaultResourceId string

@description('Name of the secret to store the admin username')
param keyVaultSecretNameAdminUsername string

@description('Name of the secret to store the admin password 0')
param keyVaultSecretNameAdminPassword0 string

@description('Name of the secret to store the admin password 1')
param keyVaultSecretNameAdminPassword1 string

param postgresSQLServerName string
param postgresSQLDatabaseName string
// added these 
param appInsightsInstrumentationKey string
param appInsightsConnectionString string
param logAnalyticsWorkspaceId string

var appServicePlanSkuName = (environmentType == 'prod') ? 'B1' : 'B1' //modify according to desired capacity




// BACKEND
module containerRegistry './infrastructure/container-registry.bicep' = {
  name: 'containerRegistry'
  params: {
    location: location
    registryName: containerRegistryName
    keyVaultResourceId: keyVaultResourceId
    keyVaultSecretNameAdminUsername: keyVaultSecretNameAdminUsername
    keyVaultSecretNameAdminPassword0: keyVaultSecretNameAdminPassword0
    keyVaultSecretNameAdminPassword1: keyVaultSecretNameAdminPassword1
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}


module appServicePlan './applications/app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    skuName: appServicePlanSkuName
  }
}


@description('Existing Key Vault resource')
resource keyVaultReference 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: last(split(keyVaultResourceId, '/'))
}


module appServiceBE './applications/backend-app-service.bicep' = {
  name: 'backend'
  params: {
    location: location
    appServiceAPIAppName: appServiceAPIAppName
    appServicePlanId: appServicePlan.outputs.id
    containerRegistryName: containerRegistryName
    dockerRegistryUserName: keyVaultReference.getSecret(keyVaultSecretNameAdminUsername)
    dockerRegistryPassword: keyVaultReference.getSecret(keyVaultSecretNameAdminPassword0)

    dockerRegistryImageName: dockerRegistryImageName
    dockerRegistryImageTag: dockerRegistryImageTag

    appSettings: [
      {
      name: 'ENV'
      value: appServiceAPIEnvVarENV
      }
      {
        name: 'DBHOST'
        value: appServiceAPIEnvVarDBHOST
      }
      {
        name: 'DBNAME'
        value: appServiceAPIEnvVarDBNAME
      }
      {
        name: 'DBPASS'
        value: appServiceAPIEnvVarDBPASS
      }
      {
        name: 'DBUSER'
        value: appServiceAPIDBHostDBUSER
      }
      {
        name: 'FLASK_APP'
        value: appServiceAPIDBHostFLASK_APP
      }
      {
        name: 'FLASK_DEBUG'
        value: appServiceAPIDBHostFLASK_DEBUG
      }
      {
        name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
        value: 'true'
      }
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: appInsightsInstrumentationKey
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: appInsightsConnectionString
      }
    ]
  }
  // dependencies are implicit
}


module applicationDatabase './database.bicep' = {
  name: 'applicationDatabase'
  params: {
    location: location
    environmentType: environmentType
    postgresSQLServerName: postgresSQLServerName
    postgresSQLDatabaseName: postgresSQLDatabaseName
    postgreSQLAdminServicePrincipalObjectId: appServiceBE.outputs.systemAssignedIdentityPrincipalId
    postgreSQLAdminServicePrincipalName: appServiceAPIAppName
  }
}


// FRONTEND

module frontendApp './applications/frontend-app-service.bicep' = {
  name: 'frontendAppService'
  params: {
    appServiceAppName: appServiceAppName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    appInsightsInstrumentationKey: appInsightsInstrumentationKey
    appInsightsConnectionString: appInsightsConnectionString
  }
}

output appServiceAppHostName string = frontendApp.outputs.appServiceAppHostName