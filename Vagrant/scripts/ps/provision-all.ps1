# Disable Windows Updates
Write-Host "Disabling Windows Updates..."

$service = Get-WmiObject Win32_Service -Filter 'Name="wuauserv"' -ComputerName "." -Ea 0
if ($service) {
  if ($service.StartMode -ne "Disabled") {
    $result = $service.ChangeStartMode("Disabled").ReturnValue
    if ($result) {
      "Failed to disable the 'wuauserv' service. The return value was $result."
    }
    else {
      "Successfully disabled the 'wuauserv' service"
    }

    if ($service.State -eq "Running") {
      $result = $service.StopService().ReturnValue
      if ($result) {
        "Failed to stop the 'wuauserv' service. The return value was $result."
      }
      else {
        "Successfully stopped the 'wuauserv' service."
      }
    }
  }
  else {
    "The 'wuauserv' service is already disabled."
  }
}
else {
  "Failed to retrieve the service 'wuauserv'."
}
Write-Host "Done disabling Windows Updates..."

# Disable Windows Firewall on all profiles
Write-Host "Disabling Windows Firewall..."
$profiles = Get-NetFirewallProfile
$profiles | ForEach-Object {
  Set-NetFirewallProfile -Name $_.Name -Enabled False
}
Write-Host "Done disabling Windows Firewall..."

# # Configure NAT Default Gateway
# Write-Host "Configuring Default Gateway on Host-only interface..."
# # Get the network adapter named "Ethernet 2"
# $adapter = Get-NetAdapter -Name "Ethernet 2"

# # Check if the adapter is found
# if ($adapter) {
#   # Disable DHCP (Optional)
#   Set-NetIPInterface -InterfaceIndex $adapter.ifIndex -Dhcp Disabled

#   # Set the Default Gateway
#   New-NetRoute -IfIndex $adapter.ifIndex -DestinationPrefix 192.168.0.0/16 -NextHop 192.168.56.1
#   # Set-NetRoute -IfIndex $adapter.ifIndex -DestinationPrefix 192.168.0.0/16 -NextHop 192.168.56.1
  
#   # Confirmation message
#   Write-Host "Default Gateway configured for Ethernet 2."
# }
# else {
#   # Error message if adapter not found
#   Write-Error "Ethernet 2 adapter not found. Please verify the adapter name."
# }
# Write-Host "Done configuring Default Gateway on Host-only interface..."

# Remove Desktop from This PC
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"
Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"
# Remove Documents from This PC
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}"
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}"
Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}"
Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}"
# Remove Downloads from This PC
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}"
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}"
Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}"
Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}"
# Remove Music from This PC
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"
Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"
Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"
# Remove Pictures from This PC
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}"
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"
Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}"
Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"
# Remove Videos from This PC
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}"
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"
Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}"
Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"
# Remove 3D Objects from This PC
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"

# Disable Ease of Access keyboard shortcuts
if ($(Get-WindowsEdition -Online).Edition -notmatch "cor") {
  Set-ItemProperty "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506"
  Set-ItemProperty "HKCU:\Control Panel\Accessibility\Keyboard Response" "Flags" "122"
  Set-ItemProperty "HKCU:\Control Panel\Accessibility\ToggleKeys" "Flags" "58"
}

# Setting view options
# Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideDrivesWithNoMedia" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSyncProviderNotifications" 0

# Setting default explorer view to This PC
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" 1

# Show all icons in the taskbar notification area
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Value 0

# Small taskbar & combine when full
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\" -Name "TaskbarSmallIcons" -Value 1
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\" -Name "TaskbarGlomLevel" -Value 1

# Disable hibernation
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power\" -Name "HiberFileSizePercent" -Value 0
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power\" -Name "HibernateEnabled" -Value 0

# Disable sleep
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
powercfg /change disk-timeout-ac 0
powercfg /change disk-timeout-dc 0
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0
powercfg /change hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 0

# Disable password expiration for Administrator and vagrant user
Set-LocalUser Administrator -PasswordNeverExpires $true
Set-LocalUser vagrant -PasswordNeverExpires $true

# Install VirtualBox Guest Addition
$ProgressPreference = "SilentlyContinue"

$webclient = New-Object System.Net.WebClient
$version_url = "http://download.virtualbox.org/virtualbox/LATEST.TXT"
$version = $webclient.DownloadString($version_url) -replace '\s', ''
$package = "VBoxGuestAdditions_$version.iso"
$url = "http://download.virtualbox.org/virtualbox/$version/$package"

Write-Output "***** Downloading Oracle VM VirtualBox Guest Additions"
$iso = "$Env:TEMP\$package"
$webclient.DownloadFile($url, $iso)

Write-Output "***** Mounting disk image at $iso"
Mount-DiskImage -ImagePath $iso

Write-Output "***** Installing VirtualBox Certificates"
$certdir = ((Get-DiskImage -ImagePath $iso | Get-Volume).Driveletter + ':\cert\')
$VBoxCertUtil = ($certdir + 'VBoxCertUtil.exe')
Get-ChildItem $certdir *.cer | ForEach-Object { & $VBoxCertUtil add-trusted-publisher $_.FullName --root $_.FullName }

Write-Output "***** Installing VirtualBox Guest Additions"
$exe = ((Get-DiskImage -ImagePath $iso | Get-Volume).Driveletter + ':\VBoxWindowsAdditions.exe')
$parameters = '/S'

Start-Process $exe $parameters -Wait

Write-Output "***** Dismounting & Deleting $iso"
Dismount-DiskImage -ImagePath $iso
Remove-Item $iso

Write-Host "Done with system provisioning..."

