function New-Password {
  <#
  .SYNOPSIS
      Generate a random password.
  .DESCRIPTION
      Generate a random password.
  .NOTES
      Change log:
          27/11/2017 - faustonascimento - Swapped Get-Random for System.Random.
                                          Swapped Sort-Object for Fisher-Yates shuffle.
          17/03/2017 - Chris Dent - Created.

          Taken from here: https://gist.github.com/indented-automation/2093bd088d59b362ec2a5b81a14ba84e
  #>

  [CmdletBinding()]
  [OutputType([String])]
  param (
      # The length of the password which should be created.
      [Parameter(ValueFromPipeline)]        
      [ValidateRange(8, 255)]
      [Int32]$Length = 10,

      # The character sets the password may contain. A password will contain at least one of each of the characters.
      [String[]]$CharacterSet = ('abcdefghijklmnopqrstuvwxyz',
                                 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                                 '0123456789',
                                 '!$%&^#@*'),
                                  

      # The number of characters to select from each character set.
      [Int32[]]$CharacterSetCount = (@(1) * $CharacterSet.Count)
  )

  begin {
      $bytes = [Byte[]]::new(4)
      $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
      $rng.GetBytes($bytes)

      $seed = [System.BitConverter]::ToInt32($bytes, 0)
      $rnd = [Random]::new($seed)

      if ($CharacterSet.Count -ne $CharacterSetCount.Count) {
          throw "The number of items in -CharacterSet needs to match the number of items in -CharacterSetCount"
      }

      $allCharacterSets = [String]::Concat($CharacterSet)
  }

  process {
      try {
          $requiredCharLength = 0
          foreach ($i in $CharacterSetCount) {
              $requiredCharLength += $i
          }

          if ($requiredCharLength -gt $Length) {
              throw "The sum of characters specified by CharacterSetCount is higher than the desired password length"
          }

          $password = [Char[]]::new($Length)
          $index = 0
      
          for ($i = 0; $i -lt $CharacterSet.Count; $i++) {
              for ($j = 0; $j -lt $CharacterSetCount[$i]; $j++) {
                  $password[$index++] = $CharacterSet[$i][$rnd.Next($CharacterSet[$i].Length)]
              }
          }

          for ($i = $index; $i -lt $Length; $i++) {
              $password[$index++] = $allCharacterSets[$rnd.Next($allCharacterSets.Length)]
          }

          # Fisher-Yates shuffle
          for ($i = $Length; $i -gt 0; $i--) {
              $n = $i - 1
              $m = $rnd.Next($i)
              $j = $password[$m]
              $password[$m] = $password[$n]
              $password[$n] = $j
          }

          [String]::new($password)
      } catch {
          Write-Error -ErrorRecord $_
      }
  }
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
        $secretValue = New-Password -Length 16
        $value = ConvertTo-SecureString -String $secretValue -AsPlainText -Force
    } Else {
      $value = ConvertTo-SecureString -String $secretValue -AsPlainText -Force
    }
    Set-AzKeyVaultSecret -VaultName $kvName -Name $secretName -SecretValue $value -ContentType $secretType | Out-Null
  }
}