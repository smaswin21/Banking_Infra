param location string = resourceGroup().location

// Define environment type
@description('The environment type (nonprod or prod)')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string

// Define App Service API application name
@description('The name of the App Service API application')
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
      alwaysOn: environmentType == 'prod' ? true : false
      ftpsState: 'FtpsOnly'
      appCommandLine: appCommandLine
      appSettings: mergedAppSettings
    }
  }
}

output appServiceAppHostName string = appServiceAPIApp.properties.defaultHostName
output systemAssignedIdentityPrincipalId string = appServiceAPIApp.identity.principalId
