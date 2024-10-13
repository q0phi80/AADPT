Import-Module ServerManager

#Install IIS Feature
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

#Install FTP feature
Install-WindowsFeature -Name Web-Ftp-Server -IncludeAllSubFeature -IncludeManagementTools -Verbose

# Define the variables.
# --------------------------------------------------------------------
$InetPubRoot = "C:\Inetpub"
$InetPubLog = "C:\Inetpub\Log"
$InetPubWWWRoot = "C:\Inetpub\WWWRoot"

# Loading IIS Modules
# --------------------------------------------------------------------
# Import-Module WebAdministration

# --------------------------------------------------------------------
# Creating IIS Folder Structure
# --------------------------------------------------------------------
New-Item -Path $InetPubRoot -type directory -Force -ErrorAction SilentlyContinue
New-Item -Path $InetPubLog -type directory -Force -ErrorAction SilentlyContinue
New-Item -Path $InetPubWWWRoot -type directory -Force -ErrorAction SilentlyContinue

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
# $Command = "%windir%\system32\inetsrv\appcmd set config -section:system.applicationHost/sites -siteDefaults.logfile.directory:$InetPubLog"
# cmd.exe /c $Command
# $Command = "%windir%\system32\inetsrv\appcmd set config -section:system.applicationHost/log -centralBinaryLogFile.directory:$InetPubLog"
# cmd.exe /c $Command
# $Command = "%windir%\system32\inetsrv\appcmd set config -section:system.applicationHost/log -centralW3CLogFile.directory:$InetPubLog"
# cmd.exe /c $Command

#Changing the Default Website location
# Set-ItemProperty 'IIS:\Sites\Default Web Site' -name physicalPath -value $InetPubWWWRoot

# Checking to prevent common errors
# --------------------------------------------------------------------
If (!(Test-Path "C:\inetpub\temp\apppools")) {
    New-Item -Path "C:\inetpub\temp\apppools" -type directory -Force -ErrorAction SilentlyContinue
}

#Creating new FTP site
$SiteName = "FTP Site"
$RootFolderpath = "C:\Inetpub\WWWRoot"
$PortNumber = 21
$FTPUserGroupName = "FTP Users Group"
$FTPUserName = "ftp"
$FTPPassword = ConvertTo-SecureString "Password123" -AsPlainText -Force

if (!(Test-Path $RootFolderpath)) {
    # if the folder doesn't exist
    New-Item -Path $RootFolderpath -ItemType Directory # create the folder
}

New-WebFtpSite -Name $SiteName -PhysicalPath $RootFolderpath -Port $PortNumber -Verbose -Force 

#Creating the local Windows group
if (!(Get-LocalGroup $FTPUserGroupName  -ErrorAction SilentlyContinue)) {
    #if the group doesn't exist
    New-LocalGroup -Name $FTPUserGroupName `
        -Description "Members of this group can connect to FTP server" #create the group
}

# Creating an FTP user
If (!(Get-LocalUser $FTPUserName -ErrorAction SilentlyContinue)) {
    New-LocalUser -Name $FTPUserName -Password $FTPPassword `
        -Description "User account to access FTP server" `
        -UserMayNotChangePassword
} 

# Add the created FTP user to the group FTP Users Group
Add-LocalGroupMember -Name $FTPUserGroupName -Member $FTPUserName -ErrorAction SilentlyContinue

# Enabling basic authentication on the FTP site
$param = @{
    Path    = 'IIS:\Sites\FTP Site'
    Name    = 'ftpserver.security.authentication.basicauthentication.enabled'
    Value   = $true 
    Verbose = $True
}
Set-ItemProperty @param

# Adding authorization rule to allow FTP users 
# in the FTP group to access the FTP site
$param = @{
    PSPath   = 'IIS:\'
    Location = $SiteName 
    Filter   = '/system.ftpserver/security/authorization'
    Value    = @{ accesstype = 'Allow'; roles = $FTPUserGroupName; permissions = 1 } 
}

Add-WebConfiguration @param

# Changing SSL policy of the FTP site
'ftpServer.security.ssl.controlChannelPolicy', 'ftpServer.security.ssl.dataChannelPolicy' | 
ForEach-Object {
    Set-ItemProperty -Path "IIS:\Sites\FTP Site" -Name $_ -Value $false
}

$ACLObject = Get-Acl -Path $RootFolderpath
$ACLObject.SetAccessRule(
    ( # Access rule object
        New-Object System.Security.AccessControl.FileSystemAccessRule(
            $FTPUserGroupName,
            'ReadAndExecute',
            'ContainerInherit,ObjectInherit',
            'None',
            'Allow'
        )
    )
)
Set-Acl -Path $RootFolderpath -AclObject $ACLObject

# Checking the NTFS permissions on the FTP root folder
Get-Acl -Path $RootFolderpath | ForEach-Object Access

# Test FTP Port and FTP access
# Test-NetConnection -ComputerName localhost -Port 21

$Command = "IISRESET"
Invoke-Expression -Command $Command