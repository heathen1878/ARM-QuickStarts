<#
    .SYNOPSIS
        Creates an Azure AD application with an associated Service Principal and assigns the Azure AD application API permissions
        and adds the associated Service Principal to the Application Administrators role.

    .NOTES
        Version:        1.0.0.0
        Author:         Dom Clayton
        Creation Date:  30/12/2020
        Updated:        17/03/2021

    .EXAMPLE
        Azure-DevOps-Service-Connection.ps1

#>

#Requires -Version 5.1
#Requires -Modules @{ModuleName="AzureAD"; ModuleVersion="2.0.2.128"}
#Requires -Modules @{ModuleName="Az.Accounts"; ModuleVersion="2.2.3"}


# Connect to Azure AD
Connect-AzureAD | Out-Null

$AADId = (Get-AzureADTenantDetail).ObjectId

# Create an Azure AD application which the service principal will use, check
# if it exists first.
If (!(Get-AzureADApplication -SearchString "PipelineDeployment")){
    $aadApp = New-AzureADApplication -DisplayName "PipelineDeployment" `
        -Homepage "https://localhost" `
        -ReplyUrls "https://localhost" `
} Else {
    $aadApp = Get-AzureADApplication -SearchString "PipelineDeployment"
}

# Create the service principal for the pipeline if it doesn't already exist
if (!(Get-AzureADServicePrincipal -SearchString "PipelineDeployment")){

    # Create a password
    $aadAppPwd = New-AzureADApplicationPasswordCredential -ObjectId $aadApp.ObjectId -CustomKeyIdentifier "ConnectFromAzureDevOps"

    $aadSp = New-AzureADServicePrincipal -AppId $aadApp.AppId -PasswordCredentials @($aadAppPwd)

} Else {

    $aadSp = Get-AzureADServicePrincipal -SearchString "PipelineDeployment"

}

# Get permissions for Microsoft Graph and Windows Azure Active Directory
$waad = Get-AzureADServicePrincipal -All $true | Where-Object {$_.DisplayName -eq "Windows Azure Active Directory"}

$msgraph = Get-AzureADServicePrincipal -All $true | Where-Object {$_.DisplayName -eq "Microsoft Graph"}

$waadAPIperms = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
$waadAPIperms.ResourceAppId = $waad.AppId

$msgraphAPIPerms = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
$msgraphAPIPerms.ResourceAppId = $msgraph.AppId

# Application.ReadWrite.OwnedBy
$waadApplicationPerm = New-Object -Typename "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "824c81eb-e3f8-4ee6-8f6d-de7f50d565b7","Role"
# User.Read
$msgraphDelegatedPerm1 = New-Object -Typename "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "e1fe6dd8-ba31-4d61-89e7-88639da4683d","Scope"
# Directory.AccessAsUser.All
$msgraphDelegatedPerm2 = New-Object -Typename "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "0e263e50-5827-48a4-b97c-d940288653c7","Scope"
# Directory.ReadWrite.All
$msgraphDelegatedPerm3 = New-Object -Typename "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "c5366453-9fb0-48a5-a156-24f0c49a4b84","Scope"

$waadAPIperms.ResourceAccess = $waadApplicationPerm
$msgraphAPIPerms.ResourceAccess = $msgraphDelegatedPerm1, $msgraphDelegatedPerm2, $msgraphDelegatedPerm3

Set-AzureADApplication -ObjectId $aadApp.ObjectId -RequiredResourceAccess @($waadAPIperms, $msgraphAPIPerms)

# First enable the role O_o - if it isn't already enabled
If (-Not (Get-AzureADDirectoryRole -Filter "DisplayName eq 'Application Administrator'")){
    $appAdmin = Get-AzureADDirectoryRoleTemplate | Where-Object {$_.DisplayName -eq "Application Administrator"}
    Enable-AzureADDirectoryRole -RoleTemplateId $appAdmin.ObjectId
}

# Add the Service Principal to the Application Administrator role
Try {
    Add-AzureADDirectoryRoleMember -ObjectId (Get-AzureADDirectoryRole -Filter "DisplayName eq 'Application Administrator'").ObjectId -RefObjectId $aadsp.ObjectId
}
Catch {
    Write-Warning $Error[0].Exception.Message
}


# Disconnect from AzureAD
Disconnect-AzureAD | Out-Null

Write-Output -InputObject ('Disconnecting from Azure AD')
Start-Sleep -Seconds 15

# Connect to Azure
Connect-AzAccount | Out-Null

# Grant the Service Principal owner rights on the subscription. Owner is required to apply RBAC from the DevOps Pipeline.
Try {
    New-AzRoleAssignment -ObjectId $aadSp.objectId -RoleDefinitionName "owner" -Scope (-join("/subscriptions/",(Get-AzContext).Subscription.Id)) -ErrorAction Stop | Out-Null
}
Catch {
    Write-Warning $Error[0].Exception.Message
}


Disconnect-AzAccount | Out-Null

### Output information ###
Write-Output -InputObject ('The service principal Id: {0}' -f $aadSp.AppId)
Write-Output -InputObject ('The service principal key: {0}' -f $aadAppPwd.value)
Write-Output -InputObject ('The Azure AD tenant Id: {0}' -f $aadId)
Write-Output -InputObject ('The API permissions granted within this script will more than likely need approving by an administrator within the portal')