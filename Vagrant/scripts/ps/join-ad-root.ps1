# Purpose: Joins a Windows host to the CLIENT domain
# Source: https://github.com/StefanScherer/adfs2,  modified script to allow it to take params

Write-Host 'Disabling the NAT inteface ...'

# netsh interface set interface name="Ethernet" disable

# Get the Ethernet adapter information
$ethernetAdapter = Get-NetAdapter -Name "Ethernet"

# Check if the adapter is found
if ($ethernetAdapter) {
    # Check if the adapter is enabled
    if ($ethernetAdapter.Status -eq "Enabled") {
        # Disable the adapter if enabled
        Disable-NetAdapter -Name $ethernetAdapter.Name
        Write-Host "Ethernet adapter disabled."
    }
    else {
        # Message if already disabled
        Write-Host "Ethernet adapter is already disabled."
    }
}
else {
    # Error message if adapter not found
    Write-Error "Ethernet adapter not found. Please verify the name."
}

Write-Host 'Joining the domain ...'

Start-Sleep -m 2000

Write-Host "First, seting DNS to DC to join the domain ..."
$newDNSServers = "192.168.56.10"
$adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -match "192.168.56" }
$adapters | ForEach-Object { $_.SetDNSServerSearchOrder($newDNSServers) }

Start-Sleep -m 2000

Write-Host "Now joining the domain ..."

$user = "client\vagrant"
$pass = ConvertTo-SecureString "vagrant" -AsPlainText -Force
$DomainCred = New-Object System.Management.Automation.PSCredential $user, $pass
Add-Computer -DomainName "client.ad" -Server "rt-dc.client.ad" -credential $DomainCred -PassThru -Force

Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "vagrant"
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value "vagrant"
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultDomainName -Value "CLIENT"