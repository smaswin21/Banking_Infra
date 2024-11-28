@description('Location of the resource')
param location string

@description('Name of the Application Insights resource')
param appInsightsName string

@description('Log Analytics Workspace ID')
param logAnalyticsWorkspaceId string

@description('The resource ID of the Azure Key Vault')
param keyVaultResourceId string

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId // i am not sure what to put
  }
}

module workbook 'workbook.bicep' = {
  name: 'workbook'
  params: {
    location: location
    sourceId: appInsights.id
  }
}

@description('Existing Key Vault resource')
resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: last(split(keyVaultResourceId, '/'))
}


resource instrumentationKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: 'instrumentationKey'
  parent: adminCredentialsKeyVault
  properties: {
    value: appInsights.properties.InstrumentationKey
  }
}

resource connectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: 'connectionString'
  parent: adminCredentialsKeyVault
  properties: {
    value: appInsights.properties.ConnectionString
  }
}


output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsConnectionString string = appInsights.properties.ConnectionString