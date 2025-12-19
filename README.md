# CHOCOLATIER: DECADENCE REFORGED
## Version 0.2 (BETA)
## Created by: Michael Lane

INTRODUCTION
------------
This is a comprehensive overhaul of "Chocolatier: Decadence by Design." 
It is a total conversion that adds new systems, a dynamic economy,
a lore encyclopedia, new characters, ingredients, and full multi-language support.

This mod is fully decrypted and open-source. The scripts are provided 
in raw Lua, allowing you to learn from them or modify them further.

⚠️ IMPORTANT: SAVE GAME WARNING ⚠️
This mod fundamentally changes the game's data structure. 
DO NOT load save files from the original game. You must start a new
game, or your save files may get corrupted or experience side effects.

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
     You can visit shops to request orders in person. Each shop has its 
     own order generation timer.
   - New Story Beats: New quests have been added, including a new 
     trust-building arc with Kowaki in Uluru.
   - Smart Dialogue: Characters now use context-aware dialogue algorithms 
     to comment on the weather, your rank, or active events.

4. EXPANDED CONTENT
   - 17 New Ingredients: Apples, Bananas, Blackberries, Brandy, Figs,
     Lavender, Lychees, Matcha, Passionfruit, Pineapples, Raisins, Rum,
     Star Anise, Sumac, Toffee, Turmeric, and Walnuts.
   - 4 New Characters: Elena Tangye, Douglas McInnes,
     Halla Þorvaldsdóttir, and Bjarki Eiríksson.
   - HD Art: Base game ingredients have been AI-upscaled for clarity.
   - Product categories now support multiple pages of recipes.

5. SECRET TEST KITCHEN 2.0
   - No character limit on recipe descriptions.
   - Add or remove ingredient slots dynamically.
   - Expanded color palette for product tinting.
   - Granular feedback system: Teddy Baumeister now gives specific, multi-part 
     advice on your creations.

6. LOCALIZATION SUPPORT
   - The game now supports language switching via the Options menu.
     Switching the language requires a game restart.
   - Includes a custom tool (.ttf to .mvec converter) for modders to 
     add their own fonts.
   - English (native language), French, German, Dutch, Italian, Spanish, Portuguese, Catalan, Maltese, Polish, Czech, Hungarian, Romanian, Croatian, Serbian, Bulgarian, Danish, Icelandic, Norwegian, Swedish, Finnish, Russian, Ukrainian, Greek, Turkish, Hindi, Bengali, Chinese (Simplified), Chinese (Traditional), Korean, Japanese, Thai, Vietnamese, Indonesian, Malay and Filipino will be supported. Any translation efforts would be greatly appreciated. The Playground SDK is incompatible with displaying fonts such as Arabic right-to-left instead of left-to-right.

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

I give a genuine, heartfelt thanks to everybody in the Chocolatier gaming community that keeps this cherished game series alive every day.

------------------------------------------------------------------------

This mod is free. If you'd like to support my work on preserving and 
expanding the Chocolatier series, you can buy me a coffee here:
https://ko-fi.com/gameboy2936
