# Create and set up a room mailbox.
#
# Uses the new PowerShell "module" that support MFA.
#

# Details of New Room
$displayName = ''
$mailboxAlias = ''
$roomCapacity = ''

# Room list to add the room to
$addToRoomList = $true
$roomList = ''

# Find and load the new ExO "module"
$exoModulePath = (Get-ChildItem -Path $env:userprofile -Filter CreateExoPSSession.ps1 -Recurse -Force -ErrorAction SilentlyContinue).DirectoryName[-1]
. "$exoModulePath\CreateExoPSSession.ps1"

# Establish a session to Exchange Online
Connect-EXOPSSession

# Create the new room mailbox
New-Mailbox -Room -Alias $mailboxAlias -Name $displayName -DisplayName $displayName -ResourceCapacity $roomCapacity

# If we're adding the room to a room list, then do that.
if ($addToRoomList) {
    # If the room list doesn't exist, create it.
    if (!(Get-DistributionGroup -Identity $roomList)) {
        New-DistributionGroup -Name $roomList -RoomList
    }

    # Add the room to the list
    Add-DistributionGroupMember -Identity $roomList -Member $mailboxAlias
}
