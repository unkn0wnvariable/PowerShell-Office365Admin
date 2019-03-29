# Enable Microsoft audio conferencing for a list of users
#
# Expects a CSV file with two columns, one containing the UserPrincipalName and the other containing the ServiceNumber.
#
# A list of dedicated conference numbers can be retrieved with:
# (Get-CsOnlineDialInConferencingBridge -Name 'Conference Bridge').ServiceNumbers | Where-Object {$_.IsShared -eq $false}
#
# If the service number entry for a user in the CSV file is blank then the default will be used.
#

# Where is the list of users?
$userListPath = 'C:\Temp\UserList.csv'

# Load the Skype Online Connector module and connect
Import-Module SkypeOnlineConnector
$sfbSession = New-CsOnlineSession
Import-PSSession -Session $sfbSession

# Get list of users from file
$users = Import-Csv -Path $userListPath

# Get the conference bridge details
$conferenceBridge = Get-CsOnlineDialInConferencingBridge -Name 'Conference Bridge'

# Enable conferencing for everyone on that list who doesn't already have it enabled
foreach ($user in $users) {
    if (($user.ServiceNumber).Length -gt 0) {
        $serviceNumber = $conferenceBridge.ServiceNumbers | Where-Object {$_.Number -eq $user.ServiceNumber}
    }
    else {
        $serviceNumber = $conferenceBridge.DefaultServiceNumber
    }
    $currentProvider = (Get-CsOnlineDialInConferencingUserInfo -Identity $user.UserPrincipalName).Provider
    if ($currentProvider -ne 'Microsoft') {
        Enable-CsOnlineDialInConferencingUser -Identity $user.UserPrincipalName -ServiceNumber $serviceNumber.Number -ReplaceProvider -SendEmail
        Write-Output -InputObject ('Audio conferencing enabled for ' + $user.UserPrincipalName + ' with number ' + $serviceNumber.Number + '.')
    }
    else {
        Write-Output -InputObject ('Audio conferencing already enabled for ' + $user.UserPrincipalName + '.')
    }
}

# Disconnect
Remove-PSSession -Session $sfbSession
