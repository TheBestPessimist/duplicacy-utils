
$logFilePath = "C:\Users\crist\Desktop\powershell-log.txt"


function main()
{
    $demoText = "z -log backup -storage gdrive-test1939 -stats -threads 32"
    getLastBackupStats($demoText)
}

function getLastBackupStats($backupCommand)
{
    if ($backupCommand -like '* backup *')
    {
        $dupOut = Get-Content -Tail 10 -Path $logFilePath
        logStats $dupOut
    }
}

function logStats($dupOutput)
{
    $backupStatsArr = $dupOutput.Split("`n")
#    Write-Output $backupStatsArr
    #    Backup for D:\backup_software_test\duplicacy repo at revision 3 completed
    foreach ($line in $backupStatsArr)
    {
        if ($line -like "*backup for*at revision*completed")
        {
            #            Write-Output "aaaaaaaaaaaaaaaa"
            #            Write-Output $line
            #            Write-Output $backupStatsArr.indexOf($line)
            $pos = $backupStatsArr.indexOf($line)
            $backupStatsArr = $backupStatsArr[$pos..($pos + 5)]
            break
        }
    }
    Write-Output "aaaaaaaaaaaaaaaa"
    Write-Output $backupStatsArr

    #    try
    #    {
    #        $backupStats = $dupOutput.Split("`n") | Select-String -Pattern 'All chunks'
    #        $match = ([regex]::Match($backupStats, '(.*)total, (.*) bytes; (.*) new, (.*) bytes, (.*) bytes'))
    #        $tot = formatData( $match.Groups[2].Value)
    #        $new = formatData( $match.Groups[4].Value)
    #        $upload = formatData( $match.Groups[5].Value)
    #        return "$tot, $new -> upload $upload"
    #    }
    #    Catch
    #    {
    #        return "Could not parse stats"
    #    }
}

function formatData($str)
{
    $last = $str[-1]
    $foo = ($str -replace ".$") / 1000
    $bar = [int]$foo
    if ($last -eq "K")
    {
        return "$bar MB"
    }
    elseif ($last -eq "M")
    {
        return "$bar GB"
    }
    return $str

}


main



# #=========================================================================================================
# # TODO: We should not exit upon first fail but instead continue and back up as much as possbile
# # TODO: Check if exe is running already: Get-Process | ?{$_.path -eq "C:\Program Files (x86)\Notepad++\notepad++.exe"}
# # Version: 0.0.5
# #=========================================================================================================

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

