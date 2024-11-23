@description('Name of the Azure Container Registry')
param registryName string

@description('Resource group location')
param location string = resourceGroup().location

@description('The SKU of the Azure Container Registry (Basic, Standard, Premium)')
param sku string = 'Basic'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: registryName
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: true
  }
}

output registryUserName string = containerRegistry.listCredentials().username
output registryPassword0 string = containerRegistry.listCredentials().passwords[0].value
output registryPassword1 string = containerRegistry.listCredentials().passwords[1].value

//adding diagnostic settings
param ContainerRegistryDiagnostics string ='myDiagnosticSetting'
param logAnalyticsWorkspaceId string

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: ContainerRegistryDiagnostics
  scope: containerRegistry // Attach to the Container Registry
  properties: {
    workspaceId: logAnalyticsWorkspaceId // Log Analytics Workspace ID
    logs: [
      {
        category: 'ContainerRegistryLoginEvents' // Tracks login events
        enabled: true
      }
      {
        category: 'ContainerRegistryRepositoryEvents' // Tracks repository events (push, pull, delete)
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics' // Tracks metrics for ACR
        enabled: true
      }
    ]
  }
}
