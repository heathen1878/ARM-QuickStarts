# Azure Connectivity deployment

[Home](../readme.md)

The template ConnectivityBasicLinkedTemplate.json deploys a network watcher and virtual network. 

You can deploy these templates using PowerShell or an Azure DevOps Pipeline; a working Azure DevOps Pipeline can be found [here](https://github.com/heathen1878/Azure/blob/master/Connectivity/readme.md) 

### PowerShell

First of all you'll need to setup your [deployment](../Deploy/readme.md) store and templates.

Now everything is in place to start a deployment.

Create a resource group

```powershell
$connectivityResourceGroupOutputs = New-AzDeployment `
-Name (-Join("Deploy-Resource-Group-",(Get-Date).Day,"-",(Get-Date).Month,"-",(Get-Date).Year,"-",(Get-Date).Hour,(Get-Date).Minute))`
-Location "UK South" `
-TemplateFile .\Resource-Group.json -TemplateParameterFile ..\Connectivity\Resource-Group.parameters.json
```

Run the deployment

```powershell
New-AzResourceGroupDeployment -Name (-Join("Deploy-Conncectivity-Basic-Linked-Template-",(Get-Date).Day,"-",(Get-Date).Month,"-",(Get-Date).Year,"-",(Get-Date).Hour,(Get-Date).Minute)) ` 
-ResourceGroupName $connectivityResourceGroupOutputs.Outputs.resourceGroup_Name `
-TemplateFile .\ConnectivityBasicLinkedTemplate.json -TemplateParameterFile ..\Connectivity\ConnectivityBasicLinkedTemplate.parameters.json `
-_artifactsLocation $artifactsLocation `
-_artifactsLocationSasToken $artifactsKey
```

## Template spec 
WIP
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
