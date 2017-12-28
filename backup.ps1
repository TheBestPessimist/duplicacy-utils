##############################
# This script assumes that it is run form the same folder as the duplicacy executable (eg. from __the repository__)
##############################



##############################
$logFolder = ".duplicacy/tbp-logs/"
# $logFile = $logFolder + "log " + $(Get-Date).toString("yyyy-MM-dd HH-mm-ss")
$logFile = $logFolder + "log " + $(Get-Date).toString("yyyy-MM-dd")
$logFile = $logFile -replace ' ', '` '
if(!(Test-Path -Path $logFolder )){
    New-Item -ItemType directory -Path $logFolder
}
##############################

##############################
$duplicacy = @{        # this creates a hash table in powershell
    exe = " .\z.exe "
    options = " -d -log "
    backup = " backup -vss -stats -threads 18 "
    list = " list "
    check = " check "
}
$duplicacy.command = $duplicacy.exe + $duplicacy.options
##############################

##############################
$teeCommand = " | Tee-Object -FilePath $logFile -Append "
##############################


function main {
    logStartBackupProcess

    doDuplicacyCommand $duplicacy.list

    logFinishBackupProcess
}

function logStartBackupProcess {
    $date = $(Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    log "================================================================="
    log "==== Starting duplicacy backup Process @ $date ===="
    log "================================================================="
}

function logFinishBackupProcess {
    $date = $(Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    log "================================================================="
    log "==== Finished duplicacy backup Process @ $date ===="
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
    Invoke-Expression " $command $teeCommand "
}


function log($str) {
    $date = $(Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
    invoke " Write-Output '${date} $str' "
}

main
