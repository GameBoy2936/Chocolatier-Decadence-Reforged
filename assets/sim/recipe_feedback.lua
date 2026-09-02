--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Recipe Feedback Rules)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2025-2026 Michael Lane.
--]]---------------------------------------------------------------------------

-- This file defines the culinary rule pools used by Teddy Baumeister in the
-- Secret Test Kitchen. It is written for the current EvaluatePlayerRecipe()
-- implementation in sim/recipe.lua and can replace the existing
-- sim/recipe_feedback.lua directly.
--
-- IMPORTANT SCORING NOTES:
--   * recipe.lua begins every original recipe at 140 points.
--   * Every matching rule adds its score, even when its dialogue is voided.
--   * "unique = true" limits dialogue selection only; it does not limit scoring.
--   * Scores here are therefore deliberately conservative.
--
-- PRACTICAL SCORE TARGETS:
--   100-139  Flawed, awkward, or underdeveloped
--   140-164  Sound and commercially workable
--   165-189  Strong, purposeful recipe
--   190-219  Excellent layered recipe
--   220+     Exceptional and intentionally difficult to reach
--
-- SUPPORTED RULE FIELDS:
--   feedback:   Base localization key for Teddy's dialogue.
--   score:      Points added to or removed from recipe quality.
--   requires:   Exact ingredient names that must all be present.
--   forbids:    Exact ingredient names that must all be absent.
--   ratios:     Ingredient-family checks: { "category", "operator", value }.
--   categories: Product categories to which the rule is restricted.
--   unique:     Low-priority dialogue. One valid unique line is selected.
--   voids:      Dialogue keys suppressed when this rule matches.
--
-- The current engine supports these ratio families:
--   cacao, coffee, dairy, flavor, fruit, nut, sugar
--
-- All ingredient names and dialogue keys in this file are validated against
-- the current Reforged data set. No placeholder or missing feedback keys are
-- required by this version.

------------------------------------------------------------------------------
-- CHOCOLATE FACTORY RULES
------------------------------------------------------------------------------

ChocolateEvaluators =
{
	-- =======================================================================
	-- 1. STRUCTURAL FAILURES
	-- =======================================================================
	{ ratios = { { "dairy", ">=", 0.8 } }, score = -60, feedback = "taster_choco_alldairy", voids = { "taster_feedback_butter_solo", "taster_feedback_cream_solo", "taster_feedback_whipped_cream_solo" } },
	{ ratios = { { "sugar", ">=", 0.8 } }, score = -60, feedback = "taster_choco_allsugar", voids = { "taster_feedback_honey_solo", "taster_feedback_toffee_solo" } },
	{ ratios = { { "flavor", ">=", 0.8 } }, score = -55, feedback = "taster_choco_allflavors" },
	{ ratios = { { "coffee", ">=", 0.6 } }, score = -45, feedback = "taster_choco_allcoffee", voids = { "taster_feedback_espresso_solo" } },

	-- =======================================================================
	-- 2. STRONG CLASHES
	-- =======================================================================
	{ requires = { "whiskey", "wasabi" }, score = -35, feedback = "taster_feedback_whiskey_wasabi_bad", voids = { "taster_feedback_wasabi_solo" } },
	{ requires = { "apple", "wasabi" }, score = -28, feedback = "taster_feedback_apple_wasabi_bad", voids = { "taster_feedback_apple_solo", "taster_feedback_wasabi_solo" } },
	{ requires = { "wasabi", "cherry" }, score = -22, feedback = "taster_feedback_wasabi_fruit_bad", voids = { "taster_feedback_wasabi_solo" } },
	{ requires = { "wasabi", "raspberry" }, score = -22, feedback = "taster_feedback_wasabi_fruit_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_raspberry_solo" } },
	{ requires = { "wasabi", "strawberry" }, score = -22, feedback = "taster_feedback_wasabi_fruit_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_strawberry_solo" } },
	{ requires = { "wasabi", "blueberry" }, score = -22, feedback = "taster_feedback_wasabi_fruit_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_blueberry_solo" } },
	{ requires = { "wasabi", "lemon" }, score = -18, feedback = "taster_feedback_wasabi_fruit_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "wasabi", "lime" }, score = -18, feedback = "taster_feedback_wasabi_fruit_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_lime_solo" } },
	{ requires = { "wasabi", "orange" }, score = -18, feedback = "taster_feedback_wasabi_fruit_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_orange_solo" } },
	{ requires = { "anise", "peanut" }, score = -22, feedback = "taster_feedback_anise_peanut_bad", voids = { "taster_feedback_anise_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "lavender", "cayenne" }, score = -18, feedback = "taster_feedback_lavender_cayenne_bad", voids = { "taster_feedback_lavender_solo", "taster_feedback_cayenne_solo" } },
	{ requires = { "lavender", "lime" }, score = -16, feedback = "taster_feedback_lavender_lime_bad", voids = { "taster_feedback_lavender_solo", "taster_feedback_lime_solo" } },
	{ requires = { "currant", "lime" }, score = -14, feedback = "taster_feedback_currant_lime_bad", voids = { "taster_feedback_currant_solo", "taster_feedback_lime_solo" } },
	{ requires = { "matcha", "orange" }, score = -14, feedback = "taster_feedback_matcha_orange_bad", voids = { "taster_feedback_matcha_solo", "taster_feedback_orange_solo" } },
	{ requires = { "turmeric", "mint" }, score = -12, feedback = "taster_feedback_turmeric_mint_bad", voids = { "taster_feedback_turmeric_solo" } },
	{ requires = { "rose" }, ratios = { { "cacao", ">=", 0.6 }, { "dairy", "==", 0 } }, score = -12, feedback = "taster_feedback_dark_rose_bad" },

	-- =======================================================================
	-- 3. SIGNATURE AND PREMIUM PROFILES
	-- =======================================================================
	{ requires = { "cinnamon", "cayenne" }, ratios = { { "cacao", ">", 0 }, { "dairy", "==", 0 } }, score = 24, feedback = "taster_feedback_mesoamerican", voids = { "taster_feedback_cinnamon_solo", "taster_feedback_cayenne_solo", "taster_feedback_spicy_chocolate" } },
	{ requires = { "vanilla", "cayenne" }, forbids = { "cinnamon" }, ratios = { { "cacao", ">", 0 }, { "dairy", "==", 0 } }, score = 18, feedback = "taster_feedback_mesoamerican", voids = { "taster_feedback_vanilla_solo", "taster_feedback_cayenne_solo", "taster_feedback_spicy_chocolate" } },
	{ requires = { "wasabi", "coconut" }, score = 18, feedback = "taster_feedback_wasabi_coconut", voids = { "taster_feedback_wasabi_solo", "taster_feedback_coconut_solo" } },
	{ requires = { "cherry", "whipped_cream" }, ratios = { { "cacao", ">", 0 } }, score = 20, feedback = "taster_feedback_black_forest", voids = { "taster_feedback_whipped_cream_solo", "taster_feedback_spumoni" } },
	{ requires = { "banana", "toffee" }, ratios = { { "dairy", ">=", 0.15 } }, score = 22, feedback = "taster_feedback_banoffee", voids = { "taster_feedback_banana_solo", "taster_feedback_toffee_solo" } },
	{ requires = { "pistachio", "cherry" }, ratios = { { "cacao", ">=", 0.2 } }, score = 18, feedback = "taster_feedback_spumoni" },
	{ requires = { "chestnut", "vanilla" }, ratios = { { "dairy", ">=", 0.2 } }, score = 20, feedback = "taster_feedback_mont_blanc", voids = { "taster_feedback_chestnut_solo", "taster_feedback_vanilla_solo" } },
	{ requires = { "rose", "saffron" }, score = 22, feedback = "taster_feedback_rose_saffron", voids = { "taster_feedback_saffron_solo", "taster_feedback_rose_pistachio", "taster_feedback_rose_raspberry" } },
	{ requires = { "rose", "pistachio" }, score = 20, feedback = "taster_feedback_rose_pistachio", voids = { "taster_feedback_rose_raspberry" } },
	{ requires = { "rose", "raspberry" }, score = 20, feedback = "taster_feedback_rose_raspberry", voids = { "taster_feedback_raspberry_solo" } },
	{ requires = { "salt", "caramel" }, score = 18, feedback = "taster_feedback_salt_sweet", voids = { "taster_feedback_salt_solo" } },
	{ requires = { "whiskey", "caramel" }, score = 18, feedback = "taster_feedback_boozy_caramel" },
	{ requires = { "hazelnut" }, ratios = { { "cacao", ">", 0.2 }, { "dairy", ">=", 0.1 } }, score = 18, feedback = "taster_feedback_gianduja", voids = { "taster_feedback_hazelnut_solo" } },
	{ requires = { "pecan", "butter" }, score = 16, feedback = "taster_feedback_butter_pecan", voids = { "taster_feedback_pecan_solo", "taster_feedback_butter_solo", "taster_feedback_crunchy_smooth" } },
	{ requires = { "banana", "walnut" }, score = 16, feedback = "taster_feedback_banana_walnut", voids = { "taster_feedback_banana_solo", "taster_feedback_walnut_solo" } },
	{ requires = { "maple", "walnut" }, score = 16, feedback = "taster_feedback_maple_walnut", voids = { "taster_feedback_walnut_solo" } },
	{ requires = { "maple", "pecan" }, score = 16, feedback = "taster_feedback_maple_pecan", voids = { "taster_feedback_pecan_solo" } },
	{ requires = { "espresso" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 18, feedback = "taster_feedback_dark_espresso", voids = { "taster_feedback_espresso_solo" } },
	{ requires = { "grand_marnier" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 16, feedback = "taster_feedback_dark_grand_marnier", voids = { "taster_feedback_grand_marnier_solo" } },
	{ requires = { "blackberry" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 14, feedback = "taster_feedback_dark_tart_berry", voids = { "taster_feedback_blackberry_solo" } },
	{ requires = { "raspberry" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 14, feedback = "taster_feedback_dark_tart_berry", voids = { "taster_feedback_raspberry_solo" } },
	{ requires = { "pomegranate" }, ratios = { { "cacao", ">=", 0.6 }, { "dairy", "==", 0 } }, score = 14, feedback = "taster_feedback_dark_pomegranate", voids = { "taster_feedback_pomegranate_solo" } },
	{ requires = { "mango" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 12, feedback = "taster_feedback_dark_mango" },
	{ requires = { "salt" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 12, feedback = "taster_feedback_dark_salt", voids = { "taster_feedback_salt_solo" } },
	{ requires = { "sumac" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 12, feedback = "taster_feedback_sumac_dark", voids = { "taster_feedback_sumac_solo" } },
	{ requires = { "currant" }, ratios = { { "cacao", ">=", 0.5 } }, score = 12, feedback = "taster_feedback_currant_darkchoc", voids = { "taster_feedback_currant_solo" } },

	-- =======================================================================
	-- 4. SUPPORTING PAIRINGS
	-- Most are unique to prevent Teddy from reciting a paragraph of minor notes.
	-- =======================================================================
	{ requires = { "date", "walnut" }, score = 12, feedback = "taster_feedback_stuffed_date", unique = true, voids = { "taster_feedback_date_solo", "taster_feedback_walnut_solo" } },
	{ requires = { "date", "almond" }, score = 12, feedback = "taster_feedback_stuffed_date", unique = true, voids = { "taster_feedback_date_solo", "taster_feedback_almond_solo" } },
	{ requires = { "fig", "brandy" }, score = 12, feedback = "taster_feedback_fig_brandy", unique = true, voids = { "taster_feedback_fig_solo", "taster_feedback_brandy_solo" } },
	{ requires = { "fig", "pistachio" }, score = 10, feedback = "taster_feedback_fig_pistachio", unique = true, voids = { "taster_feedback_fig_solo" } },
	{ requires = { "peanut", "raspberry" }, score = 12, feedback = "taster_feedback_pb_and_j", unique = true, voids = { "taster_feedback_peanut_solo", "taster_feedback_raspberry_solo" } },
	{ requires = { "peanut", "strawberry" }, score = 12, feedback = "taster_feedback_pb_and_j", unique = true, voids = { "taster_feedback_peanut_solo", "taster_feedback_strawberry_solo" } },
	{ requires = { "pomegranate", "pistachio" }, score = 10, feedback = "taster_feedback_pomegranate_pistachio", unique = true, voids = { "taster_feedback_pomegranate_solo" } },
	{ requires = { "hibiscus", "pineapple" }, score = 10, feedback = "taster_feedback_hibiscus_pineapple", unique = true, voids = { "taster_feedback_hibiscus_solo", "taster_feedback_pineapple_solo" } },
	{ requires = { "rose", "cardamom" }, score = 10, feedback = "taster_feedback_rose_cardamom", unique = true, voids = { "taster_feedback_cardamom_solo" } },
	{ requires = { "pumpkin", "cinnamon" }, score = 8, feedback = "taster_feedback_autumn_spice", unique = true, voids = { "taster_feedback_pumpkin_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "pumpkin", "nutmeg" }, score = 8, feedback = "taster_feedback_autumn_spice", unique = true, voids = { "taster_feedback_pumpkin_solo", "taster_feedback_nutmeg_solo" } },
	{ requires = { "pumpkin", "clove" }, score = 8, feedback = "taster_feedback_autumn_spice", unique = true, voids = { "taster_feedback_pumpkin_solo", "taster_feedback_clove_solo" } },
	{ requires = { "star_anise", "cinnamon", "clove" }, score = 12, feedback = "taster_feedback_fivespice", unique = true, voids = { "taster_feedback_star_anise_solo", "taster_feedback_cinnamon_solo", "taster_feedback_clove_solo" } },
	{ requires = { "passionfruit", "mango" }, score = 8, feedback = "taster_feedback_tropical_fruit", unique = true, voids = { "taster_feedback_passionfruit_solo" } },
	{ requires = { "pineapple", "coconut" }, score = 8, feedback = "taster_feedback_tropical_fruit", unique = true, voids = { "taster_feedback_pineapple_solo", "taster_feedback_coconut_solo" } },
	{ requires = { "dragonfruit", "coconut" }, score = 8, feedback = "taster_feedback_tropical_fruit", unique = true, voids = { "taster_feedback_coconut_solo" } },
	{ requires = { "guava", "passionfruit" }, score = 8, feedback = "taster_feedback_tropical_fruit", unique = true, voids = { "taster_feedback_passionfruit_solo" } },
	{ requires = { "blueberry", "raspberry" }, score = 6, feedback = "taster_feedback_berries", unique = true, voids = { "taster_feedback_blueberry_solo", "taster_feedback_raspberry_solo" } },
	{ requires = { "blueberry", "strawberry" }, score = 6, feedback = "taster_feedback_berries", unique = true, voids = { "taster_feedback_blueberry_solo", "taster_feedback_strawberry_solo" } },
	{ requires = { "strawberry", "raspberry" }, score = 6, feedback = "taster_feedback_berries", unique = true, voids = { "taster_feedback_strawberry_solo", "taster_feedback_raspberry_solo" } },
	{ requires = { "cranberry", "orange" }, score = 6, feedback = "taster_feedback_berries", unique = true, voids = { "taster_feedback_orange_solo" } },
	{ requires = { "rhubarb", "strawberry" }, score = 8, feedback = "taster_feedback_berries", unique = true, voids = { "taster_feedback_strawberry_solo" } },
	{ requires = { "blackberry", "lemon" }, score = 8, feedback = "taster_feedback_blackberry_lemon", unique = true, voids = { "taster_feedback_blackberry_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "coconut", "lime" }, score = 8, feedback = "taster_feedback_coconut_lime", unique = true, voids = { "taster_feedback_coconut_solo", "taster_feedback_lime_solo" } },
	{ requires = { "orange", "mango" }, score = 6, feedback = "taster_feedback_orange_mango", unique = true, voids = { "taster_feedback_orange_solo" } },
	{ requires = { "mint", "lime" }, ratios = { { "sugar", ">", 0.15 }, { "dairy", "==", 0 } }, categories = { "infusion", "exotic" }, score = 6, feedback = "taster_feedback_mojito", unique = true, voids = { "taster_feedback_lime_solo" } },
	{ requires = { "kahlua", "cream" }, score = 8, feedback = "taster_feedback_kahlua_cream", unique = true, voids = { "taster_feedback_kahlua_solo", "taster_feedback_cream_solo" } },
	{ requires = { "kahlua", "milk" }, score = 8, feedback = "taster_feedback_kahlua_milk", unique = true, voids = { "taster_feedback_kahlua_solo" } },
	{ requires = { "whiskey", "cherry" }, categories = { "truffle" }, score = 10, feedback = "taster_feedback_whiskey_cherry", unique = true },
	{ requires = { "rum", "raisin" }, score = 10, feedback = "taster_feedback_rum_raisin", unique = true, voids = { "taster_feedback_rum_solo", "taster_feedback_raisin_solo" } },
	{ requires = { "cherry", "amaretto" }, score = 10, feedback = "taster_feedback_amaretto_cherry", unique = true, voids = { "taster_feedback_amaretto_solo" } },
	{ requires = { "apple", "walnut" }, score = 8, feedback = "taster_feedback_apple_walnut", unique = true, voids = { "taster_feedback_apple_solo", "taster_feedback_walnut_solo" } },
	{ requires = { "banana", "caramel" }, score = 8, feedback = "taster_feedback_banana_caramel", unique = true, voids = { "taster_feedback_banana_solo" } },
	{ requires = { "toffee", "walnut" }, score = 8, feedback = "taster_feedback_toffee_nut", unique = true, voids = { "taster_feedback_toffee_solo", "taster_feedback_walnut_solo" } },
	{ requires = { "toffee", "almond" }, score = 8, feedback = "taster_feedback_toffee_nut", unique = true, voids = { "taster_feedback_toffee_solo", "taster_feedback_almond_solo" } },
	{ requires = { "currant", "hazelnut" }, score = 8, feedback = "taster_feedback_currant_hazelnut", unique = true, voids = { "taster_feedback_currant_solo", "taster_feedback_hazelnut_solo" } },
	{ requires = { "almond", "pistachio" }, score = 8, feedback = "taster_feedback_almond_pistachio", unique = true, voids = { "taster_feedback_almond_solo" } },
	{ requires = { "cherry", "currant" }, score = 8, feedback = "taster_feedback_cherry_currant", unique = true, voids = { "taster_feedback_currant_solo" } },
	{ requires = { "cayenne", "honey" }, score = 8, feedback = "taster_feedback_cayenne_honey", unique = true, voids = { "taster_feedback_cayenne_solo", "taster_feedback_honey_solo" } },
	{ requires = { "cayenne", "lime" }, score = 6, feedback = "taster_feedback_cayenne_lime", unique = true, voids = { "taster_feedback_cayenne_solo", "taster_feedback_lime_solo", "taster_feedback_spicy_chocolate" } },
	{ requires = { "sumac", "salt" }, score = 8, feedback = "taster_feedback_sumac_salt", unique = true, voids = { "taster_feedback_sumac_solo", "taster_feedback_salt_solo" } },
	{ requires = { "hibiscus", "mango" }, score = 8, feedback = "taster_feedback_hibiscus_mango", unique = true, voids = { "taster_feedback_hibiscus_solo" } },
	{ requires = { "lavender", "blueberry" }, score = 8, feedback = "taster_feedback_lavender_blueberry", unique = true, voids = { "taster_feedback_lavender_solo", "taster_feedback_blueberry_solo" } },
	{ requires = { "matcha", "honey" }, score = 8, feedback = "taster_feedback_matcha_honey", unique = true, voids = { "taster_feedback_matcha_solo", "taster_feedback_honey_solo" } },
	{ requires = { "lychee", "rose" }, score = 8, feedback = "taster_feedback_rose_lychee", unique = true, voids = { "taster_feedback_lychee_solo" } },
	{ requires = { "caramel", "peanut" }, score = 6, feedback = "taster_feedback_caramel_nuts", unique = true, voids = { "taster_feedback_peanut_solo", "taster_feedback_sugar_caramel" } },
	{ requires = { "caramel", "almond" }, score = 6, feedback = "taster_feedback_caramel_nuts", unique = true, voids = { "taster_feedback_almond_solo", "taster_feedback_sugar_caramel" } },
	{ requires = { "caramel", "hazelnut" }, score = 6, feedback = "taster_feedback_caramel_nuts", unique = true, voids = { "taster_feedback_hazelnut_solo", "taster_feedback_sugar_caramel" } },
	{ requires = { "caramel", "cashew" }, score = 6, feedback = "taster_feedback_caramel_nuts", unique = true, voids = { "taster_feedback_cashew_solo", "taster_feedback_sugar_caramel" } },
	{ requires = { "sesame", "wasabi" }, score = 6, feedback = "taster_feedback_sesame_wasabi", unique = true, voids = { "taster_feedback_sesame_solo", "taster_feedback_wasabi_solo" } },
	{ requires = { "matcha", "milk" }, score = 6, feedback = "taster_feedback_matcha_latte", unique = true, voids = { "taster_feedback_matcha_solo" } },
	{ requires = { "matcha", "cream" }, score = 6, feedback = "taster_feedback_matcha_latte", unique = true, voids = { "taster_feedback_matcha_solo", "taster_feedback_cream_solo" } },
	{ requires = { "sesame" }, ratios = { { "dairy", ">=", 0.1 }, { "dairy", "<=", 0.4 } }, score = 5, feedback = "taster_feedback_sesame_tahini", unique = true, voids = { "taster_feedback_sesame_solo" } },
	{ requires = { "vanilla", "caramel" }, score = 5, feedback = "taster_feedback_vanilla_sweet", unique = true, voids = { "taster_feedback_vanilla_solo" } },
	{ requires = { "vanilla", "maple" }, score = 5, feedback = "taster_feedback_vanilla_sweet", unique = true, voids = { "taster_feedback_vanilla_solo" } },
	{ requires = { "vanilla", "cherry" }, score = 5, feedback = "taster_feedback_vanilla_sweet", unique = true, voids = { "taster_feedback_vanilla_solo" } },
	{ requires = { "peach", "vanilla" }, score = 5, feedback = "taster_feedback_vanilla_sweet", unique = true, voids = { "taster_feedback_vanilla_solo" } },
	{ requires = { "vanilla", "lavender" }, score = 6, feedback = "taster_feedback_lavender_vanilla", unique = true, voids = { "taster_feedback_vanilla_solo", "taster_feedback_lavender_solo" } },
	{ requires = { "vanilla", "rose" }, score = 6, feedback = "taster_feedback_rose_vanilla", unique = true, voids = { "taster_feedback_vanilla_solo" } },
	{ requires = { "star_anise", "orange" }, score = 6, feedback = "taster_feedback_star_anise_orange", unique = true, voids = { "taster_feedback_star_anise_solo", "taster_feedback_orange_solo" } },
	{ requires = { "orange", "salt" }, ratios = { { "sugar", ">=", 0.15 } }, score = 6, feedback = "taster_feedback_salted_citrus", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_salt_solo" } },
	{ requires = { "anise", "orange" }, score = 5, feedback = "taster_feedback_anise_orange", unique = true, voids = { "taster_feedback_anise_solo", "taster_feedback_orange_solo" } },
	{ requires = { "anise", "kahlua" }, score = 4, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_anise_solo", "taster_feedback_kahlua_solo" } },
	{ requires = { "anise", "amaretto" }, score = 4, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_anise_solo", "taster_feedback_amaretto_solo" } },
	{ requires = { "anise", "grand_marnier" }, score = 4, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_anise_solo", "taster_feedback_grand_marnier_solo" } },
	{ requires = { "orange", "kahlua" }, score = 4, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_kahlua_solo" } },
	{ requires = { "orange", "amaretto" }, score = 4, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_amaretto_solo" } },
	{ requires = { "orange", "grand_marnier" }, score = 4, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_grand_marnier_solo" } },
	{ requires = { "tea", "rose" }, score = 6, feedback = "taster_feedback_tea_floral", unique = true, voids = { "taster_feedback_tea_solo" } },
	{ requires = { "tea", "hibiscus" }, score = 6, feedback = "taster_feedback_tea_floral", unique = true, voids = { "taster_feedback_tea_solo", "taster_feedback_hibiscus_solo" } },
	{ requires = { "tea", "cinnamon" }, score = 6, feedback = "taster_feedback_chai", unique = true, voids = { "taster_feedback_tea_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "hibiscus", "ginger" }, score = 6, feedback = "taster_feedback_hibiscus_ginger", unique = true, voids = { "taster_feedback_hibiscus_solo", "taster_feedback_ginger_solo" } },
	{ requires = { "hibiscus", "cinnamon" }, score = 6, feedback = "taster_feedback_hibiscus_cinnamon", unique = true, voids = { "taster_feedback_hibiscus_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "lavender", "honey" }, score = 6, feedback = "taster_feedback_lavender_honey", unique = true, voids = { "taster_feedback_lavender_solo", "taster_feedback_honey_solo" } },
	{ requires = { "lavender", "lemon" }, score = 6, feedback = "taster_feedback_lavender_lemon", unique = true, voids = { "taster_feedback_lavender_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "rose", "strawberry" }, score = 6, feedback = "taster_feedback_rose_strawberry", unique = true, voids = { "taster_feedback_strawberry_solo" } },
	{ requires = { "sumac", "honey" }, score = 6, feedback = "taster_feedback_sumac_honey", unique = true, voids = { "taster_feedback_sumac_solo", "taster_feedback_honey_solo" } },
	{ requires = { "sumac", "cayenne" }, score = 6, feedback = "taster_feedback_sumac_cayenne", unique = true, voids = { "taster_feedback_sumac_solo", "taster_feedback_cayenne_solo" } },
	{ requires = { "lemon", "honey" }, score = 5, feedback = "taster_feedback_lemon_honey", unique = true, voids = { "taster_feedback_lemon_solo", "taster_feedback_honey_solo" } },
	{ requires = { "mint", "caramel" }, score = 4, feedback = "taster_feedback_mint_caramel", unique = true },
	{ requires = { "lemon", "lime" }, score = 4, feedback = "taster_feedback_lemon_lime", unique = true, voids = { "taster_feedback_lemon_solo", "taster_feedback_lime_solo" } },
	{ requires = { "hibiscus", "mint" }, score = 4, feedback = "taster_feedback_hibiscus_mint", unique = true, voids = { "taster_feedback_hibiscus_solo" } },
	{ requires = { "matcha", "ginger" }, score = 4, feedback = "taster_feedback_matcha_ginger", unique = true, voids = { "taster_feedback_matcha_solo", "taster_feedback_ginger_solo" } },
	{ requires = { "lavender", "mint" }, score = 3, feedback = "taster_feedback_lavender_mint", unique = true, voids = { "taster_feedback_lavender_solo" } },
	{ requires = { "apple", "cinnamon" }, score = 6, feedback = "taster_feedback_apple_cinnamon", unique = true, voids = { "taster_feedback_apple_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "pear", "cinnamon" }, score = 6, feedback = "taster_feedback_autumn_spice", unique = true, voids = { "taster_feedback_cinnamon_solo" } },
	{ requires = { "turmeric", "ginger" }, score = 4, feedback = "taster_feedback_turmeric_ginger", unique = true, voids = { "taster_feedback_turmeric_solo", "taster_feedback_ginger_solo" } },
	{ requires = { "anise", "cherry" }, score = 3, feedback = "taster_feedback_anise_cherry", unique = true, voids = { "taster_feedback_anise_solo" } },
	{ requires = { "lemon", "mint" }, score = 3, feedback = "taster_feedback_lemon_mint", unique = true, voids = { "taster_feedback_lemon_solo" } },
	{ requires = { "pineapple", "mint" }, score = 3, feedback = "taster_feedback_pineapple_mint", unique = true, voids = { "taster_feedback_pineapple_solo" } },
	{ requires = { "lemon", "hazelnut" }, score = 3, feedback = "taster_feedback_lemon_hazelnut", unique = true, voids = { "taster_feedback_lemon_solo", "taster_feedback_hazelnut_solo" } },
	{ requires = { "orange", "peanut" }, score = 3, feedback = "taster_feedback_orange_peanut", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "wafer", "hazelnut" }, score = 5, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_hazelnut_solo" } },
	{ requires = { "wafer", "almond" }, score = 5, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_almond_solo" } },
	{ requires = { "butter", "cashew" }, score = 4, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_butter_solo", "taster_feedback_cashew_solo" } },
	{ requires = { "butter", "peanut" }, score = 4, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_butter_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "butter", "hazelnut" }, score = 4, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_butter_solo", "taster_feedback_hazelnut_solo" } },
	{ requires = { "butter", "macadamia" }, score = 4, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_butter_solo" } },
	{ requires = { "butter", "almond" }, score = 4, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_butter_solo", "taster_feedback_almond_solo" } },
	{ requires = { "orange", "hazelnut" }, score = 4, feedback = "taster_feedback_orange_nuts", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_hazelnut_solo" } },
	{ requires = { "orange", "almond" }, score = 4, feedback = "taster_feedback_orange_almond", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_almond_solo" } },
	{ requires = { "sumac", "strawberry" }, score = 4, feedback = "taster_feedback_sumac_berry", unique = true, voids = { "taster_feedback_sumac_solo", "taster_feedback_strawberry_solo" } },
	{ requires = { "sumac", "raspberry" }, score = 4, feedback = "taster_feedback_sumac_berry", unique = true, voids = { "taster_feedback_sumac_solo", "taster_feedback_raspberry_solo" } },
	{ requires = { "sumac", "blueberry" }, score = 4, feedback = "taster_feedback_sumac_berry", unique = true, voids = { "taster_feedback_sumac_solo", "taster_feedback_blueberry_solo" } },
	{ requires = { "sumac", "blackberry" }, score = 4, feedback = "taster_feedback_sumac_berry", unique = true, voids = { "taster_feedback_sumac_solo", "taster_feedback_blackberry_solo" } },
	{ requires = { "matcha", "almond" }, score = 4, feedback = "taster_feedback_matcha_almond", unique = true, voids = { "taster_feedback_matcha_solo", "taster_feedback_almond_solo" } },

	-- =======================================================================
	-- 5. BASE ARCHETYPES AND SIMPLE FALLBACKS
	-- =======================================================================
	{ requires = { "milk" }, ratios = { { "cacao", ">", 0 } }, score = 4, feedback = "taster_feedback_milk_chocolate", unique = true },
	{ ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 8, feedback = "taster_feedback_pure_dark", unique = true },
	{ requires = { "wasabi" }, ratios = { { "cacao", ">", 0 } }, score = 4, feedback = "taster_feedback_spicy_chocolate", unique = true, voids = { "taster_feedback_wasabi_solo" } },
	{ requires = { "cayenne" }, ratios = { { "cacao", ">", 0 } }, score = 4, feedback = "taster_feedback_spicy_chocolate", unique = true, voids = { "taster_feedback_cayenne_solo" } },
	{ requires = { "lemon", "orange" }, score = 0, feedback = "taster_feedback_lemon_orange", unique = true, voids = { "taster_feedback_lemon_solo", "taster_feedback_orange_solo" } },
	{ requires = { "sugar", "caramel" }, score = 0, feedback = "taster_feedback_sugar_caramel", unique = true },
	{ requires = { "sugar", "mint" }, score = 0, feedback = "taster_feedback_sugar_mint", unique = true },
	{ requires = { "sugar", "orange" }, score = 0, feedback = "taster_feedback_sugar_orange", unique = true, voids = { "taster_feedback_orange_solo" } },
	{ requires = { "lemon", "almond" }, score = 0, feedback = "taster_feedback_lemon_almond", unique = true, voids = { "taster_feedback_lemon_solo", "taster_feedback_almond_solo" } },
	{ requires = { "lemon", "peanut" }, score = 0, feedback = "taster_feedback_lemon_peanut", unique = true, voids = { "taster_feedback_lemon_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "sugar", "lemon" }, score = 4, feedback = "taster_feedback_sugar_lemon", unique = true, voids = { "taster_feedback_lemon_solo" } },
}

------------------------------------------------------------------------------
-- COFFEE, TEA, AND OTHER BEVERAGE RULES
------------------------------------------------------------------------------

CoffeeEvaluators =
{
	-- =======================================================================
	-- 1. BEVERAGE IDENTITY AND STRUCTURAL FAILURES
	-- Tea, matcha, cacao drinks, and turmeric drinks remain valid without coffee.
	-- =======================================================================
	{ forbids = { "tea", "earl_grey", "rooibos", "chamomile", "jasmine", "hibiscus", "matcha", "turmeric" }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 } }, categories = { "beverage", "blend" }, score = -70, feedback = "taster_coffee" },
	{ ratios = { { "dairy", ">=", 0.8 } }, score = -55, feedback = "taster_coffee_alldairy", voids = { "taster_feedback_butter_solo", "taster_feedback_cream_solo", "taster_feedback_whipped_cream_solo" } },
	{ ratios = { { "sugar", ">=", 0.8 } }, score = -55, feedback = "taster_coffee_allsugar", voids = { "taster_feedback_honey_solo", "taster_feedback_toffee_solo" } },
	{ ratios = { { "flavor", ">=", 0.8 } }, score = -45, feedback = "taster_coffee_allflavors" },
	{ ratios = { { "cacao", ">=", 0.7 } }, score = -55, feedback = "taster_coffee_allcacao" },

	-- =======================================================================
	-- 2. STRONG CLASHES
	-- =======================================================================
	{ requires = { "wasabi" }, ratios = { { "coffee", ">", 0 } }, score = -40, feedback = "taster_feedback_coffee_wasabi_bad", voids = { "taster_feedback_wasabi_solo" } },
	{ requires = { "lime" }, ratios = { { "coffee", ">", 0 } }, score = -30, feedback = "taster_feedback_espresso_lime_bad", voids = { "taster_feedback_lime_solo" } },
	{ requires = { "lemon" }, forbids = { "honey" }, ratios = { { "coffee", ">", 0 } }, score = -22, feedback = "taster_feedback_espresso_lime_bad", voids = { "taster_feedback_lemon_solo" } },
	{ requires = { "mint", "ginger" }, ratios = { { "coffee", ">", 0 } }, score = -20, feedback = "taster_feedback_ginger_mint_coffee_bad", voids = { "taster_feedback_ginger_solo" } },
	{ requires = { "salt" }, forbids = { "caramel", "toffee", "sugar", "milk", "cream", "whipped_cream", "honey", "maple" }, ratios = { { "coffee", ">", 0 } }, score = -25, feedback = "taster_feedback_coffee_salt_bad", voids = { "taster_feedback_salt_solo" } },
	{ requires = { "tea", "wasabi" }, ratios = { { "coffee", "==", 0 } }, score = -30, feedback = "taster_feedback_tea_wasabi_bad", voids = { "taster_feedback_tea_solo", "taster_feedback_wasabi_solo" } },
	{ requires = { "matcha", "cayenne" }, ratios = { { "coffee", "==", 0 } }, score = -22, feedback = "taster_feedback_tea_cayenne_clash", voids = { "taster_feedback_matcha_solo", "taster_feedback_cayenne_solo" } },

	-- =======================================================================
	-- 3. TEA AND INFUSION SIGNATURES
	-- =======================================================================
	{ requires = { "matcha", "milk" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">", 0 } }, score = 18, feedback = "taster_feedback_tea_matcha_latte", voids = { "taster_feedback_matcha_solo" } },
	{ requires = { "matcha", "cream" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">", 0 } }, score = 16, feedback = "taster_feedback_tea_matcha_latte", voids = { "taster_feedback_matcha_solo", "taster_feedback_cream_solo" } },
	{ requires = { "earl_grey", "vanilla", "cream" }, ratios = { { "coffee", "==", 0 } }, score = 22, feedback = "taster_feedback_tea_london_fog", voids = { "taster_feedback_vanilla_solo", "taster_feedback_cream_solo" } },
	{ requires = { "earl_grey", "vanilla", "milk" }, ratios = { { "coffee", "==", 0 } }, score = 18, feedback = "taster_feedback_tea_london_fog", voids = { "taster_feedback_vanilla_solo" } },
	{ requires = { "tea", "cinnamon", "milk" }, ratios = { { "coffee", "==", 0 } }, score = 18, feedback = "taster_feedback_tea_chai", voids = { "taster_feedback_tea_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "tea", "cinnamon", "cream" }, ratios = { { "coffee", "==", 0 } }, score = 18, feedback = "taster_feedback_tea_chai", voids = { "taster_feedback_tea_solo", "taster_feedback_cinnamon_solo", "taster_feedback_cream_solo" } },
	{ requires = { "tea", "whiskey", "honey" }, ratios = { { "coffee", "==", 0 } }, score = 18, feedback = "taster_feedback_tea_hot_toddy", voids = { "taster_feedback_tea_solo", "taster_feedback_honey_solo" } },
	{ requires = { "chamomile", "honey" }, ratios = { { "coffee", "==", 0 } }, score = 14, feedback = "taster_feedback_tea_soothing", voids = { "taster_feedback_honey_solo" } },
	{ requires = { "tea", "mint" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">", 0 } }, score = 12, feedback = "taster_tea_moroccan_style", voids = { "taster_feedback_tea_solo" } },
	{ requires = { "hibiscus", "tea" }, ratios = { { "coffee", "==", 0 } }, score = 12, feedback = "taster_feedback_tea_hibiscus_blend", voids = { "taster_feedback_hibiscus_solo", "taster_feedback_tea_solo" } },
	{ requires = { "tea", "rose" }, ratios = { { "coffee", "==", 0 } }, score = 10, feedback = "taster_feedback_tea_floral", voids = { "taster_feedback_tea_solo" } },
	{ requires = { "tea", "lavender" }, ratios = { { "coffee", "==", 0 } }, score = 10, feedback = "taster_feedback_tea_floral", voids = { "taster_feedback_tea_solo", "taster_feedback_lavender_solo" } },
	{ requires = { "tea", "jasmine" }, ratios = { { "coffee", "==", 0 } }, score = 10, feedback = "taster_feedback_tea_floral", voids = { "taster_feedback_tea_solo" } },
	{ requires = { "tea", "honey" }, ratios = { { "coffee", "==", 0 } }, score = 8, feedback = "taster_feedback_tea_blend", unique = true, voids = { "taster_feedback_tea_solo", "taster_feedback_honey_solo" } },
	{ requires = { "tea", "lemon" }, ratios = { { "coffee", "==", 0 } }, score = 8, feedback = "taster_feedback_tea_blend", unique = true, voids = { "taster_feedback_tea_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "tea", "cream" }, ratios = { { "coffee", "==", 0 } }, score = 8, feedback = "taster_feedback_tea_blend", unique = true, voids = { "taster_feedback_tea_solo", "taster_feedback_cream_solo" } },
	{ requires = { "tea", "milk" }, ratios = { { "coffee", "==", 0 } }, score = 8, feedback = "taster_feedback_tea_blend", unique = true, voids = { "taster_feedback_tea_solo" } },
	{ requires = { "rooibos", "vanilla" }, ratios = { { "coffee", "==", 0 } }, score = 8, feedback = "taster_feedback_tea_blend", unique = true, voids = { "taster_feedback_vanilla_solo" } },
	{ requires = { "lemongrass", "ginger" }, ratios = { { "coffee", "==", 0 } }, score = 8, feedback = "taster_feedback_tea_soothing", unique = true, voids = { "taster_feedback_ginger_solo" } },
	{ requires = { "matcha", "lemon" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">", 0 } }, score = 12, feedback = "taster_feedback_tea_matcha_lemonade", voids = { "taster_feedback_matcha_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "matcha", "yuzu" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">", 0 } }, score = 12, feedback = "taster_feedback_tea_matcha_lemonade", voids = { "taster_feedback_matcha_solo" } },
	{ requires = { "tea", "cinnamon" }, ratios = { { "coffee", ">", 0 } }, score = 18, feedback = "taster_feedback_dirty_chai", voids = { "taster_feedback_tea_solo", "taster_feedback_cinnamon_solo" } },

	-- =======================================================================
	-- 4. COFFEE SIGNATURES
	-- =======================================================================
	{ requires = { "ice_cream" }, ratios = { { "coffee", ">", 0 } }, score = 22, feedback = "taster_feedback_affogato" },
	{ requires = { "whiskey", "cream" }, ratios = { { "coffee", ">", 0 } }, score = 20, feedback = "taster_feedback_coffee_nutty_irish", voids = { "taster_feedback_cream_solo" } },
	{ requires = { "orange" }, ratios = { { "coffee", ">", 0 }, { "cacao", ">", 0 } }, score = 18, feedback = "taster_feedback_coffee_orange_mocha", voids = { "taster_feedback_orange_solo", "taster_feedback_mocha" } },
	{ requires = { "rum", "coconut" }, ratios = { { "coffee", ">", 0 } }, score = 16, feedback = "taster_feedback_coffee_tropical", voids = { "taster_feedback_rum_solo", "taster_feedback_coconut_solo" } },
	{ requires = { "cinnamon", "cayenne" }, ratios = { { "coffee", ">", 0 }, { "cacao", ">", 0 } }, score = 20, feedback = "taster_feedback_mesoamerican", voids = { "taster_feedback_cinnamon_solo", "taster_feedback_cayenne_solo", "taster_feedback_mocha" } },
	{ requires = { "pumpkin", "cinnamon" }, ratios = { { "coffee", ">", 0 }, { "dairy", ">", 0 } }, score = 16, feedback = "taster_feedback_autumn_spice", voids = { "taster_feedback_pumpkin_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "kahlua", "cream" }, ratios = { { "coffee", ">", 0 } }, score = 14, feedback = "taster_feedback_kahlua_cream", voids = { "taster_feedback_kahlua_solo", "taster_feedback_cream_solo" } },
	{ requires = { "kahlua", "milk" }, ratios = { { "coffee", ">", 0 } }, score = 14, feedback = "taster_feedback_kahlua_milk", voids = { "taster_feedback_kahlua_solo" } },
	{ requires = { "amaretto", "almond" }, ratios = { { "coffee", ">", 0 } }, score = 12, feedback = "taster_feedback_coffee_amaretto_almond", voids = { "taster_feedback_amaretto_solo", "taster_feedback_almond_solo" } },
	{ ratios = { { "coffee", ">", 0 }, { "cacao", ">", 0 }, { "cacao", "<", 0.7 } }, score = 12, feedback = "taster_feedback_mocha" },
	{ requires = { "lemon", "honey" }, ratios = { { "coffee", ">", 0 } }, score = 8, feedback = "taster_feedback_lemon_honey_coffee", voids = { "taster_feedback_lemon_solo", "taster_feedback_honey_solo" } },

	-- =======================================================================
	-- 5. SUPPORTING BEVERAGE PAIRINGS
	-- =======================================================================
	{ requires = { "vanilla", "caramel" }, score = 8, feedback = "taster_feedback_vanilla_sweet", unique = true, voids = { "taster_feedback_vanilla_solo" } },
	{ requires = { "vanilla", "maple" }, score = 8, feedback = "taster_feedback_vanilla_sweet", unique = true, voids = { "taster_feedback_vanilla_solo" } },
	{ requires = { "anise" }, ratios = { { "coffee", ">", 0 } }, score = 6, feedback = "taster_feedback_anise_coffee", unique = true, voids = { "taster_feedback_anise_solo" } },
	{ requires = { "turmeric" }, ratios = { { "coffee", ">", 0 }, { "dairy", ">=", 0.2 } }, score = 8, feedback = "taster_feedback_coffee_golden_milk", unique = true, voids = { "taster_feedback_turmeric_solo" } },
	{ requires = { "lavender", "honey" }, score = 5, feedback = "taster_feedback_lavender_honey", unique = true, voids = { "taster_feedback_lavender_solo", "taster_feedback_honey_solo" } },
	{ requires = { "turmeric", "ginger" }, score = 5, feedback = "taster_feedback_turmeric_ginger", unique = true, voids = { "taster_feedback_turmeric_solo", "taster_feedback_ginger_solo" } },
	{ requires = { "anise", "orange" }, score = 5, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_anise_solo", "taster_feedback_orange_solo" } },
	{ requires = { "anise", "kahlua" }, score = 5, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_anise_solo", "taster_feedback_kahlua_solo" } },
	{ requires = { "anise", "amaretto" }, score = 5, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_anise_solo", "taster_feedback_amaretto_solo" } },
	{ requires = { "anise", "grand_marnier" }, score = 5, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_anise_solo", "taster_feedback_grand_marnier_solo" } },
	{ requires = { "orange", "kahlua" }, score = 5, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_kahlua_solo" } },
	{ requires = { "orange", "amaretto" }, score = 5, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_amaretto_solo" } },
	{ requires = { "orange", "grand_marnier" }, score = 5, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_grand_marnier_solo" } },
	{ requires = { "banana", "caramel" }, score = 5, feedback = "taster_feedback_banana_caramel", unique = true, voids = { "taster_feedback_banana_solo" } },
	{ requires = { "rum", "raisin" }, score = 5, feedback = "taster_feedback_rum_raisin", unique = true, voids = { "taster_feedback_rum_solo", "taster_feedback_raisin_solo" } },
	{ requires = { "cherry", "amaretto" }, score = 5, feedback = "taster_feedback_amaretto_cherry", unique = true, voids = { "taster_feedback_amaretto_solo" } },
	{ requires = { "coconut", "lime" }, score = 5, feedback = "taster_feedback_coconut_lime", unique = true, voids = { "taster_feedback_coconut_solo", "taster_feedback_lime_solo" } },
	{ requires = { "hibiscus", "mango" }, score = 5, feedback = "taster_feedback_hibiscus_mango", unique = true, voids = { "taster_feedback_hibiscus_solo" } },
	{ requires = { "lavender", "blueberry" }, score = 5, feedback = "taster_feedback_lavender_blueberry", unique = true, voids = { "taster_feedback_lavender_solo", "taster_feedback_blueberry_solo" } },
	{ requires = { "matcha", "honey" }, score = 5, feedback = "taster_feedback_matcha_honey", unique = true, voids = { "taster_feedback_matcha_solo", "taster_feedback_honey_solo" } },
	{ requires = { "apple", "cinnamon" }, score = 5, feedback = "taster_feedback_apple_cinnamon", unique = true, voids = { "taster_feedback_apple_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "pear", "cinnamon" }, score = 5, feedback = "taster_feedback_autumn_spice", unique = true, voids = { "taster_feedback_cinnamon_solo" } },
	{ requires = { "wafer", "hazelnut" }, score = 5, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_hazelnut_solo" } },
	{ requires = { "wafer", "almond" }, score = 5, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_almond_solo" } },
	{ requires = { "peach", "vanilla" }, score = 5, feedback = "taster_feedback_vanilla_sweet", unique = true, voids = { "taster_feedback_vanilla_solo" } },
}

------------------------------------------------------------------------------
-- SHARED SINGLE-INGREDIENT OBSERVATIONS
------------------------------------------------------------------------------

-- These zero-point fallbacks give Teddy something ingredient-specific to say
-- when no stronger observation is available. The same rule tables are safe to
-- use in both evaluator pools because recipe.lua never mutates a rule.

local SoloFeedbackRules =
{
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
	{ requires = { "cayenne" }, score = 0, feedback = "taster_feedback_cayenne_solo", unique = true },
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
	{ requires = { "matcha" }, score = 0, feedback = "taster_feedback_matcha_solo", unique = true },
	{ requires = { "nutmeg" }, score = 0, feedback = "taster_feedback_nutmeg_solo", unique = true },
	{ requires = { "orange" }, score = 0, feedback = "taster_feedback_orange_solo", unique = true },
	{ requires = { "passionfruit" }, score = 0, feedback = "taster_feedback_passionfruit_solo", unique = true },
	{ requires = { "peanut" }, score = 0, feedback = "taster_feedback_peanut_solo", unique = true },
	{ requires = { "pecan" }, score = 0, feedback = "taster_feedback_pecan_solo", unique = true },
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

for _, rule in ipairs(SoloFeedbackRules) do
	table.insert(ChocolateEvaluators, rule)
	table.insert(CoffeeEvaluators, rule)
end

------------------------------------------------------------------------------
-- OPTIONAL DATA VALIDATION
------------------------------------------------------------------------------

-- This check is deliberately defensive. It runs only when both the ingredient
-- registry and localization system are already available at load time.
-- Modders may also call ValidateRecipeFeedbackRules() manually from the IDE.

function ValidateRecipeFeedbackRules()
	local errorCount = 0
	local validOperators = { [">"] = true, ["<"] = true, ["=="] = true, [">="] = true, ["<="] = true }
	local validRatios = { cacao = true, coffee = true, dairy = true, flavor = true, fruit = true, nut = true, sugar = true }
	local validCategories = { bar = true, beverage = true, infusion = true, truffle = true, blend = true, exotic = true }
	local pools =
	{
		ChocolateEvaluators = ChocolateEvaluators,
		CoffeeEvaluators = CoffeeEvaluators,
	}

	local function Report(message)
		errorCount = errorCount + 1
		if type(DebugOut) == "function" then
			DebugOut("ERROR", message)
		end
	end

	local function FeedbackExists(key)
		if type(GetReplacedString) ~= "function" then return true end
		if HasString(key) then return true end
		if HasString(key .. "_1") then return true end
		return false
	end

	local function ValidateIngredientList(poolName, ruleIndex, fieldName, values)
		for _, ingredientName in ipairs(values or {}) do
			if type(_AllIngredients) == "table" and not _AllIngredients[ingredientName] then
				Report(string.format("%s rule %d references unknown ingredient '%s' in %s.",
					poolName, ruleIndex, tostring(ingredientName), fieldName))
			end
		end
	end

	for poolName, rules in pairs(pools) do
		for ruleIndex, rule in ipairs(rules) do
			if type(rule.score) ~= "number" then
				Report(string.format("%s rule %d has a non-numeric score.", poolName, ruleIndex))
			end

			if type(rule.feedback) ~= "string" or rule.feedback == "" then
				Report(string.format("%s rule %d has no feedback key.", poolName, ruleIndex))
			elseif not FeedbackExists(rule.feedback) then
				Report(string.format("%s rule %d references missing feedback key '%s'.",
					poolName, ruleIndex, rule.feedback))
			end

			ValidateIngredientList(poolName, ruleIndex, "requires", rule.requires)
			ValidateIngredientList(poolName, ruleIndex, "forbids", rule.forbids)

			for _, categoryName in ipairs(rule.categories or {}) do
				if not validCategories[categoryName] then
					Report(string.format("%s rule %d references unknown product category '%s'.",
						poolName, ruleIndex, tostring(categoryName)))
				end
			end

			for _, ratio in ipairs(rule.ratios or {}) do
				local ratioName = ratio[1]
				local operator = ratio[2]
				local value = ratio[3]

				if not validRatios[ratioName] then
					Report(string.format("%s rule %d references unsupported ratio '%s'.",
						poolName, ruleIndex, tostring(ratioName)))
				end

				if not validOperators[operator] then
					Report(string.format("%s rule %d uses unsupported operator '%s'.",
						poolName, ruleIndex, tostring(operator)))
				end

				if type(value) ~= "number" then
					Report(string.format("%s rule %d has a non-numeric ratio value.",
						poolName, ruleIndex))
				end
			end

			for _, voidKey in ipairs(rule.voids or {}) do
				if not FeedbackExists(voidKey) then
					Report(string.format("%s rule %d voids missing feedback key '%s'.",
						poolName, ruleIndex, tostring(voidKey)))
				end
			end
		end
	end

	if type(DebugOut) == "function" then
		if errorCount == 0 then
			DebugOut("LOAD", "Recipe feedback validation complete. No rule errors detected.")
		else
			DebugOut("ERROR", string.format("Recipe feedback validation found %d error(s).", errorCount))
		end
	end

	return errorCount
end

