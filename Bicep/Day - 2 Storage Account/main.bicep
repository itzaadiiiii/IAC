resource storageAccount 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: 'slashhhstorage'
  // location: rg.location    #This is how you refer the other resoruce properties in bicep
  location: 'centralindia'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
