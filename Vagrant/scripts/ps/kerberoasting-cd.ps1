# Run this on the CHILD DC
Set-ADUser -Identity "shaka.zulu" -ServicePrincipalNames @{Add = 'HTTP/Zulu'}