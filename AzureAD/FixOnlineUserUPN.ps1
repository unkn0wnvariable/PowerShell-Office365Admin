# Update Online User UPN - when AD sync doesn't do it.

# Import the Azure AD module and connect
Import-Module AzureAD
Connect-AzureAD

# Whose UPN are we changing?
$oldUPN = Read-Host -Prompt 'Enter user''s old UPN in the format username@domain'

# What are we changing it to?
$newUPN = Read-Host -Prompt 'Enter user''s new UPN in the format username@domain'

# Update the UPN in AzureAD
Set-AzureADUser -ObjectId $oldUPN -UserPrincipalName $newUPN
