Import-Module ActiveDirectory
Set-Location AD:
$root = (Get-ADDomain).DistinguishedName
#Add ACL rule for the right “Write”
$acl = Get-ACL “$root”
$group = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup -Identity 'Kush Kingdom').SID
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $group, ”ExtendedRight”, ”ALLOW”, ([GUID](“1131f6aa-9c07-11d1-f79f-00c04fc2dcd2”)).guid, ”None”, ([GUID](“00000000-0000-0000-0000-000000000000”)).guid))
$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $group, ”ExtendedRight”, ”ALLOW”, ([GUID](“1131f6ad-9c07-11d1-f79f-00c04fc2dcd2”)).guid, ”None”, ([GUID](“00000000-0000-0000-0000-000000000000”)).guid))
#Apply above ACL rules
Set-ACL “$root” $acl