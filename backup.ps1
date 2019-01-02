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
# ================================================
# Import the global and local config files

. "$PSScriptRoot\default_config.ps1"
. "$PSScriptRoot\user_config.ps1"
# ================================================


# ================================================
# ================================================
# Various timers keeping time

$timings = @{
    scriptStartTime = 0
    scriptEndTime = 0
    scriptTotalRuntime = 0
}
# ================================================

# ================================================
# ================================================
# Info about log paths
# It is empty now but filled in the function initLoggingOptions

$log = @{ }
# ================================================




# ================================================
# ================================================
# Initialize the script-level duplicacy table.
# It is empty now but filled in the function initDuplicacyOptions

$duplicacy = @{ }
# ================================================



function main
{
    # http://www.wallacetech.co.uk/?p=693
    doPreBackupTasks
    # ============================================
    # ============================================

    # ============================================
    # == Execute the commands. Select which ones =
    doDuplicacyCommand $duplicacy.backup
    # doDuplicacyCommand $duplicacy.list
    # doDuplicacyCommand $duplicacy.check
    # doDuplicacyCommand $duplicacy.copy

    # doDuplicacyCommand $duplicacy.prune
    # doDuplicacyCommand $duplicacy.pruneOffsite



    # ============================================
    # ============================================
    doPostBackupTasks
}

# ================================================
# Helper functions
#
function doPreBackupTasks()
{
    initDuplicacyOptions

    Push-Location $repositoryFolder

    initLoggingOptions
    createLogFolder
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

function initDuplicacyOptions
{
    # ============================================
    # Duplicacy global options

    $globalOpts = " -log "
    if ($duplicacyDebug)
    {
        $globalOpts += " -d "
    }


    # ============================================
    # Duplicacy backup options

    $backupOpts = ""
    if ($duplicacyVssOption -And ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
    {
        $backupOpts += " -vss "
        $backupOpts += " -vss-timeout " + $duplicacyVssTimeout
    }

    if ($duplicacyMaxUploadRate)
    {
        $backupOpts += " -limit-rate " + $duplicacyMaxUploadRate
    }


    # ============================================
    # Duplicacy prune options
    #
    $pruneOpts = $duplicacyPruneRetentionPolicy
    $pruneOffsiteOpts = $duplicacyPruneRetentionPolicy

    if ($duplicacyPruneNumberOfThreads)
    {
        $pruneOpts += " -threads " + $duplicacyPruneNumberOfThreads
        $pruneOffsiteOpts += " -threads " + $duplicacyPruneNumberOfThreads
    }

    if ($duplicacyPruneExtraOptionsLocal)
    {
        $pruneOpts += " $duplicacyPruneExtraOptionsLocal "
    }

    if ($duplicacyPruneExtraOptionsOffsite)
    {
        $pruneOffsiteOpts += " $duplicacyPruneExtraOptionsOffsite "
    }


    # ============================================
    # Duplicacy copy options
    $copyOpts = ""
    if ($duplicacyCopyNumberOfThreads)
    {
        $copyOpts += " -threads " + $duplicacyCopyNumberOfThreads
    }

    if ($duplicacyMaxCopyRate)
    {
        $copyOpts += " -upload-limit-rate " + $duplicacyMaxCopyRate
    }


    # ============================================
    # Initialize the script-level duplicacy table with all the precomputed strings
    $script:duplicacy.exe = " $duplicacyExePath "
    $script:duplicacy.options = " $globalOpts "
    $script:duplicacy.command = " $duplicacyExePath $globalOpts "

    $script:duplicacy.backup = " backup -stats $backupOpts "
    $script:duplicacy.list = " list "
    $script:duplicacy.check = " check "

    $script:duplicacy.prune = " prune $pruneOpts "
    $script:duplicacy.pruneOffsite = " prune $pruneOffsiteOpts "
    $script:duplicacy.copy = " copy -to offsite $copyOpts "
}


function initLoggingOptions
{
    # Init the logging paths and files
    $log = $script:log
    $log.basePath = ".duplicacy/tbp-logs" # relative to $repositoryFolder
    $log.fileName = "backup-log " + $( Get-Date ).toString("yyyy-MM-dd HH-mm-ss") + "_" + $( Get-Date ).Ticks + ".log"
    $log.workingPath = $log.basePath + "/" + $( Get-Date ).toString("yyyy-MM-dd dddd") + "/"
    $log.filePath = $log.workingPath + $log.fileName
}


function createLogFolder
{
    if (!(Test-Path -Path $log.workingPath))
    {
        New-Item -ItemType directory -Path $log.workingPath
        log "Folder ${log.workingPath} does not exist. It has just been created"
    }
}

# elevateAsAdmin

main
