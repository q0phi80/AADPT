# Create the necessary directories
New-Item -ItemType Directory -Path "C:\setup"
New-Item -ItemType Directory -Path "C:\setup\mssql"
New-Item -ItemType Directory -Path "C:\setup\mssql\media"

# Move the MSSQL Config file to the setup location
Move-Item C:\sql_config.ini -Destination C:\setup\mssql\

$domain_controller = "cd-dc.child.client.ad"

# Download URL for SQL Server Express 2019 installer
$download_Url = "https://download.microsoft.com/download/7/f/8/7f8a9c43-8c8a-4f7c-9f92-83c18d96b681/SQL2019-SSEI-Expr.exe"

# Download location (replace with desired path)
$downloadDest = "C:\setup\mssql\sql_installer.exe"

# Check if the installer file already exists

$installerFile = Test-Path -Path "C:\setup\mssql\sql_installer.exe"

if (!$installerFile) {
    # Download the installer
    # Invoke-WebRequest -Uri $download_url -OutFile "C:\setup\mssql\sql_installer.exe"
    Invoke-WebRequest -Uri $download_Url -OutFile $downloadDest
}

$connection_type = "connection_type_2019"
$mssql_service_instance = "MSSQLSERVER"
$mssql_service_name = "MSSQLSERVER"
$config_file = "C:\setup\mssql\sql_conf.ini"

# Write-Host "MSSQL version        : $sql_version"
Write-Host "MSSQL service name   : $mssql_service_name"
Write-Host "MSSQL download url   : $download_Url"
Write-Host "MSSQL instance       : $sql_instance_name"
Write-Host "MSSQL connection use : $connection_type"

# ... other variables based on your needs (sql_version, SQLSVCACCOUNT, ...)

# Add Service Account to Log on as a Service
$SQLSVCACCOUNT == "NT AUTHORITY\\NETWORK SERVICE"

if ($SQLSVCACCOUNT -ne "NT AUTHORITY\NETWORK SERVICE") {
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ServicePrincipalName" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ServicePrincipalName" -Name "$SQLSVCACCOUNT" -Value "MSSQLSvc/$env:COMPUTERNAME" -Type MultiString
    # Set-ADUser -Identity $SQLSVCACCOUNT -Add @{'msDS-AllowedToDelegateTo'=@{('CIFS/' + $domain_controller), ('CIFS/' + child-dc01)}}
    # Set-ADAccountControl -Identity $SQLSVCACCOUNT -TrustedToAuthForDelegation $true
    # Set-ADUser -Identity $SQLSVCACCOUNT -Add @{'msDS-AllowedToDelegateTo'=@('CIFS/child-dc01.child.client.ad','CIFS/child-dc01')}
    # Set-ADAccountControl -Identity $SQLSVCACCOUNT -TrustedToAuthForDelegation $true

  
    Set-ADUser -Identity $SQLSVCACCOUNT -ServicePrincipalNames @{Add = 'MSSQLSvc/cd-srv.child.client.ad' }
    Get-ADUser -Identity $SQLSVCACCOUNT | Set-ADAccountControl -TrustedToAuthForDelegation $true
    Set-ADUser -Identity $SQLSVCACCOUNT -Add @{'msDS-AllowedToDelegateTo' = @('CIFS/cd-dc.child.client.ad', 'CIFS/cd-dc') }
  
}

$serviceExists = Get-Service -Name $mssql_service_name -ErrorAction SilentlyContinue
if (!$serviceExists) {
    # Install the database
    & C:\setup\mssql\sql_installer.exe /ConfigurationFile=C:\setup\mssql\sql_conf.ini /IACCEPTSQLSERVERLICENSETERMS /MEDIAPATH=C:\setup\mssql\media /QUIET /HIDEPROGRESSBAR
    $installAttempts = 0
    while (($installAttempts -lt 3) -and (!(Test-Connection -ComputerName $env:COMPUTERNAME -Port 1433))) {
        Start-Sleep -Seconds 120
        $installAttempts++
    }
    if (!(Test-Connection -ComputerName $env:COMPUTERNAME -Port 1433)) {
        Write-Error "MSSQL Installation Failed!"
        Exit-PSSession
    }
}



# Remove downloaded installer (optional)
# Remove-Item $downloadDest

# C:\SQLMedia\SQLServer2022> setup.exe /Q /IACCEPTSQLSERVERLICENSETERMS /ACTION="install"
# /PID="AAAAA-BBBBB-CCCCC-DDDDD-EEEEE" /FEATURES=SQL, AS, IS
# /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT="NT AUTHORITY\NETWORK SERVICE"
# /SQLSVCPASSWORD="Password123" /SQLSYSADMINACCOUNTS="MyDomain\MyAccount "
# /AGTSVCACCOUNT="MyDomain\MyAccount" /AGTSVCPASSWORD="************"
# /ASSVCACCOUNT="MyDomain\MyAccount" /ASSVCPASSWORD="************"
# /ISSVCACCOUNT="MyDomain\MyAccount" /ISSVCPASSWORD="************"
# /ASSYSADMINACCOUNTS="MyDomain\MyAccount"

