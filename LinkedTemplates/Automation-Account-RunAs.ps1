<#
    .SYNOPSIS
        Create Azure Application, Certificate, SP and link them to Azure Automation Account as Run As Account

    .DESCRIPTION
        Create Azure Application, Certificate, SP and link them to Azure Automation Account as Run As Account

    .PARAMETER ResourceGroupName
        Name of the resource group where are located Automation Account and Keyvault
    .PARAMETER AutomationAccount
        Automation Account Name
    .PARAMETER KeyVaultName
        Keyvault name

    .NOTES
        This script is taken from https://gist.github.com/omiossec/e64ec646668d8dda05502f07f9dbf11a
        Author:         https://gist.github.com/omiossec
        Creation Date:  26/10/2020

    .EXAMPLE
        .\1.3-Azure-Automation-RunAs-Account.ps1 `
            -ResourceGroupName "Resource Group Where Key Vault and Automation exist" `
            -AutomationAccount "Automation Account Name" `
            -KeyVaultName "Key Vault Name"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory)]
    [string]$AutomationAccount,
    [Parameter(Mandatory)]
    [string]$KeyVaultName
)

# Variables
$RunAsAccountName = (-Join($AutomationAccount,"-RUNAS"))
$CertificateSubjectName = (-Join("CN=",$RunAsAccountName))
$AzAppUniqueId = (New-Guid).Guid
$AzAdAppURI = (-Join("http://",$AutomationAccount,$AzAppUniqueId))

# Create a certificate and add it to Key
$AzureKeyVaultCertificatePolicy = New-AzKeyVaultCertificatePolicy -SubjectName $CertificateSubjectName -IssuerName "Self" -KeyType "RSA" `
-KeyUsage "DigitalSignature" -ValidityInMonths 12 -RenewAtNumberOfDaysBeforeExpiry 20 -KeyNotExportable:$False -ReuseKeyOnRenewal:$False

# Add the certificate to Key Vault
If (!(Get-AzKeyVaultCertificate -VaultName $keyvaultName -Name $RunAsAccountName)){
    Add-AzKeyVaultCertificate -VaultName $keyvaultName -Name $RunAsAccountName -CertificatePolicy $AzureKeyVaultCertificatePolicy | out-null

    Do {
        start-sleep -Seconds 20
    } Until ((Get-AzKeyVaultCertificateOperation -Name $RunAsAccountName -vaultName $keyvaultName).Status -eq "Completed")
}

# Create a password for the pfx export
$PfxPassword = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 48| foreach-object {[char]$_})
$PfxFilePath = join-path -Path (get-location).path -ChildPath "cert.pfx"

start-sleep 30

# Export the certificate secret
$AzKeyVaultCertificateSecret = Get-AzKeyVaultSecret -VaultName $keyvaultName -Name $RunAsAccountName

# Convert the certificate secret to a base64
$AzKeyVaultCertificateSecretBytes = [System.Convert]::FromBase64String($AzKeyVaultCertificateSecret.SecretValueText)

$certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
$certCollection.Import($AzKeyVaultCertificateSecretBytes,$null,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)

$protectedCertificateBytes = $certCollection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, $PfxPassword)
[System.IO.File]::WriteAllBytes($PfxFilePath, $protectedCertificateBytes)

If (!(Get-AzADApplication -DisplayName $RunAsAccountName)){
    $AzADApplicationRegistration = New-AzADApplication -DisplayName $RunAsAccountName -HomePage (-Join("http://",$RunAsAccountName)) -IdentifierUris $AzAdAppURI

    $AzKeyVaultCertificateStringValue = [System.Convert]::ToBase64String($certCollection.GetRawCertData())

    start-sleep -Seconds 30

    $AzADApplicationCredential = New-AzADAppCredential -ApplicationId $AzADApplicationRegistration.ApplicationId `
    -CertValue $AzKeyVaultCertificateStringValue -StartDate $certCollection.NotBefore -EndDate $certCollection.NotAfter

    $AzADServicePrincipal = New-AzADServicePrincipal -ApplicationId $AzADApplicationRegistration.ApplicationId -SkipAssignment
} Else {
    $AzADApplicationRegistration = Get-AzADApplication -DisplayName $RunAsAccountName

    If (!(Get-AzADServicePrincipal -DisplayName $RunAsAccountName)){

        $AzKeyVaultCertificateStringValue = [System.Convert]::ToBase64String($certCollection.GetRawCertData())

        start-sleep -Seconds 30

        $AzADApplicationCredential = New-AzADAppCredential -ApplicationId $AzADApplicationRegistration.ApplicationId `
        -CertValue $AzKeyVaultCertificateStringValue -StartDate $certCollection.NotBefore -EndDate $certCollection.NotAfter

        $AzADServicePrincipal = New-AzADServicePrincipal -ApplicationId $AzADApplicationRegistration.ApplicationId -SkipAssignment

    } Else {

        $AzADServicePrincipal = Get-AzADServicePrincipal -DisplayName $RunAsAccountName

    }
}

Try {
    Get-AzAutomationCertificate -ResourcegroupName $ResourceGroupName -AutomationAccountName $AutomationAccount -Name "AzureRunAsCertificate" -ErrorAction Stop | Out-Null
}
Catch {
    $PfxPassword = ConvertTo-SecureString $PfxPassword -AsPlainText -Force

    New-AzAutomationCertificate -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccount -Path $PfxFilePath `
    -Name "AzureRunAsCertificate" -Password $PfxPassword -Exportable:$Exportabl | Out-Null
}

Try {
    Get-AzAutomationConnection -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccount -Name "AzureRunAsConnection" -ErrorAction Stop | Out-Null
}
Catch {

    $ConnectionFieldData = @{
        "ApplicationId" = $AzADApplicationRegistration.ApplicationId
        "TenantId" = (Get-AzContext).Tenant.ID
        "CertificateThumbprint" = $certCollection.Thumbprint
        "SubscriptionId" = (Get-AzContext).Subscription.ID
    }

    New-AzAutomationConnection -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccount -Name "AzureRunAsConnection" -ConnectionTypeName "AzureServicePrincipal" -ConnectionFieldValues $ConnectionFieldData | Out-Null

}

start-sleep -Seconds 30

If (!(Get-AzRoleAssignment -ResourceGroupName $resourceGroupName | Where-Object {$_.DisplayName -eq $RunAsAccountName})){
    New-AzRoleAssignment -ResourceGroupName $ResourceGroupName -ApplicationId $AzADServicePrincipal.ApplicationId -RoleDefinitionName "Contributor" | Out-Null
}