# Script to grant access rights on mailboxes
#

# Mailboxes to grant rights on
$grantRightsOnMailboxes = @('','')

# Users to grant rights to
$grantRightsToUsers = @('','')

# Rights to grant
$accessRights = 'Editor'

# Establish a session to Exchange Online
Import-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline

# Apply the permissions
foreach ($grantRightsToUser in $grantRightsToUsers ) {
    foreach ($grantRightsOnMailbox in $grantRightsOnMailboxes) {
        $calendarIdentity = $grantRightsOnMailbox + ':\Calendar'
        $existingPermissions = Get-MailboxFolderPermission -Identity $calendarIdentity -User $grantRightsToUser -ErrorAction SilentlyContinue
        if (!($existingPermissions)) {
            Add-MailboxFolderPermission -Identity $calendarIdentity -User $grantRightsToUser -AccessRights $accessRights
        }
        else {
            Set-MailboxFolderPermission -Identity $calendarIdentity -User $grantRightsToUser -AccessRights $accessRights
        }
    }
}

# Disconnect from Exchange Online
Disconnect-ExchangeOnline
