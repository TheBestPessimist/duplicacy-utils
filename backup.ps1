# ================================================
#
# The log folder is created in the folder .duplicacy/tbp-logs/
#
# If the user wishes (sets the flag to true) and the script is run as an Administrator,
# the backup command will use the -vss flag (Shadow Copy),
# which can only be used as an Administrator.
#
# Thanks to <bassebaba/DuplicacyPowershell> for the initial script which
# inspired this one and from which I borrowed some parts.
#
# The script can be run manually (after setting the correct paths and variable names) like this:
#       powershell -NoProfile -ExecutionPolicy Bypass -File "C:\duplicacy repo\backup.ps1" -Verb RunAs;
#
#
# ================================================


# ================================================
# Import the global and local config file

. "$PSScriptRoot\backup config.ps1"
. "$PSScriptRoot\local config.ps1"
# ================================================


# ================================================

# ================================================
# Various timers keeping time
#
$timings = @{
    scriptStartTime = 0
    scriptEndTime = 0
    scriptTotalRuntime = 0
}
# ================================================


# ================================================
# Info about the logging
#
$log = @{
    basePath = ".duplicacy/tbp-logs" # relative to $repositoryFolder
    folder = $( Get-Date ).toString("yyyy-MM-dd dddd")
    fileName = "backup-log " + $( Get-Date ).toString("yyyy-MM-dd HH-mm-ss") + "_" + $( Get-Date ).Ticks + ".log"
}
$log.workingPath = $log.basePath + "/" + $log.folder + "/"
$log.filePath = $log.workingPath + $log.fileName
# ================================================


# ================================================
# Duplicacy global options
#
$duplicacyOptions_temp = " -log "
if ($duplicacyDebug)
{
    $duplicacyOptions_temp += " -d "
}


# ================================================
# Duplicacy backup options

$duplicacyBackupOptions_temp = ""
if ($duplicacyVssOption -And ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
{
    $duplicacyBackupOptions_temp += " -vss "
    $duplicacyBackupOptions_temp += " -vss-timeout " + $duplicacyVssTimeout
}

if ($duplicacyMaxUploadRate)
{
    $duplicacyBackupOptions_temp += " -limit-rate " + $duplicacyMaxUploadRate
}


# ================================================
# Duplicacy prune options
#
# $duplicacyPruneAll_temp = ""
# if ($duplicacyPruneAll) {
#     $duplicacyPruneAll_temp = " -all "
# }


$duplicacyPruneOptions_temp = $duplicacyPruneRetentionPolicy
$duplicacyPruneOptionsOffsite_temp = $duplicacyPruneRetentionPolicy

if ($duplicacyPruneNumberOfThreads)
{
    $duplicacyPruneOptions_temp += " -threads " + $duplicacyPruneNumberOfThreads
    $duplicacyPruneOptionsOffsite_temp += " -threads " + $duplicacyPruneNumberOfThreads
}

if ($duplicacyPruneExtraOptionsLocal)
{
    $duplicacyPruneOptions_temp += " $duplicacyPruneExtraOptionsLocal "
}

if ($duplicacyPruneExtraOptionsOffsite)
{
    $duplicacyPruneOptionsOffsite_temp += " $duplicacyPruneExtraOptionsOffsite "
}


# ================================================
# Duplicacy copy options

$duplicacyCopyOptions_temp = ""
if ($duplicacyCopyNumberOfThreads)
{
    $duplicacyCopyOptions_temp += " -threads " + $duplicacyCopyNumberOfThreads
}
if ($duplicacyMaxCopyRate)
{
    $duplicacyCopyOptions_temp += " -upload-limit-rate " + $duplicacyMaxCopyRate
}




# ================================================
# ================================================
# Create the commands in a hash table

$duplicacy = @{
    exe = " $duplicacyExePath "
    options = " $duplicacyOptions_temp "
    command = " $duplicacyExePath $duplicacyOptions_temp "

    backup = " backup -stats $duplicacyBackupOptions_temp "
    list = " list "
    check = " check -tabular "

    prune = " prune $duplicacyPruneOptions_temp "
    pruneoffsite = " prune $duplicacyPruneOptionsOffsite_temp "
    copy = " copy -to offsite $duplicacyCopyOptions_temp "
}
# ================================================



function main
{
    # http://www.wallacetech.co.uk/?p=693
    doPreBackupTasks
    # ================================================
    # ================================================

    # ===================================================
    # ===== Execute the commands. Select which ones =====
    doDuplicacyCommand $duplicacy.backup
    # doDuplicacyCommand $duplicacy.list
    # doDuplicacyCommand $duplicacy.check
    # doDuplicacyCommand $duplicacy.copy

    # doDuplicacyCommand $duplicacy.prune
    # doDuplicacyCommand $duplicacy.pruneoffsite



    # ================================================
    # ================================================
    doPostBackupTasks
}

# ================================================
# Helper functions
#
function doPreBackupTasks()
{
    Push-Location $repositoryFolder

    if (!(Test-Path -Path $log.workingPath))
    {
        New-Item -ItemType directory -Path $log.workingPath
        log "Folder ${log.workingPath} does not exist. It has just been created"
    }

    logStartBackupProcess
    zipOlderLogFiles
}

function logStartBackupProcess()
{
    $timings.scriptStartTime = Get-Date
    $startTime = $timings.scriptStartTime.ToString("yyyy-MM-dd HH:mm:ss")
    log
    log
    log "================================================================="
    log "==== Starting Duplicacy backup process =========================="
    log "======"
    log "====== Start time is: $startTime"
    log ("====== logFile is: " + (Resolve-Path -Path $log.filePath).Path)
    log "================================================================="
}

function zipOlderLogFiles()
{
    $logFiles = Get-ChildItem $log.basePath -Directory |  Where-Object { $_.LastWriteTime -lt (Get-Date -Hour 0 -Minute 0 -Second 1) }
    foreach ($folder in $logFiles)
    {
        $fullName = $folder.FullName
        $zipFileName = "$fullName.zip"
        log "Zipping (and then deleting) the folder: $fullName to the zipFile: $zipFileName"
        Compress-Archive -Path $fullName -DestinationPath $zipFileName -CompressionLevel Optimal -Update
        # Remove-Item -Path $fullName # not good since it deletes the Folder. I want to send it to recycle bin.
        $shell = New-Object -ComObject "Shell.Application"
        $item = $shell.Namespace(0).ParseName("$fullName")
        $item.InvokeVerb("delete")
    }
}

function doPostBackupTasks()
{
    logFinishBackupProcess
    if ($enableSlackNotifications)
    {
        createSlackMessage
    }

    Pop-Location
}

function logFinishBackupProcess()
{
    $timings.scriptEndTime = Get-Date
    $timings.scriptTotalRuntime = New-Timespan -Start $timings.scriptStartTime -End $timings.scriptEndTime
    $startTime = $timings.scriptStartTime.ToString("yyyy-MM-dd HH:mm:ss")
    $endTime = $timings.scriptEndTime.ToString("yyyy-MM-dd HH:mm:ss")
    log "================================================================="
    log "==== Finished Duplicacy backup process =========================="
    log "======"
    log ("====== Total runtime: {0} Days {1} Hours {2} Minutes {3} Seconds, start time: {4}, finish time: {5}" -f $timings.scriptTotalRuntime.Days, $timings.scriptTotalRuntime.Hours, $timings.scriptTotalRuntime.Minutes, $timings.scriptTotalRuntime.Seconds, $startTime, $endTime)
    log ("====== logFile is: " + (Resolve-Path -Path $log.filePath).Path)
    log "================================================================="
}

#function to split the lines at the end of the log file into individual slack notifications

function createSlackMessage()
{
    $slackOut = Get-Content -Tail $logLinestoSlack -Path $log.filePath
    $slackMessage = "*** DUPLICACY BACKUP PROCESS COMPLETE ***`n" + "-- " + "$( $slackOut -join "`n -- " )"
    slackNotify($slackMessage)
}

function slackNotify($notify_text)
{
    $payload = @{
        "text" = $notify_text
    }

    Invoke-WebRequest `
      -Body (ConvertTo-Json -Compress -InputObject $payload) `
      -Method Post `
      -Uri "$slackWebhookURL" | Out-Null
}

function doDuplicacyCommand($arg)
{
    $command = $duplicacy.command + $arg
    log "==="
    log "=== Now executting $command"
    log "==="
    invoke $command
}

function invoke($command)
{
    Invoke-Expression $command | Tee-Object -FilePath "$( $log.filePath )" -Append
}


function log($str)
{
    $date = $( Get-Date ).ToString("yyyy-MM-dd HH:mm:ss.fff")
    invoke " Write-Output '${date} $str' "
}

function elevateAsAdmin()
{
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
    {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
    }
}

# elevateAsAdmin

main

# Read-Host "Press ENTER to exit: "









# # Config / Global vars
# $duplicacyMasterDir="C:\duplicacy repo"                       # Logfiles will go here, subdir /Logs
# $repoLocations=@("C:\duplicacy repo")         # All repos to backup
# $duplicacyExe="C:\duplicacy repo\z.exe"          # Path to .exe
# $duplicacyGlobalOptions="-d -log"                                 # Global options to add to duplicacy commands
# $backupCmd="backup -stats -threads 20"                                        # Backup command. TODO: Needs improvement, we should use some sort of backup-class instead to have per-repo specifics here...
# #$backupCmd="list"

# # Pushover, leave empty for none
# $sendPushoverOnSuccess=$false
# $pushoverUserKey=""
# $pushoverToken=""


# # Main
# function main {
#         $msg = ""
#         foreach($repo in $repoLocations){
#             log ""
#             logDivider "Repo: $repo"
#             cd $repo
#             log "Running Duplicacy backup ..."

#             Invoke-Expression "& '$duplicacyExe' $duplicacyGlobalOptions $backupCmd" | Tee-Object -Variable dupOut
#             if($lastexitcode){
#                 throw "Duplicacy non zero exit code"
#             }
#             logDivider "Done backing up: $repo"
#             $stats = logStats $dupOut
#             $msg += "$repo :: $stats `n"
#         }
#         if($sendPushoverOnSuccess){
#             sendPushover "Backup success" $msg
#         }


# }

# function logStats($dupOutput) {
#     try {
#         $backupStats = $dupOutput.Split("`n") | Select-String -Pattern 'All chunks'
#         $match = ([regex]::Match($backupStats,'(.*)total, (.*) bytes; (.*) new, (.*) bytes, (.*) bytes'))
#         $tot = formatData $match.Groups[2].Value
#         $new = formatData $match.Groups[4].Value
#         $upload = formatData $match.Groups[5].Value
#     return "$tot, $new -> upload $upload"
#     } Catch {
#         return "Could not parse stats"
#     }
# }

# function formatData($str){
#     $last = $str[-1]
#     $foo =  ($str -replace ".$")/1000
#     $bar = [int]$foo
#     if($last -eq "K"){
#         return "$bar MB"
#     } elseif ($last -eq "M"){
#         return "$bar GB"
#     }
#     return $str

# }
