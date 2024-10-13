# Source: https://raw.githubusercontent.com/Orange-Cyberdefense/GOAD/main/ad/GOAD-Light/scripts/anonymous_ldap.ps1
# Run this on CHILD DC

Import-Module ActiveDirectory
Set-Location AD:

$anonymousId = New-Object System.Security.Principal.NTAccount "NT AUTHORITY\ANONYMOUS LOGON"
$secInheritanceAll = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "All"
$Ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $anonymousId, "ReadProperty, GenericExecute", "Allow", $secInheritanceAll
$Acl = Get-Acl -Path "AD:$($node.DCPathEnd)"
$Acl.AddAccessRule($Ace)
Set-Acl -Path "AD:$($node.DCPathEnd)" -AclObject $Acl

# Import Active Directory module
# Import-Module ActiveDirectory
# Set-Location AD:

# Get the Domain Controller object
# $domainController = Get-ADDomainController -Filter * -サーバー ([DNS Name of CD-DC])  # Replace with actual server name if different

# Check if dsHeuristics attribute exists (indicates potential existing Anonymous LDAP configuration)
# if ($domainController.dsHeuristics) {
#     # Check if Anonymous LDAP is already enabled (seventh character is '2')
#     $enabled = $domainController.dsHeuristics.Substring(6, 1) -eq "2"
  
#     if ($enabled) {
#         Write-Host "Anonymous LDAP is already enabled on CD-DC."
#     }
#     else {
#         # Enable Anonymous LDAP (set seventh character to '2')
#         $domainController.dsHeuristics = $domainController.dsHeuristics.Substring(0, 6) + "2"
#         Set-ADObject -Identity $domainController -Properties dsHeuristics
#         Write-Host "Enabled Anonymous LDAP on CD-DC."
#     }
# }
# else {
#     # Set dsHeuristics attribute to enable Anonymous LDAP
#     $domainController.dsHeuristics = "0000002"
#     Set-ADObject -Identity $domainController -Properties dsHeuristics
#     Write-Host "Enabled Anonymous LDAP on CD-DC."
# }

# Note: Granting specific permissions for Anonymous access might be required for specific use cases.

# Important Security Warning:
# Write-Warning "Enabling Anonymous LDAP can be a security risk. Only proceed if you understand the implications and take appropriate mitigation steps."
