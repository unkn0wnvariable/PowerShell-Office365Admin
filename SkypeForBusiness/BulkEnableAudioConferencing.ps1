# Enable all licenced users for Microsoft audio conferencing
#
# In addition to the SfB module this requires the MSOnline module so it can check who is licenced.
#

# Import MSOnline module and connect
Import-Module MSOnline
Connect-MsolService

# Load the Skype Online Connector module and connect
Import-Module SkypeOnlineConnector
$sfbSession = New-CsOnlineSession
Import-PSSession -Session $sfbSession

# At time of creation, this is the name of the audio conferencing licence
$audioConferencingLicence = 'MCOMEETADV'

# Find everyone who has the audio conferencing licence assigned
$users = (Get-MsolUser -All | Where-Object {($_.licenses).AccountSkuId -match $audioConferencingLicence}).UserPrincipalName

# Get the default service number from your tenant
$defaultServiceNumber = (Get-CsOnlineDialInConferencingBridge -Name 'Conference Bridge').DefaultServiceNumber

# Enable conferencing for everyone on that list who doesn't already have it enabled
foreach ($user in $users) {
    $currentProvider = (Get-CsOnlineDialInConferencingUserInfo -Identity $user).Provider
    if ($currentProvider -ne 'Microsoft') {
        Enable-CsOnlineDialInConferencingUser -ServiceNumber $defaultServiceNumber -ReplaceProvider -SendEmail
    }
}

# Disconnect
Remove-PSSession -Session $sfbSession
