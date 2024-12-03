// Define location parameter for resource group location
@description('Deployment location')
param location string = resourceGroup().location

// Define App Service Plan name
@description('The name of the App Service Plan for hosting the application')
param appServicePlanName string

// Define SKU name parameter with allowed values
@description('SKU for the App Service Plan (e.g., B1 for basic plan, F1 for free plan)')
@allowed([
  'B1'
  'F1'
])
param skuName string

resource appServicePlan 'Microsoft.Web/serverFarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}
output id string = appServicePlan.id