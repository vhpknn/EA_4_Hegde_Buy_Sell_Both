@echo off
setlocal EnableExtensions
title Hedge1 - Session Evidence Collector

set "RC=1"

pushd "%~dp0" >nul 2>&1
if errorlevel 1 goto folder_error

echo ==================================================
echo   Hedge1 - Session Evidence Collector
echo   Read-only MT5 log collection. No trade commands.
echo ==================================================
echo.

if not exist "Hedge1_CollectSession.py" goto missing_script

rem Prefer the Windows Python launcher.
py -3 -c "import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)" >nul 2>&1
if not errorlevel 1 goto run_with_py

rem Fall back to python if the launcher is unavailable.
python -c "import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)" >nul 2>&1
if not errorlevel 1 goto run_with_python

echo [ERROR] Python 3.8 or newer was not found.
echo Install Python or check your Python PATH.
goto finish

:run_with_py
py -3 -u "Hedge1_CollectSession.py"
set "RC=%ERRORLEVEL%"
goto process_finished

:run_with_python
python -u "Hedge1_CollectSession.py"
set "RC=%ERRORLEVEL%"
goto process_finished

:process_finished
echo.
echo ==================================================
echo Collector process ended. Exit code: %RC%
echo Check the export summary and metadata.json.
echo Exit code 0 does NOT mean the EA test passed.
echo ==================================================
goto finish

:missing_script
echo [ERROR] Hedge1_CollectSession.py was not found.
echo Put run.bat and the Python script in the same folder.
goto finish

:finish
echo.
popd
pause
endlocal & exit /b %RC%

:folder_error
echo [ERROR] Cannot open the folder containing run.bat.
pause
endlocal
exit /b 1