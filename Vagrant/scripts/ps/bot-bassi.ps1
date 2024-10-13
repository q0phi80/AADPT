# Source : https://raw.githubusercontent.com/Orange-Cyberdefense/GOAD/main/ad/NHA/files/bot.ps1
# Run this from CHILD DC
$pass = ConvertTo-SecureString 'Ghana1062' -AsPlainText -Force;
$creds = New-Object System.Management.Automation.PSCredential ('child.client.ad\ghana.bassi', $pass);
Invoke-Command -Computername cd-srv.child.client.ad -ScriptBlock { sleep 55 } -Credential $creds -AsJob