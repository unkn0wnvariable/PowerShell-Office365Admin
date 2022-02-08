# A simple script to get a list of all guest users from Azure AD along with a list of those who haven't accepted their invite within a set period
#

# How many days are we allowing for invites to be accepted?
$cutOffDays = 30

# Install the AzureAD module, uncomment if required
#Install-Module -Name AzureAD

# Import the AzureAD module and connect to Azure AD
Import-Module -Name AzureAD
Connect-AzureAD

# Get the cut off date
$cutOffDate = (Get-Date).AddDays(-$cutOffDays)

# Get a list of all guests from Azure AD and output it to CSV
$allGuests = Get-AzureADUser -All $true | Where-Object { $_.UserType -eq 'Guest' }
$allGuests | Select-Object DisplayName, Mail, MailNickName, RefreshTokensValidFromDateTime, UserState, UserStateChangedOn | Export-CSV -Path 'C:\Temp\AzureAD_AllGuests.csv'

# Filter guests list to those who haven't accepted their invite after the set period, and output the list to CSV
$oldUnacceptedInvites = $allGuests | Where-Object { $_.UserState -eq 'PendingAcceptance' -and $_.RefreshTokensValidFromDateTime -lt $cutOffDate }
$oldUnacceptedInvites | Select-Object DisplayName, Mail, MailNickName, RefreshTokensValidFromDateTime, UserState | Export-CSV -Path 'C:\Temp\AzureAD_Guests_StalePendingAcceptance.csv' -NoTypeInformation
