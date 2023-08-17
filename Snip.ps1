$XPath = "*[System[EventID=102]] and *[EventData[Data[@Name='TaskName'] and (Data='\DEUtilities\Create Auth')]]"

Get-WinEvent -FilterXPath $XPath -ProviderName "Microsoft-Windows-TaskScheduler"


$XPath =@"
    *[System[TimeCreated[@SystemTime>'$DateTime']]
    [EventID=102 or EventID=100 or EventID=107 or EventID=110]] and *[EventData[Data[@Name='TaskName'] 
    and (Data='\Directory\Create Auth')]]
"@

Get-WinEvent -FilterXPath $XPath -ProviderName "Microsoft-Windows-TaskScheduler" 


$Date = ((Get-Date).AddDays(-7)).ToUniversalTime()
$Date = (Get-Date $Date -Format 'yyyy-MM-ddTHH:mm:ss.fffZ')
$XPath = "*[System[TimeCreated[@SystemTime >= '$($Date)']]]"
Get-WinEvent -FilterXPath $XPath -ProviderName "Microsoft-Windows-WLAN-AutoConfig"
