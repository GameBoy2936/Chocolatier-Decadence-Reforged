Chocolatier Reforged v2 - Public Launcher / Installer Layer
==========================================================

Player workflow
---------------
1. Install Reforged into an existing Chocolatier: Decadence by Design folder.
2. Create a desktop shortcut if desired (enabled by default).
3. Launch "Chocolatier Reforged".

No command prompt, compiler, Python runtime, or manual bridge startup is required.

Launcher behavior
-----------------
Chocolatier Reforged.exe:
- prevents duplicate launcher sessions;
- cleans up a stale Community bridge left by a crash;
- starts ReforgedCommunityBridge.exe invisibly;
- waits briefly for bridge startup status;
- launches chocolatier-decadence.exe from the correct working directory;
- stays alive while the game is running;
- requests graceful bridge shutdown when the game exits;
- forcibly cleans up the bridge if graceful shutdown fails.

If the Community helper cannot start, the launcher warns the player but still opens
Chocolatier. Community features are unavailable for that session; offline gameplay remains
available.

Public-release rule
-------------------
Players never build the bridge or launcher. The release-build PC compiles them once and
Inno Setup packages the resulting binaries. Visual Studio Build Tools and Inno Setup are
release-engineering dependencies only.

Build
-----
Run:

  deployment\build-public-release.bat

Required on the release-build PC:
- Microsoft Visual Studio / Build Tools with Desktop development with C++
- Inno Setup 6 or 7

The build script:
- rejects release-critical files that still point at the staging Community host;
- rejects known development debris inside the runtime assets tree;
- builds Community bridge v0.2.12;
- builds the static-CRT GUI launcher;
- writes production server configuration and release metadata;
- compiles the installer into deployment\dist;
- stages the versioned public change notes beside the installer;
- calculates installer/change-notes SHA-256 hashes and writes latest-release.json.

Installer behavior
------------------
The installer requires an existing legitimate game folder containing:
- chocolatier-decadence.exe
- CadiApi.dll

On first install, the original assets folder is renamed to assets_vanilla_backup.
On later Reforged upgrades, only the Reforged assets folder is replaced.
On uninstall, the original vanilla assets folder is restored.

The installed game folder also receives:
- README-Reforged.md
- CHANGELOG-Reforged.md

Shortcuts point only to Chocolatier Reforged.exe and use the original game executable as
the shortcut icon source.

Publishing
----------
Publish the installer and versioned change notes before latest-release.json. Publishing the
manifest last prevents an existing client from discovering an update before all release payloads
are available.
