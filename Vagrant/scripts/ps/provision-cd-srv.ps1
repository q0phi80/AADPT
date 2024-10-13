# Add Local Group membership
# net localgroup "Remote Desktop Users" "child\Axumite Empire" /add
# net localgroup "Remote Desktop Users" "child\Kongo Kingdom" /add
# net localgroup "Remote Desktop Users" "child\Kushite Empire" /add
# net localgroup "Administrators" "child\idi.amin" /add
# net localgroup "Administrators" "child\mansa.musa" /add

Add-LocalGroupMember -Group "Administrators" -Member "child\mansa.musa", "child\idi.amin"
Add-LocalGroupMember -Group "Backup Operators" -Member "child\jomo.kenyatta"
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "child\Axumite Empire", "child\Kongo Kingdom", "child\Kushite Empire"

# Terminal service
# Source: https://raw.githubusercontent.com/StefanScherer/adfs2/master/scripts/install-terminalserver.ps1
Write-Host "Installing Terminal service..."
Import-Module ServerManager
Add-WindowsFeature -Name "RDS-RD-Server" -IncludeAllSubFeature

# SMB Share
Write-Host "Creating SMB Share..."
New-Item -Path "C:\Secret" -ItemType Directory -Force
$FullAccessUsers = "child\jomo.kenyatta"
# Create the SMB share with FullAccess for specified users/groups
New-SmbShare -Name "Pesonal" -Path "C:\Secret" -FullAccess $FullAccessUsers

# Install NFS on the server
Write-Host "Installing NFS Service..."
Import-Module ServerManager
Add-WindowsFeature FS-NFS-Service
Import-Module NFS

# Active Directory Module
# Write-Host "Loading Active Directory module..."
# Invoke-WebRequest -Uri  https://github.com/n0ts0cial/dll/raw/main/Microsoft.ActiveDirectory.Management.dll -OutFile Microsoft.ActiveDirectory.Management.dll
# Import-Module .\Microsoft.ActiveDirectory.Management.dll

# Generate traffic for Responder
# Run this on the CHILD SRV
Write-Host "Running responder bot that will generate network traffic..."
$task = '/c powershell New-PSDrive -Name "Public" -PSProvider "FileSystem" -Root "\\CD-SR\Fluffy"'
$repeat = (New-TimeSpan -Minutes 5)
$taskName = "responder_bot"
$user = "child.client.ad\jomo.kenyatta"
$password = "Kenya64"

$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "$task"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $repeat
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd

$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -like $taskName }
if ($taskExists) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User $user -Password $password -Settings $settings

# PS-Remoting bot
$pass = ConvertTo-SecureString 'Fluffy123!' -AsPlainText -Force;
$creds = New-Object System.Management.Automation.PSCredential ('child\mansa.musa', $pass);
$task = Invoke-Command -Computername 'CD-WKSTN' -ScriptBlock { Start-Sleep 55 } -Credential $creds -AsJob
# $task = '/c powershell New-PSDrive -Name "Public" -PSProvider "FileSystem" -Root "\\CD-SR\Fluffy"'
$repeat = (New-TimeSpan -Minutes 5)
$taskName = "session_bot"
$user = "child.client.ad\idi.amin"
$password = "Uganda79Cr4ckMeIfUc4n"

$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "$task"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $repeat
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd

$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -like $taskName }
if ($taskExists) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User $user -Password $password -Settings $settings

# Disable RDP NLA
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0

# Disable Autologon
Write-Host "Disabling autologon..."
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /d 0 /f

Write-Host "Provisioning completed..."