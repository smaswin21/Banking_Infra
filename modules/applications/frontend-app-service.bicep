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

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
