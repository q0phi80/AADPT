# This command adds the domain account thomas.sankara from the child domain to the group Kush Kingdom in the parent domain.

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