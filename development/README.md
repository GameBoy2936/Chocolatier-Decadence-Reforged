# Reforged development sources

This directory contains source-only material that is useful while maintaining Reforged but is not part of the player runtime and is not included by the public installer.

- `tools/` — CADI extraction, localization injection and font-conversion utilities.
- `tests/` — standalone development/test harnesses.
- `artwork/` — layered artwork sources and superseded visual references retained for editing/history.
- `prototypes/` — inactive concepts that should not be loaded by the game until they are completed and deliberately promoted into `assets/`.
- `CODE_STYLE.md` — the runtime Lua layout, commenting and logging conventions used for release code.

Runtime Lua, XML, images and audio belong under `assets/`. Generated build outputs belong under `deployment/generated` or `deployment/dist` only while a release is being built; those directories should not be treated as source.
