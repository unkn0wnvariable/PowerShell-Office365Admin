# Find mailboxes where UPN domain doesn't match email domain
#

# Find and load the new ExO "module"
$exoModulePath = (Get-ChildItem -Path $env:userprofile -Filter CreateExoPSSession.ps1 -Recurse -Force -ErrorAction SilentlyContinue).DirectoryName[-1]
. "$exoModulePath\CreateExoPSSession.ps1"

# Establish a session to Exchange Online
Connect-EXOPSSession

# Get list of mailboxes with a different mail domain to UPN domain
Get-Mailbox -ResultSize Unlimited | Where-Object {$_.UserPrincipalName.Split('@')[1] -ne $_.PrimarySmtpAddress.Split('@')[1]} | Format-Table Name,UserPrincipalName,PrimarySmtpAddress,RecipientTypeDetails

# End the Exchange Session
Get-PSSession | Where-Object {$_.ComputerName -eq 'outlook.office365.com'} | Remove-PSSession
