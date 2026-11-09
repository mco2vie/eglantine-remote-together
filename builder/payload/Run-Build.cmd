@echo off
setlocal
rem Starts the local PowerShell builder. -ExecutionPolicy applies only to this process;
rem it does not change your Windows PowerShell settings.
set "CONFIG=%~1"
if "%CONFIG%"=="" set "CONFIG=%~dp0BuildConfig.json"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Build-SteamRemotePlay.ps1" -ConfigPath "%CONFIG%"
set "RESULT=%ERRORLEVEL%"
echo.
if "%RESULT%"=="0" (
    echo BUILD COMPLETED. The private output folder and zip are shown above.
) else (
    echo BUILD FAILED. The log and last-build-failure.json show what needs fixing.
)
echo.
pause
exit /b %RESULT%
