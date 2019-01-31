@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0/create-scheduled-task-windows-helper.ps1" -Verb RunAs
