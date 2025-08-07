# Bulk change guest accounts from a certain domain so that they show in the Global Address List
#

# What domain are the guests email addresses from?
$guestDomain = ''

# Import module and connect to Exchange Online
Import-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline

# Find all the relevant users and enable them to show in the address list
Get-MailUser -ResultSize Unlimited | Where-Object {$_.RecipientTypeDetails -eq 'GuestMailUser' -and $_.EmailAddresses -match $guestDomain} | Set-MailUser -HiddenFromAddressListsEnabled $false

# Disconnect from Exchange Online
Disconnect-ExchangeOnline
