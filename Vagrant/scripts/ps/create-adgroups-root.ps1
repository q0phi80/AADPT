# Reference: https://github.com/q0phi80/mdt-lab-vagrant/blob/master/provision/domain-controller-configure.ps1
# wait until we can access the AD. this is needed to prevent errors like:
#   Unable to find a default server with Active Directory Web Services running.
while ($true) {
    try {
        Get-ADDomain | Out-Null
        break
    }
    catch {
        Start-Sleep -Seconds 10
    }
}

$password = ConvertTo-SecureString "vagrant" -asPlainText -Force
$username = "administrator@client.ad"
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

Import-Module ActiveDirectory
try {
    New-ADGroup -Name "Kush Kingdom" -SamAccountName "Kush Kingdom" -GroupCategory Security -GroupScope Universal -DisplayName "Kush Kingdom Security Group" -Path "CN=Users,DC=client,DC=ad" -Description "This group will have a foreign member for Cross Domain attack." -Credential $credential -ErrorAction Stop
    Write-Host "Kush Kingdom Security Group created!"
}
catch {
    # Check for specific error indicating existing group
    if ($_.Exception.Message -match "The specified group already exists") {
        Write-Host "Kush Kingdom Group already exists."
    }
    else {
        # Other errors, log the exception message
        Write-Error "Failed to create security group: $($_.Exception.Message)"
    }
    exit
}
# Create the other groups
# Define Group Names and Descriptions
$groupNames = @("The Berbers", "Songhai Empire", "Matamba Kingdom")
$groupDescriptions = @{
    "The Berbers"     = "This group has DCSync privileges and RDP on RT-DC"
    "Songhai Empire"  = "Members have ACE Write Owner on Matamba Kingdom"
    "Matamba Kingdom" = "Members have generic all permissions on user queen.cleopatra"
}

# Define Group Scope and Path (adjust if needed)
$groupScope = "Global"
$groupPath = "CN=Users,DC=client,DC=ad"

# Create Security Groups
foreach ($groupName in $groupNames) {
    New-ADGroup -Name $groupName -SamAccountName $groupName -GroupCategory Security -GroupScope $groupScope -Path $groupPath -Description ($groupDescriptions[$groupName]) -Credential $credential -ErrorAction SilentlyContinue
}

# Handle Existing Groups and Creation Errors
if ($existingGroups) {
    Write-Host "The following security group $groupName already exist:"
    $existingGroups | ForEach-Object { Write-Host "- $_" }
}
else {
    $failedGroups = $error[0].Exception.InnerException.InputObject
    if ($failedGroups) {
        Write-Host "Failed to create the following security groups:"
        $failedGroups | ForEach-Object { Write-Host "- $_" }
        Write-Error "Refer to the error messages above for details."
    }
    else {
        # Write-Host "All security groups created successfully!"
        Write-Host "$groupName group created successfully!"
    }
}
