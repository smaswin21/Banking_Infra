// Define PostgreSQL server and database parameters
@description('The name of the PostgreSQL server')
param postgresSQLServerName string

@description('The name of the PostgreSQL database, defaulting to ie-bank-db')
param postgresSQLDatabaseName string = 'ie-bank-db'

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