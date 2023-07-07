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

@REM Iterate over every assembly, checking if we should strip or just copy
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

@REM Takes in a filename, and either strips it or copies it directly to the output folder.
:SUB filename
set "foundMatch=false"
@REM Check file against all files in dontTouch
(for %%b in (%dontTouch%) do (
  set checkDll=%%b
	
  if "%1" == "!checkDll!" (
    @REM Filename matches an entry in dontTouch, so just copy the dll
    xcopy "%managedPath%\%1" "%outPath%\%1" /y /v
	goto :eof
  )
))

if %foundMatch% == false (
  @REM Filename doesn't match anything in dontTouch, so strip normally
  %~dp0\tools\NStrip.exe "%managedPath%\%1" -o "%outPath%\%1"
)
goto :eof
