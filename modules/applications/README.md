# Applications Folder

This folder contains Bicep modules for deploying application-related resources.

## Modules

- **app-service-plan.bicep**
  - Deploys an Azure App Service Plan.
  - Parameters:
    - `location`: Deployment location.
    - `appServicePlanName`: Name of the App Service Plan.
    - `skuName`: SKU tier (`B1`, `F1`, etc.).

- **backend-app-service.bicep**
  - Deploys the backend service using a Docker container.
  - Parameters:
    - `location`: Deployment location.
    - `appServiceAPIAppName`: Name of the backend App Service.
    - `appServicePlanId`: ID of the associated App Service Plan.
    - `dockerRegistryUserName`, `dockerRegistryPassword`: Credentials for the container registry.
    - `appSettings`: Array of custom environment variables for the backend service.

- **frontend-app-service.bicep**
  - Deploys the frontend service for the website.
  - Parameters:
    - `location`: Deployment location.
    - `appServiceAppName`: Name of the frontend App Service.
    - `appServicePlanId`: ID of the associated App Service Plan.
    - `appInsightsInstrumentationKey`, `appInsightsConnectionString`: Monitoring configurations.
