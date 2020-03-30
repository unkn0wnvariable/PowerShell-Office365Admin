# Script to bulk disable guest accounts in Azure AD, either all or for a specific domain
#

# Are we disabling for a specific guest domain? Leave blank for all guests.
$guestDomain = ''

# Install the AzureAD module, uncomment if required
#Install-Module -Name AzureAD

# Import the AzureAD module and connect to Azure AD
Import-Module -Name AzureAD
Connect-AzureAD

# Get a list of all guests from Azure AD either matching the domain or all guests
if ($guestDomain -ne '') {
    $guestAccounts = Get-AzureADUser -All $true | Where-Object { $_.AccountEnabled -eq $true -and $_.UserType -eq 'Guest' -and $_.Mail -like ('*' + $guestDomain) }
}
else {
    $guestAccounts = Get-AzureADUser -All $true | Where-Object { $_.AccountEnabled -eq $true -and $_.UserType -eq 'Guest' }
}

# Disable the guest accounts
try {
    $guestAccounts | Set-AzureADUser -AccountEnabled $false -ErrorAction Stop
    Write-Output -InputObject ('The specified guest accounts have been disabled.')
}
catch {
    Write-Output -InputObject ('Failed - The specified guest accounts have not been disabled.')
}
