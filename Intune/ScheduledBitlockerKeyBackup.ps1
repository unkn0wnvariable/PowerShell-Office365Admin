# ScheduledBitLockerKeyBackup.ps1

##### WORK IN PROGRESS #####

<#
Creates a locally saves PS script to get the bitlocker key and save it to Azure.
Then creates a scheduled task to run that script at every logon.
#>

$taskName = 'Bitlocker Key Backup to AzureAD'
$taskDescription = 'Retrieve Bitlocker key for system drive and store it in AzureAD'

$scriptFolder = 'C:\ProgramData\Intune\Scripts\'
$scriptFilename = 'BitlockerKeyBackup.ps1'

$scriptPath = $scriptFolder + $scriptFilename

if (!(Test-Path -Path $scriptFolder)) {
    New-Item -Path $scriptFolder -ItemType Directory
}

$scriptContents = @(
    '$recoveryPassword = ((Get-BitlockerVolume -MountPoint $env:SystemDrive).KeyProtector | Where-Object { $_.KeyProtectorType -eq "RecoveryPassword" })'
    '$null = BackupToAAD-BitLockerKeyProtector $env:systemdrive -KeyProtectorId $recoveryPassword.KeyProtectorID'
)

Out-File -InputObject $scriptContents -FilePath $scriptPath

$taskAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $scriptPath -WorkingDirectory $scriptFolder
$taskTrigger = New-ScheduledTaskTrigger -AtLogOn
$taskPrincipal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType 'ServiceAccount' -RunLevel 'Highest'
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Compatibility 'Win8' -Hidden -StartWhenAvailable

$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction Stop

if ($existingTask) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -TaskName $taskName -Description $taskDescription -Principal $taskPrincipal -Settings $taskSettings

Start-ScheduledTask -TaskName $taskName
