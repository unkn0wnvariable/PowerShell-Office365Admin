# Import the Azure AD module and connect
Import-Module AzureAD
Connect-AzureAD

# Whose ID are we getting?
$userUPN = Read-Host -Prompt 'Enter user''s UPN in the format username@domain'

# Convert 365 ImmutableID to AD GUID
$immutableID = (Get-AzureADUser -ObjectId $userUPN).ImmutableID
[GUID][System.Convert]::FromBase64String($immutableID)
