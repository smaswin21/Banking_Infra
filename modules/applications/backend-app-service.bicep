param location string = resourceGroup().location
param appServiceAPIAppName string
param appServicePlanId string
param containerRegistryName string
@secure()
param dockerRegistryUserName string
@secure()
param dockerRegistryPassword string
param dockerRegistryImageName string
param dockerRegistryImageTag string = 'latest'
param appSettings array = []
param appCommandLine string = ''
param keyVaultResourceId string

@description('Application Insights Instrumentation Key for monitoring')
param appInsightsInstrumentationKey string

@description('Application Insights Connection String for monitoring')
param appInsightsConnectionString string

var dockerAppSettings = [
  { name: 'DOCKER_REGISTRY_SERVER_URL', value: 'https://${containerRegistryName}.azurecr.io' }
  { name: 'DOCKER_REGISTRY_SERVER_USERNAME', value: dockerRegistryUserName }
  { name: 'DOCKER_REGISTRY_SERVER_PASSWORD', value: dockerRegistryPassword }
]

var appInsightsSettings = [
  { name: 'APPINSIGHTS_INSTRUMENTATIONKEY', value: appInsightsInstrumentationKey }
  { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', value: appInsightsConnectionString }
  { name: 'ApplicationInsightsAgent_EXTENSION_VERSION', value: '~3' }
  { name: 'XDT_MicrosoftApplicationInsights_NodeJS', value: '1' }
]


var mergedAppSettings = concat(appSettings, dockerAppSettings, appInsightsSettings)


resource appServiceAPIApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAPIAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${dockerRegistryImageName}:${dockerRegistryImageTag}'
      alwaysOn: false
      ftpsState: 'FtpsOnly'
      appCommandLine: appCommandLine
      appSettings: mergedAppSettings
    }
  }
}

resource appServiceAPIAppSettings 'Microsoft.Web/sites/config@2022-03-01' = {
// append DBUSER: appServiceAPIApp.identity.principalId to all the other app settings
  name: '${appServiceAPIAppName}/appsettings'
  properties: union(mergedAppSettings, [
    { name: 'DBUSER', value: appServiceAPIApp.identity.principalId }
  ])
  dependsOn: [
    appServiceAPIApp
  ]
}

@description('Existing Key Vault resource')
resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: last(split(keyVaultResourceId, '/'))
}

// add the managed identity of the app service to the key vault as a secret
resource appServiceKeyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: 'backend-api-app-service-identity'
  parent: adminCredentialsKeyVault
  properties: {
    value: appServiceAPIApp.identity.principalId
  }
}

output appServiceAppHostName string = appServiceAPIApp.properties.defaultHostName
output systemAssignedIdentityPrincipalId string = appServiceAPIApp.identity.principalId
