@description('Location of the resource')
param location string = resourceGroup().location

@description('Name of the Logic App')
param logicAppName string

@description('Slack Webhook URL to send alerts')
@secure()
param slackWebhookUrl string = 'https://hooks.slack.com/services/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'

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  properties: {
    state: 'Enabled'
    definition: json(loadTextContent('./logicAppWorkflow.json')) // Referencing the workflow JSON file.
    parameters: {
      slackWebhookUrl: {
        value: slackWebhookUrl
      }
    }
  }
}
