# Enable mailbox auditing and disable PowerShell remoting on individual mailboxes
#
# Working on this as a one stop for hardening Exchange Online accounts
#

# UPN of New User
$newUPN = ''

# Is the user an administrator?
$isAnAdmin = $false

# Establish a session to Exchange Online
Import-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline

# Set Auditing parameters
$params = @{
	'AuditEnabled' = $true
	'AuditLogAgeLimit' = '180'
	'AuditAdmin' = @('Update','MoveToDeletedItems','SoftDelete','HardDelete','SendAs','SendOnBehalf','Create','UpdateFolderPermission')
	'AuditDelegate' = @('Update','SoftDelete','HardDelete','SendAs','Create','UpdateFolderPermissions','MoveToDeletedItems','SendOnBehalf')
	'AuditOwner' = @('UpdateFolderPermission','MailboxLogin','Create','SoftDelete','HardDelete','Update','MoveToDeletedItems')
}

# Enable Auditing
Get-Mailbox -Identity $newUPN | Set-Mailbox @params

# Disable PowerShell Remoting for non-Admin staff
if ($isAnAdmin) {
	Set-User -Identity $newUPN -RemotePowerShellEnabled $true
}
else {
	Set-User -Identity $newUPN -RemotePowerShellEnabled $false
}

# Disconnect from Exchange Online
Disconnect-ExchangeOnline
