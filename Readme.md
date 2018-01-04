# Duplicacy powershell scripts

### About

The aim of these scripts is to help the windows user automate Duplicacy usage as much as possible.

The principle i followed with these is _set it and forget it_.

Currently there are 2 main scripts: `backup.ps1` and `create scheduled task.ps1`.

##### 1. `backup.ps1`

The purpose of this script is to run a duplicacy backup, or any other command by just 
calling the script and passing a simple argument: `backup` or `check` or `prune`.  
It uses the configuration file `backup config.ps1` in which the user sets only once various info such as

- the number of threads for backup
- if the `-vss` flag should be used
- the path to `duplicacy.exe`
- the repository folder
- etc.

The script also creates each day a new log file in a folder inside `[repository]/.duplicacy/` 
with all the details of any backup run or other command, just as if they were run from the console.


#### 2. `create scheduled task.ps1`

The purpose of this script is to create one or multiple Windows `Scheduled Tasks` which will run `backup.ps1` 
with the options the user set. 

It asks the user for credentials for adding the scheduled task 

---

___

***

### TODO

- guide for setting up powershell with minimum system modification

    
    - Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unsigned/Bypass
    - at the end, set executionpolicy to Undefined


- explanation of how to run the scripts, and that they need to be in the same folder
- send mail with the stats of the backup command
- save mail password to windows credentials manager, not in plaintext or some temp file which is just dumb
