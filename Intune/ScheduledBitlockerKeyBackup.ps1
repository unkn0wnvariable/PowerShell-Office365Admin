# ScheduledBitLockerKeyBackup.ps1

<#
Script intended for deployment through Intune:
Creates a locally saved PS script to get the bitlocker key and save it to Azure.
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
    'BackupToAAD-BitLockerKeyProtector $env:systemdrive -KeyProtectorId $recoveryPassword.KeyProtectorId'
)

Out-File -InputObject $scriptContents -FilePath $scriptPath

$taskAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $scriptPath -WorkingDirectory $scriptFolder
$taskTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek 'Monday' -At '12:00:00' -RandomDelay '00:20:00'
$taskPrincipal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType 'ServiceAccount' -RunLevel 'Highest'
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Compatibility 'Win8' -Hidden -StartWhenAvailable

if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -TaskName $taskName -Description $taskDescription -Principal $taskPrincipal -Settings $taskSettings
Start-ScheduledTask -TaskName $taskName
