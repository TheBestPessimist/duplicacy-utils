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
$duplicacyExePath = ".\z.exe"

# ================================================
# Should the "-d" flag (debuging) be used? (hint: it generally shouldn't)
$duplicacyDebug = $true        # or $false

# ================================================
# Should the "-vss" flag be used for backup? (hint: better not use it as it may create problems)
# If the flag is used, a user with administrator rights should be set for the scheduled task!
$duplicacyVssOption = $false    # or $true

# ================================================
# The number of threads to use for backup
$duplicacyBackupNumberOfThreads = 18

# ================================================
# The retention policy used for pruning.
#
# prune explanation (from here: https://github.com/gilbertchen/duplicacy/wiki/prune ):
# $ duplicacy prune -keep 1:7       # Keep 1 snapshot per day for snapshots older than 7 days
# $ duplicacy prune -keep 7:30      # Keep 1 snapshot every 7 days for snapshots older than 30 days
#
# Note: the order has to be from the eldest to the youngest! (hence 30 comes before 7)
$duplicacyPruneRetentionPolicy = "-keep 7:30 -keep 1:7"
# $duplicacyPruneRetentionPolicy = "-keep 0:90 -keep 7:30 -keep 1:7"
