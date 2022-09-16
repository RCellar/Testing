$ErrorReference = Get-Content .\ErrorReference.txt
$FormOutput = $Null
$SwitchFile = (Get-Location).Path + "\" + "Switch.ps1"
Try {
    Remove-Item $SwitchFile -ErrorAction Stop
}
Catch {

}

$ErrorReference | ForEach {
    $Matching = $_ -match "(?<reason>\S+)\,(?<hex>\dx\S+)\,(?<reasondesc>.+)$"
    $Props = [PSCustomObject]@{
        Hex = $Matches.hex
        Dec = [Int32]$Matches.hex
        Reason = $Matches.reason
        ReasonDesc = [String]$Matches.reasondesc
    }
    [Array]$FormOutput += $Props
}


"Switch(`$HResult) {" | Out-File $SwitchFile
"   Default   `{`$ResultReason = `"None`"`}" | Out-File $SwitchFile -Append
$FormOutput | ForEach {
    "   `"$($_.Dec)`"    {`$ResultReason = `"$($_.Reason)`" ; `$ResultReasonDesc = `"$($_.ReasonDesc)`"}" | Out-File $SwitchFile -Append
}
"}" | Out-File $SwitchFile -Append
