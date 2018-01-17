# ==============================================================================
# ==============================================================================
#
# User-configurable part. Please don't modify anything else!
#
# ==============================================================================
# ==============================================================================

# ================================================
# Backup script full path
$scriptPath = "C:\duplicacy repo\.duplicacy\duplicacy utils\backup.ps1"


# ================================================
# The name of the Scheduled Task
$taskName = "Duplicacy Hourly Backup"


# ================================================
# Repetition interval example (just copy the part after "#", which starts with "$"):
#       1 minute:     run the script every minute,
#       1 hour:       run the script every hour,
#       1 day:        run the script every day (once a day)
# $repetitionInterval = (New-TimeSpan -Minutes 1)
# $repetitionInterval = (New-TimeSpan -Hours 1)
# $repetitionInterval = (New-TimeSpan -Days 1)
#
# copy repetition interval below:
$repetitionInterval = (New-TimeSpan -Hours 1)

# ==============================================================================
# ==============================================================================
#
# END of user-configurable part. Please don't modify anything else!
#
# ==============================================================================
# ==============================================================================



# ================================================
# created with the help of:
# - https://blog.netnerds.net/2015/01/create-scheduled-task-or-scheduled-job-to-indefinitely-run-a-powershell-script-every-5-minutes/ (mostly copied)
# - http://britv8.com/powershell-create-a-scheduled-task/
#
#
#
# task options
#
# - WILL DELETE THE TASK IF IT ALREADY EXISTS!!!!
#
# - it is enabled by default
# - does not run on batteries (preserve power). however, if the task is started (while on power), it continues if the user goes on battery (so that a backup would not be incomplete)
# - does not start a new backup until the previous one is finished
# - stars a backup (but only one, not more) if the start-time has passed (eg: start-time = 16:00, computer is only powered on @ 18:21. backup starts @ 18:21)
# - don't wake the computer to run the task (as mentioned above, the task will run whenever the computer is turned on, even after it's normal start time)
# - the task will run for at most 3 days continuously before being quit (Task Scheduler constraint)
#
# ================================================


$script = '-NoProfile -ExecutionPolicy Bypass -File "' + $scriptPath + '" -Verb RunAs'

$userCredentials = @{
    username = ""
    password = ""
}

function main()
{
    ##############################
    getUserCredentials
    ##############################

    ##############################
    # cleanup: Unregister first the ScheduledTask if it already exists
    Unregister-ScheduledTask -TaskName $taskName -Confirm: $false -ErrorAction SilentlyContinue
    ##############################

        createNewTask
    
#    For ($i = 0; $i -le 100; $i++) {
#        $taskName = "$taskNameInit$i"
#        createNewTask
#    }
}

function getUserCredentials()
{
    $msg = "Enter the username and password that will run the task";
    $credential = $Host.UI.PromptForCredential("Task username and password", $msg, "$env:userdomain\$env:username", $env:userdomain)
    $userCredentials.username = $credential.UserName
    $userCredentials.password = $credential.GetNetworkCredential().Password
}

function createNewTask()
{
    # The script below will run as the specified user (you will be prompted for credentials)
    # and is set to be elevated to use the highest privileges.
    # In addition, the task will run however long specified in $repetitionInterval above.
    $task = New-ScheduledTaskAction –Execute "powershell.exe" -Argument  "$script; quit"
    $randomDelay = (New-TimeSpan -Seconds 30)  # 30 seconds of random start delay
    $repetitionDuration = (New-TimeSpan -Days 10000)  # 27 years should be enough
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval $repetitionInterval -RepetitionDuration $repetitionDuration -RandomDelay $randomDelay
    $settings = New-ScheduledTaskSettingsSet -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew -StartWhenAvailable

    Register-ScheduledTask -TaskName $taskName -Action $task -Trigger $trigger -RunLevel Highest -User $userCredentials.username -Password $userCredentials.password -Settings $settings
}

main
