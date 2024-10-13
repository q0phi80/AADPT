# This script joins the child domain (child) to the parent domain (client.ad)
# This script creates the child-parent trust
# Run this on the CHILD DC cd-dc

# Set the Default Drive to preven the WARNING: Error initializing default drive: 'Unable to find a default server with Active Directory Web Services  running.'.
$Env:ADPS_LoadDefaultDrive = 0

# Enable and start the Active Directory Web Services
Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools
Start-Sleep -Seconds 30
Set-Service -Name ADWS -StartupType Automatic
Start-Service -Name ADWS

Start-Sleep -Seconds 30
Import-Module ActiveDirectory
Write-Host 'Disable the NAT inteface'
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

# Proceed with domain joining if checks pass
# Write-Host "Active Directory module and RSAT-AD-PowerShell feature available. Proceeding..."

$adminPassword = ConvertTo-SecureString "vagrant" -AsPlainText -Force
$safeModePassword = ConvertTo-SecureString "Fluffy123!" -AsPlainText -Force

Install-ADDSDomain -Credential (New-Object System.Management.Automation.PSCredential "administrator@client.ad", $adminPassword) -DatabasePath "C:\Windows\NTDS" -NewDomainName 'child' -ParentDomainName 'client.ad' -InstallDNS -CreateDNSDelegation -SiteName 'Default-First-Site-Name' -SafeModeAdministratorPassword $safeModePassword -AllowDomainReinstall -NewDomainNetbiosName "CHILD" -DomainMode 'WinThreshold' -DomainType 'ChildDomain' -Force -ErrorAction Stop
