# Reforged Lua style

This project keeps the original Playground Lua dialect, but Reforged-owned and
modified scripts follow one consistent presentation and logging style.

## File layout

Runtime Lua files begin with the Reforged block header, followed by a blank line.
Large files use labelled ruler sections for major systems and ordinary blank lines
for local grouping. Indentation uses tabs; trailing whitespace and semicolon line
endings are avoided.

```lua
--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (System Name)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Reforged modifications (c) 2026 Michael Lane.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Section Name
-------------------------------------------------------------------------------
```

New Reforged-only files can omit the Big Splash copyright line when they contain
no original-game code.

## Comments

Comments explain intent, constraints or non-obvious engine behaviour. They use a
space after `--` and normal sentence case. Do not leave TODOs, disabled alternate
code, temporary test placements, chat/instruction fragments, AI attribution, or
release-stage notes in runtime scripts. Keep historical prototypes and source
references under `development/` instead.

Persistent identifiers such as quest names and save keys are not renamed merely
for style, because doing so can break existing saves.

## Debug logging

`DebugOut` is Reforged's single Lua logging entry point:

```lua
DebugOut("QUEST", "Queued Special Order.")
DebugOut("SAVE", "Loaded profile.", { profile = playerName })
```

Use one of the canonical categories in `assets/ui/debug.lua`. Messages use
sentence case and should describe the event without shouting or embedding their
own pseudo-category prefix. Structured details belong in the optional payload
rather than being serialized into a large diagnostic sentence when practical.

Routine logging is retained only in developer mode. `WARNING` and `ERROR` remain
visible through the native engine logger in normal builds so faults can still be
diagnosed. The in-game debug log is bounded to prevent unbounded save-session
memory growth.

## Development-only material

Player runtime files belong under `assets/`. Source artwork, converters, injection
scripts, standalone test harnesses and unfinished prototypes belong under
`development/`. Generated installer/build output belongs under `deployment/dist`
or `deployment/generated` only while a release is being built.
