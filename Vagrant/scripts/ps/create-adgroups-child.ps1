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

Import-Module ActiveDirectory

# Attempt to create the group (exits on error)
try {
    New-ADGroup -Name "Ghana Empire" -SamAccountName "Ghana Empire" -GroupCategory Security -GroupScope Universal -DisplayName "Ghana Empire" -Path "CN=Users,DC=child,DC=client,DC=ad" -Description "Members of this group are Cross Forest Group." -ErrorAction Stop
    Write-Host "Security Group created!"
}
catch {
    # Check for specific error indicating existing group
    if ($_.Exception.Message -match "The specified group already exists") {
        Write-Host "Security Group already exists."
    }
    else {
        # Other errors, log the exception message
        Write-Error "Failed to create security group: $($_.Exception.Message)"
    }
    exit
}

# Create the other groups
# Define Group Names and Descriptions (replace with actual values)
$groupNames = @("Kushite Empire", "Axumite Empire", "Kongo Kingdom")
$groupDescriptions = @{
    "Kushite Empire"     = "Members of this group have RDP on CD-DC and CD-SRV"
    "Axumite Empire"  = "Members of this group have RDP access on CD-SRV"
    "Kongo Kingdom"  = "Members of this group have RDP access on CD-SRV"
}

# Define Group Scope and Path (adjust if needed)
$groupScope = "Global"
$groupPath = "CN=Users,DC=child,DC=client,DC=ad"

# Create Security Groups
foreach ($groupName in $groupNames) {
    New-ADGroup -Name $groupName -SamAccountName $groupName -GroupCategory Security -GroupScope $groupScope -Path $groupPath -Description ($groupDescriptions[$groupName]) -ErrorAction SilentlyContinue
}

# Handle Existing Groups and Creation Errors
if ($existingGroups) {
    Write-Host "The following security groups already exist:"
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
        Write-Host "All security groups created successfully!"
    }
}
