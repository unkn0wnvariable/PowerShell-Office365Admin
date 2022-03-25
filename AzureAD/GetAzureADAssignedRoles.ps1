# Script to get all Azure AD roles assigned to all users
#

# Output file
$outputFile = 'C:\Temp\AzureADAllAssignedRoles.csv'

# Import the module and connect to AzureAD
Import-Module -Name AzureAD
Connect-AzureAD

# Get all Azure AD role definitions, excluding the default User role
$roleDefinitions = Get-AzureADMSRoleDefinition | Where-Object { $_.Id -ne 'a0b1b346-4d3e-4e8b-98f8-753987be4970' }

# Prime the output array
$allAssignedRoles = @()

# Set progress index to 0
$i = 0

# Run through all the role definitions
foreach ($roleDefinition in $roleDefinitions) {
    # Show a progress bar
    Write-Progress -Activity 'Checking users assigned to...' -Status $roleDefinition.DisplayName -PercentComplete ((++$i / $roleDefinitions.Count) * 100)

    # Get assignments for the role definition
    $roleAssignments = Get-AzureADMSRoleAssignment -All $true -Filter "roleDefinitionId eq '$($roleDefinition.Id)'"

    # If there are role assignments then find out who they are
    if ($roleAssignments) {
        # Get Azure AD objects for the list of assignments
        $azureAdObjects = Get-AzureADObjectByObjectId -ObjectIds $roleAssignments.PrincipalId

        # Add a new object for each Azure AD object to our output array
        foreach ($azureAdObject in $azureAdObjects) {
            $allAssignedRoles += [PSCustomObject]@{
                'DisplayName'       = $azureAdObject.DisplayName;
                'UserPrincipalName' = $azureAdObject.UserPrincipalName;
                'RoleName'      = $roleDefinition.DisplayName;
            }
        }
    }
}

# Output sorted list of all roles to CSV
$allAssignedRoles | Sort-Object -Property DisplayName | Export-Csv -NoTypeInformation -Path $outputFile

# Disconnect from Azure
Disconnect-AzureAD
