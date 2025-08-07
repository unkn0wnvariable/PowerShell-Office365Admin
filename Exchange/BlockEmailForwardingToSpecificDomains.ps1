# Create a rule to block email forwarding to specific domains.
#

# What domains are we blocking?
$domainListFile = 'C:\Temp\DomainList.txt'

# What do we want to call the rule?
$ruleName = 'Block Auto Forwarding to Specific Domains 4'

# What reason do we want end users to see for the rejection?
$rejectionReason = 'Auto forwarding messages to this email provider is not permitted.'

# Import module and connect to Exchange Online
Import-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline

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

# Disconnect from Exchange Online
Disconnect-ExchangeOnline
