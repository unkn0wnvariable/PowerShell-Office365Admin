# Script to bulk remove email aliases from Exchange users in a synced environment using an on-prem Exchange management server
#

# What is the FQDN of the on-prem Exchange server?
$exchangeServerFQDN = ''

# Which domains are we removing?
$domainsToRemove = @('','')

# Create Exchange connection Uri from FQDN
$exchangeConnectionUri = 'http://' + $exchangeServerFQDN +'/PowerShell/'

# Establish a session to Exchange
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $exchangeConnectionUri -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session -DisableNameChecking

### Remove the domain from mailboxes ###

# Get All Mailboxes
$allMailboxes = Get-RemoteMailbox -ResultSize Unlimited | Sort-Object -Property alias

# Find mailboxes with the domain to be removed and remove it
foreach ($domainToRemove in $domainsToRemove) {
    $affectedMailboxes = $allMailboxes | Where-Object {$_.EmailAddresses -like ('*' + $domainToRemove + '*')}

    # Remove alias from each
    foreach ($mailbox in $affectedMailboxes) {
        $redundantAddresses = (($mailbox.EmailAddresses -split ',' | Where-Object {$_ -like ('*' + $domainToRemove + '*')}) -replace 'smtp:','')
        foreach ($emailToRemove in $redundantAddresses) {
            Set-RemoteMailbox -Identity $mailbox.Identity -EmailAddresses @{remove=$emailToRemove} -Confirm:$false -WhatIf
        }
    }
}

###

### Remove the domain from contacts ###

# Get all the contacts
$allContacts = Get-MailContact -ResultSize Unlimited | Sort-Object -Property alias

# Find contacts with the domain to be removed and remove it
foreach ($domainToRemove in $domainsToRemove) {
    $affectedContacts = $allContacts | Where-Object {$_.EmailAddresses -like ('*' + $domainToRemove + '*')}

    # Remove alias from each
    foreach ($contact in $affectedContacts) {
        $redundantAddresses = (($contact.EmailAddresses -split ',' | Where-Object {$_ -like ('*' + $domainToRemove + '*')}) -replace 'smtp:','')
        foreach ($emailToRemove in $redundantAddresses) {
            Set-MailContact -Identity $contact.Identity -EmailAddresses @{remove=$emailToRemove} -Confirm:$false -ForceUpgrade:$true -WhatIf
        }
    }
}

###

### Remove the domain from groups ###

# Get all the groups (this includes email enabled security groups)
$allGroups = Get-DistributionGroup -ResultSize Unlimited

# Find groups with the domain to be removed and remove it
foreach ($domainToRemove in $domainsToRemove) {
    $affectedGroups = $allGroups | Where-Object {$_.EmailAddresses -like ('*' + $domainToRemove + '*')}

    # Remove alias from each
    foreach ($group in $affectedGroups) {
        $redundantAddresses = (($group.EmailAddresses -split ',' | Where-Object {$_ -like ('*' + $domainToRemove + '*')}) -replace 'smtp:','')
        foreach ($emailToRemove in $redundantAddresses) {
            Set-DistributionGroup -Identity $group.Identity -EmailAddresses @{remove=$emailToRemove} -Confirm:$false -WhatIf
        }
    }
}

###

# End the Exchange Session
Remove-PSSession -Session $Session
