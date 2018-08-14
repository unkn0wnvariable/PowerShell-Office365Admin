# Retrive a list of all OneDrive for Business sites within the organisation
#
# Requires the Sharepoint Online PowerShell module to be installed
#

# The name of your Office 365 organization
# This can be found in your Sharepoint URL before the '-my', eg: https://thecompany-my.sharepoint.com/
$orgName=''

# Connect to Sharepoint Online
$spoServiceURL = 'https://' + $orgName + '-admin.sharepoint.com'
Import-Module 'C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell' -DisableNameChecking
Connect-SPOService -Url $spoServiceURL

# Create the base URL for OneDrive for Business
$spoBaseWildcard = 'https://' + $orgName + '-my.sharepoint.com/personal/*'

# Get a list of all 'personal' sites (e.g.: OneDrive for Business sites) within the tenant
Get-SPOSite -Limit all -IncludePersonalSite $true | Where-Object {$_.Url -like $spoBaseWildcard} | Select-Object Owner,URL,StorageQuota | Format-Table -AutoSize
