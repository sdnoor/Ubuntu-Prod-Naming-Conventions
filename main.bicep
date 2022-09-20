param project string
param location string
param locationname string
param vmSize string

@secure()
param adminUserName string

@secure()
param adminKey string

@allowed([
  'prod'
  'dev'
])
param environmentType string

param authenticationType string = 'sshKey'

var vmName = 'vmlwso2-${environmentType}'
var computerName = '${environmentType}-id'
var osDiskName = 'vmlwso2-${environmentType}_OSDisk'
var storageAccountName = 'sto${project}${locationname}${environmentType}'
var nicName = 'NIC-VMLwso2-${environmentType}'
var pubIPVM = 'pubIP-vm-wso2-${environmentType}'
var vNetName = 'vnet-wso2-${locationname}-${environmentType}'
var    linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
    {
      path: '/home/${adminUserName}/.ssh/authorized_keys'
      keyData: adminKey
    }
    ]
  }
}






resource ubuntuVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: computerName
      adminUsername: adminUserName
      adminPassword: adminKey
   linuxConfiguration: any(authenticationType == 'password') ? null : linuxConfiguration
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: osDiskName
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageaccount.properties.primaryEndpoints.blob
      }
    }
  }
}




resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}


resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'name'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddress.id
          }
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: pubIPVM
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: 'cebsdevops'
    }
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}




