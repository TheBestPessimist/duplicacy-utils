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
##############################

##############################
$repositoryFolder = "C:/duplicacy repo/"
##############################

##############################
$logFolder = ".duplicacy/tbp-logs/"
# $logFilePath = $logFolder + "backup-log-" + $(Get-Date).toString("yyyy-MM-dd HH-mm-ss") + ".log"
$logFilePath = $logFolder + "backup-log " + $(Get-Date).toString("yyyy-MM-dd") + ".log"
##############################

##############################
$duplicacy = @{             # this creates a hash table in powershell
    exe = " .\z.exe "
    options = " -d -log "
    # options = "  "
    backup = " backup -stats -threads 18 "
    list = " list "
    check = " check "
    vssOption = $false
}
$duplicacy.command = $duplicacy.exe + $duplicacy.options
if($duplicacy.vssOption -And ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $duplicacy.backup += " -vss "
}
##############################

function main {
    doPreBackupTasks
    ##############################
    ##############################

    # doDuplicacyCommand $duplicacy.list
    doDuplicacyCommand $duplicacy.backup

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
    log "Zipping older log files..."

}

function logStartBackupProcess() {
    $date = $(Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    log
    log
    log "================================================================="
    log "==== Starting duplicacy backup Process @ $date ===="
    log "===="
    log ("==== logFile is: " + (Resolve-Path -Path $logFilePath).Path)
    log "================================================================="

}

function logFinishBackupProcess() {
    $date = $(Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    log "================================================================="
    log "==== Finished duplicacy backup Process @ $date ===="
    log "===="
    log ("==== logFile is: " + (Resolve-Path -Path $logFilePath).Path)
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
