# Bulk add a new licence to users on the basis of what licence they currently have.
#
# An updated version of my previous MSOL script, now using AzureAD.
# This is useful for something like adding Office 365 ATP to everyone who currently has E3, for example.
#
# List of available SKUs can be obtained with (Get-AzureADSubscribedSku).SkuPartNumber
#

# What licence do the users currently have?
$existingLicence = 'ENTERPRISEPACK'

# What licence are we adding?
$licenceToAdd = 'ATP_ENTERPRISE'

# Import AzureAD module and connect
Import-Module AzureAD
Connect-AzureAD

# Get all available licence skus
$allSkus = Get-AzureADSubscribedSku

# Get sku ID for existing licence
$existingSkuID = ($allSkus | Where-Object {$_.SkuPartNumber -eq $existingLicence}).SkuId

# Get sku ID for new licence
$newSkuID = ($allSkus | Where-Object {$_.SkuPartNumber -eq $licenceToAdd}).SkuId

# Find everyone who has the existing licence
$users = Get-AzureADUser -All $true | Where-Object {$_.AssignedLicenses.SkuId -match $existingSkuID -and !($_.AssignedLicenses.SkuId -match $newSkuID)}

# Create a new licence object for the licence we're adding
$newLicense = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$newLicense.SkuId = $newSkuID

# Create a new assigned licenses object and add the licence we're adding to add licenses
$newLicenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$newLicenses.AddLicenses = $newLicense

# Add the new licence to each user in the list
foreach ($user in $users) {
    Set-AzureADUserLicense -ObjectId $user.UserPrincipalName -AssignedLicenses $newLicenses
}

# Disconnect from AzureAD
Disconnect-AzureAD
