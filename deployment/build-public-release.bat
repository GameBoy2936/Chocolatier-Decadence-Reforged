@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set "REFORGED_PUBLIC_VERSION=2.0.1"
rem Production Community server baseline: Chocolatier_Community_Server_v1.1.2-bar-appearance-hotfix.zip
set "COMMUNITY_SERVER_VERSION=1.1.2"
set "REFORGED_REQUIRE_SIGNING=1"
set "PRODUCTION_HOST=scores.chocolatiercommunity.com"
set "HISCORE_URL=http://scores.chocolatiercommunity.com/hiscore"
set "UPDATE_BASE_URL=https://scores.chocolatiercommunity.com/releases"
set "RELEASE_CHANNEL=stable"
set "ROOT=%~dp0.."
set "ISCC="

if not exist "%ROOT%\assets" (
  echo ERROR: deployment must sit directly inside the Reforged game root.
  exit /b 1
)
if not exist "%ROOT%\community_bridge\community_bridge_source.c" (
  echo ERROR: Missing Community bridge source.
  exit /b 2
)
if not exist "%ROOT%\README.md" (
  echo ERROR: Missing public README.md.
  exit /b 21
)
if not exist "%ROOT%\CHANGELOG.md" (
  echo ERROR: Missing public CHANGELOG.md.
  exit /b 22
)
findstr /I /C:"v%REFORGED_PUBLIC_VERSION%" "%ROOT%\CHANGELOG.md" >nul 2>nul
if errorlevel 1 (
  echo ERROR: CHANGELOG.md does not identify Reforged v%REFORGED_PUBLIC_VERSION%.
  exit /b 23
)

rem Public-build safety gates: no release-critical source/config may still point at staging.
for %%F in (
  "%ROOT%\community_bridge\community_bridge_source.c"
  "%ROOT%\community_bridge\server.txt"
  "%ROOT%\hiscoreserver.txt"
) do (
  if exist "%%~F" (
    findstr /I /C:"scores-staging.chocolatiercommunity.com" "%%~F" >nul 2>nul
    if not errorlevel 1 (
      echo ERROR: %%~F still contains the STAGING hostname.
      echo Public releases must use %PRODUCTION_HOST%.
      exit /b 3
    )
  )
)

rem Runtime-asset hygiene: source-only tools and working files belong under development, not assets.
for /r "%ROOT%\assets" %%F in (*.psd *.py *.bak *.orig *.tmp *.spec *.lnk *_old.*) do (
  echo ERROR: Development artifact found in runtime assets: %%~fF
  exit /b 12
)
for /r "%ROOT%\assets" %%F in ("* copy.*") do (
  echo ERROR: Working-copy asset found in runtime assets: %%~fF
  exit /b 19
)
if exist "%ROOT%\assets\sim\ui" (
  echo ERROR: Stale assets\sim\ui development copy is present.
  exit /b 13
)
if exist "%ROOT%\assets\sim\firstpeek.lua" (
  echo ERROR: Legacy FirstPeek telemetry script is present in runtime assets.
  exit /b 14
)
findstr /I /C:"<firstpeek>" "%ROOT%\assets\settings.xml" >nul 2>nul
if not errorlevel 1 (
  echo ERROR: Legacy FirstPeek setting is present in assets\settings.xml.
  exit /b 20
)
if exist "%ROOT%\assets\dev\community_network_test.lua" (
  echo ERROR: Community network test script is present in runtime assets.
  exit /b 15
)
if exist "%ROOT%\assets\dev\dev_utils.before-community-v02.lua" (
  echo ERROR: Stale developer utility backup is present in runtime assets.
  exit /b 16
)
findstr /S /I /C:"temporary character for testing" "%ROOT%\assets\*.lua" >nul 2>nul
if not errorlevel 1 (
  echo ERROR: Temporary test character placement remains in runtime Lua.
  exit /b 17
)

rem Tangier uses explicit Rank 2 residents. Without these bindings the engine falls
rem back to the unfinished generic tan_shopkeep/tan_barkeep placeholder portraits.
findstr /L /C:"tan_shop:SetCharacters" "%ROOT%\assets\ports\tangiers\tangiers.lua" | findstr /L /C:"main_zach" >nul 2>nul
if errorlevel 1 (
  echo ERROR: Tangier shop is not bound to Zachariah Tangye ^(main_zach^).
  exit /b 24
)
findstr /L /C:"tan_bar:SetCharacters" "%ROOT%\assets\ports\tangiers\tangiers.lua" | findstr /L /C:"evil_bian" >nul 2>nul
if errorlevel 1 (
  echo ERROR: Tangier bar is not bound to Bianca Rabiti ^(evil_bian^).
  exit /b 25
)
findstr /S /I /C:"Google Gemini AI" "%ROOT%\assets\*.lua" >nul 2>nul
if not errorlevel 1 (
  echo ERROR: Development-era AI attribution remains in runtime Lua headers.
  exit /b 18
)

rem The in-game Community modules now share one version constant. Refuse a build
rem if it drifts from the installer/client version.
findstr /I /C:"%REFORGED_PUBLIC_VERSION%" "%ROOT%\assets\community\version.lua" >nul 2>nul
if errorlevel 1 (
  echo ERROR: assets\community\version.lua does not match Reforged v%REFORGED_PUBLIC_VERSION%.
  exit /b 10
)
findstr /S /I /C:"alpha-profile" "%ROOT%\assets\community\*.lua" >nul 2>nul
if not errorlevel 1 (
  echo ERROR: An old alpha client version string is still present in assets\community.
  exit /b 11
)

call "%ROOT%\community_bridge\build-native-bridge.bat"
if errorlevel 1 exit /b 4
call "%~dp0build-launcher.bat" --no-pause
if errorlevel 1 exit /b 5

if not exist "%~dp0generated" mkdir "%~dp0generated"
>"%~dp0generated\server.txt" echo %PRODUCTION_HOST%
>"%~dp0generated\hiscoreserver.txt" echo %HISCORE_URL%
>"%~dp0generated\CLIENT_VERSION.txt" echo %REFORGED_PUBLIC_VERSION%
>"%~dp0generated\RELEASE_CHANNEL.txt" echo %RELEASE_CHANNEL%
>"%~dp0generated\REFORGED_RELEASE.txt" echo Chocolatier: Decadence by Design Reforged v%REFORGED_PUBLIC_VERSION%
>>"%~dp0generated\REFORGED_RELEASE.txt" echo Community Services: %COMMUNITY_SERVER_VERSION%
>>"%~dp0generated\REFORGED_RELEASE.txt" echo Community Bridge: 0.2.13
>>"%~dp0generated\REFORGED_RELEASE.txt" echo Community Host: %PRODUCTION_HOST%
>>"%~dp0generated\REFORGED_RELEASE.txt" echo Change Notes: CHANGELOG-Reforged.md

for %%P in ("%ProgramFiles%\Inno Setup 7\ISCC.exe" "%ProgramFiles(x86)%\Inno Setup 7\ISCC.exe" "%ProgramFiles%\Inno Setup 6\ISCC.exe" "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe") do (
  if not defined ISCC if exist "%%~P" set "ISCC=%%~P"
)
if not defined ISCC (
  echo ERROR: Inno Setup 6 or 7 was not found on the RELEASE BUILD PC.
  exit /b 6
)

if exist "%~dp0dist" rmdir /s /q "%~dp0dist"
"%ISCC%" "%~dp0installer-public.iss"
if errorlevel 1 exit /b 7

set "INSTALLER_PATH="
set "INSTALLER_NAME="
set "INSTALLER_SHA256="
set "NOTES_PATH="
set "NOTES_NAME=Chocolatier-Reforged-v%REFORGED_PUBLIC_VERSION%-Change-Notes.md"
set "NOTES_SHA256="
for %%F in ("%~dp0dist\Chocolatier-Reforged-v%REFORGED_PUBLIC_VERSION%-Setup.exe") do (
  set "INSTALLER_PATH=%%~fF"
  set "INSTALLER_NAME=%%~nxF"
)
if not defined INSTALLER_PATH (
  echo ERROR: Expected installer output was not found.
  exit /b 8
)

call "%~dp0sign-artifact.bat" "!INSTALLER_PATH!"
if errorlevel 1 exit /b 26

for /f "usebackq delims=" %%H in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "(Get-FileHash -LiteralPath '!INSTALLER_PATH!' -Algorithm SHA256).Hash.ToLowerInvariant()"`) do set "INSTALLER_SHA256=%%H"
if not defined INSTALLER_SHA256 (
  echo ERROR: Could not calculate installer SHA-256.
  exit /b 9
)

copy /y "%ROOT%\CHANGELOG.md" "%~dp0dist\!NOTES_NAME!" >nul
if errorlevel 1 (
  echo ERROR: Could not stage public change notes.
  exit /b 24
)
for %%F in ("%~dp0dist\!NOTES_NAME!") do set "NOTES_PATH=%%~fF"
for /f "usebackq delims=" %%H in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "(Get-FileHash -LiteralPath '!NOTES_PATH!' -Algorithm SHA256).Hash.ToLowerInvariant()"`) do set "NOTES_SHA256=%%H"
if not defined NOTES_SHA256 (
  echo ERROR: Could not calculate change-notes SHA-256.
  exit /b 25
)

>"%~dp0dist\latest-release.json" echo {
>>"%~dp0dist\latest-release.json" echo   "product": "chocolatier-dbd-reforged",
>>"%~dp0dist\latest-release.json" echo   "channel": "%RELEASE_CHANNEL%",
>>"%~dp0dist\latest-release.json" echo   "version": "%REFORGED_PUBLIC_VERSION%",
>>"%~dp0dist\latest-release.json" echo   "installer": "!INSTALLER_NAME!",
>>"%~dp0dist\latest-release.json" echo   "download_url": "%UPDATE_BASE_URL%/!INSTALLER_NAME!",
>>"%~dp0dist\latest-release.json" echo   "sha256": "!INSTALLER_SHA256!",
>>"%~dp0dist\latest-release.json" echo   "release_notes": "!NOTES_NAME!",
>>"%~dp0dist\latest-release.json" echo   "release_notes_url": "%UPDATE_BASE_URL%/!NOTES_NAME!",
>>"%~dp0dist\latest-release.json" echo   "release_notes_sha256": "!NOTES_SHA256!"
>>"%~dp0dist\latest-release.json" echo }

echo.
echo PUBLIC INSTALLER BUILT SUCCESSFULLY
echo   !INSTALLER_PATH!
echo   SHA-256: !INSTALLER_SHA256!
echo   Change notes: !NOTES_PATH!
echo   Change-notes SHA-256: !NOTES_SHA256!
echo   Update manifest: %~dp0dist\latest-release.json
echo   Update manifest URL: %UPDATE_BASE_URL%/latest-release.json
echo.
echo This same installer supports both a first-time Reforged install and an in-place update.
echo Publish the installer and change notes first, then latest-release.json LAST so existing clients never see an incomplete release.
exit /b 0
