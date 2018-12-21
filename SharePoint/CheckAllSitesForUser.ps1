# Script to go through all SPO sites and check if a user is assigned to them
#

# This is the name of your tenant, as shown in the URL when accessing SharePoint online
# E.g.: https://<tenant-name>.sharepoint.com/
$spoTenantName = ''

# Who are we looking for? (uses a wildcard like comparison)
$loginNameLike = ''

# Connect to Sharepoint Online
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
Connect-SPOService -Url ('https://' + $spoTenantName + '-admin.sharepoint.com')

# Get all SharePoint Online sites
$allSpoSites = Get-SPOSite -Limit All

# Run through the sites...
foreach ($spoSite in $allSpoSites) {
    # Try to get a list of users for the current site - requires owner access to the site.
    try {
        $spoUsers = Get-SPOUser -Site $spoSite.Url -Limit All -ErrorAction:Stop | Where-Object {$_.LoginName -like $loginNameLike}
        $usersRetrived = $true
    }
    catch {
        $spoUsers = ''
        $usersRetrived = $false
    }

    # If the previous try didn't fail then work on the retrived list
    if ($usersRetrived) {
        # If the list isn't empty, then set the output message to the userlogin name and site URL.
        if ([string]$spoUsers.Count -gt 0) {
            foreach ($spoUser in $spoUsers) {
                $outputMessage = 'User ' + $spoUser.LoginName + ' found in site ' + $spoSite.Url
            }
        }
        # Else (if the list is empty) set the output message to reflect that the user wasn't found in that group.
        else {
            $outputMessage = 'User not found in site ' + $spoSite.Url
        }
    }
    # If users weren't retrived then set the output message to reflect that.
    else {
        $outputMessage = 'Unable to get users from site: ' + $spoSite.Url
    }
    # Finally write out the output message.
    Write-Output -InputObject $outputMessage
}
