# Bulk remove licences to a list of users.
#
# List of available SKUs can be obtained with (Get-AzureADSubscribedSku).SkuPartNumber
#
# Removing licences with this module doesn't work in the way that Microsoft's documentation states.
# I'm assuming this is a bug, so the code below works at time of creation but may stop working in the future.
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

# Create a licenses object
$licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses

# Get SkuIDs for licence(s) to be removed
$licenses.RemoveLicenses = (Get-AzureADSubscribedSku | Where-Object {$_.SkuPartNumber -in $licencesToRemove}).SkuId

# Remove the licenses
foreach ($username in $userList) {
    $user = Get-AzureADUser -ObjectId $username
    if ($user.AccountEnabled -eq $true) {
        Set-AzureADUserLicense -ObjectId $user.UserPrincipalName -AssignedLicenses $licenses
        Write-Output -InputObject ('Licence remove from user account ' + $user.UserPrincipalName + '.')
    }
    else {
        Write-Output -InputObject ('User account ' + $user.UserPrincipalName + ' is disabled.')
    }
}

# Disconnect from AzureAD
Disconnect-AzureAD
