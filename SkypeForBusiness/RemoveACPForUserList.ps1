# Script to bulk remove conferencing details for a list of users
#

# Where is the list of user UPN's?
$userListPath = 'C:\Temp\UserList.txt'

# Load the Skype Online Connector module
Import-Module SkypeOnlineConnector

# Establish a session to Exchange Online
$sfbSession = New-CsOnlineSession
Import-PSSession -Session $sfbSession -AllowClobber

# Import list of users from file
$userList = Get-Content -Path $userListPath | Sort-Object

# Get CS Online user identities for all the users in the list
$csOnlineUsers = (Get-CsOnlineUser -WarningAction SilentlyContinue | Where-Object {$_.UserPrincipalName -in $userList}).Identity

# Run through the users and remove their ACP info
foreach ($csOnlineUser in $csOnlineUsers) {
    Remove-CsUserAcp -Identity $csOnlineUser
}

# End the PS Session
Remove-PSSession -Session $sfbSession
