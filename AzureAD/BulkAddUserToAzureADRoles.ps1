# Script to add multiple users to multiple AzureAD roles

<#
You can find a list of available roles in the following Microsoft article
https://docs.microsoft.com/en-us/azure/active-directory/active-directory-assign-admin-roles-azure-portal
Double check using Get-AzureADDirectoryRole as they don't always have the same name in PowerShell as the GUI

Built from the code example on the following Mircosoft page
https://docs.microsoft.com/en-us/powershell/module/azuread/add-azureaddirectoryrolemember?view=azureadps-2.0
#>


# User UPNs to assign roles to
$roleUsers = @('')

# Role Names to Assign
$roleNames = @('')


# Import AzureAD module and Connect
Import-Module AzureAD
Connect-AzureAD

# Run through the list of users
foreach ($roleUser in $roleUsers) {
    # Fetch user to assign to role
    $roleMember = Get-AzureADUser -ObjectId $roleUser

    # Run through the list of roles
    foreach ($roleName in $roleNames) {
        # Fetch User Account Administrator role instance
        $role = Get-AzureADDirectoryRole | Where-Object { $_.displayName -eq $roleName }

        # If role instance does not exist, instantiate it based on the role template
        if ($role -eq $null) {
            # Instantiate an instance of the role template
            $roleTemplate = Get-AzureADDirectoryRoleTemplate | Where-Object { $_.displayName -eq $roleName }
            Enable-AzureADDirectoryRole -RoleTemplateId $roleTemplate.ObjectId

            # Fetch User Account Administrator role instance again
            $role = Get-AzureADDirectoryRole | Where-Object { $_.displayName -eq $roleName }
        }

        # Get existing users with the role assigned
        $existingRoleUsers = (Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId).UserPrincipalName

        # Assign role to new user if not already in the list
        if ($roleMember.UserPrincipalName -notin $existingRoleUsers) {
            Add-AzureADDirectoryRoleMember -ObjectId $role.ObjectId -RefObjectId $roleMember.ObjectId -ErrorAction Stop
        }
    }
}

# Uncomment to fetch role membership for each role to confirm
#foreach ($roleName in $roleNames) {
#    Write-Output -InputObject ('Members for role: ' + $roleName)
#    Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId | Get-AzureADUser | Where-Object {$_.UserPrincipalName -in $roleUsers}
#}
