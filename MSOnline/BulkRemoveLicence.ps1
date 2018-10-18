# Bulk remove a licence from users
#

# What licence are we removing?
$licenceToRemove = ''

# Import MSOnline module and connect
Import-Module MSOnline
Connect-MsolService

# Find everyone who has the licence to be removed
$users = Get-MsolUser -All | Where-Object {($_.licenses).AccountSkuId -match $licenceToRemove}

# Remove the licence
foreach ($user in $users) {
    Set-MSOLUserLicense –user $user.UserPrincipalName –RemoveLicenses $licenceToRemove
}
