# Source: https://github.com/StefanScherer/adfs2/blob/master/scripts/provision-dc.ps1
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
#$root = (Get-ADDomain).DistinguishedName
$root = "ad:\dc=client,dc=ad"

Write-Host "Additional steps on the Domain Controller..."

# Disable RDP NLA
Write-Host "Disabling RDP NLA..."
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0

# Unconstrained Delegation
Write-Host "Creating Unconstrained Delegation..."
Get-ADComputer -Identity "RT-WKSTN" | Set-ADAccountControl -TrustedForDelegation $true

# sidHistory
Write-Host "Setting up sidHistory..."
# netdom trust client.ad /d:foreign.ad /enablesidhistory:yes
netdom trust foreign.ad /d:client.ad /enablesidhistory:yes

# Account Description
Write-Host "Adding password in account Description..."
Get-ADUser -Identity "king.moshoeshoe" | Set-ADUser -Description "Pass: Basotho19"

# Add the domain account thomas.sankara from the child domain to the group Kush Kingdom in the parent domain.
# Foreign Membership
Write-Host "Setting up Domain Foreign Membership..."
$userParams = @{
    Identity = 'CN=Thomas Sankara,CN=Users,DC=child,DC=client,DC=ad'
    Server   = 'cd-dc.child.client.ad'
}
$User = Get-ADUser @userParams
$groupParams = @{
    Identity = 'CN=Kush Kingdom,CN=Users,DC=client,DC=ad'
    Server   = 'rt-dc.client.ad'
}
$Group = Get-ADGroup @groupParams
Add-ADGroupMember -Identity $Group -Members $User -Server "rt-dc.client.ad"

# DCSync ACL setup
Write-Host "Creating DCSync ACL..."
# Source: https://happycamper84.medium.com/set-acl-cheatsheet-6c79e0c2f32b
$acl = Get-ACL “$root”
$group = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup -Identity 'The Berbers').SID
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $group, ”ExtendedRight”, ”ALLOW”, ([GUID](“1131f6aa-9c07-11d1-f79f-00c04fc2dcd2”)).guid, ”None”, ([GUID](“00000000-0000-0000-0000-000000000000”)).guid))
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $group, ”ExtendedRight”, ”ALLOW”, ([GUID](“1131f6ad-9c07-11d1-f79f-00c04fc2dcd2”)).guid, ”None”, ([GUID](“00000000-0000-0000-0000-000000000000”)).guid))
Set-ACL “$root” $acl
# To check if the ACL has been applied
# (Get-Acl $root).Access | Where-Object { ($_.IdentityReference -like “*The Berbers*”) }
# (Get-Acl "ad:\dc=client,dc=ad").Access | ? {$_.IdentityReference -match 'The Berbers' -and ($_.ObjectType -eq "1131f6aa-9c07-11d1-f79f-00c04fc2dcd2" -or $_.ObjectType -eq "1131f6ad-9c07-11d1-f79f-00c04fc2dcd2" -or $_.ObjectType -eq "89e95b76-444d-4c62-991a-0facbeda640c" ) }
# Another option
# Set-ADACL -SamAccountName 'The Berbers' -DistinguishedName 'DC=client,DC=ad' -GUIDRight DCSync -Verbose

# GenericWrite ACL for the Kush Kingdom group to the RT-DC
Write-Host "Creating GenericWrite ACL..."
$group = (Get-ADGroup -Identity 'Kush Kingdom').SID
$dc = (Get-ADComputer -Identity "RT-DC")
$dcDistName = ($dc).distinguishedname
$dcDistNameAD = $dcDistName = "AD:$dc"
$dcACL = Get-Acl $dcDistNameAD
$MyADRights = [System.DirectoryServices.ActiveDirectoryRights] "GenericWrite"
$MyType = [System.Security.AccessControl.AccessControlType] "Allow"
$MyInheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "All"
$MyACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $group, $MyADRights, $MyType, $MyInheritanceType
$dcACL.AddAccessRule($MyACE)
Set-acl -aclobject $dcACL $dcDistNameAD
#check if applied
# (Get-ACL "AD:$((Get-ADComputer -Identity 'Kush Kingdom').distinguishedname)").access | Select IdentityReference, AccessControlType, ActiveDirectoryRights | Where-Object { $_.ActiveDirectoryRights -contains "GenericWrite" }

# PS-Remoting bot
# Write-Host "Creating PS Remoting session..."
# $pass = ConvertTo-SecureString 'OneAfrica1964' -AsPlainText -Force;
# $creds = New-Object System.Management.Automation.PSCredential ('client\kwame.nkrumah', $pass);
# Invoke-Command -Computername 'RT-WKSTN' -ScriptBlock { sleep 55 } -Credential $creds -AsJob
# Source: https://raw.githubusercontent.com/Orange-Cyberdefense/GOAD/main/ad/GOAD-Light/scripts/rdp_scheduler.ps1

$pass = ConvertTo-SecureString 'OneAfrica1964' -AsPlainText -Force;
$creds = New-Object System.Management.Automation.PSCredential ('client\kwame.nkrumah', $pass);
$task = "/c powershell Invoke-Command -Computername 'RT-WKSTN.client.ad' -ScriptBlock { sleep 55 } -Credential $creds -AsJob"
$repeat = (New-TimeSpan -Minutes 1)
$taskName = "psremoting_bot_rt"
$user = "client\vagrant"
$password = "vagrant"
$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "$task"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $repeat
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd
$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -like $taskName }
if ($taskExists) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User $user -Password $password -Settings $settings

# Enroll ADCS Certificate templates
Write-Host "Enrolling certificate templates..."
# Source: https://github.com/arth0sz/Practice-AD-CS-Domain-Escalation
# Source: https://github.com/Orange-Cyberdefense/GOAD/tree/main/ansible/roles/adcs_templates/files

$templateNames = @("ESC1", "ESC2", "ESC3-1", "ESC3-2", "ESC4")

Write-Host "Publishing and Enrolling vulnerable certificates..."

foreach ($templateName in $templateNames) {
    # Check if template exists
    $templateExists = Get-ADCSTemplate -DisplayName $templateName -ErrorAction SilentlyContinue

    if (!$templateExists) {
        # Create and publish template
        New-ADCSTemplate -DisplayName $templateName -JSON (Get-Content C:\$templateName.json -Raw) -Publish
        Write-Host "Published template: $templateName"
    }
    else {
        Write-Host "Template '$templateName' already exists, skipping..."
    }

    # Set ACL only if the template was published
    if ($templateExists) {
        Set-ADCSTemplateACL -DisplayName $templateName -Identity 'CLIENT\Domain Users', 'CLIENT\Domain Computers' -Enroll -AutoEnroll
        Write-Host "Set permissions for '$templateName'"
    }
}

Write-Host "Provisioning completed..."
