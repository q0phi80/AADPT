# Source: https://4sysops.com/archives/how-to-configure-computer-delegation-with-powershell/
# Run this on the CHILD DC

$cdsrv = Get-ADComputer -Identity "CD-SRV"
Set-ADComputer $cdsrv -PrincipalsAllowedToDelegateToAccount (Get-ADComputer CD-WKSTN)