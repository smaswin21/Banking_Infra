@description('The name of the App Service application')
param appServiceAppName string

@description('The location where the App Service will be deployed')
param location string

@description('The ID of the App Service Plan this App Service will use')
param appServicePlanId string

@description('Application Insights Instrumentation Key for monitoring')
param appInsightsInstrumentationKey string

@description('Application Insights Connection String for monitoring')
param appInsightsConnectionString string

@description('The command line to run for the App Service')
param appCommandLine string = 'pm2 serve /home/site/wwwroot --spa --no-daemon'

@description('Name of the static web app')
param name string

@allowed([
  'Free'
  'Standard'
])
@description('The service tier')
param sku string


resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'NODE|18-lts'
      alwaysOn: false
      ftpsState: 'FtpsOnly'
      appCommandLine: appCommandLine
      appSettings: [
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
  }
}


// https://learn.microsoft.com/en-us/azure/templates/microsoft.web/staticsites?pivots=deployment-language-bicep
resource swa 'Microsoft.Web/staticSites@2024-04-01' = {
  //identity: {
  //  type: 'string'
  //  userAssignedIdentities: {
  //    {customized property}: {}
  //  }
  //}
  location: location
  name: name
  properties: {
    allowConfigFileUpdates: false
    //branch: 'string'
    //buildProperties: {
    //  apiBuildCommand: 'string'
    //  apiLocation: 'string'
    //  appArtifactLocation: 'string'
    //  appBuildCommand: 'string'
    //  appLocation: 'string'
    //  githubActionSecretNameOverride: 'string'
    //  outputLocation: 'string'
    //  skipGithubActionWorkflowGeneration: bool
    //}
    //enterpriseGradeCdnStatus: 'string'
    //provider: 'string'
    //publicNetworkAccess: 'string'
    //repositoryToken: 'string'
    //repositoryUrl: 'string'
    //stagingEnvironmentPolicy: 'string'
    //templateProperties: {
    //  description: 'string'
    //  isPrivate: bool
    //  owner: 'string'
    //  repositoryName: 'string'
    //  templateRepositoryUrl: 'string'
    //}
  }
  sku: {
    name: sku  // Replace `sku` with your desired SKU value, e.g., 'Standard'
    tier: 'Standard'  // Adjust based on the tier you want, e.g., 'Standard'
  }
    //capacity: int
    //family: 'string'
    //locations: [
    //  'string'
    //]
    //name: 'string'
    //size: 'string'
    //skuCapacity: {
    //  default: int
    //  elasticMaximum: int
    //  maximum: int
    //  minimum: int
    //  scaleType: 'string'
    //}
    //tier: 'string'
  //tags: {
  //  {customized property}: 'string'
  //}
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
output staticWebAppUrl string = swa.properties.defaultHostname
