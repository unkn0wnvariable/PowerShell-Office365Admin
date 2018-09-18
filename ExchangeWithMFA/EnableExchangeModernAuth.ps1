# Enable Modern Authentication in Exchange Online
#
# Uses the new PowerShell "module" that support MFA.
#

# Find and load the new ExO "module"
$exoModulePath = (Get-ChildItem -Path $env:userprofile -Filter CreateExoPSSession.ps1 -Recurse -Force -ErrorAction SilentlyContinue).DirectoryName[-1]
. "$exoModulePath\CreateExoPSSession.ps1"

# Establish a session to Exchange Online
Connect-EXOPSSession

# Enable modern authentication
Set-OrganizationConfig -OAuth2ClientProfileEnabled $true

# Verify the setting has changed
Get-OrganizationConfig | Format-Table -AutoSize Name,OAuth2ClientProfileEnabled

# End the Exchange Session
Get-PSSession | Where-Object {$_.ComputerName -eq 'outlook.office365.com'} | Remove-PSSession
