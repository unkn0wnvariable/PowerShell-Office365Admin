# Script to bulk remove email proxy addresses from Exchange users in a synced environment using an on-prem Exchange management server
#

# What is the FQDN of the on-prem Exchange server?
$exchangeServerFQDN = ''

# Which domains are we removing?
$domainsToRemove = @('','')

# Create Exchange connection Uri from FQDN
$exchangeConnectionUri = 'http://' + $exchangeServerFQDN +'/PowerShell/'

# Establish a session to Exchange
$userCredential = Get-Credential
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $exchangeConnectionUri -Authentication Kerberos -Credential $userCredential
Import-PSSession $session -DisableNameChecking

### Check if address policies are using this domain ###

# Initialise a hastable to store our results in
$addressPolicies = @()

# Get all address policies from Exchange
$allAddressPolicies = Get-EmailAddressPolicy

# Run through the domains checking if the domain to be removed is in the address policies
foreach ($domainToRemove in $domainsToRemove) {
    $emailAddressTemplate = 'SMTP:@' + $domainToRemove
    $addressPolicies += $allAddressPolicies | Where-Object {$_.EnabledEmailAddressTemplates -contains $emailAddressTemplate}
}

# If domain found in address policies then list them and ask if we want to contiue removing the proxy domain
if ($addressPolicies.Count -gt 0) {
    Write-Output -InputObject ('The following address policies are using the domain to be removed:')
    $addressPolicies | Format-Table
    $continue = ''
    while ($continue -notmatch '[YyNn]') {
        $continue = Read-Host -Prompt 'Do you want to continue running the script? (Y/N)'
    }
    if ($continue -match '[Nn]') {
        Write-Output -InputObject ('Terminating script.')
        break
    }
    else {
        Write-Output -InputObject ('Continuing with script.')
    }
}

###

### Remove the domain from mailboxes ###

# Get All Mailboxes
$allMailboxes = Get-RemoteMailbox -ResultSize Unlimited | Sort-Object -Property alias

# Remove alias from each mailbox
foreach ($mailbox in $allMailboxes) {
    $redundantAddresses = @()
    foreach ($domainToRemove in $domainsToRemove) {
        $redundantAddresses += (($mailbox.EmailAddresses -split ',' | Where-Object {$_ -match $domainToRemove}) -replace 'smtp:','')
    }
    if ($redundantAddresses.Count -gt 0) {
        Write-Output -InputObject ('Removing addresses ' + $redundantAddresses + ' from maibox ' + $mailbox.Name)
        Set-RemoteMailbox -Identity $mailbox.Identity -EmailAddresses @{remove=$redundantAddresses} -Confirm:$false
    }
}

###

### Remove the domain from contacts ###

# Get all the contacts
$allContacts = Get-MailContact -ResultSize Unlimited | Sort-Object -Property alias

# Remove alias from each contact
foreach ($contact in $allContacts) {
    $redundantAddresses = @()
    foreach ($domainToRemove in $domainsToRemove) {
        $redundantAddresses += (($contact.EmailAddresses -split ',' | Where-Object {$_ -like ('*' + $domainToRemove + '*')}) -replace 'smtp:','')
    }
    if ($redundantAddresses.Count -gt 0) {
        Write-Output -InputObject ('Removing addresses ' + $redundantAddresses + ' from contact ' + $contact.Name)
        Set-MailContact -Identity $contact.Identity -EmailAddresses @{remove=$redundantAddresses} -Confirm:$false -ForceUpgrade:$true
    }
}

###

### Remove the domain from groups ###

# Get all the groups (this includes email enabled security groups)
$allGroups = Get-DistributionGroup -ResultSize Unlimited | Sort-Object -Property alias

# Remove alias from each group
foreach ($group in $allGroups) {
    $redundantAddresses = @()
    foreach ($domainToRemove in $domainsToRemove) {
        $redundantAddresses += (($group.EmailAddresses -split ',' | Where-Object {$_ -like ('*' + $domainToRemove + '*')}) -replace 'smtp:','')
    }
    if ($redundantAddresses.Count -gt 0) {
        Write-Output -InputObject ('Removing addresses ' + $redundantAddresses + ' from group ' + $group.Name)
        Set-DistributionGroup -Identity $group.Identity -EmailAddresses @{remove=$redundantAddresses} -Confirm:$false
    }
}

###

### Public folders don't feature here because in this scenario they're cloud only ###

# End the Exchange Session
Remove-PSSession -Session $session
