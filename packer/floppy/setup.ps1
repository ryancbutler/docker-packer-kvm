$ErrorActionPreference = "Stop"

#Get username and password from autounattend
[xml]$xml = get-content "a:\Autounattend.xml"
$component = $xml.unattend.settings|Where-Object{$_.pass -eq "oobeSystem"}
$localadminpw = $component.component.UserAccounts.LocalAccounts.LocalAccount.Password.Value
$localadminuser = $component.component.UserAccounts.LocalAccounts.LocalAccount.name

Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0

#Update VM Tools 
$UnattendedArgs = '/S /v /qn REBOOT=R'
$filepath = "$($env:SystemRoot)\temp\" 
$url = "https://packages.vmware.com/tools/esx/latest/windows/x64/"
$link = invoke-webrequest $url -SessionVariable mysession -UseBasicParsing
$link  = $link.Links|Where-Object{$_.outerHTML -like "*VMware*"}
$filename = ($link.href).Replace("x64/","")
Invoke-WebRequest -Uri ($url + $filename) -WebSession $mysession -OutFile "$filepath\$filename" -UseBasicParsing

Start-Process ("$filepath\$filename") $UnattendedArgs -Wait -Passthru

Install-PackageProvider -Name NuGet -Force

Find-module -Name PSWindowsUpdate
Install-Module -Name PSWindowsUpdate -Force
Find-Module -Name Autologon
Install-Module -Name Autologon -Force

Copy-Item -path "a:\UpdateTask.ps1" -Destination "C:\Windows\temp\UpdateTask.ps1" -Force

$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-ExecutionPolicy Bypass -file "C:\Windows\temp\UpdateTask.ps1" -noexit'
$trigger =  New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PSWindowsUpdate"

Import-Module -Name Autologon -force;
Enable-AutoLogon -Username $localadminuser -Password (ConvertTo-SecureString -String $localadminpw -AsPlainText -Force) -LogonCount "1"

Restart-Computer -Force

# Reset auto logon count
# https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-logoncount#logoncount-known-issue
#Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0

#Try enabling HTTPS for Winrm
#Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))



