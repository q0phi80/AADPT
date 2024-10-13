# Source: https://raw.githubusercontent.com/Orange-Cyberdefense/GOAD/main/ad/GOAD-Light/scripts/rdp_scheduler.ps1

$pass = ConvertTo-SecureString 'Fluffy123!' -AsPlainText -Force;
$creds = New-Object System.Management.Automation.PSCredential ('child\mansa.musa', $pass);
# Invoke-Command -Computername "CD-WKSTN.child.client.ad" -ScriptBlock { sleep 55 } -Credential $creds -AsJob

$task = "/c powershell Invoke-Command -Computername 'CD-WKSTN.child.client.ad' -ScriptBlock { sleep 55 } -Credential $creds -AsJob"
$repeat = (New-TimeSpan -Minutes 1)
$taskName = "psremoting_bot2"
$user = "vagrant"
$password = "vagrant"
$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "$task"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $repeat
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd
#$settings.CimInstanceProperties.Item('MultipleInstances').Value = 3   # 3 corresponds to 'Stop the existing instance'

$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -like $taskName }
if ($taskExists) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User $user -Password $password -Settings $settings