function GeneratePassword {
    param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(12, 256)]
        [int]
        $length = 14
    )

    $symbols = '!@#$%^&*'.ToCharArray()
    $characterList = 'a'..'z' + 'A'..'Z' + '0'..'9' + $symbols

    do {
        $password = ""
        for ($i = 0; $i -lt $length; $i++) {
            $randomIndex = [System.Security.Cryptography.RandomNumberGenerator]::GetInt32(0, $characterList.Length)
            $password += $characterList[$randomIndex]
        }

        [int]$hasLowerChar = $password -cmatch '[a-z]'
        [int]$hasUpperChar = $password -cmatch '[A-Z]'
        [int]$hasDigit = $password -match '[0-9]'
        [int]$hasSymbol = $password.IndexOfAny($symbols) -ne -1

    }
    until (($hasLowerChar + $hasUpperChar + $hasDigit + $hasSymbol) -ge 3)

    $password | ConvertTo-SecureString -AsPlainText
}

function addSecretToKeyVault {

  [CmdletBinding()]
  param (
    [Parameter(Mandatory, HelpMessage="The Key Vault name where the secret will be stored.")]
    [string]
    $kvName,
    [Parameter(Mandatory, HelpMessage="The name of the secret, this name will be used for retrieval.")]
    [string]
    $secretName,
    [Parameter(Mandatory, HelpMessage="The type of secret e.g. Username or Password")]
    [string]
    $secretType,
    [Parameter(Mandatory=$false, HelpMessage="Only required when the secret type is a username")]
    [string]
    $secretValue
  )

  If (!(Get-AzKeyVaultSecret -VaultName $kvName -Name $secretName)){
    # Create password if the secret is a password
    If ($secretType -eq "Password"){
      $Value = GeneratePassword -Length 16
    } Else {
      $value = ConvertTo-SecureString -String $secretValue -AsPlainText -Force
    }
    Set-AzKeyVaultSecret -VaultName $kvName -Name $secretName -SecretValue $value -ContentType $secretType | Out-Null
  }
}