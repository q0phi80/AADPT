# Import modules
Import-Module ServerManager
Add-WindowsFeature Adcs-Web-Enrollment

# Install the AD CS, including the Certification Authority and Certificate Templates consoles
# Install-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools -Force
Install-WindowsFeature -Name AD-Certificate -IncludeManagementTools -Force | Out-Null
Install-WindowsFeature -Name Adcs-Cert-Authority -IncludeManagementTools -Force | Out-Null

Write-Host "[*] Installing new Active Directory Certificate Authority. `n"

# Install a new Enterprise Root CA using a specific provider and a validity period
$params = @{
    CAType              = "EnterpriseRootCa"
    CryptoProviderName  = "RSA#Microsoft Software Key Storage Provider"
    KeyLength           = 2048
    HashAlgorithmName   = "SHA1"
    ValidityPeriod      = "Years"
    ValidityPeriodUnits = 3
}
Install-AdcsCertificationAuthority @params -Force

Start-Sleep -m 2000

# Install the Web Enrollment role
Install-AdcsWebEnrollment -Force

# Remove the certification authority role service
# Uninstall-AdcsCertificationAuthority
# Uninstall-AdcsWebEnrollment


# Install-WindowsFeature -Name AD-Certificate -IncludeManagementTools -WarningAction SilentlyContinue | Out-Null

# Install-WindowsFeature -Name Adcs-Cert-Authority -IncludeManagementTools -WarningAction SilentlyContinue | Out-Null

# Write-Host "[*] Installing new Active Directory Certificate Authority. `n"
  
# Install-AdcsCertificationAuthority -CACommonName ROOT-CA -CAType EnterpriseRootCa -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
#     -KeyLength 2048 -HashAlgorithmName SHA256 -ValidityPeriod Years -ValidityPeriodUnits 99 -WarningAction SilentlyContinue -Force | Out-Null


New-ADCSTemplate -DisplayName ESC1 -JSON (Get-Content C:\ESC1.json -Raw) -Publish
Set-ADCSTemplateACL -DisplayName ESC1 -Identity 'foreign\domain users' -Enroll -AutoEnroll