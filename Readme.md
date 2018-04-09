# Duplicacy utils

The aim of these scripts is to help the windows user automate Duplicacy usage as much as possible.

The principle i followed with these is _set it and forget it_.

---

Currently there are 2 main scripts: `backup.ps1` and `create scheduled task.ps1`, and a generic `filters`
file for Windows and MacOS.

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


##### 2. `create scheduled task.ps1`

The purpose of this script is to create one or multiple Windows `Scheduled Tasks` which will run `backup.ps1`
with the options the user set.

It asks the user for credentials for adding the scheduled task .

##### 3. `filters`

This is a duplicacy ignore file which stores some exclude patters for Windows and MacOS.

It should be edited as needed, either by commenting lines (put `#` at the beginning) or uncommenting them (remove `#` at the beginning).

The way the file is created, there should be no need to edit it currently, as it _should_ remove no user data.

---


### TODO (HELP NEEDED)

- `filters`
    - improve the exclude rules for MacOS


- misc
    - name/organize the scripts better


- readme
    - explanation of how to run the scripts, and that they need to be in the same folder


- backup
    - send mail/notification with the statistics of the run (and other info)
    - save mail/notification password/token to windows credentials manager, not in plaintext or some temp file which is just dumb


### Changelog

##### 2018.04.09
- Improved the filters file with more (better?) regex from [NiJoao](https://github.com/NiJoao).


##### 2018.01.31

- There is no need to do anything to powershell. Just running the .bat file to create the Scheduled Task is enough.
