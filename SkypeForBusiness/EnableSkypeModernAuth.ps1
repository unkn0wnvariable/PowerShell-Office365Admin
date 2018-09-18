# Enable Modern Authentication in Skype for Business Online
#

# Load the Skype Online Connector module
Import-Module SkypeOnlineConnector

# Establish a session to Exchange Online
$sfbSession = New-CsOnlineSession
Import-PSSession -Session $sfbSession

# Enable modern authentication
Set-CsOAuthConfiguration -ClientAdalAuthOverride Allowed 

# Verify the setting has changed
Get-CsOAuthConfiguration | Format-Table -AutoSize Identity,ClientAdalAuthOverride

# End the PS Session
Remove-PSSession -Session $sfbSession
