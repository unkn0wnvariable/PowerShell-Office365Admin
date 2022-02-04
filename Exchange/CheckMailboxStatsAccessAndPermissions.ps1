# Script to get details for a list of mailboxes and save that out to a CSV file
#

# File containing the list of mailboxes
$inputFile = ''

# File to save the results to
$outputFile = 'C:\Temp\MailboxStats.csv'

# Establish a session to Exchange Online
Import-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline

# Check output folder exists and create it if it doesn't
$outputPath = (Split-Path -Path $outputFile)
if (!(Test-Path -Path $outputPath)) { New-Item -Path $outputFolder -ItemType Directory }

# If output file already exists, delete it.
if (Test-Path -Path $outputFile) { Remove-Item -Path $outputFile }

# Get the list of mailboxes from the file, or if input file is blank get all mailboxes
if ($inputFile) {
    $mailboxes = Get-Content -Path $inputFile
}
else {
    $mailboxes = (Get-Mailbox -ResultSize unlimited).UserPrincipalName
}

# Initialise the results table
$mailboxesTable = @()

# Iterate through the mailboxes and show a progress bar as we go.
foreach ($mailbox in $mailboxes) {
    Write-Progress -Activity 'Checking..' -status $mailbox -percentComplete ($mailboxes.IndexOf($mailbox) / $mailboxes.Count * 100)

    # Get the statistics for the mailbox.
    $mailboxStats = ''
    $mailboxStats = Get-MailboxStatistics -Identity $mailbox

    # If mailboxStats is blank then mailbox doesn't exist, so that entry can be skipped. For all others get the mailbox permissions and build the output table.
    if ($mailboxStats) {
        # Get permit permissions for users where the username has an @ in it, this filters out all the system permissions.
        $usersWithPermissions = Get-MailboxPermission -Identity $mailbox | Where-Object { $_.User -like '*@*' -and $_.IsInherited -eq $false }

        $otherUserAccess = @()
        foreach ($userWithPermissions in $usersWithPermissions) {
            $otherUserAccess += $userWithPermissions.User + ' (' + ($userWithPermissions.AccessRights -split ',' -replace ' ','' -join '; ') + ')'
        }

        $mailboxesTable += [PSCustomObject]@{
            'MailboxUPN'      = $mailbox;
            'MailboxType'     = $mailboxStats.MailboxTypeDetail;
            'ItemCount'       = $mailboxStats.ItemCount;
            'TotalItemSize'   = $mailboxStats.TotalItemSize;
            'LastLogonTime'   = $mailboxStats.LastLogonTime;
            'OtherUserAccess' = $otherUserAccess -join '; ';
        }
    }
}

# Output the final table of results to a file.
$mailboxesTable | Sort-Object -Property 'MailboxUPN' | Export-Csv -Path $outputFile -NoTypeInformation

# End the Exchange Online session
Disconnect-ExchangeOnline
