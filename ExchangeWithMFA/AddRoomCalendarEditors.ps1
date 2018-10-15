# Create a group and add it to all room mailboxes as an editor
#
# Uses the new PowerShell "module" that support MFA.
#

# What do you want the editors group to be called?
$editorsGroup = 'Calendar Editors'

# Who do you want to be in the group? This can be 1 or more people.
$editorsMembers = @('','')

# Find and load the new ExO "module"
$exoModulePath = (Get-ChildItem -Path $env:userprofile -Filter CreateExoPSSession.ps1 -Recurse -Force -ErrorAction SilentlyContinue).DirectoryName[-1]
. "$exoModulePath\CreateExoPSSession.ps1"

# Establish a session to Exchange Online
Connect-EXOPSSession

# Get all room mailboxes in the organisation
$roomMailboxes = (Get-Mailbox -RecipientTypeDetails RoomMailbox).Alias

# If the editors group doesn't exist, create it.
if (!(Get-DistributionGroup -Identity $editorsGroup -ErrorAction SilentlyContinue)) {
    New-DistributionGroup -Name $editorsGroup -Type Security
}

# Add members to the group
$existingMembers = Get-DistributionGroupMember -Identity $editorsGroup
foreach ($editorsMember in $editorsMembers) {
    if ($editorsMember -notin $existingMembers.Name) {
        Add-DistributionGroupMember -Identity $editorsGroup -Member $editorsMember
    }
}
    
# Add the permissions to the mailboxes
foreach ($roomMailbox in $roomMailboxes) {
    $calendarFolder = $mailboxAlias + ':\calendar'
    Add-MailboxFolderPermission -Identity $calendarFolder -User $editorsGroup  -AccessRights Editor
}

# End the Exchange Session
Get-PSSession | Where-Object {$_.ComputerName -eq 'outlook.office365.com'} | Remove-PSSession
