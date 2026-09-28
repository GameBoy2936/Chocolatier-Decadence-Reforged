# Reforged Public Code Signing

Reforged v2.0.1 requires the public Windows release artifacts to be Authenticode-signed.

This was added after an unsigned `ReforgedCommunityBridge.exe` was blocked by Windows Smart App Control on a player's machine. Do not work around that class of report by asking players to disable Windows security. The public release should establish trust at build time instead.

## Required setup

Install a trusted **RSA** Windows code-signing certificate from a certificate authority in Microsoft's Trusted Root Program in the certificate store on the release-build PC. Smart App Control does not currently accept ECC code-signing signatures. Keep private keys and certificate passwords out of the repository.

Set:

```bat
set REFORGED_SIGN_CERT_THUMBPRINT=<certificate SHA-1 thumbprint>
```

The signing helper uses the current-user certificate store by default. If the certificate is installed in the local-machine store, also set:

```bat
set REFORGED_SIGN_MACHINE_STORE=1
```

The RFC 3161 timestamp service defaults to:

```text
http://timestamp.digicert.com
```

To use another trusted timestamp service:

```bat
set REFORGED_SIGN_TIMESTAMP_URL=<timestamp URL>
```

The Windows SDK `signtool.exe` must be available on `PATH`.

## Public release behavior

`deployment/build-public-release.bat` sets:

```bat
REFORGED_REQUIRE_SIGNING=1
```

and therefore refuses to produce a public release if signing is not configured or if signature verification fails.

The release pipeline signs and verifies:

1. `community_bridge/ReforgedCommunityBridge.exe`
2. `deployment/bin/Chocolatier Reforged.exe`
3. the Inno Setup installer
4. the Inno-generated uninstaller

Inno Setup performs the installer/uninstaller signing through its configured `SignTool` hook. The installer hash is calculated only **after** the signed installer has been produced.

Development builds may leave `REFORGED_REQUIRE_SIGNING` unset. In that case the shared signing helper reports that signing was skipped instead of failing the build.

## Verification

The helper performs both:

```bat
signtool verify /pa /v <file>
```

and a PowerShell `Get-AuthenticodeSignature` check. A public build stops unless the signature status is `Valid`.

Before publication, manually inspect the final installer and both executables in Windows Properties > Digital Signatures as an additional sanity check.
