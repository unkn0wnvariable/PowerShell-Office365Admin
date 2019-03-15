# Retrieve licences for a list of users and export them to a CSV file.
#

# Where is the list of user UPN's?
$userListPath = 'C:\Temp\UserList.txt'

# Import AzureAD module and connect
Import-Module AzureAD
Connect-AzureAD

# Get all available licence details
$allSkus = Get-AzureADSubscribedSku

# Import list of users from file
$users = Get-Content -Path $userListPath | Sort-Object

# Get Licences for user and find out what they are from the list
$allUserLicences = @()
foreach ($user in $users) {
    $assignedLicences = @()
    $userDetails = Get-AzureADUser -ObjectId $user
    foreach ($license in $userDetails.AssignedLicenses.SkuID) {
        $assignedLicences += ($allSkus | Where-Object { $_.ObjectId.Split('_')[1] -eq $license }).SkuPartNumber
    }
    $userLicences = [PSCustomObject]@{
        'UserName' = $user
        'AssignedLicences' = (($assignedLicences | Sort-Object) -join ';')
    }
    $allUserLicences += $userLicences
}

# Export list to CSV file
$allUserLicences | Export-Csv -Path 'C:\Temp\UserLicences.csv'
