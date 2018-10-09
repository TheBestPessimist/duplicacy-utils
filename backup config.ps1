# ==============================================================================
# ==============================================================================
#
# User-configurable file. Please don't modify anything else!
#
# Note: by default, these scripts assume that they are located in the path relative
#   to duplicacy repository: "<duplicacy repo>/.duplicacy/duplicacy-utils/".
# - If that is true, then $repositoryFolder needs not be changed.
# - If that is not true (these scrips are in another folder) then you need to
#   fill the FULL path to the repository folder.
#
# Please ensure that all folder paths have a "/" at the end
# Please give full paths wherever a path is needed.
#   (eg.: $duplicacyExePath = "C:/duplicacy installation/duplicacy 2.10.0.exe")
#
# ==============================================================================
# ==============================================================================


# ================================================
# Full path to the repository

$repositoryFolder = (Get-Item $PSScriptRoot).Parent.Parent.FullName
# $repositoryFolder = "C:/duplicacy repositories/some documents/"
# $repositoryFolder = "C:/duplicacy repositories/my downloads/"


# ================================================
# Full path to Duplicacy exe
$duplicacyExePath = $repositoryFolder + ".duplicacy\duplicacy_win_x64_2.1.1.exe"



# ================================================
# Process Priority to use when executing duplicacy
# Possible values: Idle, BelowNormal, Normal, AboveNormal, High, RealTime

$duplicacyPriority = 'IDLE'


# ================================================
# Processor Affinity to use when executing duplicacy
# what CPU cores will be active? 0x1 = only the first one

$duplicacyProcessorAffinity = 0x1


# ================================================
# Should the "-d" flag (debuging) be used? (hint: it generally shouldn't)
$duplicacyDebug = $false        # or $true


# ================================================
# The name of the Scheduled Task when creating
$taskName = "Duplicacy Backup"


# ================================================
# Should the "-vss" flag be used for backup? (hint: better not use it as it may create problems)
# If the flag is used, a user with administrator rights should be set for the scheduled task!

$duplicacyVssOption = $true    # or $false
$duplicacyVssTimeout = 60    # in seconds


# ================================================
# The number of threads to use during backup
$duplicacyBackupNumberOfThreads = 2

# The number of threads to use during prune commands
$duplicacyPruneNumberOfThreads = 3

# The number of threads to use during copy to "offsite"
$duplicacyCopyNumberOfThreads = 4


# ================================================
# Number of Backup/Prune/Copy retries before giving up. 0 for no retries
# This is not passed to duplicacy app, and is instead a script level retry:
#   the duplicacy command is called again up to N times when not sucessful

$duplicacyRetries = 3 


# ================================================
# Max Upload rate when backing up (kB/s)
$duplicacyMaxUploadRate = "3000"

# Max Upload rate when copying to "offsite" (kB/s)
$duplicacyMaxCopyRate = "4000"


# ================================================
# The retention policy used for pruning.
# Retention policies are the same for default and "offsite" storages
# $ duplicacy prune -keep 1:7       # Keep 1 snapshot per day for snapshots older than 7 days
# $ duplicacy prune -keep 7:30      # Keep 1 snapshot every 7 days for snapshots older than 30 days

$duplicacyPruneRetentionPolicy = " -keep 0:1825 -keep 30:180 -keep 7:30 -keep 1:7" 	# Once per month from 18 to 6 months old, etc...

$duplicacyPruneExtraOptionsLocal = " -all " 	# -all, -exhaustive, -exclusive, etc

$duplicacyPruneExtraOptionsOffsite = " -all -exclusive -storage offsite " 	# -exhaustive, -exclusive, or other


# ================================================
# The script will GET this URL when sucessfull, allowing remote monitoring of backup jobs. ( E.g.: https://healthchecks.io )
# $getURLWhenDone = "URL to Health Check Ping"
