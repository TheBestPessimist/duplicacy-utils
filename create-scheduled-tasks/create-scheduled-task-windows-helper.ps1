# ==============================================================================
# ==============================================================================
#
# All the configuration should be placed in "config.user.ps1".
# Just copy the related config  from "config.default.ps1" and modify as needed
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
# ================================================


# ================================================
# Import the global and local config file

. "$PSScriptRoot\..\config.default.ps1"
. "$PSScriptRoot\..\config.user.ps1"
# ================================================


$script = '-NoProfile -ExecutionPolicy Bypass -File "' + $backupScriptPath + '" -Verb RunAs'

$userCredentials = @{
    username = ""
    password = ""
}

$duplicacyFolderIndex = $backupScriptPath.IndexOf('.duplicacy')
if ($duplicacyFolderIndex -ne -1)
{
    $scheduledTaskName = $scheduledTaskName + " for repository " + $backupScriptPath.Substring(0, $duplicacyFolderIndex - 1).Replace("\", "__").Replace(":", "")
}
# it appears that the task name length limit is somewhere around 190 characters :^)
$scheduledTaskName = $scheduledTaskName[0..190] -join "" # range operator, like in kotlin :^)


function main()
{
    elevateAsAdmin

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
    # In addition, the task will run however long specified in $scheduledTaskRepetitionInterval above.
    $task = New-ScheduledTaskAction –Execute "powershell.exe" -Argument  "$script; quit"
    $repetitionDuration = (New-TimeSpan -Days 10000)  # 27 years should be enough
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval $scheduledTaskRepetitionInterval -RepetitionDuration $repetitionDuration -RandomDelay $scheduledTaskRandomDelay
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

function elevateAsAdmin()
{
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
    {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
    }
}

main

Pause
