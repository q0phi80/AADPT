# https://techexpert.tips/powershell/powershell-configure-genericwrite-permission-user-account/
Import-Module ActiveDirectory
Set-Location AD:
# $root = (Get-ADDomain).DistinguishedName
#Add ACL rule for the right “Write”

# $acl = Get-ACL “$root”
# $group = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup -Identity 'Kush Kingdom').SID

# A script to add ACL rule for GenericWrite for the Kush Kingdom group to the RT-DC
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