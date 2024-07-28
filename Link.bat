@echo off
setlocal enabledelayedexpansion

:: Get the directory where this batch script is located
set "script_dir=%~dp0"

:: Check if marker file exists
if not exist "%script_dir%\.first_run_marker.txt" (
    :: Run the installSSH.ps1 script
    PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%script_dir%installSSH.ps1""' -Verb RunAs -Wait}"

    :: Set the key file name
    set keyfile=key

    :: Check if the key file exists
    if not exist "%script_dir%!keyfile!" (
        echo Key file not found: %script_dir%!keyfile!
        pause
        exit /b 1
    )

    :: Change permissions of the key file
    icacls "%script_dir%!keyfile!" /inheritance:r /grant:r %username%:F

    :: Check if the command was successful
    if %errorlevel% neq 0 (
        echo Failed to change permissions for: %script_dir%!keyfile!
        pause
        exit /b 1
    )

    echo Permissions successfully updated for: %script_dir%!keyfile!

    :: Create hidden marker file
    echo First run completed > "%script_dir%\.first_run_marker.txt"
    attrib +h "%script_dir%\.first_run_marker.txt"
)

:: Run the connect.ps1 script
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%script_dir%connect.ps1"
