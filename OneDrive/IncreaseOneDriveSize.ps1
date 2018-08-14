# Increase the size of specific users' OneDrive for Business accounts
#
# Requires the Sharepoint Online PowerShell module to be installed
#

# The name of your Office 365 organization
# This can be found in your Sharepoint URL before the '-my', eg: https://thecompany-my.sharepoint.com/
$orgName=''

# The size you want to increase to in TB.
$newSize = 1

# The list of UPNs for the accounts you wich to add the secondary admin to (list can contain a single item if required)
$userList = @('','')

# Connect to Sharepoint Online
$spoServiceURL = 'https://' + $orgName + '-admin.sharepoint.com'
Import-Module 'C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell' -DisableNameChecking
Connect-SPOService -Url $spoServiceURL

# Create the base URL for OneDrive for Business
$spoBaseURL = 'https://' + $orgName + '-my.sharepoint.com/personal/'

# Convert new size to bytes
$newBytes = $newSize * 1048576

# Increase size for each user in list
foreach ($userUPN in $userList) {
    $spoURL = $spoBaseURL + ($userUPN.ToLower() -replace "[@.]", "_")
    try {
        $currentBytes = (Get-SPOSite -Identity $spoURL -ErrorAction:Stop).StorageQuota
        if ($currentBytes -ne $newBytes) {
            try {
                Set-SPOSite -Identity $spoURL -StorageQuota $newBytes -ErrorAction:Stop -WhatIf
                Write-Output -InputObject ('Updated OneDrive account limit for ' + $userUPN + ' to ' + $newSize + 'TB.')
            }
            catch {
                Write-Output -InputObject ('Failed to update OneDrive account limit for ' + $userUPN + '.')
            }
        }
        else {
            Write-Output -InputObject ('Updated OneDrive account limit for ' + $userUPN + ' to ' + $newSize + 'TB.')
        }
    }
    catch {
        Write-Output -InputObject ('No OneDrive account found for ' + $userUPN + '.')
    }
}
