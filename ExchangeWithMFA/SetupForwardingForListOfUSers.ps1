# A simple script to enable forwarding for a list of users from a CSV file
#
# The script is expecting the CSV file to have two columns called SourceAddress and DestinationAddress
#

# Get the list of users from a CSV file
$userList = Import-Csv -Path 'C:\Temp\UserList.csv'

# Find and load the new ExO "module"
$exoModulePath = (Get-ChildItem -Path $env:userprofile -Filter CreateExoPSSession.ps1 -Recurse -Force -ErrorAction SilentlyContinue).DirectoryName[-1]
. "$exoModulePath\CreateExoPSSession.ps1"

# Establish a session to Exchange Online
Connect-EXOPSSession

# Get all non-inherited permissions excluding self and output to a CSV file named for each group
foreach ($user in $userList) {
    Write-Output -InputObject ('Forwarding ' + $user.SourceAddress + ' to ' + $user.DestinationAddress)
    Set-Mailbox -Identity $user.SourceAddress -ForwardingSmtpAddress $user.DestinationAddress
}

# Pull back a list to check everything has worked correctly
foreach ($user in $userList) {
    Get-Mailbox -Identity $user.SourceAddress | Select-Object UserPrincipalName,ForwardingSmtpAddress,DeliverToMailboxAndForward
}

# End the Exchange Session
Get-PSSession | Where-Object {$_.ComputerName -eq 'outlook.office365.com'} | Remove-PSSession
