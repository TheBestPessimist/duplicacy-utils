# create systemd config (service+timer) which starts backup.ps1 on schedule

# the systemd user cfg folder
$systemdPath = '/etc/systemd/system/'

# create the service
$serviceUnitPath = $systemdPath + 'duplicacy-utils.service'
$serviceUnit = @"
[Unit]
Description=Duplicacy-utils backup

[Service]
ExecStart=/usr/bin/pwsh $PSScriptRoot/backup.ps1

"@

Out-File -Encoding utf8 -LiteralPath $serviceUnitPath -InputObject $serviceUnit



# the service is run by a timer
$timerUnitPath = $systemdPath + 'duplicacy-utils.timer'
$timerUnit = @"
[Unit]
Description=Run duplicacy-utils on schedule


# this "Requires" shouldn't be _required_ but systemd is software and therefore it has bugs
# ref: https://serverfault.com/questions/775246/systemd-timer-not-starting-its-service-unit
# ref: https://github.com/systemd/systemd/issues/6680#issuecomment-435597258

Requires=duplicacy-utils.service


[Timer]
# right now this is hardcoded to 4 hours
OnUnitInactiveSec=4h
Unit=duplicacy-utils.service

"@

Out-File -Encoding utf8 -LiteralPath $timerUnitPath -InputObject $timerUnit


# refresh systemd, enable the units and start the timer
systemctl daemon-reload

systemctl enable duplicacy-utils.timer
systemctl enable duplicacy-utils.service

systemctl start duplicacy-utils.timer

# show when the timer runs next
systemctl status duplicacy-utils.timer

systemctl list-timers duplicacy-utils.timer

# this is just for debugging
# sleep 6
# while($true){
#     clear
#     systemctl status duplicacy-utils.timer
#     systemctl status duplicacy-utils.service
#     sleep 0.5
# }
