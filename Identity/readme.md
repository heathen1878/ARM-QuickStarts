# Identity 

[Home](../readme.md)

The artifact VirtualMachineBasicLinkedTemplate.json deploys the following:

* Storage acccount for boot diagnostics
* Key vault
* Network Security Group with ruleset
* One or more virtual machines. 

The prerequisites for this template are: 

* [Virtual Network](../Connectivity/readme.md)
* Subnet
* Log Analytics Workspace

You can deploy these templates using PowerShell or an Azure DevOps Pipeline. 

### PowerShell

First of all you'll need a resource group

```powershell
New-AzDeployment `
-Name (-Join("Deploy-Resource-Group-",(Get-Date).Day,"-",(Get-Date).Month,"-",(Get-Date).Year,"-",(Get-Date).Hour,(Get-Date).Minute))`
-Location "UK South" `
-TemplateFile .\Resource-Group.json -TemplateParameterFile .\Resource-Group.parameters.json
```

Then you'll need to deploy a storage account to store the ARM artifacts - this is because the template references other ARM templates and those templates must be accessible to the Azure Resource Manager.

```powershell
New-AzResourceGroupDeployment `
-Name (-Join("Deploy-Storage-Account-",(Get-Date).Day,"-",(Get-Date).Month,"-",(Get-Date).Year,"-",(Get-Date).Hour,(Get-Date).Minute)) `
-Location "UK South" `
-TemplateFile .\Storage-Account.json -TemplateParameterFile .\Storage-Account.parameters.json
```



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
