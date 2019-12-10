. "$PSScriptRoot\config.user.ps1"

## ================================================
## function to split the lines at the end of the log file into individual slack notifications
#function createSlackMessage()
#{
#    $slackOut = Get-Content -Tail $logLinestoSlack -Path $log.filePath
#    $slackMessage = "*** DUPLICACY BACKUP PROCESS COMPLETE ***`n" + "-- " + "$( $slackOut -join "`n -- " )"
#    slackNotify($slackMessage)
#}
#
#function slackNotify($notify_text)
#{
#    $payload = @{
#        "text" = $notify_text
#    }
#
#    Invoke-WebRequest `
#      -Body (ConvertTo-Json -Compress -InputObject $payload) `
#      -ContentType 'application/json' `
#      -Method Post `
#      -Uri "$slackWebhookURL" | Out-Null
#}
#

# doRemotePing is called only at the end of the script IF $globalSuccessStatus is true.
# This style of pinging is useful as an 'all-or-nothing' approach:
#   all steps of the script MUST be successful otherwise this backup is considered failed.
#
# This functionality is useful for monitoring via platforms like `https://healthchecks.io`
#
# Note that doRemotePing does not check the status of $globalSuccessStatus.
#   It is caller's job to check that.
function doRemotePing
{
    log "=== doRemotePing"
    doHealthchecksIOPing
}

function doHealthchecksIOPing
{
    if ($healthchecksIOPingURL)
    {
        log "=== doHealthchecksIOPing"
        doPostRequest $healthchecksIOPingURL ""
    }
}

# doRemoteNotifications is called at script start/end and before/after a duplicacy command is run.
# The notification contains a $message in the body, it is not empty.
function doRemoteNotifications($message)
{
    log "=== doRemoteNotifications"
    doTelegramNotification $message
}

# Telegram notifications use the bot
# https://t.me/DuplicacyUtilsTBPBot
function doTelegramNotification($message)
{
    if ($telegramToken)
    {
        log "=== doTelegramNotification"
        $payload = @{
            content = ($message).ToString()
            chat_id = $telegramToken
        }

        $body = ConvertTo-Json -Compress -InputObject $payload
        $url = "https://duplicacy-utils.tbp.land/userUpdate"

        doPostRequest $url $body
    }
}

function doPostRequest($url, $body)
{
    doCall {
        Invoke-WebRequest `
        -Body $body `
        -ContentType 'application/json' `
        -Method Post `
        -Uri $url | Format-List -Property StatusCode, StatusDescription, Content
    }
}
