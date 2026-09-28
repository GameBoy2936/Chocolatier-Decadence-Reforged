@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "NOPAUSE=0"
if /I "%~1"=="--no-pause" set "NOPAUSE=1"

set "OUTDIR=%~dp0bin"
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
set "OBJ=%TEMP%\ChocolatierReforgedLauncher.obj"
set "RES=%TEMP%\ChocolatierReforgedLauncher.res"

if not exist "%OUTDIR%" mkdir "%OUTDIR%"
del /q "%OBJ%" "%RES%" 2>nul

where cl.exe >nul 2>nul
if not errorlevel 1 goto tools_ready
if not exist "%VSWHERE%" goto no_tools
for /f "usebackq tokens=*" %%I in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSROOT=%%I"
if not defined VSROOT goto no_tools
call "%VSROOT%\VC\Auxiliary\Build\vcvars64.bat" >nul
if errorlevel 1 goto no_tools

:tools_ready
echo.
echo [1/3] Compiling launcher resources...
rc.exe /nologo /fo "%RES%" "%~dp0launcher.rc"
if errorlevel 1 goto resource_failed

echo [2/3] Compiling launcher source...
cl.exe /nologo /O2 /W4 /MT /c "%~dp0launcher.c" /Fo"%OBJ%"
if errorlevel 1 goto compile_failed

echo [3/3] Linking launcher...
link.exe /nologo /SUBSYSTEM:WINDOWS /OUT:"%OUTDIR%\Chocolatier Reforged.exe" "%OBJ%" "%RES%" kernel32.lib user32.lib winhttp.lib shell32.lib
if errorlevel 1 goto link_failed

if not exist "%OUTDIR%\Chocolatier Reforged.exe" goto output_missing

echo.
echo SUCCESS
echo Built: "%OUTDIR%\Chocolatier Reforged.exe"
del /q "%OBJ%" "%RES%" 2>nul
if "%NOPAUSE%"=="0" pause
exit /b 0

:resource_failed
echo.
echo ERROR: Resource compilation failed.
goto failed

:compile_failed
echo.
echo ERROR: C compilation failed.
goto failed

:link_failed
echo.
echo ERROR: Linking failed.
echo Review the linker output above for LNK errors.
goto failed

:output_missing
echo.
echo ERROR: Linker reported success but the launcher EXE was not created.
goto failed

:no_tools
echo.
echo ERROR: Microsoft Visual C++ x64 Build Tools were not found.
echo Install the "Desktop development with C++" workload on the RELEASE BUILD PC.
goto failed

:failed
del /q "%OBJ%" "%RES%" 2>nul
if "%NOPAUSE%"=="0" pause
exit /b 1
