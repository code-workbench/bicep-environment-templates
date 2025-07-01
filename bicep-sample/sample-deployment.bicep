targetScope = 'subscription'
@description('Prefix for the resource names')
param prefix string

@description('Location for the resource group')
param location string = 'usgovvirginia'

@description('SKU for the App Service Plan')
param appServicePlanSku string = 'P1v2'

@description('SKU for the Storage Account')
param storageSku string = 'Standard_LRS'

// Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${prefix}-rg'
  location: location
}

module appServiceModule 'sample-app-service.bicep' = {
  name: 'appServiceModule'
  scope: resourceGroup
  params: {
    prefix: prefix
    location: location
    appServicePlanSku: appServicePlanSku
  }
}
module storageModule 'sample-storage.bicep' = {
  name: 'storageModule'
  scope: resourceGroup
  params: {
    prefix: prefix
    location: location
    storageSku: storageSku
  }
}

// Output resource IDs
output resourceGroupId string = resourceGroup.id
