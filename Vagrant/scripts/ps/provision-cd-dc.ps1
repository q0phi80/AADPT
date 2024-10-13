# Reference: https://github.com/q0phi80/mdt-lab-vagrant/blob/master/provision/domain-controller-configure.ps1
# wait until we can access the AD. this is needed to prevent errors like:
#   Unable to find a default server with Active Directory Web Services running.
# while ($true) {
#     try {
#         Get-ADDomain | Out-Null
#         break
#     }
#     catch {
#         Start-Sleep -Seconds 10
#     }
# }

Import-Module ActiveDirectory
# Set-Location AD:

Write-Host "Additional steps on domain controller"

# Relay-bot
# Write-Host "Running the relay bot that will generate network traffic..."
# $task = '/c powershell New-PSDrive -Name "Public" -PSProvider "FileSystem" -Root "\\CD-SR\Wabbit"'
# $repeat = (New-TimeSpan -Minutes 3)
# $taskName = "ntlm_bot"
# $user = "child.client.ad\jomo.kenyatta"
# $password = "Kenya64"

# $action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "$task"
# $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $repeat
# $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd

# $taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -like $taskName }
# if ($taskExists) {
#     Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
# }
# Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User $user -Password $password -Settings $settings

# Responder bot
# Write-Host "Running responder bot that will generate network traffic..."
# $task = '/c powershell New-PSDrive -Name "Public" -PSProvider "FileSystem" -Root "\\CD-WKSTN\fluffy"'
# $repeat = (New-TimeSpan -Minutes 2)
# $taskName = "responder_bot"
# $user = "child.client.ad\jomo.kenyatta"
# $password = "Kenya64"

# $action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "$task"
# $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $repeat
# $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd

# $taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -like $taskName }
# if ($taskExists) {
#     Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
# }
# Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User $user -Password $password -Settings $settings

# NTLM Relay bot
Write-Host "Running ntlm relay bot that will generate network share traffic for LLMNR and NTLM-related attacks..."
$task = '/c powershell New-PSDrive -Name "Public" -PSProvider "FileSystem" -Root "\\CD-SR\Fluffy"'
$repeat = (New-TimeSpan -Minutes 5)
$taskName = "relay_bot"
$user = "child.client.ad\idi.amin"
$password = "Uganda79Cr4ckMeIfUc4n"

$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "$task"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $repeat
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd

$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -like $taskName }
if ($taskExists) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User $user -Password $password -Settings $settings

# Unconstrained Delegation
Write-Host "Setting up Unconstrained Delegation..."
Get-ADComputer -Identity "CD-WKSTN" | Set-ADAccountControl -TrustedForDelegation $true

#RBCD
# Source: https://4sysops.com/archives/how-to-configure-computer-delegation-with-powershell/
Write-Host "Setting up Resource-Based Constrained Delegation..."
$cdsrv = Get-ADComputer -Identity "CD-SRV"
Set-ADComputer $cdsrv -PrincipalsAllowedToDelegateToAccount (Get-ADComputer CD-WKSTN)

# Constrained Delegation
# Source: https://github.com/Orange-Cyberdefense/GOAD/blob/606d9cd9895d53cd36489b47196e20ed07d8a33c/ad/GOAD/scripts/constrained_delegation_kerb_only.ps1
# https://www.thehacker.recipes/ad/movement/kerberos/delegations/constrained#without-protocol-transition
Write-Host "Setting up Constrained Delegation..."
# Set-ADComputer -Identity "CD-SRV$" -ServicePrincipalNames @{Add = 'HTTP/cd-dc.child.client.ad' }
# Set-ADComputer -Identity "CD-SRV$" -Add @{'msDS-AllowedToDelegateTo' = @('HTTP/cd-dc.child.client.ad', 'HTTP/cd-dc') }
# #Set-ADComputer -Identity "CD-SRV$" -Add @{'msDS-AllowedToDelegateTo' = @('HTTP/cd-dc.child.client.ad', 'HTTP/cd-dc') }
# Set-ADComputer -Identity "CD-SRV$" -Add @{'msDS-AllowedToDelegateTo' = @('CIFS/cd-dc.child.client.ad', 'CIFS/cd-dc')}
Set-ADComputer -Identity "CD-SRV$" -ServicePrincipalNames @{Add = 'CIFS/cd-dc.child.client.ad' }
Get-ADComputer -Identity "CD-SRV$" | Set-ADAccountControl -TrustedToAuthForDelegation $true
Set-ADComputer -Identity "CD-SRV$" -Add @{'msDS-AllowedToDelegateTo' = @('CIFS/cd-dc.child.client.ad', 'CIFS/cd-dc') }

# ASRep-Roasting
Write-Host "Creating ASRep-Roasting vuln..."
Get-ADUser -Identity "kofi.annan" | Set-ADAccountControl -DoesNotRequirePreAuth:$true

#Kerberoast
Write-Host "Creating Kerberoasting vuln..."
Set-ADUser -Identity "shaka.zulu" -ServicePrincipalNames @{Add = 'HTTP/Zulu' }

# Anonymous LDAP(throws errors. needs revisited.)
# Write-Host "Creating Anonymous LDAP vuln..."
# $anonymousId = New-Object System.Security.Principal.NTAccount "NT AUTHORITY\ANONYMOUS LOGON"
# $secInheritanceAll = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "All"
# $Ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $anonymousId, "ReadProperty, GenericExecute", "Allow", $secInheritanceAll
# $Acl = Get-Acl -Path "AD:$($node.DCPathEnd)"
# $Acl.AddAccessRule($Ace)
# Set-Acl -Path "AD:$($node.DCPathEnd)" -AclObject $Acl

# Enable RDP
Write-Host 'Enabling RDP...'
netsh advfirewall firewall add rule name="Open Port 3389" dir=in action=allow protocol=TCP localport=3389
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f

# Disalbe Autologin
Write-Host "Disabling Autologin..."
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /d 0 /f

# Session Bot
# Source : https://raw.githubusercontent.com/Orange-Cyberdefense/GOAD/main/ad/NHA/files/bot.ps1
Write-Host "Setting up a bot that creates a session from a DA to a server..."
$pass = ConvertTo-SecureString 'Ghana1062' -AsPlainText -Force;
$creds = New-Object System.Management.Automation.PSCredential ('child.client.ad\ghana.bassi', $pass);
Invoke-Command -Computername cd-srv.child.client.ad -ScriptBlock { sleep 55 } -Credential $creds -AsJob

# RDP Bot
# Write-Host "Setting up RDP session from a DA to a server..."
# if (-not(query session idi.amin /server:cd-srv)) {
#     #kill process if exist
#     Get-Process mstsc -IncludeUserName | Where { $_.UserName -eq "CHILD\idi.amin" } | Stop-Process
#     #run the command
#     mstsc /v:cd-srv
# }

