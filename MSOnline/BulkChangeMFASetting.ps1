# Bulk enable or disable MFA for all users in a tenant
#

# Enable or disable MFA?
$enableMFA = $true

# Import MSOnline module and connect
Import-Module MSOnline
Connect-MsolService

# Enable or disable MFA
if ($enableMFA) {
    # Create an object containing the authentication requirements
    $authReq = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement

    # Include all relying parties
    $authReq.RelyingParty = '*'

    # Set MFA state to enabled
    # Enabled allows connected apps to keep working until the user completes MFA set up.
    # This can also be set to enforced which would disconnect everything immediately.
    $authReq.State = 'Enabled'

    # Set the cut off date before which registered devices should require re-connecting with MFA.
    # Using the current date is recommended so that all previously connected devices have to be reconnected.
    $authReq.RememberDevicesNotIssuedBefore = (Get-Date)

    # Find all licenced users who do not currently have MFA enabled or enforced
    $usersToChange = Get-MsolUser | Where-Object {$_.StrongAuthenticationRequirements.State -notmatch 'Enabled|Enforced' -and $_.isLicensed -eq $true}

    # Enable MFA for those users
    $usersToChange | Set-MsolUser -StrongAuthenticationRequirements $authReq
}
else {
    # Find all licenced users who currently have MFA enabled or enforced
    $usersToChange = Get-MsolUser | Where-Object {$_.StrongAuthenticationRequirements.State -match 'Enabled|Enforced' -and $_.isLicensed -eq $true}

    # Disable MFA for those users
    $usersToChange | Set-MsolUser -StrongAuthenticationRequirements @()
}


