Start-Sleep -Seconds 30
# $domain = "client.ad"
$password = ConvertTo-SecureString "vagrant" -asPlainText -Force
$username = "administrator@client.ad"
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

$ps = New-PSSession -ComputerName RT-DC -Credential $credential -ErrorAction Stop

Invoke-Command -Session $ps -FilePath "C:\adcs-cert-templates-rt.ps1"