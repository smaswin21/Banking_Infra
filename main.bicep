// Environment Parameters
@sys.description('The environment type (nonprod or prod)')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string = 'nonprod'

@sys.description('The Azure location where the resources will be deployed')
param location string = resourceGroup().location

// PostgreSQL Parameters
@sys.description('The PostgreSQL Server name')
@minLength(3)
@maxLength(24)
param postgresSQLServerName string = 'ie-bank-db-server-dev'

@sys.description('The PostgreSQL Database name')
@minLength(3)
@maxLength(24)
param postgresSQLDatabaseName string = 'ie-bank-db'

// App Service Parameters
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

@sys.description('The SKU of the App Service Plan')
param sku string

// App Service Environment Variables
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

// Azure Container Registry Parameters
@sys.description('The name of the Azure Container Registry')
param containerRegistryName string

@sys.description('The name of the Docker image')
param dockerRegistryImageName string

@sys.description('The tag of the Docker image')
param dockerRegistryImageTag string = 'latest'

// Log Analytics Parameters
@sys.description('The name of the Log Analytics Workspace')
param logAnalyticsWorkspaceName string

var logAnalyticsWorkspaceId = resourceId('Microsoft.OperationalInsights/workspaces', logAnalyticsWorkspaceName)

// Application Insights Parameters
@sys.description('The name of the Application Insights resource')
param appInsightsName string

// Key Vault Parameters
@sys.description('The name of the Key Vault')
param keyVaultName string = 'ie-bank-kv-dev'

@sys.description('The array of role assignments for the Key Vault')
param keyVaultRoleAssignments array = []

@sys.description('Name of the secret to store the admin username')
param keyVaultSecretNameAdminUsername string

@sys.description('Name of the secret to store the admin password 0')
param keyVaultSecretNameAdminPassword0 string

@sys.description('Name of the secret to store the admin password 1')
param keyVaultSecretNameAdminPassword1 string

// Static Web App Parameters
@sys.description('The name of the Static Web App')
@minLength(3)
@maxLength(24)
param staticWebAppName string = 'ie-bank-swa-dev'

@sys.description('The location where the Static Web App will be deployed')
param locationswa string


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
    appInsightsName: appInsightsName
    appServiceAPIAppName: appServiceAPIAppName
    appServiceAPIDBHostDBUSER: appServiceAPIDBHostDBUSER
    appServiceAPIDBHostFLASK_APP: appServiceAPIDBHostFLASK_APP
    appServiceAPIDBHostFLASK_DEBUG: appServiceAPIDBHostFLASK_DEBUG
    appServiceAPIEnvVarDBHOST: appServiceAPIEnvVarDBHOST
    appServiceAPIEnvVarDBNAME: appServiceAPIEnvVarDBNAME
    appServiceAPIEnvVarDBPASS: appServiceAPIEnvVarDBPASS
    appServiceAPIEnvVarENV: appServiceAPIEnvVarENV
    appServiceAppName: appServiceAppName
    appServicePlanName: appServicePlanName
    containerRegistryName: containerRegistryName
    dockerRegistryImageName: dockerRegistryImageName
    dockerRegistryImageTag: dockerRegistryImageTag
    environmentType: environmentType
    keyVaultResourceId: keyVault.outputs.keyVaultResourceId // implicit dependency
    keyVaultSecretNameAdminPassword0: keyVaultSecretNameAdminPassword0
    keyVaultSecretNameAdminPassword1: keyVaultSecretNameAdminPassword1
    keyVaultSecretNameAdminUsername: keyVaultSecretNameAdminUsername
    location: location
    locationswa: locationswa
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    postgresSQLDatabaseName: postgresSQLDatabaseName
    postgresSQLServerName: postgresSQLServerName
    sku: sku
    staticappServiceAppName: staticWebAppName
//    appInsightsConnectionString: appInsights.outputs.appInsightsConnectionString
//    appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey // implicit dependency

  }
}


output appServiceAppHostName string = appService.outputs.appServiceAppHostName
output logAnalyticsWorkspaceId string = logAnalytics.outputs.logAnalyticsWorkspaceId
output logAnalyticsWorkspaceName string = logAnalytics.outputs.logAnalyticsWorkspaceName
output staticWebAppEndpoint string = appService.outputs.staticWebAppEndpoint
output staticWebAppResourceName string = appService.outputs.staticWebAppResourceName
