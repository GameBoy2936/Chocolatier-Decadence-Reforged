# Reforged launcher update checking

The v2 launcher performs one short best-effort HTTPS check at startup:

`https://scores.chocolatiercommunity.com/releases/latest-release.json`

If the manifest contains a semantic version newer than the installed `CLIENT_VERSION.txt`, the launcher offers the player three choices when a release-notes URL is present:

- **Yes** — open the installer download;
- **No** — open the published change notes;
- **Cancel** — continue without updating.

Older manifests without `release_notes_url` retain the original Yes/No installer prompt. The game still launches normally either way.

Update checks deliberately fail silently if the player is offline, DNS is unavailable, the manifest cannot be fetched, or the manifest is malformed. They do not gate ordinary play or Community Bridge startup.

The launcher does **not** silently install software. It opens the HTTPS `download_url` supplied by the release manifest, and the player runs the normal signed/packaged Reforged Setup when convenient. The existing installer performs the in-place update.

For local launcher testing without contacting the update manifest, launch:

`Chocolatier Reforged.exe --no-update-check`

## Publishing a release

`build-public-release.bat` generates the installer, a versioned Markdown change-notes file and `dist\latest-release.json`. The manifest includes filenames, HTTPS URLs and SHA-256 hashes for both public payloads.

After release hosting has been enabled on the production server, publish from PowerShell with:

```powershell
.\publish-release.ps1
```

The publisher verifies both local hashes, uploads the installer and change notes first, publishes `latest-release.json` last, then verifies all public URLs. Publishing the manifest last prevents existing clients from discovering an update before the complete release is available.
