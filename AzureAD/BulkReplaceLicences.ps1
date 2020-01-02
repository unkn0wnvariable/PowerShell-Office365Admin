# Bulk replace licences to a list of users.
#
# List of available SKUs can be obtained with (Get-AzureADSubscribedSku).SkuPartNumber
#

# Where is the list of user UPN's?
$userListPath = 'C:\Temp\UserList.txt'

# What licences are we adding?
$licencesToAdd = @('EMSPREMIUM')

# What licences are we removing?
$licencesToRemove = @('EMS','AAD_PREMIUM_P2')

# Import AzureAD module and connect
Import-Module AzureAD
Connect-AzureAD

# Import list of users from file
$userList = Get-Content -Path $userListPath | Sort-Object

$userList = @('OAndrewsAdmin@sis.tv')

# Get all available licence skus
$newSkuIDs = (Get-AzureADSubscribedSku | Where-Object {$_.SkuPartNumber -in $licencesToAdd}).SkuId

# Create a licenses object
$licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses

# Add the licences to add to the licences object
foreach ($newSkuID in $newSkuIDs) {
    $newLicense = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
    $newLicense.SkuId = $newSkuID
    $licenses.AddLicenses += $newLicense
}

# Add the licences we want to remove to the $licenses object
$licenses.RemoveLicenses =  (Get-AzureADSubscribedSku | Where-Object {$_.SkuPartNumber -in $licencesToRemove}).SkuID

# Replace the licenses
foreach ($username in $userList) {
    try {
        $user = Get-AzureADUser -ObjectId $username -ErrorAction Stop
        if ($user.AccountEnabled -eq $true) {
            Set-AzureADUserLicense -ObjectId $user.UserPrincipalName -AssignedLicenses $licenses
            Write-Output -InputObject ('Licences updated for user account ' + $user.UserPrincipalName + '.')
        }
        else {
            Write-Output -InputObject ('User account ' + $user.UserPrincipalName + ' is disabled.')
        }
    }
    catch {
        Write-Output -InputObject ('There was a problem updating licences for user account ' + $user.UserPrincipalName + '.')
        Write-Output -InputObject $Error[0]
    }
}

# Disconnect from AzureAD
Disconnect-AzureAD
