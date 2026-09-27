# Building the Reforged Community native bridge — v0.2.12

The Community bridge is a small native Windows helper used by the original Playground engine to reach Reforged Community services. Public releases ship the compiled `ReforgedCommunityBridge.exe`; players do not need Visual Studio, Python, a command prompt, or any build step.

The source build remains in the project tree for release engineering and preservation. The bridge is CRT-free and links only Windows system libraries:

- `kernel32.lib`
- `wininet.lib`
- `shell32.lib` for allowlisted external links

Version 0.2.12 adds authenticated profile presence on top of the anonymous Community heartbeat. When a valid Community Account session is available, the bridge sends that session only to the allowlisted presence endpoint so profiles can show online/offline and retain a last-played time. Anonymous players still count toward the aggregate online total. The bridge does not expose arbitrary command execution or arbitrary URL handling.

## Build

From a normal Command Prompt on the release-build PC, run:

```text
community_bridge\build-native-bridge.bat
```

The script locates Visual Studio / Build Tools using `vswhere.exe`, initializes the x64 compiler and links the bridge. Temporary object files are removed when the build finishes.

`bridge_status.txt` is generated at runtime and should not be kept in the clean source tree. The public installer packages only the compiled bridge, `bridge_version.txt`, and the generated production `server.txt`.
