# Find shared mailboxes on the basis of their email domain and lists of who has access to them
#
# Uses the new PowerShell "module" that support MFA.
#

# Where to save the CSV files to
$outputFile = 'C:\Temp\GroupDetails.csv'

# Wildcard for groups to find
$searchWildcard = '*@example.domain'

# Find and load the new ExO "module"
$exoModulePath = (Get-ChildItem -Path $env:userprofile -Filter CreateExoPSSession.ps1 -Recurse -Force -ErrorAction SilentlyContinue).DirectoryName[-1]
. "$exoModulePath\CreateExoPSSession.ps1"

# Establish a session to Exchange Online
Connect-EXOPSSession

# Get all the groups we're looking for
$allGroups = Get-DistributionGroup | Where-Object {$_.PrimarySmtpAddress -like $searchWildcard}

# Initialise the hash table to store results in
$groupDetails = @()

# Run through the groups getting the members and adding 
foreach ($group in $allGroups) {
    $groupMembers = (Get-DistributionGroupMember -Identity $group.Name).Alias -join '; '
    $groupDetails += [PSCustomObject]@{
        'GroupName' = $group.Name;
        'GroupEmail' = $group.PrimarySmtpAddress;
        'GroupType' = $group.GroupType;
        'GroupMembers' = $groupMembers
    }
}

# Export results to CSV file
$groupDetails | Export-Csv -Path $outputFile -NoTypeInformation

# End the Exchange Session
Get-PSSession | Where-Object {$_.ComputerName -eq 'outlook.office365.com'} | Remove-PSSession
