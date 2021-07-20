[CmdletBinding()]
Param (
    [Parameter(Mandatory)]
    [string]$location
)

If ($location -In (Get-AzLocation).Location -or $Location -In (Get-AzLocation).DisplayName){
    Write-Output ('Location {0} valid' -f $location)
} else {    
    Write-Output ('Location {0} not valid' -f $location)
    Exit
}

$Publisher = Get-AzVMImagePublisher -Location $location | Select-Object PublisherName | Out-GridView -Title "Select the publisher you wish to use" -PassThru

$Offer = Get-AzVMImageOffer -Location $Location -PublisherName $Publisher.PublisherName | Select-Object Offer | Out-GridView -Title "Select the offer you wish to use" -PassThru

$sku = Get-AzVMImageSku -Location $location -PublisherName $Publisher.PublisherName -Offer $offer.Offer | Select-Object Skus | Out-GridView -Title "Select the sku you wish to use" -PassThru

Write-Output ('Update the parameters.json with:')
Write-Output ('"ImagePublisher": {{"value": "{0}"}}' -f $publisher)
Write-Output ('"ImageOffer": {{"value": "{0}"}}' -f $offer)
Write-Output ('"ImageSku": {{"value": "{0}"}}' -f $Sku)