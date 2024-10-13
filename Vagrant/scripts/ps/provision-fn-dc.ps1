# ASRep-Roasting
Write-Host "Creating ASRep Roasting vuln..."
Get-ADUser -Identity "ndongo.sima" | Set-ADAccountControl -DoesNotRequirePreAuth:$true

# SIdHistory
# Write-Host "Setting up SIDHistory..."
# netdom trust foreign.ad /d:client.ad /enablesidhistory:yes

# Constrained Delegation
Write-Host "Creating Constained Delegation vuln..."
Get-ADUser -Identity "iis.admin" | Set-ADAccountControl -TrustedToAuthForDelegation $True
Set-ADUser -Identity "iis.admin" -Add @{'msDS-AllowedToDelegateTo' = @('TIME/FN-DC.FOREIGN.AD', 'TIME/FN-DC') }

# Disable Autologon
Write-Host "Disabling autologong..."
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /d 0 /f

# Enroll ADCS Certificates
Write-Host "Enrolling certificates templates..."
# Source: https://github.com/arth0sz/Practice-AD-CS-Domain-Escalation
# Source: https://github.com/Orange-Cyberdefense/GOAD/tree/main/ansible/roles/adcs_templates/files

$templateNames = @("Vuln-ESC1", "Vuln-ESC2", "Vuln-ESC3-1", "Vuln-ESC3-2", "Vuln-ESC4")

Write-Host "Publishing and Enrolling vulnerable certificates..."

foreach ($templateName in $templateNames) {
    # Check if template exists
    $templateExists = Get-ADCSTemplate -DisplayName $templateName -ErrorAction SilentlyContinue

    if (!$templateExists) {
        # Create and publish template
        New-ADCSTemplate -DisplayName $templateName -JSON (Get-Content C:\Windows\Temp\$templateName.json -Raw) -Publish
        Write-Host "Published template: $templateName"
    }
    else {
        Write-Host "Template '$templateName' already exists, skipping..."
    }

    # Set ACL only if the template was published
    if ($templateExists) {
        Set-ADCSTemplateACL -DisplayName $templateName -Identity 'FOREIGN\Domain Users', 'FOREIGN\Domain Computers' -Enroll -AutoEnroll
        Write-Host "Set permissions for '$templateName'"
    }
}

Start-Sleep -Seconds 10
Import-Module ADCSTemplate
# Add the user Queen Makeda control over Vuln-ESC4
Get-CertificateTemplate -Name 'Vuln-ESC4' | Get-CertificateTemplateAcl | Add-CertificateTemplateAcl -Identity 'queen.makeda' -AccessType Allow -AccessMask FullControl, Write | Set-CertificateTemplateAcl