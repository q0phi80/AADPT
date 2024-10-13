# Source: https://raw.githubusercontent.com/StefanScherer/adfs2/master/scripts/install-iis.ps1
# Source: https://github.com/Humoud/BackBag-Lab-VM/blob/main/scripts/install-iis-utils.ps1

# Write-Host 'Install IIS'

# from http://stackoverflow.com/questions/10522240/powershell-script-to-auto-install-of-iis-7-and-above
# --------------------------------------------------------------------
# Define the variables.
# --------------------------------------------------------------------
$InetPubRoot = "C:\Inetpub"
$InetPubLog = "C:\Inetpub\Log"
$InetPubWWWRoot = "C:\Inetpub\WWWRoot"

# --------------------------------------------------------------------
# Loading Feature Installation Modules
# --------------------------------------------------------------------
Import-Module ServerManager

# --------------------------------------------------------------------
# Installing IIS
# --------------------------------------------------------------------
# Add-WindowsFeature -Name Web-Common-Http,Web-Asp-Net,Web-Net-Ext,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Http-Logging,Web-Request-Monitor,Web-Basic-Auth,Web-Windows-Auth,Web-Filtering,Web-Performance,Web-Mgmt-Console,Web-Mgmt-Compat,WAS -IncludeAllSubFeature

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing IIS..."
  # Get-WindowsFeature -Name Web-*
  # Get-WindowsOptionalFeature -Online -FeatureName "IIS-*" | findstr "FeatureName"
  dism /online /enable-feature /featurename:IIS-WebServer /all-
  dism /online /enable-feature /featurename:IIS-HttpRedirect /all-
  dism /online /enable-feature /featurename:IIS-WebDAV /all-
  dism /online /enable-feature /featurename:IIS-WebSockets /all-
  dism /online /enable-feature /featurename:IIS-ApplicationInit /all-
  dism /online /enable-feature /featurename:IIS-NetFxExtensibility /all
  dism /online /enable-feature /featurename:IIS-NetFxExtensibility45 /all
  dism /online /enable-feature /featurename:IIS-ISAPIExtensions /all
  dism /online /enable-feature /featurename:IIS-ISAPIFilter /all
  dism /online /enable-feature /featurename:IIS-ASPNET /all
  dism /online /enable-feature /featurename:IIS-ASPNET45 /all
  dism /online /enable-feature /featurename:IIS-ASP /all
  dism /online /enable-feature /featurename:IIS-CGI /all
  dism /online /enable-feature /featurename:IIS-CertProvider /all
  dism /online /enable-feature /featurename:IIS-BasicAuthentication /all
  dism /online /enable-feature /featurename:IIS-WindowsAuthentication /all
  dism /online /enable-feature /featurename:IIS-DigestAuthentication /all
  dism /online /enable-feature /featurename:IIS-ClientCertificateMappingAuthentication /all
  dism /online /enable-feature /featurename:IIS-IISCertificateMappingAuthentication /all
  dism /online /enable-feature /featurename:IIS-URLAuthorization /all
  dism /online /enable-feature /featurename:IIS-ManagementConsole /all
  dism /online /enable-feature /featurename:IIS-IPSecurity /all
  dism /online /enable-feature /featurename:IIS-ServerSideIncludes /all
  dism /online /enable-feature /featurename:IIS-FTPServer /all
  dism /online /enable-feature /featurename:IIS-FTPSvc /all

# --------------------------------------------------------------------
# Loading IIS Modules
# --------------------------------------------------------------------
Import-Module WebAdministration

# --------------------------------------------------------------------
# Creating IIS Folder Structure
# --------------------------------------------------------------------
New-Item -Path $InetPubRoot -type directory -Force -ErrorAction SilentlyContinue
New-Item -Path $InetPubLog -type directory -Force -ErrorAction SilentlyContinue
New-Item -Path $InetPubWWWRoot -type directory -Force -ErrorAction SilentlyContinue

# --------------------------------------------------------------------
# Copying old WWW Root data to new folder
# --------------------------------------------------------------------
$InetPubOldLocation = @(get-website)[0].physicalPath.ToString()
$InetPubOldLocation =  $InetPubOldLocation.Replace("%SystemDrive%",$env:SystemDrive)
# Copy-Item -Path $InetPubOldLocation -Destination $InetPubRoot -Force -Recurse

# --------------------------------------------------------------------
# Setting directory access
# --------------------------------------------------------------------
$Command = "icacls $InetPubWWWRoot /grant BUILTIN\IIS_IUSRS:(OI)(CI)(RX) BUILTIN\Users:(OI)(CI)(RX)"
cmd.exe /c $Command
$Command = "icacls $InetPubLog /grant ""NT SERVICE\TrustedInstaller"":(OI)(CI)(F)"
cmd.exe /c $Command

# --------------------------------------------------------------------
# Setting IIS Variables
# --------------------------------------------------------------------
#Changing Log Location
$Command = "%windir%\system32\inetsrv\appcmd set config -section:system.applicationHost/sites -siteDefaults.logfile.directory:$InetPubLog"
cmd.exe /c $Command
$Command = "%windir%\system32\inetsrv\appcmd set config -section:system.applicationHost/log -centralBinaryLogFile.directory:$InetPubLog"
cmd.exe /c $Command
$Command = "%windir%\system32\inetsrv\appcmd set config -section:system.applicationHost/log -centralW3CLogFile.directory:$InetPubLog"
cmd.exe /c $Command

#Changing the Default Website location
Set-ItemProperty 'IIS:\Sites\Default Web Site' -name physicalPath -value $InetPubWWWRoot

# --------------------------------------------------------------------
# Checking to prevent common errors
# --------------------------------------------------------------------
If (!(Test-Path "C:\inetpub\temp\apppools")) {
  New-Item -Path "C:\inetpub\temp\apppools" -type directory -Force -ErrorAction SilentlyContinue
}

# --------------------------------------------------------------------
# Deleting Old WWWRoot
# --------------------------------------------------------------------
# Remove-Item $InetPubOldLocation -Recurse -Force

# --------------------------------------------------------------------
# Resetting IIS
# --------------------------------------------------------------------
$Command = "IISRESET"
Invoke-Expression -Command $Command