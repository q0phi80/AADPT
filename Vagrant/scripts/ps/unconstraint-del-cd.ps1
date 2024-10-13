# Run on CHILD DC
Get-ADComputer -Identity "CD-WKSTN" | Set-ADAccountControl -TrustedForDelegation $true