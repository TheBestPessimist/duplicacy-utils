# ==============================================================================
# ==============================================================================
#
# User-configurable file. Please don't modify anything else!
#
#
# Please ensure that all folder paths have a "/" at the end
# Please give full paths wherever a path is needed.
#   (eg.: $duplicacyExePath = "C:/duplicacy installation/duplicacy 2.10.0.exe")
#
# ==============================================================================
# ==============================================================================

# ================================================
# Full path to the repository
$repositoryFolder = "C:/duplicacy repo/"

# ================================================
# Full path to Duplicacy exe
$duplicacyExePath = ".\z.exe"

# ================================================
# Should the "-d" flag (debuging) be used? (hint: it generally shouldn't)
$duplicacyDebug = $false        # or $true

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
