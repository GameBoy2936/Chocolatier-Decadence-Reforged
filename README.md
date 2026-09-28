# Chocolatier: Decadence by Design Reforged

**Version 2.0.1**  
Created by **Michael Lane**

---

## So, what is Reforged?

*Chocolatier: Decadence by Design Reforged* is my huge overhaul of the original game. It started out as a fairly simple project to restore cut content and fix things that always bothered me, and then, well... it got a bit out of hand.

At this point Reforged changes a huge amount of *Decadence by Design*. There are new ingredients, characters, quests, economy systems, a much bigger and better Secret Test Kitchen, Free Play, a full Catalogue, language support, living characters that move around the world, Community accounts and online services, cloud saves, Company Scores, shared creations, and a whole pile of smaller fixes and additions that have accumulated over time.

I am still very deliberately keeping this recognisable as *Decadence by Design*. I do not want to turn it into a completely different game wearing Chocolatier's skin. The point is to expand it, modernise the parts that need modernising, restore ideas that deserved more room, and make the whole thing feel like the game could have kept growing.

Reforged is free. You still need your own legitimate Windows copy of *Chocolatier: Decadence by Design* to install it.

---

## Requirements and compatibility

Reforged v2 is built for the **original Playground Windows version** of *Chocolatier: Decadence by Design*.

You need:

- a legitimate Windows installation of *Chocolatier: Decadence by Design*;
- the original `chocolatier-decadence.exe`;
- the original `CadiApi.dll`.

Normal single-player play does **not** require an internet connection. Internet access is only needed for optional Reforged Community features such as accounts, cloud saves, the Community Cookbook and Community Scores.

Reforged v2 does not currently target OpenChoc as a supported runtime.

---

## Installing Reforged

Thankfully, installation is no longer the old "rename your assets folder and drag files around manually" process. Just run:

`Chocolatier-Reforged-v2.0.1-Setup.exe`

The installer will ask you to choose your existing *Chocolatier: Decadence by Design* installation folder if it cannot detect it automatically.

On the first install, Reforged preserves the original vanilla `assets` folder as:

`assets_vanilla_backup`

It then installs the Reforged assets, launcher, Community Bridge and the other files it needs.

Once installed, launch the game using `Chocolatier Reforged.exe`. You can also use the Start Menu or desktop shortcut if you chose to create one.

### Please do not delete `assets_vanilla_backup`

That is your preserved vanilla game data. Reforged uses it so the original game can be restored properly if you uninstall the mod later.

---

## Updating Reforged

Updating is intentionally boring. When a newer Reforged installer is released, just download it and run it over your existing Reforged installation. The installer recognises the existing install and updates it in place. You do **not** need to uninstall the previous version first.

Your vanilla backup is preserved, and Reforged replaces its own current files with the newer release. Save data is not intentionally removed as part of an update.

In other words, if you are on v2.0.0 and v2.0.1 comes out, install v2.0.1 normally. That is the update process.

The full release notes are installed alongside the game as `CHANGELOG-Reforged.md`, and the same versioned change-notes file is published beside the installer for each public release.

---

## Save games

### Reforged v1 saves

**Reforged v1 saves are supported by v2.**

V2 includes migration logic for older Reforged progression, ingredients, recipes, Catalogue discoveries, quest and Special Order state, score data, character mobility and other persistent systems that changed between releases.

The old Pepper ingredient used by Reforged v1 is migrated to Cayenne where applicable, including compatible custom-recipe state.

### Vanilla and other modded saves

Vanilla saves and saves created by unrelated mods are **not covered by the same v1-to-v2 migration guarantee**. They may work, but starting a new game is recommended if a save did not originate from Reforged.

This mod changes an enormous amount of the game, so I still recommend keeping a backup of any save you really care about before a major update. The installer itself does not go around deleting your save files.

---

## Free Play

Reforged v2 adds a proper **Free Play Mode** alongside Story Mode.

Free Play has its own persistent game state rather than simply pretending the normal campaign has no quests. It is designed for people who want to build a company, experiment with the economy, expand factories, create products and chase scores without replaying the story every time.

Among other things:

- Free Play keeps its own save state separate from Story Mode;
- Story progression can unlock applicable content into Free Play without Free Play rewriting your Story campaign;
- Free Play has its own custom Creations rather than consuming Story Mode's Creation slots;
- Free Play Creation capacity is effectively unrestricted;
- starting cash scales by difficulty;
- Zurich begins as your starting production base, including a Bar Recycler;
- additional factories around the world can be purchased directly;
- the pause menu includes a **Restart** option for starting the run again cleanly;
- Free Play participates in the Company Score system.

### Shops and Special Orders

Shops work differently from Story Mode.

You do **not** own shops in Free Play. That means Story Mode shop ownership cannot become a shortcut or permanent pricing advantage in the sandbox.

Instead, every active shop in an accessible port can act as an independent source of Special Orders. That gives shopkeepers around the world a reason to matter even when their shop is not ownable in Story Mode, and it lets their character-specific order dialogue actually appear during play.

Free Play keeps the number of pending Special Orders under control globally, while each shop also keeps its own cooldown and order chance.

---

## The Reforged Community

Reforged has its own optional online Community services built into the game.

From the Community menu you can:

- create and sign into a Reforged Community account;
- view Community Scores;
- inspect detailed company snapshots attached to submitted scores;
- upload Secret Test Kitchen creations to the Community Cookbook;
- browse, load, rate and remix creations shared by other players;
- create and manage cloud saves;
- view public player profiles;
- choose profile favourites such as characters, ports, ingredients and products;
- see Community statistics and presence information.

The production service is hosted at `scores.chocolatiercommunity.com`.

Community features are optional. If the local Community Bridge cannot start, or the service itself is unavailable, Reforged can still launch and ordinary offline play remains available.

The backend is being built with the wider Chocolatier series in mind rather than hard-wiring the project forever to one game. *Decadence by Design* is simply the first title actively using it.

---

## Company Score

The old cash-per-week high-score idea has been replaced by a much broader **Company Score**.

Company Score can take into account things such as:

- company value;
- production and sales;
- factories and shops;
- ports visited;
- recipe mastery and medals;
- career rank;
- earnings pace;
- difficulty.

Reforged also keeps persistent campaign statistics and personal-best history so a run can be understood as more than one final money number.

Developer-mode campaigns are intentionally treated as unranked.

Older legacy submissions remain separate from current-formula Company Scores rather than being compared as if they were produced by the same scoring system.

---

## Major Reforged features

### The Catalogue

The Catalogue is a full in-game reference system covering:

- characters;
- ingredients;
- ports;
- history.

Entries unlock as you play instead of simply dumping everything on you from the beginning.

The History section has grown into a proper archive of documents, letters, journals, correspondence, eyewitness accounts and other material tied to the Baumeisters and the wider Chocolatier world. Some entries also use recreated document artwork rather than existing only as plain text.

The Catalogue has gradually become one of the main pieces holding Reforged together because so much of the game's expanded world, character information and ingredient data now has somewhere sensible to live.

### A more alive world

Characters are no longer treated as if they are permanently nailed to one building.

Reforged has a mobility system that allows supported characters to travel, settle temporarily in appropriate locations, and be encountered in places that make sense for them. Home-port locals can move around their own city without suddenly appearing on the other side of the world.

Quest and Special Order handling has been adjusted around that rather than quietly assuming everybody is always standing in their original vanilla spot.

There are also many new and reworked character profiles, conversations, quest appearances and bits of worldbuilding throughout the game.

### Economy, events and difficulty

Reforged adds **Easy, Medium and Hard** difficulty modes and gives the economy much more room to move.

Regional and global events, market tips, ingredient seasons and other systems can influence prices and availability. Difficulty also matters to Company Score rather than existing only as a label on the campaign.

### Quests and Special Orders

A lot of quest and order logic has been rebuilt or expanded.

Special Orders are much less detached from the world now. Characters can preserve the place where you actually met them, order text can use live character, item, timing and location information, and Special Order characters can return correctly after an order completes or fails.

Existing story material has also been adjusted in quite a few places, and Reforged adds new character interactions and optional story material of its own.

### Secret Test Kitchen 2.0

The Secret Test Kitchen has had one of the biggest rebuilds in the entire project.

Reforged now supports:

- custom recipes using **2 to 6 ingredients**;
- a much broader ingredient library;
- Tea and Liqueurs ingredient drawers;
- scrollable drawer navigation without crushing the original drawer artwork;
- expanded product art and tint options;
- a dedicated powder appearance layer for Beverage Blends;
- longer recipe names and descriptions;
- far more detailed Teddy Baumeister tasting feedback;
- recipe repair and revision;
- Recipe Book pagination for larger libraries;
- Community Cookbook imports and uploads;
- ownership, source and remix provenance for shared creations.

Teddy's feedback has also been expanded heavily. He can react to ingredient overuse, ingredient families, structural recipe problems, dietary conflicts, particular combinations and a much larger range of specific pairings.

The goal is to make creating something in the Test Kitchen feel like an actual part of the game rather than a fun little side screen you exhaust quickly.

### Ingredients and food data

Reforged v2 contains **100 ingredients**, up from 80 in Reforged v1.

That is 40 more ingredient slots than the original game.

The expanded ingredient data can also represent more than a simple name and price. Reforged can track things such as origin, recipe-family behaviour, seasonal information, alcohol content and kitchen classification.

Character dietary requirements can also be represented more directly, including things such as alcohol-free, halal, kosher, lactose-free and no-beef requirements, instead of trying to squeeze everything into ordinary likes and dislikes.

Some existing recipes have been adjusted where the expanded ingredient set gave me a better option than vanilla had available.

### Characters and artwork

Reforged adds new characters and also revisits a lot of the existing cast.

The art side of the project has increasingly moved toward proper HD remastering rather than simple upscaling. Character portraits, facial-expression sheets, silhouettes, ingredient artwork, interface graphics and other assets have been restored, redrawn, remastered or rebuilt where needed.

The aim is still to fit *Decadence by Design's* own presentation rather than making the interface look like unrelated art has been pasted over it.

### Language support

Reforged includes a much broader localization framework, an in-game language selector and expanded font support.

**English is the canonical and most complete language.** Translation coverage varies significantly, and incomplete languages may fall back to English for newer Reforged text.

The old Playground engine also has hard technical limits around some writing systems. Right-to-left scripts such as Hebrew and Arabic are particularly difficult, and South Asian scripts have shaping requirements that the original engine was never designed to handle properly.

Translation help is very welcome.

---

## For modders

A large amount of Reforged's game logic remains available as readable Lua rather than being packed away into some deliberately inaccessible format.

If you want to poke around, learn how something works, make your own expansion or simply break the game in spectacular ways, go for it.

### Developer tools

Reforged includes in-game development and debugging tools.

To enable them, open:

`assets/settings.xml`

and change:

```xml
<cheatmode>0</cheatmode>
```

to:

```xml
<cheatmode>1</cheatmode>
```

This exposes tools for things such as:

- quest state;
- Special Orders and economic events;
- inventory and item spawning;
- port and building state;
- teleporting;
- progression;
- runtime diagnostics and logging.

Cheat mode is intended for testing and modding. Developer-mode campaigns are not eligible for normal ranked Company Score treatment.

### Source-side tools

The source project keeps non-runtime utilities under:

`development/`

This includes font conversion, localization injection, CADI extraction, artwork sources, prototypes and test tooling.

Those files are deliberately kept outside the runtime `assets/` tree so they cannot accidentally become part of normal game data.

The runtime Lua code also follows a shared Reforged layout and logging standard, documented in:

`development/CODE_STYLE.md`

---

## Release components

If you are reporting a technical problem with this release, these are the component versions to include:

- **Reforged:** 2.0.1
- **Community Services:** 1.1.2
- **Community Bridge:** 0.2.13

Community Services 1.1.2 includes the current Community creation appearance allowlist used by this client.

---

## Uninstalling

Use the normal Windows uninstall entry for:

**Chocolatier: Decadence by Design Reforged**

The Reforged installer removes the files it installed and restores the preserved vanilla `assets` folder from `assets_vanilla_backup` where possible.

Your original game executable and `CadiApi.dll` are not bundled as Reforged files and are not replaced by the installer.

---

## Permissions and credits

### Original game

*Chocolatier: Decadence by Design* was created by Big Splash Games and published by PlayFirst.

Reforged uses and modifies material from the original game, and I obviously do not claim ownership of PlayFirst or Big Splash Games' original assets, characters, code or trademarks.

Reforged is an unofficial, non-commercial fan project.

### Community use

You are welcome to look through my changes, learn from them and make your own modifications or expansions.

If you publicly release something substantially based on Reforged, please credit **Michael Lane / GameBoy2936** for the Reforged work you used and clearly distinguish your version from the official Reforged release.

Please preserve appropriate attribution to the original developers and rights holders.

Please keep derivative Reforged work freely accessible. Do not sell this mod, put it behind a paywall, or package my work into something commercial.

And yes, if you modify the Lua, please leave it readable. There is really no reason to re-encrypt it and make everybody's life harder. I care for this community! I would love it if you can do so too in return.

---

## A genuine thank you

This project has become much bigger than I ever expected it to be.

The Chocolatier games are old, charming little things that could very easily have just disappeared into the pile of forgotten late-2000s PC games. The fact that people still play them, talk about them, preserve them, make guides, dig through their files and generally care enough to keep the series alive is the reason I have been able to justify spending this much time on Reforged in the first place.

So, genuinely, thank you to everybody in the Chocolatier community who is still here. And to those of us who want to make the bold revival of the whole series happen one day and turn heads back to this franchise, thank you.

I hope Reforged gives you a great excuse to play *Decadence by Design* and the other *Chocolatier* games again.

---

## Links

**Chocolatier Wiki**  
https://the-chocolatier-series.fandom.com/

**Discord**  
https://discord.gg/ef3TPaVsmq

**Ko-fi**  
https://ko-fi.com/gameboy2936

Reforged is free. If you want to support the work I am doing to preserve and expand the Chocolatier series, the Ko-fi is there and is a great help with Community server costs, but there is absolutely no requirement to do so.

---

*Chocolatier: Decadence by Design Reforged is a fan-made modification and is not an official PlayFirst release.*
