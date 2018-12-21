# Script to go through all SPO sites and check if a user is assigned to them
#

# This is the name of your tenant, as shown in the URL when accessing SharePoint online
# E.g.: https://<tenant-name>.sharepoint.com/
$spoTenantName = ''

# Who are we looking for? (uses a wildcard like comparison)
$siteNameLike = '*'

# Connect to Sharepoint Online
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
Connect-SPOService -Url ('https://' + $spoTenantName + '-admin.sharepoint.com')

# Get all SharePoint Online sites
$allSpoSites = Get-SPOSite -Limit All | Where-Object {$_.Title -like $siteNameLike}

Get-SpoSiteGroup


# Run through the sites...
foreach ($spoSite in $allSpoSites) {
    # Try to get a list of users for the current site - requires owner access to the site.
    $allSiteGroups = Get-SpoSiteGroup -Site $spoSite.Url
    foreach ($siteGroup in $allSiteGroups) {
        Write-Host
        $siteGroup | Select-Object -ExpandProperty Users
    }
}

$spoUsers | Export-Csv C:\Temp\SISLive-Sharepoint-Site.csv -NoTypeInformation

$allSpoSites