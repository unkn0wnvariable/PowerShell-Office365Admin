# Bulk add additional licences to a list of users where they already have a licence assigned.
#
# Only works where the user already has a licence assigned as assigning a licence to an unlicenced user is a different process
#

# Where is the list of user UPN's?
$userListPath = 'C:\Temp\UserList.txt'

# What licences are we adding?
# List of available SKUs can be obtained with (Get-MsolAccountSku).AccountSkuId
$licencesToAdd = @('','')

# Import MSOnline module and connect
Import-Module MSOnline
Connect-MsolService

# Import list of users from file
$users = Get-Content -Path $userListPath | Sort-Object

# Add the new licence
foreach ($user in $users) {
    $userDetails = Get-MSOLUser -UserPrincipalName $user
    foreach ($licenceToAdd in $licencesToAdd) {
        if ($userDetails.IsLicensed -eq $true) {
            if (!(($userDetails.licenses).AccountSkuId -match $licenceToAdd)) {
                Write-Output -InputObject ('Adding Licence ' + $licenceToAdd + ' to ' + $user + '.')
                Set-MSOLUserLicense -UserPrincipalName $user –AddLicenses $licenceToAdd
            }
            else {
                Write-Output -InputObject ('User ' + $user + ' already has ' + $licenceToAdd + ' licence assigned.')
            }
        }
        else {
            Write-Output -InputObject ('User ' + $user + ' has no existing licence assigned.')
        }
    }
}
