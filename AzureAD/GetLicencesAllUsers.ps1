# Retrieve licences for all users and export to CSV.
#

# Import AzureAD module and connect
Import-Module AzureAD
Connect-AzureAD

# Get all available licence details
$allSkus = Get-AzureADSubscribedSku

# Import list of users from file
$users = Get-AzureADUser -All $true

# Get Licences for each user and find out what they are from the list
$allUserLicences = @()
foreach ($user in $users) {
    $assignedLicences = @()
    foreach ($license in $user.AssignedLicenses.SkuID) {
        $assignedLicences += ($allSkus | Where-Object { $_.ObjectId.Split('_')[1] -eq $license }).SkuPartNumber
    }
    $userLicences = [PSCustomObject]@{
        'UserName' = $user.UserPrincipalName
        'AssignedLicences' = (($assignedLicences | Sort-Object) -join ';')
    }
    $allUserLicences += $userLicences
}

# Export list to CSV file
$allUserLicences | Export-Csv -Path 'C:\Temp\AllUserLicences.csv' -NoTypeInformation
