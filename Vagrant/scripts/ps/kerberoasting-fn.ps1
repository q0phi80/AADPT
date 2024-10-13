# Run this on the FOREIGN DC
Set-ADUser -Identity "iis.admin" -ServicePrincipalNames @{Add = 'HTTP/iisadmin' }