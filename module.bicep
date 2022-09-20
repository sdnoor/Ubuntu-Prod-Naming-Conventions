param project string
param location string
param locationname string
param vmSize string

@secure()
param adminUserName string

@allowed([
  'prod'
  'dev'
])
param environmentType string

param kVaultRGName string = 'rg-weu-prod'

module vmUbuntu 'main.bicep'= {
  name: 'Referencing ssh Public Key through Key Vault'
  params: {
    location: location 
    adminKey: keyVault.getSecret('sshKey')
    adminUserName: adminUserName
    environmentType: environmentType
    locationname: locationname
    project: project
    vmSize: vmSize
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: 'kvsql40'
  scope: resourceGroup(kVaultRGName)
}
