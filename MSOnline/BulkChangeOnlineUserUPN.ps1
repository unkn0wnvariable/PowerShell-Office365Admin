# Bulk update Online User UPNs
#

# What domain are we replacing?
$oldDomain = ''

# What are we replacing it with?
$newDomain = ''

# Import the MSOnline module and connect
Import-Module MSOnline
Connect-MsolService

# Get all users using that domain as their UPN
$users = Get-MsolUser -All | Where-Object {$_.UserPrincipalName -match $oldDomain}

# Run through the users replacing their UPN and keeping us updated on what's going on
foreach ($user in $users) {
    $newUPN = $user.UserPrincipalName.Split('@')[0] + '@' + $newDomain
    Write-Output -InputObject ('Setting UPN for user ' + $user.UserPrincipalName + ' to ' + $newUPN)
    Set-MsolUserPrincipalName -UserPrincipalName $user.UserPrincipalName -NewUserPrincipalName $newUPN
}
