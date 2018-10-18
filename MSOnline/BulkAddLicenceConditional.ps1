# Bulk add a new licence to users on the basis of what licence they currently have
#
# This is useful for something like adding Office 365 ATP to everyone who currently has E3, for example.
#

# What licence do the users currently have?
$existingLicence = ''

# What licence are we adding?
$licenceToAdd = ''

# Import MSOnline module and connect
Import-Module MSOnline
Connect-MsolService

# Find everyone who has the existing
$users = Get-MsolUser -All | Where-Object {($_.licenses).AccountSkuId -match $existingLicence -and !(($_.licenses).AccountSkuId -match $licenceToAdd)}

# Add the new licence
foreach ($user in $users) {
    Set-MSOLUserLicense –user $user.UserPrincipalName –AddLicenses $licenceToAdd
}
