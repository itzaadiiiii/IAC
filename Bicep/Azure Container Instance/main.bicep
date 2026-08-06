@secure()
param containerGroups_hello_world_workspaceKey string
param containerGroups_hello_world_name string = 'hello-world'

resource containerGroups_hello_world_name_resource 'Microsoft.ContainerInstance/containerGroups@2025-09-01' = {
  name: containerGroups_hello_world_name
  location: 'eastus'
  properties: {
    sku: 'Standard'
    containers: [
      {
        name: containerGroups_hello_world_name
        properties: {
          image: 'mcr.microsoft.com/azuredocs/aci-helloworld:latest'
          ports: [
            {
              protocol: 'TCP'
              port: 80
            }
          ]
          environmentVariables: []
          configMap: {
            keyValuePairs: {}
          }
          resources: {
            requests: {
              memoryInGB: json('1.5')
              cpu: json('1')
            }
          }
        }
      }
    ]
    initContainers: []
    restartPolicy: 'OnFailure'
    ipAddress: {
      ports: [
        {
          protocol: 'TCP'
          port: 80
        }
      ]
      ip: '128.203.82.106'
      type: 'Public'
    }
    osType: 'Linux'
    diagnostics: {
      logAnalytics: {
        workspaceId: '597852f1-41cf-4b4c-bbb0-953cd7a0897e'
        logType: 'ContainerInstanceLogs'
        workspaceKey: containerGroups_hello_world_workspaceKey
      }
    }
  }
}
