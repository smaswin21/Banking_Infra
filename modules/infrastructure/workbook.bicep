@sys.description('The linked resource of the workbook')
param sourceId string
@sys.description('The location of the resource')
param location string

resource sampleWorkbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: guid('sampleWorkbook', resourceGroup().id)
  location: location
  kind:'shared'
  properties: {
    category: 'workbook'
    displayName: 'Awesome Workbook'
    //serializedData: replace(loadTextContent(('workbooks/workbook.json')), 'APPINSIGHTSPLACEHOLDER', appInsightsResourceId)
    serializedData: loadTextContent('../../workbooks/main.workbook')
    sourceId: sourceId
  }
}