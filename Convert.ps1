[IO.File]::WriteAllBytes($B64File,[char[]][Convert]::ToBase64String([IO.File]::ReadAllBytes($SourceFile)))
[IO.File]::WriteAllBytes($Reconstituted, [Convert]::FromBase64String([char[]][IO.File]::ReadAllBytes($B64File)))


$EncodeSource = [Convert]::ToBase64String((Get-Content .\Test.txt -Encoding Byte))
$GUID = New-Guid
Set-ItemProperty -Path "HKLM:\SOFTWARE\Test" -Name $GUID -Value $EncodeSource


$Retrieve = [String](Get-ItemProperty -Path "HKLM:\Software\Test").$GUID
$ConvertBytes = [Convert]::FromBase64String($Retrieve)
$ConvertToString = [System.Text.Encoding]::ASCII.GetString($ConvertBytes)
$ConvertToString
