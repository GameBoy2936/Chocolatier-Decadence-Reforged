--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Recipe Feedback Engine)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- INSTRUCTIONS FOR MODDERS:
-- This file contains the culinary rule sets that Teddy Baumeister uses to 
-- evaluate player-created User Generated Recipes (UGRs) in the Test Kitchen.
-- The system iterates through these arrays and accumulates score modifiers 
-- for every rule that matches the recipe. 
--
-- Note: Base recipe score is 140. Max score is 300 (which grants a 3.0x price markup).

-- RULE PROPERTIES:
--	feedback:   The base string key for the taster's dialogue. 
--	score:	    The points to add or subtract from the recipe's quality score.
--
-- CONDITIONS (ALL must be met for the rule to trigger):
--	requires:   A list of ingredient names that MUST be in the recipe.
--	forbids:	A list of ingredient names that MUST NOT be in the recipe.
--	ratios:	    A list of category ratio checks { "category", "operator", value }.
--	categories: A list of product category names this rule applies to. (If omitted, applies to all).
--
-- FEEDBACK CONTROL:
--	unique:     If true, this is low-priority "flavor text" used only if no specific feedback triggers.
--	voids:	    A list of other feedback keys that this rule overrides (Prevents generic text spam).

------------------------------------------------------------------------------
-- CHOCOLATE EVALUATORS
------------------------------------------------------------------------------

ChocolateEvaluators =
{
	-- =======================================================================
	-- SECTION 1: HARD PENALTIES & CULINARY DISASTERS (Score: -80 to -40)
	-- =======================================================================
	-- These rules ensure the product is actually chocolate and physically edible.
	
	-- Texture Failures (Violates the fundamental physics of chocolate making)
	{ ratios = { { "dairy", ">=", 0.8 } }, score = -80, feedback = "taster_choco_alldairy" },
	{ ratios = { { "sugar", ">=", 0.8 } }, score = -80, feedback = "taster_choco_allsugar" },
	{ ratios = { { "flavor", ">=", 0.8 } }, score = -80, feedback = "taster_choco_allflavors" },
	
	-- Identity Crisis (Too much coffee in a chocolate factory)
	{ ratios = { { "coffee", ">=", 0.7 } }, score = -60, feedback = "taster_choco_allcoffee" },

	-- The "Toothpaste" Effect (Mint clashes horribly with acid or warm spices)
	{ requires = { "cayenne", "mint" }, score = -40, feedback = "taster_feedback_cayenne_mint_bad", voids = { "taster_feedback_cayenne_solo", "taster_feedback_mint_solo" } },
	{ requires = { "turmeric", "mint" }, score = -40, feedback = "taster_feedback_turmeric_mint_bad", voids = { "taster_feedback_turmeric_solo", "taster_feedback_mint_solo" } },
	{ requires = { "ginger", "mint" }, score = -30, feedback = "taster_feedback_ginger_mint_bad", voids = { "taster_feedback_ginger_solo", "taster_feedback_mint_solo" } },
	{ requires = { "rose", "mint" }, score = -30, feedback = "taster_feedback_rose_mint_bad", voids = { "taster_feedback_rose_solo", "taster_feedback_mint_solo" } },

	-- The "Curdle" Effect (Citrus acid destroys dairy) 
	-- Exception: White chocolate (high fat/sugar) stabilizes acid, which is handled favorably in Section 2.
	-- If it's NOT white chocolate (i.e. has high cacao) and mixes dairy + acid, it curdles:
	{ requires = { "lemon", "dairy" }, ratios = { { "cacao", ">", 0.1 } }, score = -40, feedback = "taster_feedback_lemon_dairy_bad", voids = { "taster_feedback_lemon_solo", "taster_feedback_milk_chocolate" } },
	{ requires = { "lime", "dairy" }, ratios = { { "cacao", ">", 0.1 } }, score = -40, feedback = "taster_feedback_lemon_dairy_bad", voids = { "taster_feedback_lime_solo", "taster_feedback_milk_chocolate" } },
	{ requires = { "orange", "dairy" }, ratios = { { "cacao", ">", 0.1 } }, score = -40, feedback = "taster_feedback_lemon_dairy_bad", voids = { "taster_feedback_orange_solo", "taster_feedback_milk_chocolate" } },
	{ requires = { "sumac", "dairy" }, ratios = { { "cacao", ">", 0.1 } }, score = -40, feedback = "taster_feedback_sumac_dairy_bad", voids = { "taster_feedback_sumac_solo", "taster_feedback_milk_chocolate" } },

	-- Wasabi Misuse (Wasabi utterly destroys sweet fruits and liquors)
	{ requires = { "wasabi", "cherry" }, score = -60, feedback = "taster_feedback_wasabi_fruit_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_cherry_solo" } },
	{ requires = { "wasabi", "lemon" }, score = -60, feedback = "taster_feedback_wasabi_fruit_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "wasabi", "lime" }, score = -60, feedback = "taster_feedback_wasabi_fruit_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_lime_solo" } },
	{ requires = { "wasabi", "orange" }, score = -60, feedback = "taster_feedback_wasabi_fruit_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_orange_solo" } },
	{ requires = { "wasabi", "raspberry" }, score = -60, feedback = "taster_feedback_wasabi_fruit_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_raspberry_solo" } },
	{ requires = { "wasabi", "blueberry" }, score = -60, feedback = "taster_feedback_wasabi_fruit_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_blueberry_solo" } },
	{ requires = { "wasabi", "strawberry" }, score = -60, feedback = "taster_feedback_wasabi_fruit_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_strawberry_solo" } },
	{ requires = { "whiskey", "wasabi" }, score = -60, feedback = "taster_feedback_whiskey_wasabi_bad", voids = { "taster_feedback_whiskey_solo", "taster_feedback_wasabi_solo" } },
	
	-- Floral & Spice Clashes (Perfume Overload)
	{ requires = { "lavender", "lime" }, score = -45, feedback = "taster_feedback_lavender_lime_bad", voids = { "taster_feedback_lavender_solo", "taster_feedback_lime_solo" } },
	{ requires = { "matcha", "orange" }, score = -40, feedback = "taster_feedback_matcha_orange_bad", voids = { "taster_feedback_matcha_solo", "taster_feedback_orange_solo" } },
	{ requires = { "currant", "lime" }, score = -30, feedback = "taster_feedback_currant_lime_bad", voids = { "taster_feedback_currant_solo", "taster_feedback_lime_solo" } },
	{ requires = { "lavender", "cayenne" }, score = -30, feedback = "taster_feedback_lavender_cayenne_bad", voids = { "taster_feedback_lavender_solo", "taster_feedback_cayenne_solo" } },
	{ requires = { "anise", "peanut" }, score = -30, feedback = "taster_feedback_anise_peanut_bad", voids = { "taster_feedback_anise_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "lavender", "cinnamon" }, score = -30, feedback = "taster_feedback_lavender_cinnamon_bad", voids = { "taster_feedback_lavender_solo", "taster_feedback_cinnamon_solo" } },

	-- Delicate Ingredient Overpowering (Dark chocolate completely masks these subtle flavors)
	{ requires = { "matcha" }, ratios = { { "cacao", ">=", 0.6 }, { "dairy", "<", 0.1 } }, score = -25, feedback = "taster_feedback_matcha_dark_bad", voids = { "taster_feedback_matcha_solo", "taster_feedback_pure_dark" } },
	{ requires = { "rose" }, ratios = { { "cacao", ">=", 0.6 }, { "dairy", "==", 0 } }, score = -25, feedback = "taster_feedback_dark_rose_bad", voids = { "taster_feedback_rose_solo" } },


	-- =======================================================================
	-- SECTION 2: TOP-TIER & COMPLEX RECIPES (Score: +40 to +60)
	-- =======================================================================
	-- These are highly specific, difficult-to-balance recipes that reward players 
	-- generously for discovering them.
	
	-- Mesoamerican / Spicy Profiles
	{ requires = { "cinnamon", "cayenne" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 60, feedback = "taster_feedback_mesoamerican", voids = { "taster_feedback_spicy_chocolate" } },
	{ requires = { "vanilla", "cayenne" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 55, feedback = "taster_feedback_mesoamerican", voids = { "taster_feedback_spicy_chocolate" } },
	{ requires = { "wasabi", "coconut" }, score = 50, feedback = "taster_feedback_wasabi_coconut", voids = {"taster_feedback_wasabi_solo", "taster_feedback_coconut_solo"} },
	
	-- Master Pastry Classics
	{ requires = { "apple", "caramel" }, score = 55, feedback = "taster_feedback_caramel_apple", voids = {"taster_feedback_apple_solo", "taster_feedback_sugar_caramel"} },
	{ requires = { "cherry", "whipped_cream" }, score = 50, feedback = "taster_feedback_black_forest", voids = {"taster_feedback_cherry_solo"} },
	{ requires = { "banana", "toffee" }, ratios = { { "dairy", ">=", 0.15 } }, score = 50, feedback = "taster_feedback_banoffee", voids = {"taster_feedback_banana_caramel"} },
	{ requires = { "pistachio", "cherry" }, ratios = { { "cacao", ">=", 0.2 } }, score = 50, feedback = "taster_feedback_spumoni", voids = {"taster_feedback_pistachio_solo", "taster_feedback_cherry_solo"} },
	{ requires = { "chestnut", "vanilla" }, ratios = { { "dairy", ">=", 0.2 } }, score = 50, feedback = "taster_feedback_mont_blanc", voids = { "taster_feedback_chestnut_solo", "taster_feedback_vanilla_solo" } },
	{ requires = { "strawberry", "vanilla" }, ratios = { { "cacao", ">=", 0.2 } }, score = 45, feedback = "taster_feedback_neapolitan", voids = { "taster_feedback_strawberry_solo", "taster_feedback_vanilla_solo" } },
	
	-- White Chocolate Specialties (High Score because it's difficult to balance 0 cacao)
	{ requires = { "matcha" }, ratios = { { "dairy", ">", 0 }, { "cacao", "<=", 0.25 } }, score = 55, feedback = "taster_feedback_white_matcha", voids = { "taster_feedback_white_chocolate", "taster_feedback_matcha_solo" } },
	{ requires = { "macadamia" }, ratios = { { "dairy", ">", 0 }, { "cacao", "<=", 0.25 } }, score = 50, feedback = "taster_feedback_white_macadamia", voids = { "taster_feedback_white_chocolate", "taster_feedback_macadamia_solo" } },
	{ requires = { "pistachio" }, ratios = { { "dairy", ">", 0 }, { "cacao", "<=", 0.25 } }, score = 50, feedback = "taster_feedback_white_pistachio", voids = { "taster_feedback_white_chocolate", "taster_feedback_pistachio_solo" } },
	{ requires = { "passionfruit" }, ratios = { { "dairy", ">", 0 }, { "cacao", "<=", 0.25 } }, score = 50, feedback = "taster_feedback_white_passion", voids = { "taster_feedback_white_chocolate", "taster_feedback_passionfruit_solo" } },
	{ requires = { "hibiscus" }, ratios = { { "dairy", ">", 0 }, { "cacao", "<=", 0.25 } }, score = 50, feedback = "taster_feedback_white_hibiscus", voids = { "taster_feedback_white_chocolate", "taster_feedback_hibiscus_solo" } },
	{ requires = { "lavender" }, ratios = { { "dairy", ">", 0 }, { "cacao", "<=", 0.25 } }, score = 45, feedback = "taster_feedback_white_lavender", voids = { "taster_feedback_white_chocolate", "taster_feedback_lavender_solo" } },
	{ requires = { "wasabi" }, ratios = { { "dairy", ">", 0 }, { "cacao", "<=", 0.25 } }, score = 45, feedback = "taster_feedback_wasabi_white", voids = {"taster_feedback_wasabi_solo", "taster_feedback_white_chocolate"} },

	-- Deep Dark Chocolate Specialties
	{ requires = { "salt" }, ratios = { { "cacao", ">=", 0.6 }, { "dairy", "==", 0 } }, score = 45, feedback = "taster_feedback_dark_salt", voids = { "taster_feedback_salt_solo" } },
	{ requires = { "espresso" }, ratios = { { "cacao", ">=", 0.6 }, { "dairy", "==", 0 } }, score = 45, feedback = "taster_feedback_dark_espresso", voids = { "taster_feedback_espresso_solo" } },
	{ requires = { "grand_marnier" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 50, feedback = "taster_feedback_dark_grand_marnier", voids = { "taster_feedback_grand_marnier_solo" } },
	{ requires = { "sumac" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 45, feedback = "taster_feedback_sumac_dark", voids = { "taster_feedback_sumac_solo", "taster_feedback_pure_dark" } },
	{ requires = { "mango" }, ratios = { { "cacao", "=>", 0.5 }, { "dairy", "==", 0 } }, score = 45, feedback = "taster_feedback_dark_mango" },
	{ requires = { "currant" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 40, feedback = "taster_feedback_currant_darkchoc", voids = { "taster_feedback_currant_solo" } },
	{ requires = { "blackberry" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 40, feedback = "taster_feedback_dark_tart_berry", voids = { "taster_feedback_blackberry_solo" } },
	{ requires = { "raspberry" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 40, feedback = "taster_feedback_dark_tart_berry", voids = { "taster_feedback_raspberry_solo" } },
	{ requires = { "pomegranate" }, ratios = { { "cacao", ">=", 0.6 }, { "dairy", "==", 0 } }, score = 40, feedback = "taster_feedback_dark_pomegranate", voids = { "taster_feedback_pomegranate_solo" } },

	-- Floral Masterpieces
	{ requires = { "rose", "saffron" }, score = 50, feedback = "taster_feedback_rose_saffron", voids = { "taster_feedback_rose_solo", "taster_feedback_saffron_solo" } },
	{ requires = { "rose", "pistachio" }, score = 50, feedback = "taster_feedback_rose_pistachio", voids = { "taster_feedback_rose_solo", "taster_feedback_pistachio_solo" } },
	{ requires = { "rose", "raspberry" }, score = 50, feedback = "taster_feedback_rose_raspberry", voids = { "taster_feedback_rose_solo", "taster_feedback_raspberry_solo" } },

	-- Savory / Salty Caramels
	{ requires = { "salt", "caramel" }, score = 45, feedback = "taster_feedback_salt_sweet", voids = {"taster_feedback_sugar_caramel", "taster_feedback_salt_solo"} },
	{ requires = { "salt", "maple" }, score = 45, feedback = "taster_feedback_salt_sweet", voids = {"taster_feedback_sugar_caramel", "taster_feedback_salt_solo"} },
	{ requires = { "whiskey", "caramel" }, score = 45, feedback = "taster_feedback_boozy_caramel", voids = { "taster_feedback_whiskey_solo", "taster_feedback_sugar_caramel" } },
	
	-- Nutty Core Synergies
	{ requires = { "hazelnut" }, ratios = { { "cacao", ">", 0.2 }, { "dairy", ">=", 0.1 } }, score = 45, feedback = "taster_feedback_gianduja", voids = { "taster_feedback_hazelnut_solo" } },
	{ requires = { "pecan", "butter" }, score = 45, feedback = "taster_feedback_butter_pecan", voids = {"taster_feedback_crunchy_smooth", "taster_feedback_pecan_solo"} },
	{ requires = { "banana", "walnut" }, score = 45, feedback = "taster_feedback_banana_walnut", voids = {"taster_feedback_banana_solo", "taster_feedback_walnut_solo"} },
	{ requires = { "maple", "walnut" }, score = 45, feedback = "taster_feedback_maple_walnut", voids = { "taster_feedback_maple_solo", "taster_feedback_walnut_solo" } },
	{ requires = { "maple", "pecan" }, score = 45, feedback = "taster_feedback_maple_pecan", voids = { "taster_feedback_maple_solo", "taster_feedback_pecan_solo" } },


	-- =======================================================================
	-- SECTION 3: GOOD / COMPLEMENTARY COMBINATIONS (Score: +25 to +35)
	-- =======================================================================

	-- Stuffed Fruits
	{ requires = { "date", "walnut" }, score = 35, feedback = "taster_feedback_stuffed_date", voids = { "taster_feedback_date_solo", "taster_feedback_walnut_solo" } },
	{ requires = { "date", "almond" }, score = 35, feedback = "taster_feedback_stuffed_date", voids = { "taster_feedback_date_solo", "taster_feedback_almond_solo" } },
	{ requires = { "fig", "brandy" }, score = 35, feedback = "taster_feedback_fig_brandy", voids = {"taster_feedback_fig_solo", "taster_feedback_brandy_solo"} },
	{ requires = { "fig", "pistachio" }, score = 35, feedback = "taster_feedback_fig_pistachio" },

	-- Modern Twists (PB&J, etc.)
	{ requires = { "peanut", "raspberry" }, score = 40, feedback = "taster_feedback_pb_and_j", voids = { "taster_feedback_peanut_solo", "taster_feedback_raspberry_solo" } },
	{ requires = { "peanut", "strawberry" }, score = 40, feedback = "taster_feedback_pb_and_j", voids = { "taster_feedback_peanut_solo", "taster_feedback_strawberry_solo" } },
	{ requires = { "pomegranate", "pistachio" }, score = 35, feedback = "taster_feedback_pomegranate_pistachio", voids = { "taster_feedback_pomegranate_solo", "taster_feedback_pistachio_solo" } },
	{ requires = { "lavender", "tea" }, score = 35, feedback = "taster_feedback_lavender_tea", voids = { "taster_feedback_lavender_solo", "taster_feedback_tea_solo" } },
	{ requires = { "hibiscus", "pineapple" }, score = 35, feedback = "taster_feedback_hibiscus_pineapple", voids = { "taster_feedback_hibiscus_solo", "taster_feedback_pineapple_solo" } },
	{ requires = { "rose", "cardamom" }, score = 35, feedback = "taster_feedback_rose_cardamom", voids = { "taster_feedback_rose_solo", "taster_feedback_cardamom_solo" } },
	{ requires = { "cinnamon", "pumpkin" }, score = 35, feedback = "taster_feedback_autumn_spice", voids = {"taster_feedback_pumpkin_solo"} },
	{ requires = { "nutmeg", "pumpkin" }, score = 35, feedback = "taster_feedback_autumn_spice", voids = {"taster_feedback_pumpkin_solo"} },
	{ requires = { "clove", "pumpkin" }, score = 35, feedback = "taster_feedback_autumn_spice", voids = {"taster_feedback_pumpkin_solo"} },
	{ requires = { "cinnamon", "clove" }, score = 30, feedback = "taster_feedback_autumn_spice", voids = {"taster_feedback_cinnamon_solo"} },
	{ requires = { "star_anise", "cinnamon", "clove" }, score = 35, feedback = "taster_feedback_fivespice" },

	-- Tropical & Mixed Fruits
	{ requires = { "passionfruit", "mango" }, score = 30, feedback = "taster_feedback_tropical_fruit", voids = {"taster_feedback_mango_solo"} },
	{ requires = { "pineapple", "coconut" }, score = 30, feedback = "taster_feedback_tropical_fruit", voids = {"taster_feedback_coconut_solo"} },
	{ requires = { "blueberry", "raspberry" }, score = 30, feedback = "taster_feedback_berries" },
	{ requires = { "blueberry", "strawberry" }, score = 30, feedback = "taster_feedback_berries" },
	{ requires = { "strawberry", "raspberry" }, score = 30, feedback = "taster_feedback_berries" },
	{ requires = { "blackberry", "lemon" }, score = 35, feedback = "taster_feedback_blackberry_lemon", voids = {"taster_feedback_blackberry_solo"} },
	{ requires = { "coconut", "lime" }, score = 35, feedback = "taster_feedback_coconut_lime", voids = { "taster_feedback_coconut_solo", "taster_feedback_lime_solo" } },
	{ requires = { "orange", "mango" }, score = 30, feedback = "taster_feedback_orange_mango" },

	-- Boozy Pairings
	{ requires = { "mint", "lime" }, ratios = { { "sugar", ">", 0.15 } }, forbids = { "dairy" }, score = 35, feedback = "taster_feedback_mojito", voids = {"taster_feedback_mint_solo"} },
	{ requires = { "kahlua", "cream" }, score = 30, feedback = "taster_feedback_kahlua_cream" },
	{ requires = { "kahlua", "milk" }, score = 30, feedback = "taster_feedback_kahlua_milk" },
	{ requires = { "whiskey", "cherry" }, categories = { "truffle" }, score = 35, feedback = "taster_feedback_whiskey_cherry", voids = {"taster_feedback_whiskey_solo"} },
	{ requires = { "rum", "raisin" }, score = 35, feedback = "taster_feedback_rum_raisin", voids = {"taster_feedback_rum_solo"} },
	{ requires = { "cherry", "amaretto" }, score = 35, feedback = "taster_feedback_amaretto_cherry", voids = {"taster_feedback_cherry_solo", "taster_feedback_amaretto_solo"} },

	-- Mixed Nuts & Savory
	{ requires = { "apple", "walnut" }, score = 30, feedback = "taster_feedback_apple_walnut" },
	{ requires = { "banana", "caramel" }, score = 30, feedback = "taster_feedback_banana_caramel" },
	{ requires = { "toffee", "walnut" }, score = 30, feedback = "taster_feedback_toffee_nut" },
	{ requires = { "toffee", "almond" }, score = 30, feedback = "taster_feedback_toffee_nut" },
	{ requires = { "currant", "hazelnut" }, score = 30, feedback = "taster_feedback_currant_hazelnut", voids = { "taster_feedback_currant_solo", "taster_feedback_hazelnut_solo" } },
	{ requires = { "almond", "pistachio" }, score = 30, feedback = "taster_feedback_almond_pistachio", voids = { "taster_feedback_almond_solo", "taster_feedback_pistachio_solo" } },
	{ requires = { "cherry", "currant" }, score = 30, feedback = "taster_feedback_cherry_currant", voids = { "taster_feedback_cherry_solo", "taster_feedback_currant_solo" } },
	{ requires = { "cayenne", "honey" }, score = 30, feedback = "taster_feedback_cayenne_honey", voids = {"taster_feedback_honey_solo"} },
	{ requires = { "cayenne", "lime" }, score = 30, feedback = "taster_feedback_cayenne_lime", voids = {"taster_feedback_spicy_chocolate"} },
	{ requires = { "sumac", "salt" }, score = 30, feedback = "taster_feedback_sumac_salt", voids = { "taster_feedback_sumac_solo", "taster_feedback_salt_solo" } },
	{ requires = { "hibiscus", "mango" }, score = 30, feedback = "taster_feedback_hibiscus_mango", voids = { "taster_feedback_hibiscus_solo", "taster_feedback_mango_solo" } },
	{ requires = { "lavender", "blueberry" }, score = 30, feedback = "taster_feedback_lavender_blueberry", voids = { "taster_feedback_lavender_solo", "taster_feedback_blueberry_solo" } },
	{ requires = { "matcha", "honey" }, score = 30, feedback = "taster_feedback_matcha_honey", voids = { "taster_feedback_matcha_solo", "taster_feedback_honey_solo" } },


	-- =======================================================================
	-- SECTION 4: INTERESTING / SUBTLE COMBINATIONS (Score: +10 to +25)
	-- =======================================================================
	
	-- Sweet & Creamy Variations
	{ requires = { "currant", "cream" }, score = 25, feedback = "taster_feedback_currant_cream" },
	{ requires = { "lychee", "rose" }, score = 25, feedback = "taster_feedback_rose_lychee", voids = {"taster_feedback_lychee_solo"} },
	{ requires = { "caramel", "peanut" }, score = 25, feedback = "taster_feedback_caramel_nuts", voids = {"taster_feedback_sugar_caramel"} },
	{ requires = { "caramel", "almond" }, score = 25, feedback = "taster_feedback_caramel_nuts", voids = {"taster_feedback_sugar_caramel"} },
	{ requires = { "caramel", "hazelnut" }, score = 25, feedback = "taster_feedback_caramel_nuts", voids = {"taster_feedback_sugar_caramel"} },
	{ requires = { "caramel", "cashew" }, score = 25, feedback = "taster_feedback_caramel_nuts", voids = {"taster_feedback_sugar_caramel"} },
	{ requires = { "sesame", "wasabi" }, score = 25, feedback = "taster_feedback_sesame_wasabi", voids = {"taster_feedback_wasabi_solo"} },
	{ requires = { "matcha", "milk" }, score = 25, feedback = "taster_feedback_matcha_latte", voids = {"taster_feedback_matcha_solo"} },
	{ requires = { "matcha", "cream" }, score = 25, feedback = "taster_feedback_matcha_latte", voids = {"taster_feedback_matcha_solo"} },
	{ requires = { "sesame" }, ratios = { { "dairy", ">=", 0.1 }, { "dairy", "<=", 0.4 } }, score = 25, feedback = "taster_feedback_sesame_tahini", voids = {"taster_feedback_sesame_solo"} },
	
	-- Vanilla Synergy
	{ requires = { "vanilla", "caramel" }, score = 20, feedback = "taster_feedback_vanilla_sweet", voids = {"taster_feedback_sugar_caramel"} },
	{ requires = { "vanilla", "maple" }, score = 20, feedback = "taster_feedback_vanilla_sweet", voids = {"taster_feedback_vanilla_solo"} },
	{ requires = { "vanilla", "cherry" }, score = 20, feedback = "taster_feedback_vanilla_sweet", voids = {"taster_feedback_vanilla_solo"} },
	{ requires = { "vanilla", "lavender" }, score = 25, feedback = "taster_feedback_lavender_vanilla", voids = { "taster_feedback_lavender_solo" } },
	{ requires = { "vanilla", "rose" }, score = 25, feedback = "taster_feedback_rose_vanilla", voids = { "taster_feedback_rose_solo" } },

	-- Mediterranean Synergy
	{ requires = { "star_anise", "orange" }, score = 25, feedback = "taster_feedback_star_anise_orange" },
	{ requires = { "orange", "salt" }, ratios = { { "sugar", ">=", 0.15 } }, score = 25, feedback = "taster_feedback_salted_citrus", voids = {"taster_feedback_salt_solo"} },
	{ requires = { "anise", "orange" }, score = 25, feedback = "taster_feedback_anise_orange" },
	{ requires = { "anise", "kahlua" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "anise", "amaretto" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "anise", "grand_marnier" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "orange", "kahlua" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "orange", "amaretto" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "orange", "grand_marnier" }, score = 20, feedback = "taster_feedback_mediterranean" },
	
	-- Herbal / Florals
	{ requires = { "tea", "rose" }, score = 25, feedback = "taster_feedback_tea_floral", voids = { "taster_feedback_tea_solo", "taster_feedback_rose_solo" } },
	{ requires = { "tea", "hibiscus" }, score = 25, feedback = "taster_feedback_tea_floral", voids = { "taster_feedback_tea_solo", "taster_feedback_hibiscus_solo" } },
	{ requires = { "tea", "cinnamon" }, score = 20, feedback = "taster_feedback_chai", voids = {"taster_feedback_tea_solo"} },
	{ requires = { "hibiscus", "ginger" }, score = 25, feedback = "taster_feedback_hibiscus_ginger" },
	{ requires = { "hibiscus", "cinnamon" }, score = 25, feedback = "taster_feedback_hibiscus_cinnamon" },
	{ requires = { "lavender", "honey" }, score = 25, feedback = "taster_feedback_lavender_honey", voids = { "taster_feedback_lavender_solo", "taster_feedback_honey_solo" } },
	{ requires = { "lavender", "lemon" }, score = 25, feedback = "taster_feedback_lavender_lemon", voids = { "taster_feedback_lavender_solo" } },
	{ requires = { "rose", "strawberry" }, score = 25, feedback = "taster_feedback_rose_strawberry", voids = { "taster_feedback_rose_solo", "taster_feedback_strawberry_solo" } },
	{ requires = { "sumac", "honey" }, score = 25, feedback = "taster_feedback_sumac_honey", voids = { "taster_feedback_sumac_solo", "taster_feedback_honey_solo" } },
	{ requires = { "sumac", "cayenne" }, score = 25, feedback = "taster_feedback_sumac_cayenne", voids = { "taster_feedback_sumac_solo", "taster_feedback_spicy_chocolate" } },
	{ requires = { "lemon", "honey" }, score = 20, feedback = "taster_feedback_lemon_honey" },
	{ requires = { "mint", "caramel" }, score = 20, feedback = "taster_feedback_mint_caramel" },
	{ requires = { "lemon", "lime" }, score = 20, feedback = "taster_feedback_lemon_lime" },
	{ requires = { "hibiscus", "mint" }, score = 20, feedback = "taster_feedback_hibiscus_mint", voids = { "taster_feedback_hibiscus_solo", "taster_feedback_mint_solo" } },
	{ requires = { "matcha", "lemon" }, score = 20, feedback = "taster_feedback_matcha_lemon", voids = { "taster_feedback_matcha_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "matcha", "ginger" }, score = 20, feedback = "taster_feedback_matcha_ginger", voids = { "taster_feedback_matcha_solo", "taster_feedback_ginger_solo" } },
	{ requires = { "lavender", "mint" }, score = 15, feedback = "taster_feedback_lavender_mint", voids = { "taster_feedback_lavender_solo", "taster_feedback_mint_solo" } },
	{ requires = { "apple", "cinnamon" }, score = 20, feedback = "taster_feedback_apple_cinnamon", voids = {"taster_feedback_autumn_spice", "taster_feedback_cinnamon_solo"} },

	-- Texture Blends
	{ requires = { "butter", "cashew" }, score = 15, feedback = "taster_feedback_crunchy_smooth", voids = {"taster_feedback_butter_solo"} },
	{ requires = { "butter", "peanut" }, score = 15, feedback = "taster_feedback_crunchy_smooth", voids = {"taster_feedback_butter_solo"} },
	{ requires = { "butter", "hazelnut" }, score = 15, feedback = "taster_feedback_crunchy_smooth", voids = {"taster_feedback_butter_solo"} },
	{ requires = { "butter", "macadamia" }, score = 15, feedback = "taster_feedback_crunchy_smooth", voids = {"taster_feedback_butter_solo"} },
	{ requires = { "butter", "almond" }, score = 15, feedback = "taster_feedback_crunchy_smooth", voids = {"taster_feedback_butter_solo"} },
	
	-- Miscellaneous Minor Synergies
	{ requires = { "orange", "hazelnut" }, score = 15, feedback = "taster_feedback_orange_nuts" },
	{ requires = { "orange", "almond" }, score = 15, feedback = "taster_feedback_orange_almond" },
	{ requires = { "turmeric", "ginger" }, score = 15, feedback = "taster_feedback_turmeric_ginger" },
	{ requires = { "sumac", "strawberry" }, score = 15, feedback = "taster_feedback_sumac_berry", voids = {"taster_feedback_sumac_solo"} },
	{ requires = { "sumac", "raspberry" }, score = 15, feedback = "taster_feedback_sumac_berry", voids = {"taster_feedback_sumac_solo"} },
	{ requires = { "sumac", "blueberry" }, score = 15, feedback = "taster_feedback_sumac_berry", voids = {"taster_feedback_sumac_solo"} },
	{ requires = { "sumac", "blackberry" }, score = 15, feedback = "taster_feedback_sumac_berry", voids = {"taster_feedback_sumac_solo"} },
	{ requires = { "matcha", "almond" }, score = 15, feedback = "taster_feedback_matcha_almond", voids = { "taster_feedback_matcha_solo", "taster_feedback_almond_solo" } },
	{ requires = { "anise", "cherry" }, score = 10, feedback = "taster_feedback_anise_cherry" },
	{ requires = { "lemon", "mint" }, score = 10, feedback = "taster_feedback_lemon_mint" },
	{ requires = { "pineapple", "mint" }, score = 10, feedback = "taster_feedback_pineapple_mint" },
	{ requires = { "anise" }, ratios = { { "coffee", ">=", 0.1 } }, score = 10, feedback = "taster_feedback_anise_coffee" },
	{ requires = { "lemon", "hazelnut" }, score = 10, feedback = "taster_feedback_lemon_hazelnut" },
	{ requires = { "orange", "peanut" }, score = 10, feedback = "taster_feedback_orange_peanut" },
	
	-- Fallback Checks (If not a specific named recipe)
	{ requires = { "wasabi", "cacao" }, score = 10, feedback = "taster_feedback_spicy_chocolate", unique = true },
	{ requires = { "cayenne", "cacao" }, score = 10, feedback = "taster_feedback_spicy_chocolate", unique = true },
	
	-- Core Base Archetype Identification
	{ ratios = { { "dairy", ">=", 0.4 }, { "sugar", ">=", 0.3 }, { "cacao", "<=", 0.05 } }, score = 25, feedback = "taster_feedback_white_chocolate", voids = {"taster_feedback_milk_chocolate"} },
	{ ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 25, feedback = "taster_feedback_pure_dark", unique = true },

	-- =======================================================================
	-- SECTION 5: FLAVOR TEXT & SINGLE-INGREDIENT COMMENTS (Score: +0)
	-- =======================================================================
	-- These are marked Unique=True, meaning Teddy will only say these lines if 
	-- absolutely nothing else triggered during his evaluation.
	
	-- Generic Simple Combinations
	{ requires = { "milk", "cacao" }, score = 0, feedback = "taster_feedback_milk_chocolate", unique = true },
	{ requires = { "lemon", "orange" }, score = 0, feedback = "taster_feedback_lemon_orange", unique = true },
	{ requires = { "sugar", "caramel" }, score = 0, feedback = "taster_feedback_sugar_caramel", unique = true },
	{ requires = { "sugar", "mint" }, score = 0, feedback = "taster_feedback_sugar_mint", unique = true },
	{ requires = { "sugar", "orange" }, score = 0, feedback = "taster_feedback_sugar_orange", unique = true },
	{ requires = { "lemon", "almond" }, score = 0, feedback = "taster_feedback_lemon_almond", unique = true },
	{ requires = { "lemon", "peanut" }, score = 0, feedback = "taster_feedback_lemon_peanut", unique = true },
	{ requires = { "sugar", "lemon" }, score = 15, feedback = "taster_feedback_sugar_lemon", unique = true },
	
	-- Solo Ingredient Observation Fallbacks (Alphabetical)
	{ requires = { "allspice" }, score = 0, feedback = "taster_feedback_allspice_solo", unique = true },
	{ requires = { "almond" }, score = 0, feedback = "taster_feedback_almond_solo", unique = true },
	{ requires = { "amaretto" }, score = 0, feedback = "taster_feedback_amaretto_solo", unique = true },
	{ requires = { "anise" }, score = 0, feedback = "taster_feedback_anise_solo", unique = true },
	{ requires = { "apple" }, score = 0, feedback = "taster_feedback_apple_solo", unique = true },
	{ requires = { "banana" }, score = 0, feedback = "taster_feedback_banana_solo", unique = true },
	{ requires = { "blackberry" }, score = 0, feedback = "taster_feedback_blackberry_solo", unique = true },
	{ requires = { "blueberry" }, score = 0, feedback = "taster_feedback_blueberry_solo", unique = true },
	{ requires = { "brandy" }, score = 0, feedback = "taster_feedback_brandy_solo", unique = true },
	{ requires = { "butter" }, score = 0, feedback = "taster_feedback_butter_solo", unique = true },
	{ requires = { "cardamom" }, score = 0, feedback = "taster_feedback_cardamom_solo", unique = true },
	{ requires = { "cashew" }, score = 0, feedback = "taster_feedback_cashew_solo", unique = true },
	{ requires = { "chestnut" }, score = 0, feedback = "taster_feedback_chestnut_solo", unique = true },
	{ requires = { "cinnamon" }, score = 0, feedback = "taster_feedback_cinnamon_solo", unique = true },
	{ requires = { "clove" }, score = 0, feedback = "taster_feedback_clove_solo", unique = true },
	{ requires = { "coconut" }, score = 0, feedback = "taster_feedback_coconut_solo", unique = true },
	{ requires = { "cream" }, score = 0, feedback = "taster_feedback_cream_solo", unique = true },
	{ requires = { "currant" }, score = 0, feedback = "taster_feedback_currant_solo", unique = true },
	{ requires = { "date" }, score = 0, feedback = "taster_feedback_date_solo", unique = true },
	{ requires = { "espresso" }, score = 0, feedback = "taster_feedback_espresso_solo", unique = true },
	{ requires = { "fig" }, score = 0, feedback = "taster_feedback_fig_solo", unique = true },
	{ requires = { "ginger" }, score = 0, feedback = "taster_feedback_ginger_solo", unique = true },
	{ requires = { "grand_marnier" }, score = 0, feedback = "taster_feedback_grand_marnier_solo", unique = true },
	{ requires = { "hazelnut" }, score = 0, feedback = "taster_feedback_hazelnut_solo", unique = true },
	{ requires = { "hibiscus" }, score = 0, feedback = "taster_feedback_hibiscus_solo", unique = true },
	{ requires = { "honey" }, score = 0, feedback = "taster_feedback_honey_solo", unique = true },
	{ requires = { "kahlua" }, score = 0, feedback = "taster_feedback_kahlua_solo", unique = true },
	{ requires = { "lavender" }, score = 0, feedback = "taster_feedback_lavender_solo", unique = true },
	{ requires = { "lemon" }, score = 0, feedback = "taster_feedback_lemon_solo", unique = true },
	{ requires = { "lime" }, score = 0, feedback = "taster_feedback_lime_solo", unique = true },
	{ requires = { "lychee" }, score = 0, feedback = "taster_feedback_lychee_solo", unique = true },
	{ requires = { "macadamia" }, score = 0, feedback = "taster_feedback_macadamia_solo", unique = true },
	{ requires = { "matcha" }, score = 0, feedback = "taster_feedback_matcha_solo", unique = true },
	{ requires = { "nutmeg" }, score = 0, feedback = "taster_feedback_nutmeg_solo", unique = true },
	{ requires = { "orange" }, score = 0, feedback = "taster_feedback_orange_solo", unique = true },
	{ requires = { "passionfruit" }, score = 0, feedback = "taster_feedback_passionfruit_solo", unique = true },
	{ requires = { "peanut" }, score = 0, feedback = "taster_feedback_peanut_solo", unique = true },
	{ requires = { "pecan" }, score = 0, feedback = "taster_feedback_pecan_solo", unique = true },
	{ requires = { "cayenne" }, score = 0, feedback = "taster_feedback_cayenne_solo", unique = true },
	{ requires = { "pineapple" }, score = 0, feedback = "taster_feedback_pineapple_solo", unique = true },
	{ requires = { "pomegranate" }, score = 0, feedback = "taster_feedback_pomegranate_solo", unique = true },
	{ requires = { "pumpkin" }, score = 0, feedback = "taster_feedback_pumpkin_solo", unique = true },
	{ requires = { "raisin" }, score = 0, feedback = "taster_feedback_raisin_solo", unique = true },
	{ requires = { "raspberry" }, score = 0, feedback = "taster_feedback_raspberry_solo", unique = true },
	{ requires = { "rum" }, score = 0, feedback = "taster_feedback_rum_solo", unique = true },
	{ requires = { "saffron" }, score = 0, feedback = "taster_feedback_saffron_solo", unique = true },
	{ requires = { "salt" }, score = 0, feedback = "taster_feedback_salt_solo", unique = true },
	{ requires = { "sesame" }, score = 0, feedback = "taster_feedback_sesame_solo", unique = true },
	{ requires = { "star_anise" }, score = 0, feedback = "taster_feedback_star_anise_solo", unique = true },
	{ requires = { "strawberry" }, score = 0, feedback = "taster_feedback_strawberry_solo", unique = true },
	{ requires = { "sumac" }, score = 0, feedback = "taster_feedback_sumac_solo", unique = true },
	{ requires = { "tea" }, score = 0, feedback = "taster_feedback_tea_solo", unique = true },
	{ requires = { "toffee" }, score = 0, feedback = "taster_feedback_toffee_solo", unique = true },
	{ requires = { "turmeric" }, score = 0, feedback = "taster_feedback_turmeric_solo", unique = true },
	{ requires = { "vanilla" }, score = 0, feedback = "taster_feedback_vanilla_solo", unique = true },
	{ requires = { "walnut" }, score = 0, feedback = "taster_feedback_walnut_solo", unique = true },
	{ requires = { "wasabi" }, score = 0, feedback = "taster_feedback_wasabi_solo", unique = true },
	{ requires = { "whipped_cream" }, score = 0, feedback = "taster_feedback_whipped_cream_solo", unique = true },
}


------------------------------------------------------------------------------
-- COFFEE EVALUATORS
------------------------------------------------------------------------------

CoffeeEvaluators =
{
	-- =======================================================================
	-- SECTION 1: TEA HACKS (The "Hidden" Menu) (Score: +30 to +50)
	-- =======================================================================
	-- These rules trigger ONLY if the player puts zero coffee beans into the 
	-- coffee machine. This explicitly overrides the "Where's the coffee?" 
	-- penalty, allowing players to legitimately manufacture and sell teas.

	-- Top-Tier Tea & Matcha Recipes
	{ requires = { "matcha", "cream" }, ratios = { { "coffee", "==", 0 } }, score = 50, feedback = "taster_feedback_tea_matcha_latte", voids = { "taster_coffee", "taster_matcha_solo" } },
	{ requires = { "matcha", "milk" }, ratios = { { "coffee", "==", 0 } }, score = 50, feedback = "taster_feedback_tea_matcha_latte", voids = { "taster_coffee", "taster_matcha_solo" } },
	{ requires = { "tea", "vanilla", "cream" }, ratios = { { "coffee", "==", 0 } }, score = 50, feedback = "taster_feedback_tea_london_fog", voids = { "taster_coffee", "taster_tea_solo" } },
	
	-- Spiced Teas
	{ requires = { "tea", "cinnamon", "cardamom" }, ratios = { { "coffee", "==", 0 } }, score = 45, feedback = "taster_feedback_tea_chai", voids = { "taster_coffee", "taster_tea_solo" } },
	{ requires = { "tea", "clove", "ginger" }, ratios = { { "coffee", "==", 0 } }, score = 45, feedback = "taster_feedback_tea_chai", voids = { "taster_coffee", "taster_tea_solo" } },
	
	-- Hot Toddies
	{ requires = { "tea", "whiskey", "lemon" }, ratios = { { "coffee", "==", 0 } }, score = 45, feedback = "taster_feedback_tea_hot_toddy", voids = { "taster_coffee", "taster_tea_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "tea", "brandy", "honey" }, ratios = { { "coffee", "==", 0 } }, score = 45, feedback = "taster_feedback_tea_hot_toddy", voids = { "taster_coffee", "taster_tea_solo", "taster_feedback_honey_solo" } },

	-- Fruit & Floral Infusions
	{ requires = { "tea", "hibiscus" }, ratios = { { "coffee", "==", 0 } }, score = 35, feedback = "taster_feedback_tea_hibiscus_blend", voids = { "taster_coffee", "taster_tea_solo" } },
	{ requires = { "tea", "lemon", "honey" }, ratios = { { "coffee", "==", 0 } }, score = 40, feedback = "taster_feedback_tea_soothing", voids = { "taster_coffee", "taster_tea_solo" } },
	{ requires = { "matcha", "lemon" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">", 0 } }, score = 40, feedback = "taster_feedback_tea_matcha_lemonade", voids = { "taster_coffee", "taster_matcha_solo" } },
	{ requires = { "tea", "mint" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">", 0 } }, score = 35, feedback = "taster_feedback_tea_moroccan_style", voids = { "taster_coffee", "taster_tea_solo" } },

	-- Tea Penalties (Clashes)
	{ requires = { "tea", "wasabi" }, ratios = { { "coffee", "==", 0 } }, score = -60, feedback = "taster_feedback_tea_wasabi_bad", voids = { "taster_coffee" } },
	{ requires = { "matcha", "cayenne" }, ratios = { { "coffee", "==", 0 } }, score = -50, feedback = "taster_feedback_tea_cayenne_clash", voids = { "taster_coffee" } },

	-- =======================================================================
	-- SECTION 2: HARD PENALTIES & DISASTERS (Score: -100 to -40)
	-- =======================================================================
	
	-- The "Not A Drink" Penalty (If you have NO coffee, NO tea, and NO matcha)
	{ ratios = { { "coffee", "==", 0 }, { "tea", "==", 0 }, { "matcha", "==", 0 } }, score = -100, feedback = "taster_coffee" },
	
	-- Physics / Proportion failures
	{ ratios = { { "dairy", ">=", 0.8 } }, score = -80, feedback = "taster_coffee_alldairy" },
	{ ratios = { { "sugar", ">=", 0.8 } }, score = -80, feedback = "taster_coffee_allsugar" },
	{ ratios = { { "flavor", ">=", 0.8 } }, score = -60, feedback = "taster_coffee_allflavors" },
	{ ratios = { { "cacao", ">=", 0.7 } }, score = -80, feedback = "taster_coffee_allcacao" }, 

	-- Negative Flavor Combinations
	-- Note: The rule `ratios = {{"coffee", ">", 0}}` ensures that "Fruit Teas" 
	-- (from Section 1) aren't accidentally penalized by the "Fruit Coffee" rules.
	{ ratios = { { "fruit", ">=", 0.3 }, { "coffee", ">", 0 } }, forbids = { "orange", "coconut", "pumpkin" }, score = -60, feedback = "taster_coffee_nofruit" },
	
	-- Specific Clashes
	{ requires = { "wasabi" }, score = -75, feedback = "taster_feedback_coffee_wasabi_bad", voids = { "taster_feedback_wasabi_solo" } },
	{ requires = { "lime" }, ratios = { { "coffee", ">", 0 } }, score = -60, feedback = "taster_feedback_espresso_lime_bad", voids = { "taster_feedback_lime_solo" } },
	{ requires = { "lemon" }, ratios = { { "coffee", ">", 0 } }, forbids = { "honey" }, score = -60, feedback = "taster_feedback_espresso_lime_bad", voids = { "taster_feedback_lemon_solo" } },
	{ requires = { "mint", "ginger" }, ratios = { { "coffee", ">", 0 } }, score = -50, feedback = "taster_feedback_ginger_mint_coffee_bad", voids = { "taster_feedback_mint_solo", "taster_feedback_ginger_solo" } },
	{ requires = { "salt" }, forbids = { "caramel", "toffee", "sugar", "milk" }, score = -50, feedback = "taster_feedback_coffee_salt_bad" },
	{ requires = { "cayenne" }, forbids = { "cacao" }, score = -50, feedback = "taster_feedback_coffee_cayenne_bad" },

	-- =======================================================================
	-- SECTION 3: TOP-TIER COFFEE SYNERGIES (Score: +40 to +60)
	-- =======================================================================
	
	-- Seasonal / Specialty Standouts
	{ requires = { "pumpkin", "cinnamon", "coffee" }, ratios = { { "dairy", ">", 0 } }, score = 60, feedback = "taster_feedback_pumpkin_spice", voids = { "taster_feedback_autumn_spice", "taster_coffee_nofruit", "taster_feedback_pumpkin_solo" } },
	{ requires = { "coffee", "cacao", "cinnamon", "cayenne" }, score = 55, feedback = "taster_feedback_mexican_hot_chocolate", voids = { "taster_feedback_mocha", "taster_coffee_cayenne_bad", "taster_feedback_spicy_chocolate" } },
	{ requires = { "coffee", "cardamom" }, ratios = { {"dairy", "==", 0} }, score = 50, feedback = "taster_feedback_turkish_coffee", voids = { "taster_feedback_cardamom_solo" } },
	{ requires = { "coffee", "maple", "whiskey" }, score = 50, feedback = "taster_feedback_lumberjack_coffee", voids = { "taster_feedback_whiskey_solo", "taster_feedback_maple_solo" } },
	
	-- Barista Classics
	{ requires = { "whiskey", "cream" }, ratios = { {"coffee", ">", 0} }, score = 50, feedback = "taster_feedback_coffee_nutty_irish", voids = {"taster_feedback_whiskey_solo"} },
	{ requires = { "turmeric" }, ratios = { { "dairy", ">=", 0.2 } }, score = 45, feedback = "taster_feedback_coffee_golden_milk", voids = {"taster_feedback_turmeric_solo"} },
	{ requires = { "orange", "cacao" }, ratios = { {"coffee", ">", 0} }, score = 45, feedback = "taster_feedback_coffee_orange_mocha", voids = { "taster_feedback_orange_solo", "taster_feedback_mocha", "taster_coffee_nofruit" } },
	{ requires = { "vanilla", "cream" }, ratios = { {"coffee", ">", 0} }, score = 45, feedback = "taster_feedback_affogato", voids = {"taster_feedback_vanilla_solo"} },
	{ requires = { "rum", "coconut" }, ratios = { {"coffee", ">", 0} }, score = 40, feedback = "taster_feedback_coffee_tropical", voids = { "taster_feedback_rum_solo", "taster_feedback_coconut_solo", "taster_coffee_nofruit" } },
	
	-- Dirty Chai (Handles the edge case where the player mixes Coffee AND Tea)
	{ requires = { "tea", "cinnamon", "coffee" }, score = 45, feedback = "taster_feedback_dirty_chai", voids = { "taster_feedback_chai_coffee", "taster_feedback_tea_solo" } },
	
	-- Liqueur Coffees
	{ requires = { "kahlua", "cream" }, score = 40, feedback = "taster_feedback_kahlua_cream", voids = { "taster_feedback_kahlua_solo" } },
	{ requires = { "kahlua", "milk" }, score = 40, feedback = "taster_feedback_kahlua_milk", voids = { "taster_feedback_kahlua_solo" } },
	{ requires = { "amaretto", "almond" }, score = 35, feedback = "taster_feedback_coffee_amaretto_almond", voids = { "taster_feedback_anise_solo", "taster_coffee_nonuts" } },

	-- =======================================================================
	-- SECTION 4: GOOD COFFEE COMBINATIONS (Score: +15 to +30)
	-- =======================================================================
	
	-- Mochas (Requires Coffee & Cacao but limits the cacao so it stays a drink)
	{ requires = { "cacao" }, ratios = { { "cacao", "<", 0.7 }, { "coffee", ">", 0 } }, score = 30, feedback = "taster_feedback_mocha" },
	{ requires = { "bal_cacao" }, ratios = { { "cacao", "<", 0.7 }, { "coffee", ">", 0 } }, score = 30, feedback = "taster_feedback_mocha" },
	{ requires = { "bel_cacao" }, ratios = { { "cacao", "<", 0.7 }, { "coffee", ">", 0 } }, score = 30, feedback = "taster_feedback_mocha" },
	{ requires = { "bog_cacao" }, ratios = { { "cacao", "<", 0.7 }, { "coffee", ">", 0 } }, score = 30, feedback = "taster_feedback_mocha" },
	{ requires = { "dou_cacao" }, ratios = { { "cacao", "<", 0.7 }, { "coffee", ">", 0 } }, score = 30, feedback = "taster_feedback_mocha" },
	{ requires = { "lim_cacao" }, ratios = { { "cacao", "<", 0.7 }, { "coffee", ">", 0 } }, score = 30, feedback = "taster_feedback_mocha" },
	
	-- Tea Blends (If mixed with coffee, or if Section 1 didn't catch a specific combo)
	{ requires = { "tea", "honey" }, score = 25, feedback = "taster_feedback_tea_blend", voids = { "taster_feedback_tea_solo" } },
	{ requires = { "tea", "lemon" }, score = 25, feedback = "taster_feedback_tea_blend", voids = { "taster_feedback_tea_solo", "taster_coffee_nofruit" } },
	{ requires = { "tea", "cream" }, score = 25, feedback = "taster_feedback_tea_blend", voids = { "taster_feedback_tea_solo" } },
	{ requires = { "tea", "milk" }, score = 25, feedback = "taster_feedback_tea_blend", voids = { "taster_feedback_tea_solo" } },
	
	-- Syrups and Additives
	{ requires = { "vanilla", "caramel" }, score = 25, feedback = "taster_feedback_vanilla_sweet", voids = { "taster_feedback_vanilla_solo", "taster_feedback_sugar_caramel" } },
	{ requires = { "vanilla", "maple" }, score = 25, feedback = "taster_feedback_vanilla_sweet", voids = { "taster_feedback_vanilla_solo" } },
	{ requires = { "lemon", "honey" }, score = 25, feedback = "taster_feedback_lemon_honey_coffee", voids = { "taster_feedback_lemon_honey", "taster_feedback_lemon_solo", "taster_feedback_honey_solo", "taster_coffee_nofruit" } },
	{ requires = { "lavender", "honey" }, score = 20, feedback = "taster_feedback_lavender_honey", voids = { "taster_feedback_lavender_solo" } },
	{ requires = { "turmeric", "ginger" }, score = 20, feedback = "taster_feedback_turmeric_ginger", voids = { "taster_feedback_turmeric_solo", "taster_feedback_ginger_solo" } },
	
	-- Mediterranean Spiced Coffees
	{ requires = { "anise", "orange" }, score = 20, feedback = "taster_feedback_mediterranean", voids = { "taster_coffee_nofruit", "taster_feedback_anise_solo" } },
	{ requires = { "anise", "kahlua" }, score = 20, feedback = "taster_feedback_mediterranean", voids = { "taster_feedback_anise_solo" } },
	{ requires = { "anise", "amaretto" }, score = 20, feedback = "taster_feedback_mediterranean", voids = { "taster_feedback_anise_solo" } },
	{ requires = { "anise", "grand_marnier" }, score = 20, feedback = "taster_feedback_mediterranean", voids = { "taster_feedback_anise_solo" } },
	{ requires = { "orange", "kahlua" }, score = 20, feedback = "taster_feedback_mediterranean", voids = { "taster_coffee_nofruit", "taster_feedback_orange_solo" } },
	{ requires = { "orange", "amaretto" }, score = 20, feedback = "taster_feedback_mediterranean", voids = { "taster_coffee_nofruit", "taster_feedback_orange_solo" } },
	{ requires = { "orange", "grand_marnier" }, score = 20, feedback = "taster_feedback_mediterranean", voids = { "taster_coffee_nofruit", "taster_feedback_orange_solo" } },

	-- =======================================================================
	-- SECTION 5: FLAVOR TEXT & SINGLE-INGREDIENT COMMENTS (Score: +0)
	-- =======================================================================
	-- Automatically inherited by the Coffee side from the same dictionary logic.
	-- If nothing above catches, it falls back to the generic flavor text pool.
}