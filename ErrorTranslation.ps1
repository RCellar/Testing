$ErrorTranslationOrigin = Get-Content .\ErrorTranslation.txt
$Filter = @()
$FO = @()
$Exiled = @()

try {
    Remove-Item .\Switch.ps1
    Start-Sleep -s 2
}
catch {

}
$ErrorTranslationOrigin | ForEach {
    if ($_ -match "^\S") {
        $Filter += $_
    }
}

$Filter | ForEach {
    $Matching = $_ -match "(?<hex>\dx\S+)\s+(?<dec>\-\S+|\d+)\s+(?<reason>\S+)\s*"
    if ($Matching -eq "True") {
        if ($Matches.Dec -like "-*") {
            $Dec = $Matches.Dec
        }
        else {
            $Dec = ("-" + $Matches.Dec)
        }
    $Breakdown = [PSCustomObject]@{
        Hex = $Matches.hex
        Dec = $Dec
        Reason = $Matches.reason
    }

    $FO += $Breakdown
    }
    else {
        $Exiled += $_
    }
}

$Exiled | ForEach {
    $Matching = $_ -match "(?<hex>\dx\S+)\s+(?<reason>\S+)\s*"
    if ($Matching -eq "True") {
        $Breakdown = [PSCustomObject]@{
            Hex = $Matches.hex
            Dec = [Int32]($Matches.hex)
            Reason = $Matches.reason
        }
    
    $FO += $Breakdown
    }
}

"Switch(`$HResult) {" | Out-File .\Switch.ps1
"   Default   `{`$ResultReason = `"None`"`}" | Out-File .\Switch.ps1 -Append
$FO | Foreach {
    "   `"$($_.Dec)`"    {`$ResultReason = `"$($_.Reason)`"}" | Out-File .\Switch.ps1 -Append
}
"}" | Out-File .\Switch.ps1 -Append