--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Traveler Instantiation)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- This script serves as the fundamental creation hook for all characters that 
-- do not physically own/operate a building in a port.

-------------------------------------------------------------------------------
-- 1. Main Cast Initialization
-------------------------------------------------------------------------------

CreateCharacter("main_alex")
CreateCharacter("main_chas")
CreateCharacter("main_deit")
CreateCharacter("main_elen")
CreateCharacter("main_evan")
CreateCharacter("main_feli")
CreateCharacter("main_jose")
CreateCharacter("main_sean")
CreateCharacter("main_tedd")
CreateCharacter("main_whit")
CreateCharacter("main_zach")
CreateCharacter("evil_bian")
CreateCharacter("evil_kath")
CreateCharacter("evil_wolf")
CreateCharacter("evil_tyso")

-------------------------------------------------------------------------------
-- 2. "Primary" System Characters
-------------------------------------------------------------------------------
-- These characters serve high-level mechanical roles and are tracked independently.

CreatePrimaryCharacter("las_casinokeep")
CreatePrimaryCharacter("announcer")

-------------------------------------------------------------------------------
-- 3. Dynamic Travelers & Roaming NPCs
-------------------------------------------------------------------------------

CreateCharacter("trav_01")
CreateCharacter("trav_02")
CreateCharacter("trav_03")
CreateCharacter("trav_04")
CreateCharacter("trav_05")
CreateCharacter("trav_06")
CreateCharacter("trav_07")
CreateCharacter("trav_08")
CreateCharacter("trav_09")
CreateCharacter("trav_10")
CreateCharacter("trav_11")

-- Specific story characters that enter the traveler pool at various points
CreateCharacter("main_loud")
CreateCharacter("main_sara")
CreateCharacter("dou_bldg1keep")
CreateCharacter("bag_bldg2keep")
CreateCharacter("kon_bldg2keep")
CreateCharacter("mah_shopkeep")
CreateCharacter("rey_xxxxkeep")
CreateCharacter("tor_bldg1keep")
CreateCharacter("tor_bldg2keep")
CreateCharacter("wel_bldg1keep")
CreateCharacter("zur_riverkeep")

-------------------------------------------------------------------------------
-- 4. Global Encounter Pools (Ghost Buildings)
-------------------------------------------------------------------------------
-- The game engine uses "Buildings" as the fundamental container for character lists.
-- To facilitate random encounters during airplane flights or when wandering town, 
-- we create invisible "Ghost" buildings to act as a global array for these characters.

-- The "_travelers" building pool is checked during Airplane Flight encounters.
EmptyBuilding("_travelers")
_travelers.type = "special"

_travelers.characters[1] = { "trav_01" }
_travelers.characters[2] = { "trav_02" }
_travelers.characters[3] = { "trav_03" }
_travelers.characters[4] = { "trav_04" }
_travelers.characters[5] = { "trav_05" }
_travelers.characters[6] = { "trav_06" }
_travelers.characters[7] = { "trav_07" }
_travelers.characters[8] = { "trav_08" }
_travelers.characters[9] = { "trav_09" }
_travelers.characters[10] = { "trav_10" }
_travelers.characters[11] = { "trav_11" }
_travelers.characters[12] = { "mah_shopkeep" }
_travelers.characters[13] = { "main_loud" }
_travelers.characters[14] = { "main_sara" }

_TravelCharacters = { 
	"trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", 
	"trav_08", "trav_09", "trav_10", "trav_11", "mah_shopkeep", "main_loud", "main_sara" 
}

-- The "_empty" building pool is used as a fallback if the player enters a 
-- physical building in a port that currently has no active quest NPCs assigned to it.
EmptyBuilding("_empty")
_empty.type = "special"

_empty.characters[1] = { "tor_bldg2keep" }
_empty.characters[2] = { "wel_bldg1keep" }
_empty.characters[3] = { "dou_bldg1keep" }
_empty.characters[4] = { "bag_bldg2keep" }
_empty.characters[5] = { "kon_bldg2keep" }
_empty.characters[6] = { "rey_xxxxkeep" }
_empty.characters[7] = { "tor_bldg1keep" }
_empty.characters[8] = { "zur_riverkeep" }

-- NOTE: As long as these are defined with CreateCharacter above, do NOT use quotation marks 
-- when referencing them in engine hooks.
_EmptyCharacters = { 
	"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", 
	"kon_bldg2keep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep" 
}