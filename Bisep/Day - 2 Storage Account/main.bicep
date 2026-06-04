resource storageAccount 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: 'slashhhstorage'
  location: rg.location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
