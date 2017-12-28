##############################
# This script assumes that it is run form the same folder as the duplicacy
# executable (eg. from __the repository__).
#
# If it is run as an Administrator, the backup command will use
# the -vss flag (Shadow Copy), which can only be used as an Administrator.
# This is not a hard requirement though. The flag is NOT added if a
# non-admin user starts the script.
#
# Thanks to <bassebaba/DuplicacyPowershell> for the initial script which
# inspired this one and from which i borrowed some parts.
#
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
$duplicacy = @{             # this creates a hash table in powershell
    exe = " .\z.exe "
    options = " -d -log "
    backup = " backup -stats -threads 18 "
    list = " list "
    check = " check "
    # vssOption = $false
    vssOption = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}
$duplicacy.command = $duplicacy.exe + $duplicacy.options
if($duplicacy.vssOption) {
    $duplicacy.backup += " -vss "
}
##############################

##############################
$teeCommand = " | Tee-Object -FilePath $logFile -Append "
##############################


function main {
    logStartBackupProcess

    doDuplicacyCommand $duplicacy.list
    doDuplicacyCommand $duplicacy.backup

    logFinishBackupProcess
}

function logStartBackupProcess {
    $date = $(Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    log
    log
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

function elevateAsAdmin() {
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
    }
}

# elevateAsAdmin
main
# Read-Host "Press ENTER"
