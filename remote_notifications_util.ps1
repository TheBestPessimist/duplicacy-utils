. "$PSScriptRoot\user_config.ps1"

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
#      -Method Post `
#      -Uri "$slackWebhookURL" | Out-Null
#}
#


function doRemoteNotifications($message)
{
    doTelegramNotification $message
}


function doTelegramNotification($message)
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

function doPostRequest($url, $body)
{
    doCall {
        Invoke-WebRequest `
        -Body $body `
        -Method Post `
        -Uri $url | Format-List -Property StatusCode, StatusDescription, Content
    }
}
