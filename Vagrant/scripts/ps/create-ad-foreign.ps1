# Purpose: Creates the "foreign".ad" domain
# Source: https://github.com/StefanScherer/adfs2, modified script to allow it to take params

param ([String] $ip, [String] $domain, [String] $netbiosName)

$subnet = $ip -replace "\.\d+$", ""


if ((Get-WmiObject win32_computersystem).partofdomain -eq $false) {

  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing RSAT tools"
  Import-Module ServerManager
  Add-WindowsFeature RSAT-AD-PowerShell,RSAT-AD-AdminCenter

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

  $PlainPassword = "vagrant" # "P@ssw0rd"
  $SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force

  # Windows Server 20022
  Install-WindowsFeature AD-domain-services
  Import-Module ADDSDeployment
  Install-ADDSForest `
    -SafeModeAdministratorPassword $SecurePassword `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName $domain `
    -DomainNetbiosName $netbiosName `
    -ForestMode "7" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$true `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true

  $newDNSServers = "192.168.56.10", "127.0.0.1"

  $adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -And ($_.IPAddress).StartsWith($subnet) }
  if ($adapters) {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Setting DNS"
    # Don't do this in Azure. If the network adatper description contains "Hyper-V", this won't apply changes.
    $adapters | ForEach-Object {if (!($_.Description).Contains("Hyper-V")) {$_.SetDNSServerSearchOrder($newDNSServers)}}
  }
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Setting timezone to UTC"
  c:\windows\system32\tzutil.exe /s "UTC"

  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Excluding NAT interface from DNS"
  # $nics=Get-WmiObject "Win32_NetworkAdapterConfiguration where IPEnabled='TRUE'" |Where-Object { $_.IPAddress[0] -ilike "10.0.2.*" }
  $nics = Get-WmiObject "Win32_NetworkAdapterConfiguration where IPEnabled='TRUE'" | Where-Object { $_.IPAddress[0] -ilike "10.*" }
  $dnslistenip=$nics.IPAddress
  $dnslistenip
  dnscmd /ResetListenAddresses  $dnslistenip

  $nics=Get-WmiObject "Win32_NetworkAdapterConfiguration where IPEnabled='TRUE'" |Where-Object { $_.IPAddress[0] -ilike "10.*" }
  foreach($nic in $nics) {
    $nic.DomainDNSRegistrationEnabled = $false
    $nic.SetDynamicDNSRegistration($false) |Out-Null
  }

  $RRs= Get-DnsServerResourceRecord -ZoneName $domain -type 1 -Name "@"
  foreach($RR in $RRs) {
    if ( (Select-Object  -InputObject $RR HostName,RecordType -ExpandProperty RecordData).IPv4Address -ilike "10.*") {
      Remove-DnsServerResourceRecord -ZoneName $domain -RRType A -Name "@" -RecordData $RR.RecordData.IPv4Address -Confirm
    }
  }
  Restart-Service DNS
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

  # Create DNS Conditional Forwarders for 2 way trust with the CLIENT domain
  Add-DnsServerConditionalForwarderZone -Name client.ad -MasterServers 192.168.56.10