// Define location parameter for resource group location
@description('Deployment location')
param location string = resourceGroup().location

// Define environment type
@description('Environment type for deployment')
param environmentType string = 'nonprod'

// Define PostgreSQL parameters
@description('The name of the PostgreSQL server')
param postgresSQLServerName string

@description('The name of the PostgreSQL database')
param postgresSQLDatabaseName string

@description('The service principal object ID for PostgreSQL admin')
param postgreSQLAdminServicePrincipalObjectId string

@description('The service principal name for PostgreSQL admin')
param postgreSQLAdminServicePrincipalName string

// Define Log Analytics Workspace parameter
@description('The ID of the Log Analytics Workspace for monitoring')
param logAnalyticsWorkspaceId string

module postgresSQLServer './databases/postgres-sql-server.bicep' = {
  name: 'postgresSQLServer'
  params: {
    environmentType: environmentType
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    postgreSQLAdminServicePrincipalName: postgreSQLAdminServicePrincipalName
    postgreSQLAdminServicePrincipalObjectId: postgreSQLAdminServicePrincipalObjectId
    postgresSQLServerName: postgresSQLServerName
  }
}


module postgresSQLDatabase './databases/postgres-sql-database.bicep' = {
  name: 'postgresSQLDatabase'
  params: {
    postgresSQLDatabaseName: postgresSQLDatabaseName
    postgresSQLServerName: postgresSQLServer.outputs.postgresSQLServerName
  }
  dependsOn: [
    postgresSQLServer
  ]
}

output postgresSQLServerName string = postgresSQLServer.outputs.postgresSQLServerName
