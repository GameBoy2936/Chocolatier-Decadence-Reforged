--[[--------------------------------------------------------------------------
	Chocolatier Three: User-Generated Recipe Feedback Table
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

-- INSTRUCTIONS:
-- This file contains the rule sets that Teddy Baumeister uses to evaluate
-- player-created recipes in the Secret Test Kitchen.
-- The system iterates through these rules and, if the conditions are met,
-- applies a score modifier and adds the specified feedback to a list.

-- Each entry is a rule with the following properties:
--	feedback: The base string key for the taster's dialogue. Can be a simple
--            string or a table for weighted random responses.
--	score:    The points to add or subtract from the recipe's quality score.
--            (A base recipe starts at 140 points).
--
--  CONDITIONS (ALL must be met for the rule to trigger):
--	requires:   (Optional) A list of ingredient names that MUST be in the recipe.
--              Example: { requires = { "salt", "caramel" } }
--	forbids:    (Optional) A list of ingredient names that MUST NOT be in the recipe.
--              Example: { forbids = { "wasabi" } }
--	ratios:     (Optional) A list of category ratio checks.
--              Example: { ratios = { { "dairy", ">", 0.7 } } } -- (if >70% of ingredients are dairy)
--	ing_ratios: (Optional) A list of specific ingredient ratio checks.
--              Example: { ing_ratios = { { "vanilla", ">=", 0.5 } } } -- (if >=50% of ingredients are vanilla)
--	categories: (Optional) A list of product category names this rule applies to.
--              If omitted, applies to all categories in the evaluator list.
--              Example: { categories = { "truffle", "exotic" } }
--
--  FEEDBACK CONTROL:
--	unique:   (Optional) If true, this feedback is low-priority "flavor text" and
--            will only be chosen if no other, more specific feedback is triggered.
--	voids:    (Optional) A list of other feedback keys that this rule should
--            override and prevent from being displayed.
--            Example: { voids = { "taster_feedback_vanilla_nut" } }
--
--  WEIGHTED FEEDBACK EXAMPLE:
--  To give different dialogue variations different chances of appearing,
--  use a table for the 'feedback' property. The number of weights must
--  match the number of numbered string variations in strings.xml.
--
--  feedback = { key = "my_feedback_key", weights = { 75, 25 } }
--  This would give "my_feedback_key_1" a 75% chance and "my_feedback_key_2" a 25% chance.
--

------------------------------------------------------------------------------
-- CHOCOLATE EVALUATORS
------------------------------------------------------------------------------

ChocolateEvaluators =
{
    -- === SECTION 1: HARD PENALTIES & RATIO CHECKS ===
    { ratios = { { "dairy", ">=", 0.8 } }, score = -80, feedback = "taster_choco_alldairy" },
    { ratios = { { "sugar", ">=", 0.8 } }, score = -80, feedback = "taster_choco_allsugar" },
    { ratios = { { "flavor", ">=", 0.8 } }, score = -80, feedback = "taster_choco_allflavors" },
    { ratios = { { "coffee", ">=", 0.7 } }, score = -60, feedback = "taster_choco_allcoffee" },

    -- === SECTION 2: NEGATIVE FLAVOR COMBINATIONS ===
	{ requires = { "wasabi", "cherry" }, score = -50, feedback = "taster_feedback_wasabi_fruit_bad" },
	{ requires = { "wasabi", "lemon" }, score = -50, feedback = "taster_feedback_wasabi_fruit_bad" },
	{ requires = { "wasabi", "lime" }, score = -50, feedback = "taster_feedback_wasabi_fruit_bad" },
	{ requires = { "wasabi", "raspberry" }, score = -50, feedback = "taster_feedback_wasabi_fruit_bad" },
    { requires = { "whiskey", "wasabi" }, score = -40, feedback = "taster_feedback_whiskey_wasabi_bad" },
	{ requires = { "matcha", "orange" }, score = -40, feedback = "taster_feedback_matcha_orange_bad" },
	{ requires = { "lemon", "dairy" }, score = -20, feedback = "taster_feedback_lemon_dairy_bad" },
	{ requires = { "turmeric", "mint" }, score = -30, feedback = "taster_feedback_turmeric_mint_bad" },
	{ requires = { "lavender", "pepper" }, score = -30, feedback = "taster_feedback_lavender_pepper_bad" },
	{ requires = { "turmeric", "mint" }, score = -30, feedback = "taster_feedback_turmeric_mint_bad" },
	{ requires = { "ginger", "mint" }, score = -25, feedback = "taster_feedback_ginger_mint_bad" },
	{ requires = { "lime", "dairy" }, score = -20, feedback = "taster_feedback_lemon_dairy_bad" },
	{ requires = { "orange", "dairy" }, score = -20, feedback = "taster_feedback_lemon_dairy_bad" },
	{ requires = { "sumac", "dairy" }, score = -20, feedback = "taster_feedback_sumac_dairy_bad" },

    -- === SECTION 3: TOP-TIER & "SECRET" COMBINATIONS ===
	{ requires = { "salt", "caramel" }, score = 40, feedback = "taster_feedback_salt_sweet", voids = {"taster_feedback_vanilla_sweet"} },
	{ requires = { "salt", "maple" }, score = 40, feedback = "taster_feedback_salt_sweet", voids = {"taster_feedback_vanilla_sweet"} },
	{ requires = { "pecan", "butter" }, score = 40, feedback = "taster_feedback_butter_pecan", voids = {"taster_feedback_crunchy_smooth"} },
	{ requires = { "espresso" }, ratios = { { "dairy", ">", 0.2 } }, forbids = { "fruit" }, score = 40, feedback = "taster_feedback_affogato" },
    { requires = { "cinnamon", "pepper" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 40, feedback = "taster_feedback_mesoamerican" },
    { requires = { "vanilla", "pepper" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 40, feedback = "taster_feedback_mesoamerican" },
	{ requires = { "apple", "cinnamon" }, score = 40, feedback = "taster_feedback_apple_cinnamon", voids = {"taster_feedback_autumn_spice"} },
	{ requires = { "banana", "walnut" }, score = 40, feedback = "taster_feedback_banana_walnut" },
	{ requires = { "cinnamon", "pumpkin" }, score = 35, feedback = "taster_feedback_autumn_spice" },
	{ requires = { "nutmeg", "pumpkin" }, score = 35, feedback = "taster_feedback_autumn_spice" },
	{ requires = { "clove", "pumpkin" }, score = 35, feedback = "taster_feedback_autumn_spice" },
	{ requires = { "cinnamon", "clove" }, score = 30, feedback = "taster_feedback_autumn_spice" },
	{ requires = { "fig", "brandy" }, score = 35, feedback = "taster_feedback_fig_brandy" },
	{ requires = { "blackberry", "lemon" }, score = 35, feedback = "taster_feedback_blackberry_lemon" },
	{ requires = { "hazelnut" }, ratios = { { "cacao", ">", 0.3 }, { "dairy", ">=", 0.2 } }, score = 35, feedback = "taster_feedback_gianduja" },
    { requires = { "banana", "toffee" }, ratios = { { "dairy", ">=", 0.15 } }, score = 35, feedback = "taster_feedback_banoffee" },
    { requires = { "pistachio", "cherry" }, ratios = { { "cacao", ">=", 0.2 } }, score = 35, feedback = "taster_feedback_spumoni" },
	
    -- === SECTION 4: GOOD & COMPLEMENTARY COMBINATIONS ===
	{ requires = { "kahlua", "cream" }, score = 30, feedback = "taster_feedback_kahlua_cream" },
	{ requires = { "kahlua", "milk" }, score = 30, feedback = "taster_feedback_kahlua_milk" },
	{ requires = { "blueberry", "raspberry" }, score = 30, feedback = "taster_feedback_berries" },
	{ requires = { "blueberry", "strawberry" }, score = 30, feedback = "taster_feedback_berries" },
	{ requires = { "strawberry", "raspberry" }, score = 30, feedback = "taster_feedback_berries" },
	{ requires = { "banana", "caramel" }, score = 30, feedback = "taster_feedback_banana_caramel" },
	{ requires = { "toffee", "walnut" }, score = 30, feedback = "taster_feedback_toffee_nut" },
	{ requires = { "toffee", "almond" }, score = 30, feedback = "taster_feedback_toffee_nut" },
	{ requires = { "passionfruit", "mango" }, score = 30, feedback = "taster_feedback_tropical_fruit" },
	{ requires = { "pineapple", "coconut" }, score = 30, feedback = "taster_feedback_tropical_fruit" },
	{ requires = { "mango" }, ratios = { { "cacao", "=>", 0.5 }, { "dairy", "==", 0 } }, score = 30, feedback = "taster_feedback_mango_darkchoc" },
    { requires = { "star_anise", "cinnamon", "clove" }, score = 30, feedback = "taster_feedback_fivespice" },
    { requires = { "whiskey", "cherry" }, categories = { "truffle" }, score = 30, feedback = "taster_feedback_whiskey_cherry" },
    { requires = { "mint", "lime" }, ratios = { { "sugar", ">", 0.15 } }, forbids = { "dairy" }, score = 30, feedback = "taster_feedback_mojito" },
    { requires = { "fig", "pistachio" }, score = 30, feedback = "taster_feedback_fig_pistachio" },
	{ requires = { "caramel", "peanut" }, score = 25, feedback = "taster_feedback_caramel_nuts" },
	{ requires = { "caramel", "almond" }, score = 25, feedback = "taster_feedback_caramel_nuts" },
	{ requires = { "caramel", "hazelnut" }, score = 25, feedback = "taster_feedback_caramel_nuts" },
	{ requires = { "caramel", "cashew" }, score = 25, feedback = "taster_feedback_caramel_nuts" },
	{ requires = { "cherry", "whipped_cream" }, score = 25, feedback = "taster_feedback_black_forest" },
	{ requires = { "sesame", "wasabi" }, score = 25, feedback = "taster_feedback_sesame_wasabi" },
	{ requires = { "rum", "raisin" }, score = 25, feedback = "taster_feedback_rum_raisin" },
	{ requires = { "star_anise", "orange" }, score = 25, feedback = "taster_feedback_star_anise_orange" },
	{ requires = { "matcha", "milk" }, score = 25, feedback = "taster_feedback_matcha_latte" },
	{ requires = { "matcha", "cream" }, score = 25, feedback = "taster_feedback_matcha_latte" },
    { requires = { "sesame" }, ratios = { { "dairy", ">=", 0.1 }, { "dairy", "<=", 0.4 } }, score = 25, feedback = "taster_feedback_sesame_tahini" },
    { ratios = { { "dairy", ">=", 0.4 }, { "sugar", ">=", 0.3 }, { "cacao", "<=", 0.05 } }, score = 25, feedback = "taster_feedback_white_chocolate" },
    { requires = { "orange", "salt" }, ratios = { { "sugar", ">=", 0.15 } }, score = 25, feedback = "taster_feedback_salted_citrus" },
	
    -- === SECTION 5: INTERESTING & SUBTLE COMBINATIONS ===
	{ requires = { "vanilla", "caramel" }, score = 20, feedback = "taster_feedback_vanilla_sweet", voids = {"taster_feedback_sugar_caramel"} },
	{ requires = { "vanilla", "maple" }, score = 20, feedback = "taster_feedback_vanilla_sweet" },
	{ requires = { "vanilla", "cherry" }, score = 20, feedback = "taster_feedback_vanilla_sweet" },
	{ requires = { "lemon", "honey" }, score = 20, feedback = "taster_feedback_lemon_honey" },
	{ requires = { "mint", "caramel" }, score = 20, feedback = "taster_feedback_mint_caramel" },
	{ requires = { "anise", "orange" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "anise", "kahlua" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "anise", "amaretto" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "anise", "grand_marnier" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "orange", "kahlua" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "orange", "amaretto" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "orange", "grand_marnier" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "tea", "cinnamon" }, score = 20, feedback = "taster_feedback_chai" },
	{ requires = { "lemon", "lime" }, score = 20, feedback = "taster_feedback_lemon_lime" },
	{ requires = { "lavender", "honey" }, score = 20, feedback = "taster_feedback_lavender_honey" },
	{ requires = { "lychee", "rose" }, score = 20, feedback = "taster_feedback_lychee_rose" },
	{ requires = { "apple", "walnut" }, score = 20, feedback = "taster_feedback_apple_walnut" },
	{ requires = { "orange", "hazelnut" }, score = 15, feedback = "taster_feedback_orange_nuts" },
	{ requires = { "orange", "almond" }, score = 15, feedback = "taster_feedback_orange_almond" },
	{ requires = { "butter", "cashew" }, score = 15, feedback = "taster_feedback_crunchy_smooth" },
    { requires = { "butter", "peanut" }, score = 15, feedback = "taster_feedback_crunchy_smooth" },
    { requires = { "butter", "hazelnut" }, score = 15, feedback = "taster_feedback_crunchy_smooth" },
    { requires = { "butter", "macadamia" }, score = 15, feedback = "taster_feedback_crunchy_smooth" },
    { requires = { "butter", "almond" }, score = 15, feedback = "taster_feedback_crunchy_smooth" },
	{ requires = { "sugar", "lemon" }, score = 15, feedback = "taster_feedback_sugar_lemon", unique = true },
	{ requires = { "turmeric", "ginger" }, score = 15, feedback = "taster_feedback_turmeric_ginger" },
	{ requires = { "sumac", "strawberry" }, score = 15, feedback = "taster_feedback_sumac_berry" },
	{ requires = { "sumac", "raspberry" }, score = 15, feedback = "taster_feedback_sumac_berry" },
	{ requires = { "sumac", "blueberry" }, score = 15, feedback = "taster_feedback_sumac_berry" },
	{ requires = { "sumac", "blackberry" }, score = 15, feedback = "taster_feedback_sumac_berry" },
	{ requires = { "anise", "cherry" }, score = 10, feedback = "taster_feedback_anise_cherry" },
	{ requires = { "lemon", "mint" }, score = 10, feedback = "taster_feedback_lemon_mint" },
	{ requires = { "pineapple", "mint" }, score = 10, feedback = "taster_feedback_pineapple_mint" },
	{ requires = { "wasabi", "cacao" }, score = 5, feedback = "taster_feedback_spicy_chocolate", unique = true },
	{ requires = { "wasabi", "bal_cacao" }, score = 5, feedback = "taster_feedback_spicy_chocolate", unique = true },
	{ requires = { "wasabi", "bel_cacao" }, score = 5, feedback = "taster_feedback_spicy_chocolate", unique = true },
	{ requires = { "wasabi", "bog_cacao" }, score = 5, feedback = "taster_feedback_spicy_chocolate", unique = true },
	{ requires = { "wasabi", "dou_cacao" }, score = 5, feedback = "taster_feedback_spicy_chocolate", unique = true },
	{ requires = { "wasabi", "lim_cacao" }, score = 5, feedback = "taster_feedback_spicy_chocolate", unique = true },
	{ requires = { "pepper", "cacao" }, score = 5, feedback = "taster_feedback_spicy_chocolate", unique = true },
	{ requires = { "pepper", "bal_cacao" }, score = 5, feedback = "taster_feedback_spicy_chocolate", unique = true },
	{ requires = { "pepper", "bel_cacao" }, score = 5, feedback = "taster_feedback_spicy_chocolate", unique = true },
	{ requires = { "pepper", "bog_cacao" }, score = 5, feedback = "taster_feedback_spicy_chocolate", unique = true },
	{ requires = { "pepper", "dou_cacao" }, score = 5, feedback = "taster_feedback_spicy_chocolate", unique = true },
	{ requires = { "pepper", "lim_cacao" }, score = 5, feedback = "taster_feedback_spicy_chocolate", unique = true },
	{ requires = { "lemon", "hazelnut" }, score = 5, feedback = "taster_feedback_lemon_hazelnut" },
	{ requires = { "orange", "peanut" }, score = 5, feedback = "taster_feedback_orange_peanut" },

    -- === SECTION 6: FLAVOR TEXT & SINGLE-INGREDIENT COMMENTS ===
	{ requires = { "milk", "cacao" }, score = 0, feedback = "taster_feedback_milk_chocolate", unique = true },
	{ requires = { "milk", "bal_cacao" }, score = 0, feedback = "taster_feedback_milk_chocolate", unique = true },
	{ requires = { "milk", "bel_cacao" }, score = 0, feedback = "taster_feedback_milk_chocolate", unique = true },
	{ requires = { "milk", "bog_cacao" }, score = 0, feedback = "taster_feedback_milk_chocolate", unique = true },
	{ requires = { "milk", "dou_cacao" }, score = 0, feedback = "taster_feedback_milk_chocolate", unique = true },
	{ requires = { "milk", "lim_cacao" }, score = 0, feedback = "taster_feedback_milk_chocolate", unique = true },
	{ requires = { "lemon", "orange" }, score = 0, feedback = "taster_feedback_lemon_orange" },
	{ requires = { "sugar", "caramel" }, score = 0, feedback = "taster_feedback_sugar_caramel", unique = true },
	{ requires = { "sugar", "mint" }, score = 0, feedback = "taster_feedback_sugar_mint", unique = true },
	{ requires = { "sugar", "orange" }, score = 0, feedback = "taster_feedback_sugar_orange", unique = true },
	{ requires = { "lemon", "almond" }, score = 0, feedback = "taster_feedback_lemon_almond" },
	{ requires = { "lemon", "peanut" }, score = 0, feedback = "taster_feedback_lemon_peanut" },
	{ requires = { "allspice" }, score = 0, feedback = "taster_feedback_allspice_solo", unique = true },
	{ requires = { "anise" }, score = 0, feedback = "taster_feedback_anise_solo", unique = true },
	{ requires = { "apple" }, score = 0, feedback = "taster_feedback_apple_solo", unique = true },
	{ requires = { "banana" }, score = 0, feedback = "taster_feedback_banana_solo", unique = true },
	{ requires = { "blackberry" }, score = 0, feedback = "taster_feedback_blackberry_solo", unique = true },
	{ requires = { "blueberry" }, score = 0, feedback = "taster_feedback_blueberry_solo", unique = true },
	{ requires = { "brandy" }, score = 0, feedback = "taster_feedback_brandy_solo", unique = true },
	{ requires = { "butter" }, score = 0, feedback = "taster_feedback_butter_solo", unique = true },
	{ requires = { "cardamom" }, score = 0, feedback = "taster_feedback_cardamom_solo", unique = true },
	{ requires = { "cinnamon" }, score = 0, feedback = "taster_feedback_cinnamon_solo", unique = true },
	{ requires = { "clove" }, score = 0, feedback = "taster_feedback_clove_solo", unique = true },
	{ requires = { "coconut" }, score = 0, feedback = "taster_feedback_coconut_solo", unique = true },
	{ requires = { "currant" }, score = 0, feedback = "taster_feedback_currant_solo", unique = true },
	{ requires = { "date" }, score = 0, feedback = "taster_feedback_date_solo", unique = true },
	{ requires = { "espresso" }, score = 0, feedback = "taster_feedback_espresso_solo", unique = true },
	{ requires = { "fig" }, score = 0, feedback = "taster_feedback_fig_solo", unique = true },
	{ requires = { "ginger" }, score = 0, feedback = "taster_feedback_ginger_solo", unique = true },
	{ requires = { "honey" }, score = 0, feedback = "taster_feedback_honey_solo", unique = true },
	{ requires = { "lavender" }, score = 0, feedback = "taster_feedback_lavender_solo", unique = true },
	{ requires = { "lychee" }, score = 0, feedback = "taster_feedback_lychee_solo", unique = true },
	{ requires = { "matcha" }, score = 0, feedback = "taster_feedback_matcha_solo", unique = true },
	{ requires = { "nutmeg" }, score = 0, feedback = "taster_feedback_nutmeg_solo", unique = true },
	{ requires = { "passionfruit" }, score = 0, feedback = "taster_feedback_passionfruit_solo", unique = true },
	{ requires = { "peanut" }, score = 0, feedback = "taster_feedback_peanut_solo", unique = true },
	{ requires = { "pepper" }, score = 0, feedback = "taster_feedback_pepper_solo", unique = true },
	{ requires = { "pineapple" }, score = 0, feedback = "taster_feedback_pineapple_solo", unique = true },
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
}

------------------------------------------------------------------------------
-- COFFEE EVALUATORS
------------------------------------------------------------------------------

CoffeeEvaluators =
{
    -- === SECTION 1: HARD REQUIREMENTS & PENALTIES ===
    { ratios = { { "coffee", "==", 0 } }, score = -100, feedback = "taster_coffee" },
    { ratios = { { "fruit", ">", 0 } }, score = -60, feedback = "taster_coffee_nofruit" },
    { ratios = { { "nut", ">", 0 } }, score = -40, feedback = "taster_coffee_nonuts" },
    { ratios = { { "dairy", ">=", 0.8 } }, score = -80, feedback = "taster_coffee_alldairy" },
    { ratios = { { "sugar", ">=", 0.8 } }, score = -80, feedback = "taster_coffee_allsugar" },
    { ratios = { { "flavor", ">=", 0.8 } }, score = -60, feedback = "taster_coffee_allflavors" },
    { ratios = { { "cacao", ">=", 0.7 } }, score = -80, feedback = "taster_coffee_allcacao" },

    -- === SECTION 2: NEGATIVE FLAVOR COMBINATIONS ===
	{ requires = { "wasabi", "cherry" }, score = -50, feedback = "taster_feedback_wasabi_fruit_bad" },
	{ requires = { "wasabi", "lemon" }, score = -50, feedback = "taster_feedback_wasabi_fruit_bad" },
	{ requires = { "wasabi", "lime" }, score = -50, feedback = "taster_feedback_wasabi_fruit_bad" },
	{ requires = { "wasabi", "raspberry" }, score = -50, feedback = "taster_feedback_wasabi_fruit_bad" },
	{ requires = { "espresso", "lime" }, score = -50, feedback = "taster_feedback_espresso_lime_bad" },
	{ requires = { "bal_coffee", "lime" }, score = -50, feedback = "taster_feedback_espresso_lime_bad" },
	{ requires = { "bog_coffee", "lime" }, score = -50, feedback = "taster_feedback_espresso_lime_bad" },
	{ requires = { "hav_coffee", "lime" }, score = -50, feedback = "taster_feedback_espresso_lime_bad" },
	{ requires = { "kon_coffee", "lime" }, score = -50, feedback = "taster_feedback_espresso_lime_bad" },
	{ requires = { "tan_coffee", "lime" }, score = -50, feedback = "taster_feedback_espresso_lime_bad" },
    { requires = { "whiskey", "wasabi" }, score = -40, feedback = "taster_feedback_whiskey_wasabi_bad" },
	{ requires = { "matcha", "orange" }, score = -40, feedback = "taster_feedback_matcha_orange_bad" },
	{ requires = { "ginger", "mint" }, score = -30, feedback = "taster_feedback_ginger_mint_coffee_bad" },
	{ requires = { "turmeric", "mint" }, score = -30, feedback = "taster_feedback_turmeric_mint_bad" },
	{ requires = { "lavender", "pepper" }, score = -30, feedback = "taster_feedback_lavender_pepper_bad" },
	{ requires = { "turmeric", "mint" }, score = -30, feedback = "taster_feedback_turmeric_mint_bad" },
	{ requires = { "ginger", "mint" }, score = -25, feedback = "taster_feedback_ginger_mint_bad" },
	{ requires = { "sumac", "dairy" }, score = -20, feedback = "taster_feedback_sumac_dairy_bad" },

    -- === SECTION 3: TOP-TIER & "SECRET" COMBINATIONS ===
    { requires = { "kahlua", "cream" }, score = 35, feedback = "taster_feedback_kahlua_cream" },
    { requires = { "kahlua", "milk" }, score = 35, feedback = "taster_feedback_kahlua_milk" },
    { requires = { "tea", "cinnamon" }, score = 30, feedback = "taster_feedback_chai_coffee" },
    { requires = { "lemon", "honey" }, score = 30, feedback = "taster_feedback_lemon_honey_coffee" },

    -- === SECTION 4: GOOD & COMPLEMENTARY COMBINATIONS ===
    { requires = { "tea", "honey" }, score = 25, feedback = "taster_feedback_tea_blend" },
    { requires = { "tea", "lemon" }, score = 25, feedback = "taster_feedback_tea_blend" },
    { requires = { "tea", "cream" }, score = 25, feedback = "taster_feedback_tea_blend" },
    { requires = { "tea", "milk" }, score = 25, feedback = "taster_feedback_tea_blend" },
    { requires = { "tea", "rose" }, score = 25, feedback = "taster_feedback_tea_floral" },
	{ requires = { "matcha", "milk" }, score = 25, feedback = "taster_feedback_matcha_latte" },
	{ requires = { "matcha", "cream" }, score = 25, feedback = "taster_feedback_matcha_latte" },
    { requires = { "vanilla", "caramel" }, score = 20, feedback = "taster_feedback_vanilla_sweet" },
    { requires = { "vanilla", "maple" }, score = 20, feedback = "taster_feedback_vanilla_sweet" },
    { requires = { "anise", "orange" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "anise", "kahlua" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "anise", "amaretto" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "anise", "grand_marnier" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "orange", "kahlua" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "orange", "amaretto" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "orange", "grand_marnier" }, score = 20, feedback = "taster_feedback_mediterranean" },
	{ requires = { "lavender", "honey" }, score = 20, feedback = "taster_feedback_lavender_honey" },
	{ requires = { "turmeric", "ginger" }, score = 15, feedback = "taster_feedback_turmeric_ginger" },
	
    -- === SECTION 5: FLAVOR TEXT & SINGLE-INGREDIENT COMMENTS ===
	{ requires = { "allspice" }, score = 0, feedback = "taster_feedback_allspice_solo", unique = true },
	{ requires = { "anise" }, score = 0, feedback = "taster_feedback_anise_solo", unique = true },
	{ requires = { "brandy" }, score = 0, feedback = "taster_feedback_brandy_solo", unique = true },
	{ requires = { "cardamom" }, score = 0, feedback = "taster_feedback_cardamom_solo", unique = true },
	{ requires = { "cinnamon" }, score = 0, feedback = "taster_feedback_cinnamon_solo", unique = true },
	{ requires = { "clove" }, score = 0, feedback = "taster_feedback_clove_solo", unique = true },
	{ requires = { "coconut" }, score = 0, feedback = "taster_feedback_coconut_solo", unique = true },
	{ requires = { "honey" }, score = 0, feedback = "taster_feedback_honey_solo", unique = true },
	{ requires = { "lavender" }, score = 0, feedback = "taster_feedback_lavender_solo", unique = true },
	{ requires = { "matcha" }, score = 0, feedback = "taster_feedback_matcha_solo", unique = true },
	{ requires = { "nutmeg" }, score = 0, feedback = "taster_feedback_nutmeg_solo", unique = true },
	{ requires = { "pepper" }, score = 0, feedback = "taster_feedback_pepper_solo", unique = true },
	{ requires = { "rum" }, score = 0, feedback = "taster_feedback_rum_solo", unique = true },
	{ requires = { "saffron" }, score = 0, feedback = "taster_feedback_saffron_solo", unique = true },
	{ requires = { "salt" }, score = 0, feedback = "taster_feedback_salt_solo", unique = true },
	{ requires = { "star_anise" }, score = 0, feedback = "taster_feedback_star_anise_solo", unique = true },
	{ requires = { "sumac" }, score = 0, feedback = "taster_feedback_sumac_solo", unique = true },
	{ requires = { "tea" }, score = 0, feedback = "taster_feedback_tea_solo", unique = true },
	{ requires = { "toffee" }, score = 0, feedback = "taster_feedback_toffee_solo", unique = true },
	{ requires = { "turmeric" }, score = 0, feedback = "taster_feedback_turmeric_solo", unique = true },
	{ requires = { "vanilla" }, score = 0, feedback = "taster_feedback_vanilla_solo", unique = true },
}