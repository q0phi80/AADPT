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

Import-CSV -delimiter ";" C:\users-child.csv | ForEach-Object {
    $userName = $_.SamAccountName

    # Check if user already exists
    $existingUser = Get-ADUser -Filter "SamAccountName -eq '$userName'" -SearchBase "DC=child,DC=client,DC=ad" -ErrorAction SilentlyContinue

    if ($existingUser) {
        Write-Warning "User '$userName' already exists in domain 'child.client.ad'."
    }
    else {
        # User doesn't exist, proceed with creation
        New-ADUser -SamAccountName $userName -GivenName $_.GivenName -Surname $_.Surname -Name $_.Name `
            -Path "CN=Users,DC=child,DC=client,DC=ad" `
            -AccountPassword (ConvertTo-SecureString -AsPlainText $_.Password -Force) -Enabled $true
        Write-Host "User '$userName' created successfully."
    }
}

Add-ADGroupMember -Identity "Kushite Empire" -Members haile.selassie
Add-ADGroupMember -Identity "Kushite Empire" -Members nelson.mandela
Add-ADGroupMember -Identity "Kushite Empire" -Members mansa.musa
Add-ADGroupMember -Identity "Kushite Empire" -Members muammar.gaddafi
Add-ADGroupMember -Identity "Kushite Empire" -Members kofi.annan
Add-ADGroupMember -Identity "Kushite Empire" -Members jeremiah.kofi
Add-ADGroupMember -Identity "Kushite Empire" -Members shaka.zulu

Add-ADGroupMember -Identity "Axumite Empire" -Members queen.sheba
Add-ADGroupMember -Identity "Axumite Empire" -Members shaka.zulu
Add-ADGroupMember -Identity "Axumite Empire" -Members idi.amin

Add-ADGroupMember -Identity "Kongo Kingdom" -Members idi.amin


Add-ADGroupMember -Identity "Ghana Empire" -Members idi.amin
Add-ADGroupMember -Identity "Domain Admins" -Members ghana.bassi
Add-ADGroupMember -Identity "Domain Admins" -Members idi.amin

# Add Local Group membership
net localgroup "Remote Desktop Users" "child\Kushite Empire" /add
net localgroup "Administrators" "child\ghana.bassi" /add
net localgroup "Administrators" "child\nelson.mandela" /add
net localgroup "Administrators" "child\mansa.musa" /add

Add-ADGroupMember `
    -Identity 'Domain Admins' `
    -Members "CN=vagrant,$usersAdPath"

Write-Output 'Domain Administrators'
Get-ADGroupMember `
    -Identity 'Domain Admins' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

Write-Output 'Enabled Domain User Accounts'
Get-ADUser -Filter {Enabled -eq $true} `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000
