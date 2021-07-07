# Quickstart templates

## Template Specs
To deploy a template specs first create a resource group using the New-AzDeployment cmdlet e.g.
```powershell
New-AzDeployment `
-Name (-Join("Deploy-Resource-Group-",(Get-Date).Day,"-",(Get-Date).Month,"-",(Get-Date).Year,"-",(Get-Date).Hour,(Get-Date).Minute))`
-Location "UK South" `
-TemplateFile .\Artifacts\Resource-Group.json -TemplateParameterFile .\GitHub\ARM-QuickStarts\Artifacts\Resource-Group.parameters.json
```

