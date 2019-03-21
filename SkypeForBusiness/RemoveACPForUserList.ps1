# Script to bulk remove 3rd party conferencing details for all users
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

# Run through the users and remove their ACP info
foreach ($user in $userList) {
    Remove-CsUserAcp -Identity $user
}

# End the PS Session
Remove-PSSession -Session $sfbSession
