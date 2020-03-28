# Find all guests with unaccepted invites over a specific time period and remove them
#

# How many days are we allowing for invites to be accepted? (This can be 0 for all)
$cutOffDays = 0

# Install the AzureAD module, uncomment if required
#Install-Module -Name AzureAD

# Import the AzureAD module and connect to Azure AD
Import-Module -Name AzureAD
Connect-AzureAD

# Get the cut off date
$cutOffDate = (Get-Date).AddDays(-$cutOffDays)

# Get a list of all guests with unaccepted invites older than the specificed timeframe
$unacceptedGuests = Get-AzureADUser -All $true | Where-Object { $_.UserType -eq 'Guest' -and  $_.UserState -eq 'PendingAcceptance' -and $_.RefreshTokensValidFromDateTime -lt $cutOffDate }

# Remove the guest accounts
$unacceptedGuests | Remove-AzureADUser
