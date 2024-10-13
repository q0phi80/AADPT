# Source: https://raw.githubusercontent.com/q0phi80/cybersecurity-ops/main/02-Resources/Vagrant/scripts/enable-rdp.bat

netsh advfirewall firewall add rule name="Open Port 3389" dir=in action=allow protocol=TCP localport=3389
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f