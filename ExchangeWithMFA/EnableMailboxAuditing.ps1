# Enable mailbox auditing on mailboxes where auditing is not already enabled
#
# This is a rewrite of a script from https://github.com/OfficeDev/O365-InvestigationTooling
#

# Find and load the new ExO "module"
$exoModulePath = (Get-ChildItem -Path $env:userprofile -Filter CreateExoPSSession.ps1 -Recurse -Force -ErrorAction SilentlyContinue).DirectoryName[-1]
. "$exoModulePath\CreateExoPSSession.ps1"

# Establish a session to Exchange Online
Connect-EXOPSSession

# Set Auditing parameters
$params = @{
	'AuditEnabled' = $true
	'AuditLogAgeLimit' = '180'
	'AuditAdmin' = @('Update','MoveToDeletedItems','SoftDelete','HardDelete','SendAs','SendOnBehalf','Create','UpdateFolderPermission')
	'AuditDelegate' = @('Update','SoftDelete','HardDelete','SendAs','Create','UpdateFolderPermissions','MoveToDeletedItems','SendOnBehalf')
	'AuditOwner' = @('UpdateFolderPermission','MailboxLogin','Create','SoftDelete','HardDelete','Update','MoveToDeletedItems')
}

# Enable Auditing
Get-Mailbox -ResultSize Unlimited | Where-Object {$_.RecipientTypeDetails -match '(User|Shared|Room|Discovery)Mailbox' -and $_.AuditEnabled -eq $false} | Set-Mailbox @params

# Check Auditing
Get-Mailbox -ResultSize Unlimited | Where-Object {$_.RecipientTypeDetails -match '(User|Shared|Room|Discovery)Mailbox'} | Format-Table -AutoSize UserPrincipalName,RecipientTypeDetails,AuditEnabled,AuditLogAgeLimit

# Disconnect from Exchange Online
Remove-PSSession $exchangeSession
