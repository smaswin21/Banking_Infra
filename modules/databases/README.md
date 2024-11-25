# Databases Folder

This folder contains Bicep modules for deploying database resources.

## Modules

- **postgres-sql-server.bicep**
  - Deploys a PostgreSQL Flexible Server.
  - Parameters:
    - `location`: Deployment location.
    - `environmentType`: Environment type (`nonprod`, `prod`).
    - `postgresSQLServerName`: Name of the PostgreSQL server.

- **postgres-sql-database.bicep**
  - Deploys a database within an existing PostgreSQL server.
  - Parameters:
    - `postgresSQLServerName`: Name of the existing PostgreSQL server.
    - `postgresSQLDatabaseName`: Name of the database to create.
