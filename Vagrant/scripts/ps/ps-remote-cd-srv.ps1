# A PS-Remote session from CD-SRV to CD-WKSTN
# Run this on CD-SRV
$pass = ConvertTo-SecureString 'Fluffy123!' -AsPlainText -Force;
$creds = New-Object System.Management.Automation.PSCredential ('child\mansa.musa', $pass);
Invoke-Command -Computername 'CD-WKSTN' -ScriptBlock { Start-Sleep 55 } -Credential $creds -AsJob
#$task = Invoke-Command -Computername 'CD-WKSTN' -ScriptBlock { Start-Sleep 55 } -Credential $creds -AsJob

$password = ConvertTo-SecureString "Fluffy123!" -asPlainText -Force
$username = "mansa.musa@child.client.ad"
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

#Enter-PSSession -ComputerName 'cd-wkstn.child.client.ad' -Credential $credential -ErrorAction Stop
$ps = New-PSSession -ComputerName 'cd-wkstn.child.client.ad' -Credential $credential -ErrorAction Stop