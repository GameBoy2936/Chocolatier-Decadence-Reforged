# Chocolatier: Decadence by Design Reforged — v2.0.3 Change Notes

Reforged v2.0.3 is a focused Community launcher hotfix for a process-handoff issue discovered on some Steam installations.

## Highlights

- Fixed the Reforged Community Bridge shutting down while *Chocolatier: Decadence by Design* was still running on affected Steam systems.
- The launcher now follows a replacement `chocolatier-decadence.exe` process when the initially launched game process hands off or relaunches.
- Community Accounts, the Community Cookbook, Cloud Saves and Community Scores now remain available for the full game session in this case.

## Community & Launcher

- Previously, `Chocolatier Reforged.exe` treated the process handle returned by its initial `CreateProcessW` call as the entire game session. On affected systems that process could exit after handing execution to another `chocolatier-decadence.exe`, causing the launcher to create `community_bridge\\stop.txt` and shut down `ReforgedCommunityBridge.exe` even though the game remained open.
- The launcher now waits briefly for same-installation replacement game processes after the original process exits.
- Replacement detection matches the full executable path, rather than only the process name, so an unrelated Chocolatier installation does not keep the Community Bridge alive.
- The handoff check is repeated if another same-path replacement occurs before the session genuinely ends.

## Release & Versioning

- Updated Reforged client, launcher, installer and public-release metadata to **2.0.3**.
- Community Services remains **1.1.2** and Community Bridge remains **0.2.12**; this fix is entirely in the Reforged launcher.

---

# Chocolatier: Decadence by Design Reforged — v2.0.2 Change Notes

Reforged v2.0.2 is a focused Community hotfix for Creation sharing. It fixes uploads that could be rejected when player-authored Creation names or descriptions contained legacy Windows text bytes produced by the original game's text controls.

## Highlights

- Fixed Community Creation uploads failing with `Request body must be UTF-8.` for otherwise valid player-created recipes.
- Preserved valid UTF-8 text while safely converting legacy Windows-1252 punctuation and characters before Community submission.
- Added a regression case covering legacy encoded punctuation in Community POST requests.

## Community & Networking

- Hardened `CommunityJSON.Encode` so valid UTF-8 byte sequences pass through unchanged.
- Added Windows-1252 fallback conversion for legacy bytes that are not valid UTF-8, emitting JSON Unicode escapes rather than malformed request data.
- This specifically covers common pasted or typed characters such as smart quotes, en/em dashes, ellipses and non-breaking spaces without requiring players to rename or rewrite their Creations.

## Release & Versioning

- Updated Reforged client, launcher, installer and public-release metadata to **2.0.2**.
- Community Services remains **1.1.2** and Community Bridge remains **0.2.12**; neither component requires a version bump for this client-side fix.

---

# Chocolatier: Decadence by Design Reforged — v2.0.1 Change Notes

Reforged v2.0.1 is the first post-launch hotfix for Reforged v2, focused on Secret Test Kitchen recipe evaluation, localization-safe interface fixes, installer compatibility and several gameplay, quest and dialogue corrections discovered immediately after release.

## Highlights

- Expanded and corrected numerous Secret Test Kitchen ingredient-pairing evaluations.
- Activated several previously dormant Teddy Baumeister critique lines.
- Fixed localization-related clipping in parts of the Community and Help interfaces.
- Fixed a Rank 2 quest completion text error.
- Fixed missing shop haggling dialogue caused by mismatched string IDs.
- Restored the public release configuration to launch with developer/cheat mode disabled.
- Fixed the installer repeatedly rejecting correctly selected Steam installations when browsing to the existing game folder.

## Secret Test Kitchen & Recipe Evaluation

- Expanded Teddy Baumeister's beverage evaluation for **Cayenne + Honey**.
- Added **Cayenne + Lime** feedback for non-coffee beverages.
- Activated the previously unused **Cayenne + Mango** feedback in both confection and beverage evaluations.
- Added standard **Lemon + Honey** feedback for tea and other non-coffee drinks while preserving the separate coffee-specific evaluation.
- Added **Rose + Saffron** evaluation to non-coffee beverages.
- Added the following Black Tea pairings to confection evaluation:
  - Black Tea + Lavender;
  - Black Tea + Jasmine;
  - Black Tea + Cardamom;
  - Black Tea + Ginger;
  - Black Tea + Peach.
- Added **Matcha + Ginger** and **Matcha + Almond** to beverage evaluation.
- Added **Jasmine + Honey** and **Jasmine + Lychee** to confection evaluation.
- Added **Lemongrass + Honey** and **Lemongrass + Mint** to confection evaluation.
- Activated previously dormant negative pairing feedback for:
  - Cayenne + Mint;
  - Lavender + Cinnamon;
  - Rose + Mint;
  - Ginger + Mint.
- Non-coffee Ginger + Mint drinks now use the general Ginger/Mint critique, while coffee-based recipes retain their stronger coffee-specific critique.
- Generalized several Teddy feedback lines so they read naturally in both beverages and confections rather than referring specifically to a cup, sipping or chocolates.
- Applied those shared feedback wording corrections across all **38 current Kitchen string files**.

## Interface & Localization

- Increased the height of the Community Hub's signed-in/signed-out helper text area while keeping it in its original position.
- Changed that helper text to top alignment while retaining its right alignment, giving longer translations room to wrap without moving the Hub's buttons or lower interface sections.
- Reduced the width of Community Cookbook creation-name labels so long Creation names no longer encroach on the separate Ready/Locked status area.
- Reduced body-text size slightly on the Catalogue, Market and Shop Help screens to improve fit for longer text.
- Adjusted the Reforged Help screen's body text and expanded its Community information area to reduce clipping.
- Improved Community Profile picker diagnostics so support logs more clearly identify when favorite-content selectors are queued, opened and closed.

## Quests, Haggling & Dialogue

- Fixed a Rank 2 Uluru quest completion sequence that incorrectly displayed `ugr_02_extra01` twice instead of advancing to `ugr_02_extra02`.
- Corrected four soft shop **push-your-luck** haggling string IDs so they match the IDs generated by the haggling interface and can actually appear in play.
- Polished several Special Order rejection and antagonist dialogue lines.
- Improved formatting and punctuation in selected Special Order outcomes.

## Release Safety & Technical

- Fixed the installer rejecting valid Steam installations after the user selected the correct existing game folder.
- Disabled Inno Setup's automatic default-folder-name appending for the existing-game-folder picker, preventing duplicated paths such as `Chocolatier Decadence by Design\Chocolatier Decadence by Design`.
- Restored the shipped `settings.xml` default to `<cheatmode>0</cheatmode>`.
- Updated public build metadata and README information for Reforged **2.0.1**; Community Services remains **1.1.2** and Community Bridge remains **0.2.12**.

---

# Chocolatier: Decadence by Design Reforged — v2.0.0 Change Notes

Reforged v2.0.0 is the largest update to the project so far, expanding the game across Free Play, online Community features, the Secret Test Kitchen, the Catalogue, world simulation, quests, scoring, localization and general quality of life.

These notes cover the major player-facing changes from the public Reforged v1 release.

## Highlights

- Added a fully separated **Free Play Mode** with its own economy, factories, Creations, saves, Company Scores and Community leaderboard tables.
- Added the **Reforged Community**, including accounts, profiles, Cloud Saves, the Community Cookbook, ratings, shared Creations and Community Scores.
- Replaced the old cash-per-week high-score model with the new **Company Score** system.
- Expanded the ingredient roster from **80 to 100 ingredients**.
- Substantially rebuilt the **Secret Test Kitchen**, including more flexible recipes, new ingredient drawers, richer appearance editing and hundreds of new Teddy feedback cases.
- Rebuilt and greatly expanded the **Catalogue** across Characters, Ingredients, Ports and History.
- Added a persistent **living-character system** allowing travelers and local characters to move through the world naturally.
- Reworked **Special Orders** with multi-item requests, dynamic dialogue, stronger character integration and more varied outcomes.
- Expanded localization support to **38 selectable languages**, with script-aware fonts and English fallback.
- Added extensive save migration and repair support for Reforged v1 campaigns.

## Free Play

- Added Free Play as a full game mode separate from Story Mode.
- Free Play uses its own Reforged-managed save state and cannot overwrite the Story campaign.
- Story progression is synchronized one-way into Free Play for applicable unlocks, recipes, ingredients, ports, medals and Catalogue discoveries.
- Free Play keeps independent money, time, inventory, production, factories, statistics and Creations.
- Added separate **Story Creations** and **Free Play Creations** libraries while playing Free Play.
- Story Creations remain available for production in Free Play without being rewritten.
- Free Play Creations have no gameplay-imposed slot limit and never flow back into Story Mode.
- Starting cash now scales by difficulty:
  - Easy: **$20,000**
  - Medium: **$25,000**
  - Hard: **$30,000**
- Free Play begins in Zürich with the Zürich factory and a Bar Recycler.
- Additional factories can be purchased using Free Play money.
- Added **Restart** to the Free Play pause menu.
- Added Free Play-specific Company Score calculations that exclude inherited Story rank, medals and recipe knowledge.
- Added dedicated Story and Free Play Community leaderboard tables.
- Added separate Story/Free Play Cloud Save handling.
- Shops cannot be owned in Free Play and therefore never grant Story Mode ownership pricing benefits.
- Every eligible shop in an accessible port can generate Special Orders in Free Play.
- Free Play supports up to **three pending Special Orders** at once, with per-shop cooldowns and randomized shop evaluation.

## Reforged Community

- Added Community Account registration, sign-in and persistent sessions.
- Added public Community Profiles with nationality, flag, biography and favorite game content.
- Added online/offline presence and Last Played information.
- Added the **Community Cookbook** for player-created Secret Test Kitchen recipes.
- Added Cookbook search, sorting, category filters and paging.
- Added Creation detail pages with ingredients, appearance, creator information, ratings, tags and provenance.
- Added Creation uploading directly from Reforged.
- Added Creation ratings and load counts.
- Added source/remix attribution for shared Creations.
- Added direct loading of Community Creations into the Secret Test Kitchen.
- Added ownership-aware deletion of the player's own Community Creations.
- Added **Cloud Saves** with sync, restore, import and deletion controls.
- Added Community statistics and service-status information.
- Added account-linked Community Score submission and management.
- Added public-profile links from compatible leaderboard entries.
- Added safe external links to the Reforged Wiki and Discord through the Community Bridge.
- Updated Community compatibility to **Community Services 1.1.2** and **Community Bridge 0.2.12**.

## Company Score & Statistics

- Replaced the old cash-per-week leaderboard score with **Company Score**.
- Company Score now considers company value, production, sales, expansion, mastery, progression, earnings pace and difficulty.
- Added difficulty multipliers for Medium and Hard campaigns.
- Added detailed score breakdown screens.
- Added persistent personal bests and limited score history.
- Added campaign statistics for money earned/spent, sales, production, travel, gambling, quests, Special Orders and major transactions.
- Added score nationality selection and a global flag library.
- Added ranked campaign integrity states.
- New campaigns can participate as ranked runs.
- Older migrated campaigns are marked as legacy/unverified where historical statistics cannot be reconstructed.
- Developer-mode campaigns are marked unranked.
- Story Mode and Free Play scores are ranked separately.

## Secret Test Kitchen & Recipe Book

- Expanded custom recipes to support **2–6 ingredients**, subject to confection-category rules.
- Added category-driven structural recipe requirements instead of relying on one-size-fits-all checks.
- Beverages can now use **3–4 ingredients**.
- Beverage Blends can now use **3–5 ingredients**.
- Added **Tea** and **Liqueurs** ingredient drawers.
- Added horizontal drawer scrolling so the expanded ingredient categories fit without shrinking the original drawer presentation.
- Added a dedicated powder appearance layer for Beverage Blends.
- Reworked beverage rendering with separate mug and rim composition.
- Expanded Bar, Infusion and Truffle decoration options.
- Added Recipe Book pagination for larger recipe libraries.
- Added Community Creation import, repair and re-saving support.
- Added duplicate-recipe protection when importing Community Creations.
- Added provenance tracking for owned, downloaded and remixed Creations.
- Added much more detailed Teddy Baumeister tasting feedback.
- Expanded feedback for ingredient overuse, first use, pairings, bad combinations, ingredient families, ratios, recipe structure, dietary restrictions and specific confection types.
- Added Community-aware Teddy reactions based on ratings, popularity, authorship, ownership and tags.
- Improved feedback selection so useful ingredient feedback is not discarded by later structural checks.
- Expanded validation for recipe definitions and feedback rules.

## Catalogue

- The **History** tab is fully available and active! Expanded into an archive of letters, journals, correspondence, records and other historical documents.
- Added scrollable long-form article layouts.
- Expanded character pages with biographies, identity information, preferences and dietary information.
- Rebuilt ingredient articles into structured sections covering production, flavor, culinary use, strengths, weaknesses and trivia.
- Added ingredient origin, season and discovery information.
- Expanded Port articles with cultural, geographic and gameplay information.
- Added document artwork for selected History entries.
- Added pagination, locked-entry presentation and retroactive unlock restoration for those migrating from v1.
- Added Catalogue discovery backfilling for compatible migrated saves.
- Added broader country, culture, religion, holiday, region and dietary metadata used throughout the Catalogue.

## Ingredients & Recipes

- Expanded the ingredient roster from **80 to 100**.
- Added:
  - Apricot
  - Cayenne
  - Chamomile
  - Cranberry
  - Dragonfruit
  - Earl Grey
  - Guava
  - Ice Cream
  - Jasmine
  - Lemongrass
  - Marshmallow
  - Oat
  - Peach
  - Pear
  - Plum
  - Rhubarb
  - Rooibos
  - Rosemary
  - Tamarind
  - Wafer
  - Yuzu
- Replaced **Pepper** with **Cayenne**, including compatible recipes, progression and port inventories.
- Added ingredient origin data to most ingredients.
- Added alcohol metadata for applicable ingredients.
- Added Test Kitchen category and recipe-family metadata.
- Corrected Chestnut's wraparound seasonal definition.
- Adjusted Strawberry seasonal pricing.

## Living World & Characters

- Added persistent character-location tracking.
- Global travelers can now alternate between travel and multi-week stays around the world. Character destinations can be influenced by venue type and personal affinities. Local characters remain within their home port instead of appearing randomly overseas. Buildings can host permanent residents and multiple visiting characters at the same time. Travel encounters now respect a character's actual current location. Quest and Special Order characters can be temporarily pinned to the correct location and restored afterward.
- Added centralized character identity and preference data.
- Expanded likes and dislikes across substantially more NPCs.
- Added explicit nationality, gender, religion and dietary metadata where applicable.
- Added dietary checks such as alcohol-free, halal, kosher, lactose-free and no-beef requirements.
- Expanded dynamic character grammar, including names, honorifics and pronouns for dialogue substitution.
- Added and refreshed HD portraits, expression sheets and silhouettes for numerous characters.

## Quests & Special Orders

- Added **14 quests** and retired one redundant quest from the v1 quest set.
- Added new optional character/story encounters across the campaign.
- Added additional contextual help prompts and tutorial dialogue.
- Integrated every new v2 ingredient into campaign progression.
- Converted several traveler quests to use the living-character location system instead of hard-coded teleporting.
- Added context-sensitive quest text based on where a character was actually encountered.
- Added richer dynamic text using live characters, locations, products, quantities, payments and deadlines.
- Added **multi-item Special Orders** from Rank 3 onward.
- Added dietary filtering when selecting Special Order recipients/products.
- Added richer recipient reactions for successful, incomplete and failed deliveries.
- Added antagonist Special Order schemes and aftermath dialogue from shop owners.
- Improved Special Order character restoration after completion or failure.
- Fixed several difficulty-specific quest fields that were previously overwritten by generic values.
- Corrected several broken late-game quest references and auto-completion fields.
- Reduced the Hard-mode Sean ransom from **$50,000,000 to $25,000,000**.
- Added save-repair handling for older campaigns with disabled antagonist Special Orders.
- Improved Quest Log sorting and prevented repeatable Special Orders from flooding completed quest history.

## Economy, Events & Difficulty

- Increased the weekly dynamic-tip chance from **20% to 25%**.
- Dynamic tips now last **6–12 weeks** instead of a fixed eight weeks.
- Price increases and decreases now vary in strength rather than using one fixed multiplier.
- Tip selection now considers what is relevant to the player's current economy.
- Added better conflict prevention between overlapping or contradictory market events.
- Fixed antagonist misinformation changing the real market instead of only misleading the player.
- Added richer dynamic event dialogue using ports, regions, products, characters and time remaining.
- Reworked holiday handling around an actual campaign calendar beginning in 1946.
- Added date-aware support for fixed and moving holidays.

## Factories, Markets & Shops

- Added a dedicated **Factory Upgrades** screen.
- Added direct machinery purchases for Bars, Beverages, Infusions, Truffles, Blends and Exotics.
- Added purchasable Recycler upgrades for compatible machinery.
- Recycler prices scale by difficulty:
  - Easy: **$250,000**
  - Medium: **$350,000**
  - Hard: **$500,000**
- Added first-ever, first-at-port and category-specific merchant reactions.
- Added richer haggling dialogue, including push-your-luck reactions after a successful haggle.
- Rebalanced ingredient inventories across **18 ports**, increasing total ingredient placements from **239 to 264** while distributing the expanded roster more deliberately around the world.
- Port inventory changes from Reforged v1:
  - **Baghdad:** Added Apricots and Turmeric.
  - **Bali:** Added Jasmine Petals and Lemongrass; removed Allspice and Star Anise.
  - **Belize:** Added Cacao, Cayenne Peppers, Dragonfruit, Espresso Beans, Guava, Tamarind and Vanilla.
  - **Bogotá:** Added Bananas and Guava.
  - **Cape Town:** Added Butter, Ice Cream, Plums and Rooibos.
  - **Douala:** Added Cayenne Peppers and Tamarind; removed Hazelnuts and Pepper.
  - **Gobi Desert:** Added Black Tea, Peaches, Rhubarb and Star Anise; removed Cloves, Currants, Figs and Sumac.
  - **Havana:** Added Pineapples; removed Cinnamon.
  - **Kona:** Added Hazelnuts; removed Passionfruit.
  - **Las Vegas:** Added Bing Cherries, Ice Cream, Marshmallows and Wafers.
  - **Lima:** Added Cayenne Peppers and Sea Salt; removed Pecans and Pepper.
  - **Reykjavík:** Added Cranberries, Oats and Rhubarb; removed Raspberries.
  - **San Francisco:** Added Pears; removed Mint.
  - **Tangiers:** Added Anise, Apricots, Chamomile and Rosemary; removed Blueberries and Cashews.
  - **Tokyo:** Added Chestnuts, Lychees, Sesame Seeds, Star Anise and Yuzu; removed Cloves, Pumpkins and Strawberries.
  - **Toronto:** Added Oats and Peanuts; removed Chestnuts and Pecans.
  - **Wellington:** Added Earl Grey Tea and Oats; removed Currants and Pumpkins.
  - **Zürich:** Added Blueberries and Hazelnuts; removed Cloves and Walnuts.
- Specialty plantation inventories remain unchanged. The Falkland Islands, Mahajanga and Uluru receive no ingredient-inventory changes.

## Interface & Quality of Life

- Replaced the main-menu High Scores entry with the new **Community** hub.
- Added Community access from the pause menu.
- Rebuilt the high-score browser around Company Score and Community data.
- Added detailed score views, run metadata, flags and integrity information.
- Rebuilt Catalogue detail screens into dedicated article views.
- Added more flexible dialog sizing for longer localized text and response buttons.
- Improved player-profile creation, renaming and deletion behavior.
- Improved name validation and whitespace handling.
- Improved port discovery tracking for Catalogue entries and ingredient sources.
- Improved language-change confirmation and restart messaging.
- Added new Catalogue help and Reforged help.
- Added clearer localization-safe quantity and transaction text.

## Localization

- Rebuilt the language selector into a scrollable **3 × 7** browser.
- Expanded the current selectable language list to **38 languages**. Lithuanian, Latvian and Estonian are now planned for translation.
- Added script-specific font routing for Latin, Cyrillic, Greek, Chinese, Korean, Japanese and Thai.
- Added separate indicators for the currently loaded language and the language selected for the next launch.
- Expanded or refreshed localization files across the v2 string set. All core strings are complete, but dialogue, the catalogue, quests and the Secret Test Kitchen remain in English for native player translation.

## Art

- Expanded the nationality system to a **256-flag** library.
- Added Community rating, score and profile artwork.
- Added substantially more large-format ingredient artwork, currently not in use but would be helpful for the future.
- Refreshed numerous ingredient icons and character portraits.
- Added new and revised Test Kitchen visual layers.
- Reworked beverage mug/rim presentation.

## Save Compatibility & Fixes

- Added **Reforged v1 → v2 save migration**. Migrates applicable ingredient progression, custom recipes, Catalogue state, score state, quest state and character-location data.
- Migrates saved Pepper references to Cayenne where compatible.
- Backfills Catalogue discoveries from owned items, purchases and existing progression.
- Repairs known older progression states where rewards could fail to apply.
- Preserves actual default locked/hidden states for ports missing from older saves.
- Added Free Play sidecar migrations and cleanup for pre-release Free Play builds.
- Added automatic removal of stale Free Play shop ownership from experimental saves.
- Fixed custom-product restoration collisions when rebuilding saved Creations.
- Fixed Community imports that could lose visible first-option art layers.
- Added stronger defensive handling for malformed or missing simulation data.
- Added centralized simulation validation for ingredients, categories, products and Test Kitchen feedback rules.

## Technical & Modding

- Standardized runtime logging behind a single categorized `DebugOut` system.
- Standardized runtime Lua file headers, layout, indentation and comments.
- Moved source-only tools, prototypes, tests and artwork out of the runtime `assets/` tree into `development/`.
- Removed stale test scripts, backups, duplicate files and generated build artifacts from the release tree.
- Added release-build checks that reject development artifacts if they reappear inside runtime assets.
- Added a shared Reforged code-style document for future development.
- Kept Reforged Lua source readable for modding and preservation work.
- Expanded developer tools for quests, Special Orders, events, inventory, ports, simulation state and runtime diagnostics.
- Developer-mode campaigns remain intentionally unranked.
