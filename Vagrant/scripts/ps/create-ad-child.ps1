# Purpose: Creates the child domain and join it to the parent domain client.ad
# Source: https://github.com/StefanScherer/adfs2, modified script to allow it to take params

Write-Host 'Disable the NAT inteface'

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


$ip = "192.168.56.11"

$subnet = $ip -replace "\.\d+$", ""

if ((Get-WmiObject win32_computersystem).partofdomain -eq $false) {

  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing AD Services"
  Import-Module ServerManager
  Add-WindowsFeature RSAT-AD-PowerShell, RSAT-AD-AdminCenter, DNS, DHCP 
 
  # After the installation of the AD features, pause for 30 seconds
  # Wait until we can access the AD. this is needed to prevent errors like:
  #   Unable to find a default server with Active Directory Web Services running.
  Start-Sleep -Seconds 10
  Install-WindowsFeature AD-domain-services
  #Import-Module ServerManager
  Import-Module ADDSDeployment
  #Import-Module ActiveDirectory
  # Install-WindowsFeature -Name LDAP -IncludeAllSubFeature
  
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Creating domain controller..."
  # Disable password complexity policy
  secedit /export /cfg C:\secpol.cfg
  (Get-Content C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
  secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY
  Remove-Item -force C:\secpol.cfg -confirm:$false

  # Set administrator password
  $computerName = $env:COMPUTERNAME
  $adminPassword = "vagrant"
  $adminUser = [ADSI] "WinNT://$computerName/Administrator,User"
  $adminUser.SetPassword($adminPassword)

# Set DNS servers to parent and self
  $newDNSServers = "192.168.56.10", "127.0.0.1"

  $adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -And ($_.IPAddress).StartsWith($subnet) }
  if ($adapters) {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Setting DNS"
    # Don't do this in Azure. If the network adatper description contains "Hyper-V", this won't apply changes.
    $adapters | ForEach-Object {if (!($_.Description).Contains("Hyper-V")) {$_.SetDNSServerSearchOrder($newDNSServers)}}
  }

  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Excluding NAT interface from DNS"
  # $nics=Get-WmiObject "Win32_NetworkAdapterConfiguration where IPEnabled='TRUE'" |Where-Object { $_.IPAddress[0] -ilike "10.0.2.*" }
  $nics = Get-WmiObject "Win32_NetworkAdapterConfiguration where IPEnabled='TRUE'" | Where-Object { $_.IPAddress[0] -ilike "10.*" }
  $dnslistenip=$nics.IPAddress
  $dnslistenip
  # dnscmd /ResetListenAddresses  $dnslistenip

  $nics=Get-WmiObject "Win32_NetworkAdapterConfiguration where IPEnabled='TRUE'" |Where-Object { $_.IPAddress[0] -ilike "10.*" }
  foreach($nic in $nics) {
    $nic.DomainDNSRegistrationEnabled = $false
    $nic.SetDynamicDNSRegistration($false) |Out-Null
  }

}

# Uninstall Windows Defender
If ((Get-Service -Name WinDefend -ErrorAction SilentlyContinue).status -eq 'Running') {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Uninstalling Windows Defender..."
  Try {
    Uninstall-WindowsFeature Windows-Defender -ErrorAction Stop
    Uninstall-WindowsFeature Windows-Defender-Features -ErrorAction Stop
  }
  Catch {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Windows Defender did not uninstall successfully..."
  }
}

# WinRM stuff is necessary after the Creation of Domain since it kills it for some reason
  Write-Host "Reconfiguring WinRM"
  winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
  winrm set winrm/config/service '@{AllowUnencrypted="true"}'
  winrm set winrm/config/service/auth '@{Basic="true"}'
  winrm set winrm/config/client/auth '@{Basic="true"}'

  
  Start-Sleep -m 200

  # Enable the NAT interface to be able to reconnect to the VM for subsequent provisioning
  
  netsh interface set interface name="Ethernet" enable