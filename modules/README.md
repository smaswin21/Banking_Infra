# Azure Infrastructure Deployment

This directory contains Bicep templates for deploying Azure resources for the IE Bank application. The templates are organized into modular components to ensure reusability, clarity, and maintainability.

## Folder Structure

```
modules/
├── applications/      # Application services and plans
├── databases/         # Database resources
├── infrastructure/    # Shared infrastructure resources
├── database.bicep/    # Combined deployment for databases
└── website.bicep      # Combined deployment for the website frontend and backend
```

## Usage

1. **Ensure Azure CLI and Bicep CLI are installed.**
   - Install the Azure CLI: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
   - Install Bicep: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install

2. **Joint Orchestration**
    - The complete stack is organized by the `main.bicep` file in the parent directory

## Website Deployment

This file orchestrates the deployment of the entire website, including both frontend and backend applications.

### Resources Deployed

1. **Backend Service**: Deployed via the `backend-app-service.bicep` module.
2. **Frontend Service**: Deployed via the `frontend-app-service.bicep` module.
3. **App Service Plan**: Shared between frontend and backend.
4. **Container Registry**: Used for storing backend Docker images.
5. **Monitoring**: Includes Application Insights and Log Analytics.

### Parameters

Refer to the modules' README files for detailed parameter descriptions. Key parameters:
- `environmentType`: Environment type (`nonprod`, `prod`).
- `location`: Deployment location.
- `containerRegistryName`: Name of the Azure Container Registry.
- `appServiceAppName`, `appServiceAPIAppName`: Names of the frontend and backend services.
