# Disable MFA for all licenced users who currently have it enabled
#

# Import MSOnline module and connect
Import-Module MSOnline
Connect-MsolService

# Find all licenced users who currently have MFA enabled or enforced
$usersToChange = Get-MsolUser | Where-Object {$_.StrongAuthenticationRequirements.State -match 'Enabled|Enforced' -and $_.isLicensed -eq $true}

# Disable MFA for those users
$usersToChange | Set-MsolUser -StrongAuthenticationRequirements @()
