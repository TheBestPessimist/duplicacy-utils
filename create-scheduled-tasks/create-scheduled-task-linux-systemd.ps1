# Create systemd config (service+timer) which starts backup.ps1 on schedule

# ================================================
# Import the global and local config file

. "$PSScriptRoot\..\config.default.ps1"
. "$PSScriptRoot\..\config.user.ps1"
# ================================================

# the systemd user cfg folder
$systemdPath = '/etc/systemd/system/'
$scheduledTaskName = $scheduledTaskName.replace(' ', '-')

function createService
{
    $serviceUnitPath = $systemdPath + 'duplicacy-utils-' + $scheduledTaskName + '.service'
    $serviceUnit = @"
[Unit]
Description=$scheduledTaskName
Requires=network-online.target
After=network.target network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/pwsh $backupScriptPath

"@
    Out-File -Encoding utf8 -LiteralPath $serviceUnitPath -InputObject $serviceUnit
}


# the service is run by a timer
function createTimer
{
    $timerUnitPath = $systemdPath +'duplicacy-utils-' + $scheduledTaskName + '.timer'
    $timerUnit = @"
[Unit]
Description=Run duplicacy-utils on schedule


# this "Requires" shouldn't be _required_ but systemd is software and therefore it has bugs
# ref: https://serverfault.com/questions/775246/systemd-timer-not-starting-its-service-unit
# ref: https://github.com/systemd/systemd/issues/6680#issuecomment-435597258

Requires=duplicacy-utils-$scheduledTaskName.service


[Timer]

OnUnitInactiveSec=$( $scheduledTaskRepetitionInterval.TotalHours )h
RandomizedDelaySec=$( $scheduledTaskRandomDelay.TotalMinutes )m
Unit=duplicacy-utils-$scheduledTaskName.service

[Install]
WantedBy=timers.target

"@
    Out-File -Encoding utf8 -LiteralPath $timerUnitPath -InputObject $timerUnit
}


# Enable and start Everything
function startTimerAndService
{
    # refresh systemd, enable the units and start the timer
    systemctl daemon-reload

    systemctl enable duplicacy-utils-$scheduledTaskName.timer

    systemctl start duplicacy-utils-$scheduledTaskName.timer

    echo "`n`n status of the timer: "
    systemctl status duplicacy-utils-$scheduledTaskName.timer

    echo "`n`n timer runs next @: "
    systemctl list-timers duplicacy-utils-$scheduledTaskName.timer
}

function main
{
    createService
    createTimer
    startTimerAndService
}



main


## this is just for debugging
# sleep 6
# while($true){
#     clear
#     systemctl list-timers duplicacy-utils.timer
#     sleep 0.5
# }
