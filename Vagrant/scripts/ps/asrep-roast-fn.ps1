Get-ADUser -Identity "ndongo.sima" | Set-ADAccountControl -DoesNotRequirePreAuth:$true
