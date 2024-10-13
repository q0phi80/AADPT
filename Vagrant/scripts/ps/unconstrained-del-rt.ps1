# Run on ROOT DC
Get-ADComputer -Identity "RT-WKSTN" | Set-ADAccountControl -TrustedForDelegation $true