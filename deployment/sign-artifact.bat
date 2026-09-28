@echo off
setlocal EnableExtensions

set "TARGET=%~1"
set "MODE=%~2"
if not defined TARGET (
  echo ERROR: sign-artifact.bat requires a file path.
  exit /b 2
)
if not exist "%TARGET%" (
  echo ERROR: Cannot sign missing file:
  echo   %TARGET%
  exit /b 3
)

if not defined REFORGED_SIGN_CERT_THUMBPRINT (
  if /I "%REFORGED_REQUIRE_SIGNING%"=="1" (
    echo ERROR: Public release signing is required, but REFORGED_SIGN_CERT_THUMBPRINT is not set.
    echo Install a trusted code-signing certificate and set its SHA-1 thumbprint in that environment variable.
    exit /b 4
  )
  echo Signing skipped for %~nx1 ^(REFORGED_SIGN_CERT_THUMBPRINT is not set^).
  exit /b 0
)

where signtool.exe >nul 2>nul
if errorlevel 1 (
  echo ERROR: signtool.exe was not found.
  echo Install the Windows SDK Signing Tools component or run from a Developer Command Prompt.
  exit /b 5
)

set "CERT_STORE=Cert:\CurrentUser\My"
if /I "%REFORGED_SIGN_MACHINE_STORE%"=="1" set "CERT_STORE=Cert:\LocalMachine\My"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$t = '%REFORGED_SIGN_CERT_THUMBPRINT%'.Replace(' ','').ToUpperInvariant(); $c = Get-ChildItem '%CERT_STORE%' | Where-Object { $_.Thumbprint.ToUpperInvariant() -eq $t } | Select-Object -First 1; if (-not $c) { Write-Host 'ERROR: Signing certificate not found in %CERT_STORE%.'; exit 1 }; if ($c.PublicKey.Oid.Value -ne '1.2.840.113549.1.1.1') { Write-Host ('ERROR: Smart App Control requires RSA signing; certificate key algorithm is ' + $c.PublicKey.Oid.FriendlyName + '.'); exit 2 }"
if errorlevel 1 exit /b 9

if not defined REFORGED_SIGN_TIMESTAMP_URL set "REFORGED_SIGN_TIMESTAMP_URL=http://timestamp.digicert.com"

set "STORE_SWITCH="
if /I "%REFORGED_SIGN_MACHINE_STORE%"=="1" set "STORE_SWITCH=/sm"

if /I not "%MODE%"=="--verify-only" (
  echo Signing:
  echo   %TARGET%
  signtool.exe sign %STORE_SWITCH% /sha1 "%REFORGED_SIGN_CERT_THUMBPRINT%" /fd SHA256 /tr "%REFORGED_SIGN_TIMESTAMP_URL%" /td SHA256 /v "%TARGET%"
  if errorlevel 1 (
    echo ERROR: Authenticode signing failed for %~nx1.
    exit /b 6
  )
) else (
  echo Verifying existing signature:
  echo   %TARGET%
)

signtool.exe verify /pa /v "%TARGET%"
if errorlevel 1 (
  echo ERROR: Authenticode verification failed for %~nx1.
  exit /b 7
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$s = Get-AuthenticodeSignature -LiteralPath '%TARGET%'; if ($s.Status -ne 'Valid') { Write-Host ('ERROR: Signature status is ' + $s.Status); exit 1 }"
if errorlevel 1 exit /b 8

echo Signature verified for %~nx1.
exit /b 0
