# Script to bulk remove email proxy addresses from Exchange Online users
#

# Which domains are we removing?
$domainsToRemove = @('','')

# Find and load the new ExO "module"
$exoModulePath = (Get-ChildItem -Path $env:userprofile -Filter CreateExoPSSession.ps1 -Recurse -Force -ErrorAction SilentlyContinue).DirectoryName[-1]
. "$exoModulePath\CreateExoPSSession.ps1"

# Establish a session to Exchange Online
Connect-EXOPSSession

### Remove the domain from mailboxes ###

# Get All Mailboxes
$allMailboxes = Get-Mailbox -ResultSize Unlimited | Sort-Object -Property alias

# Remove alias from each mailbox
foreach ($mailbox in $allMailboxes) {
    $redundantAddresses = @()
    foreach ($domainToRemove in $domainsToRemove) {
        $redundantAddresses += (($mailbox.EmailAddresses -split ',' | Where-Object {$_ -like ('*' + $domainToRemove + '*')}) -replace 'smtp:','')
    }
    if ($redundantAddresses.Count -gt 0) {
        Write-Output -InputObject ('Removing addresses ' + $redundantAddresses + ' from maibox ' + $mailbox.Name)
        Set-Mailbox -Identity $mailbox.Identity -EmailAddresses @{remove=$redundantAddresses} -Confirm:$false
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

### Remove the domain from public folders ###

# Get all the groups (this includes email enabled security groups)
$allPublicFolders = Get-MailPublicFolder -ResultSize Unlimited | Sort-Object -Property alias

# Remove alias from each public folder
foreach ($publicFolder in $allPublicFolders) {
    $redundantAddresses = @()
    foreach ($domainToRemove in $domainsToRemove) {
        $redundantAddresses += (($publicFolder.EmailAddresses -split ',' | Where-Object {$_ -like ('*' + $domainToRemove + '*')}) -replace 'smtp:','')
    }
    if ($redundantAddresses.Count -gt 0) {
        Write-Output -InputObject ('Removing addresses ' + $redundantAddresses + ' from public folder ' + $publicFolder.Name)
        Set-MailPublicFolder -Identity $publicFolder.Identity -EmailAddresses @{remove=$redundantAddresses} -Confirm:$false
    }
}

###

# End the Exchange Session
Get-PSSession | Where-Object {$_.ComputerName -eq 'outlook.office365.com'} | Remove-PSSession
