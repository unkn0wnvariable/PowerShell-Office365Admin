# Remove a collection administrator from your users' OneDrive for Business accounts
#
# Requires the Sharepoint Online PowerShell module to be installed
#

# The name of your Office 365 organization
# This can be found in your Sharepoint URL before the '-my', eg: https://thecompany-my.sharepoint.com/
$spoTenantName=''

# The UPN of the account you wish to add as a secondary admin
$secondaryAdminUPN = ''

# The list of UPNs for the accounts you wich to add the secondary admin to
$userList = @('','')

# Connect to Sharepoint Online
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
Connect-SPOService -Url ('https://' + $spoTenantName + '-admin.sharepoint.com')

# Create the base URL for OneDrive for Business
$spoBaseURL = 'https://' + $spoTenantName + '-my.sharepoint.com/personal/'

# Add secondary admin to each user in the list
foreach ($userUPN in $userList) {
    $spoURL = $spoBaseURL + ($userUPN.ToLower() -replace "[@.]", "_")
    Set-SPOUser -Site $spoURL -LoginName $secondaryAdminUPN -IsSiteCollectionAdmin $false -ErrorAction:Continue
    Remove-SPOUser -Site $spoURL -LoginName $secondaryAdminUPN
}
