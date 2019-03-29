# Script to extract conferencing details for users from the AcpInfo setting
#

# Load the Skype Online Connector module
Import-Module SkypeOnlineConnector

# Establish a session to Exchange Online
$sfbSession = New-CsOnlineSession
Import-PSSession -Session $sfbSession

# Company Wildcard
$companyWildcard = '*'

# AcpInfo Wildcard
$acpInfoWildcard = '*BT*'

# Output file
$outputFile = 'C:\Temp\ConferencingUsers.csv'

# Get all conferencing users matching the above wildcarded info
$conferencingUsers = Get-CsOnlineUser -WarningAction:SilentlyContinue -ErrorAction:SilentlyContinue | Where-Object {($_.Company -like $companyWildcard) -and ($_.AcpInfo -like $acpInfoWildcard) -and ($_.Enabled -eq $true)} | Select-Object DisplayName,UserPrincipalName,AcpInfo

# Set up user details hash table
$userDetails = @()

# Run through the users, check if they're in the exclusions list and if not then pull the details out of the AcpInfo code
foreach ($conferencingUser in $conferencingUsers) {
    $tollNumber = ''
    if ([string]$conferencingUser.AcpInfo -match '<tollNumber>(?<tollNumber>.*)</tollNumber>') {
        $tollNumber = $Matches.tollNumber
    }    
    
    $tollFreeNumber = ''
    if ([string]$conferencingUser.AcpInfo -match '<tollFreeNumber>(?<tollFreeNumber>.*)</tollFreeNumber>') {
        $tollFreeNumber = $Matches.tollFreeNumber
    }
    
    $participantPassCode = ''
    if ([string]$conferencingUser.AcpInfo -match '<participantPassCode>(?<participantPassCode>.*)</participantPassCode>') {
        $participantPassCode = $Matches.participantPassCode
    }
        
    $domain = ''
    if ([string]$conferencingUser.AcpInfo -match '<domain>(?<domain>.*)</domain>') {
        $domain = $Matches.domain
    }
        
    $name = ''
    if ([string]$conferencingUser.AcpInfo -match '<name>(?<name>.*)</name>') {
        $name = $Matches.name
    }
        
    $url = ''
    if ([string]$conferencingUser.AcpInfo -match '<url>(?<url>.*)</url>') {
        $url = $Matches.url
    }
    
    $userDetails += [PSCustomObject]@{
        'DisplayName' = [string]$conferencingUser.DisplayName
        'UserPrincipalName' = [string]$conferencingUser.UserPrincipalName
        'TollNumber' = [string]$tollNumber
        'TollFreeNumber' = [string]$tollFreeNumber
        'ParticipantPassCode' = [string]$participantPassCode
        'Domain' = [string]$domain
        'Name' = [string]$name
        'Url' = [string]$url
    }
}

# Output to CSV file
$userDetails | Export-Csv -Path $outputFile -NoTypeInformation

# End the PS Session
Remove-PSSession -Session $sfbSession
