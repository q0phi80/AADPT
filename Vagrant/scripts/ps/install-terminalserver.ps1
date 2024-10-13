# Source: https://raw.githubusercontent.com/StefanScherer/adfs2/master/scripts/install-terminalserver.ps1
# Run this on CHILD SERVER
Import-Module ServerManager
Add-WindowsFeature -Name "RDS-RD-Server" -IncludeAllSubFeature