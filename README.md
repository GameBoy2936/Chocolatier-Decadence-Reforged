========================================================================
CHOCOLATIER: DECADENCE BY DESIGN REFORGED
Version 1.0
Release Date: December 25, 2025
Created by: Michael Lane
========================================================================

INTRODUCTION
------------
"Decadence by Design Reforged" is a massive total conversion mod for
the classic business simulation game "Chocolatier: Decadence by Design."
This is the definitive way to experience the Baumeister saga in 2025.

Born from a project to restore cut content, this mod evolved into a 
complete engine overhaul. By decrypting the Playground SDK engine, 
I have implemented features that were previously impossible: a dynamic 
living economy, procedural quest generation, a comprehensive in-game 
encyclopedia, and support for non-Latin languages.

This mod is fully decrypted and open-source. The scripts are provided 
in raw Lua, allowing you to learn from them or modify them further.

------------------------------------------------------------------------
⚠️  WARNING: SAVE GAMES  ⚠️
------------------------------------------------------------------------
This mod fundamentally rewrites the game's save data structure to support 
Difficulty Modes and the Catalogue.

DO NOT LOAD OLD SAVES.
Focus on starting a NEW GAME. Loading a save file from the vanilla game 
will result in corrupted data or logic errors.

------------------------------------------------------------------------
INSTALLATION INSTRUCTIONS
------------------------------------------------------------------------
1. Navigate to your game installation folder.
   (e.g., C:\Users\[YOURNAME]\My Games\Chocolatier Decadence by Design)
   (e.g., C:\Program Files (x86)\Chocolatier Decadence by Design)

2. Rename the base game assets folder to assets_backup. The game will
   not load this folder. If you wish to, you can alternatively delete the
   base game assets folder entirely if you don't need it.

3. Open the .zip file you downloaded.
   Drag and drop the "assets" folder into the game directory.
   The game will load this folder in runtime.

4. If asked to overwrite files, click YES.

5. Launch the game!
   If you see the "Reforged" logo on the title screen, it is working.

------------------------------------------------------------------------
KEY FEATURES
------------------------------------------------------------------------

1. THE CATALOGUE (New Feature)
   A comprehensive in-game encyclopedia. As you play, you will unlock 
   entries for Characters, Ingredients, Ports, and History. Learn flavor 
   profiles, track seasonal availability, and discover character lore.

2. DYNAMIC ECONOMY & EVENTS
   - Difficulty Modes: Choose Easy, Medium, or Hard at the start of a 
     new game.
   - Tips System: Random economic events (strikes, bumper crops, fads) 
     will shift prices dynamically.
   - Holidays: Global and regional holidays (Christmas, Ramadan, 
     Valentine's) affect prices and dialogue during specific times of year.

3. OVERHAULED QUESTS & ORDERS
   - Special Orders Rebuilt: Orders are no longer random telegrams. 
     You can visit shops to review orders early in person, or even catch
	 the recipient face-to-face to accept it while you are there.
	 Each shop has its own order generation timer.
   - New Story Beats: New quests and storylines have been added, including
     a new trust-building arc with Kowaki in Uluru, a more meaningful
	 storyline of Sean Fletcher involving various characters
	 not used in the base game, and various changes to existing ones.
   - Smart Dialogue: Characters now use context-aware dialogue algorithms 
     to comment on your actions, your current quests, or certain events.

4. EXPANDED CONTENT
   - 20 New Ingredients: Apples, Bananas, Blackberries, Brandy, Chestnuts,
     Figs, Hibiscus Petals, Lavender, Lychees, Matcha, Passionfruit,
	 Pineapples, Pomegranate, Raisins, Rum, Star Anise, Sumac, Toffee,
	 Turmeric, and Walnuts. A few base game recipes have been altered
	 to involve some of these ingredients.
   - 4 New Characters: Elena Tangye, Douglas McInnes,
     Patrick Ratsimbazafy (Mahajanga in a future release if we get art comms?),
	 Halla Þorvaldsdóttir, and Bjarki Eiríksson.
   - HD Art: Base game ingredients have been AI-upscaled for clarity.
   - Product categories now support multiple pages of recipes and product
     lines, which allows for further modding going forward.

5. SECRET TEST KITCHEN 2.0
   - No character limit on recipe descriptions.
   - Recipe slots are now dynamic: Create recipes with 2 to 6 ingredients.
   - Expanded color palette for product tinting.
   - Granular feedback system: Teddy Baumeister now gives specific, multi-part 
     advice on your creations.

6. LOCALIZATION SUPPORT
   - The game now supports language switching via the Options menu.
     Switching the language requires a game restart.
   - Includes a custom tool (.ttf to .mvec converter) for modders to 
     add their own fonts.
   - English (native language), French, German, Dutch, Italian,
     Spanish (European), Spanish (Latin American), Portuguese (European),
	 Portuguese (Brazilian), Catalan, Maltese, Polish, Czech, Hungarian,
	 Romanian, Croatian, Serbian, Bulgarian, Danish, Icelandic, Norwegian,
	 Swedish, Finnish, Russian, Ukrainian, Greek, Turkish,
	 Chinese (Simplified), Chinese (Traditional), Korean, Japanese,
	 Thai, Vietnamese, Indonesian, Malay and Filipino will be supported.
	 
	 Any translation efforts would be greatly appreciated. The Playground SDK
	 is incompatible with displaying fonts such as Arabic right-to-left
	 instead of left-to-right.

------------------------------------------------------------------------
FOR MODDERS: DEVELOPER TOOLS
------------------------------------------------------------------------
This mod includes a full in-game Integrated Development Environment (IDE).

To access the Dev Tools:
1. Open "assets/settings.xml".
2. Change <cheatmode>0</cheatmode> to <cheatmode>1</cheatmode>.
3. In-game, a toolbar will appear at the top of the screen.

Dev Features:
- Quest Inspector: View active quest states and force-complete objectives.
- Special Order and Tip Generators: Create your own custom special
  orders and events.
- Inventory Spawner: Add any item or ingredient instantly.
- World State: Unlock all ports, own all buildings, teleport instantly.
- External Saving: Save your game and export your player table to a new file via
  C:\Users\[YOURNAME]\AppData\Roaming\PlayFirst\chocolatier-decadence-design.
- Console: View the debug log in real-time.

Font Tool:
Located in "assets/fonts/tools/", you will find "ttf_to_mvec.py".
(Requires Python 3.x installed).
This Python script allows you to convert standard .ttf fonts into the 
game's proprietary .mvec vector font format.

------------------------------------------------------------------------
PERMISSIONS & CREDITS
------------------------------------------------------------------------
1. OWNERSHIP
   Portions of this mod utilize assets and code originally created by 
   Big Splash Games/PlayFirst. I do not claim ownership of these original 
   assets. This mod is a derivative work intended for community use.

2. COMMUNITY USE
   You are free to view, edit, and learn from my code changes. You may 
   create your own versions, patches, or expansions based on this mod.

3. DISTRIBUTION
   If you release a modified version of this mod, you must:
   - Keep the source files open (do not re-encrypt them).
   - Credit Michael Lane for the original rebalancing and catalogue systems.
   - Link back to the original mod page.

4. NON-COMMERCIAL
   You may NOT sell this mod, put it behind a paywall, or use it for 
   any commercial purpose. This mod must remain free for the community.

I give a genuine, heartfelt thanks to everybody in the Chocolatier gaming community
that keeps this cherished game series alive every day.

------------------------------------------------------------------------

Wiki & Documentation:
https://the-chocolatier-series.fandom.com/

Official Discord:
https://discord.gg/ef3TPaVsmq

This mod is free. If you'd like to support my work on preserving and 
expanding the Chocolatier series, you can buy me a coffee here:
https://ko-fi.com/gameboy2936