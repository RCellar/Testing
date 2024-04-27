Function GetLocalUsersFromUsersDir {
    $IgnoreList = "Public,Default,f5 Pre-Logon User,defaultuser0" -split ","
    $Path = "C:\Users"
    $List = Get-ChildItem $Path | ? {$IgnoreList -notcontains $_.BaseName}
    $List.BaseName
}

Function Get-EdgeExtensions {
    param(
        [Parameter(Mandatory=$true)][String]$User
    )

    $ObjList = [System.Collections.Generic.List[Object]]@()
    $Pull = Get-ChildItem -Path "C:\Users\$($User)\AppData\Local\Microsoft\Edge\User Data\Default\Extensions" 
    $Pull | ? {$_.BaseName -ne "Temp"} | ForEach-Object {
        $Obj = [PSCustomObject]@{
            ExtensionID = $_.BaseName
        }
        $Version = (Get-ChildItem -Path "$($_.FullName)" | Sort -Property BaseName -Descending | Select -First 1)
        $ManifestPull = (Get-ChildItem -Path $Version.FullName -Filter manifest.json)
        $ManifestPull = (Get-Content $ManifestPull.FullName -Raw -Encoding UTF8 | ConvertFrom-Json | Select-Object Author, homepage_url, update_url, version)
        $ManifestPull.PSObject.Properties | ForEach {
            $Obj | Add-Member -NotePropertyName $_.Name -NotePropertyValue $_.Value
        }
        try {$ExtName = EdgeExtensionLookup -Extension $Obj.ExtensionID}
        catch {}
        if ($ExtName) {$Obj | Add-Member -NotePropertyName Name -NotePropertyValue $ExtName}
        #$Obj | Add-Member -NotePropertyName 'Manifest' -NotePropertyValue $ManifestPull
        $ObjList.Add($Obj)
    }
    return $ObjList
}

Function EdgeExtensionLookup {
    param(
    [String]$Extension
    )

    #Build local index cache?

    try {
        $Call = Invoke-WebRequest -URI "https://microsoftedge.microsoft.com/addons/detail/$($Extension)" -UseBasicParsing -ErrorAction Stop
        [Void]($Call.Content -match ".*title>(?'title'.*)<\/title>")
        $Matches.Title.Replace(" - Microsoft Edge Addons","")
        }
    catch {$_}
}

GetLocalUsersFromUsersDir | ForEach {
    Get-EdgeExtensions $_
}
