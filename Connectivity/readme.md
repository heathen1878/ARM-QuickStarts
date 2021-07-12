# Azure Connectivity deployment

[Home](../readme.md)

The artifact ConnectivityBasicLinkedTemplate.json and ConnectivityBasicTemplateSpec deploys a network watcher and virtual network. 

You can deploy these templates using PowerShell or an Azure DevOps Pipeline. 

## Template Spec

### PowerShell

To deploy a template spec you'll need a resource group - see the example below

```powershell
New-AzDeployment `
-Name (-Join("Deploy-Resource-Group-",(Get-Date).Day,"-",(Get-Date).Month,"-",(Get-Date).Year,"-",(Get-Date).Hour,(Get-Date).Minute))`
-Location "UK South" `
-TemplateFile .\Artifacts\Resource-Group.json -TemplateParameterFile .\Artifacts\Resource-Group.parameters.json
```

Then you'll need to deploy the template spec

```powershell
New-AzTemplateSpec `
-ResourceGroupName 'RG-DEMO-ARTIFACTS-UKSOUTH' `
-Name 'Connectivity-Basic' `
-Version '1.0.0.0' `
-Description 'Deploys a network watcher and vNet resource' `
-TemplateFile 'ConnectivityTemplateSpec.json' `
-DisplayName 'Connectivity - Network Watcher and vNet' `
-Location 'UK South'
```

Then run a deployment using the template spec by creating a resource for the deployment

```powershell
New-AzDeployment -Name (-Join("Deploy-Resource-Group-",(Get-Date).Day,"-",`
>> (Get-Date).Month,"-",(Get-Date).Year,"-",(Get-Date).Hour,(Get-Date).Minute)) -Location "UK South" -TemplateFile Resource-Group.json -TemplateParameterFile ..\Connectivity\Resource-Group.parameters.json
```

Then deploying the template spec

```powershell



```
