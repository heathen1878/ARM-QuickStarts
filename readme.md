# Quickstart templates

## Template Specs
To deploy a template specs first create a resource group using the New-AzDeployment cmdlet e.g.
```powershell
New-AzDeployment `
-Name (-Join("Deploy-Resource-Group-",(Get-Date).Day,"-",(Get-Date).Month,"-",(Get-Date).Year,"-",(Get-Date).Hour,(Get-Date).Minute))`
-Location "UK South" `
-TemplateFile .\Artifacts\Resource-Group.json -TemplateParameterFile .\Artifacts\Resource-Group.parameters.json
```

Then deploy the template spec, taking care to version correctly. I set the version to match the contentVersion attribute within the main template e.g.
```json
...
"$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
...
```

```powershell
New-AzTemplateSpec `
-ResourceGroupName 'RG-DEMO-ARTIFACTS-UKSOUTH' `
-Name 'Connectivity-Basic' `
-Version '1.0.0.0' `
-Description 'Deploys a network watcher and vNet resource' `
-TemplateFile 'ConnectivityTemplateSpec.json' `
-DisplayName 'Connectivity - Network Watcher and vNet'
```

## Azure DevOps
[Service Connection](/AzureDevOps/readMe.md)

## Resource Groups
[To deploy a resource group review this readme first](/Artifacts/Resource-Group.md)

## Connectivity
[Basic Connectivity](/Connectivity/readme.md)
