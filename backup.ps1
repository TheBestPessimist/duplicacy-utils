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
$duplicacyExe = " .\z.exe "
$duplicacyOptions = " -d -log "
$duplicacyCommand = " $duplicacyExe $duplicacyOptions "
# $duplicacyBackup = " backup -vss -stats -threads 18 "
$duplicacyList = " list "
$duplicacyCheck = " check "
##############################

##############################
$teeCommand = " | Tee-Object -FilePath $logFile -Append "
##############################


function main {
    log "aaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    log "aaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    log "aaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    log "aaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    log "aaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    log "aaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

    doDuplicacyCommand $duplicacyList
    # $command = $duplicacyExe + $duplicacyOptions + $duplicacyCheck
    # Invoke-Expression $command

    # | Out-File ("a" + $(Get-Date).toString("yyyy-MM-dd HH-mm-ss"))




}

function doDuplicacyCommand($arg){
   invoke " $duplicacyCommand $arg "
}

function invoke($command) {
    Invoke-Expression " $command $teeCommand "
}


function log($str) {
    $date = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss:fff")
    invoke " Write-Output '${date} $str' "
}

Enum Fruit {
   Apple = 29
   Pear = 30
   Kiwi = 31
}

main



# $duplicacy = @{}        # this creates a hash table in powershell
# $duplicacy.exe = " .\z.exe "
# $duplicacy.options = " -d -log "
# $duplicacy.command = " $duplicacyExe $duplicacyOptions "
# $duplicacy.backup = " backup -vss -stats -threads 18 "
# $duplicacy.list = " list "
# $duplicacy.check = " check "
