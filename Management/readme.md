# Azure Management deployment

[Home](../readme.md)

The template ManagementBasicLinkedTemplate.json deploys a log analytics workspace, key vault and Azure automatiom account.

You can deploy these templates using PowerShell or an Azure DevOps Pipeline; a working Azure DevOps Pipeline can be found [here](Pipeline/management.yml)

[![Build Status](https://dev.azure.com/heathen1878/MSDN/_apis/build/status/Management?branchName=master)](https://dev.azure.com/heathen1878/MSDN/_build/latest?definitionId=2&branchName=master)

<a href="https%3A%2F%2Fraw.githubusercontent.com%2Fheathen1878%2FARM-QuickStarts%2Fmaster%2FArtifacts%2FManagementLinkedTemplate.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>


### PowerShell

First of all you'll need to setup your [deployment](../Deploy/readme.md) store and templates.

Now everything is in place to start a deployment.

Create a resource group

```powershell
$managementResourceGroupOutputs = New-AzDeployment `
-Name (-Join("Deploy-Resource-Group-",(Get-Date).Day,"-",(Get-Date).Month,"-",(Get-Date).Year,"-",(Get-Date).Hour,(Get-Date).Minute))`
-Location "UK South" `
-TemplateFile .\Resource-Group.json -TemplateParameterFile ..\Management\Resource-Group.parameters.json
```

Run the deployment

```powershell
$managementOutputs = New-AzResourceGroupDeployment `
-Name (-Join("Deploy-Management-Basic-Linked-Template-",(Get-Date).Day,"-",(Get-Date).Month,"-",(Get-Date).Year,"-",(Get-Date).Hour,(Get-Date).Minute)) `
-ResourceGroupName $managementResourceGroupOutputs.Outputs.resourceGroup_Name.value `
-TemplateFile .\ManagementLinkedTemplate.json -TemplateParameterFile ..\Management\ManagementLinkedTemplate.parameters.json `
-_artifactsLocation $artifactsLocation `
-_artifactsLocationSasToken $artifactsKey
```

Configure the Azure Automation Account

```powershell
.\Automation-Account-RunAs.ps1 `
-ResourceGroupName $managementResourceGroupOutputs.Outputs.resourceGroup_Name.Value `
-AutomationAccount $managementOutputs.Outputs.automationAccount_Name.Value `
-KeyVaultName $managementOutputs.Outputs.keyVault_Name.Value
```