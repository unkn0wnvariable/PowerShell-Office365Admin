# Bulk change guest accounts from a certain domain so that they show in the Global Address List
#
# Uses the new PowerShell "module" that support MFA.
#

# What domain are the guests email addresses from?
$guestDomain = ''

# Find and load the new ExO "module"
$exoModulePath = (Get-ChildItem -Path $env:userprofile -Filter CreateExoPSSession.ps1 -Recurse -Force -ErrorAction SilentlyContinue).DirectoryName[-1]
. "$exoModulePath\CreateExoPSSession.ps1"

# Establish a session to Exchange Online
Connect-EXOPSSession

# Find all the relevant users and enable them to show in the address list
Get-MailUser -ResultSize Unlimited | Where-Object {$_.RecipientTypeDetails -eq 'GuestMailUser' -and $_.EmailAddresses -match $guestDomain} | Set-MailUser -HiddenFromAddressListsEnabled $false

# End the Exchange Session
Get-PSSession | Where-Object {$_.ComputerName -eq 'outlook.office365.com'} | Remove-PSSession
