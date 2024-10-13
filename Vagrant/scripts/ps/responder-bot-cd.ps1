# Source: https://github.com/Orange-Cyberdefense/GOAD/blob/main/ad/GOAD-Light/scripts/responder.ps1
# Run this on the CHILD DC

$task = '/c powershell New-PSDrive -Name "Public" -PSProvider "FileSystem" -Root "\\CD-WKSTN\fluffy"'
$repeat = (New-TimeSpan -Minutes 2)
$taskName = "responder_bot"
$user = "child.client.ad\jomo.kenyatta"
$password = "Kenya64"

$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "$task"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $repeat
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd

$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -like $taskName }
if ($taskExists) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User $user -Password $password -Settings $settings