
param location string = resourceGroup().location
param appServiceAPIAppName string
param appServicePlanId string
param containerRegistryName string
@secure()
param dockerRegistryUserName string
@secure()
param dockerRegistryPassword string
param dockerRegistryImageName string
param dockerRegistryImageTag string = 'latest'
param appSettings array = []
param appCommandLine string = ''

var dockerAppSettings = [
  { name: 'DOCKER_REGISTRY_SERVER_URL', value: 'https://${containerRegistryName}.azurecr.io'}
  { name: 'DOCKER_REGISTRY_SERVER_USERNAME', value: dockerRegistryUserName }
  { name: 'DOCKER_REGISTRY_SERVER_PASSWORD', value: dockerRegistryPassword }
  { name: 'WEBSITES_PORT', value: '5000' }
]

resource appServiceAPIApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAPIAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${dockerRegistryImageName}:${dockerRegistryImageTag}'
      alwaysOn: false
      ftpsState: 'FtpsOnly'
      appCommandLine: appCommandLine
      appSettings: union(appSettings, dockerAppSettings)
    }
  }
}

output appServiceAppHostName string = appServiceAPIApp.properties.defaultHostName
output systemAssignedIdentityPrincipalId string = appServiceAPIApp.identity.principalId
