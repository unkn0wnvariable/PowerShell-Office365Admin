# Update Online User UPN - when AD sync doesn't do it.

# Import the MSOL module and connect
Import-Module MSOnline
Connect-MsolService

# Whose UPN are we changing?
$oldUPN = Read-Host -Prompt 'Enter user''s old UPN in the format username@domain'

# What are we changing it to?
$newUPN = Read-Host -Prompt 'Enter user''s new UPN in the format username@domain'

# Change the UPN
if (Get-ADUser -Identity $newUPN.Split('@')[0]) {
    Set-MsolUserPrincipalName -UserPrincipalName $oldUPN -NewUserPrincipalName $newUPN
}
