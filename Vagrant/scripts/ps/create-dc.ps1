# Script to install Active Directory services

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing RSAT tools"
Import-Module ServerManager
Add-WindowsFeature RSAT-AD-PowerShell,RSAT-AD-AdminCenter,DNS

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Creating domain controller..."
Install-WindowsFeature AD-domain-services
Import-Module ADDSDeployment
# Import-Module ActiveDirectory

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Done with DC deployment..."