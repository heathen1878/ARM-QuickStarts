# Identity 

[Home](../readme.md)

The artifacts used here deploy the following:

* Storage acccount for boot diagnostics
* Key vault
* Network Security Group with ruleset
* Creates secrets as specified
* One or more virtual machines 

The prerequisites for this template are: 

* [Virtual Network](../Connectivity/readme.md)
* Subnet
* Log Analytics Workspace

You can deploy these templates using PowerShell or an Azure DevOps Pipeline. 

### PowerShell

First of all you'll need to setup your [deployment](../Deploy/readme.md) artifacts

Now everything is in place to start a deployment.

Create a resource group

```powershell
$resourceGroupOutputs = New-AzDeployment `
-Name (-Join("Deploy-Resource-Group-",(Get-Date).Day,"-",(Get-Date).Month,"-",(Get-Date).Year,"-",(Get-Date).Hour,(Get-Date).Minute))`
-Location "UK South" `
-TemplateFile .\Resource-Group.json -TemplateParameterFile ..\Identity\Resource-Group.parameters.json
```

As above you'll need a [virtual network](../Connectivity/readme.md)

Create a subnet

```powershell
$subnetOutputs = New-AzResourceGroupDeployment -Name (-Join("Deploy-Virtual-Network-Subnet-",(Get-Date).Day,"-",(Get-Date).Month,"-",(Get-Date).Year,"-",(Get-Date).Hour,(Get-Date).Minute)) `
-ResourceGroupName $connectivityResourceGroupName.Outputs.resourceGroupName.value `
-TemplateFile .\Virtual-Network-Subnet.json `
-TemplateParameterFile ..\Identity\Virtual-Network-Subnet.parameters.json


```


```powershell
New-AzResourceGroupDeployment -Name (-Join("Deploy-Storage-Account-",(Get-Date).Day,"-",(Get-Date).Month,"-",(Get-Date).Year,"-",(Get-Date).Hour,(Get-Date).Minute)) ` -ResourceGroupName "RG-DOM-DEMO-IDENTITY-UKSOUTH" -TemplateFile .\VirtualMachineBasicLinkedTemplate.json -TemplateParameterFile ..\Identity\VirtualMachineBasicLinkedTemplate.parameters.json -_artifactsLocation $artifactsLocation -_artifactsLocationSasToken $artifactsKey
```