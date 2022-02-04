# Find mailboxes where UPN domain doesn't match email domain
#

# Establish a session to Exchange Online
Import-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline

# Get list of mailboxes with a different mail domain to UPN domain
$mismatchedMailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object { $_.UserPrincipalName.Split('@')[1] -ne $_.PrimarySmtpAddress.Split('@')[1] }

# Output as table
$mismatchedMailboxes | Format-Table -Property Name, UserPrincipalName, PrimarySmtpAddress, RecipientTypeDetails -AutoSize

# Disconnect from Exchange Online
Disconnect-ExchangeOnline
