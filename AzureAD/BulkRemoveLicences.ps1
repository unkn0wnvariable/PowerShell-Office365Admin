# Bulk remove licences to a list of users.
#
# List of available SKUs can be obtained with (Get-AzureADSubscribedSku).SkuPartNumber
#

# Where is the list of user UPN's?
$userListPath = 'C:\Temp\UserList.txt'

# What licences are we removing?
$licencesToRemove = @('MCOMEETADV')

# Import MSOnline module and connect
Import-Module AzureAD
Connect-AzureAD

# Import list of users from file
$userList = Get-Content -Path $userListPath | Sort-Object

# Get user details from AzureAD
$users = Get-AzureADUser -All $true | Where-Object {$_.UserPrincipalName -in $userList}

# Get all available licence skus
$skuIDs = (Get-AzureADSubscribedSku | Where-Object {$_.SkuPartNumber -in $licencesToRemove}).SkuId

$licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses

foreach ($skuID in $skuIDs) {
    $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
    $license.SkuId = $skuID
    $licenses.RemoveLicenses += $license
}

# Add the new licence
foreach ($user in $users) {
    if ($user.AccountEnabled -eq $true) {
        Set-AzureADUserLicense -ObjectId $user.UserPrincipalName -AssignedLicenses $licenses
        Write-Output -InputObject ('Licence remove to user account ' + $user.UserPrincipalName + '.')
    }
    else {
        Write-Output -InputObject ('User account ' + $user.UserPrincipalName + ' is disabled.')
    }
}

# Disconnect from AzureAD
Disconnect-AzureAD
