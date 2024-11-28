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

// Unauthorized Access Alert Rule
@description('Alert rule for login time')
resource loginSLOAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'Login-SLO-Alert'
  location: 'global'
  properties: {
    description: 'Alert when login response time exceeds 5 seconds'
    severity: 2
    enabled: true
    scopes: [
      appInsights.id
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'LoginResponseTime'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'requests/duration'
          operator: 'GreaterThan'
          threshold: 5000
          timeAggregation: 'Average'
        }
      ]
    }
  }
}


output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsConnectionString string = appInsights.properties.ConnectionString
