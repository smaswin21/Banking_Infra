// Define deployment location
@description('Deployment location for the resource group')
param location string = resourceGroup().location

// Define App Service API application name
@description('The name of the App Service API application')
param appServiceAPIAppName string

// Define App Service Plan ID
@description('The ID of the App Service Plan to use for hosting the application')
param appServicePlanId string

// Define Container Registry parameters
@description('The name of the container registry')
param containerRegistryName string

@description('The username for Docker Registry authentication')
@secure()
param dockerRegistryUserName string

@description('The password for Docker Registry authentication')
@secure()
param dockerRegistryPassword string

@description('The name of the Docker image to be used')
param dockerRegistryImageName string

@description('The tag of the Docker image to be used, default is latest')
param dockerRegistryImageTag string = 'latest'

// Define application settings
@description('Array of application settings as key-value pairs')
param appSettings array = []

@description('The command line to run when starting the app')
param appCommandLine string = ''

// Define Application Insights parameters
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

output appServiceAppHostName string = appServiceAPIApp.properties.defaultHostName
output systemAssignedIdentityPrincipalId string = appServiceAPIApp.identity.principalId
