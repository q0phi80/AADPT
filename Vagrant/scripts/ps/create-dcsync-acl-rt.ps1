# Source: https://happycamper84.medium.com/set-acl-cheatsheet-6c79e0c2f32b

Import-Module ActiveDirectory
Set-Location AD:
$root = (Get-ADDomain).DistinguishedName
#Add ACL rule for the right “DCSync”
$acl = Get-ACL “$root”
$group = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup -Identity 'The Berbers').SID
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $group, ”ExtendedRight”, ”ALLOW”, ([GUID](“1131f6aa-9c07-11d1-f79f-00c04fc2dcd2”)).guid, ”None”, ([GUID](“00000000-0000-0000-0000-000000000000”)).guid))
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $group, ”ExtendedRight”, ”ALLOW”, ([GUID](“1131f6ad-9c07-11d1-f79f-00c04fc2dcd2”)).guid, ”None”, ([GUID](“00000000-0000-0000-0000-000000000000”)).guid))
#Apply above ACL rules
Set-ACL “$root” $acl

# To check if the ACL has been applied
# (Get-Acl $root).Access | Where-Object { ($_.IdentityReference -like “*The Berbers*”) }

# Another option
# Set-ADACL -SamAccountName 'The Berbers' -DistinguishedName 'DC=client,DC=ad' -GUIDRight DCSync -Verbose