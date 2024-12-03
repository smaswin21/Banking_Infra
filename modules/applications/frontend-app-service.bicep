// Define App Service application name
@description('The name of the App Service application')
param appServiceAppName string

// Define deployment location
@description('The location where the App Service will be deployed')
param location string

// Define App Service Plan ID
@description('The ID of the App Service Plan this App Service will use')
param appServicePlanId string

// Define Application Insights parameters
@description('Application Insights Instrumentation Key for monitoring')
param appInsightsInstrumentationKey string

@description('Application Insights Connection String for monitoring')
param appInsightsConnectionString string

// Define command line to run for App Service
@description('The command line to run for the App Service')
param appCommandLine string = 'pm2 serve /home/site/wwwroot --spa --no-daemon'

// Define static web app parameters
@description('Name of the static web app')
param name string

@description('The location where the Static Web App will be deployed')
param locationswa string

// Define service tier
@allowed([
  'Free'
  'Standard'
])
@description('The service tier')
param sku string



// https://learn.microsoft.com/en-us/azure/templates/microsoft.web/staticsites?pivots=deployment-language-bicep
resource swa 'Microsoft.Web/staticSites@2024-04-01' = {
  //identity: {
  //  type: 'string'
  //  userAssignedIdentities: {
  //    {customized property}: {}
  //  }
  //}
  location: locationswa
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

output staticWebAppUrl string = swa.properties.defaultHostname
output staticWebAppEndpoint string = swa.properties.defaultHostname
output staticWebAppResourceName string = swa.name
