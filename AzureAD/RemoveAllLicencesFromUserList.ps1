# Remove all licences from a list of users
#

# Where is the list of user UPN's?
$userListPath = 'C:\Temp\UserList.txt'

# Import MSOnline module and connect
Import-Module AzureAD
Connect-AzureAD

# Import list of users from file
$userList = Get-Content -Path $userListPath | Sort-Object

# Get user details from AzureAD
$users = Get-AzureADUser -All $true | Where-Object {$_.UserPrincipalName -in $userList}

# Remove all the licences
foreach ($user in $users) {
    if ($user.AccountEnabled -eq $true) {
        $skuIDs = (Get-AzureADSubscribedSku | Where-Object {$_.SkuId -in $users.AssignedLicenses.SkuId}).SkuId
        $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        foreach ($skuID in $skuIDs) {
            $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
            $license.SkuId = $skuID
            $licenses.RemoveLicenses += $license
        }
        Set-AzureADUserLicense -ObjectId $user.UserPrincipalName -AssignedLicenses $licenses
        Write-Output -InputObject ('All licences removed from user account ' + $user.UserPrincipalName + '.')
    }
    else {
        Write-Output -InputObject ('User account ' + $user.UserPrincipalName + ' is disabled.')
    }
}

# Disconnect from AzureAD
Disconnect-AzureAD
