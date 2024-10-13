# Add Local Group membership
net localgroup "Remote Desktop Users" "foreign\Basotho Kingdom" /add
net localgroup "Administrators" "foreign\queen.makeda" /add

# Enable RDP
Write-Host "Enabling RDP..."
netsh advfirewall firewall add rule name="Open Port 3389" dir=in action=allow protocol=TCP localport=3389
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f

# Install NFS on the server
Write-Host "Installing NFS service..."
Import-Module ServerManager
Add-WindowsFeature FS-NFS-Service
Import-Module NFS

# Disable RDP NLA
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0

# Disable autologon
Write-Host "Disabling autologon..."
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /d 0 /f

Write-Host 'Done provisioning'
