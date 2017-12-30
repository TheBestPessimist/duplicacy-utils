##############################
# This script assumes that it is run form the same folder as the duplicacy
# executable (eg. from __the repository__).
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
# prune explanation (from here: https://github.com/gilbertchen/duplicacy/wiki/prune) :
# $ duplicacy prune -keep 1:7       # Keep 1 snapshot per day for snapshots older than 7 days
# $ duplicacy prune -keep 7:30      # Keep 1 snapshot every 7 days for snapshots older than 30 days
# $ duplicacy prune -keep 30:180    # Keep 1 snapshot every 30 days for snapshots older than 180 days
# $ duplicacy prune -keep 0:360     # Keep no snapshots older than 360 days
# the order has to be from the eldest to the youngest!
##############################

##############################
# various timings that could prove useful for the user
$timings = @{
    scriptStartTime = 0
    scriptEndTime = 0
    scriptTotalRuntime = 0
}
##############################


##############################
$repositoryFolder = "C:/duplicacy repo/"
##############################

##############################
$logFolder = ".duplicacy/tbp-logs/"
# $logFilePath = $logFolder + "backup-log-" + $(Get-Date).toString("yyyy-MM-dd HH") + ".log"
$logFilePath = $logFolder + "backup-log " + $(Get-Date).toString("yyyy-MM-dd") + ".log"
##############################

##############################
$duplicacy = @{             # this creates a hash table in powershell
    exe = " .\z.exe "
    options = " -d -log "
    # options = " -log "
    vssOption = $false

    backup = " backup -stats -threads 18 "
    list   = " list "
    check  = " check -tabular "
    prune  = " prune -exhaustive -keep 7:30 -keep 1:7 "
}
$duplicacy.command = $duplicacy.exe + $duplicacy.options
if($duplicacy.vssOption -And ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $duplicacy.backup += " -vss "
}
##############################

function main {
# http://www.wallacetech.co.uk/?p=693
    doPreBackupTasks
    ##############################
    ##############################

    # doDuplicacyCommand $duplicacy.list
    # doDuplicacyCommand $duplicacy.backup
    # doDuplicacyCommand $duplicacy.check
    # doDuplicacyCommand $duplicacy.prune

    ##############################
    ##############################
    doPostBackupTasks
}


function doPreBackupTasks() {
    Push-Location $repositoryFolder

    if( !(Test-Path -Path $logFolder ) ) {
        New-Item -ItemType directory -Path $logFolder
        log "Folder $logFolder does not exist. It has just been created"
    }

    logStartBackupProcess
    zipOlderLogFiles
}

function doPostBackupTasks() {
    logFinishBackupProcess
    Pop-Location
}

function zipOlderLogFiles() {
    log "Zipping older log files... NOT IMPLEMENTED"

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
