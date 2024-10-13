# Source: https://github.com/Orange-Cyberdefense/GOAD/blob/606d9cd9895d53cd36489b47196e20ed07d8a33c/ad/GOAD/scripts/constrained_delegation_kerb_only.ps1
# https://www.thehacker.recipes/ad/movement/kerberos/delegations/constrained#without-protocol-transition
Set-ADComputer -Identity "CD-SRV$" -ServicePrincipalNames @{Add = 'CIFS/cd-dc.child.client.ad' }
Get-ADComputer -Identity "CD-SRV$" | Set-ADAccountControl -TrustedToAuthForDelegation $true
Set-ADComputer -Identity "CD-SRV$" -Add @{'msDS-AllowedToDelegateTo' = @('CIFS/cd-dc.child.client.ad', 'CIFS/cd-dc') }