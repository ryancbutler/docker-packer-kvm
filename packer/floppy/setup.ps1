$ErrorActionPreference = "Stop"

#Get username and password from autounattend
[xml]$xml = get-content "a:\Autounattend.xml"
$component = $xml.unattend.settings|Where-Object{$_.pass -eq "oobeSystem"}
$localadminpw = $component.component.UserAccounts.LocalAccounts.LocalAccount.Password.Value
$localadminuser = $component.component.UserAccounts.LocalAccounts.LocalAccount.name

Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0


$UnattendedArgs = '/install /passive /norestart'
$filepath = "$($env:SystemRoot)\temp" 
$filename = "vcredist_x64.exe"
$url = "http://192.168.2.250/vmwaretools/vcredist_x64.exe"

Invoke-WebRequest -Uri $url -OutFile "$filepath\$filename" -UseBasicParsing

Start-Process ("$filepath\$filename") $UnattendedArgs -Wait -Passthru

$url = "http://192.168.2.250/vmwaretools/VMware%20Tools64-NOVMCHECk.msi"
$filename = "VMwareTools64-NOVMCHECk.msi"

$filepath = "$($env:SystemRoot)\temp" 

Invoke-WebRequest -Uri $url -OutFile "$filepath\$filename" -UseBasicParsing


$DataStamp = get-date -Format yyyyMMddTHHmmss
$logFile = '{0}-{1}.log' -f ("$filepath\$filename"),$DataStamp

$MSIArguments = @(
    "/i"
    ('"{0}"' -f ("$filepath\$filename"))
    "/qb"
    "/norestart"
    "/L*v"
    $logFile
)
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -Passthru


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



