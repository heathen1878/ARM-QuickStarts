# Deploy

This is used for linked templates 

```powershell
$deployResourceGroupOutputs = New-AzDeployment `
-Name (-Join("Deploy-Resource-Group-",(Get-Date).Day,"-",(Get-Date).Month,"-",(Get-Date).Year,"-",(Get-Date).Hour,(Get-Date).Minute))`
-Location "UK South" `
-TemplateFile .\Resource-Group.json -TemplateParameterFile ..\Deploy\Resource-Group.parameters.json
```

Then you'll need to deploy a storage account to store the ARM artifacts - this is because the template references other ARM templates and those templates must be accessible to the Azure Resource Manager.

```powershell
$storageAccountOutputs = New-AzResourceGroupDeployment `
-Name (-Join("Deploy-Storage-Account-",(Get-Date).Day,"-",(Get-Date).Month,"-",(Get-Date).Year,"-",(Get-Date).Hour,(Get-Date).Minute)) `
-Location "UK South" `
-ResourceGroup $deployResourceGroupOutputs.Outputs.resourceGroup_Name.value `
-TemplateFile .\Storage-Account.json -TemplateParameterFile ..\Deploy\Storage-Account.parameters.json
```

Once the storage account is created, upload the artifacts directory into a container - you'll see i've named the container templates and concatenated with the 
BlobEndPoint property.

Then using PowerShell you can generate a SAS Token and deploy the template

```powershell
$context = `
(Get-AzStorageAccount `
-ResourceGroupName $storageAccountOutputs.Outputs.storageAccount_Id.value.split('/')[4] `
-StorageAccountName $storageAccountOutputs.Outputs.storageAccount_Id.value.split('/')[8]).Context

# This generate a SAS token which is valid for 1 hour but starts 1 hour prior to the current time.
$sasToken = New-AzStorageAccountSASToken `
-Context $context `
-Service Blob `
-ResourceType service,container,object `
-Permission r `
-StartTime (Get-Date).AddHours(-1) `
-ExpiryTime (Get-Date).AddHours(2)

$artifactsKey = ConvertTo-SecureString -String $sasToken -AsPlainText -Force
$artifactsLocation = (-join($context.BlobEndPoint, "templates/"))
```