# Increase the size of all users' OneDrive for Business accounts
#
# Requires the Sharepoint Online PowerShell module to be installed
#

# The name of your Office 365 organization
# This can be found in your Sharepoint URL before the '-my', eg: https://thecompany-my.sharepoint.com/
$spoTenantName=''

# The size you want to increase to in TB.
$newSize = 1

# Connect to Sharepoint Online
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
Connect-SPOService -Url ('https://' + $spoTenantName + '-admin.sharepoint.com')

# Create the common base URL for OneDrive for Business
$spoBaseWildcard = 'https://' + $spoTenantName + '-my.sharepoint.com/personal/*'

# Convert new size to bytes
$newBytes = $newSize * 1048576

# Get a list of all personal sites within the tenant.
$personalSites = Get-SPOSite -Limit all -IncludePersonalSite $true | Where-Object {$_.Url -like $spoBaseWildcard}

# Increase size for each user in turn.
foreach ($personalSite in $personalSites) {
    $spoURL = $personalSite.Url
    $userUPN = $personalSite.Owner
    $currentBytes = $personalSite.StorageQuota

    if ($currentBytes -lt $newBytes) {
        try {
            Set-SPOSite -Identity $spoURL -StorageQuota $newBytes -ErrorAction:Stop
            Write-Output -InputObject ('Updated OneDrive account limit for ' + $userUPN + ' to ' + $newSize + 'TB.')
        }
        catch {
            Write-Output -InputObject ('Failed to update OneDrive account limit for ' + $userUPN + '.')
        }
    }
    else {
        Write-Output -InputObject ('OneDrive account limit for ' + $userUPN + ' already equal to or higher than ' + $newSize + 'TB.')
    }
}
