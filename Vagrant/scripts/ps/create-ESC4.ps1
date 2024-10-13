# Install the PowerShell PKI Module
Install-Module -Name PSPKI -Force

# Wait for 10 seconds before publishing the Cert Templates
Start-Sleep -Seconds 10
Get-Command -Module PSPKI

# Add the user Queen Makeda control over Vuln-ESC4
Get-CertificateTemplate -Name 'Vuln-ESC4' | Get-CertificateTemplateAcl | Add-CertificateTemplateAcl -Identity 'queen.makeda' -AccessType Allow -AccessMask FullControl, Write | Set-CertificateTemplateAcl