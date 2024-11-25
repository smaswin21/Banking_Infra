# Infrastructure Folder

This folder contains shared infrastructure modules, such as monitoring, logging, and key management.

## Modules

- **keyvault.bicep**
  - Deploys an Azure Key Vault.
  - Parameters:
    - `location`: Deployment location.
    - `keyVaultName`: Name of the Key Vault.
    - `roleAssignments`: Array of role assignments for the Key Vault.

- **log-analytics.bicep**
  - Deploys a Log Analytics Workspace.
  - Parameters:
    - `location`: Deployment location.
    - `name`: Name of the Log Analytics Workspace.

- **app-insights.bicep**
  - Deploys an Application Insights resource.
  - Parameters:
    - `location`: Deployment location.
    - `appInsightsName`: Name of the Application Insights resource.
    - `logAnalyticsWorkspaceId`: ID of the associated Log Analytics Workspace.

- **container-registry.bicep**
  - Deploys an Azure Container Registry.
  - Parameters:
    - `location`: Deployment location.
    - `registryName`: Name of the container registry.
    - `sku`: SKU tier (`Basic`, `Standard`, `Premium`).
