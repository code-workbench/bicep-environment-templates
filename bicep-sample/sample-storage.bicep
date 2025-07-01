param prefix string
param location string = 'usgovvirginia'
param storageSku string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: '${prefix}stg'
  location: location
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
}
