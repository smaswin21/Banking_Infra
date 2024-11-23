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

param appInsightsInstrumentationKey string
param appInsightsConnectionString string



// BACKEND
module containerRegistry './infrastructure/container-registry.bicep' = {
  name: 'containerRegistry'
  params: {
    location: location
    registryName: containerRegistryName
  }
}


module appServicePlan './applications/app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    skuName: appServicePlanSkuName
  }
}

module appServiceBE './applications/backend-app-service.bicep' = {
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
  // dependencies are implicit
}

// FRONTEND

module frontendApp './applications/frontend-app-service.bicep' = {
  name: 'frontendAppService'
  params: {
    appServiceAppName: appServiceAppName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    appInsightsInstrumentationKey: appInsightsInstrumentationKey
    appInsightsConnectionString: appInsightsConnectionString
  }
}

output appServiceAppHostName string = frontendApp.outputs.appServiceAppHostName