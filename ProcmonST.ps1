$ProcmonPath = "C:\temp\ProcessMonitor\Procmon.exe"
$User = $env:username
$Action = New-ScheduledTaskAction -Execute $ProcmonPath -Argument "/AcceptEula /Quiet"
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances Parallel
$TaskPath = '\DEUtilities'
$TaskName = "ProcMon"

Register-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -User "$User" -RunLevel Highest -Force -Action $action -Settings $settings | Out-Null
Start-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath | Out-Null
Unregister-ScheduledTask -TaskName $TaskNAme -Confirm:$false | Out-Null
