# Import modules
Import-Module ServerManager

# Install the AD CS, including the Certification Authority and Certificate Templates consoles
# Install-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools -Force
Install-WindowsFeature -Name AD-Certificate -IncludeManagementTools -IncludeAllSubFeature | Out-Null
Install-WindowsFeature -Name Adcs-Cert-Authority -IncludeManagementTools -IncludeAllSubFeature | Out-Null


Write-Host "[*] Installing new Active Directory Certificate Authority. `n"

# Install a new Enterprise Root CA using a specific provider and a validity period
$cred = New-Object -TypeName PSCredential -ArgumentList 'Administrator@foreign.ad', (ConvertTo-SecureString -String 'vagrant' -AsPlainText -Force)
$params = @{
    Credential          = $cred
    CACommonName        = "FOREIGN-CA"
    CAType              = "EnterpriseRootCa"
    # CAType              = "StandaloneRootCa"
    CryptoProviderName  = "RSA#Microsoft Software Key Storage Provider"
    KeyLength           = 2048
    HashAlgorithmName   = "SHA256"
    ValidityPeriod      = "Years"
    ValidityPeriodUnits = 3
}
Install-AdcsCertificationAuthority @params -Force

Start-Sleep -m 2000

# Install the Web Enrollment role
Install-AdcsWebEnrollment -Force
Install-WindowsFeature ADCS-Web-Enrollment

# Install ADCSTemplate
Write-Host "[*] Installing ADCSTemplate module." 
Install-PackageProvider -Name NuGet -MinimumVersion "2.8.5.201" -Force
Install-Module ADCSTemplate -Force

# Install the PowerShell PKI Module
Install-Module -Name PSPKI -Force
Get-Command -Module PSPKI

# Remove the certification authority role service
# Uninstall-AdcsCertificationAuthority
# Uninstall-AdcsWebEnrollment