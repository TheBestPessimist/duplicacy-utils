# ==============================================================================
# ==============================================================================
#
# Machine-local configurations file. 
# 
# Any setting here overrides the one from "default_config.ps1" file.
#
# Just copy here then modify the variables you need changed from the default file.
# In this way when duplicacy utils will be updated in the future, there should be no conflicts
# since only this file is modified (by you) and not the default one!


# ============================
# Examples:

# $repositoryFolder = "C:\Duplicacy\"
# $repositoryFolder = "C:/duplicacy repositories/some documents/"
# $repositoryFolder = "C:/duplicacy repositories/my downloads/"

# Full path to Duplicacy.exe
# $duplicacyExePath = "C:\Duplicacy\.duplicacy\duplicacy_win_x64_2.1.1.exe"

# Should the "-d" flag (debuging) be used? (hint: it generally shouldn't)
# $duplicacyDebug = $true

# The number of threads to use during backup
# $duplicacyBackupNumberOfThreads = 18

# Prune retention: once per month from 18 to 6 months old, etc...
# $pruneRetentionPolicyLocal = " -keep 0:1825 -keep 30:180 -keep 7:30 -keep 1:7 "

# Other options for prune:
# $duplicacyPruneExtraOptionsLocal = " -all -exhaustive "
# ==============================================================================
# ==============================================================================

# ================================================
# What commands you want to execute: set to $true
$runBackup = $true
$runPrune = $false
$runCheck = $false
$runPruneOffsite = $false
$runCopyToOffsite = $false

