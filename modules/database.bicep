@description('Deployment location')
param location string = resourceGroup().location
@description('Environment type for deployment')
param environmentType string = 'nonprod'
param postgresSQLServerName string
param postgresSQLDatabaseName string
param postgreSQLAdminServicePrincipalObjectId string
param postgreSQLAdminServicePrincipalName string

module postgresSQLServer './databases/postgres-sql-server.bicep' = {
  name: 'postgresSQLServer'
  params: {
    location: location
    environmentType: environmentType
    postgresSQLServerName: postgresSQLServerName
    postgreSQLAdminServicePrincipalObjectId: postgreSQLAdminServicePrincipalObjectId
    postgreSQLAdminServicePrincipalName: postgreSQLAdminServicePrincipalName
  }
}


module postgresSQLDatabase './databases/postgres-sql-database.bicep' = {
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
