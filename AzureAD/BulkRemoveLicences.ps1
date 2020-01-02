# Bulk remove licences to a list of users.
#
# List of available SKUs can be obtained with (Get-AzureADSubscribedSku).SkuPartNumber
#

# Where is the list of user UPN's?
$userListPath = 'C:\Temp\UserList.txt'

# What licences are we removing?
$licencesToRemove = @('ENTERPRISEPACK','ATP_ENTERPRISE','EMSPREMIUM')

# Import AzureAD module and connect
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
    try {
        $user = Get-AzureADUser -ObjectId $username -ErrorAction Stop
        if ($user.AccountEnabled -eq $true) {
            Set-AzureADUserLicense -ObjectId $user.UserPrincipalName -AssignedLicenses $licenses
            Write-Output -InputObject ('Licence(s) removed from user account ' + $user.UserPrincipalName + '.')
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
