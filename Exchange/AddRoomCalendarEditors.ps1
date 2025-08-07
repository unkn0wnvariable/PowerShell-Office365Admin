# Create a group and add it to all room mailboxes as an editor
#

# What do you want the editors group to be called?
$editorsGroup = 'Calendar Editors'

# Who do you want to be in the group? This can be 1 or more people.
$editorsMembers = @('','')

# Import module and connect to Exchange Online
Import-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline

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

# Disconnect from Exchange Online
Disconnect-ExchangeOnline
