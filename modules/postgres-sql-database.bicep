param location string = resourceGroup().location
param environmentType string = 'nonprod'
param postgresSQLDatabaseName string = 'ie-bank-db'
param postgresSQLServerName string

resource existingPostgresSQLServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' existing = {
  name: postgresSQLServerName
}

resource postgresSQLDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
  name: postgresSQLDatabaseName
  parent: existingPostgresSQLServer
  properties: {
    charset: 'UTF8'
    collation: 'en_US.UTF8'
  }
}

output postgresSQLDatabaseName string = postgresSQLDatabase.name
