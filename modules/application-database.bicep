param location string = resourceGroup().location
param environmentType string = 'nonprod'
param postgresSQLServerName string
param postgresSQLDatabaseName string

if (location == null) {
  throw new Error('location is required')
}

module postgresSQLServer 'postgres-sql-server.bicep' = {
  name: 'postgresSQLServer'
  params: {
    location: location
    environmentType: environmentType
    postgresSQLServerName: postgresSQLServerName
  }
}


module postgresSQLDatabase 'postgres-sql-database.bicep' = {
  name: 'postgresSQLDatabase'
  params: {
    location: location
    environmentType: environmentType
    postgresSQLServerName: postgresSQLServer.outputs.postgresSQLServerName
    postgresSQLDatabaseName: postgresSQLDatabaseName
  }
  dependsOn: [
    postgresSQLServer
  ]
}

output postgresSQLServerName string = postgresSQLServer.outputs.postgresSQLServerName