New-EventLog –LogName Application –Source "PowerAutomateDesktop"
Write-EventLog –LogName Application –Source "PowerAutomateDesktop" –EntryType Information –EventID 1 –Message "PowerAutomateDesktop: Disabling UAC"

Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0

Write-EventLog –LogName Application –Source "PowerAutomateDesktop" –EntryType Information –EventID 1 –Message "PowerAutomateDesktop: create powerautomatedesktop folder in C drive"
md c:\powerautomatedesktop

Write-EventLog –LogName Application –Source "PowerAutomateDesktop" –EntryType Information –EventID 1 –Message "PowerAutomateDesktop: download PAD from web"
$start_time = Get-Date
$webClient = New-Object –TypeName System.Net.WebClient
$webClient.DownloadFile('https://go.microsoft.com/fwlink/?linkid=2102613','C:\powerautomatedesktop\Setup.Microsoft.PowerAutomateDesktop.exe')
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

cd C:\powerautomatedesktop

Write-EventLog –LogName Application –Source "PowerAutomateDesktop" –EntryType Information –EventID 1 –Message "PowerAutomateDesktop: Install PAD"

.\Setup.Microsoft.PowerAutomateDesktop.exe -Silent -Install -ACCEPTEULA

Write-EventLog –LogName Application –Source "PowerAutomateDesktop" –EntryType Information –EventID 1 –Message "PowerAutomateDesktop: Installation completed"
Write-EventLog –LogName Application –Source "PowerAutomateDesktop" –EntryType Information –EventID 1 –Message "PowerAutomateDesktop: Switch on UAC"
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 1


Write-EventLog –LogName Application –Source "PowerAutomateDesktop" –EntryType Information –EventID 1 –Message "PowerAutomateDesktop: Installing chrome"

$LocalTempDir = $env:TEMP; 
$ChromeInstaller = "ChromeInstaller.exe"; 
(new-object System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller"); 
& "$LocalTempDir\$ChromeInstaller" /silent /install; 
$Process2Monitor = "ChromeInstaller"; 

Do 
{ 
    $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; 
    If ($ProcessesFound) 
    { 
        "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 
    } 
    else 
    { 
        rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose 
    } 
} Until (!$ProcessesFound)

Write-EventLog –LogName Application –Source "PowerAutomateDesktop" –EntryType Information –EventID 1 –Message "PowerAutomateDesktop: Adding extension"
#pad extension id
$Extension="gjgfobnenmnljakmhboildkafdkicala"

#register with machine, hence, get machine key
$regLocation = "Software\Policies\Google\Chrome\ExtensionInstallForcelist"

             If (!(Test-Path "HKLM:\$regLocation")) {
                    Write-Verbose -Message "No Registry Path, setting count to: 0"
                    [int]$Count = 0                    
                    New-Item -Path "HKLM:\$regLocation" -Force
        
                }
                Else {
                    Write-Verbose -Message "Keys found, counting them..."
                    [int]$Count = (Get-Item "HKLM:\$regLocation").Count
                    Write-Verbose -Message "Count is now $Count"
                }

 $regKey = $Count + 1
        
$regData = "$Extension;https://clients2.google.com/service/update2/crx"

#register with machine
New-ItemProperty -Path "HKLM:\$regLocation" -Name $regKey -Value $regData -PropertyType STRING -Force 
#register with user
#New-ItemProperty -Path "HKCU:\$regLocation" -Name $regKey -Value $regData -PropertyType STRING -Force 
        
 



