# Script to invite a list of guest users to AzureAD and add them to a group
#
# Useful for bulk adding guests to a SharePoint or Teams group
#
# Uses a CSV file containing columns for FirstName,LastName,DisplayName,ExternalEmailAddress
#

# Where is our list of people?
$contactsFile = 'C:\Temp\ExternalContacts.csv'

# What group are we added them to?
$groupName = 'Test Group'

# Import the AzureAD module and connect
Import-Module AzureAD
Connect-AzureAD

# Import the list of people
$contactsList = Import-Csv -Path $contactsFile

# Find the group ID for our group
$groupID = (Get-AzureADGroup -All $true | Where-Object {$_.DisplayName -eq $groupName}).ObjectId

# Run through the list sending the guest invite and adding them to the group, unless their email address is already used somewhere
foreach ($externalUser in $contactsList) {
    $getExisting = Get-AzureADUser -SearchString $externalUser.ExternalEmailAddress

    if ($getExisting.Count -eq 0) {
        $newUser = New-AzureADMSInvitation -InvitedUserDisplayName $externalUser.DisplayName -InvitedUserEmailAddress $externalUser.ExternalEmailAddress -SendInvitationMessage $true -InviteRedirectUrl "https://myapps.microsoft.com"
        Add-AzureADGroupMember -ObjectId $groupID -RefObjectId $newUser.InvitedUser.Id
        Write-Output -InputObject ('Guest ' + $externalUser.ExternalEmailAddress + ' created and added to group.')
    }
    else {
        Write-Output -InputObject ('Object already exists with email address ' + $externalUser.ExternalEmailAddress + '.')
    }
}
