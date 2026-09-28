@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "SOURCE=%~dp0community_bridge_source.c"
set "OUTPUT=%~dp0ReforgedCommunityBridge.exe"
set "OBJ=%TEMP%\ReforgedCommunityBridge.obj"
set "BRIDGE_VERSION=0.2.13"
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"

if not exist "%SOURCE%" (
  echo ERROR: Missing community_bridge_source.c
  exit /b 1
)

rem Prefer an already configured Visual Studio developer shell.
where cl.exe >nul 2>nul
if not errorlevel 1 goto compile

rem Otherwise locate Visual Studio / Build Tools and initialize the x64 compiler.
if not exist "%VSWHERE%" (
  echo ERROR: Microsoft C++ Build Tools were not found.
  echo Install the Desktop development with C++ workload in Visual Studio,
  echo or run this script from an x64 Native Tools Command Prompt.
  exit /b 2
)

for /f "usebackq tokens=*" %%I in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSROOT=%%I"
if not defined VSROOT (
  echo ERROR: Visual Studio is installed, but the C++ x64 toolchain was not found.
  echo Add the Desktop development with C++ workload in Visual Studio Installer.
  exit /b 3
)

call "%VSROOT%\VC\Auxiliary\Build\vcvars64.bat" >nul
if errorlevel 1 (
  echo ERROR: Could not initialize the Visual Studio x64 compiler environment.
  exit /b 4
)

:compile
echo Building ReforgedCommunityBridge.exe...
if exist "%OUTPUT%" del /q "%OUTPUT%"
if exist "%OBJ%" del /q "%OBJ%"

rem Keep the bridge CRT-free. Optimized builds may replace append_text's manual
rem byte-copy loop with a CRT memcpy call, which cannot link under /NODEFAULTLIB.
cl.exe /nologo /Od /Oi- /GS- /TC /c "%SOURCE%" /Fo"%OBJ%"
if errorlevel 1 goto compile_failed

link.exe /nologo /NODEFAULTLIB /SUBSYSTEM:WINDOWS /ENTRY:mainCRTStartup /OUT:"%OUTPUT%" "%OBJ%" kernel32.lib wininet.lib shell32.lib
if errorlevel 1 goto link_failed

if not exist "%OUTPUT%" (
  echo ERROR: Compiler returned success, but the bridge executable was not produced.
  goto failed
)

echo Built successfully:
echo   %OUTPUT%
echo   Version: %BRIDGE_VERSION%

call "%~dp0..\deployment\sign-artifact.bat" "%OUTPUT%"
if errorlevel 1 goto failed

del /q "%OBJ%" 2>nul
exit /b 0

:compile_failed
echo ERROR: Community bridge compilation failed.
goto failed

:link_failed
echo ERROR: Community bridge linking failed.
goto failed

:failed
del /q "%OBJ%" 2>nul
exit /b 5
