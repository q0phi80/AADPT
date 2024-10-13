# Source: https://www.automatedvision.info/2023/01/setup-a-2-way-trust-between-2-active-directory-forest-domains/
# Source: https://www.anujvarma.com/powershell-to-create-ad-trust/
# Change following parameters 
$strRemoteForest = "client.ad" 

$strRemoteAdmin = "client\administrator" 

$strRemoteAdminPassword = "vagrant" 

$remoteContext = New-Object -TypeName "System.DirectoryServices.ActiveDirectory.DirectoryContext" -ArgumentList @( "Forest",$strRemoteForest, $strRemoteAdmin, $strRemoteAdminPassword) 

try { 

$remoteForest = [System.DirectoryServices.ActiveDirectory.Forest]::getForest($remoteContext) 

Write-Host "GetRemoteForest: Succeeded for domain $($remoteForest)" 

} 

catch { 

Write-Warning "GetRemoteForest: Failed:`n`tError: $($($_.Exception).Message)" 

} 

Write-Host "Connected to Remote forest: $($remoteForest.Name)" 

$localforest=[System.DirectoryServices.ActiveDirectory.Forest]::getCurrentForest() 

Write-Host "Connected to Local forest: $($localforest.Name)" 

try { 

$localForest.CreateTrustRelationship($remoteForest, "Bidirectional") 

Write-Host "CreateTrustRelationship: Succeeded for domain $($remoteForest)" 

} 

catch { 

Write-Warning "CreateTrustRelationship: Failed for domain$($remoteForest)`n`tError: $($($_.Exception).Message)" 

}

Start-Sleep -Seconds 10
# SIdHistory
Write-Host "Setting up SIDHistory..."
netdom trust foreign.ad /d:client.ad /enablesidhistory:yes