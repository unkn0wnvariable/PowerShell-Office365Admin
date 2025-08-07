# Reset default calendar permissions to availability for a list of users.
#

# File with list of users
$userlistPath = 'C:\Temp\Userlist.txt'

# Import module and connect to Exchange Online
Import-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline

# Get list of users
$userlist = Get-Content -Path $userlistPath

# Get mailboxes for users in list
$mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object {$_.Name -in $userlist} | Sort-Object -Property Name

# Check the mailboxes and reset any which have default permissions of None to AvailabilityOnly
foreach ($mailbox in $mailboxes) {
    $calendarPath = $mailbox.UserPrincipalName + ':\Calendar'
    $defaultPermissions = Get-MailboxFolderPermission -Identity $calendarPath -User 'Default'
    if ($defaultPermissions.AccessRights -eq 'None') {
        Set-MailboxFolderPermission -Identity $calendarPath -User 'Default' -AccessRights AvailabilityOnly
    }
}

# Disconnect from Exchange Online
Disconnect-ExchangeOnline
