#=================================================
#
# The log folder is created in the folder .duplicacy/tbp-logs/
#
# If the user wishes (sets the flag to true) and the script it is run as an Administrator,
# the backup command will use the -vss flag (Shadow Copy),
# which can only be used as an Administrator.
#
# Thanks to <bassebaba/DuplicacyPowershell> for the initial script which
# inspired this one and from which i borrowed some parts.
#
# The script can be run (after setting the correct paths and variable names) like this:
#       powershell -NoProfile -ExecutionPolicy Bypass -File "C:\duplicacy repo\backup.ps1" -Verb RunAs;
#
# prune explanation (from here: https://github.com/gilbertchen/duplicacy/wiki/prune ):
# $ duplicacy prune -keep 1:7       # Keep 1 snapshot per day for snapshots older than 7 days
# $ duplicacy prune -keep 7:30      # Keep 1 snapshot every 7 days for snapshots older than 30 days
# the order has to be from the eldest to the youngest!
#
#=================================================


#=================================================
# Import the backup config file
#
. ".\backup config.ps1"
#=================================================

#=================================================
# Various timers keeping time
#
$timings = @{
    scriptStartTime = 0
    scriptEndTime = 0
    scriptTotalRuntime = 0
}
#=================================================

#=================================================
# Info about the logging
#
$logFolder = ".duplicacy/tbp-logs/" # relative to repositoryFolder
# $logFilePath = $logFolder + "backup-log-" + $(Get-Date).toString("yyyy-MM-dd HH") + ".log"
$logFilePath = $logFolder + "backup-log " + $(Get-Date).toString("yyyy-MM-dd") + ".log"
#=================================================

#=================================================
# The duplicacy commands
#
$duplicacyBackupVss_temp = ""
if( $duplicacyVssOption -And ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") ) {
    $duplicacyBackupVss_temp = " -vss "
}

$duplicacyOptions_temp = " -log "
if( $duplicacyDebug ) {
    $duplicacyOptions_temp += " -d "
}

$duplicacy = @{             # this is a hash table
    exe = " $duplicacyExePath "
    options = " $duplicacyOptions_temp "
    command = " $duplicacyExePath $duplicacyOptions_temp "

    backup = " backup -stats -threads 18 $duplicacyBackupVss_temp "
    list   = " list "
    check  = " check -tabular "
    prune  = " prune $duplicacyPruneRetentionPolicy "
}
#=================================================


function main {
    # http://www.wallacetech.co.uk/?p=693
    doPreBackupTasks
    #=================================================
    #=================================================

    # doDuplicacyCommand $duplicacy.list
    # doDuplicacyCommand $duplicacy.backup
    doDuplicacyCommand $duplicacy.prune
    doDuplicacyCommand $duplicacy.check

    #=================================================
    #=================================================
    doPostBackupTasks
}

#=================================================
# Helper functions
#
function doPreBackupTasks() {
    Push-Location $repositoryFolder

    if( !(Test-Path -Path $logFolder ) ) {
        New-Item -ItemType directory -Path $logFolder
        log "Folder $logFolder does not exist. It has just been created"
    }

    logStartBackupProcess
    zipOlderLogFiles
}

function logStartBackupProcess() {
    $timings.scriptStartTime = Get-Date
    $startTime = $timings.scriptStartTime.ToString("yyyy-MM-dd HH:mm:ss")
    log
    log
    log "================================================================="
    log "==== Starting Duplicacy backup process =========================="
    log "======"
    log "====== Start time is: $startTime"
    log ("====== logFile is: " + (Resolve-Path -Path $logFilePath).Path)
    log "================================================================="
}

function zipOlderLogFiles() {
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")   # needed to delete logFile
    $logFiles = Get-ChildItem $logFolder -File -Filter *.log |  Where-Object { $_.LastWriteTime -lt (Get-Date -Hour 0 -Minute 0 -Second 1)}
    foreach( $file in $logFiles ) {
        $fullName = $file.FullName
        $zipFileName = Join-Path -Path $file.DirectoryName -ChildPath $file.Basename
        log "Zipping (and then deleting) the logFile: $fullName to the zipFile: $zipFileName"
        Compress-Archive -Path $fullName -DestinationPath $zipFileName -CompressionLevel Optimal
        # Remove-Item -Path $fullName # not good since it deletes the file. I want to send it to recycle bin.
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($fullName, 'OnlyErrorDialogs', 'SendToRecycleBin')
    }
}

function doPostBackupTasks() {
    logFinishBackupProcess
    Pop-Location
}

function logFinishBackupProcess() {
    $timings.scriptEndTime = Get-Date
    $timings.scriptTotalRuntime = New-Timespan -Start $timings.scriptStartTime -End $timings.scriptEndTime
    $startTime = $timings.scriptStartTime.ToString("yyyy-MM-dd HH:mm:ss")
    $endTime = $timings.scriptEndTime.ToString("yyyy-MM-dd HH:mm:ss")
    log "================================================================="
    log "==== Finished Duplicacy backup process =========================="
    log "======"
    log ("====== Total runtime: {0} Days {1} Hours {2} Minutes {3} Seconds, start time: {4}, finish time: {5}" -f $timings.scriptTotalRuntime.Days, $timings.scriptTotalRuntime.Hours, $timings.scriptTotalRuntime.Minutes, $timings.scriptTotalRuntime.Seconds, $startTime, $endTime)
    log ("====== logFile is: " + (Resolve-Path -Path $logFilePath).Path)
    log "================================================================="
}

function doDuplicacyCommand($arg){
    $command = $duplicacy.command + $arg
    log "==="
    log "=== Now executting $command"
    log "==="
    invoke $command
}

function invoke($command) {
    Invoke-Expression " $command | Tee-Object -FilePath '$logFilePath' -Append "
}


function log($str) {
    $date = $(Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
    invoke " Write-Output '${date} $str' "
}

function elevateAsAdmin() {
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
    }
}

# elevateAsAdmin
main
# Read-Host "Press ENTER to exit: "
