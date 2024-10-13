# Source: https://phackt.com/en-kerberos-constrained-delegation-with-protocol-transition
# https://github.com/Orange-Cyberdefense/GOAD/blob/main/ad/GOAD/scripts/constrained_delegation_use_any.ps1
# Constrained Delegation with Protocol Transition
Get-ADUser -Identity "iis.admin" | Set-ADAccountControl -TrustedToAuthForDelegation $True
Set-ADUser -Identity "iis.admin" -Add @{'msDS-AllowedToDelegateTo' = @('TIME/FN-DC.FOREIGN.AD', 'TIME/FN-DC')}