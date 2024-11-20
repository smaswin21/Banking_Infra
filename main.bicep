@sys.description('The environment type (nonprod or prod)')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string = 'nonprod'
@sys.description('The PostgreSQL Server name')
@minLength(3)
@maxLength(24)
param postgresSQLServerName string = 'ie-bank-db-server-dev'
@sys.description('The PostgreSQL Database name')
@minLength(3)
@maxLength(24)
param postgresSQLDatabaseName string = 'ie-bank-db'
@sys.description('The App Service Plan name')
@minLength(3)
@maxLength(24)
param appServicePlanName string = 'ie-bank-app-sp-dev'
@sys.description('The Web App name (frontend)')
@minLength(3)
@maxLength(24)
param appServiceAppName string = 'ie-bank-dev'
@sys.description('The API App name (backend)')
@minLength(3)
@maxLength(24)
param appServiceAPIAppName string = 'ie-bank-api-dev'
@sys.description('The Azure location where the resources will be deployed')
param location string = resourceGroup().location
@sys.description('The value for the environment variable ENV')
param appServiceAPIEnvVarENV string
@sys.description('The value for the environment variable DBHOST')
param appServiceAPIEnvVarDBHOST string
@sys.description('The value for the environment variable DBNAME')
param appServiceAPIEnvVarDBNAME string
@sys.description('The value for the environment variable DBPASS')
@secure()
param appServiceAPIEnvVarDBPASS string
@sys.description('The value for the environment variable DBUSER')
param appServiceAPIDBHostDBUSER string
@sys.description('The value for the environment variable FLASK_APP')
param appServiceAPIDBHostFLASK_APP string
@sys.description('The value for the environment variable FLASK_DEBUG')
param appServiceAPIDBHostFLASK_DEBUG string
@sys.description('The name of the Azure Container Registry')
param containerRegistryName string
@sys.description('The name of the Docker image')
param dockerRegistryImageName string
@sys.description('The tag of the Docker image')
param dockerRegistryImageTag string = 'latest'
@sys.description('The name of the Log Analytics Workspace')
param logAnalyticsWorkspaceName string
@description('The name of the Application Insights resource')
param appInsightsName string 
var logAnalyticsWorkspaceId = resourceId('Microsoft.OperationalInsights/workspaces', logAnalyticsWorkspaceName)



module applicationDatabase 'modules/application-database.bicep' = {
  name: 'applicationDatabase'
  params: {
    location: location
    environmentType: environmentType
    postgresSQLServerName: postgresSQLServerName
    postgresSQLDatabaseName: postgresSQLDatabaseName
  }

}

// Deploy Log Analytics Workspace
module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'logAnalytics'
  params: {
    location: location
    name: logAnalyticsWorkspaceName
  }
}

module appInsights 'modules/app-insights.bicep' = {
  name: 'appInsights'
  params: {
    location: location
    appInsightsName: appInsightsName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
  dependsOn: [
    logAnalytics
  ]
}

module appService 'modules/app-service.bicep' = {
  name: 'appService'
  params: {
    location: location
    environmentType: environmentType
    appServiceAppName: appServiceAppName
    appServiceAPIAppName: appServiceAPIAppName
    appServicePlanName: appServicePlanName
    appServiceAPIDBHostDBUSER: appServiceAPIDBHostDBUSER
    appServiceAPIDBHostFLASK_APP: appServiceAPIDBHostFLASK_APP
    appServiceAPIDBHostFLASK_DEBUG: appServiceAPIDBHostFLASK_DEBUG
    appServiceAPIEnvVarDBHOST: appServiceAPIEnvVarDBHOST
    appServiceAPIEnvVarDBNAME: appServiceAPIEnvVarDBNAME
    appServiceAPIEnvVarDBPASS: appServiceAPIEnvVarDBPASS
    appServiceAPIEnvVarENV: appServiceAPIEnvVarENV
    dockerRegistryImageName: dockerRegistryImageName
    dockerRegistryImageTag: dockerRegistryImageTag
    containerRegistryName: containerRegistryName
    // Pass Application Insights settings
    appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey
    appInsightsConnectionString: appInsights.outputs.appInsightsConnectionString

  }
  dependsOn: [
    applicationDatabase
    // i think the registry should be here aswell
    appInsights
  ]
}

output appServiceAppHostName string = appService.outputs.appServiceAppHostName
output logAnalyticsWorkspaceId string = logAnalytics.outputs.logAnalyticsWorkspaceId
output logAnalyticsWorkspaceName string = logAnalytics.outputs.logAnalyticsWorkspaceName
output appInsightsInstrumentationKey string = appInsights.outputs.appInsightsInstrumentationKey
output appInsightsConnectionString string = appInsights.outputs.appInsightsConnectionString 


