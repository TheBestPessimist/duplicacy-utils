# ==============================================================================
# ==============================================================================
#
# Default configuration file. Please don't modify anything here,
#   but copy the line you want to edit to the file `user_config.ps1`
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

# Should the "-d" flag (debuging) be used? (hint: it generally shouldn't)
$duplicacyDebug = $false        # or $true


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

# The value of -limit-rate
$duplicacyLimitRate = 100000


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

# The number of threads to use during copy to "offsite"
$duplicacyCopyNumberOfThreads = 4

# Other options for offiste prune (retention is the same as local)
# -exhaustive, -exclusive, or other
$duplicacyPruneExtraOptionsOffsite = " -all -exclusive -storage offsite "
