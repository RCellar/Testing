$XPath = "*[System[EventID=102]] and *[EventData[Data[@Name='TaskName'] and (Data='\DEUtilities\Create Auth')]]"

Get-WinEvent -FilterXPath $XPath -ProviderName "Microsoft-Windows-TaskScheduler"
