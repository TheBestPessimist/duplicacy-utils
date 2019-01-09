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
    doCall "doTelegramNotification" @($message)
}


function doTelegramNotification($message)
{
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
    Invoke-WebRequest `
        -Body $body `
        -Method Post `
        -Uri $url
}
