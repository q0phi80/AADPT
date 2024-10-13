# Source:

Get-ADUser -Identity "kofi.annan" | Set-ADAccountControl -DoesNotRequirePreAuth:$true