@echo off 
SETLOCAL ENABLEDELAYEDEXPANSION

set toPublicize=Assembly-CSharp.dll Assembly-CSharp-firstpass.dll
set dontTouch=Newtonsoft.Json.dll mscorlib.dll netstandard.dll System.Core.dll System.Data.dll System.dll

set exePath=%1
echo exePath: %exePath% 

@REM Remove quotes
set exePath=%exePath:"=%

set managedPath=%exePath:.exe=_Data\Managed%
echo managedPath: %managedPath%

set outPath=%~dp0\package\lib

@REM Strip all assembiles, but keep them private.
(for %%a in ("%managedpath%\*") do (
  set filename=%%~nxa
  
  call :SUB !filename!
))

@REM Strip and publicize assemblies from toPublicize.
(for %%a in (%toPublicize%) do (
  echo a: %%a

  %~dp0\tools\NStrip.exe "%managedPath%\%%a" -o "%outPath%\%%a" -cg -p --cg-exclude-events
))

pause
goto :eof

:SUB filename
set "foundMatch=false"
(for %%b in (%dontTouch%) do (
  set checkDll=%%b
	
  if "%1" == "!checkDll!" (
    xcopy "%managedPath%\%1" "%outPath%\%1" /y /v
	goto :eof
  )
))

if %foundMatch% == false (
  %~dp0\tools\NStrip.exe "%managedPath%\%1" -o "%outPath%\%1"
)
goto :eof
