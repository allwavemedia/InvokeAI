@echo off
setlocal EnableExtensions EnableDelayedExpansion

@rem This script requires the user to install Python 3.10 or higher. All other
@rem requirements are downloaded as needed.

@rem change to the script's directory
PUSHD "%~dp0"

set "no_cache_dir=--no-cache-dir"
if "%1" == "use-cache" (
    set "no_cache_dir="
)

@rem Config
@rem The version in the next line is replaced by an up to date release number
@rem when create_installer.sh is run. Change the release number there.
set INVOKEAI_VERSION=v3.4.0post2
set INSTRUCTIONS=https://invoke-ai.github.io/InvokeAI/installation/INSTALL_AUTOMATED/
set TROUBLESHOOTING=https://invoke-ai.github.io/InvokeAI/installation/INSTALL_AUTOMATED/#troubleshooting
set PYTHON_URL=https://www.python.org/downloads/windows/
set MINIMUM_PYTHON_VERSION=3.10.0
set PYTHON_URL=https://www.python.org/downloads/release/python-3109/

set err_msg=An error has occurred and the script could not continue.

@rem --------------------------- Intro -------------------------------
echo This script will install InvokeAI and its dependencies.
echo.
echo BEFORE YOU START PLEASE MAKE SURE TO DO THE FOLLOWING
echo 1. Install python 3.10 or 3.11. Python version 3.9 is no longer supported.
echo 2. Double-click on the file WinLongPathsEnabled.reg in order to
echo    enable long path support on your system.
echo 3. Install the Visual C++ core libraries.
echo    Please download and install the libraries from:
echo    https://learn.microsoft.com/en-US/cpp/windows/latest-supported-vc-redist?view=msvc-170
echo.
echo See %INSTRUCTIONS% for more details.
echo.
echo FOR THE BEST USER EXPERIENCE WE SUGGEST MAXIMIZING THIS WINDOW NOW.
pause

@rem ---------------------------- check Python version ---------------
echo ***** Checking and Updating Python *****

call python --version >.tmp1 2>.tmp2
if %errorlevel% == 1 (
   set err_msg=Please install Python 3.10-11. See %INSTRUCTIONS% for details.
   goto err_exit
)

for /f "tokens=2" %%i in (.tmp1) do set python_version=%%i
if "%python_version%" == "" (
   set err_msg=No python was detected on your system. Please install Python version %MINIMUM_PYTHON_VERSION% or higher. We recommend Python 3.10.12 from %PYTHON_URL%
   goto err_exit
)

call :compareVersions %MINIMUM_PYTHON_VERSION% %python_version%
if %errorlevel% == 1 (
   set err_msg=Your version of Python is too low. You need at least %MINIMUM_PYTHON_VERSION% but you have %python_version%. We recommend Python 3.10.12 from %PYTHON_URL%
   goto err_exit
)

@rem Cleanup
del /q .tmp1 .tmp2

@rem -------------- Install and Configure ---------------

call python .\lib\main.py
pause
exit /b

@rem ------------------------ Subroutines ---------------
@rem routine to do comparison of semantic version numbers
@rem found at https://stackoverflow.com/questions/15807762/compare-version-numbers-in-batch-file
:compareVersions
::
:: Compares two version numbers and returns the result in the ERRORLEVEL
::
:: Returns 1 if version1 > version2
::         0 if version1 = version2
::        -1 if version1 < version2
::
:: The nodes must be delimited by . or , or -
::
:: Nodes are normally strictly numeric, without a 0 prefix. A letter suffix
:: is treated as a separate node
::
setlocal enableDelayedExpansion
set "v1=%~1"
set "v2=%~2"
call :divideLetters v1
call :divideLetters v2
:loop
call :parseNode "%v1%" n1 v1
call :parseNode "%v2%" n2 v2
if %n1% gtr %n2% exit /b 1
if %n1% lss %n2% exit /b -1
if not defined v1 if not defined v2 exit /b 0
if not defined v1 exit /b -1
if not defined v2 exit /b 1
goto :loop


:parseNode  version  nodeVar  remainderVar
for /f "tokens=1* delims=.,-" %%A in ("%~1") do (
  set "%~2=%%A"
  set "%~3=%%B"
)
exit /b


:divideLetters  versionVar
for %%C in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do set "%~1=!%~1:%%C=.%%C!"
exit /b

:err_exit
echo %err_msg%
echo The installer will exit now.
pause
exit /b

pause

:Trim
SetLocal EnableDelayedExpansion
set Params=%*
for /f "tokens=1*" %%a in ("!Params!") do EndLocal & set %1=%%b
exit /b
