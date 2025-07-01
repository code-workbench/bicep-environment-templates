param prefix string
param location string = 'usgovvirginia'
param appServicePlanSku string = 'P1v2'

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: '${prefix}-app'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${prefix}-app-plan'
  location: location
  sku: {
    name: appServicePlanSku
    tier: 'PremiumV2'
  }
  kind: 'app'
}
