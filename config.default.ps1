# ==============================================================================
# ==============================================================================
#
# Default configuration file. Please don't modify anything here,
#   but copy the line you want to edit to the file `config.user.ps1`
#   and do the edit there.
#   In this way when duplicacy utils will be updated in the future, there should be no conflicts.
#
# Note: by default, these scripts assume that they are located in the path relative
#   to duplicacy repository: "<duplicacy repo>/.duplicacy/duplicacy-utils/".
# - If that is true, then $repositoryFolder needs not be changed.
# - If that is not true (these scrips are in another folder) then you need to
#   fill the FULL path to the repository folder.
#
# Please ensure that all folder paths have a "/" at the end
# Although relative paths are ok, when in doubt DO give full paths wherever a path is needed.
#   (eg.: $duplicacyExePath = "C:/duplicacy installation/duplicacy 2.10.0.exe")
#
# ==============================================================================
# ==============================================================================

# ==============================================================================
# ==============================================================================
# ========      Generic configuration

# ================================================
# Full path to the repository

$repositoryFolder = (Get-Item $PSScriptRoot).Parent.Parent.FullName
# $repositoryFolder = "C:/duplicacy repositories/some documents/"
# $repositoryFolder = "C:/duplicacy repositories/my downloads/"

# Full path to Duplicacy.exe
$duplicacyExePath = ".duplicacy/z.exe"

# Backup script full path
$backupScriptPath = (Resolve-Path -Path "$PSScriptRoot\backup.ps1").Path

# Should the "-d" flag (debuging) be used? (hint: it generally shouldn't)
$duplicacyDebug = $false        # or $true

# ================================================
# The name used when creating the Scheduled Task
#       and also when sending notifications
# Recommendation: please use unique names for each different task (backup prune, etc.),
#       as tasks which already exist WILL BE REPLACED!
$scheduledTaskName = "Duplicacy Backup"



# ================================================
# How often to run the backup:
#       1 hour:       run the backup every hour,
#       3 hours:      run the backup every 3 hours,
#       1 day:        run the backup every day (once a day)
# $repetitionInterval = (New-TimeSpan -Hours 1)
# $repetitionInterval = (New-TimeSpan -Hours 3)
# $repetitionInterval = (New-TimeSpan -Days 1)
#
$scheduledTaskRepetitionInterval = (New-TimeSpan -Hours 4)

# ================================================
# Add a random time delay before starting the backup between 0 and $randomDelay minutes.
# Helpful in case multiple backups start at the exact same time, so that the machine won't be slowed to a crawl
$scheduledTaskRandomDelay = (New-TimeSpan -Minutes 3)  # 3 minutes of random start delay is sufficient


# ================================================
# What commands you want to execute

$runBackup = $false
$runPrune = $false
$runCheck = $false
$runPruneOffsite = $false
$runCopyToOffsite = $false


# ==============================================================================
# ==============================================================================
# ======== Backup configuration

# Should the "-vss" flag be used for backup? (hint: better not use it as it may create problems)
# If the flag is used, a user with administrator rights should be set for the scheduled task!
$duplicacyVssOption = $false    # or $true
$duplicacyVssTimeout = 60       # in seconds

# The number of threads to use during backup
$duplicacyBackupNumberOfThreads = 1


# The max transfer rate for backup (value of -limit-rate)
$maxBackupTransferRate = 100000


# ==============================================================================
# ==============================================================================
# ========       Prune configuration

# The retention policy used for pruning.
# Retention policies are the same for default and "offsite" storages
# $ duplicacy prune -keep 1:7       # Keep 1 snapshot per day for snapshots older than 7 days
# $ duplicacy prune -keep 7:30      # Keep 1 snapshot every 7 days for snapshots older than 30 days

# Once per month from 18 to 6 months old, etc...
$pruneRetentionPolicyLocal = " -keep 0:1825 -keep 30:180 -keep 7:30 -keep 1:7"

# Other options for prune:
# -all, -exhaustive, -exclusive, etc
$duplicacyPruneExtraOptionsLocal = "  "

# The number of threads to use during prune commands
$duplicacyPruneNumberOfThreads = 4




# ==============================================================================
# ==============================================================================
# ========       Offsite repository configuration

# The name of the offsite storage
$offsiteStorageName = "offsite"

# The number of threads to use during copy to "offsite"
$duplicacyCopyNumberOfThreads = 4

# The max transfer rate for copy (value of -upload-limit-rate)
$maxCopyTransferRate = 100000

# By default the copy operation copies all the snapshot IDs
# If you want to copy only a specific one, fill it's name here
# This fills the `-id` parameter
# Reference: https://forum.duplicacy.com/t/copy-command-details/1083
$copySnapshotId = ""

# Other options for offiste prune (retention is the same as local)
# -exhaustive, -exclusive, or other
$duplicacyPruneExtraOptionsOffsite = " -all -storage $offsiteStorageName "


# ==============================================================================
# ==============================================================================
# ========       Notifications configuration

# By default whenever a command starts or ends a notification will be sent (eg. to Telegram).
# If $mergeNotificationsIntoOne is set to $true then all notifications will be merged into a single one.
# Basically you get a single notification at the end with the complete text instead of multiple notifications.
$mergeNotificationsIntoOne = $false

# By default, log messages will be written to standard output and also to a log file.
# If you want the backup script to operate in "quiet mode", for example when it is being called by cron,
# set $doNotWriteToStdout to $true.
$doNotWriteToStdout = $false
