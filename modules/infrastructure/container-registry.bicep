@description('Name of the Azure Container Registry')
param registryName string

@description('Resource group location')
param location string = resourceGroup().location

@description('The SKU of the Azure Container Registry (Basic, Standard, Premium)')
param sku string = 'Basic'

@description('The resource ID of the Azure Key Vault')
param keyVaultResourceId string

@description('Name of the secret to store the admin username')
param keyVaultSecretNameAdminUsername string

@description('Name of the secret to store the admin password 0')
param keyVaultSecretNameAdminPassword0 string

@description('Name of the secret to store the admin password 1')
param keyVaultSecretNameAdminPassword1 string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: registryName
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: true
  }
}

@description('Existing Key Vault resource')
resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: last(split(keyVaultResourceId, '/'))
}

// Store the container registry admin username in Key Vault
resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: keyVaultSecretNameAdminUsername
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().username
  }
}

// Store the container registry admin password 0 in Key Vault
resource secretAdminUserPassword0 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: keyVaultSecretNameAdminPassword0
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[0].value
  }
}

// Store the container registry admin password 1 in Key Vault
resource secretAdminUserPassword1 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: keyVaultSecretNameAdminPassword1
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[1].value
  }
}
