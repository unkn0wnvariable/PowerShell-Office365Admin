# ScheduledBitLockerKeyBackup.ps1

<#
Script intended for deployment through Intune:
Creates a locally saved PS script to get the bitlocker key and save it to Azure.
Then creates a scheduled task to run that script at every logon.
#>

# Name and description for the schedulled task to be created
$taskName = 'Bitlocker Key Backup to AzureAD'
$taskDescription = 'Retrieve Bitlocker key for system drive and store it in AzureAD'

# Day, time and randomised delay for the task to be created
$taskDay = 'Monday'
$taskTime = '12:00:00'
$taskDelay = '00:20:00'

# Path to the folder for the files to be created
$scriptFolder = 'C:\ProgramData\Intune\Scripts\'

# Names of the files to be created
$scriptFilename = 'BitlockerKeyBackup.ps1'
$scriptLogFilename = 'BitlockerKeyBackup-LastRun.log'
$deployLogFilename = 'BitlockerKeyBackup-Deployed.log'

# Establish full paths to the files
$scriptPath = $scriptFolder + $scriptFilename
$logPath = $scriptFolder + $scriptLogFilename
$deployLogPath = $scriptFolder + $deployLogFilename

# If folder doesn't exist create it, else clean up files from last run
if (!(Test-Path -Path $scriptFolder)) {
    New-Item -Path $scriptFolder -ItemType Directory
}
else {
    foreach ($filePath in @($scriptPath, $logPath, $deployLogPath)) {
        if (Test-Path -Path $filePath) {
            Remove-Item -Path $filePath
        }
    }
}

# Contents of the PS script file to be created on the target machine
$scriptContents = @(
    '$logPath = ''' + $logPath + ''''
    'try {'
    '    $recoveryPassword = ((Get-BitlockerVolume -MountPoint $env:SystemDrive -ErrorAction Stop).KeyProtector | Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"})'
    '    $result = BackupToAAD-BitLockerKeyProtector $env:systemdrive -KeyProtectorId $recoveryPassword.KeyProtectorId -ErrorAction Stop'
    '    Out-File -InputObject $result -FilePath $logPath'
    '}'
    'catch {'
    '    Out-File -InputObject $Error[0].Exception.Message -FilePath $logPath'
    '}'
)

# Create the script file
Out-File -InputObject $scriptContents -FilePath $scriptPath

# Set up the various parts of the scheduled task
$taskArgument = '-ExecutionPolicy Bypass -Command ". ' + $scriptPath + '"'
$taskAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $taskArgument -WorkingDirectory $scriptFolder
$taskTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $taskDay -At $taskTime -RandomDelay $taskDelay
$taskPrincipal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType 'ServiceAccount' -RunLevel 'Highest'
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Compatibility 'Win8' -Hidden -StartWhenAvailable

# If the scheduled task already exists then remove it
if (Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskName }) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# Create the scheduled task and run it immediately
$taskCreated = Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -TaskName $taskName -Description $taskDescription -Principal $taskPrincipal -Settings $taskSettings
Start-ScheduledTask -TaskName $taskName

# Create a log file for the deployment of the scheduled task
Out-File -InputObject $taskCreated -FilePath $deployLogPath
