// Define location parameter for resource group location
@description('The location where all resources will be deployed')
param location string = resourceGroup().location

// Define application and service-related parameters
@description('The name of the App Service Plan for hosting the application')
param appServicePlanName string

@description('The name of the App Service application')
param appServiceAppName string

@description('The name of the Static App Service application')
param staticappServiceAppName string

@description('The name of the Application Insights resource for monitoring and diagnostics')
param appInsightsName string

@description('The name of the App Service API application')
param appServiceAPIAppName string

// Define environment variable parameters for App Service API
@description('Environment variable for the application environment (e.g., staging, production)')
param appServiceAPIEnvVarENV string

@description('Database host for the API environment variable')
param appServiceAPIEnvVarDBHOST string

@description('Database name for the API environment variable')
param appServiceAPIEnvVarDBNAME string

@description('Database password for the API environment variable')
@secure()
param appServiceAPIEnvVarDBPASS string

@description('Database user for the API environment variable')
param appServiceAPIDBHostDBUSER string

@description('Flask application name for the API environment variable')
param appServiceAPIDBHostFLASK_APP string

@description('Flask debug mode for the API environment variable (e.g., 0 for off, 1 for on)')
param appServiceAPIDBHostFLASK_DEBUG string

// Define environment type
@description('The environment type (nonprod or prod)')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string

// Define container registry parameters
@description('The name of the container registry')
param containerRegistryName string

@description('The name of the Docker registry image')
param dockerRegistryImageName string

@description('The tag of the Docker registry image')
param dockerRegistryImageTag string

// Define Key Vault-related parameters
@description('Resource ID of the Key Vault')
param keyVaultResourceId string

@description('Name of the secret in Key Vault to store the admin username')
param keyVaultSecretNameAdminUsername string

@description('Name of the secret in Key Vault to store the admin password 0')
param keyVaultSecretNameAdminPassword0 string

@description('Name of the secret in Key Vault to store the admin password 1')
param keyVaultSecretNameAdminPassword1 string

// Define PostgreSQL parameters
@description('The name of the PostgreSQL server')
param postgresSQLServerName string

@description('The name of the PostgreSQL database')
param postgresSQLDatabaseName string

// Define Log Analytics Workspace parameter
@description('The ID of the Log Analytics Workspace for monitoring')
param logAnalyticsWorkspaceId string

// Define App Service Plan SKU
@description('SKU for the App Service Plan based on environment type (e.g., B1 for basic plan)')
var appServicePlanSkuName = (environmentType == 'prod') ? 'B1' : 'B1' // Modify according to desired capacity

// Define SKU and location parameters
@description('SKU for the resource')
param sku string

@description('Location for the Static Web App')
param locationswa string


module appInsights './infrastructure/app-insights.bicep' = {
  name: 'appInsights'
  params: {
    appInsightsName: appInsightsName
    keyVaultResourceId: keyVaultResourceId
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId // Pass log analytics reference to Application Insights
  }
}


// BACKEND
module containerRegistry './infrastructure/container-registry.bicep' = {
  name: 'containerRegistry'
  params: {
    keyVaultResourceId: keyVaultResourceId
    keyVaultSecretNameAdminPassword0: keyVaultSecretNameAdminPassword0
    keyVaultSecretNameAdminPassword1: keyVaultSecretNameAdminPassword1
    keyVaultSecretNameAdminUsername: keyVaultSecretNameAdminUsername
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    registryName: containerRegistryName
  }
}


module appServicePlan './applications/app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    appServicePlanName: appServicePlanName
    location: location
    skuName: appServicePlanSkuName
  }
}


@description('Existing Key Vault resource')
resource keyVaultReference 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: last(split(keyVaultResourceId, '/'))
}


module appServiceBE './applications/backend-app-service.bicep' = {
  name: 'backend'
  params: {
    appInsightsConnectionString: appInsights.outputs.appInsightsConnectionString
    appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey // implicit dependency
    appServiceAPIAppName: appServiceAPIAppName
    appServicePlanId: appServicePlan.outputs.id
    containerRegistryName: containerRegistryName
    dockerRegistryImageName: dockerRegistryImageName
    dockerRegistryImageTag: dockerRegistryImageTag
    dockerRegistryPassword: keyVaultReference.getSecret(keyVaultSecretNameAdminPassword0)
    dockerRegistryUserName: keyVaultReference.getSecret(keyVaultSecretNameAdminUsername)
    location: location

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
        value: appServiceAPIAppName
      }
      {
        name: 'FLASK_DEBUG'
        value: appServiceAPIDBHostFLASK_DEBUG
      }
      {
        name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
        value: 'true'
      }

    ]
  }
  // dependencies are implicit
  dependsOn: [
    appInsights
    appServicePlan
    containerRegistry
    keyVaultReference
  ]
}


module applicationDatabase './database.bicep' = {
  name: 'applicationDatabase'
  params: {
    environmentType: environmentType
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    postgreSQLAdminServicePrincipalName: appServiceAPIAppName
    postgreSQLAdminServicePrincipalObjectId: appServiceBE.outputs.systemAssignedIdentityPrincipalId
    postgresSQLDatabaseName: postgresSQLDatabaseName
    postgresSQLServerName: postgresSQLServerName
  }
}


// FRONTEND

module frontendApp './applications/frontend-app-service.bicep' = {
  name: 'frontendAppService'
  params: {
    appInsightsConnectionString: appInsights.outputs.appInsightsConnectionString
    appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey // implicit dependency
    appServiceAppName: appServiceAppName
    appServicePlanId: appServicePlan.outputs.id
    location: location
    locationswa: locationswa
    name: staticappServiceAppName  // Name for the static web app
    sku: sku         // Set appropriate SKU for Static Web App
  }
}

output appServiceAppHostName string = frontendApp.outputs.appServiceAppHostName
output staticWebAppEndpoint string = frontendApp.outputs.staticWebAppEndpoint
output staticWebAppResourceName string = frontendApp.outputs.staticWebAppResourceName