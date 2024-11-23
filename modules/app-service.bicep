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

var appServicePlanSkuName = (environmentType == 'prod') ? 'B1' : 'B1' //modify according to desired capacity
// added these 
param appInsightsInstrumentationKey string
param appInsightsConnectionString string
param logAnalyticsWorkspaceId string



// BACKEND
module containerRegistry './container-registry.bicep' = {
  name: 'containerRegistry'
  params: {
    location: location
    registryName: containerRegistryName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

module appServicePlan './app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    skuName: appServicePlanSkuName
  }
}

module appServiceBE './backend-app-service.bicep' = {
  name: 'backend'
  params: {
    location: location
    appServiceAPIAppName: appServiceAPIAppName
    appServicePlanId: appServicePlan.outputs.id

    containerRegistryName: containerRegistryName
    dockerRegistryUserName: containerRegistry.outputs.registryUserName
    dockerRegistryPassword: containerRegistry.outputs.registryPassword0
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
  dependsOn: [
    containerRegistry
    appServicePlan
  ]
}

// FRONTEND
resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.outputs.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'NODE|18-lts'
      alwaysOn: false
      ftpsState: 'FtpsOnly'
      appCommandLine: 'pm2 serve /home/site/wwwroot --spa --no-daemon'
      appSettings: [
          // Add Application Insights settings
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
  dependsOn: [
    appServicePlan
  ]
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName


// Diagnostic Settings for App Service
resource appServiceDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'AppServiceDiagnostics'
  scope: appServiceApp
  properties: {
    workspaceId: logAnalyticsWorkspaceId // Log Analytics Workspace ID
    logs: [
      {
        category: 'AppServiceHTTPLogs' // Captures HTTP logs
        enabled: true
      }
      {
        category: 'AppServiceConsoleLogs' // Captures console logs
        enabled: true
      }
      {
        category: 'AppServiceAppLogs' // Captures application logs
        enabled: true
      }
      {
        category: 'AppServiceAuditLogs' // Captures audit logs
        enabled: true
      }
      {
        category: 'AppServiceIPSecAuditLogs' // Captures IPSec audit logs
        enabled: true
      }
      {
        category: 'AppServicePlatformLogs' // Captures platform logs
        enabled: true
      }
      {
        category: 'AppServiceAuthenticationLogs' // Captures authentication logs
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics' // Tracks all metrics for the app service
        enabled: false
      }
    ]
  }
}

// Outputs
output systemAssignedIdentityPrincipalId string = appServiceApp.identity.principalId
