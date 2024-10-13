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

# Define Group Names and Descriptions (replace with actual values)
$groupNames = @("Zulu Kingdom", "Basotho Kingdom")
$groupDescriptions = @{
    "Zulu Kingdom"   = "Members of this group are from the Zulu family and have RDP access to FN-DC."
    "Basotho Kingdom" = "Members of this group are from the Sotho clans"
}

# Define Group Scope and Path (adjust if needed)
$groupScope = "Global"
$groupPath = "CN=Users,DC=foreign,DC=ad"

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

# # Define Group Names and Descriptions (replace with actual values)
$groupNames = @("Ndongo Kingdom", "Mali Empire")
$groupDescriptions = @{
    "Ndongo Kingdom"    = "Members of this group are from the Ndongo Kingdom"
    "Mali Empire"    = "Members of this group are from the Great Mali Empire"
}

# Define Group Scope and Path (adjust if needed)
$groupScope = "Universal"
$groupPath = "CN=Users,DC=foreign,DC=ad"

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

