# Remove all licences from a list of users
#
# Removing licences with this module doesn't work in the way that Microsoft's documentation states.
# I'm assuming this is a bug, so the code below works at time of creation but may stop working in the future.
#

# Where is the list of user UPN's?
$userListPath = 'C:\Temp\UserList.txt'

# Import AzureAD module and connect
Import-Module AzureAD
Connect-AzureAD

# Import list of users from file
$userList = Get-Content -Path $userListPath | Sort-Object

# Remove all the licences
foreach ($username in $userList) {
    try {
        $user = Get-AzureADUser -ObjectId $username -ErrorAction Stop
        if ($user.AccountEnabled -eq $true) {
            if(($user.AssignedLicenses.SkuId).Count -ge 1) {
                $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
                $licenses.RemoveLicenses = (Get-AzureADSubscribedSku | Where-Object {$_.SkuId -in $user.AssignedLicenses.SkuId}).SkuId
                Set-AzureADUserLicense -ObjectId $user.UserPrincipalName -AssignedLicenses $licenses
                Write-Output -InputObject ('All licences removed from user account ' + $username + '.')
            }
            else {
                Write-Output -InputObject ('User account ' + $username + ' has no licences assigned.')
            }
        }
        else {
            Write-Output -InputObject ('User account ' + $username + ' is disabled.')
        }
    }
    catch {
        Write-Output -InputObject ('User account ' + $username + ' does not exist.')
    }
}

# Disconnect from AzureAD
Disconnect-AzureAD
