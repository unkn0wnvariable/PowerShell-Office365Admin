# Find shared mailboxes on the basis of their email domain and lists of who has access to them
#

# Where to save the CSV files to
$outputPath = 'C:\Temp\'

# Wildcard for mailboxes to find
$searchWildcard = '*'

# Import module and connect to Exchange Online
Import-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline

# Get all the mailboxes we're looking for
$sharedMailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited | Where-Object {$_.PrimarySmtpAddress -like $searchWildcard} | Select-Object Name,Alias,PrimarySmtpAddress,ProhibitSendQuota

# Export list of mailboxes to CSV File
$sharedMailboxes | Export-CSV -Path ($outputPath + 'Shared Mailboxes.csv') -NoTypeInformation

# Get all non-inherited permissions excluding self and output to a CSV file named for each group
foreach ($sharedMailbox in $sharedMailboxes) {
    $mailboxPermissions = Get-MailboxPermission -Identity $sharedMailbox.alias | Where-Object {$_.IsInherited -eq $false -and $_.User -ne 'NT AUTHORITY\SELF'} | Select-Object Identity,User,AccessRights,Deny
    $mailboxPermissions | Export-CSV -Path ($outputPath + $sharedMailbox.Name + '.csv') -NoTypeInformation
}

# Disconnect from Exchange Online
Disconnect-ExchangeOnline
