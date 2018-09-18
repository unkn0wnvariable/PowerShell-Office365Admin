# Create and set up a room mailbox.
#
# Uses the new PowerShell "module" that support MFA.
#

# New room name and alias
$displayName = ''
$mailboxAlias = ''

# How many people can the room take?
$roomCapacity = ''

# Do you want meeting requests to be auto accepted?
$requestAutoAccept = $true

# Do we want to add the room to a room list?
$addToRoomList = $true

# What is the room list called? (Will be created if it doesn't exist)
$roomList = ''

# Find and load the new ExO "module"
$exoModulePath = (Get-ChildItem -Path $env:userprofile -Filter CreateExoPSSession.ps1 -Recurse -Force -ErrorAction SilentlyContinue).DirectoryName[-1]
. "$exoModulePath\CreateExoPSSession.ps1"

# Establish a session to Exchange Online
Connect-EXOPSSession

# Create the new room mailbox
New-Mailbox -Room -Alias $mailboxAlias -Name $displayName -DisplayName $displayName -ResourceCapacity $roomCapacity

# Wait for the meeting room mailbox to process
Start-Sleep -Seconds 30

# Set the mailbox calendar to auto accept meeting requests (assuming policies are met)
if ($requestAutoAccept) {
    Set-CalendarProcessing $mailboxAlias -AutomateProcessing AutoAccept
}

# If we're adding the room to a room list, then do that.
if ($addToRoomList) {
    # If the room list doesn't exist, create it.
    if (!(Get-DistributionGroup -Identity $roomList -ErrorAction SilentlyContinue)) {
        New-DistributionGroup -Name $roomList -RoomList
    }

    # Add the room to the list
    Add-DistributionGroupMember -Identity $roomList -Member $mailboxAlias
}

# End the Exchange Session
Get-PSSession | Where-Object {$_.ComputerName -eq 'outlook.office365.com'} | Remove-PSSession
