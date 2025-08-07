# Get the permissions and sendas rights for a list of mailboxes and output them to CSV
#

# Where to save the CSV files to
$outputPath = 'C:\Temp\MailboxPermissions\'

# What mailboxes are we checking?
$mailboxes = Get-Content -Path 'C:\Temp\Mailboxes.txt'

# Import module and connect to Exchange Online
Import-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline

# Get all non-inherited mailbox permissions excluding self and output to a CSV file named for each mailbox
foreach ($mailbox in $mailboxes) {
    Write-Output -InputObject ('Getting permissions for mailbox ' + $mailbox)
    $mailboxPermissions = Get-MailboxPermission -Identity $mailbox | Where-Object {$_.IsInherited -eq $false -and $_.User -ne 'NT AUTHORITY\SELF'} | Select-Object Identity,User,AccessRights,Deny
    if ($mailboxPermissions.Count -gt 0) {
        $outputFile = $outputPath + 'MailboxPermissions_' + ($mailbox -replace '@','_') + '.csv'
        $mailboxPermissions | Export-CSV -Path $outputFile -NoTypeInformation
    }
}

# Get all non-inherited recipient permissions (sendas) excluding self and output to a CSV file named for each mailbox
foreach ($mailbox in $mailboxes) {
    Write-Output -InputObject ('Getting permissions for recipient ' + $mailbox)
    $recipientPermissions = Get-RecipientPermission -Identity $mailbox | Where-Object {$_.IsInherited -eq $false -and $_.Trustee -ne 'NT AUTHORITY\SELF'} | Select-Object Identity,Trustee,AccessRights,AccessControlType
    if ($recipientPermissions.Count -gt 0) {
        $outputFile = $outputPath + 'RecipientPermissions_' + ($mailbox -replace '@','_') + '.csv'
        $recipientPermissions | Export-CSV -Path $outputFile -NoTypeInformation
    }
}

# Disconnect from Exchange Online
Disconnect-ExchangeOnline
