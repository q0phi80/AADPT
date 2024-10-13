# Run this on CD-DC
# Remoting from CD-DC to CD-SRV for Constrained Delegation attack

# Start-Sleep -Seconds 30
# $domain = "child.client.ad"
$password = ConvertTo-SecureString "OneAfrica1964" -asPlainText -Force
$username = "kwame.nkrumah@client.ad"
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

$ps = New-PSSession -ComputerName 'rt-wkstn.client.ad' -Credential $credential -ErrorAction Stop

# A PS-Remote session from RT-DC to RT-WKSTN
# Run this on RT-DC
$pass = ConvertTo-SecureString 'OneAfrica1964' -AsPlainText -Force;
$creds = New-Object System.Management.Automation.PSCredential ('client\kwame.nkrumah', $pass);
Invoke-Command -Computername 'rt-wkstn.client.ad' -ScriptBlock { Start-Sleep 55 } -Credential $creds -AsJob