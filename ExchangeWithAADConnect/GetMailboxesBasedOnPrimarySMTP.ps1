# Find mailboxes using a specific email domain and export list to CSV file
#

# What is the FQDN of the on-prem Exchange server?
$exchangeServerFQDN = ''

# Primary SMTP domain to search for
$primarySMTP = ''

# Where are we saving the output file?
$outputFile = 'C:\Temp\Mailboxes.csv'

# Create Exchange connection Uri from FQDN
$exchangeConnectionUri = 'http://' + $exchangeServerFQDN +'/PowerShell/'

# Establish a session to Exchange
$userCredential = Get-Credential
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $exchangeConnectionUri -Authentication Kerberos -Credential $userCredential
Import-PSSession $session -DisableNameChecking

# Get list of mailboxes
$allMailboxes = Get-RemoteMailbox -ResultSize Unlimited | Where-Object {($_.PrimarySmtpAddress.Split('@')[1] -eq $primarySMTP)}

# Export results to CSV file
$allMailboxes | Select-Object Name,Alias,UserPrincipalName,PrimarySmtpAddress,EmailAddresses | Export-Csv -Path $outputFile -NoTypeInformation

# End the Exchange Session
Remove-PSSession -Session $session
