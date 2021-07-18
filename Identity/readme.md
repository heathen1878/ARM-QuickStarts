# Identity 

[Home](../readme.md)

The templates used here deploy the following:

* Subnet
* Storage account for boot diagnostics
* Key vault
* Network Security Group with default ruleset
* Creates secrets as specified
* One or more virtual machines 

The prerequisites for this template are: 

* [Virtual Network](../Connectivity/readme.md)
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

Create a storage account for boot diagnostics, key vault, and network security group.

```powershell
$vmPrereqs = New-AzResourceGroupDeployment -Name (-Join("Virtual-Machine-Prereqs-Basic-Linked-Template-",(Get-Date).Day,"-",(Get-Date).Month,"-",(Get-Date).Year,"-",(Get-Date).Hour,(Get-Date).Minute)) `
-ResourceGroupName $resourceGroupOutputs.Outputs.resourceGroupName.value `
-TemplateFile .\VirtualMachinePrereqsBasicLinkedTemplate.json `
-TemplateParameterFile ..\Identity\VirtualMachinePrereqsBasicLinkedTemplate.parameters.json `
-_artifactsLocation $artifactsLocation `
-_artifactsLocationSasToken $artifactsKey
```

Create some credentials for the VM deployment. The functions PowerShell script contains two functions; the first function generates a password and the second function uses the GeneratePassword function and adds the secrets to tke key vault.

```powershell
.\functions\functions.ps1

addSecretToKeyVault -kvName $vmPrereqs.Outputs.keyVault_Name.value -secretName "builtInAdmin-Username" -secretType "Username" -secretValue "local_admin"
addSecretToKeyVault -kvName $vmPrereqs.Outputs.keyVault_Name.value -secretName "builtInAdmin-Password" -secretType "Password"

# Retrieve the values from the key vault or add these the parameter file
Write-Output ('Add this as the Key Vault Id: {0} for the adminUsername and adminPassword parameters.' -f $vmPrereqs.Outputs.keyVault_Id.value)
Write-Output ('Add this as the adminUsername secret name')
Write-Output ('Add this as the adminPassword secret name')

$adminUsername = Get-AzKeyVaultSecret `
-VaultName $vmPrereqs.Outputs.keyVault_Name.value `
-Name "builtInAdmin-Username" `
-AsPlainText

$adminPassword = Get-AzKeyVaultSecret `
-VaultName $vmPrereqs.Outputs.keyVault_Name.value `
-Name "builtInAdmin-Password"
```

Create one or more virtual machines. The template here can be used to deploy the following customisations:

* Dynamic or Static IP addresses
* Set the offSet for the IP Address e.g. start addressing from .10 within a subnet where a subnet can use .10 i.e. 192.168.0.0/24.
* Windows Client or Windows Server OS
* One or more data disks if required
* 


```powershell
New-AzResourceGroupDeployment -Name (-Join("Virtual-Machine-Marketplace-Image-",(Get-Date).Day,"-",(Get-Date).Month,"-",(Get-Date).Year,"-",(Get-Date).Hour,(Get-Date).Minute)) `
-ResourceGroupName $resourceGroupOutputs.Outputs.resourceGroupName.value `
-TemplateFile .\Virtual-Machine-Marketplace-Image.json `
-TemplateParameterFile ..\Identity\Virtual-Machine-Marketplace-Image.parameters.json `
-subnetId $subnetOutputs.Outputs.subnet_Id.value `
-subnetAddressPrefix $subnetOutputs.Outputs.subnet_IP_Range.value `
-adminUsername $adminUsername `
-adminPassword $adminPassword
```
