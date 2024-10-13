# # This script creates a PSRemoting session from the ROOT DC to a ROOT Workstation box
# $user = "client\kwame.nkrumah"
# $pass = ConvertTo-SecureString "OneAfrica1964" -AsPlainText -Force
# $DomainCred = New-Object System.Management.Automation.PSCredential $user, $pass
# # Enter-PSSession -ComputerName ROOT-WKS01 -Credential $DomainCred
# $ps = New-PSSession -ComputerName ROOT-WKS01 -Credential $DomainCred
# Define user credentials (replace with actual values)

$user = "client\kwame.nkrumah"
$pass = ConvertTo-SecureString "OneAfrica1964" -AsPlainText -Force
$DomainCred = New-Object System.Management.Automation.PSCredential $user, $pass

$ps = New-PSSession -ComputerName 'RT-WKSTN' -Credential $DomainCred -ErrorAction Stop  # Stop on error

while ($true) {
    # Check if $ps session is active
    if ($ps -eq $null) {
        Write-Host "PSRemote session to RT-WKSTN not established. Attempting to reconnect..."
        $ps = New-PSSession -ComputerName RT-WKSTN -Credential $DomainCred -ErrorAction Stop -AsJob
    }
    else {
        Write-Host "PSRemote session to RT-WKSTN established."
    }

    # Wait 5 minutes (300 seconds) before next check
    Start-Sleep -Seconds 300
}

Write-Host "Bot setup completed"