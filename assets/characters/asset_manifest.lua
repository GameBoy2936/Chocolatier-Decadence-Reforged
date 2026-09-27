--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Character Asset Manifest)
	Copyright (c) 2025-2026 Michael Lane.
--]]---------------------------------------------------------------------------

-- This file acts as the visual configuration dictionary for the UI engine.
-- It tells the game which art assets exist for each character, their exact
-- pixel dimensions, and the precise X/Y offsets required to center them properly
-- in dialogues, catalogues, and menus.

CharacterAssetManifest = {
	-- ------------------------------------------------------------------------
	-- Main Characters (Baumeister / Tangye Clan)
	-- ------------------------------------------------------------------------
	main_alex = { png = true, mask = false, silhouette = true },
	main_chas = { png = true, mask = false, silhouette = true },
	main_deit = { png = true, mask = false, silhouette = true },
	main_elen = { png = true, mask = false, silhouette = true },
	main_evan = { png = true, mask = false, silhouette = true },
	main_feli = { png = true, mask = false, silhouette = true },
	main_jose = { png = true, mask = false, silhouette = true },
	main_loud = { png = true, mask = false, silhouette = true },
	main_sara = { png = true, mask = false, silhouette = true },
	main_sean = { png = true, mask = false, silhouette = true },
	main_tedd = { png = true, mask = false, silhouette = true },
	main_whit = { png = true, mask = false, silhouette = true },
	main_zach = { png = true, mask = false, silhouette = true },

	-- ------------------------------------------------------------------------
	-- Antagonists
	-- ------------------------------------------------------------------------
	evil_bian = { png = true, mask = false, silhouette = true },
	evil_kath = { png = true, mask = false, silhouette = true },
	evil_wolf = { png = true, mask = false, silhouette = true },
	evil_tyso = { png = true, mask = false, silhouette = true },

	-- ------------------------------------------------------------------------
	-- Primary Building Caretakers (Shopkeepers, Farmers)
	-- ------------------------------------------------------------------------
	bag_marketkeep     = { png = true, mask = false, silhouette = true },
	bag_shopkeep       = { png = true, mask = false, silhouette = true },
	bag_towerkeep      = { png = true, mask = false, silhouette = true },
	bal_marketkeep     = { png = true, mask = false, silhouette = true },
	bal_shopkeep       = { png = true, mask = false, silhouette = true },
	bal_xxxkeep        = { png = true, mask = false, silhouette = true },
	bel_hutkeep        = { png = true, mask = false, silhouette = true },
	bog_marketkeep     = { png = true, mask = false, silhouette = true },
	bog_plantationkeep = { png = true, mask = false, silhouette = true },
	bog_shopkeep       = { png = true, mask = false, silhouette = true },
	cap_marketkeep     = { png = true, mask = false, silhouette = true },
	cap_shopkeep       = { png = true, mask = false, silhouette = true },
	dou_marketkeep     = { png = true, mask = false, silhouette = true },
	dou_plantationkeep = { png = true, mask = false, silhouette = true },
	dou_shopkeep       = { png = true, mask = false, silhouette = true },
	hav_marketkeep     = { png = true, mask = false, silhouette = true },
	hav_plantationkeep = { png = true, mask = false, silhouette = true },
	hav_shopkeep       = { png = true, mask = false, silhouette = true },
	kon_hutkeep        = { png = true, mask = false, silhouette = true },
	kon_marketkeep     = { png = true, mask = false, silhouette = true },
	kon_plantationkeep = { png = true, mask = false, silhouette = true },
	kon_shopkeep       = { png = true, mask = false, silhouette = true },
	lim_marketkeep     = { png = true, mask = false, silhouette = true },
	lim_shopkeep       = { png = true, mask = false, silhouette = true },
	mah_shopkeep       = { png = true, mask = false },
	rey_marketkeep     = { png = true, mask = false, silhouette = true },
	rey_shopkeep       = { png = true, mask = false, silhouette = true },
	san_marketkeep     = { png = true, mask = false, silhouette = true },
	san_shopkeep       = { png = true, mask = false, silhouette = true },
	tok_marketkeep     = { png = true, mask = false, silhouette = true },
	tok_shopkeep       = { png = true, mask = false, silhouette = true },
	tor_factorykeep    = { png = true, mask = false, silhouette = true },
	tor_marketkeep     = { png = true, mask = false, silhouette = true },
	tor_shopkeep       = { png = true, mask = false, silhouette = true },
	trav_13            = { png = true, mask = false, silhouette = true },
	trav_16            = { png = true, mask = false, silhouette = true },
	trav_21            = { png = true, mask = false, silhouette = true },
	ulu_hutkeep        = { png = true, mask = false, silhouette = true },
	wel_marketkeep     = { png = true, mask = false, silhouette = true },
	wel_shopkeep       = { png = true, mask = false, silhouette = true },
	zur_factorykeep    = { png = true, mask = false, silhouette = true },
	zur_marketkeep     = { png = true, mask = false, silhouette = true },
	zur_shopkeep       = { png = true, mask = false, silhouette = true },

	-- ------------------------------------------------------------------------
	-- Unmasked Characters (No custom silhouettes required)
	-- ------------------------------------------------------------------------
	announcer          = { png = true, mask = false },
	bag_bldg2keep      = { png = true, mask = false },
	bog_churchkeep     = { png = true, mask = false },
	bog_mountainkeep   = { png = true, mask = false },
	cap_mountainkeep   = { png = true, mask = false },
	dou_bldg1keep      = { png = true, mask = false },
	fal_xxxkeep        = { png = true, mask = false },
	gob_xxxkeep        = { png = true, mask = false },
	hav_casinokeep     = { png = true, mask = false },
	hav_hotelkeep      = { png = true, mask = false },
	kon_bldg2keep      = { png = true, mask = false },
	las_casinokeep     = { png = true, mask = false },
	las_marketkeep     = { png = true, mask = false },
	lim_churchkeep     = { png = true, mask = false },
	lim_plazakeep      = { png = true, mask = false },
	rey_xxxxkeep       = { png = true, mask = false },
	san_barkeep        = { png = true, mask = false },
	tan_hotelkeep      = { png = true, mask = false },
	tan_marketkeep     = { png = true, mask = false },
	tan_portkeep       = { png = true, mask = false },
	tok_mountainkeep   = { png = true, mask = false },
	tok_palacekeep     = { png = true, mask = false },
	tok_stationkeep    = { png = true, mask = false },
	tok_towerkeep      = { png = true, mask = false },
	tor_bldg1keep      = { png = true, mask = false },
	tor_bldg2keep      = { png = true, mask = false },
	trav_01            = { png = true, mask = false },
	trav_02            = { png = true, mask = false },
	trav_03            = { png = true, mask = false },
	trav_04            = { png = true, mask = false },
	trav_05            = { png = true, mask = false },
	trav_06            = { png = true, mask = false },
	trav_07            = { png = true, mask = false },
	trav_08            = { png = true, mask = false },
	trav_09            = { png = true, mask = false },
	trav_10            = { png = true, mask = false },
	trav_11            = { png = true, mask = false },
	ulu_rockkeep       = { png = true, mask = false },
	wel_bldg1keep      = { png = true, mask = false },
	zur_bankkeep       = { png = true, mask = false },
	zur_mountainkeep   = { png = true, mask = false },
	zur_riverkeep      = { png = true, mask = false },
	zur_schoolkeep     = { png = true, mask = false },
	zur_stationkeep    = { png = true, mask = false },
	zur_towerkeep      = { png = true, mask = false },
}
