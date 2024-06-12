@echo off
setlocal enabledelayedexpansion

:: Get the directory where this batch script is located
set "script_dir=%~dp0"

:: Check if marker file exists
if not exist "%script_dir%\.first_run_marker.txt" (
    :: Run the installSSH.ps1 script
    PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%script_dir%installSSH.ps1""' -Verb RunAs -Wait}"

    :: Create hidden marker file
    echo First run completed > "%script_dir%\.first_run_marker.txt"
    attrib +h "%script_dir%\.first_run_marker.txt"
)

:: Run the connect.ps1 script
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%script_dir%connect.ps1"
