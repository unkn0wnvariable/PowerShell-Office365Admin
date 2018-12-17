# Disable a list of mail users
#

# What is the FQDN of the on-prem Exchange server?
$exchangeServerFQDN = ''

# What accounts are we disabling?
$usersToDisable = @('','')

# Create Exchange connection Uri from FQDN
$exchangeConnectionUri = 'http://' + $exchangeServerFQDN +'/PowerShell/'

# Establish a session to Exchange
$userCredential = Get-Credential
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $exchangeConnectionUri -Authentication Kerberos -Credential $userCredential
Import-PSSession $session -DisableNameChecking -AllowClobber

# Get list of mailboxes
foreach ($userToDisable in $usersToDisable) {
    Disable-RemoteMailbox -Identity $userToDisable -Confirm:$false
}

# End the Exchange Session
Remove-PSSession -Session $session
