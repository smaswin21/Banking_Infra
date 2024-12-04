@description('Location of the resource')
param location string

@description('Name of the Application Insights resource')
param appInsightsName string

@description('Log Analytics Workspace ID')
param logAnalyticsWorkspaceId string

@description('The resource ID of the Azure Key Vault')
param keyVaultResourceId string

@description('Slack Webhook URL to send alerts')
@secure()
param slackWebhookUrl string = 'https://hooks.slack.com/services/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'

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
@description('Alert rule for login response time exceeding 5 seconds')
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
    autoMitigate: true
    actions: [
      {
        actionGroupId: logicAppActionGroup.id
        webHookProperties: {
          customMessage: 'Login response time exceeded the threshold of 5 seconds. Immediate attention required.'
        }
      }
    ]
  }
}

// Page Load Time Alert Rule with Action Group to trigger Slack notification
@description('Alert rule for page load time exceeding 2 seconds')
resource pageLoadTimeAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'Page-Load-Time-Alert'
  location: 'global'
  properties: {
    description: 'Alert when page load time exceeds 5 seconds'
    severity: 4
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
          name: 'PageLoadTime'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'browserTimings/totalDuration'
          operator: 'GreaterThan'
          threshold: 5000
          timeAggregation: 'Average'
        }
      ]
    }
    autoMitigate: true
    actions: [
      {
        actionGroupId: logicAppActionGroup.id
        webHookProperties: {
          // Additional properties if needed
          customMessage: 'Page load time exceeded the threshold of 5 seconds. Please check immediately.'
        }
      }
    ]
  }
}

// Action Group Resource
@description('Action group for Slack notification through Logic App')
resource logicAppActionGroup 'Microsoft.Insights/actionGroups@2022-06-01' = {
  name: 'Slack-Notification-ActionGroup'
  location: 'global'
  properties: {
    groupShortName: 'SlackAlert'
    enabled: true
    webhookReceivers: [
      {
        name: 'SlackWebhook'
        serviceUri: slackWebhookUrl
        useCommonAlertSchema: true
      }
    ]
  }
}


output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsConnectionString string = appInsights.properties.ConnectionString
