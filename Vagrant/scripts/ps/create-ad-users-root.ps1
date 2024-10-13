# Referrence: https://github.com/StefanScherer/adfs2/blob/master/scripts/fill-ad.ps1
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

$adDomain = Get-ADDomain
# $domain = $adDomain.DNSRoot
$domainDn = $adDomain.DistinguishedName
$usersAdPath = "CN=Users,$domainDn"

Import-Module ActiveDirectory

Import-CSV -delimiter ";" C:\users-root.csv | ForEach-Object {
    $userName = $_.SamAccountName

    # Check if user already exists
    $existingUser = Get-ADUser -Filter "SamAccountName -eq '$userName'" -SearchBase "DC=client,DC=ad" -ErrorAction SilentlyContinue

    if ($existingUser) {
        Write-Warning "User '$userName' already exists in domain 'client.ad'."
    }
    else {
        # User doesn't exist, proceed with creation
        New-ADUser -SamAccountName $userName -GivenName $_.GivenName -Surname $_.Surname -Name $_.Name `
            -Path "CN=Users,DC=client,DC=ad" `
            -AccountPassword (ConvertTo-SecureString -AsPlainText $_.Password -Force) -Enabled $true
        Write-Host "User '$userName' created successfully."
    }
}

Add-ADGroupMember -Identity "The Berbers" -Members sunni.ali
Add-ADGroupMember -Identity "The Berbers" -Members njinga.mbandi
Add-ADGroupMember -Identity "The Berbers" -Members eze.nri

Add-ADGroupMember -Identity "Kush Kingdom" -Members julius.nyerere
Add-ADGroupMember -Identity "Enterprise Admins" -Members kwame.nkrumah
Add-ADGroupMember -Identity "Domain Admins" -Members kwame.nkrumah
Add-ADGroupMember -Identity "Domain Admins" -Members patrice.lumumba

# Add Local Group membership
net localgroup "Remote Desktop Users" "client\The Berbers" /add
net localgroup "Administrators" "client\patrice.lumumba" /add
net localgroup "Administrators" "client\kwame.nkrumah" /add

# Add the vagrant user to the Enterprise Admins group.
# NB this is needed to install the Enterprise Root Certification Authority.
Add-ADGroupMember `
    -Identity 'Enterprise Admins' `
    -Members "CN=vagrant,$usersAdPath"

Add-ADGroupMember `
    -Identity 'Domain Admins' `
    -Members "CN=vagrant,$usersAdPath"

Write-Output 'vagrant Group Membership'
Get-ADPrincipalGroupMembership -Identity 'vagrant' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

Write-Output 'Enterprise Administrators'
Get-ADGroupMember `
    -Identity 'Enterprise Admins' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

Write-Output 'Domain Administrators'
Get-ADGroupMember `
    -Identity 'Domain Admins' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

Write-Output 'Enabled Domain User Accounts'
Get-ADUser -Filter {Enabled -eq $true} `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

Write-Output 'Done creating the AD users...'   
