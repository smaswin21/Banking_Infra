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
@sys.description('The name of the Key Vault')
param keyVaultName string = 'ie-bank-kv-dev'
@sys.description('The arrasy of role assignments for the Key Vault')
param keyVaultRoleAssignments array = []
@description('Name of the secret to store the admin username')
param keyVaultSecretNameAdminUsername string
@description('Name of the secret to store the admin password 0')
param keyVaultSecretNameAdminPassword0 string
@description('Name of the secret to store the admin password 1')
param keyVaultSecretNameAdminPassword1 string
@sys.description('The name of the Static Web App')
@minLength(3)
@maxLength(24)
param staticWebAppName string = 'ie-bank-swa-dev'
@sys.description('The location where the Static Web App will be deployed')
param locationswa string
@sys.description('The SKU of the App Service Plan')
param sku string


@description('Name of the Logic App')
param logicAppName string

@description('Slack Webhook URL to send alerts')
@secure()
param slackWebhookUrl string

module keyVault 'modules/infrastructure/keyvault.bicep' = {
  name: 'keyVault'
  params: {
    keyVaultName: keyVaultName
    location: location
    roleAssignments: keyVaultRoleAssignments
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}


// Deploy Log Analytics Workspace
module logAnalytics 'modules/infrastructure/log-analytics.bicep' = {
  name: 'logAnalytics'
  params: {
    location: location
    name: logAnalyticsWorkspaceName
  }
}

module logicAppModule 'modules/infrastructure/logic-app.bicep' = {
  name: 'logicAppDeployment'
  params: {
    logicAppName: logicAppName
    slackWebhookUrl: slackWebhookUrl
  }
}


module appService 'modules/website.bicep' = {
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
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    //static web app
    staticappServiceAppName: staticWebAppName
    sku: sku
    locationswa: locationswa
    // Pass Application Insights settings
    appInsightsName: appInsightsName
//    appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey // implicit dependency
//    appInsightsConnectionString: appInsights.outputs.appInsightsConnectionString
    keyVaultResourceId: keyVault.outputs.keyVaultResourceId // implicit dependency
    keyVaultSecretNameAdminUsername: keyVaultSecretNameAdminUsername
    keyVaultSecretNameAdminPassword0: keyVaultSecretNameAdminPassword0
    keyVaultSecretNameAdminPassword1: keyVaultSecretNameAdminPassword1
    postgresSQLServerName: postgresSQLServerName
    postgresSQLDatabaseName: postgresSQLDatabaseName

  }
}


output appServiceAppHostName string = appService.outputs.appServiceAppHostName
output logAnalyticsWorkspaceId string = logAnalytics.outputs.logAnalyticsWorkspaceId
output logAnalyticsWorkspaceName string = logAnalytics.outputs.logAnalyticsWorkspaceName
output staticWebAppEndpoint string = appService.outputs.staticWebAppEndpoint
output staticWebAppResourceName string = appService.outputs.staticWebAppResourceName
