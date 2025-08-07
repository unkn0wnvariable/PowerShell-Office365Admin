# Find shared mailboxes on the basis of their email domain and lists of who has access to them
#

# Where to save the CSV files to
$outputFile = 'C:\Temp\GroupDetails.csv'

# Wildcard for groups to find
$searchWildcard = '*@example.domain'

# Import module and connect to Exchange Online
Import-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline

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

# Disconnect from Exchange Online
Disconnect-ExchangeOnline
