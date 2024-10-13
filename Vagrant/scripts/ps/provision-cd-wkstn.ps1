# Active Directory Module
Write-Host "Loading Active Directory module..."
Invoke-WebRequest -Uri  https://github.com/n0ts0cial/dll/raw/main/Microsoft.ActiveDirectory.Management.dll -OutFile Microsoft.ActiveDirectory.Management.dll
Import-Module .\Microsoft.ActiveDirectory.Management.dll

# Add Local Group membership
net localgroup "Remote Desktop Users" "child\kofi.annan" /add
net localgroup "Administrators" "child\shaka.zulu" /add
net localgroup "Administrators" "child\mansa.musa" /add

# Enable RDP
Write-Host 'Enable RDP'
netsh advfirewall firewall add rule name="Open Port 3389" dir=in action=allow protocol=TCP localport=3389
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
Write-Host 'Done'

# Remove AppxPackages Win10
# Write-Host "Removing Win10 bloated apps..."
# Get-AppxPackage -Name * | Remove-AppxPackage -ErrorAction SilentlyContinue | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

# Disable RDP NLA
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0

# Disable Autologon
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /d 0 /f

# Extend the Windows Evaluation period
# slmgr -rearm