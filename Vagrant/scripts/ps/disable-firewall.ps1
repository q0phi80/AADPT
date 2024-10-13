# Disable Windows Firewall on all profiles
$profiles = Get-NetFirewallProfile

$profiles | ForEach-Object {
    Set-NetFirewallProfile -Name $_.Name -Enabled False
}

Write-Host "Windows Firewall disabled on all profiles."
