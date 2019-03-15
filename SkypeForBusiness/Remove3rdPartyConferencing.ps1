# Script to bulk remove 3rd party conferencing details for all users
#

# Load the Skype Online Connector module
Import-Module SkypeOnlineConnector

# Establish a session to Exchange Online
$sfbSession = New-CsOnlineSession
Import-PSSession -Session $sfbSession -AllowClobber

# AcpInfo Wildcard
$acpName = 'BT Conferencing UK_EMEA'

# Get all conferencing users matching the above wildcarded info
$thirdPartyAcps = (Get-CsUserAcp | Where-Object {$_.AcpInfo -match $acpName}).Identity

# Run through the users and remove their ACP info
foreach ($thirdPartyUser in $thirdPartyAcps) {
    Remove-CsUserAcp -Identity $thirdPartyUser
}

# End the PS Session
Remove-PSSession -Session $sfbSession
