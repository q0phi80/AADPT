# Source: https://github.com/StefanScherer/adfs2/blob/master/scripts/provision-win7.ps1
# Active Directory Module
# Write-Host "Loading Active Directory module..."
# Invoke-WebRequest -Uri  https://github.com/n0ts0cial/dll/raw/main/Microsoft.ActiveDirectory.Management.dll -OutFile C:\Microsoft.ActiveDirectory.Management.dll
# Import-Module .\Microsoft.ActiveDirectory.Management.dll
  
# Add the Kush Kingdom domain group the Local Administrators group"
# Add-LocalGroupMember -Group "Administrators" -Member "CLIENT\Kush Kingdom"
net localgroup Administrators "CLIENT\Kush Kingdom" /add

# Disable RDP NLA
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0

# Remove AppxPackages Win10
# Write-Host "Removing Win10 bloated apps..."
# Get-AppxPackage -Name * | Remove-AppxPackage -ErrorAction SilentlyContinue | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

# This script generates network share traffic for LLMNR and NTLM-related attacks

$task = '/c powershell New-PSDrive -Name "Public" -PSProvider "FileSystem" -Root "\\fluffy"'
$repeat = (New-TimeSpan -Minutes 4)
$taskName = "ntlm_bot"
$user = "client.ad\king.moshoeshoe"
$password = "Basotho19"

$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "$task"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $repeat
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd

$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -like $taskName }
if ($taskExists) {
  Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User $user -Password $password -Settings $settings

# Extend the Windows Evaluation period
# slmgr -rearm