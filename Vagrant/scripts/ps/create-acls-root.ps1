# Source: https://raw.githubusercontent.com/Orange-Cyberdefense/GOAD/main/ad/GOAD-Light/scripts/acl.ps1

Import-Module ActiveDirectory
Set-Location AD:

###########################################################################################################
# SetAcl  $for ---- $right ----> $to
###########################################################################################################
Function SetAcl($for, $to, $right, $inheritance) {
    $forSID = New-Object System.Security.Principal.SecurityIdentifier (Get-ADUser $for).SID
    $objOU = ($to).DistinguishedName
    $objAcl = get-acl $objOU
    # https://docs.microsoft.com/fr-fr/dotnet/api/system.directoryservices.activedirectoryrights?view=dotnet-plat-ext-5.0
    $adRight = [System.DirectoryServices.ActiveDirectoryRights] $right # https://docs.microsoft.com/fr-fr/dotnet/api/system.directoryservices.activedirectoryrights?view=dotnet-plat-ext-5.0
    $type = [System.Security.AccessControl.AccessControlType] "Allow" # https://docs.microsoft.com/fr-fr/dotnet/api/system.security.accesscontrol.accesscontroltype?view=dotnet-plat-ext-5.0
    $inheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] $inheritance # https://docs.microsoft.com/fr-fr/dotnet/api/system.directoryservices.activedirectorysecurityinheritance?view=dotnet-plat-ext-5.0
    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $forSID, $adRight, $type, $inheritanceType
    $objAcl.AddAccessRule($ace)
    Set-Acl -AclObject $objAcl -path $objOU
}

# https://jorgequestforknowledge.wordpress.com/2014/08/20/powershell-and-dacls-in-ad-adding-ace-for-some-extended-right-on-some-object/
Function SetAclExtended($for, $to, $right, $extendedRightGUID, $inheritance) {
    $forSID = New-Object System.Security.Principal.SecurityIdentifier (Get-ADUser $for).SID
    $objOU = ($to).DistinguishedName
    $objAcl = get-acl $objOU
    # https://docs.microsoft.com/fr-fr/dotnet/api/system.directoryservices.activedirectoryrights?view=dotnet-plat-ext-5.0
    $adRight = [System.DirectoryServices.ActiveDirectoryRights] $right # https://docs.microsoft.com/fr-fr/dotnet/api/system.directoryservices.activedirectoryrights?view=dotnet-plat-ext-5.0
    $type = [System.Security.AccessControl.AccessControlType] "Allow" # https://docs.microsoft.com/fr-fr/dotnet/api/system.security.accesscontrol.accesscontroltype?view=dotnet-plat-ext-5.0
    $inheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] $inheritance # https://docs.microsoft.com/fr-fr/dotnet/api/system.directoryservices.activedirectorysecurityinheritance?view=dotnet-plat-ext-5.0

    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $forSID, $adRight, $type, $extendedRightGUID, $inheritanceType
    $objAcl.AddAccessRule($ace)
    Set-Acl -AclObject $objAcl -path $objOU
}

## acl values :
# AccessSystemSecurity
# CreateChild
# Delete
# DeleteChild
# DeleteTree
# ExtendedRight
# GenericAll
# GenericExecute
# GenericRead
# GenericWrite
# ListChildren
# ListObject
# ReadControl
# ReadProperty
# Self
# Synchronize
# WriteDacl
# WriteOwner
# WriteProperty 

## extend rights
# "00299570-246d-11d0-a768-00aa006e0529" {$right = "User-Force-Change-Password"}
# "45ec5156-db7e-47bb-b53f-dbeb2d03c40"  {$right = "Reanimate-Tombstones"}
# "bf9679c0-0de6-11d0-a285-00aa003049e2" {$right = "Self-Membership"}
# "ba33815a-4f93-4c76-87f3-57574bff8109" {$right = "Manage-SID-History"}
# "1131f6ad-9c07-11d1-f79f-00c04fc2dcd2" {$right = "DS-Replication-Get-Changes-All"}

# ACL abuse scenarios
# https://sensepost.com/blog/2020/ace-to-rce/
# https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces
# https://adsecurity.org/?p=3658

# king.moshoeshoe - ForceChangePassword pharoah.ramses
# forcechangepassword
# https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces#forcechangepassword
# https://docs.microsoft.com/fr-fr/windows/win32/adschema/r-user-change-password
SetAclExtended (Get-ADUser "king.moshoeshoe") (Get-ADUser "pharoah.ramses") "ExtendedRight" "00299570-246d-11d0-a768-00aa006e0529" "None"

# genericwrite-on-user
# https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces#genericwrite-on-user
SetAcl (Get-ADUser "pharoah.ramses") (Get-ADUser "pharoah.hatshepsut") "GenericWrite" "None"

# pharoah.hatshepsut - WriteDACL on julius.nyerere
SetAcl (Get-ADUser "pharoah.hatshepsut") (Get-ADUser "julius.nyerere") "WriteDacl" "None"

# julius.nyerere - AddSelf to group “The Berbers”
# self-self-membership-on-group
# https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces#self-self-membership-on-group
SetAclExtended (Get-ADUser "julius.nyerere") (Get-ADGroup "The Berbers") "Self" "bf9679c0-0de6-11d0-a285-00aa003049e2" "None"

# “The Berbers” - AddMember to group “Songhai Empire”
# writeproperty-on-group
# https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces#writeproperty-on-group
SetAcl (Get-ADUser "julius.nyerere") (Get-ADGroup "The Berbers") "WriteProperty" "All"

# genericall-genericwrite-write-on-computer
# https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces#genericall-genericwrite-write-on-computer
SetAcl (Get-ADUser "queen.cleopatra") (Get-ADComputer "rt-dc") "GenericAll" "None"