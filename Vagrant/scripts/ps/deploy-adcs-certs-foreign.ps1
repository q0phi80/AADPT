Start-Sleep -Seconds 30
# $domain = "client.ad"
$password = ConvertTo-SecureString "vagrant" -asPlainText -Force
$username = "administrator@foreign.ad"
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

$ps = New-PSSession -ComputerName FN-DC -Credential $credential -ErrorAction Stop

Invoke-Command -Session $ps -FilePath "C:\Windows\Temp\adcs-cert-templates-fn.ps1"