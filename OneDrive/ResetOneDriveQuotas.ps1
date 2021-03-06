# Retrive a list of all OneDrive for Business sites, check their size and reset it if it is less than the default
#
# Requires the Sharepoint Online PowerShell module to be installed
#

# The name of your Office 365 organization
# This can be found in your Sharepoint URL before the '-my', eg: https://thecompany-my.sharepoint.com/
$spoTenantName=''

# Connect to Sharepoint Online
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
Connect-SPOService -Url ('https://' + $spoTenantName + '-admin.sharepoint.com')

# Create the common base URL for OneDrive for Business
$spoBaseWildcard = 'https://' + $spoTenantName + '-my.sharepoint.com/personal/*'

# Get the default quota for the tenant
$defaultQuota = (Get-SPOTenant).OneDriveStorageQuota

# Get a list of all 'personal' sites (e.g.: OneDrive for Business sites) within the tenant
$usersToReset = Get-SPOSite -Limit all -IncludePersonalSite $true | Where-Object {$_.Url -like $spoBaseWildcard -and $_.StorageQuota -lt $defaultQuota}

# Get a list of all 'personal' sites (e.g.: OneDrive for Business sites) within the tenant
foreach ($userToReset in $usersToReset) {
    Write-Output -InputObject ('Resetting user ' + $userToReset.Owner)
    Set-SPOSite -Identity $userToReset.Url -StorageQuotaReset
}
