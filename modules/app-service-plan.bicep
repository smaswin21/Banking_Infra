param location string = resourceGroup().location
param appServicePlanName string
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