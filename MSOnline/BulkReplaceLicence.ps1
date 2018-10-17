# Bulk replace a licence for all users who have the one being replaced.
#

# What licence are we removing?
$licenceToRemove = ''

# What licence are we adding?
$licenceToAdd = ''

# Import MSOnline module and connect
Import-Module MSOnline
Connect-MsolService

# Find everyone who has the existing licence but not the new one
$users = Get-MsolUser -All | Where-Object {(($_.licenses).AccountSkuId -match $licenceToRemove)}

# Remove the existing licence and add the new one
foreach ($user in $users) {
    Set-MSOLUserLicense –user $user.UserPrincipalName –RemoveLicenses $licenceToRemove -AddLicenses $licenceToAdd
}
