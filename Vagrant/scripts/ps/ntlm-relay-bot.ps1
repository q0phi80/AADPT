# This script generates network share traffic for LLMNR and NTLM-related attacks

$task = '/c powershell New-PSDrive -Name "Public" -PSProvider "FileSystem" -Root "\\CD-SR\Fluffy"'
$repeat = (New-TimeSpan -Minutes 5)
$taskName = "relay_bot"
$user = "child.client.ad\idi.amin"
$password = "Uganda79Cr4ckMeIfUc4n"

$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "$task"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $repeat
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd

$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -like $taskName }
if ($taskExists) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User $user -Password $password -Settings $settings