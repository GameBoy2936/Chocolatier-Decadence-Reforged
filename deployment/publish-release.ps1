param(
    [string]$Server = $env:REFORGED_RELEASE_SERVER,
    [string]$KeyPath = $env:REFORGED_RELEASE_KEY,
    [string]$DistDir = (Join-Path $PSScriptRoot "dist")
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Server)) {
    throw "Release server is required. Pass -Server or set REFORGED_RELEASE_SERVER."
}
if ([string]::IsNullOrWhiteSpace($KeyPath)) {
    throw "SSH key path is required. Pass -KeyPath or set REFORGED_RELEASE_KEY."
}

$manifestPath = Join-Path $DistDir "latest-release.json"
if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw "Missing $manifestPath. Build the public release first."
}
if (-not (Test-Path -LiteralPath $KeyPath)) {
    throw "SSH key not found: $KeyPath"
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$installerPath = Join-Path $DistDir $manifest.installer
if (-not (Test-Path -LiteralPath $installerPath)) {
    throw "Installer named by latest-release.json was not found: $installerPath"
}
if ([string]::IsNullOrWhiteSpace([string]$manifest.release_notes)) {
    throw "latest-release.json does not name a release-notes file."
}
if ([string]::IsNullOrWhiteSpace([string]$manifest.release_notes_sha256)) {
    throw "latest-release.json does not contain a release-notes SHA-256."
}
$notesPath = Join-Path $DistDir ([string]$manifest.release_notes)
if (-not (Test-Path -LiteralPath $notesPath)) {
    throw "Release notes named by latest-release.json were not found: $notesPath"
}

$actualHash = (Get-FileHash -LiteralPath $installerPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualHash -ne ([string]$manifest.sha256).ToLowerInvariant()) {
    throw "Installer SHA-256 does not match latest-release.json. Rebuild before publishing."
}
$actualNotesHash = (Get-FileHash -LiteralPath $notesPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualNotesHash -ne ([string]$manifest.release_notes_sha256).ToLowerInvariant()) {
    throw "Release-notes SHA-256 does not match latest-release.json. Rebuild before publishing."
}

$installerName = [IO.Path]::GetFileName($installerPath)
$notesName = [IO.Path]::GetFileName($notesPath)
$manifestName = "latest-release.json"
$remoteInstaller = "/tmp/$installerName"
$remoteNotes = "/tmp/$notesName"
$remoteManifest = "/tmp/$manifestName"

Write-Host "Publishing Reforged v$($manifest.version) to $Server"
Write-Host "Installer:     $installerName"
Write-Host "SHA-256:       $actualHash"
Write-Host "Change notes:  $notesName"
Write-Host "Notes SHA-256: $actualNotesHash"
Write-Host

# Release payloads are published first. The manifest is published last so launchers
# never discover a release whose installer or change notes are not yet available.
& scp -i $KeyPath $installerPath "${Server}:$remoteInstaller"
if ($LASTEXITCODE -ne 0) { throw "Installer upload failed." }

& ssh -i $KeyPath $Server "sudo install -d -o root -g caddy -m 0755 /var/www/chocolatier-releases && sudo install -o root -g caddy -m 0644 '$remoteInstaller' '/var/www/chocolatier-releases/$installerName' && rm -f '$remoteInstaller'"
if ($LASTEXITCODE -ne 0) { throw "Could not publish installer on the server." }

& scp -i $KeyPath $notesPath "${Server}:$remoteNotes"
if ($LASTEXITCODE -ne 0) { throw "Change-notes upload failed." }

& ssh -i $KeyPath $Server "sudo install -o root -g caddy -m 0644 '$remoteNotes' '/var/www/chocolatier-releases/$notesName' && rm -f '$remoteNotes'"
if ($LASTEXITCODE -ne 0) { throw "Could not publish change notes on the server." }

& scp -i $KeyPath $manifestPath "${Server}:$remoteManifest"
if ($LASTEXITCODE -ne 0) { throw "Manifest upload failed." }

& ssh -i $KeyPath $Server "sudo install -o root -g caddy -m 0644 '$remoteManifest' '/var/www/chocolatier-releases/latest-release.json' && rm -f '$remoteManifest'"
if ($LASTEXITCODE -ne 0) { throw "Could not publish manifest on the server." }

$manifestUrl = "https://scores.chocolatiercommunity.com/releases/latest-release.json"
$installerUrl = "https://scores.chocolatiercommunity.com/releases/$installerName"
$notesUrl = [string]$manifest.release_notes_url
if ([string]::IsNullOrWhiteSpace($notesUrl)) {
    $notesUrl = "https://scores.chocolatiercommunity.com/releases/$notesName"
}

Write-Host
Write-Host "Published successfully. Verifying public URLs..."
$publicManifest = Invoke-RestMethod -Uri $manifestUrl -Headers @{"Cache-Control"="no-cache"}
if ($publicManifest.version -ne $manifest.version) {
    throw "Public manifest version does not match the local build."
}
$head = Invoke-WebRequest -Uri $installerUrl -Method Head
if ($head.StatusCode -ne 200) {
    throw "Installer URL did not return HTTP 200."
}
$notesHead = Invoke-WebRequest -Uri $notesUrl -Method Head
if ($notesHead.StatusCode -ne 200) {
    throw "Change-notes URL did not return HTTP 200."
}

Write-Host "Manifest:     $manifestUrl"
Write-Host "Installer:    $installerUrl"
Write-Host "Change notes: $notesUrl"
Write-Host "Reforged v$($manifest.version) is published."
