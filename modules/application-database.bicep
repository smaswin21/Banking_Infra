@description('Deployment location')
param location string = resourceGroup().location
@description('Environment type for deployment')
param environmentType string = 'nonprod'
param postgresSQLServerName string
param postgresSQLDatabaseName string
param logAnalyticsWorkspaceId string

module postgresSQLServer 'postgres-sql-server.bicep' = {
  name: 'postgresSQLServer'
  params: {
    location: location
    environmentType: environmentType
    postgresSQLServerName: postgresSQLServerName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}


module postgresSQLDatabase 'postgres-sql-database.bicep' = {
  name: 'postgresSQLDatabase'
  params: {
    postgresSQLServerName: postgresSQLServer.outputs.postgresSQLServerName
    postgresSQLDatabaseName: postgresSQLDatabaseName
  }
  dependsOn: [
    postgresSQLServer
  ]
}

output postgresSQLServerName string = postgresSQLServer.outputs.postgresSQLServerName
