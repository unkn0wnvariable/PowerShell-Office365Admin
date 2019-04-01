# Script to bulk remove 3rd party conferencing details for all users
#

# Load the Skype Online Connector module
Import-Module SkypeOnlineConnector

# Establish a session to Exchange Online
$sfbSession = New-CsOnlineSession
Import-PSSession -Session $sfbSession -AllowClobber

# Company Wildcard
$companyWildcard = '*'

# AcpInfo to match (doesn't need to be the full name)
$acpInfoWildcard = '*BT*'

# Get all conferencing users matching the above info
$thirdPartyAcpUsers = Get-CsOnlineUser -WarningAction:SilentlyContinue -ErrorAction:SilentlyContinue | Where-Object {($_.Company -like $companyWildcard) -and ($_.AcpInfo -like $acpInfoWildcard) -and ($_.Enabled -eq $true)}

# Run through the users and remove their ACP info
foreach ($thirdPartyAcpUser in $thirdPartyAcpUsers) {
    $acpInfoName = ([xml]$thirdPartyAcpUser.AcpInfo).acpInformation.name
    Remove-CsUserAcp -Identity $thirdPartyAcpUser.Identity -Name $acpInfoName
}

# End the PS Session
Remove-PSSession -Session $sfbSession
