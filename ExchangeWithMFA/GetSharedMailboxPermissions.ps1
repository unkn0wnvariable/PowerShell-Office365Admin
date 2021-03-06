# Find shared mailboxes on the basis of their email domain and lists of who has access to them
#
# Uses the new PowerShell "module" that support MFA.
#

# Where to save the CSV files to
$outputPath = 'C:\Temp\'

# Wildcard for mailboxes to find
$searchWildcard = '*'

# Find and load the new ExO "module"
$exoModulePath = (Get-ChildItem -Path $env:userprofile -Filter CreateExoPSSession.ps1 -Recurse -Force -ErrorAction SilentlyContinue).DirectoryName[-1]
. "$exoModulePath\CreateExoPSSession.ps1"

# Establish a session to Exchange Online
Connect-EXOPSSession

# Get all the mailboxes we're looking for
$sharedMailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited | Where-Object {$_.PrimarySmtpAddress -like $searchWildcard} | Select-Object Name,Alias,PrimarySmtpAddress,ProhibitSendQuota

# Export list of mailboxes to CSV File
$sharedMailboxes | Export-CSV -Path ($outputPath + 'Shared Mailboxes.csv') -NoTypeInformation

# Get all non-inherited permissions excluding self and output to a CSV file named for each group
foreach ($sharedMailbox in $sharedMailboxes) {
    $mailboxPermissions = Get-MailboxPermission -Identity $sharedMailbox.alias | Where-Object {$_.IsInherited -eq $false -and $_.User -ne 'NT AUTHORITY\SELF'} | Select-Object Identity,User,AccessRights,Deny
    $mailboxPermissions | Export-CSV -Path ($outputPath + $sharedMailbox.Name + '.csv') -NoTypeInformation
}

# End the Exchange Session
Get-PSSession | Where-Object {$_.ComputerName -eq 'outlook.office365.com'} | Remove-PSSession
