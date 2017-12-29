# created with the help of:
# - https://blog.netnerds.net/2015/01/create-scheduled-task-or-scheduled-job-to-indefinitely-run-a-powershell-script-every-5-minutes/ (mostly copied)
# - http://britv8.com/powershell-create-a-scheduled-task/
#
# Change these three variables to whatever you want
$jobname = "zzzzzzzzzzzzzzzzzzzzzzzzz"
$script =  "C:\Scripts\Test-ExampleScript.ps1 -Server server1"
$repeat = (New-TimeSpan -Minutes 5)
 
# The script below will run as the specified user (you will be prompted for credentials)
# and is set to be elevated to use the highest privileges.
# In addition, the task will run every 5 minutes or however long specified in $repeat.
$action = New-ScheduledTaskAction –Execute "$pshome\powershell.exe" -Argument  "$script; quit"
$duration = ([timeSpan]::maxvalue)
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval $repeat -RepetitionDuration $duration
 
$msg = "Enter the username and password that will run the task"; 
$credential = $Host.UI.PromptForCredential("Task username and password",$msg,"$env:userdomain\$env:username",$env:userdomain)
$username = $credential.UserName
$password = $credential.GetNetworkCredential().Password
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd
 
Register-ScheduledTask -TaskName $jobname -Action $action -Trigger $trigger -RunLevel Highest -User $username -Password $password -Settings $settings