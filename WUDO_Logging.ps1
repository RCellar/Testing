[String]$DT = (Get-Date -f MMddyy)
[String]$WUDOPath = "C:\Windows\Temp\WUDO_Archive"
[String]$Dest = "$WUDOPath\$DT.zip"

if ((Test-Path -Path $WUDOPath) -eq $False) {
    New-Item -ItemType Directory -Path $WUDOPath | Out-Null
}

$Items = [PSCustomObject]@{
    WU = "$WUDOPath\WU_$DT"
    DOpt = "$WUDOPath\DO_$DT"
}

try {
    Get-WindowsupdateLog -LogPath "$($Items.WU).log" -ErrorAction Stop | Out-Null
    Get-DeliveryOptimizationLog -ErrorAction Stop | Set-Content -Path "$($Items.DOpt).log" -ErrorAction Stop -Force
}
catch {
    $_.ErrorDetails
    Exit 1
}

$Items.PSObject.Properties.Value | ForEach-Object {
    Compress-Archive -Path "$_`.log" -DestinationPath $Dest -Update
    Remove-Item -Path "$_`.log"
}

###Cleanup
[Int]$ArchiveMax = 30
[Int]$ArchiveCount = (Get-ChildItem $WUDOPath -Filter "*.zip").count

if (($ArchiveCount -gt $ArchiveMax) -and (Test-Path -Path $WUDOPath) ) {
    [Int]$RemoveCount = $ArchiveCount - $ArchiveMax
    $Removals = (Get-ChildItem -Path $WUDOPath -Filter "*.zip" | Sort-Object CreationTime | Select-Object -First $RemoveCount)
    $Removals | ForEach-Object {
        Remove-Item -Path $WUDOPath\$($_.Name)
    }
}
