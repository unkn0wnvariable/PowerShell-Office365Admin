# Reset default calendar permissions to availability for a list of users.
#
# Uses the new PowerShell "module" that support MFA.
#

# File with list of users
$userlistPath = 'C:\Temp\Userlist.txt'

# Find and load the new ExO "module"
$exoModulePath = (Get-ChildItem -Path $env:userprofile -Filter CreateExoPSSession.ps1 -Recurse -Force -ErrorAction SilentlyContinue).DirectoryName[-1]
. "$exoModulePath\CreateExoPSSession.ps1"

# Establish a session to Exchange Online
Connect-EXOPSSession

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

# End the Exchange Session
Get-PSSession | Where-Object {$_.ComputerName -eq 'outlook.office365.com'} | Remove-PSSession
