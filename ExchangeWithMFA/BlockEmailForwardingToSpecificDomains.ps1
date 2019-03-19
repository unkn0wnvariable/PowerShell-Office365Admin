# Create a rule to block email forwarding to specific domains.
#
# Uses the new PowerShell "module" that support MFA.
#

# What domains are we blocking?
$domainListFile = 'C:\Temp\DomainList.txt'

# What do we want to call the rule?
$ruleName = 'Block Auto Forwarding to Specific Domains 4'

# What reason do we want end users to see for the rejection?
$rejectionReason = 'Auto forwarding messages to this email provider is not permitted.'

# Find and load the new ExO "module"
$exoModulePath = (Get-ChildItem -Path $env:userprofile -Filter CreateExoPSSession.ps1 -Recurse -Force -ErrorAction SilentlyContinue).DirectoryName[-1]
. "$exoModulePath\CreateExoPSSession.ps1"

# Establish a session to Exchange Online
Connect-EXOPSSession

# Get the domain list from the file
$domainList = Get-Content -Path $domainListFile

# Create a new rule
$parameters = @{
    'Name' = $ruleName;
    'FromScope' = 'InOrganization';
    'SenderAddressLocation' = 'Header'
    'RecipientDomainIs' = $domainList;
    'MessageTypeMatches' = 'AutoForward';
    'RejectMessageEnhancedStatusCode' = '5.7.1'
    'RejectMessageReasonText' = $rejectionReason;
    'Priority' = 0;
    'Mode' = 'Enforce'
    'Enabled' = $true
}
New-TransportRule @parameters

# End the Exchange Session
Get-PSSession | Where-Object {$_.ComputerName -eq 'outlook.office365.com'} | Remove-PSSession
