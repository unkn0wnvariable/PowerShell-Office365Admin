# A simple script to enable forwarding for a list of users from a CSV file
#

# Get the list of users from a CSV file
$userList = Import-Csv -Path 'C:\Temp\UserList.csv'

# Import module and connect to Exchange Online
Import-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline

# Get all non-inherited permissions excluding self and output to a CSV file named for each group
foreach ($user in $userList) {
    Write-Output -InputObject ('Forwarding ' + $user.SourceAddress + ' to ' + $user.DestinationAddress)
    Set-Mailbox -Identity $user.SourceAddress -ForwardingSmtpAddress $user.DestinationAddress
}

# Pull back a list to check everything has worked correctly
foreach ($user in $userList) {
    Get-Mailbox -Identity $user.SourceAddress | Select-Object UserPrincipalName,ForwardingSmtpAddress,DeliverToMailboxAndForward
}

# Disconnect from Exchange Online
Disconnect-ExchangeOnline
