# Update Microsoft audio conferencing for a list of users
#
# Expects a CSV file with two columns, one containing the UserPrincipalName and the other containing the ServiceNumber.
#
# A list of dedicated conference numbers can be retrieved with:
# (Get-CsOnlineDialInConferencingBridge -Name 'Conference Bridge').ServiceNumbers | Where-Object {$_.IsShared -eq $false}
#
# If the service number entry for a user in the CSV file is blank then the default will be used.
#

# Where is the list of users?
$userListPath = 'C:\Temp\UsersToUpdate.csv'

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
    $currentTollNumber = (Get-CsOnlineDialInConferencingUserInfo -Identity $user.UserPrincipalName).DefaultTollNumber
    if ($currentTollNumber -ne $user.ServiceNumber) {
        Set-CsOnlineDialInConferencingUser -Identity $user.UserPrincipalName -ServiceNumber $serviceNumber.Number -SendEmail
        Write-Output -InputObject ('Audio conferencing updated for ' + $user.UserPrincipalName + ' with number ' + $serviceNumber.Number + '.')
    }
}

# Disconnect
Remove-PSSession -Session $sfbSession
