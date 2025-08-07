# Enable Modern Authentication in Exchange Online
#

# Import module and connect to Exchange Online
Import-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline

# Enable modern authentication
Set-OrganizationConfig -OAuth2ClientProfileEnabled $true

# Verify the setting has changed
Get-OrganizationConfig | Format-Table -AutoSize Name,OAuth2ClientProfileEnabled

# Disconnect from Exchange Online
Disconnect-ExchangeOnline
