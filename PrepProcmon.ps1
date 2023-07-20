Function Prep-Procmon {
    param(
        [String]$ProcmonPath = "C:\Temp",
        [String]$ProcmonURL = "https://download.sysinternals.com/files/ProcessMonitor.zip"
    )
    Import-Module BitsTransfer
    Start-BitsTransfer -Source $ProcmonURL -Destination $ProcmonPath
    Expand-Archive -Path $ProcmonPath\ProcessMonitor.zip -DestinationPath $ProcmonPath\ProcessMonitor -Force

    &"$($ProcmonPath)\ProcessMonitor\Procmon.exe" "/AcceptEula"
}
