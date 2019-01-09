# ==============================================================================
# ==============================================================================
#
# User-configurable part. Please don't modify anything else!
#
# ==============================================================================
# ==============================================================================


# ================================================
# Import the global and local config file 

. "$PSScriptRoot\default_config.ps1"
. "$PSScriptRoot\user_config.ps1"
# ================================================


# ================================================
# Backup script full path
#   Recommendation: please place all the util scrips in
#       [duplicacy repo path]\.duplicacy\duplicacy utils (eg. relative to the repository)
$scriptPath = "$PSScriptRoot\backup.ps1"
# $scriptPath = "C:\duplicacy repo\.duplicacy\duplicacy utils\backup.ps1"


# ================================================
# Repetition interval example (just copy the part after "#", which starts with "$"):
#       1 minute:     run the backup every minute (not recommended!),
#       1 hour:       run the backup every hour,
#       3 hours:       run the backup every 3 hours,
#       1 day:        run the backup every day (once a day)
# $repetitionInterval = (New-TimeSpan -Minutes 1)
# $repetitionInterval = (New-TimeSpan -Hours 1)
# $repetitionInterval = (New-TimeSpan -Hours 3)
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
# task options
#
# - WILL DELETE THE TASK IF IT ALREADY EXISTS!!!!
#
# - is enabled by default
# - do not run on batteries (preserve power). however, if the task is started (while plugged), it continues if
#       the user goes on battery (so that a backup would not be incomplete)
# - do not start a new backup until the previous one is finished
# - start a backup (but only one, not more) if the start-time has passed (eg: start-time = 16:00, computer is
#       only powered on @ 18:21. backup starts @ 18:21)
# - don't wake the computer to run the task (as mentioned above, the task will run whenever the computer is
#       turned on and plugged, even after it's normal start time)
# - the task will run for at most 3 days continuously before being quit (Task Scheduler constraint)
#
#
#
# created with the help of:
# - https://blog.netnerds.net/2015/01/create-scheduled-task-or-scheduled-job-to-indefinitely-run-a-powershell-script-every-5-minutes/ (mostly copied)
# - http://britv8.com/powershell-create-a-scheduled-task/
# - https://stackoverflow.com/a/30856340/2161279
#
# ================================================


$script = '-NoProfile -ExecutionPolicy Bypass -File "' + $scriptPath + '" -Verb RunAs'

$userCredentials = @{
    username = ""
    password = ""
}

$duplicacyFolderIndex = $scriptPath.IndexOf('.duplicacy')
if ($duplicacyFolderIndex -ne -1)
{
    $scheduledTaskName = $scheduledTaskName + " for repository " + $scriptPath.Substring(0, $duplicacyFolderIndex - 1).Replace("\", "__").Replace(":", "")
    # it appears that the task name length limit is somewhere around 190 characters :^)
}
$scheduledTaskName = $scheduledTaskName[0..190] -join "" # range operator, like in kotlin :^)


function main()
{
    ##############################
    getUserCredentials
    ##############################

    ##############################
    # cleanup: Unregister first the ScheduledTask if it already exists
    Unregister-ScheduledTask -TaskName $scheduledTaskName -Confirm: $false -ErrorAction SilentlyContinue
    ##############################

    createNewTask
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

    $scheduledTaskParameters = @{
        TaskName = $scheduledTaskName
        Action = $task
        Trigger = $trigger
        RunLevel = "Highest"
        User = $userCredentials.username
        Password = $userCredentials.password
        Settings = $settings
    }
    Register-ScheduledTask @scheduledTaskParameters
}

main
