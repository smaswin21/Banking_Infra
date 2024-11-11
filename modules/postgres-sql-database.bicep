param location string = resourceGroup().location
param environmentType string = 'nonprod'
param postgreSQLServerName string = 'ie-bank-db-server-dev'
param postgreSQLDatabaseName string = 'ie-bank-db'


resource postgresSQLDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
  name: postgreSQLDatabaseName
  parent: postgresSQLServer
  properties: {
    charset: 'UTF8'
    collation: 'en_US.UTF8'
  }
}

output postgresSQLDatabaseName string = postgresSQLDatabase.name
