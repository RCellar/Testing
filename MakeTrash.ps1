$TrashCount = 70
$Path = "C:\Windows\Temp\WUDO_Archive"
$Count = (Get-ChildItem $Path).Count

do {
    $Item = "$(New-Guid).txt"
    New-Item -ItemType File -Path "$Path\$Item.zip"
    $Count = (Get-ChildItem $Path).Count
    $Item = $null
} until ($Count -eq $TrashCount)
