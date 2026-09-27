--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Recipe Feedback Rules)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Reforged modifications (c) 2025-2026 Michael Lane.
--]]---------------------------------------------------------------------------

-- This file defines the culinary rule pools used by Teddy Baumeister in the
-- Secret Test Kitchen. It is written for the current EvaluatePlayerRecipe()
-- implementation in sim/recipe.lua and can replace the existing
-- sim/recipe_feedback.lua directly.

-- IMPORTANT SCORING NOTES:
--   * recipe.lua begins every original recipe at 140 points.
--   * Every matching rule adds its score, even when its dialogue is voided.
--   * "unique = true" limits dialogue selection only; it does not limit scoring.
--   * Scores here are therefore deliberately conservative.

-- PRACTICAL SCORE TARGETS:
--   100-139  Flawed, awkward, or underdeveloped
--   140-164  Sound and commercially workable
--   165-189  Strong, purposeful recipe
--   190-219  Excellent layered recipe
--   220+     Exceptional and intentionally difficult to reach

-- SUPPORTED RULE FIELDS:
--   feedback:   Base localization key for Teddy's dialogue.
--   score:      Points added to or removed from recipe quality.
--   requires:   Exact ingredient names that must all be present.
--   forbids:    Exact ingredient names that must all be absent.
--   counts:     Exact ingredient-count checks: { "ingredient", "operator", value }.
--   trait_counts: Count checks for ingredient flags such as alcohol.
--   ratios:     Ingredient-family checks: { "category", "operator", value }.
--   categories: Product categories to which the rule is restricted.
--   unique:     Low-priority dialogue. One valid unique line is selected.
--   voids:      Dialogue keys suppressed when this rule matches.

-- The current engine supports these ratio families:
--   cacao, coffee, dairy, flavor, fruit, nut, sugar
-- Supported count operators are the same as ratio operators.
-- Supported trait counts currently include: alcohol

-- All culinary rules are declared directly inside ChocolateEvaluators or
-- CoffeeEvaluators. recipe.lua selects one of these two lists and iterates it
-- directly, so no feedback rules are injected afterward with table.insert().

-- Source layout:
--   * Rules without a required ingredient stay in GLOBAL / STRUCTURAL.
--   * Ingredient rules are grouped alphabetically under a primary ingredient.
--   * The first required ingredient is the default owner; a shared-theme rule may
--     be filed under the ingredient that best preserves its feedback priority.
--   * Group ownership is only for maintainability; matching still checks every field.

-- All ingredient names and dialogue keys in this file are validated against
-- the current Reforged data set.

------------------------------------------------------------------------------
-- CHOCOLATE FACTORY RULES
------------------------------------------------------------------------------

ChocolateEvaluators =
{
	-- =======================================================================
	-- GLOBAL / STRUCTURAL
	-- Rules that describe the recipe as a whole rather than one ingredient.
	-- =======================================================================
	{ ratios = { { "dairy", ">=", 0.8 } }, score = -60, feedback = "taster_choco_alldairy", voids = { "taster_feedback_butter_solo", "taster_feedback_cream_solo", "taster_feedback_whipped_cream_solo" } },
	{ ratios = { { "sugar", ">=", 0.8 } }, score = -60, feedback = "taster_choco_allsugar", voids = { "taster_feedback_honey_solo", "taster_feedback_toffee_solo" } },
	{ ratios = { { "flavor", ">=", 0.8 } }, score = -55, feedback = "taster_choco_allflavors" },
	{ ratios = { { "coffee", ">=", 0.6 } }, score = -45, feedback = "taster_choco_allcoffee", voids = { "taster_feedback_espresso_solo" } },
	{ ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 8, feedback = "taster_feedback_pure_dark", unique = true },

	-- ALLSPICE --------------------------------------------------------------
	{ requires = { "allspice" }, counts = { { "allspice", ">=", 2 } }, score = -20, feedback = "taster_feedback_allspice_overuse", voids = { "taster_feedback_allspice_solo" } },
	{ requires = { "allspice", "apple" }, score = 7, feedback = "taster_feedback_allspice_apple", unique = true, voids = { "taster_feedback_allspice_solo", "taster_feedback_apple_solo" } },
	{ requires = { "allspice", "pumpkin" }, score = 8, feedback = "taster_feedback_allspice_pumpkin", unique = true, voids = { "taster_feedback_allspice_solo", "taster_feedback_pumpkin_solo" } },
	{ requires = { "allspice", "orange" }, score = 6, feedback = "taster_feedback_allspice_orange", unique = true, voids = { "taster_feedback_allspice_solo", "taster_feedback_orange_solo" } },
	{ requires = { "allspice" }, score = 0, feedback = "taster_feedback_allspice_solo", unique = true },

	-- ALMOND ----------------------------------------------------------------
	{ requires = { "almond", "pistachio" }, score = 8, feedback = "taster_feedback_almond_pistachio", unique = true, voids = { "taster_feedback_almond_solo", "taster_feedback_pistachio_solo" } },
	{ requires = { "almond" }, score = 0, feedback = "taster_feedback_almond_solo", unique = true },

	-- AMARETTO --------------------------------------------------------------
	{ requires = { "amaretto" }, score = 0, feedback = "taster_feedback_amaretto_solo", unique = true },

	-- ANISE -----------------------------------------------------------------
	{ requires = { "anise" }, counts = { { "anise", ">=", 2 } }, score = -22, feedback = "taster_feedback_anise_overuse", voids = { "taster_feedback_anise_solo" } },
	{ requires = { "anise", "peanut" }, score = -22, feedback = "taster_feedback_anise_peanut_bad", voids = { "taster_feedback_anise_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "anise", "star_anise", "clove" }, score = -18, feedback = "taster_feedback_spice_medicine_bad", voids = { "taster_feedback_anise_solo", "taster_feedback_star_anise_solo", "taster_feedback_clove_solo" } },
	{ requires = { "anise", "orange" }, score = 5, feedback = "taster_feedback_anise_orange", unique = true, voids = { "taster_feedback_anise_solo", "taster_feedback_orange_solo" } },
	{ requires = { "anise", "kahlua" }, score = 4, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_anise_solo", "taster_feedback_kahlua_solo" } },
	{ requires = { "anise", "amaretto" }, score = 4, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_anise_solo", "taster_feedback_amaretto_solo" } },
	{ requires = { "anise", "grand_marnier" }, score = 4, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_anise_solo", "taster_feedback_grand_marnier_solo" } },
	{ requires = { "anise", "cherry" }, score = 3, feedback = "taster_feedback_anise_cherry", unique = true, voids = { "taster_feedback_anise_solo", "taster_feedback_cherry_solo" } },
	{ requires = { "anise" }, score = 0, feedback = "taster_feedback_anise_solo", unique = true },

	-- APPLE -----------------------------------------------------------------
	{ requires = { "apple", "wasabi" }, score = -28, feedback = "taster_feedback_apple_wasabi_bad", voids = { "taster_feedback_apple_solo", "taster_feedback_wasabi_solo" } },
	{ requires = { "apple", "walnut" }, score = 8, feedback = "taster_feedback_apple_walnut", unique = true, voids = { "taster_feedback_apple_solo", "taster_feedback_walnut_solo" } },
	{ requires = { "apple", "cinnamon" }, score = 6, feedback = "taster_feedback_apple_cinnamon", unique = true, voids = { "taster_feedback_apple_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "apple", "caramel" }, score = 8, feedback = "taster_feedback_apple_caramel", unique = true, voids = { "taster_feedback_apple_solo" } },
	{ requires = { "apple" }, score = 0, feedback = "taster_feedback_apple_solo", unique = true },

	-- APRICOT ---------------------------------------------------------------
	{ requires = { "apricot", "almond" }, score = 6, feedback = "taster_feedback_apricot_almond", unique = true, voids = { "taster_feedback_apricot_solo", "taster_feedback_almond_solo" } },
	{ requires = { "apricot", "amaretto" }, score = 6, feedback = "taster_feedback_apricot_almond", unique = true, voids = { "taster_feedback_apricot_solo", "taster_feedback_amaretto_solo" } },
	{ requires = { "apricot" }, score = 0, feedback = "taster_feedback_apricot_solo", unique = true },

	-- BANANA ----------------------------------------------------------------
	{ requires = { "banana", "toffee" }, ratios = { { "dairy", ">=", 0.15 } }, score = 22, feedback = "taster_feedback_banoffee", voids = { "taster_feedback_banana_solo", "taster_feedback_toffee_solo" } },
	{ requires = { "banana", "walnut" }, score = 16, feedback = "taster_feedback_banana_walnut", voids = { "taster_feedback_banana_solo", "taster_feedback_walnut_solo" } },
	{ requires = { "banana", "caramel" }, score = 8, feedback = "taster_feedback_banana_caramel", unique = true, voids = { "taster_feedback_banana_solo" } },
	{ requires = { "banana", "peanut" }, score = 8, feedback = "taster_feedback_banana_peanut", unique = true, voids = { "taster_feedback_banana_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "banana", "rum" }, score = 8, feedback = "taster_feedback_banana_rum", unique = true, voids = { "taster_feedback_banana_solo", "taster_feedback_rum_solo" } },
	{ requires = { "banana" }, score = 0, feedback = "taster_feedback_banana_solo", unique = true },

	-- BLACKBERRY ------------------------------------------------------------
	{ requires = { "blackberry" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 14, feedback = "taster_feedback_dark_tart_berry", voids = { "taster_feedback_blackberry_solo" } },
	{ requires = { "blackberry", "lemon" }, score = 8, feedback = "taster_feedback_blackberry_lemon", unique = true, voids = { "taster_feedback_blackberry_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "blackberry" }, score = 0, feedback = "taster_feedback_blackberry_solo", unique = true },

	-- BLUEBERRY -------------------------------------------------------------
	{ requires = { "blueberry", "raspberry" }, score = 6, feedback = "taster_feedback_berries", unique = true, voids = { "taster_feedback_blueberry_solo", "taster_feedback_raspberry_solo" } },
	{ requires = { "blueberry", "strawberry" }, score = 6, feedback = "taster_feedback_berries", unique = true, voids = { "taster_feedback_blueberry_solo", "taster_feedback_strawberry_solo" } },
	{ requires = { "blueberry", "lemon" }, score = 8, feedback = "taster_feedback_blueberry_lemon", unique = true, voids = { "taster_feedback_blueberry_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "blueberry" }, score = 0, feedback = "taster_feedback_blueberry_solo", unique = true },

	-- BRANDY ----------------------------------------------------------------
	{ requires = { "brandy" }, score = 0, feedback = "taster_feedback_brandy_solo", unique = true },

	-- BUTTER ----------------------------------------------------------------
	{ requires = { "butter" }, counts = { { "butter", ">=", 2 } }, score = -18, feedback = "taster_feedback_butter_overuse", voids = { "taster_feedback_butter_solo" } },
	{ requires = { "butter", "cashew" }, score = 4, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_butter_solo", "taster_feedback_cashew_solo" } },
	{ requires = { "butter", "peanut" }, score = 4, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_butter_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "butter", "hazelnut" }, score = 4, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_butter_solo", "taster_feedback_hazelnut_solo" } },
	{ requires = { "butter", "macadamia" }, score = 4, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_butter_solo", "taster_feedback_macadamia_solo" } },
	{ requires = { "butter", "almond" }, score = 4, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_butter_solo", "taster_feedback_almond_solo" } },
	{ requires = { "butter" }, score = 0, feedback = "taster_feedback_butter_solo", unique = true },

	-- CARAMEL ---------------------------------------------------------------
	{ requires = { "caramel" }, counts = { { "caramel", ">=", 3 } }, score = -16, feedback = "taster_feedback_caramel_overuse" },
	{ requires = { "caramel", "peanut" }, score = 6, feedback = "taster_feedback_caramel_nuts", unique = true, voids = { "taster_feedback_peanut_solo", "taster_feedback_sugar_caramel" } },
	{ requires = { "caramel", "almond" }, score = 6, feedback = "taster_feedback_caramel_nuts", unique = true, voids = { "taster_feedback_almond_solo", "taster_feedback_sugar_caramel" } },
	{ requires = { "caramel", "hazelnut" }, score = 6, feedback = "taster_feedback_caramel_nuts", unique = true, voids = { "taster_feedback_hazelnut_solo", "taster_feedback_sugar_caramel" } },
	{ requires = { "caramel", "cashew" }, score = 6, feedback = "taster_feedback_caramel_nuts", unique = true, voids = { "taster_feedback_cashew_solo", "taster_feedback_sugar_caramel" } },
	{ requires = { "caramel" }, ratios = { { "cacao", ">", 0.2 } }, score = 14, feedback = "taster_feedback_chocolate_caramel", unique = true },

	-- CARDAMOM --------------------------------------------------------------
	{ requires = { "cardamom" }, counts = { { "cardamom", ">=", 2 } }, score = -18, feedback = "taster_feedback_cardamom_overuse", voids = { "taster_feedback_cardamom_solo" } },
	{ requires = { "cardamom", "orange" }, score = 7, feedback = "taster_feedback_cardamom_orange", unique = true, voids = { "taster_feedback_cardamom_solo", "taster_feedback_orange_solo" } },
	{ requires = { "cardamom", "pistachio" }, score = 7, feedback = "taster_feedback_cardamom_pistachio", unique = true, voids = { "taster_feedback_cardamom_solo", "taster_feedback_pistachio_solo" } },
	{ requires = { "cardamom", "honey" }, score = 6, feedback = "taster_feedback_cardamom_honey", unique = true, voids = { "taster_feedback_cardamom_solo", "taster_feedback_honey_solo" } },
	{ requires = { "cardamom" }, score = 0, feedback = "taster_feedback_cardamom_solo", unique = true },

	-- CASHEW ----------------------------------------------------------------
	{ requires = { "cashew" }, score = 0, feedback = "taster_feedback_cashew_solo", unique = true },

	-- CAYENNE ---------------------------------------------------------------
	{ requires = { "cayenne" }, counts = { { "cayenne", ">=", 2 } }, score = -26, feedback = "taster_feedback_cayenne_overuse", voids = { "taster_feedback_cayenne_solo" } },
	{ requires = { "cayenne", "jasmine" }, score = -20, feedback = "taster_feedback_jasmine_cayenne_bad", voids = { "taster_feedback_cayenne_solo", "taster_feedback_jasmine_solo" } },
	{ requires = { "cayenne", "chamomile" }, score = -18, feedback = "taster_feedback_chamomile_cayenne_bad", voids = { "taster_feedback_cayenne_solo", "taster_feedback_chamomile_solo" } },
	{ requires = { "cayenne", "honey" }, score = 8, feedback = "taster_feedback_cayenne_honey", unique = true, voids = { "taster_feedback_cayenne_solo", "taster_feedback_honey_solo" } },
	{ requires = { "cayenne", "lime" }, score = 6, feedback = "taster_feedback_cayenne_lime", unique = true, voids = { "taster_feedback_cayenne_solo", "taster_feedback_lime_solo", "taster_feedback_spicy_chocolate" } },
	{ requires = { "cayenne" }, ratios = { { "cacao", ">", 0 } }, score = 4, feedback = "taster_feedback_spicy_chocolate", unique = true, voids = { "taster_feedback_cayenne_solo" } },
	{ requires = { "cayenne" }, score = 0, feedback = "taster_feedback_cayenne_solo", unique = true },

	-- CHAMOMILE -------------------------------------------------------------
	{ requires = { "chamomile" }, counts = { { "chamomile", ">=", 2 } }, score = -14, feedback = "taster_feedback_chamomile_overuse", voids = { "taster_feedback_chamomile_solo" } },
	{ requires = { "chamomile" }, ratios = { { "coffee", ">", 0 } }, score = -18, feedback = "taster_feedback_coffee_chamomile_bad", voids = { "taster_feedback_chamomile_solo" } },
	{ requires = { "chamomile", "honey" }, score = 6, feedback = "taster_feedback_chamomile_honey", unique = true, voids = { "taster_feedback_chamomile_solo", "taster_feedback_honey_solo" } },
	{ requires = { "chamomile" }, score = 0, feedback = "taster_feedback_chamomile_solo", unique = true },

	-- CHERRY ----------------------------------------------------------------
	{ requires = { "cherry", "whipped_cream" }, ratios = { { "cacao", ">", 0 } }, score = 20, feedback = "taster_feedback_black_forest", voids = { "taster_feedback_whipped_cream_solo", "taster_feedback_whipped_cream_chocolate", "taster_feedback_whipped_cream_darkchoc", "taster_feedback_spumoni", "taster_feedback_cherry_solo" } },
	{ requires = { "cherry", "amaretto" }, score = 10, feedback = "taster_feedback_amaretto_cherry", unique = true, voids = { "taster_feedback_amaretto_solo", "taster_feedback_cherry_solo" } },
	{ requires = { "cherry", "currant" }, score = 8, feedback = "taster_feedback_cherry_currant", unique = true, voids = { "taster_feedback_currant_solo", "taster_feedback_cherry_solo" } },
	{ requires = { "cherry" }, ratios = { { "cacao", ">", 0.2 } }, score = 10, feedback = "taster_feedback_chocolate_cherry", unique = true, voids = { "taster_feedback_cherry_solo" } },
	{ requires = { "cherry", "almond" }, score = 8, feedback = "taster_feedback_cherry_almond", unique = true, voids = { "taster_feedback_cherry_solo", "taster_feedback_almond_solo" } },
	{ requires = { "cherry" }, score = 0, feedback = "taster_feedback_cherry_solo", unique = true },

	-- CHESTNUT --------------------------------------------------------------
	{ requires = { "chestnut", "vanilla" }, ratios = { { "dairy", ">=", 0.2 } }, score = 20, feedback = "taster_feedback_mont_blanc", voids = { "taster_feedback_chestnut_solo", "taster_feedback_vanilla_solo" } },
	{ requires = { "chestnut", "rum" }, score = 8, feedback = "taster_feedback_chestnut_rum", unique = true, voids = { "taster_feedback_chestnut_solo", "taster_feedback_rum_solo" } },
	{ requires = { "chestnut", "vanilla" }, ratios = { { "dairy", "==", 0 } }, score = 7, feedback = "taster_feedback_chestnut_vanilla", unique = true, voids = { "taster_feedback_chestnut_solo", "taster_feedback_vanilla_solo" } },
	{ requires = { "chestnut" }, score = 0, feedback = "taster_feedback_chestnut_solo", unique = true },

	-- CINNAMON --------------------------------------------------------------
	{ requires = { "cinnamon" }, counts = { { "cinnamon", ">=", 2 } }, score = -18, feedback = "taster_feedback_cinnamon_overuse", voids = { "taster_feedback_cinnamon_solo" } },
	{ requires = { "cinnamon", "cayenne" }, ratios = { { "cacao", ">", 0 }, { "dairy", "==", 0 } }, score = 24, feedback = "taster_feedback_mesoamerican", voids = { "taster_feedback_cinnamon_solo", "taster_feedback_cayenne_solo", "taster_feedback_spicy_chocolate" } },
	{ requires = { "cinnamon" }, score = 0, feedback = "taster_feedback_cinnamon_solo", unique = true },

	-- CLOVE -----------------------------------------------------------------
	{ requires = { "clove" }, counts = { { "clove", ">=", 2 } }, score = -24, feedback = "taster_feedback_clove_overuse", voids = { "taster_feedback_clove_solo" } },
	{ requires = { "clove" }, score = 0, feedback = "taster_feedback_clove_solo", unique = true },

	-- COCONUT ---------------------------------------------------------------
	{ requires = { "coconut", "lime" }, score = 8, feedback = "taster_feedback_coconut_lime", unique = true, voids = { "taster_feedback_coconut_solo", "taster_feedback_lime_solo" } },
	{ requires = { "coconut" }, ratios = { { "cacao", ">", 0.2 } }, score = 10, feedback = "taster_feedback_chocolate_coconut", unique = true, voids = { "taster_feedback_coconut_solo" } },
	{ requires = { "coconut", "mango" }, score = 8, feedback = "taster_feedback_coconut_mango", unique = true, voids = { "taster_feedback_coconut_solo", "taster_feedback_mango_solo" } },
	{ requires = { "coconut", "passionfruit" }, score = 8, feedback = "taster_feedback_coconut_passionfruit", unique = true, voids = { "taster_feedback_coconut_solo", "taster_feedback_passionfruit_solo" } },
	{ requires = { "coconut" }, score = 0, feedback = "taster_feedback_coconut_solo", unique = true },

	-- CRANBERRY -------------------------------------------------------------
	{ requires = { "cranberry", "orange" }, score = 8, feedback = "taster_feedback_cranberry_orange", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_cranberry_solo" } },
	{ requires = { "cranberry" }, score = 0, feedback = "taster_feedback_cranberry_solo", unique = true },

	-- CREAM -----------------------------------------------------------------
	{ requires = { "cream" }, score = 0, feedback = "taster_feedback_cream_solo", unique = true },

	-- CURRANT ---------------------------------------------------------------
	{ requires = { "currant", "lime" }, score = -14, feedback = "taster_feedback_currant_lime_bad", voids = { "taster_feedback_currant_solo", "taster_feedback_lime_solo" } },
	{ requires = { "currant" }, ratios = { { "cacao", ">=", 0.5 } }, score = 12, feedback = "taster_feedback_currant_darkchoc", voids = { "taster_feedback_currant_solo" } },
	{ requires = { "currant", "hazelnut" }, score = 8, feedback = "taster_feedback_currant_hazelnut", unique = true, voids = { "taster_feedback_currant_solo", "taster_feedback_hazelnut_solo" } },
	{ requires = { "currant", "cream" }, score = 7, feedback = "taster_feedback_currant_cream", unique = true, voids = { "taster_feedback_currant_solo", "taster_feedback_cream_solo" } },
	{ requires = { "currant" }, score = 0, feedback = "taster_feedback_currant_solo", unique = true },

	-- DATE ------------------------------------------------------------------
	{ requires = { "date", "walnut" }, score = 12, feedback = "taster_feedback_stuffed_date", unique = true, voids = { "taster_feedback_date_solo", "taster_feedback_walnut_solo" } },
	{ requires = { "date", "almond" }, score = 12, feedback = "taster_feedback_stuffed_date", unique = true, voids = { "taster_feedback_date_solo", "taster_feedback_almond_solo" } },
	{ requires = { "date" }, score = 0, feedback = "taster_feedback_date_solo", unique = true },

	-- DRAGONFRUIT -----------------------------------------------------------
	{ requires = { "dragonfruit", "anise" }, score = -12, feedback = "taster_feedback_dragonfruit_anise_bad", voids = { "taster_feedback_dragonfruit_solo", "taster_feedback_anise_solo" } },
	{ requires = { "dragonfruit", "coconut" }, score = 8, feedback = "taster_feedback_tropical_fruit", unique = true, voids = { "taster_feedback_coconut_solo", "taster_feedback_dragonfruit_solo" } },
	{ requires = { "dragonfruit" }, score = 0, feedback = "taster_feedback_dragonfruit_solo", unique = true },

	-- EARL GREY -------------------------------------------------------------
	{ requires = { "earl_grey" }, counts = { { "earl_grey", ">=", 2 } }, score = -16, feedback = "taster_feedback_earl_grey_overuse", voids = { "taster_feedback_earl_grey_solo" } },
	{ requires = { "earl_grey", "peanut" }, ratios = { { "coffee", "==", 0 } }, score = -16, feedback = "taster_feedback_earl_grey_peanut_bad", voids = { "taster_feedback_earl_grey_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "earl_grey", "lemon" }, score = 6, feedback = "taster_feedback_earl_grey_lemon", unique = true, voids = { "taster_feedback_earl_grey_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "earl_grey", "lavender" }, score = 6, feedback = "taster_feedback_earl_grey_lavender", unique = true, voids = { "taster_feedback_earl_grey_solo", "taster_feedback_lavender_solo" } },
	{ requires = { "earl_grey" }, score = 0, feedback = "taster_feedback_earl_grey_solo", unique = true },

	-- ESPRESSO --------------------------------------------------------------
	{ requires = { "espresso" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 18, feedback = "taster_feedback_dark_espresso", voids = { "taster_feedback_espresso_solo" } },
	{ requires = { "espresso" }, score = 0, feedback = "taster_feedback_espresso_solo", unique = true },

	-- FIG -------------------------------------------------------------------
	{ requires = { "fig", "brandy" }, score = 12, feedback = "taster_feedback_fig_brandy", unique = true, voids = { "taster_feedback_fig_solo", "taster_feedback_brandy_solo" } },
	{ requires = { "fig", "pistachio" }, score = 10, feedback = "taster_feedback_fig_pistachio", unique = true, voids = { "taster_feedback_fig_solo", "taster_feedback_pistachio_solo" } },
	{ requires = { "fig", "walnut" }, score = 10, feedback = "taster_feedback_fig_walnut", unique = true, voids = { "taster_feedback_fig_solo", "taster_feedback_walnut_solo" } },
	{ requires = { "fig" }, score = 0, feedback = "taster_feedback_fig_solo", unique = true },

	-- GINGER ----------------------------------------------------------------
	{ requires = { "ginger" }, counts = { { "ginger", ">=", 2 } }, score = -18, feedback = "taster_feedback_ginger_overuse", voids = { "taster_feedback_ginger_solo" } },
	{ requires = { "ginger" }, score = 0, feedback = "taster_feedback_ginger_solo", unique = true },

	-- GRAND MARNIER ---------------------------------------------------------
	{ requires = { "grand_marnier" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 16, feedback = "taster_feedback_dark_grand_marnier", voids = { "taster_feedback_grand_marnier_solo" } },
	{ requires = { "grand_marnier" }, score = 0, feedback = "taster_feedback_grand_marnier_solo", unique = true },

	-- GUAVA -----------------------------------------------------------------
	{ requires = { "guava", "clove" }, score = -14, feedback = "taster_feedback_guava_clove_bad", voids = { "taster_feedback_guava_solo", "taster_feedback_clove_solo" } },
	{ requires = { "guava", "passionfruit" }, score = 8, feedback = "taster_feedback_tropical_fruit", unique = true, voids = { "taster_feedback_passionfruit_solo", "taster_feedback_guava_solo" } },
	{ requires = { "guava" }, score = 0, feedback = "taster_feedback_guava_solo", unique = true },

	-- HAZELNUT --------------------------------------------------------------
	{ requires = { "hazelnut" }, ratios = { { "cacao", ">", 0.2 }, { "dairy", ">=", 0.1 } }, score = 18, feedback = "taster_feedback_gianduja", voids = { "taster_feedback_hazelnut_solo" } },
	{ requires = { "hazelnut" }, score = 0, feedback = "taster_feedback_hazelnut_solo", unique = true },

	-- HIBISCUS --------------------------------------------------------------
	{ requires = { "hibiscus" }, counts = { { "hibiscus", ">=", 2 } }, score = -18, feedback = "taster_feedback_hibiscus_overuse", voids = { "taster_feedback_hibiscus_solo" } },
	{ requires = { "hibiscus", "peanut" }, score = -16, feedback = "taster_feedback_hibiscus_peanut_bad", voids = { "taster_feedback_hibiscus_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "hibiscus" }, ratios = { { "coffee", ">", 0 } }, score = -16, feedback = "taster_feedback_coffee_hibiscus_bad", voids = { "taster_feedback_hibiscus_solo" } },
	{ requires = { "hibiscus", "pineapple" }, score = 10, feedback = "taster_feedback_hibiscus_pineapple", unique = true, voids = { "taster_feedback_hibiscus_solo", "taster_feedback_pineapple_solo" } },
	{ requires = { "hibiscus", "mango" }, score = 8, feedback = "taster_feedback_hibiscus_mango", unique = true, voids = { "taster_feedback_hibiscus_solo", "taster_feedback_mango_solo" } },
	{ requires = { "hibiscus", "ginger" }, score = 6, feedback = "taster_feedback_hibiscus_ginger", unique = true, voids = { "taster_feedback_hibiscus_solo", "taster_feedback_ginger_solo" } },
	{ requires = { "hibiscus", "cinnamon" }, score = 6, feedback = "taster_feedback_hibiscus_cinnamon", unique = true, voids = { "taster_feedback_hibiscus_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "hibiscus", "mint" }, score = 4, feedback = "taster_feedback_hibiscus_mint", unique = true, voids = { "taster_feedback_hibiscus_solo", "taster_feedback_mint_solo" } },
	{ requires = { "hibiscus", "orange" }, score = 6, feedback = "taster_feedback_hibiscus_orange", unique = true, voids = { "taster_feedback_hibiscus_solo", "taster_feedback_orange_solo" } },
	{ requires = { "hibiscus" }, score = 0, feedback = "taster_feedback_hibiscus_solo", unique = true },

	-- HONEY -----------------------------------------------------------------
	{ requires = { "honey" }, counts = { { "honey", ">=", 2 } }, score = -18, feedback = "taster_feedback_honey_overuse", voids = { "taster_feedback_honey_solo" } },
	{ requires = { "honey" }, score = 0, feedback = "taster_feedback_honey_solo", unique = true },

	-- ICE CREAM -------------------------------------------------------------
	{ requires = { "ice_cream" }, score = 0, feedback = "taster_feedback_ice_cream_solo", unique = true },

	-- JASMINE ---------------------------------------------------------------
	{ requires = { "jasmine" }, counts = { { "jasmine", ">=", 2 } }, score = -18, feedback = "taster_feedback_jasmine_overuse", voids = { "taster_feedback_jasmine_solo" } },
	{ requires = { "jasmine", "peanut" }, ratios = { { "coffee", "==", 0 } }, score = -16, feedback = "taster_feedback_jasmine_peanut_bad", voids = { "taster_feedback_jasmine_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "jasmine", "peach" }, score = 6, feedback = "taster_feedback_jasmine_peach", unique = true, voids = { "taster_feedback_jasmine_solo", "taster_feedback_peach_solo" } },
	{ requires = { "jasmine" }, score = 0, feedback = "taster_feedback_jasmine_solo", unique = true },

	-- KAHLUA ----------------------------------------------------------------
	{ requires = { "kahlua", "cream" }, score = 8, feedback = "taster_feedback_kahlua_cream", unique = true, voids = { "taster_feedback_kahlua_solo", "taster_feedback_cream_solo" } },
	{ requires = { "kahlua", "milk" }, score = 8, feedback = "taster_feedback_kahlua_milk", unique = true, voids = { "taster_feedback_kahlua_solo" } },
	{ requires = { "kahlua" }, score = 0, feedback = "taster_feedback_kahlua_solo", unique = true },

	-- LAVENDER --------------------------------------------------------------
	{ requires = { "lavender" }, counts = { { "lavender", ">=", 2 } }, score = -20, feedback = "taster_feedback_lavender_overuse", voids = { "taster_feedback_lavender_solo" } },
	{ requires = { "lavender", "cayenne" }, score = -18, feedback = "taster_feedback_lavender_cayenne_bad", voids = { "taster_feedback_lavender_solo", "taster_feedback_cayenne_solo" } },
	{ requires = { "lavender", "lime" }, score = -16, feedback = "taster_feedback_lavender_lime_bad", voids = { "taster_feedback_lavender_solo", "taster_feedback_lime_solo" } },
	{ requires = { "lavender", "blueberry" }, score = 8, feedback = "taster_feedback_lavender_blueberry", unique = true, voids = { "taster_feedback_lavender_solo", "taster_feedback_blueberry_solo" } },
	{ requires = { "lavender", "honey" }, score = 6, feedback = "taster_feedback_lavender_honey", unique = true, voids = { "taster_feedback_lavender_solo", "taster_feedback_honey_solo" } },
	{ requires = { "lavender", "lemon" }, score = 6, feedback = "taster_feedback_lavender_lemon", unique = true, voids = { "taster_feedback_lavender_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "lavender", "mint" }, score = 3, feedback = "taster_feedback_lavender_mint", unique = true, voids = { "taster_feedback_lavender_solo", "taster_feedback_mint_solo" } },
	{ requires = { "lavender" }, score = 0, feedback = "taster_feedback_lavender_solo", unique = true },

	-- LEMON -----------------------------------------------------------------
	{ requires = { "lemon" }, counts = { { "lemon", ">=", 2 } }, score = -16, feedback = "taster_feedback_lemon_overuse", voids = { "taster_feedback_lemon_solo" } },
	{ requires = { "lemon", "honey" }, score = 5, feedback = "taster_feedback_lemon_honey", unique = true, voids = { "taster_feedback_lemon_solo", "taster_feedback_honey_solo" } },
	{ requires = { "lemon", "lime" }, score = 4, feedback = "taster_feedback_lemon_lime", unique = true, voids = { "taster_feedback_lemon_solo", "taster_feedback_lime_solo" } },
	{ requires = { "lemon", "mint" }, score = 3, feedback = "taster_feedback_lemon_mint", unique = true, voids = { "taster_feedback_lemon_solo", "taster_feedback_mint_solo" } },
	{ requires = { "lemon", "hazelnut" }, score = 3, feedback = "taster_feedback_lemon_hazelnut", unique = true, voids = { "taster_feedback_lemon_solo", "taster_feedback_hazelnut_solo" } },
	{ requires = { "lemon", "orange" }, score = 0, feedback = "taster_feedback_lemon_orange", unique = true, voids = { "taster_feedback_lemon_solo", "taster_feedback_orange_solo" } },
	{ requires = { "lemon", "almond" }, score = 0, feedback = "taster_feedback_lemon_almond", unique = true, voids = { "taster_feedback_lemon_solo", "taster_feedback_almond_solo" } },
	{ requires = { "lemon", "peanut" }, score = 0, feedback = "taster_feedback_lemon_peanut", unique = true, voids = { "taster_feedback_lemon_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "lemon", "ginger" }, score = 6, feedback = "taster_feedback_lemon_ginger", unique = true, voids = { "taster_feedback_lemon_solo", "taster_feedback_ginger_solo" } },
	{ requires = { "lemon" }, score = 0, feedback = "taster_feedback_lemon_solo", unique = true },

	-- LEMONGRASS ------------------------------------------------------------
	{ requires = { "lemongrass" }, counts = { { "lemongrass", ">=", 2 } }, score = -16, feedback = "taster_feedback_lemongrass_overuse", voids = { "taster_feedback_lemongrass_solo" } },
	{ requires = { "lemongrass", "ginger" }, score = 6, feedback = "taster_feedback_lemongrass_ginger", unique = true, voids = { "taster_feedback_lemongrass_solo", "taster_feedback_ginger_solo" } },
	{ requires = { "lemongrass" }, score = 0, feedback = "taster_feedback_lemongrass_solo", unique = true },

	-- LIME ------------------------------------------------------------------
	{ requires = { "lime" }, counts = { { "lime", ">=", 2 } }, score = -16, feedback = "taster_feedback_lime_overuse", voids = { "taster_feedback_lime_solo" } },
	{ requires = { "lime" }, score = 0, feedback = "taster_feedback_lime_solo", unique = true },

	-- LYCHEE ----------------------------------------------------------------
	{ requires = { "lychee", "rose" }, score = 8, feedback = "taster_feedback_rose_lychee", unique = true, voids = { "taster_feedback_lychee_solo", "taster_feedback_rose_solo" } },
	{ requires = { "lychee" }, score = 0, feedback = "taster_feedback_lychee_solo", unique = true },

	-- MACADAMIA -------------------------------------------------------------
	{ requires = { "macadamia" }, score = 0, feedback = "taster_feedback_macadamia_solo", unique = true },

	-- MANGO -----------------------------------------------------------------
	{ requires = { "mango" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 12, feedback = "taster_feedback_dark_mango", voids = { "taster_feedback_mango_solo" } },
	{ requires = { "mango" }, score = 0, feedback = "taster_feedback_mango_solo", unique = true },

	-- MAPLE -----------------------------------------------------------------
	{ requires = { "maple" }, counts = { { "maple", ">=", 3 } }, score = -16, feedback = "taster_feedback_maple_overuse", voids = { "taster_feedback_maple_solo" } },
	{ requires = { "maple", "walnut" }, score = 16, feedback = "taster_feedback_maple_walnut", voids = { "taster_feedback_walnut_solo", "taster_feedback_maple_solo" } },
	{ requires = { "maple", "pecan" }, score = 16, feedback = "taster_feedback_maple_pecan", voids = { "taster_feedback_pecan_solo", "taster_feedback_maple_solo" } },
	{ requires = { "maple" }, score = 0, feedback = "taster_feedback_maple_solo", unique = true },

	-- MARSHMALLOW -----------------------------------------------------------
	{ requires = { "marshmallow" }, counts = { { "marshmallow", ">=", 2 } }, score = -22, feedback = "taster_feedback_marshmallow_overuse", voids = { "taster_feedback_marshmallow_solo" } },
	{ requires = { "marshmallow", "wafer" }, score = 6, feedback = "taster_feedback_marshmallow_wafer", unique = true, voids = { "taster_feedback_marshmallow_solo", "taster_feedback_wafer_solo" } },
	{ requires = { "marshmallow", "peanut" }, score = 8, feedback = "taster_feedback_marshmallow_peanut", unique = true, voids = { "taster_feedback_marshmallow_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "marshmallow", "caramel" }, score = 7, feedback = "taster_feedback_marshmallow_caramel", unique = true, voids = { "taster_feedback_marshmallow_solo" } },
	{ requires = { "marshmallow", "walnut" }, score = 8, feedback = "taster_feedback_marshmallow_walnut", unique = true, voids = { "taster_feedback_marshmallow_solo", "taster_feedback_walnut_solo" } },
	{ requires = { "marshmallow" }, ratios = { { "cacao", ">=", 0.6 }, { "dairy", "==", 0 } }, score = 12, feedback = "taster_feedback_marshmallow_darkchoc", unique = true, voids = { "taster_feedback_marshmallow_solo", "taster_feedback_chocolate_marshmallow" } },
	{ requires = { "marshmallow" }, ratios = { { "cacao", ">", 0.2 } }, score = 10, feedback = "taster_feedback_chocolate_marshmallow", unique = true, voids = { "taster_feedback_marshmallow_solo" } },
	{ requires = { "marshmallow" }, score = 0, feedback = "taster_feedback_marshmallow_solo", unique = true },

	-- MATCHA ----------------------------------------------------------------
	{ requires = { "matcha" }, counts = { { "matcha", ">=", 2 } }, score = -22, feedback = "taster_feedback_matcha_overuse", voids = { "taster_feedback_matcha_solo" } },
	{ requires = { "matcha", "orange" }, score = -14, feedback = "taster_feedback_matcha_orange_bad", voids = { "taster_feedback_matcha_solo", "taster_feedback_orange_solo" } },
	{ requires = { "matcha", "whiskey" }, ratios = { { "coffee", "==", 0 } }, score = -18, feedback = "taster_feedback_matcha_whiskey_bad", voids = { "taster_feedback_matcha_solo", "taster_feedback_whiskey_solo" } },
	{ requires = { "matcha", "honey" }, score = 8, feedback = "taster_feedback_matcha_honey", unique = true, voids = { "taster_feedback_matcha_solo", "taster_feedback_honey_solo" } },
	{ requires = { "matcha", "milk" }, score = 6, feedback = "taster_feedback_matcha_dairy", unique = true, voids = { "taster_feedback_matcha_solo" } },
	{ requires = { "matcha", "cream" }, score = 6, feedback = "taster_feedback_matcha_dairy", unique = true, voids = { "taster_feedback_matcha_solo", "taster_feedback_cream_solo" } },
	{ requires = { "matcha", "ginger" }, score = 4, feedback = "taster_feedback_matcha_ginger", unique = true, voids = { "taster_feedback_matcha_solo", "taster_feedback_ginger_solo" } },
	{ requires = { "matcha", "almond" }, score = 4, feedback = "taster_feedback_matcha_almond", unique = true, voids = { "taster_feedback_matcha_solo", "taster_feedback_almond_solo" } },
	{ requires = { "matcha", "yuzu" }, score = 8, feedback = "taster_feedback_matcha_yuzu", unique = true, voids = { "taster_feedback_matcha_solo", "taster_feedback_yuzu_solo" } },
	{ requires = { "matcha", "strawberry" }, score = 6, feedback = "taster_feedback_matcha_strawberry", unique = true, voids = { "taster_feedback_matcha_solo", "taster_feedback_strawberry_solo" } },
	{ requires = { "matcha", "coconut" }, score = 6, feedback = "taster_feedback_matcha_coconut", unique = true, voids = { "taster_feedback_matcha_solo", "taster_feedback_coconut_solo" } },
	{ requires = { "matcha" }, score = 0, feedback = "taster_feedback_matcha_solo", unique = true },

	-- MILK ------------------------------------------------------------------
	{ requires = { "milk" }, ratios = { { "cacao", ">", 0 } }, score = 4, feedback = "taster_feedback_milk_chocolate", unique = true },

	-- MINT ------------------------------------------------------------------
	{ requires = { "mint" }, counts = { { "mint", ">=", 2 } }, score = -18, feedback = "taster_feedback_mint_overuse", voids = { "taster_feedback_mint_solo" } },
	{ requires = { "mint", "clove" }, score = -14, feedback = "taster_feedback_mint_clove_bad", voids = { "taster_feedback_mint_solo", "taster_feedback_clove_solo" } },
	{ requires = { "mint", "lime" }, ratios = { { "sugar", ">", 0.15 }, { "dairy", "==", 0 } }, categories = { "infusion", "exotic" }, score = 6, feedback = "taster_feedback_mojito", unique = true, voids = { "taster_feedback_lime_solo", "taster_feedback_mint_solo" } },
	{ requires = { "mint", "caramel" }, score = 4, feedback = "taster_feedback_mint_caramel", unique = true, voids = { "taster_feedback_mint_solo" } },
	{ requires = { "mint" }, ratios = { { "cacao", ">", 0.2 } }, score = 14, feedback = "taster_feedback_chocolate_mint", unique = true, voids = { "taster_feedback_mint_solo" } },
	{ requires = { "mint" }, score = 0, feedback = "taster_feedback_mint_solo", unique = true },

	-- NUTMEG ----------------------------------------------------------------
	{ requires = { "nutmeg" }, counts = { { "nutmeg", ">=", 2 } }, score = -18, feedback = "taster_feedback_nutmeg_overuse", voids = { "taster_feedback_nutmeg_solo" } },
	{ requires = { "nutmeg" }, score = 0, feedback = "taster_feedback_nutmeg_solo", unique = true },

	-- OAT -------------------------------------------------------------------
	{ requires = { "oat", "maple" }, score = 5, feedback = "taster_feedback_oat_sweet", unique = true, voids = { "taster_feedback_oat_solo", "taster_feedback_maple_solo" } },
	{ requires = { "oat", "honey" }, score = 5, feedback = "taster_feedback_oat_sweet", unique = true, voids = { "taster_feedback_oat_solo", "taster_feedback_honey_solo" } },
	{ requires = { "oat" }, score = 0, feedback = "taster_feedback_oat_solo", unique = true },

	-- ORANGE ----------------------------------------------------------------
	{ requires = { "orange", "mango" }, score = 6, feedback = "taster_feedback_orange_mango", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_mango_solo" } },
	{ requires = { "orange", "salt" }, ratios = { { "sugar", ">=", 0.15 } }, score = 6, feedback = "taster_feedback_salted_citrus", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_salt_solo" } },
	{ requires = { "orange", "kahlua" }, score = 4, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_kahlua_solo" } },
	{ requires = { "orange", "amaretto" }, score = 4, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_amaretto_solo" } },
	{ requires = { "orange", "grand_marnier" }, score = 4, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_grand_marnier_solo" } },
	{ requires = { "orange", "peanut" }, score = 3, feedback = "taster_feedback_orange_peanut", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "orange", "hazelnut" }, score = 4, feedback = "taster_feedback_orange_nuts", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_hazelnut_solo" } },
	{ requires = { "orange", "almond" }, score = 4, feedback = "taster_feedback_orange_almond", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_almond_solo" } },
	{ requires = { "orange" }, ratios = { { "cacao", ">", 0.2 } }, score = 14, feedback = "taster_feedback_chocolate_orange", unique = true, voids = { "taster_feedback_orange_solo" } },
	{ requires = { "orange", "cinnamon" }, score = 8, feedback = "taster_feedback_orange_cinnamon", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "orange", "clove" }, score = 6, feedback = "taster_feedback_orange_clove", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_clove_solo" } },
	{ requires = { "orange" }, score = 0, feedback = "taster_feedback_orange_solo", unique = true },

	-- PASSIONFRUIT ----------------------------------------------------------
	{ requires = { "passionfruit", "mango" }, score = 8, feedback = "taster_feedback_tropical_fruit", unique = true, voids = { "taster_feedback_passionfruit_solo", "taster_feedback_mango_solo" } },
	{ requires = { "passionfruit" }, score = 0, feedback = "taster_feedback_passionfruit_solo", unique = true },

	-- PEACH -----------------------------------------------------------------
	{ requires = { "peach", "vanilla" }, score = 5, feedback = "taster_feedback_vanilla_sweet", unique = true, voids = { "taster_feedback_vanilla_solo", "taster_feedback_peach_solo" } },
	{ requires = { "peach", "cream" }, score = 6, feedback = "taster_feedback_peach_cream", unique = true, voids = { "taster_feedback_peach_solo", "taster_feedback_cream_solo" } },
	{ requires = { "peach" }, score = 0, feedback = "taster_feedback_peach_solo", unique = true },

	-- PEANUT ----------------------------------------------------------------
	{ requires = { "peanut", "raspberry" }, score = 12, feedback = "taster_feedback_pb_and_j", unique = true, voids = { "taster_feedback_peanut_solo", "taster_feedback_raspberry_solo" } },
	{ requires = { "peanut", "strawberry" }, score = 12, feedback = "taster_feedback_pb_and_j", unique = true, voids = { "taster_feedback_peanut_solo", "taster_feedback_strawberry_solo" } },
	{ requires = { "peanut" }, ratios = { { "cacao", ">", 0.2 } }, score = 12, feedback = "taster_feedback_chocolate_peanut", unique = true, voids = { "taster_feedback_peanut_solo" } },
	{ requires = { "peanut" }, score = 0, feedback = "taster_feedback_peanut_solo", unique = true },

	-- PEAR ------------------------------------------------------------------
	{ requires = { "pear", "cinnamon" }, score = 6, feedback = "taster_feedback_autumn_spice", unique = true, voids = { "taster_feedback_cinnamon_solo", "taster_feedback_pear_solo" } },
	{ requires = { "pear" }, score = 0, feedback = "taster_feedback_pear_solo", unique = true },

	-- PECAN -----------------------------------------------------------------
	{ requires = { "pecan", "butter" }, score = 16, feedback = "taster_feedback_butter_pecan", voids = { "taster_feedback_pecan_solo", "taster_feedback_butter_solo", "taster_feedback_crunchy_smooth" } },
	{ requires = { "pecan", "caramel" }, score = 10, feedback = "taster_feedback_pecan_caramel", unique = true, voids = { "taster_feedback_pecan_solo" } },
	{ requires = { "pecan" }, score = 0, feedback = "taster_feedback_pecan_solo", unique = true },

	-- PINEAPPLE -------------------------------------------------------------
	{ requires = { "pineapple", "coconut" }, score = 10, feedback = "taster_feedback_pineapple_coconut", unique = true, voids = { "taster_feedback_pineapple_solo", "taster_feedback_coconut_solo" } },
	{ requires = { "pineapple", "mint" }, score = 3, feedback = "taster_feedback_pineapple_mint", unique = true, voids = { "taster_feedback_pineapple_solo", "taster_feedback_mint_solo" } },
	{ requires = { "pineapple", "coconut", "rum" }, score = 14, feedback = "taster_feedback_rum_pina_colada", unique = true, voids = { "taster_feedback_pineapple_coconut", "taster_feedback_pineapple_solo", "taster_feedback_coconut_solo", "taster_feedback_rum_solo" } },
	{ requires = { "pineapple" }, score = 0, feedback = "taster_feedback_pineapple_solo", unique = true },

	-- PISTACHIO -------------------------------------------------------------
	{ requires = { "pistachio", "cherry" }, ratios = { { "cacao", ">=", 0.2 } }, score = 18, feedback = "taster_feedback_spumoni", voids = { "taster_feedback_pistachio_solo", "taster_feedback_cherry_solo" } },
	{ requires = { "pistachio" }, score = 0, feedback = "taster_feedback_pistachio_solo", unique = true },

	-- PLUM ------------------------------------------------------------------
	{ requires = { "plum", "cinnamon" }, score = 5, feedback = "taster_feedback_plum_cinnamon", unique = true, voids = { "taster_feedback_plum_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "plum", "brandy" }, score = 6, feedback = "taster_feedback_plum_brandy", unique = true, voids = { "taster_feedback_plum_solo", "taster_feedback_brandy_solo" } },
	{ requires = { "plum" }, score = 0, feedback = "taster_feedback_plum_solo", unique = true },

	-- POMEGRANATE -----------------------------------------------------------
	{ requires = { "pomegranate" }, ratios = { { "cacao", ">=", 0.6 }, { "dairy", "==", 0 } }, score = 14, feedback = "taster_feedback_dark_pomegranate", voids = { "taster_feedback_pomegranate_solo" } },
	{ requires = { "pomegranate", "pistachio" }, score = 10, feedback = "taster_feedback_pomegranate_pistachio", unique = true, voids = { "taster_feedback_pomegranate_solo", "taster_feedback_pistachio_solo" } },
	{ requires = { "pomegranate" }, score = 0, feedback = "taster_feedback_pomegranate_solo", unique = true },

	-- POWDER ----------------------------------------------------------------
	{ requires = { "powder" }, counts = { { "powder", ">=", 2 } }, score = -22, feedback = "taster_feedback_powder_overuse", voids = { "taster_feedback_powder_solo" } },
	{ requires = { "powder" }, score = 0, feedback = "taster_feedback_powder_solo", unique = true },

	-- PUMPKIN ---------------------------------------------------------------
	{ requires = { "pumpkin", "cinnamon" }, score = 8, feedback = "taster_feedback_autumn_spice", unique = true, voids = { "taster_feedback_pumpkin_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "pumpkin", "nutmeg" }, score = 8, feedback = "taster_feedback_autumn_spice", unique = true, voids = { "taster_feedback_pumpkin_solo", "taster_feedback_nutmeg_solo" } },
	{ requires = { "pumpkin", "clove" }, score = 8, feedback = "taster_feedback_autumn_spice", unique = true, voids = { "taster_feedback_pumpkin_solo", "taster_feedback_clove_solo" } },
	{ requires = { "pumpkin" }, score = 0, feedback = "taster_feedback_pumpkin_solo", unique = true },

	-- RAISIN ----------------------------------------------------------------
	{ requires = { "raisin" }, score = 0, feedback = "taster_feedback_raisin_solo", unique = true },

	-- RASPBERRY -------------------------------------------------------------
	{ requires = { "raspberry" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 14, feedback = "taster_feedback_dark_tart_berry", voids = { "taster_feedback_raspberry_solo" } },
	{ requires = { "raspberry", "cream" }, score = 8, feedback = "taster_feedback_raspberry_cream", unique = true, voids = { "taster_feedback_raspberry_solo", "taster_feedback_cream_solo" } },
	{ requires = { "raspberry" }, score = 0, feedback = "taster_feedback_raspberry_solo", unique = true },

	-- RHUBARB ---------------------------------------------------------------
	{ requires = { "rhubarb", "strawberry" }, score = 8, feedback = "taster_feedback_rhubarb_strawberry", unique = true, voids = { "taster_feedback_strawberry_solo", "taster_feedback_rhubarb_solo" } },
	{ requires = { "rhubarb" }, score = 0, feedback = "taster_feedback_rhubarb_solo", unique = true },

	-- ROOIBOS ---------------------------------------------------------------
	{ requires = { "rooibos", "wasabi" }, ratios = { { "coffee", "==", 0 } }, score = -22, feedback = "taster_feedback_rooibos_wasabi_bad", voids = { "taster_feedback_rooibos_solo", "taster_feedback_wasabi_solo" } },
	{ requires = { "rooibos", "vanilla" }, score = 6, feedback = "taster_feedback_rooibos_vanilla", unique = true, voids = { "taster_feedback_rooibos_solo", "taster_feedback_vanilla_solo" } },
	{ requires = { "rooibos" }, score = 0, feedback = "taster_feedback_rooibos_solo", unique = true },

	-- ROSE ------------------------------------------------------------------
	{ requires = { "rose" }, counts = { { "rose", ">=", 2 } }, score = -20, feedback = "taster_feedback_rose_overuse", voids = { "taster_feedback_rose_solo" } },
	{ requires = { "rose" }, ratios = { { "cacao", ">=", 0.6 }, { "dairy", "==", 0 } }, score = -12, feedback = "taster_feedback_dark_rose_bad", voids = { "taster_feedback_rose_solo" } },
	{ requires = { "rose", "lavender", "jasmine" }, score = -18, feedback = "taster_feedback_floral_overload_bad", voids = { "taster_feedback_rose_solo", "taster_feedback_lavender_solo", "taster_feedback_jasmine_solo" } },
	{ requires = { "rose", "saffron" }, score = 22, feedback = "taster_feedback_rose_saffron", voids = { "taster_feedback_saffron_solo", "taster_feedback_rose_pistachio", "taster_feedback_rose_raspberry", "taster_feedback_rose_solo" } },
	{ requires = { "rose", "pistachio" }, score = 20, feedback = "taster_feedback_rose_pistachio", voids = { "taster_feedback_rose_raspberry", "taster_feedback_rose_solo", "taster_feedback_pistachio_solo" } },
	{ requires = { "rose", "raspberry" }, score = 20, feedback = "taster_feedback_rose_raspberry", voids = { "taster_feedback_raspberry_solo", "taster_feedback_rose_solo" } },
	{ requires = { "rose", "cardamom" }, score = 10, feedback = "taster_feedback_rose_cardamom", unique = true, voids = { "taster_feedback_cardamom_solo", "taster_feedback_rose_solo" } },
	{ requires = { "rose", "strawberry" }, score = 6, feedback = "taster_feedback_rose_strawberry", unique = true, voids = { "taster_feedback_strawberry_solo", "taster_feedback_rose_solo" } },
	{ requires = { "rose" }, score = 0, feedback = "taster_feedback_rose_solo", unique = true },

	-- ROSEMARY --------------------------------------------------------------
	{ requires = { "rosemary" }, counts = { { "rosemary", ">=", 2 } }, score = -18, feedback = "taster_feedback_rosemary_overuse", voids = { "taster_feedback_rosemary_solo" } },
	{ requires = { "rosemary", "marshmallow" }, score = -18, feedback = "taster_feedback_rosemary_marshmallow_bad", voids = { "taster_feedback_rosemary_solo", "taster_feedback_marshmallow_solo" } },
	{ requires = { "rosemary", "banana" }, score = -14, feedback = "taster_feedback_rosemary_banana_bad", voids = { "taster_feedback_rosemary_solo", "taster_feedback_banana_solo" } },
	{ requires = { "rosemary", "lychee" }, score = -16, feedback = "taster_feedback_rosemary_lychee_bad", voids = { "taster_feedback_rosemary_solo", "taster_feedback_lychee_solo" } },
	{ requires = { "rosemary", "lemon" }, score = 4, feedback = "taster_feedback_rosemary_citrus", unique = true, voids = { "taster_feedback_rosemary_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "rosemary", "orange" }, score = 4, feedback = "taster_feedback_rosemary_citrus", unique = true, voids = { "taster_feedback_rosemary_solo", "taster_feedback_orange_solo" } },
	{ requires = { "rosemary", "honey" }, score = 6, feedback = "taster_feedback_rosemary_honey", unique = true, voids = { "taster_feedback_rosemary_solo", "taster_feedback_honey_solo" } },
	{ requires = { "rosemary" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 8, feedback = "taster_feedback_rosemary_darkchoc", unique = true, voids = { "taster_feedback_rosemary_solo" } },
	{ requires = { "rosemary" }, score = 0, feedback = "taster_feedback_rosemary_solo", unique = true },

	-- RUM -------------------------------------------------------------------
	{ requires = { "rum", "raisin" }, score = 10, feedback = "taster_feedback_rum_raisin", unique = true, voids = { "taster_feedback_rum_solo", "taster_feedback_raisin_solo" } },
	{ requires = { "rum" }, score = 0, feedback = "taster_feedback_rum_solo", unique = true },

	-- SAFFRON ---------------------------------------------------------------
	{ requires = { "saffron" }, counts = { { "saffron", ">=", 2 } }, score = -22, feedback = "taster_feedback_saffron_overuse", voids = { "taster_feedback_saffron_solo" } },
	{ requires = { "saffron", "pistachio" }, score = 10, feedback = "taster_feedback_saffron_pistachio", unique = true, voids = { "taster_feedback_saffron_solo", "taster_feedback_pistachio_solo" } },
	{ requires = { "saffron", "almond" }, score = 8, feedback = "taster_feedback_saffron_almond", unique = true, voids = { "taster_feedback_saffron_solo", "taster_feedback_almond_solo" } },
	{ requires = { "saffron", "honey" }, score = 7, feedback = "taster_feedback_saffron_honey", unique = true, voids = { "taster_feedback_saffron_solo", "taster_feedback_honey_solo" } },
	{ requires = { "saffron", "vanilla" }, score = 6, feedback = "taster_feedback_saffron_vanilla", unique = true, voids = { "taster_feedback_saffron_solo", "taster_feedback_vanilla_solo" } },
	{ requires = { "saffron" }, score = 0, feedback = "taster_feedback_saffron_solo", unique = true },

	-- SALT ------------------------------------------------------------------
	{ requires = { "salt" }, counts = { { "salt", ">=", 2 } }, score = -30, feedback = "taster_feedback_salt_overuse", voids = { "taster_feedback_salt_solo" } },
	{ requires = { "salt", "caramel" }, score = 18, feedback = "taster_feedback_salt_sweet", voids = { "taster_feedback_salt_solo" } },
	{ requires = { "salt" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 12, feedback = "taster_feedback_dark_salt", voids = { "taster_feedback_salt_solo" } },
	{ requires = { "salt" }, score = 0, feedback = "taster_feedback_salt_solo", unique = true },

	-- SESAME ----------------------------------------------------------------
	{ requires = { "sesame", "wasabi" }, score = 6, feedback = "taster_feedback_sesame_wasabi", unique = true, voids = { "taster_feedback_sesame_solo", "taster_feedback_wasabi_solo" } },
	{ requires = { "sesame" }, ratios = { { "dairy", ">=", 0.1 }, { "dairy", "<=", 0.4 } }, score = 5, feedback = "taster_feedback_sesame_tahini", unique = true, voids = { "taster_feedback_sesame_solo" } },
	{ requires = { "sesame" }, score = 0, feedback = "taster_feedback_sesame_solo", unique = true },

	-- STAR ANISE ------------------------------------------------------------
	{ requires = { "star_anise" }, counts = { { "star_anise", ">=", 2 } }, score = -22, feedback = "taster_feedback_star_anise_overuse", voids = { "taster_feedback_star_anise_solo" } },
	{ requires = { "star_anise", "cinnamon", "clove" }, score = 12, feedback = "taster_feedback_fivespice", unique = true, voids = { "taster_feedback_star_anise_solo", "taster_feedback_cinnamon_solo", "taster_feedback_clove_solo" } },
	{ requires = { "star_anise", "orange" }, score = 6, feedback = "taster_feedback_star_anise_orange", unique = true, voids = { "taster_feedback_star_anise_solo", "taster_feedback_orange_solo" } },
	{ requires = { "star_anise", "cherry" }, score = 7, feedback = "taster_feedback_star_anise_cherry", unique = true, voids = { "taster_feedback_star_anise_solo", "taster_feedback_cherry_solo" } },
	{ requires = { "star_anise", "plum" }, score = 7, feedback = "taster_feedback_star_anise_plum", unique = true, voids = { "taster_feedback_star_anise_solo", "taster_feedback_plum_solo" } },
	{ requires = { "star_anise" }, ratios = { { "coffee", ">", 0 } }, score = 6, feedback = "taster_feedback_star_anise_coffee", unique = true, voids = { "taster_feedback_star_anise_solo" } },
	{ requires = { "star_anise" }, score = 0, feedback = "taster_feedback_star_anise_solo", unique = true },

	-- STRAWBERRY ------------------------------------------------------------
	{ requires = { "strawberry", "raspberry" }, score = 6, feedback = "taster_feedback_berries", unique = true, voids = { "taster_feedback_strawberry_solo", "taster_feedback_raspberry_solo" } },
	{ requires = { "strawberry", "cream" }, score = 8, feedback = "taster_feedback_strawberry_cream", unique = true, voids = { "taster_feedback_strawberry_solo", "taster_feedback_cream_solo" } },
	{ requires = { "strawberry" }, score = 0, feedback = "taster_feedback_strawberry_solo", unique = true },

	-- SUGAR -----------------------------------------------------------------
	{ requires = { "sugar", "caramel" }, score = 0, feedback = "taster_feedback_sugar_caramel", unique = true },
	{ requires = { "sugar", "mint" }, score = 0, feedback = "taster_feedback_sugar_mint", unique = true, voids = { "taster_feedback_mint_solo" } },
	{ requires = { "sugar", "orange" }, score = 0, feedback = "taster_feedback_sugar_orange", unique = true, voids = { "taster_feedback_orange_solo" } },
	{ requires = { "sugar", "lemon" }, score = 4, feedback = "taster_feedback_sugar_lemon", unique = true, voids = { "taster_feedback_lemon_solo" } },

	-- SUMAC -----------------------------------------------------------------
	{ requires = { "sumac" }, counts = { { "sumac", ">=", 2 } }, score = -18, feedback = "taster_feedback_sumac_overuse", voids = { "taster_feedback_sumac_solo" } },
	{ requires = { "sumac" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 12, feedback = "taster_feedback_sumac_dark", voids = { "taster_feedback_sumac_solo" } },
	{ requires = { "sumac", "salt" }, score = 8, feedback = "taster_feedback_sumac_salt", unique = true, voids = { "taster_feedback_sumac_solo", "taster_feedback_salt_solo" } },
	{ requires = { "sumac", "honey" }, score = 6, feedback = "taster_feedback_sumac_honey", unique = true, voids = { "taster_feedback_sumac_solo", "taster_feedback_honey_solo" } },
	{ requires = { "sumac", "cayenne" }, score = 6, feedback = "taster_feedback_sumac_cayenne", unique = true, voids = { "taster_feedback_sumac_solo", "taster_feedback_cayenne_solo" } },
	{ requires = { "sumac", "strawberry" }, score = 4, feedback = "taster_feedback_sumac_berry", unique = true, voids = { "taster_feedback_sumac_solo", "taster_feedback_strawberry_solo" } },
	{ requires = { "sumac", "raspberry" }, score = 4, feedback = "taster_feedback_sumac_berry", unique = true, voids = { "taster_feedback_sumac_solo", "taster_feedback_raspberry_solo" } },
	{ requires = { "sumac", "blueberry" }, score = 4, feedback = "taster_feedback_sumac_berry", unique = true, voids = { "taster_feedback_sumac_solo", "taster_feedback_blueberry_solo" } },
	{ requires = { "sumac", "blackberry" }, score = 4, feedback = "taster_feedback_sumac_berry", unique = true, voids = { "taster_feedback_sumac_solo", "taster_feedback_blackberry_solo" } },
	{ requires = { "sumac" }, score = 0, feedback = "taster_feedback_sumac_solo", unique = true },

	-- TAMARIND --------------------------------------------------------------
	{ requires = { "tamarind" }, counts = { { "tamarind", ">=", 2 } }, score = -18, feedback = "taster_feedback_tamarind_overuse", voids = { "taster_feedback_tamarind_solo" } },
	{ requires = { "tamarind", "lavender" }, score = -16, feedback = "taster_feedback_tamarind_lavender_bad", voids = { "taster_feedback_tamarind_solo", "taster_feedback_lavender_solo" } },
	{ requires = { "tamarind", "rose" }, score = -16, feedback = "taster_feedback_tamarind_rose_bad", voids = { "taster_feedback_tamarind_solo", "taster_feedback_rose_solo" } },
	{ requires = { "tamarind", "mango" }, score = 6, feedback = "taster_feedback_tamarind_mango", unique = true, voids = { "taster_feedback_tamarind_solo", "taster_feedback_mango_solo" } },
	{ requires = { "tamarind", "coconut" }, score = 5, feedback = "taster_feedback_tamarind_coconut", unique = true, voids = { "taster_feedback_tamarind_solo", "taster_feedback_coconut_solo" } },
	{ requires = { "tamarind", "ginger" }, score = 7, feedback = "taster_feedback_tamarind_ginger", unique = true, voids = { "taster_feedback_tamarind_solo", "taster_feedback_ginger_solo" } },
	{ requires = { "tamarind", "caramel" }, score = 7, feedback = "taster_feedback_tamarind_caramel", unique = true, voids = { "taster_feedback_tamarind_solo" } },
	{ requires = { "tamarind" }, ratios = { { "cacao", ">=", 0.5 }, { "dairy", "==", 0 } }, score = 8, feedback = "taster_feedback_tamarind_darkchoc", unique = true, voids = { "taster_feedback_tamarind_solo" } },
	{ requires = { "tamarind" }, score = 0, feedback = "taster_feedback_tamarind_solo", unique = true },

	-- TEA -------------------------------------------------------------------
	{ requires = { "tea" }, counts = { { "tea", ">=", 2 } }, score = -16, feedback = "taster_feedback_tea_overuse", voids = { "taster_feedback_blacktea_solo" } },
	{ requires = { "tea", "rose" }, score = 6, feedback = "taster_feedback_blacktea_rose", unique = true, voids = { "taster_feedback_blacktea_solo", "taster_feedback_rose_solo" } },
	{ requires = { "tea", "hibiscus" }, score = 6, feedback = "taster_feedback_blacktea_hibiscus", unique = true, voids = { "taster_feedback_blacktea_solo", "taster_feedback_hibiscus_solo" } },
	{ requires = { "tea", "cinnamon" }, score = 6, feedback = "taster_feedback_blacktea_cinnamon", unique = true, voids = { "taster_feedback_blacktea_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "tea", "orange" }, score = 5, feedback = "taster_feedback_blacktea_orange", unique = true, voids = { "taster_feedback_blacktea_solo", "taster_feedback_orange_solo" } },
	{ requires = { "tea" }, score = 0, feedback = "taster_feedback_blacktea_solo", unique = true },

	-- TOFFEE ----------------------------------------------------------------
	{ requires = { "toffee" }, counts = { { "toffee", ">=", 3 } }, score = -16, feedback = "taster_feedback_toffee_overuse", voids = { "taster_feedback_toffee_solo" } },
	{ requires = { "toffee", "walnut" }, score = 8, feedback = "taster_feedback_toffee_nut", unique = true, voids = { "taster_feedback_toffee_solo", "taster_feedback_walnut_solo" } },
	{ requires = { "toffee", "almond" }, score = 8, feedback = "taster_feedback_toffee_nut", unique = true, voids = { "taster_feedback_toffee_solo", "taster_feedback_almond_solo" } },
	{ requires = { "toffee" }, score = 0, feedback = "taster_feedback_toffee_solo", unique = true },

	-- TURMERIC --------------------------------------------------------------
	{ requires = { "turmeric" }, counts = { { "turmeric", ">=", 2 } }, score = -20, feedback = "taster_feedback_turmeric_overuse", voids = { "taster_feedback_turmeric_solo" } },
	{ requires = { "turmeric", "mint" }, score = -12, feedback = "taster_feedback_turmeric_mint_bad", voids = { "taster_feedback_turmeric_solo", "taster_feedback_mint_solo" } },
	{ requires = { "turmeric", "ginger" }, score = 4, feedback = "taster_feedback_turmeric_ginger", unique = true, voids = { "taster_feedback_turmeric_solo", "taster_feedback_ginger_solo" } },
	{ requires = { "turmeric" }, score = 0, feedback = "taster_feedback_turmeric_solo", unique = true },

	-- VANILLA ---------------------------------------------------------------
	{ requires = { "vanilla" }, counts = { { "vanilla", ">=", 2 } }, score = -18, feedback = "taster_feedback_vanilla_overuse", voids = { "taster_feedback_vanilla_solo" } },
	{ requires = { "vanilla", "cayenne" }, forbids = { "cinnamon" }, ratios = { { "cacao", ">", 0 }, { "dairy", "==", 0 } }, score = 18, feedback = "taster_feedback_mesoamerican", voids = { "taster_feedback_vanilla_solo", "taster_feedback_cayenne_solo", "taster_feedback_spicy_chocolate" } },
	{ requires = { "vanilla", "caramel" }, score = 5, feedback = "taster_feedback_vanilla_sweet", unique = true, voids = { "taster_feedback_vanilla_solo" } },
	{ requires = { "vanilla", "maple" }, score = 5, feedback = "taster_feedback_vanilla_sweet", unique = true, voids = { "taster_feedback_vanilla_solo", "taster_feedback_maple_solo" } },
	{ requires = { "vanilla", "cherry" }, score = 5, feedback = "taster_feedback_vanilla_sweet", unique = true, voids = { "taster_feedback_vanilla_solo", "taster_feedback_cherry_solo" } },
	{ requires = { "vanilla", "lavender" }, score = 6, feedback = "taster_feedback_lavender_vanilla", unique = true, voids = { "taster_feedback_vanilla_solo", "taster_feedback_lavender_solo" } },
	{ requires = { "vanilla", "rose" }, score = 6, feedback = "taster_feedback_rose_vanilla", unique = true, voids = { "taster_feedback_vanilla_solo", "taster_feedback_rose_solo" } },
	{ requires = { "vanilla" }, score = 0, feedback = "taster_feedback_vanilla_solo", unique = true },

	-- WAFER -----------------------------------------------------------------
	{ requires = { "wafer", "hazelnut" }, score = 5, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_hazelnut_solo", "taster_feedback_wafer_solo" } },
	{ requires = { "wafer", "almond" }, score = 5, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_almond_solo", "taster_feedback_wafer_solo" } },
	{ requires = { "wafer" }, score = 0, feedback = "taster_feedback_wafer_solo", unique = true },

	-- WALNUT ----------------------------------------------------------------
	{ requires = { "walnut" }, score = 0, feedback = "taster_feedback_walnut_solo", unique = true },

	-- WASABI ----------------------------------------------------------------
	{ requires = { "wasabi" }, counts = { { "wasabi", ">=", 2 } }, score = -32, feedback = "taster_feedback_wasabi_overuse", voids = { "taster_feedback_wasabi_solo" } },
	-- Fruit is not categorically bad with wasabi. Keep only combinations where
	-- the fruit is too soft/delicate to stand up to the pungency; citrus and
	-- berries are left open for experimentation, with yuzu and lime rewarded.
	{ requires = { "wasabi", "banana" }, score = -18, feedback = "taster_feedback_wasabi_banana_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_banana_solo" } },
	{ requires = { "wasabi", "pear" }, score = -16, feedback = "taster_feedback_wasabi_pear_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_pear_solo" } },
	{ requires = { "wasabi", "cayenne" }, score = -36, feedback = "taster_feedback_wasabi_cayenne_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_cayenne_solo" } },
	{ requires = { "wasabi", "lavender" }, score = -24, feedback = "taster_feedback_wasabi_lavender_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_lavender_solo" } },
	{ requires = { "wasabi", "chamomile" }, score = -24, feedback = "taster_feedback_chamomile_wasabi_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_chamomile_solo" } },
	{ requires = { "wasabi", "earl_grey" }, score = -22, feedback = "taster_feedback_earl_grey_wasabi_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_earl_grey_solo" } },
	{ requires = { "wasabi", "marshmallow" }, score = -28, feedback = "taster_feedback_wasabi_marshmallow_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_marshmallow_solo" } },
	{ requires = { "wasabi", "oat" }, score = -18, feedback = "taster_feedback_wasabi_oat_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_oat_solo" } },
	{ requires = { "wasabi", "saffron" }, score = -24, feedback = "taster_feedback_wasabi_saffron_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_saffron_solo" } },
	{ requires = { "wasabi", "coconut" }, score = 18, feedback = "taster_feedback_wasabi_coconut", voids = { "taster_feedback_wasabi_solo", "taster_feedback_coconut_solo" } },
	{ requires = { "wasabi", "cashew" }, score = 7, feedback = "taster_feedback_wasabi_cashew", unique = true, voids = { "taster_feedback_wasabi_solo", "taster_feedback_cashew_solo" } },
	{ requires = { "wasabi", "pistachio" }, score = 7, feedback = "taster_feedback_wasabi_pistachio", unique = true, voids = { "taster_feedback_wasabi_solo", "taster_feedback_pistachio_solo" } },
	{ requires = { "wasabi", "yuzu" }, score = 8, feedback = "taster_feedback_wasabi_yuzu", unique = true, voids = { "taster_feedback_wasabi_solo", "taster_feedback_yuzu_solo" } },
	{ requires = { "wasabi", "lime" }, score = 7, feedback = "taster_feedback_wasabi_lime", unique = true, voids = { "taster_feedback_wasabi_solo", "taster_feedback_lime_solo" } },
	{ requires = { "wasabi", "ginger" }, score = 6, feedback = "taster_feedback_wasabi_ginger", unique = true, voids = { "taster_feedback_wasabi_solo", "taster_feedback_ginger_solo" } },
	{ requires = { "wasabi", "salt" }, score = 5, feedback = "taster_feedback_wasabi_salt", unique = true, voids = { "taster_feedback_wasabi_solo", "taster_feedback_salt_solo" } },
	{ requires = { "wasabi" }, ratios = { { "cacao", ">=", 0.6 } }, score = 10, feedback = "taster_feedback_wasabi_darkchoc", unique = true, voids = { "taster_feedback_wasabi_solo", "taster_feedback_spicy_chocolate" } },
	{ requires = { "wasabi" }, ratios = { { "cacao", ">", 0 }, { "cacao", "<", 0.6 } }, score = 4, feedback = "taster_feedback_spicy_chocolate", unique = true, voids = { "taster_feedback_wasabi_solo" } },
	{ requires = { "wasabi" }, score = 0, feedback = "taster_feedback_wasabi_solo", unique = true },

	-- WHIPPED CREAM ---------------------------------------------------------
	-- Aeration should be commercially useful, but repeating it quickly turns a
	-- structured confection into sweet dairy foam. Specific overuse supersedes
	-- the generic all-dairy complaint and positive whipped-cream observations.
	{ requires = { "whipped_cream" }, counts = { { "whipped_cream", ">=", 2 } }, score = -22, feedback = "taster_feedback_whipped_cream_overuse", voids = { "taster_choco_alldairy", "taster_feedback_whipped_cream_solo", "taster_feedback_whipped_cream_chocolate", "taster_feedback_whipped_cream_darkchoc", "taster_feedback_whipped_cream_strawberry", "taster_feedback_whipped_cream_raspberry", "taster_feedback_whipped_cream_peach", "taster_feedback_whipped_cream_vanilla", "taster_feedback_whipped_cream_caramel", "taster_feedback_whipped_cream_matcha", "taster_feedback_black_forest" } },
	{ requires = { "whipped_cream", "strawberry" }, score = 10, feedback = "taster_feedback_whipped_cream_strawberry", unique = true, voids = { "taster_feedback_whipped_cream_chocolate", "taster_feedback_whipped_cream_solo", "taster_feedback_strawberry_solo" } },
	{ requires = { "whipped_cream", "raspberry" }, score = 9, feedback = "taster_feedback_whipped_cream_raspberry", unique = true, voids = { "taster_feedback_whipped_cream_chocolate", "taster_feedback_whipped_cream_solo", "taster_feedback_raspberry_solo" } },
	{ requires = { "whipped_cream", "peach" }, score = 8, feedback = "taster_feedback_whipped_cream_peach", unique = true, voids = { "taster_feedback_whipped_cream_chocolate", "taster_feedback_whipped_cream_solo", "taster_feedback_peach_solo" } },
	{ requires = { "whipped_cream", "vanilla" }, score = 7, feedback = "taster_feedback_whipped_cream_vanilla", unique = true, voids = { "taster_feedback_whipped_cream_chocolate", "taster_feedback_whipped_cream_solo", "taster_feedback_vanilla_solo" } },
	{ requires = { "whipped_cream", "caramel" }, score = 8, feedback = "taster_feedback_whipped_cream_caramel", unique = true, voids = { "taster_feedback_whipped_cream_chocolate", "taster_feedback_whipped_cream_solo" } },
	{ requires = { "whipped_cream", "matcha" }, score = 8, feedback = "taster_feedback_whipped_cream_matcha", unique = true, voids = { "taster_feedback_whipped_cream_chocolate", "taster_feedback_whipped_cream_solo", "taster_feedback_matcha_solo" } },
	{ requires = { "whipped_cream" }, ratios = { { "cacao", ">=", 0.5 } }, score = 10, feedback = "taster_feedback_whipped_cream_darkchoc", unique = true, voids = { "taster_feedback_whipped_cream_solo", "taster_feedback_whipped_cream_chocolate" } },
	{ requires = { "whipped_cream" }, ratios = { { "cacao", ">", 0 } }, score = 6, feedback = "taster_feedback_whipped_cream_chocolate", unique = true, voids = { "taster_feedback_whipped_cream_solo" } },
	{ requires = { "whipped_cream" }, score = 0, feedback = "taster_feedback_whipped_cream_solo", unique = true },

	-- WHISKEY ---------------------------------------------------------------
	{ requires = { "whiskey", "wasabi" }, score = -35, feedback = "taster_feedback_whiskey_wasabi_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_whiskey_solo" } },
	{ requires = { "whiskey", "rum", "brandy" }, score = -18, feedback = "taster_feedback_booze_overload_bad", voids = { "taster_feedback_whiskey_solo", "taster_feedback_rum_solo", "taster_feedback_brandy_solo" } },
	{ requires = { "whiskey", "caramel" }, score = 18, feedback = "taster_feedback_boozy_caramel", voids = { "taster_feedback_whiskey_solo" } },
	{ requires = { "whiskey", "cherry" }, categories = { "truffle" }, score = 10, feedback = "taster_feedback_whiskey_cherry", unique = true, voids = { "taster_feedback_whiskey_solo", "taster_feedback_cherry_solo" } },
	{ requires = { "whiskey" }, score = 0, feedback = "taster_feedback_whiskey_solo", unique = true },

	-- YUZU ------------------------------------------------------------------
	{ requires = { "yuzu" }, counts = { { "yuzu", ">=", 2 } }, score = -16, feedback = "taster_feedback_yuzu_overuse", voids = { "taster_feedback_yuzu_solo" } },
	{ requires = { "yuzu" }, score = 0, feedback = "taster_feedback_yuzu_solo", unique = true },
}

------------------------------------------------------------------------------
-- DRINKS AND BEVERAGE-BLEND RULES
------------------------------------------------------------------------------

CoffeeEvaluators =
{
	-- =======================================================================
	-- GLOBAL / BEVERAGE STRUCTURE
	-- The legacy CoffeeEvaluators name is retained for save/mod compatibility.
	-- Served Drinks and packaged Beverage Blends may be coffee-, cacao-, tea-,
	-- dairy-, fruit-, spice-, or otherwise based; only context-specific faults
	-- below should assume coffee is present.
	-- =======================================================================
	{ ratios = { { "coffee", ">", 0 }, { "dairy", ">=", 0.8 } }, score = -55, feedback = "taster_coffee_alldairy", voids = { "taster_feedback_butter_solo", "taster_feedback_cream_solo", "taster_feedback_whipped_cream_solo" } },
	{ ratios = { { "coffee", ">", 0 }, { "sugar", ">=", 0.8 } }, score = -55, feedback = "taster_coffee_allsugar", voids = { "taster_feedback_honey_solo", "taster_feedback_toffee_solo" } },
	{ ratios = { { "coffee", ">", 0 }, { "flavor", ">=", 0.8 } }, score = -45, feedback = "taster_coffee_allflavors" },
	{ ratios = { { "coffee", ">", 0 }, { "cacao", ">=", 0.7 } }, score = -55, feedback = "taster_coffee_allcacao" },
	{ categories = { "beverage", "blend" }, ratios = { { "coffee", ">", 0 }, { "fruit", ">=", 0.5 } }, score = -25, feedback = "taster_coffee_nofruit" },
	{ categories = { "beverage", "blend" }, ratios = { { "coffee", ">", 0 }, { "nut", ">=", 0.5 } }, score = -25, feedback = "taster_coffee_nonuts" },
	{ trait_counts = { { "alcohol", ">=", 2 } }, ratios = { { "coffee", ">", 0 } }, score = -20, feedback = "taster_feedback_coffee_alcohol_overuse", voids = { "taster_feedback_booze_overload_bad", "taster_feedback_coffee_nutty_irish", "taster_feedback_coffee_tropical", "taster_feedback_kahlua_cream", "taster_feedback_kahlua_milk", "taster_feedback_coffee_amaretto_almond", "taster_feedback_coffee_whiskey", "taster_feedback_coffee_brandy", "taster_feedback_coffee_grand_marnier", "taster_feedback_coffee_amaretto", "taster_feedback_coffee_kahlua", "taster_feedback_coffee_caribbean_rum", "taster_feedback_coffee_irish_cream_build", "taster_feedback_coffee_mocha_valencia" } },
	{ ratios = { { "coffee", ">", 0 }, { "cacao", ">", 0 }, { "cacao", "<", 0.7 } }, score = 12, feedback = "taster_feedback_mocha" },

	-- =======================================================================
	-- SERVED DRINK SIGNATURES
	-- Finished-drink archetypes only. Packaged Beverage Blends deliberately do
	-- not inherit these names just because they contain similar ingredients.
	-- More specific signatures void broader pairings/archetypes where needed.
	-- =======================================================================

	-- MILKSHAKES / SMOOTHIES ------------------------------------------------
	{ requires = { "ice_cream", "milk", "banana", "peanut" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 } }, score = 24, feedback = "taster_feedback_milkshake_peanut_banana", voids = { "taster_feedback_milkshake_banana", "taster_feedback_banana_peanut", "taster_feedback_ice_cream_solo", "taster_feedback_banana_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "ice_cream", "milk", "caramel", "salt" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 } }, score = 24, feedback = "taster_feedback_milkshake_salted_caramel", voids = { "taster_feedback_ice_cream_solo", "taster_feedback_salt_solo" } },
	{ requires = { "ice_cream", "milk", "cherry", "vanilla" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 } }, score = 22, feedback = "taster_feedback_milkshake_cherry_vanilla", voids = { "taster_feedback_milkshake_vanilla", "taster_feedback_ice_cream_solo", "taster_feedback_cherry_solo", "taster_feedback_vanilla_solo" } },
	{ requires = { "ice_cream", "milk", "raspberry" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", ">", 0 } }, score = 22, feedback = "taster_feedback_milkshake_raspberry_chocolate", voids = { "taster_feedback_milkshake_chocolate", "taster_feedback_ice_cream_solo", "taster_feedback_raspberry_solo" } },
	{ requires = { "ice_cream", "milk", "espresso" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, score = 24, feedback = "taster_feedback_milkshake_coffee", voids = { "taster_feedback_coffee_affogato", "taster_feedback_espresso_profile", "taster_feedback_espresso_solo", "taster_feedback_ice_cream_solo" } },
	{ requires = { "ice_cream", "milk", "pineapple", "coconut" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 } }, score = 22, feedback = "taster_feedback_milkshake_tropical", voids = { "taster_feedback_pineapple_coconut", "taster_feedback_ice_cream_solo", "taster_feedback_pineapple_solo", "taster_feedback_coconut_solo" } },
	{ requires = { "milk", "strawberry", "banana" }, forbids = { "ice_cream" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 } }, score = 16, feedback = "taster_feedback_smoothie_strawberry_banana", voids = { "taster_feedback_strawberry_solo", "taster_feedback_banana_solo" } },
	{ requires = { "milk", "mango", "coconut" }, forbids = { "ice_cream" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 } }, score = 16, feedback = "taster_feedback_smoothie_mango_coconut", voids = { "taster_feedback_mango_solo", "taster_feedback_coconut_solo" } },
	{ requires = { "milk", "blueberry", "honey" }, forbids = { "ice_cream" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 } }, score = 16, feedback = "taster_feedback_smoothie_blueberry_honey", voids = { "taster_feedback_blueberry_solo", "taster_feedback_honey_solo" } },

	-- HOT CHOCOLATE ---------------------------------------------------------
	{ requires = { "milk", "mint" }, forbids = { "ice_cream" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", ">", 0 } }, score = 22, feedback = "taster_feedback_hot_chocolate_mint", voids = { "taster_feedback_hot_chocolate", "taster_feedback_chocolate_mint", "taster_feedback_mint_solo" } },
	{ requires = { "milk", "orange" }, forbids = { "ice_cream" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", ">", 0 } }, score = 20, feedback = "taster_feedback_hot_chocolate_orange", voids = { "taster_feedback_hot_chocolate", "taster_feedback_chocolate_orange", "taster_feedback_orange_solo" } },
	{ requires = { "milk", "cinnamon" }, forbids = { "ice_cream", "cayenne" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", ">", 0 } }, score = 20, feedback = "taster_feedback_hot_chocolate_cinnamon", voids = { "taster_feedback_hot_chocolate", "taster_feedback_cinnamon_solo" } },
	{ requires = { "milk", "cinnamon", "cayenne" }, forbids = { "ice_cream" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", ">", 0 } }, score = 26, feedback = "taster_feedback_hot_chocolate_spiced", voids = { "taster_feedback_hot_chocolate", "taster_feedback_hot_chocolate_cinnamon", "taster_feedback_spicy_chocolate", "taster_feedback_cinnamon_solo", "taster_feedback_cayenne_solo" } },
	{ requires = { "milk", "caramel", "salt" }, forbids = { "ice_cream" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", ">", 0 } }, score = 24, feedback = "taster_feedback_hot_chocolate_salted_caramel", voids = { "taster_feedback_hot_chocolate", "taster_feedback_salt_solo" } },
	{ requires = { "milk", "coconut" }, forbids = { "ice_cream" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", ">", 0 } }, score = 20, feedback = "taster_feedback_hot_chocolate_coconut", voids = { "taster_feedback_hot_chocolate", "taster_feedback_chocolate_coconut", "taster_feedback_coconut_solo" } },
	{ requires = { "milk", "marshmallow" }, forbids = { "ice_cream" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", ">", 0 } }, score = 22, feedback = "taster_feedback_hot_chocolate_marshmallow", voids = { "taster_feedback_hot_chocolate", "taster_feedback_chocolate_marshmallow", "taster_feedback_marshmallow_solo" } },

	-- ALCOHOL-FREE COOLERS / MOCKTAILS -------------------------------------
	{ requires = { "lime", "mint", "sugar" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 18, feedback = "taster_feedback_mocktail_mint_lime", voids = { "taster_feedback_limeade", "taster_feedback_lime_solo", "taster_feedback_mint_solo" } },
	{ requires = { "lemon", "sugar", "strawberry" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 18, feedback = "taster_feedback_lemonade_strawberry", voids = { "taster_feedback_lemonade", "taster_feedback_lemon_solo", "taster_feedback_strawberry_solo" } },
	{ requires = { "lemon", "sugar", "raspberry" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 18, feedback = "taster_feedback_lemonade_raspberry", voids = { "taster_feedback_lemonade", "taster_feedback_lemon_solo", "taster_feedback_raspberry_solo" } },
	{ requires = { "passionfruit", "lime", "sugar" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 18, feedback = "taster_feedback_mocktail_passionfruit_lime", voids = { "taster_feedback_limeade", "taster_feedback_passionfruit_solo", "taster_feedback_lime_solo" } },
	{ requires = { "pomegranate", "lime", "sugar" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 18, feedback = "taster_feedback_mocktail_pomegranate_lime", voids = { "taster_feedback_limeade", "taster_feedback_pomegranate_solo", "taster_feedback_lime_solo" } },
	{ requires = { "cranberry", "orange", "sugar" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 18, feedback = "taster_feedback_mocktail_cranberry_orange", voids = { "taster_feedback_cranberry_orange", "taster_feedback_cranberry_solo", "taster_feedback_orange_solo" } },
	{ requires = { "hibiscus", "orange", "honey" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 18, feedback = "taster_feedback_mocktail_hibiscus_citrus", voids = { "taster_feedback_hibiscus_orange", "taster_feedback_hibiscus_honey", "taster_feedback_hibiscus_solo", "taster_feedback_orange_solo", "taster_feedback_honey_solo" } },
	{ requires = { "mango", "ginger", "lime" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 18, feedback = "taster_feedback_mocktail_mango_ginger", voids = { "taster_feedback_mango_solo", "taster_feedback_ginger_solo", "taster_feedback_lime_solo" } },
	{ requires = { "yuzu", "ginger", "honey" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 18, feedback = "taster_feedback_mocktail_yuzu_ginger", voids = { "taster_feedback_yuzu_solo", "taster_feedback_ginger_solo", "taster_feedback_honey_solo" } },
	{ requires = { "pineapple", "coconut", "lime" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 18, feedback = "taster_feedback_mocktail_tropical_cooler", voids = { "taster_feedback_pineapple_coconut", "taster_feedback_pineapple_solo", "taster_feedback_coconut_solo", "taster_feedback_lime_solo" } },
	{ requires = { "tea", "lemon", "sugar" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 18, feedback = "taster_feedback_tea_lemonade", voids = { "taster_feedback_blacktea_lemon", "taster_feedback_blacktea_solo", "taster_feedback_lemon_solo" } },

	-- COCKTAILS / SPIRIT-LED DRINKS ----------------------------------------
	{ requires = { "rum", "lime", "mint", "sugar" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 28, feedback = "taster_feedback_mojito", voids = { "taster_feedback_cocktail_daiquiri", "taster_feedback_mocktail_mint_lime", "taster_feedback_limeade", "taster_feedback_rum_solo", "taster_feedback_lime_solo", "taster_feedback_mint_solo" } },
	{ requires = { "rum", "lime", "sugar" }, forbids = { "mint" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 24, feedback = "taster_feedback_cocktail_daiquiri", voids = { "taster_feedback_limeade", "taster_feedback_rum_solo", "taster_feedback_lime_solo" } },
	{ requires = { "rum", "pineapple", "orange", "lime" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 26, feedback = "taster_feedback_cocktail_rum_punch", voids = { "taster_feedback_rum_solo", "taster_feedback_pineapple_solo", "taster_feedback_orange_solo", "taster_feedback_lime_solo" } },
	{ requires = { "amaretto", "lemon", "sugar" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 22, feedback = "taster_feedback_cocktail_almond_sour", voids = { "taster_feedback_amaretto_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "whiskey", "lemon", "sugar" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 22, feedback = "taster_feedback_cocktail_whiskey_sour", voids = { "taster_feedback_whiskey_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "brandy", "grand_marnier", "lemon" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 2 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 28, feedback = "taster_feedback_cocktail_sidecar", voids = { "taster_feedback_brandy_solo", "taster_feedback_grand_marnier_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "brandy", "cream" }, forbids = { "milk", "ice_cream" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", "==", 0 }, { "cacao", ">", 0 } }, score = 26, feedback = "taster_feedback_cocktail_brandy_alexander", voids = { "taster_feedback_brandy_solo", "taster_feedback_cream_solo" } },
	{ requires = { "whiskey", "amaretto" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 2 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 20, feedback = "taster_feedback_cocktail_whiskey_almond", voids = { "taster_feedback_whiskey_solo", "taster_feedback_amaretto_solo" } },
	{ requires = { "brandy", "amaretto" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 2 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 20, feedback = "taster_feedback_cocktail_brandy_almond", voids = { "taster_feedback_brandy_solo", "taster_feedback_amaretto_solo" } },
	{ requires = { "rum", "butter", "sugar", "cinnamon" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 } }, score = 26, feedback = "taster_feedback_cocktail_hot_buttered_rum", voids = { "taster_feedback_rum_solo", "taster_feedback_butter_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "kahlua", "ice_cream", "milk" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", "==", 0 } }, score = 24, feedback = "taster_feedback_cocktail_kahlua_shake", voids = { "taster_feedback_kahlua_solo", "taster_feedback_ice_cream_solo" } },
	{ requires = { "grand_marnier", "milk" }, forbids = { "ice_cream" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", "==", 0 }, { "cacao", ">", 0 } }, score = 24, feedback = "taster_feedback_cocktail_orange_hot_chocolate", voids = { "taster_feedback_hot_chocolate", "taster_feedback_hot_chocolate_orange", "taster_feedback_grand_marnier_solo" } },
	{ requires = { "whiskey", "milk" }, forbids = { "ice_cream" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", "==", 0 }, { "cacao", ">", 0 } }, score = 22, feedback = "taster_feedback_cocktail_whiskey_hot_chocolate", voids = { "taster_feedback_hot_chocolate", "taster_feedback_whiskey_solo" } },

	-- ALLSPICE --------------------------------------------------------------
	{ requires = { "allspice" }, counts = { { "allspice", ">=", 2 } }, score = -20, feedback = "taster_feedback_allspice_overuse", voids = { "taster_feedback_allspice_solo" } },
	{ requires = { "allspice", "apple" }, score = 5, feedback = "taster_feedback_allspice_apple", unique = true, voids = { "taster_feedback_allspice_solo", "taster_feedback_apple_solo" } },
	{ requires = { "allspice", "pumpkin" }, score = 6, feedback = "taster_feedback_allspice_pumpkin", unique = true, voids = { "taster_feedback_allspice_solo", "taster_feedback_pumpkin_solo" } },
	{ requires = { "allspice", "orange" }, score = 5, feedback = "taster_feedback_allspice_orange", unique = true, voids = { "taster_feedback_allspice_solo", "taster_feedback_orange_solo" } },
	{ requires = { "allspice" }, score = 0, feedback = "taster_feedback_allspice_solo", unique = true },

	-- ALMOND ----------------------------------------------------------------
	{ requires = { "almond" }, score = 0, feedback = "taster_feedback_almond_solo", unique = true },

	-- AMARETTO --------------------------------------------------------------
	{ requires = { "amaretto", "almond" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", ">", 0 } }, score = 12, feedback = "taster_feedback_coffee_amaretto_almond", voids = { "taster_feedback_amaretto_solo", "taster_feedback_almond_solo" } },
	{ requires = { "amaretto" }, forbids = { "almond" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", ">", 0 } }, score = 7, feedback = "taster_feedback_coffee_amaretto", unique = true, voids = { "taster_feedback_amaretto_solo" } },
	{ requires = { "amaretto" }, score = 0, feedback = "taster_feedback_amaretto_solo", unique = true },

	-- ANISE -----------------------------------------------------------------
	{ requires = { "anise" }, counts = { { "anise", ">=", 2 } }, score = -22, feedback = "taster_feedback_anise_overuse", voids = { "taster_feedback_anise_solo" } },
	{ requires = { "anise", "star_anise", "clove" }, score = -18, feedback = "taster_feedback_spice_medicine_bad", voids = { "taster_feedback_anise_solo", "taster_feedback_star_anise_solo", "taster_feedback_clove_solo" } },
	{ requires = { "anise" }, counts = { { "anise", "==", 1 } }, ratios = { { "coffee", ">", 0 } }, score = 6, feedback = "taster_feedback_anise_coffee", unique = true, voids = { "taster_feedback_anise_solo" } },
	{ requires = { "anise", "orange" }, score = 5, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_anise_solo", "taster_feedback_orange_solo" } },
	{ requires = { "anise", "kahlua" }, score = 5, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_anise_solo", "taster_feedback_kahlua_solo" } },
	{ requires = { "anise", "amaretto" }, score = 5, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_anise_solo", "taster_feedback_amaretto_solo" } },
	{ requires = { "anise", "grand_marnier" }, score = 5, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_anise_solo", "taster_feedback_grand_marnier_solo" } },
	{ requires = { "anise" }, score = 0, feedback = "taster_feedback_anise_solo", unique = true },

	-- APPLE -----------------------------------------------------------------
	{ requires = { "apple", "cinnamon" }, score = 5, feedback = "taster_feedback_apple_cinnamon", unique = true, voids = { "taster_feedback_apple_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "apple", "caramel" }, score = 6, feedback = "taster_feedback_apple_caramel", unique = true, voids = { "taster_feedback_apple_solo" } },
	{ requires = { "apple" }, score = 0, feedback = "taster_feedback_apple_solo", unique = true },

	-- APRICOT ---------------------------------------------------------------
	{ requires = { "apricot", "almond" }, score = 6, feedback = "taster_feedback_apricot_almond", unique = true, voids = { "taster_feedback_apricot_solo", "taster_feedback_almond_solo" } },
	{ requires = { "apricot", "amaretto" }, score = 6, feedback = "taster_feedback_apricot_almond", unique = true, voids = { "taster_feedback_apricot_solo", "taster_feedback_amaretto_solo" } },
	{ requires = { "apricot" }, score = 0, feedback = "taster_feedback_apricot_solo", unique = true },

	-- BALI COFFEE -----------------------------------------------------------
	{ requires = { "bal_coffee", "coconut" }, forbids = { "bog_coffee", "hav_coffee", "kon_coffee", "tan_coffee", "espresso" }, score = 12, feedback = "taster_feedback_indonesian_coconut_coffee", voids = { "taster_feedback_bal_coffee_profile", "taster_feedback_coconut_solo" } },
	{ requires = { "bal_coffee", "ginger" }, forbids = { "bog_coffee", "hav_coffee", "kon_coffee", "tan_coffee", "espresso", "mint" }, counts = { { "ginger", "==", 1 } }, score = 14, feedback = "taster_feedback_coffee_kopi_jahe", voids = { "taster_feedback_bal_coffee_profile", "taster_feedback_ginger_solo" } },
	{ requires = { "bal_coffee" }, score = 0, feedback = "taster_feedback_bal_coffee_profile", unique = true },

	-- BANANA ----------------------------------------------------------------
	{ requires = { "banana", "caramel" }, score = 5, feedback = "taster_feedback_banana_caramel", unique = true, voids = { "taster_feedback_banana_solo" } },
	{ requires = { "banana", "peanut" }, score = 5, feedback = "taster_feedback_banana_peanut", unique = true, voids = { "taster_feedback_banana_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "banana", "rum" }, score = 5, feedback = "taster_feedback_banana_rum", unique = true, voids = { "taster_feedback_banana_solo", "taster_feedback_rum_solo" } },
	{ requires = { "banana" }, score = 0, feedback = "taster_feedback_banana_solo", unique = true },

	-- BLACKBERRY ------------------------------------------------------------
	{ requires = { "blackberry" }, score = 0, feedback = "taster_feedback_blackberry_solo", unique = true },

	-- BLUEBERRY -------------------------------------------------------------
	{ requires = { "blueberry", "lemon" }, score = 5, feedback = "taster_feedback_blueberry_lemon", unique = true, voids = { "taster_feedback_blueberry_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "blueberry" }, score = 0, feedback = "taster_feedback_blueberry_solo", unique = true },

	-- BOGOTÁ COFFEE ---------------------------------------------------------
	{ requires = { "bog_coffee", "hazelnut" }, forbids = { "bal_coffee", "hav_coffee", "kon_coffee", "tan_coffee", "espresso" }, score = 12, feedback = "taster_feedback_colombian_hazelnut_coffee", voids = { "taster_feedback_bog_coffee_profile", "taster_feedback_hazelnut_solo" } },
	{ requires = { "bog_coffee" }, score = 0, feedback = "taster_feedback_bog_coffee_profile", unique = true },

	-- BRANDY ----------------------------------------------------------------
	{ requires = { "brandy" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", ">", 0 } }, score = 10, feedback = "taster_feedback_coffee_brandy", voids = { "taster_feedback_brandy_solo" } },
	{ requires = { "brandy" }, score = 0, feedback = "taster_feedback_brandy_solo", unique = true },

	-- BUTTER ----------------------------------------------------------------
	{ requires = { "butter" }, counts = { { "butter", ">=", 2 } }, score = -18, feedback = "taster_feedback_butter_overuse", voids = { "taster_feedback_butter_solo" } },
	{ requires = { "butter" }, counts = { { "butter", "==", 1 } }, ratios = { { "coffee", ">", 0 } }, score = 7, feedback = "taster_feedback_coffee_butter", voids = { "taster_feedback_butter_solo" } },
	{ requires = { "butter" }, score = 0, feedback = "taster_feedback_butter_solo", unique = true },

	-- CARAMEL ---------------------------------------------------------------
	{ requires = { "caramel" }, counts = { { "caramel", ">=", 3 } }, score = -16, feedback = "taster_feedback_caramel_overuse" },
	{ requires = { "caramel", "salt" }, counts = { { "salt", "==", 1 } }, ratios = { { "coffee", ">", 0 } }, score = 12, feedback = "taster_feedback_salted_caramel_coffee", voids = { "taster_feedback_salt_solo", "taster_feedback_coffee_caramel" } },
	{ requires = { "caramel" }, forbids = { "espresso", "salt" }, ratios = { { "coffee", ">", 0 } }, score = 6, feedback = "taster_feedback_coffee_caramel", unique = true },
	{ requires = { "caramel" }, forbids = { "espresso" }, ratios = { { "coffee", ">", 0 } }, score = 7, feedback = "taster_feedback_coffee_caramel", unique = true },

	-- CARDAMOM --------------------------------------------------------------
	{ requires = { "cardamom" }, counts = { { "cardamom", ">=", 2 } }, score = -18, feedback = "taster_feedback_cardamom_overuse", voids = { "taster_feedback_cardamom_solo" } },
	{ requires = { "cardamom" }, forbids = { "espresso", "tan_coffee" }, counts = { { "cardamom", "==", 1 } }, ratios = { { "coffee", ">", 0 } }, score = 6, feedback = "taster_feedback_coffee_cardamom", unique = true, voids = { "taster_feedback_cardamom_solo" } },
	{ requires = { "cardamom" }, forbids = { "espresso" }, ratios = { { "coffee", ">", 0 } }, score = 7, feedback = "taster_feedback_coffee_cardamom", unique = true, voids = { "taster_feedback_cardamom_solo" } },
	{ requires = { "cardamom", "orange" }, score = 6, feedback = "taster_feedback_cardamom_orange", unique = true, voids = { "taster_feedback_cardamom_solo", "taster_feedback_orange_solo" } },
	{ requires = { "cardamom", "pistachio" }, score = 6, feedback = "taster_feedback_cardamom_pistachio", unique = true, voids = { "taster_feedback_cardamom_solo", "taster_feedback_pistachio_solo" } },
	{ requires = { "cardamom", "honey" }, score = 5, feedback = "taster_feedback_cardamom_honey", unique = true, voids = { "taster_feedback_cardamom_solo", "taster_feedback_honey_solo" } },
	{ requires = { "cardamom" }, score = 0, feedback = "taster_feedback_cardamom_solo", unique = true },

	-- CASHEW ----------------------------------------------------------------
	{ requires = { "cashew" }, score = 0, feedback = "taster_feedback_cashew_solo", unique = true },

	-- CAYENNE ---------------------------------------------------------------
	{ requires = { "cayenne" }, counts = { { "cayenne", ">=", 2 } }, score = -26, feedback = "taster_feedback_cayenne_overuse", voids = { "taster_feedback_cayenne_solo" } },
	{ requires = { "cayenne" }, forbids = { "ginger", "sugar", "honey", "maple", "caramel", "toffee", "milk", "cream", "whipped_cream" }, ratios = { { "coffee", ">", 0 }, { "cacao", "==", 0 } }, score = -18, feedback = "taster_feedback_coffee_cayenne_bad", voids = { "taster_feedback_cayenne_solo" } },
	{ requires = { "cayenne", "jasmine" }, score = -20, feedback = "taster_feedback_jasmine_cayenne_bad", voids = { "taster_feedback_cayenne_solo", "taster_feedback_jasmine_solo" } },
	{ requires = { "cayenne", "chamomile" }, score = -18, feedback = "taster_feedback_chamomile_cayenne_bad", voids = { "taster_feedback_cayenne_solo", "taster_feedback_chamomile_solo" } },
	{ requires = { "cayenne" }, score = 0, feedback = "taster_feedback_cayenne_solo", unique = true },

	-- CHAMOMILE -------------------------------------------------------------
	{ requires = { "chamomile" }, counts = { { "chamomile", ">=", 2 } }, score = -14, feedback = "taster_feedback_chamomile_overuse", voids = { "taster_feedback_chamomile_solo" } },
	{ requires = { "chamomile" }, ratios = { { "coffee", "==", 0 }, { "dairy", ">=", 0.8 } }, score = -55, feedback = "taster_feedback_tea_alldairy", negative = true, voids = { "taster_coffee_alldairy", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "chamomile" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">=", 0.8 } }, score = -55, feedback = "taster_feedback_tea_allsugar", negative = true, voids = { "taster_coffee_allsugar", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "chamomile" }, ratios = { { "coffee", "==", 0 }, { "cacao", ">=", 0.7 } }, score = -55, feedback = "taster_feedback_tea_allcacao", negative = true, voids = { "taster_coffee_allcacao", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "chamomile" }, ratios = { { "coffee", ">", 0 } }, score = -18, feedback = "taster_feedback_coffee_chamomile_bad", voids = { "taster_feedback_chamomile_solo" } },
	{ requires = { "chamomile", "honey" }, ratios = { { "coffee", "==", 0 } }, score = 14, feedback = "taster_feedback_chamomile_honey", voids = { "taster_feedback_honey_solo", "taster_feedback_chamomile_solo" } },
	{ requires = { "chamomile", "lemon" }, ratios = { { "coffee", "==", 0 } }, score = 5, feedback = "taster_feedback_chamomile_lemon", unique = true, voids = { "taster_feedback_chamomile_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "chamomile", "lavender" }, ratios = { { "coffee", "==", 0 } }, score = 5, feedback = "taster_feedback_chamomile_lavender", unique = true, voids = { "taster_feedback_chamomile_solo", "taster_feedback_lavender_solo" } },
	{ requires = { "chamomile", "apple" }, ratios = { { "coffee", "==", 0 } }, score = 5, feedback = "taster_feedback_chamomile_apple", unique = true, voids = { "taster_feedback_chamomile_solo", "taster_feedback_apple_solo" } },
	{ requires = { "chamomile" }, score = 0, feedback = "taster_feedback_chamomile_solo", unique = true },

	-- CHERRY ----------------------------------------------------------------
	{ requires = { "cherry" }, ratios = { { "coffee", ">", 0 } }, score = 6, feedback = "taster_feedback_coffee_cherry", unique = true, voids = { "taster_feedback_cherry_solo" } },
	{ requires = { "cherry", "amaretto" }, score = 5, feedback = "taster_feedback_amaretto_cherry", unique = true, voids = { "taster_feedback_amaretto_solo", "taster_feedback_cherry_solo" } },
	{ requires = { "cherry", "almond" }, score = 5, feedback = "taster_feedback_cherry_almond", unique = true, voids = { "taster_feedback_cherry_solo", "taster_feedback_almond_solo" } },
	{ requires = { "cherry" }, score = 0, feedback = "taster_feedback_cherry_solo", unique = true },

	-- CHESTNUT --------------------------------------------------------------
	{ requires = { "chestnut", "rum" }, score = 5, feedback = "taster_feedback_chestnut_rum", unique = true, voids = { "taster_feedback_chestnut_solo", "taster_feedback_rum_solo" } },
	{ requires = { "chestnut", "vanilla" }, score = 5, feedback = "taster_feedback_chestnut_vanilla", unique = true, voids = { "taster_feedback_chestnut_solo", "taster_feedback_vanilla_solo" } },
	{ requires = { "chestnut" }, score = 0, feedback = "taster_feedback_chestnut_solo", unique = true },

	-- CINNAMON --------------------------------------------------------------
	{ requires = { "cinnamon" }, counts = { { "cinnamon", ">=", 2 } }, score = -18, feedback = "taster_feedback_cinnamon_overuse", voids = { "taster_feedback_cinnamon_solo" } },
	{ requires = { "cinnamon", "cayenne" }, ratios = { { "coffee", ">", 0 }, { "cacao", ">", 0 } }, score = 20, feedback = "taster_feedback_mesoamerican", voids = { "taster_feedback_cinnamon_solo", "taster_feedback_cayenne_solo", "taster_feedback_mocha" } },
	{ requires = { "pumpkin", "cinnamon" }, ratios = { { "coffee", ">", 0 }, { "dairy", ">", 0 } }, score = 16, feedback = "taster_feedback_autumn_spice", voids = { "taster_feedback_pumpkin_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "cinnamon" }, forbids = { "espresso" }, counts = { { "cinnamon", "==", 1 } }, ratios = { { "coffee", ">", 0 } }, score = 5, feedback = "taster_feedback_coffee_cinnamon", unique = true, voids = { "taster_feedback_cinnamon_solo" } },
	{ requires = { "pear", "cinnamon" }, score = 5, feedback = "taster_feedback_autumn_spice", unique = true, voids = { "taster_feedback_cinnamon_solo", "taster_feedback_pear_solo" } },
	{ requires = { "cinnamon" }, forbids = { "espresso" }, ratios = { { "coffee", ">", 0 } }, score = 6, feedback = "taster_feedback_coffee_cinnamon", unique = true, voids = { "taster_feedback_cinnamon_solo" } },
	{ requires = { "cinnamon" }, score = 0, feedback = "taster_feedback_cinnamon_solo", unique = true },

	-- CLOVE -----------------------------------------------------------------
	{ requires = { "clove" }, counts = { { "clove", ">=", 2 } }, score = -24, feedback = "taster_feedback_clove_overuse", voids = { "taster_feedback_clove_solo" } },
	{ requires = { "clove" }, score = 0, feedback = "taster_feedback_clove_solo", unique = true },

	-- COCONUT ---------------------------------------------------------------
	{ requires = { "coconut" }, forbids = { "bal_coffee", "rum" }, ratios = { { "coffee", ">", 0 } }, score = 6, feedback = "taster_feedback_coffee_coconut", unique = true, voids = { "taster_feedback_coconut_solo" } },
	{ requires = { "coconut", "lime" }, score = 5, feedback = "taster_feedback_coconut_lime", unique = true, voids = { "taster_feedback_coconut_solo", "taster_feedback_lime_solo" } },
	{ requires = { "coconut", "mango" }, score = 5, feedback = "taster_feedback_coconut_mango", unique = true, voids = { "taster_feedback_coconut_solo", "taster_feedback_mango_solo" } },
	{ requires = { "coconut", "passionfruit" }, score = 5, feedback = "taster_feedback_coconut_passionfruit", unique = true, voids = { "taster_feedback_coconut_solo", "taster_feedback_passionfruit_solo" } },
	{ requires = { "coconut" }, score = 0, feedback = "taster_feedback_coconut_solo", unique = true },

	-- CRANBERRY -------------------------------------------------------------
	{ requires = { "cranberry", "orange" }, score = 5, feedback = "taster_feedback_cranberry_orange", unique = true, voids = { "taster_feedback_cranberry_solo", "taster_feedback_orange_solo" } },
	{ requires = { "cranberry" }, score = 0, feedback = "taster_feedback_cranberry_solo", unique = true },

	-- CREAM -----------------------------------------------------------------
	{ requires = { "cream" }, score = 0, feedback = "taster_feedback_cream_solo", unique = true },

	-- CURRANT ---------------------------------------------------------------
	{ requires = { "currant", "cream" }, score = 5, feedback = "taster_feedback_currant_cream", unique = true, voids = { "taster_feedback_currant_solo", "taster_feedback_cream_solo" } },
	{ requires = { "currant" }, score = 0, feedback = "taster_feedback_currant_solo", unique = true },

	-- DATE ------------------------------------------------------------------
	{ requires = { "date" }, score = 0, feedback = "taster_feedback_date_solo", unique = true },

	-- DRAGONFRUIT -----------------------------------------------------------
	{ requires = { "dragonfruit", "anise" }, score = -12, feedback = "taster_feedback_dragonfruit_anise_bad", voids = { "taster_feedback_dragonfruit_solo", "taster_feedback_anise_solo" } },
	{ requires = { "dragonfruit" }, score = 0, feedback = "taster_feedback_dragonfruit_solo", unique = true },

	-- EARL GREY -------------------------------------------------------------
	{ requires = { "earl_grey" }, counts = { { "earl_grey", ">=", 2 } }, score = -16, feedback = "taster_feedback_earl_grey_overuse", voids = { "taster_feedback_earl_grey_solo" } },
	{ requires = { "earl_grey" }, ratios = { { "coffee", "==", 0 }, { "dairy", ">=", 0.8 } }, score = -55, feedback = "taster_feedback_tea_alldairy", negative = true, voids = { "taster_coffee_alldairy", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "earl_grey" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">=", 0.8 } }, score = -55, feedback = "taster_feedback_tea_allsugar", negative = true, voids = { "taster_coffee_allsugar", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "earl_grey" }, ratios = { { "coffee", "==", 0 }, { "cacao", ">=", 0.7 } }, score = -55, feedback = "taster_feedback_tea_allcacao", negative = true, voids = { "taster_coffee_allcacao", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "earl_grey", "peanut" }, ratios = { { "coffee", "==", 0 } }, score = -16, feedback = "taster_feedback_earl_grey_peanut_bad", voids = { "taster_feedback_earl_grey_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "earl_grey", "vanilla", "cream" }, ratios = { { "coffee", "==", 0 } }, score = 22, feedback = "taster_feedback_tea_london_fog", voids = { "taster_feedback_vanilla_solo", "taster_feedback_cream_solo", "taster_feedback_earl_grey_solo" } },
	{ requires = { "earl_grey", "vanilla", "milk" }, ratios = { { "coffee", "==", 0 } }, score = 18, feedback = "taster_feedback_tea_london_fog", voids = { "taster_feedback_vanilla_solo", "taster_feedback_earl_grey_solo" } },
	{ requires = { "earl_grey", "lemon" }, forbids = { "vanilla", "milk", "cream" }, ratios = { { "coffee", "==", 0 } }, score = 6, feedback = "taster_feedback_earl_grey_lemon", unique = true, voids = { "taster_feedback_earl_grey_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "earl_grey", "honey" }, forbids = { "vanilla", "milk", "cream" }, ratios = { { "coffee", "==", 0 } }, score = 5, feedback = "taster_feedback_earl_grey_honey", unique = true, voids = { "taster_feedback_earl_grey_solo", "taster_feedback_honey_solo" } },
	{ requires = { "earl_grey", "lavender" }, ratios = { { "coffee", "==", 0 } }, score = 6, feedback = "taster_feedback_earl_grey_lavender", unique = true, voids = { "taster_feedback_earl_grey_solo", "taster_feedback_lavender_solo" } },
	{ requires = { "earl_grey", "milk" }, forbids = { "vanilla", "cream" }, ratios = { { "coffee", "==", 0 } }, score = 5, feedback = "taster_feedback_earl_grey_milk", unique = true, voids = { "taster_feedback_earl_grey_solo" } },
	{ requires = { "earl_grey" }, score = 0, feedback = "taster_feedback_earl_grey_solo", unique = true },

	-- ESPRESSO --------------------------------------------------------------
	{ requires = { "espresso", "tea", "cinnamon" }, score = 20, feedback = "taster_feedback_coffee_dirty_chai", voids = { "taster_feedback_espresso_profile", "taster_feedback_espresso_solo", "taster_feedback_blacktea_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "espresso", "ice_cream" }, forbids = { "toffee" }, score = 22, feedback = "taster_feedback_coffee_affogato", voids = { "taster_feedback_espresso_profile", "taster_feedback_espresso_solo", "taster_feedback_ice_cream_solo" } },
	{ requires = { "espresso", "ice_cream", "toffee" }, score = 26, feedback = "taster_feedback_coffee_affogato_toffee", voids = { "taster_feedback_coffee_affogato", "taster_feedback_espresso_profile", "taster_feedback_espresso_solo", "taster_feedback_ice_cream_solo", "taster_feedback_coffee_toffee", "taster_feedback_toffee_solo" } },
	{ requires = { "espresso", "whiskey", "cream" }, trait_counts = { { "alcohol", "==", 1 } }, score = 22, feedback = "taster_feedback_coffee_irish_cream_build", voids = { "taster_feedback_espresso_profile", "taster_feedback_espresso_solo", "taster_feedback_coffee_whiskey", "taster_feedback_cream_solo", "taster_feedback_whiskey_solo" } },
	{ requires = { "espresso", "cream" }, trait_counts = { { "alcohol", "==", 0 } }, score = 16, feedback = "taster_feedback_espresso_con_panna", voids = { "taster_feedback_espresso_profile", "taster_feedback_espresso_solo", "taster_feedback_cream_solo" } },
	{ requires = { "espresso", "lemon" }, score = 14, feedback = "taster_feedback_coffee_lemon_romano", voids = { "taster_feedback_espresso_profile", "taster_feedback_espresso_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "espresso", "caramel" }, score = 8, feedback = "taster_feedback_espresso_caramel", unique = true, voids = { "taster_feedback_espresso_profile", "taster_feedback_espresso_solo" } },
	{ requires = { "espresso", "hazelnut" }, score = 8, feedback = "taster_feedback_espresso_hazelnut", unique = true, voids = { "taster_feedback_espresso_profile", "taster_feedback_espresso_solo", "taster_feedback_hazelnut_solo" } },
	{ requires = { "espresso", "cardamom" }, counts = { { "cardamom", "==", 1 } }, score = 8, feedback = "taster_feedback_espresso_cardamom", unique = true, voids = { "taster_feedback_espresso_profile", "taster_feedback_espresso_solo", "taster_feedback_cardamom_solo" } },
	{ requires = { "espresso", "vanilla" }, counts = { { "vanilla", "==", 1 } }, score = 7, feedback = "taster_feedback_espresso_vanilla", unique = true, voids = { "taster_feedback_espresso_profile", "taster_feedback_espresso_solo", "taster_feedback_vanilla_solo" } },
	{ requires = { "espresso", "cinnamon" }, forbids = { "tea" }, counts = { { "cinnamon", "==", 1 } }, score = 7, feedback = "taster_feedback_espresso_cinnamon", unique = true, voids = { "taster_feedback_espresso_profile", "taster_feedback_espresso_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "espresso" }, score = 0, feedback = "taster_feedback_espresso_profile", unique = true, voids = { "taster_feedback_espresso_solo" } },
	{ requires = { "espresso" }, score = 0, feedback = "taster_feedback_espresso_solo", unique = true },

	-- FIG -------------------------------------------------------------------
	{ requires = { "fig" }, score = 0, feedback = "taster_feedback_fig_solo", unique = true },

	-- GINGER ----------------------------------------------------------------
	{ requires = { "ginger" }, counts = { { "ginger", ">=", 2 } }, score = -18, feedback = "taster_feedback_ginger_overuse", voids = { "taster_feedback_ginger_solo" } },
	{ requires = { "ginger" }, score = 0, feedback = "taster_feedback_ginger_solo", unique = true },

	-- GRAND MARNIER ---------------------------------------------------------
	{ requires = { "grand_marnier" }, forbids = { "cacao" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", ">", 0 } }, score = 10, feedback = "taster_feedback_coffee_grand_marnier", voids = { "taster_feedback_grand_marnier_solo" } },
	{ requires = { "grand_marnier" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", ">", 0 }, { "cacao", ">", 0 }, { "cacao", "<", 0.7 } }, score = 8, feedback = "taster_feedback_coffee_mocha_valencia", voids = { "taster_feedback_mocha", "taster_feedback_coffee_grand_marnier", "taster_feedback_grand_marnier_solo" } },
	{ requires = { "grand_marnier" }, score = 0, feedback = "taster_feedback_grand_marnier_solo", unique = true },

	-- GUAVA -----------------------------------------------------------------
	{ requires = { "guava", "clove" }, score = -14, feedback = "taster_feedback_guava_clove_bad", voids = { "taster_feedback_guava_solo", "taster_feedback_clove_solo" } },
	{ requires = { "guava" }, score = 0, feedback = "taster_feedback_guava_solo", unique = true },

	-- HAVANA COFFEE ---------------------------------------------------------
	{ requires = { "hav_coffee", "sugar" }, forbids = { "bal_coffee", "bog_coffee", "kon_coffee", "tan_coffee", "espresso", "rum", "milk", "cream", "whipped_cream" }, counts = { { "hav_coffee", ">=", 2 } }, score = 16, feedback = "taster_feedback_cafecito", voids = { "taster_feedback_hav_coffee_profile" } },
	{ requires = { "hav_coffee", "rum", "sugar" }, forbids = { "bal_coffee", "bog_coffee", "kon_coffee", "tan_coffee", "espresso", "milk", "cream", "whipped_cream" }, trait_counts = { { "alcohol", "==", 1 } }, score = 20, feedback = "taster_feedback_coffee_caribbean_rum", voids = { "taster_feedback_cafecito", "taster_feedback_hav_coffee_profile", "taster_feedback_rum_solo" } },
	{ requires = { "hav_coffee" }, score = 0, feedback = "taster_feedback_hav_coffee_profile", unique = true },

	-- HAZELNUT --------------------------------------------------------------
	{ requires = { "hazelnut" }, forbids = { "espresso", "bog_coffee" }, ratios = { { "coffee", ">", 0 } }, score = 6, feedback = "taster_feedback_coffee_hazelnut", unique = true, voids = { "taster_feedback_hazelnut_solo" } },
	{ requires = { "hazelnut" }, forbids = { "espresso" }, ratios = { { "coffee", ">", 0 } }, score = 7, feedback = "taster_feedback_coffee_hazelnut", unique = true, voids = { "taster_feedback_hazelnut_solo" } },
	{ requires = { "hazelnut" }, score = 0, feedback = "taster_feedback_hazelnut_solo", unique = true },

	-- HIBISCUS --------------------------------------------------------------
	{ requires = { "hibiscus" }, counts = { { "hibiscus", ">=", 2 } }, score = -18, feedback = "taster_feedback_hibiscus_overuse", voids = { "taster_feedback_hibiscus_solo" } },
	{ requires = { "hibiscus" }, ratios = { { "coffee", "==", 0 }, { "dairy", ">=", 0.8 } }, score = -55, feedback = "taster_feedback_tea_alldairy", negative = true, voids = { "taster_coffee_alldairy", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "hibiscus" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">=", 0.8 } }, score = -55, feedback = "taster_feedback_tea_allsugar", negative = true, voids = { "taster_coffee_allsugar", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "hibiscus" }, ratios = { { "coffee", "==", 0 }, { "cacao", ">=", 0.7 } }, score = -55, feedback = "taster_feedback_tea_allcacao", negative = true, voids = { "taster_coffee_allcacao", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "hibiscus", "peanut" }, score = -16, feedback = "taster_feedback_hibiscus_peanut_bad", voids = { "taster_feedback_hibiscus_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "hibiscus" }, ratios = { { "coffee", ">", 0 } }, score = -16, feedback = "taster_feedback_coffee_hibiscus_bad", voids = { "taster_feedback_hibiscus_solo" } },
	{ requires = { "hibiscus", "tea" }, ratios = { { "coffee", "==", 0 } }, score = 12, feedback = "taster_feedback_blacktea_hibiscus", voids = { "taster_feedback_hibiscus_solo", "taster_feedback_blacktea_solo" } },
	{ requires = { "hibiscus", "honey" }, ratios = { { "coffee", "==", 0 } }, score = 5, feedback = "taster_feedback_hibiscus_honey", unique = true, voids = { "taster_feedback_hibiscus_solo", "taster_feedback_honey_solo" } },
	{ requires = { "hibiscus", "orange" }, ratios = { { "coffee", "==", 0 } }, score = 5, feedback = "taster_feedback_hibiscus_orange", unique = true, voids = { "taster_feedback_hibiscus_solo", "taster_feedback_orange_solo" } },
	{ requires = { "hibiscus", "mango" }, score = 5, feedback = "taster_feedback_hibiscus_mango", unique = true, voids = { "taster_feedback_hibiscus_solo", "taster_feedback_mango_solo" } },
	{ requires = { "hibiscus" }, score = 0, feedback = "taster_feedback_hibiscus_solo", unique = true },

	-- HONEY -----------------------------------------------------------------
	{ requires = { "honey" }, counts = { { "honey", ">=", 2 } }, score = -18, feedback = "taster_feedback_honey_overuse", voids = { "taster_feedback_honey_solo" } },
	{ requires = { "honey" }, score = 0, feedback = "taster_feedback_honey_solo", unique = true },

	-- ICE CREAM -------------------------------------------------------------
	{ requires = { "ice_cream", "milk" }, categories = { "beverage" }, ratios = { { "coffee", "==", 0 }, { "cacao", ">", 0 } }, score = 20, feedback = "taster_feedback_milkshake_chocolate", voids = { "taster_feedback_milkshake_vanilla", "taster_feedback_milkshake_strawberry", "taster_feedback_milkshake_banana", "taster_feedback_ice_cream_solo" } },
	{ requires = { "ice_cream", "milk", "vanilla" }, categories = { "beverage" }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "fruit", "==", 0 } }, score = 18, feedback = "taster_feedback_milkshake_vanilla", voids = { "taster_feedback_ice_cream_solo", "taster_feedback_vanilla_solo" } },
	{ requires = { "ice_cream", "milk", "strawberry" }, forbids = { "banana" }, categories = { "beverage" }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 } }, score = 18, feedback = "taster_feedback_milkshake_strawberry", voids = { "taster_feedback_ice_cream_solo", "taster_feedback_strawberry_solo" } },
	{ requires = { "ice_cream", "milk", "banana" }, forbids = { "strawberry" }, categories = { "beverage" }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 } }, score = 18, feedback = "taster_feedback_milkshake_banana", voids = { "taster_feedback_ice_cream_solo", "taster_feedback_banana_solo" } },
	{ requires = { "ice_cream" }, score = 0, feedback = "taster_feedback_ice_cream_solo", unique = true },

	-- JASMINE ---------------------------------------------------------------
	{ requires = { "jasmine" }, counts = { { "jasmine", ">=", 2 } }, score = -18, feedback = "taster_feedback_jasmine_overuse", voids = { "taster_feedback_jasmine_solo" } },
	{ requires = { "jasmine" }, ratios = { { "coffee", "==", 0 }, { "dairy", ">=", 0.8 } }, score = -55, feedback = "taster_feedback_tea_alldairy", negative = true, voids = { "taster_coffee_alldairy", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "jasmine" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">=", 0.8 } }, score = -55, feedback = "taster_feedback_tea_allsugar", negative = true, voids = { "taster_coffee_allsugar", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "jasmine" }, ratios = { { "coffee", "==", 0 }, { "cacao", ">=", 0.7 } }, score = -55, feedback = "taster_feedback_tea_allcacao", negative = true, voids = { "taster_coffee_allcacao", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "jasmine", "peanut" }, ratios = { { "coffee", "==", 0 } }, score = -16, feedback = "taster_feedback_jasmine_peanut_bad", voids = { "taster_feedback_jasmine_solo", "taster_feedback_peanut_solo" } },
	{ requires = { "jasmine", "honey" }, ratios = { { "coffee", "==", 0 } }, score = 5, feedback = "taster_feedback_jasmine_honey", unique = true, voids = { "taster_feedback_jasmine_solo", "taster_feedback_honey_solo" } },
	{ requires = { "jasmine", "peach" }, ratios = { { "coffee", "==", 0 } }, score = 6, feedback = "taster_feedback_jasmine_peach", unique = true, voids = { "taster_feedback_jasmine_solo", "taster_feedback_peach_solo" } },
	{ requires = { "jasmine", "lychee" }, ratios = { { "coffee", "==", 0 } }, score = 6, feedback = "taster_feedback_jasmine_lychee", unique = true, voids = { "taster_feedback_jasmine_solo", "taster_feedback_lychee_solo" } },
	{ requires = { "jasmine" }, score = 0, feedback = "taster_feedback_jasmine_solo", unique = true },

	-- KAHLUA ----------------------------------------------------------------
	{ requires = { "kahlua", "cream" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", ">", 0 } }, score = 14, feedback = "taster_feedback_kahlua_cream", voids = { "taster_feedback_kahlua_solo", "taster_feedback_cream_solo" } },
	{ requires = { "kahlua", "milk" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", ">", 0 } }, score = 14, feedback = "taster_feedback_kahlua_milk", voids = { "taster_feedback_kahlua_solo" } },
	{ requires = { "kahlua" }, forbids = { "cream", "milk" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", ">", 0 } }, score = 7, feedback = "taster_feedback_coffee_kahlua", unique = true, voids = { "taster_feedback_kahlua_solo" } },
	{ requires = { "kahlua" }, score = 0, feedback = "taster_feedback_kahlua_solo", unique = true },

	-- KONA COFFEE -----------------------------------------------------------
	{ requires = { "kon_coffee", "vanilla" }, forbids = { "bal_coffee", "bog_coffee", "hav_coffee", "tan_coffee", "espresso" }, counts = { { "vanilla", "==", 1 } }, score = 12, feedback = "taster_feedback_kona_vanilla_coffee", voids = { "taster_feedback_kon_coffee_profile", "taster_feedback_vanilla_solo" } },
	{ requires = { "kon_coffee", "macadamia" }, forbids = { "bal_coffee", "bog_coffee", "hav_coffee", "tan_coffee", "espresso" }, score = 14, feedback = "taster_feedback_coffee_kona_macadamia", voids = { "taster_feedback_kon_coffee_profile", "taster_feedback_macadamia_solo" } },
	{ requires = { "kon_coffee" }, score = 0, feedback = "taster_feedback_kon_coffee_profile", unique = true },

	-- LAVENDER --------------------------------------------------------------
	{ requires = { "lavender" }, counts = { { "lavender", ">=", 2 } }, score = -20, feedback = "taster_feedback_lavender_overuse", voids = { "taster_feedback_lavender_solo" } },
	{ requires = { "lavender", "honey" }, score = 5, feedback = "taster_feedback_lavender_honey", unique = true, voids = { "taster_feedback_lavender_solo", "taster_feedback_honey_solo" } },
	{ requires = { "lavender", "blueberry" }, score = 5, feedback = "taster_feedback_lavender_blueberry", unique = true, voids = { "taster_feedback_lavender_solo", "taster_feedback_blueberry_solo" } },
	{ requires = { "lavender", "lemon" }, score = 5, feedback = "taster_feedback_lavender_lemon", unique = true, voids = { "taster_feedback_lavender_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "lavender", "mint" }, score = 3, feedback = "taster_feedback_lavender_mint", unique = true, voids = { "taster_feedback_lavender_solo", "taster_feedback_mint_solo" } },
	{ requires = { "lavender", "vanilla" }, score = 5, feedback = "taster_feedback_lavender_vanilla", unique = true, voids = { "taster_feedback_lavender_solo", "taster_feedback_vanilla_solo" } },
	{ requires = { "lavender" }, score = 0, feedback = "taster_feedback_lavender_solo", unique = true },

	-- LEMON -----------------------------------------------------------------
	{ requires = { "lemon", "sugar" }, forbids = { "tea", "earl_grey", "rooibos", "chamomile", "jasmine", "hibiscus", "matcha", "lemongrass" }, categories = { "beverage", "blend" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 14, feedback = "taster_feedback_lemonade", voids = { "taster_feedback_lemon_solo" } },
	{ requires = { "lemon" }, counts = { { "lemon", ">=", 2 } }, score = -16, feedback = "taster_feedback_lemon_overuse", voids = { "taster_feedback_lemon_solo" } },
	{ requires = { "lemon" }, forbids = { "honey", "espresso" }, ratios = { { "coffee", ">", 0 } }, score = -22, feedback = "taster_feedback_espresso_lime_bad", voids = { "taster_feedback_lemon_solo" } },
	{ requires = { "lemon", "honey" }, ratios = { { "coffee", ">", 0 } }, score = 8, feedback = "taster_feedback_lemon_honey_coffee", voids = { "taster_feedback_lemon_solo", "taster_feedback_honey_solo" } },
	{ requires = { "lemon", "ginger" }, score = 6, feedback = "taster_feedback_lemon_ginger", unique = true, voids = { "taster_feedback_lemon_solo", "taster_feedback_ginger_solo" } },
	{ requires = { "lemon" }, score = 0, feedback = "taster_feedback_lemon_solo", unique = true },

	-- LEMONGRASS ------------------------------------------------------------
	{ requires = { "lemongrass" }, counts = { { "lemongrass", ">=", 2 } }, score = -16, feedback = "taster_feedback_lemongrass_overuse", voids = { "taster_feedback_lemongrass_solo" } },
	{ requires = { "lemongrass" }, ratios = { { "coffee", "==", 0 }, { "dairy", ">=", 0.8 } }, score = -55, feedback = "taster_feedback_tea_alldairy", negative = true, voids = { "taster_coffee_alldairy", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "lemongrass" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">=", 0.8 } }, score = -55, feedback = "taster_feedback_tea_allsugar", negative = true, voids = { "taster_coffee_allsugar", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "lemongrass" }, ratios = { { "coffee", "==", 0 }, { "cacao", ">=", 0.7 } }, score = -55, feedback = "taster_feedback_tea_allcacao", negative = true, voids = { "taster_coffee_allcacao", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "lemongrass", "ginger" }, ratios = { { "coffee", "==", 0 } }, score = 8, feedback = "taster_feedback_lemongrass_ginger", unique = true, voids = { "taster_feedback_ginger_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "lemongrass", "honey" }, ratios = { { "coffee", "==", 0 } }, score = 5, feedback = "taster_feedback_lemongrass_honey", unique = true, voids = { "taster_feedback_lemongrass_solo", "taster_feedback_honey_solo" } },
	{ requires = { "lemongrass", "mint" }, ratios = { { "coffee", "==", 0 } }, score = 5, feedback = "taster_feedback_lemongrass_mint", unique = true, voids = { "taster_feedback_lemongrass_solo", "taster_feedback_mint_solo" } },
	{ requires = { "lemongrass" }, score = 0, feedback = "taster_feedback_lemongrass_solo", unique = true },

	-- LIME ------------------------------------------------------------------
	{ requires = { "lime", "sugar" }, forbids = { "tea", "earl_grey", "rooibos", "chamomile", "jasmine", "hibiscus", "matcha", "lemongrass" }, categories = { "beverage", "blend" }, trait_counts = { { "alcohol", "==", 0 } }, ratios = { { "coffee", "==", 0 }, { "cacao", "==", 0 }, { "dairy", "==", 0 } }, score = 14, feedback = "taster_feedback_limeade", voids = { "taster_feedback_lime_solo" } },
	{ requires = { "lime" }, counts = { { "lime", ">=", 2 } }, score = -16, feedback = "taster_feedback_lime_overuse", voids = { "taster_feedback_lime_solo" } },
	{ requires = { "lime" }, ratios = { { "coffee", ">", 0 } }, score = -30, feedback = "taster_feedback_espresso_lime_bad", voids = { "taster_feedback_lime_solo" } },
	{ requires = { "lime" }, score = 0, feedback = "taster_feedback_lime_solo", unique = true },

	-- LYCHEE ----------------------------------------------------------------
	{ requires = { "lychee" }, score = 0, feedback = "taster_feedback_lychee_solo", unique = true },

	-- MACADAMIA -------------------------------------------------------------
	{ requires = { "macadamia" }, score = 0, feedback = "taster_feedback_macadamia_solo", unique = true },

	-- MANGO -----------------------------------------------------------------
	{ requires = { "mango" }, score = 0, feedback = "taster_feedback_mango_solo", unique = true },

	-- MAPLE -----------------------------------------------------------------
	{ requires = { "maple" }, counts = { { "maple", ">=", 3 } }, score = -16, feedback = "taster_feedback_maple_overuse", voids = { "taster_feedback_maple_solo" } },
	{ requires = { "maple" }, ratios = { { "coffee", ">", 0 } }, score = 7, feedback = "taster_feedback_coffee_maple", unique = true, voids = { "taster_feedback_maple_solo" } },
	{ requires = { "maple" }, score = 0, feedback = "taster_feedback_maple_solo", unique = true },

	-- MARSHMALLOW -----------------------------------------------------------
	{ requires = { "marshmallow", "espresso" }, counts = { { "marshmallow", ">=", 2 } }, score = -22, feedback = "taster_feedback_coffee_marshmallow_overuse", voids = { "taster_feedback_marshmallow_solo", "taster_feedback_coffee_marshmallow" } },
	{ requires = { "marshmallow", "espresso" }, score = 8, feedback = "taster_feedback_coffee_marshmallow", unique = true, voids = { "taster_feedback_marshmallow_solo" } },
	{ requires = { "marshmallow", "wafer" }, score = 6, feedback = "taster_feedback_marshmallow_wafer", unique = true, voids = { "taster_feedback_marshmallow_solo", "taster_feedback_wafer_solo" } },
	{ requires = { "marshmallow" }, ratios = { { "cacao", ">", 0.2 } }, score = 8, feedback = "taster_feedback_chocolate_marshmallow", unique = true, voids = { "taster_feedback_marshmallow_solo" } },
	{ requires = { "marshmallow" }, score = 0, feedback = "taster_feedback_marshmallow_solo", unique = true },

	-- MATCHA ----------------------------------------------------------------
	{ requires = { "matcha" }, counts = { { "matcha", ">=", 2 } }, score = -22, feedback = "taster_feedback_matcha_overuse", voids = { "taster_feedback_matcha_solo" } },
	{ requires = { "matcha" }, ratios = { { "coffee", "==", 0 }, { "dairy", ">=", 0.8 } }, score = -55, feedback = "taster_feedback_tea_alldairy", negative = true, voids = { "taster_coffee_alldairy", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "matcha" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">=", 0.8 } }, score = -55, feedback = "taster_feedback_tea_allsugar", negative = true, voids = { "taster_coffee_allsugar", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "matcha" }, ratios = { { "coffee", "==", 0 }, { "cacao", ">=", 0.7 } }, score = -55, feedback = "taster_feedback_tea_allcacao", negative = true, voids = { "taster_coffee_allcacao", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "matcha", "cayenne" }, ratios = { { "coffee", "==", 0 } }, score = -22, feedback = "taster_feedback_matcha_cayenne_bad", voids = { "taster_feedback_matcha_solo", "taster_feedback_cayenne_solo" } },
	{ requires = { "matcha", "whiskey" }, ratios = { { "coffee", "==", 0 } }, score = -18, feedback = "taster_feedback_matcha_whiskey_bad", voids = { "taster_feedback_matcha_solo", "taster_feedback_whiskey_solo" } },
	{ requires = { "matcha", "milk" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">", 0 } }, score = 18, feedback = "taster_feedback_matcha_latte", voids = { "taster_feedback_matcha_solo" } },
	{ requires = { "matcha", "cream" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">", 0 } }, score = 16, feedback = "taster_feedback_matcha_latte", voids = { "taster_feedback_matcha_solo", "taster_feedback_cream_solo" } },
	{ requires = { "matcha", "lemon" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">", 0 } }, score = 12, feedback = "taster_feedback_matcha_lemonade", voids = { "taster_feedback_matcha_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "matcha", "yuzu" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">", 0 } }, score = 12, feedback = "taster_feedback_matcha_yuzu", voids = { "taster_feedback_matcha_solo", "taster_feedback_yuzu_solo" } },
	{ requires = { "matcha", "strawberry" }, ratios = { { "coffee", "==", 0 } }, score = 6, feedback = "taster_feedback_matcha_strawberry", unique = true, voids = { "taster_feedback_matcha_solo", "taster_feedback_strawberry_solo" } },
	{ requires = { "matcha", "coconut" }, ratios = { { "coffee", "==", 0 } }, score = 5, feedback = "taster_feedback_matcha_coconut", unique = true, voids = { "taster_feedback_matcha_solo", "taster_feedback_coconut_solo" } },
	{ requires = { "matcha", "honey" }, score = 5, feedback = "taster_feedback_matcha_honey", unique = true, voids = { "taster_feedback_matcha_solo", "taster_feedback_honey_solo" } },
	{ requires = { "matcha" }, score = 0, feedback = "taster_feedback_matcha_solo", unique = true },

	-- MILK ------------------------------------------------------------------
	{ requires = { "milk" }, forbids = { "ice_cream" }, categories = { "beverage", "blend" }, ratios = { { "coffee", "==", 0 }, { "cacao", ">", 0 } }, score = 18, feedback = "taster_feedback_hot_chocolate" },

	-- MINT ------------------------------------------------------------------
	{ requires = { "mint" }, counts = { { "mint", ">=", 2 } }, score = -18, feedback = "taster_feedback_mint_overuse", voids = { "taster_feedback_mint_solo" } },
	{ requires = { "mint", "ginger" }, ratios = { { "coffee", ">", 0 } }, score = -20, feedback = "taster_feedback_ginger_mint_coffee_bad", voids = { "taster_feedback_ginger_solo", "taster_feedback_mint_solo" } },
	{ requires = { "mint", "clove" }, score = -14, feedback = "taster_feedback_mint_clove_bad", voids = { "taster_feedback_mint_solo", "taster_feedback_clove_solo" } },
	{ requires = { "mint" }, score = 0, feedback = "taster_feedback_mint_solo", unique = true },

	-- NUTMEG ----------------------------------------------------------------
	{ requires = { "nutmeg" }, counts = { { "nutmeg", ">=", 2 } }, score = -18, feedback = "taster_feedback_nutmeg_overuse", voids = { "taster_feedback_nutmeg_solo" } },
	{ requires = { "nutmeg" }, score = 0, feedback = "taster_feedback_nutmeg_solo", unique = true },

	-- OAT -------------------------------------------------------------------
	{ requires = { "oat", "maple" }, score = 5, feedback = "taster_feedback_oat_sweet", unique = true, voids = { "taster_feedback_oat_solo", "taster_feedback_maple_solo" } },
	{ requires = { "oat", "honey" }, score = 5, feedback = "taster_feedback_oat_sweet", unique = true, voids = { "taster_feedback_oat_solo", "taster_feedback_honey_solo" } },
	{ requires = { "oat" }, score = 0, feedback = "taster_feedback_oat_solo", unique = true },

	-- ORANGE ----------------------------------------------------------------
	{ requires = { "orange" }, ratios = { { "coffee", ">", 0 }, { "cacao", ">", 0 } }, score = 18, feedback = "taster_feedback_coffee_orange_mocha", voids = { "taster_feedback_orange_solo", "taster_feedback_mocha" } },
	{ requires = { "orange", "kahlua" }, score = 5, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_kahlua_solo" } },
	{ requires = { "orange", "amaretto" }, score = 5, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_amaretto_solo" } },
	{ requires = { "orange", "grand_marnier" }, score = 5, feedback = "taster_feedback_mediterranean", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_grand_marnier_solo" } },
	{ requires = { "orange", "cinnamon" }, score = 6, feedback = "taster_feedback_orange_cinnamon", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "orange", "clove" }, score = 5, feedback = "taster_feedback_orange_clove", unique = true, voids = { "taster_feedback_orange_solo", "taster_feedback_clove_solo" } },
	{ requires = { "orange" }, score = 0, feedback = "taster_feedback_orange_solo", unique = true },

	-- PASSIONFRUIT ----------------------------------------------------------
	{ requires = { "passionfruit" }, score = 0, feedback = "taster_feedback_passionfruit_solo", unique = true },

	-- PEACH -----------------------------------------------------------------
	{ requires = { "peach", "vanilla" }, score = 5, feedback = "taster_feedback_vanilla_sweet", unique = true, voids = { "taster_feedback_vanilla_solo", "taster_feedback_peach_solo" } },
	{ requires = { "peach", "cream" }, score = 5, feedback = "taster_feedback_peach_cream", unique = true, voids = { "taster_feedback_peach_solo", "taster_feedback_cream_solo" } },
	{ requires = { "peach" }, score = 0, feedback = "taster_feedback_peach_solo", unique = true },

	-- PEANUT ----------------------------------------------------------------
	{ requires = { "peanut" }, score = 0, feedback = "taster_feedback_peanut_solo", unique = true },

	-- PEAR ------------------------------------------------------------------
	{ requires = { "pear" }, score = 0, feedback = "taster_feedback_pear_solo", unique = true },

	-- PECAN -----------------------------------------------------------------
	{ requires = { "pecan", "maple" }, ratios = { { "coffee", ">", 0 } }, score = 8, feedback = "taster_feedback_coffee_nutty_maple", voids = { "taster_feedback_coffee_maple", "taster_feedback_pecan_solo", "taster_feedback_maple_solo" } },
	{ requires = { "pecan", "caramel" }, score = 6, feedback = "taster_feedback_pecan_caramel", unique = true, voids = { "taster_feedback_pecan_solo" } },
	{ requires = { "pecan" }, score = 0, feedback = "taster_feedback_pecan_solo", unique = true },

	-- PINEAPPLE -------------------------------------------------------------
	{ requires = { "pineapple", "coconut" }, score = 6, feedback = "taster_feedback_pineapple_coconut", unique = true, voids = { "taster_feedback_pineapple_solo", "taster_feedback_coconut_solo" } },
	{ requires = { "pineapple", "coconut", "rum" }, categories = { "beverage" }, score = 14, feedback = "taster_feedback_rum_pina_colada", unique = true, voids = { "taster_feedback_pineapple_coconut", "taster_feedback_pineapple_solo", "taster_feedback_coconut_solo", "taster_feedback_rum_solo" } },
	{ requires = { "pineapple" }, score = 0, feedback = "taster_feedback_pineapple_solo", unique = true },

	-- PISTACHIO -------------------------------------------------------------
	{ requires = { "pistachio" }, score = 0, feedback = "taster_feedback_pistachio_solo", unique = true },

	-- PLUM ------------------------------------------------------------------
	{ requires = { "plum", "cinnamon" }, score = 5, feedback = "taster_feedback_plum_cinnamon", unique = true, voids = { "taster_feedback_plum_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "plum", "brandy" }, score = 6, feedback = "taster_feedback_plum_brandy", unique = true, voids = { "taster_feedback_plum_solo", "taster_feedback_brandy_solo" } },
	{ requires = { "plum" }, score = 0, feedback = "taster_feedback_plum_solo", unique = true },

	-- POMEGRANATE -----------------------------------------------------------
	{ requires = { "pomegranate" }, score = 0, feedback = "taster_feedback_pomegranate_solo", unique = true },

	-- POWDER ----------------------------------------------------------------
	{ requires = { "powder" }, counts = { { "powder", ">=", 2 } }, score = -22, feedback = "taster_feedback_powder_overuse", voids = { "taster_feedback_powder_solo" } },
	{ requires = { "powder" }, score = 0, feedback = "taster_feedback_powder_solo", unique = true },

	-- PUMPKIN ---------------------------------------------------------------
	{ requires = { "pumpkin" }, score = 0, feedback = "taster_feedback_pumpkin_solo", unique = true },

	-- RAISIN ----------------------------------------------------------------
	{ requires = { "raisin" }, score = 0, feedback = "taster_feedback_raisin_solo", unique = true },

	-- RASPBERRY -------------------------------------------------------------
	{ requires = { "raspberry", "cream" }, score = 5, feedback = "taster_feedback_raspberry_cream", unique = true, voids = { "taster_feedback_raspberry_solo", "taster_feedback_cream_solo" } },
	{ requires = { "raspberry" }, score = 0, feedback = "taster_feedback_raspberry_solo", unique = true },

	-- RHUBARB ---------------------------------------------------------------
	{ requires = { "rhubarb" }, score = 0, feedback = "taster_feedback_rhubarb_solo", unique = true },

	-- ROOIBOS ---------------------------------------------------------------
	{ requires = { "rooibos" }, ratios = { { "coffee", "==", 0 }, { "dairy", ">=", 0.8 } }, score = -55, feedback = "taster_feedback_tea_alldairy", negative = true, voids = { "taster_coffee_alldairy", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "rooibos" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">=", 0.8 } }, score = -55, feedback = "taster_feedback_tea_allsugar", negative = true, voids = { "taster_coffee_allsugar", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "rooibos" }, ratios = { { "coffee", "==", 0 }, { "cacao", ">=", 0.7 } }, score = -55, feedback = "taster_feedback_tea_allcacao", negative = true, voids = { "taster_coffee_allcacao", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "rooibos", "wasabi" }, ratios = { { "coffee", "==", 0 } }, score = -22, feedback = "taster_feedback_rooibos_wasabi_bad", voids = { "taster_feedback_rooibos_solo", "taster_feedback_wasabi_solo" } },
	{ requires = { "rooibos", "vanilla" }, ratios = { { "coffee", "==", 0 } }, score = 8, feedback = "taster_feedback_rooibos_vanilla", unique = true, voids = { "taster_feedback_vanilla_solo", "taster_feedback_rooibos_solo" } },
	{ requires = { "rooibos", "cinnamon" }, ratios = { { "coffee", "==", 0 } }, score = 6, feedback = "taster_feedback_rooibos_cinnamon", unique = true, voids = { "taster_feedback_rooibos_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "rooibos", "orange" }, ratios = { { "coffee", "==", 0 } }, score = 5, feedback = "taster_feedback_rooibos_orange", unique = true, voids = { "taster_feedback_rooibos_solo", "taster_feedback_orange_solo" } },
	{ requires = { "rooibos", "milk" }, ratios = { { "coffee", "==", 0 } }, score = 5, feedback = "taster_feedback_rooibos_milk", unique = true, voids = { "taster_feedback_rooibos_solo" } },
	{ requires = { "rooibos" }, score = 0, feedback = "taster_feedback_rooibos_solo", unique = true },

	-- ROSE ------------------------------------------------------------------
	{ requires = { "rose" }, counts = { { "rose", ">=", 2 } }, score = -20, feedback = "taster_feedback_rose_overuse", voids = { "taster_feedback_rose_solo" } },
	{ requires = { "rose", "lavender", "jasmine" }, score = -18, feedback = "taster_feedback_floral_overload_bad", voids = { "taster_feedback_rose_solo", "taster_feedback_lavender_solo", "taster_feedback_jasmine_solo" } },
	{ requires = { "rose", "cardamom" }, score = 7, feedback = "taster_feedback_rose_cardamom", unique = true, voids = { "taster_feedback_rose_solo", "taster_feedback_cardamom_solo" } },
	{ requires = { "rose", "pistachio" }, score = 7, feedback = "taster_feedback_rose_pistachio", unique = true, voids = { "taster_feedback_rose_solo", "taster_feedback_pistachio_solo" } },
	{ requires = { "rose", "raspberry" }, score = 7, feedback = "taster_feedback_rose_raspberry", unique = true, voids = { "taster_feedback_rose_solo", "taster_feedback_raspberry_solo" } },
	{ requires = { "rose", "vanilla" }, score = 5, feedback = "taster_feedback_rose_vanilla", unique = true, voids = { "taster_feedback_rose_solo", "taster_feedback_vanilla_solo" } },
	{ requires = { "rose" }, score = 0, feedback = "taster_feedback_rose_solo", unique = true },

	-- ROSEMARY --------------------------------------------------------------
	{ requires = { "rosemary" }, counts = { { "rosemary", ">=", 2 } }, score = -18, feedback = "taster_feedback_rosemary_overuse", voids = { "taster_feedback_rosemary_solo" } },
	{ requires = { "rosemary", "marshmallow" }, score = -18, feedback = "taster_feedback_rosemary_marshmallow_bad", voids = { "taster_feedback_rosemary_solo", "taster_feedback_marshmallow_solo" } },
	{ requires = { "rosemary", "banana" }, score = -14, feedback = "taster_feedback_rosemary_banana_bad", voids = { "taster_feedback_rosemary_solo", "taster_feedback_banana_solo" } },
	{ requires = { "rosemary", "lychee" }, score = -16, feedback = "taster_feedback_rosemary_lychee_bad", voids = { "taster_feedback_rosemary_solo", "taster_feedback_lychee_solo" } },
	{ requires = { "rosemary", "lemon" }, score = 4, feedback = "taster_feedback_rosemary_citrus", unique = true, voids = { "taster_feedback_rosemary_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "rosemary", "orange" }, score = 4, feedback = "taster_feedback_rosemary_citrus", unique = true, voids = { "taster_feedback_rosemary_solo", "taster_feedback_orange_solo" } },
	{ requires = { "rosemary", "honey" }, score = 5, feedback = "taster_feedback_rosemary_honey", unique = true, voids = { "taster_feedback_rosemary_solo", "taster_feedback_honey_solo" } },
	{ requires = { "rosemary" }, ratios = { { "cacao", ">=", 0.5 } }, score = 6, feedback = "taster_feedback_rosemary_darkchoc", unique = true, voids = { "taster_feedback_rosemary_solo" } },
	{ requires = { "rosemary" }, score = 0, feedback = "taster_feedback_rosemary_solo", unique = true },

	-- RUM -------------------------------------------------------------------
	{ requires = { "rum", "coconut" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", ">", 0 } }, score = 16, feedback = "taster_feedback_coffee_tropical", voids = { "taster_feedback_rum_solo", "taster_feedback_coconut_solo" } },
	{ requires = { "rum", "caramel" }, forbids = { "sugar", "honey" }, trait_counts = { { "alcohol", "==", 1 } }, score = 14, feedback = "taster_feedback_coffee_caramel_rum", voids = { "taster_feedback_rum_solo", "taster_feedback_coffee_caramel" } },
	{ requires = { "rum", "raisin" }, score = 5, feedback = "taster_feedback_rum_raisin", unique = true, voids = { "taster_feedback_rum_solo", "taster_feedback_raisin_solo" } },
	{ requires = { "rum" }, score = 0, feedback = "taster_feedback_rum_solo", unique = true },

	-- SAFFRON ---------------------------------------------------------------
	{ requires = { "saffron" }, counts = { { "saffron", ">=", 2 } }, score = -22, feedback = "taster_feedback_saffron_overuse", voids = { "taster_feedback_saffron_solo" } },
	{ requires = { "saffron", "pistachio" }, score = 8, feedback = "taster_feedback_saffron_pistachio", unique = true, voids = { "taster_feedback_saffron_solo", "taster_feedback_pistachio_solo" } },
	{ requires = { "saffron", "almond" }, score = 7, feedback = "taster_feedback_saffron_almond", unique = true, voids = { "taster_feedback_saffron_solo", "taster_feedback_almond_solo" } },
	{ requires = { "saffron", "honey" }, score = 7, feedback = "taster_feedback_saffron_honey", unique = true, voids = { "taster_feedback_saffron_solo", "taster_feedback_honey_solo" } },
	{ requires = { "saffron", "vanilla" }, score = 6, feedback = "taster_feedback_saffron_vanilla", unique = true, voids = { "taster_feedback_saffron_solo", "taster_feedback_vanilla_solo" } },
	{ requires = { "saffron" }, score = 0, feedback = "taster_feedback_saffron_solo", unique = true },

	-- SALT ------------------------------------------------------------------
	{ requires = { "salt" }, counts = { { "salt", ">=", 2 } }, score = -30, feedback = "taster_feedback_salt_overuse", voids = { "taster_feedback_salt_solo" } },
	{ requires = { "salt" }, forbids = { "caramel", "toffee", "sugar", "milk", "cream", "whipped_cream", "honey", "maple" }, ratios = { { "coffee", ">", 0 } }, score = -25, feedback = "taster_feedback_coffee_salt_bad", voids = { "taster_feedback_salt_solo" } },
	{ requires = { "salt" }, score = 0, feedback = "taster_feedback_salt_solo", unique = true },

	-- SESAME ----------------------------------------------------------------
	{ requires = { "sesame" }, score = 0, feedback = "taster_feedback_sesame_solo", unique = true },

	-- STAR ANISE ------------------------------------------------------------
	{ requires = { "star_anise" }, counts = { { "star_anise", ">=", 2 } }, score = -22, feedback = "taster_feedback_star_anise_overuse", voids = { "taster_feedback_star_anise_solo" } },
	{ requires = { "star_anise", "orange" }, score = 6, feedback = "taster_feedback_star_anise_orange", unique = true, voids = { "taster_feedback_star_anise_solo", "taster_feedback_orange_solo" } },
	{ requires = { "star_anise", "cherry" }, score = 6, feedback = "taster_feedback_star_anise_cherry", unique = true, voids = { "taster_feedback_star_anise_solo", "taster_feedback_cherry_solo" } },
	{ requires = { "star_anise", "plum" }, score = 6, feedback = "taster_feedback_star_anise_plum", unique = true, voids = { "taster_feedback_star_anise_solo", "taster_feedback_plum_solo" } },
	{ requires = { "star_anise" }, ratios = { { "coffee", ">", 0 } }, score = 7, feedback = "taster_feedback_star_anise_coffee", unique = true, voids = { "taster_feedback_star_anise_solo" } },
	{ requires = { "star_anise" }, score = 0, feedback = "taster_feedback_star_anise_solo", unique = true },

	-- STRAWBERRY ------------------------------------------------------------
	{ requires = { "strawberry", "cream" }, score = 5, feedback = "taster_feedback_strawberry_cream", unique = true, voids = { "taster_feedback_strawberry_solo", "taster_feedback_cream_solo" } },
	{ requires = { "strawberry" }, score = 0, feedback = "taster_feedback_strawberry_solo", unique = true },

	-- SUMAC -----------------------------------------------------------------
	{ requires = { "sumac" }, counts = { { "sumac", ">=", 2 } }, score = -18, feedback = "taster_feedback_sumac_overuse", voids = { "taster_feedback_sumac_solo" } },
	{ requires = { "sumac", "salt" }, score = 6, feedback = "taster_feedback_sumac_salt", unique = true, voids = { "taster_feedback_sumac_solo", "taster_feedback_salt_solo" } },
	{ requires = { "sumac", "honey" }, score = 6, feedback = "taster_feedback_sumac_honey", unique = true, voids = { "taster_feedback_sumac_solo", "taster_feedback_honey_solo" } },
	{ requires = { "sumac", "strawberry" }, score = 5, feedback = "taster_feedback_sumac_berry", unique = true, voids = { "taster_feedback_sumac_solo", "taster_feedback_strawberry_solo" } },
	{ requires = { "sumac" }, score = 0, feedback = "taster_feedback_sumac_solo", unique = true },

	-- TAMARIND --------------------------------------------------------------
	{ requires = { "tamarind" }, counts = { { "tamarind", ">=", 2 } }, score = -18, feedback = "taster_feedback_tamarind_overuse", voids = { "taster_feedback_tamarind_solo" } },
	{ requires = { "tamarind", "lavender" }, score = -16, feedback = "taster_feedback_tamarind_lavender_bad", voids = { "taster_feedback_tamarind_solo", "taster_feedback_lavender_solo" } },
	{ requires = { "tamarind", "rose" }, score = -16, feedback = "taster_feedback_tamarind_rose_bad", voids = { "taster_feedback_tamarind_solo", "taster_feedback_rose_solo" } },
	{ requires = { "tamarind", "mango" }, score = 6, feedback = "taster_feedback_tamarind_mango", unique = true, voids = { "taster_feedback_tamarind_solo", "taster_feedback_mango_solo" } },
	{ requires = { "tamarind", "coconut" }, score = 5, feedback = "taster_feedback_tamarind_coconut", unique = true, voids = { "taster_feedback_tamarind_solo", "taster_feedback_coconut_solo" } },
	{ requires = { "tamarind", "ginger" }, score = 7, feedback = "taster_feedback_tamarind_ginger", unique = true, voids = { "taster_feedback_tamarind_solo", "taster_feedback_ginger_solo" } },
	{ requires = { "tamarind", "caramel" }, score = 6, feedback = "taster_feedback_tamarind_caramel", unique = true, voids = { "taster_feedback_tamarind_solo" } },
	{ requires = { "tamarind" }, ratios = { { "cacao", ">=", 0.5 } }, score = 7, feedback = "taster_feedback_tamarind_darkchoc", unique = true, voids = { "taster_feedback_tamarind_solo" } },
	{ requires = { "tamarind" }, score = 0, feedback = "taster_feedback_tamarind_solo", unique = true },

	-- TANGIER COFFEE --------------------------------------------------------
	{ requires = { "tan_coffee", "cardamom" }, forbids = { "bal_coffee", "bog_coffee", "hav_coffee", "kon_coffee", "espresso" }, counts = { { "cardamom", "==", 1 } }, score = 14, feedback = "taster_feedback_tangier_cardamom_coffee", voids = { "taster_feedback_tan_coffee_profile", "taster_feedback_cardamom_solo" } },
	{ requires = { "tan_coffee" }, score = 0, feedback = "taster_feedback_tan_coffee_profile", unique = true },

	-- TEA -------------------------------------------------------------------
	{ requires = { "tea" }, counts = { { "tea", ">=", 2 } }, score = -16, feedback = "taster_feedback_tea_overuse", voids = { "taster_feedback_blacktea_solo" } },
	{ requires = { "tea" }, ratios = { { "coffee", "==", 0 }, { "dairy", ">=", 0.8 } }, score = -55, feedback = "taster_feedback_tea_alldairy", negative = true, voids = { "taster_coffee_alldairy", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "tea" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">=", 0.8 } }, score = -55, feedback = "taster_feedback_tea_allsugar", negative = true, voids = { "taster_coffee_allsugar", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "tea" }, ratios = { { "coffee", "==", 0 }, { "cacao", ">=", 0.7 } }, score = -55, feedback = "taster_feedback_tea_allcacao", negative = true, voids = { "taster_coffee_allcacao", "taster_feedback_blacktea_solo", "taster_feedback_earl_grey_solo", "taster_feedback_jasmine_solo", "taster_feedback_chamomile_solo", "taster_feedback_rooibos_solo", "taster_feedback_matcha_solo", "taster_feedback_hibiscus_solo", "taster_feedback_lemongrass_solo" } },
	{ requires = { "tea", "wasabi" }, ratios = { { "coffee", "==", 0 } }, score = -30, feedback = "taster_feedback_blacktea_wasabi_bad", voids = { "taster_feedback_blacktea_solo", "taster_feedback_wasabi_solo" } },
	{ requires = { "tea", "cinnamon", "milk" }, ratios = { { "coffee", "==", 0 } }, score = 18, feedback = "taster_feedback_tea_chai", voids = { "taster_feedback_blacktea_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "tea", "cinnamon", "cream" }, ratios = { { "coffee", "==", 0 } }, score = 18, feedback = "taster_feedback_tea_chai", voids = { "taster_feedback_blacktea_solo", "taster_feedback_cinnamon_solo", "taster_feedback_cream_solo" } },
	{ requires = { "tea", "whiskey", "honey" }, categories = { "beverage" }, ratios = { { "coffee", "==", 0 } }, score = 18, feedback = "taster_feedback_tea_hot_toddy", voids = { "taster_feedback_blacktea_solo", "taster_feedback_honey_solo", "taster_feedback_whiskey_solo" } },
	{ requires = { "tea", "mint" }, ratios = { { "coffee", "==", 0 }, { "sugar", ">", 0 } }, score = 12, feedback = "taster_feedback_tea_moroccan_style", voids = { "taster_feedback_blacktea_solo", "taster_feedback_mint_solo" } },
	{ requires = { "tea", "rose" }, ratios = { { "coffee", "==", 0 } }, score = 10, feedback = "taster_feedback_blacktea_rose", voids = { "taster_feedback_blacktea_solo", "taster_feedback_rose_solo" } },
	{ requires = { "tea", "lavender" }, ratios = { { "coffee", "==", 0 } }, score = 10, feedback = "taster_feedback_blacktea_lavender", voids = { "taster_feedback_blacktea_solo", "taster_feedback_lavender_solo" } },
	{ requires = { "tea", "jasmine" }, ratios = { { "coffee", "==", 0 } }, score = 10, feedback = "taster_feedback_blacktea_jasmine", voids = { "taster_feedback_blacktea_solo", "taster_feedback_jasmine_solo" } },
	{ requires = { "tea", "honey" }, forbids = { "whiskey" }, ratios = { { "coffee", "==", 0 } }, score = 8, feedback = "taster_feedback_blacktea_honey", unique = true, voids = { "taster_feedback_blacktea_solo", "taster_feedback_honey_solo" } },
	{ requires = { "tea", "lemon" }, ratios = { { "coffee", "==", 0 } }, score = 8, feedback = "taster_feedback_blacktea_lemon", unique = true, voids = { "taster_feedback_blacktea_solo", "taster_feedback_lemon_solo" } },
	{ requires = { "tea", "cream" }, forbids = { "cinnamon" }, ratios = { { "coffee", "==", 0 } }, score = 8, feedback = "taster_feedback_blacktea_cream", unique = true, voids = { "taster_feedback_blacktea_solo", "taster_feedback_cream_solo" } },
	{ requires = { "tea", "milk" }, forbids = { "cinnamon" }, ratios = { { "coffee", "==", 0 } }, score = 8, feedback = "taster_feedback_blacktea_milk", unique = true, voids = { "taster_feedback_blacktea_solo" } },
	{ requires = { "tea", "cardamom" }, ratios = { { "coffee", "==", 0 } }, score = 6, feedback = "taster_feedback_blacktea_cardamom", unique = true, voids = { "taster_feedback_blacktea_solo", "taster_feedback_cardamom_solo" } },
	{ requires = { "tea", "ginger" }, ratios = { { "coffee", "==", 0 } }, score = 6, feedback = "taster_feedback_blacktea_ginger", unique = true, voids = { "taster_feedback_blacktea_solo", "taster_feedback_ginger_solo" } },
	{ requires = { "tea", "orange" }, ratios = { { "coffee", "==", 0 } }, score = 5, feedback = "taster_feedback_blacktea_orange", unique = true, voids = { "taster_feedback_blacktea_solo", "taster_feedback_orange_solo" } },
	{ requires = { "tea", "peach" }, ratios = { { "coffee", "==", 0 } }, score = 5, feedback = "taster_feedback_blacktea_peach", unique = true, voids = { "taster_feedback_blacktea_solo", "taster_feedback_peach_solo" } },
	{ requires = { "tea", "cinnamon" }, forbids = { "espresso" }, ratios = { { "coffee", ">", 0 } }, score = 18, feedback = "taster_feedback_dirty_chai", voids = { "taster_feedback_blacktea_solo", "taster_feedback_cinnamon_solo" } },
	{ requires = { "tea", "milk" }, forbids = { "cinnamon", "cardamom", "ginger" }, ratios = { { "coffee", ">", 0 } }, score = 18, feedback = "taster_feedback_coffee_yuenyuang", voids = { "taster_feedback_blacktea_solo" } },
	{ requires = { "tea" }, score = 0, feedback = "taster_feedback_blacktea_solo", unique = true },

	-- TOFFEE ----------------------------------------------------------------
	{ requires = { "toffee" }, counts = { { "toffee", ">=", 3 } }, score = -16, feedback = "taster_feedback_toffee_overuse", voids = { "taster_feedback_toffee_solo" } },
	{ requires = { "toffee" }, forbids = { "ice_cream" }, ratios = { { "coffee", ">", 0 } }, score = 6, feedback = "taster_feedback_coffee_toffee", unique = true, voids = { "taster_feedback_toffee_solo" } },
	{ requires = { "toffee" }, score = 0, feedback = "taster_feedback_toffee_solo", unique = true },

	-- TURMERIC --------------------------------------------------------------
	{ requires = { "turmeric" }, counts = { { "turmeric", ">=", 2 } }, score = -20, feedback = "taster_feedback_turmeric_overuse", voids = { "taster_feedback_turmeric_solo" } },
	{ requires = { "turmeric", "milk", "honey" }, counts = { { "turmeric", "==", 1 } }, ratios = { { "coffee", "==", 0 } }, score = 16, feedback = "taster_feedback_coffee_golden_turmeric", voids = { "taster_feedback_turmeric_solo", "taster_feedback_honey_solo" } },
	{ requires = { "turmeric" }, counts = { { "turmeric", "==", 1 } }, ratios = { { "coffee", ">", 0 }, { "dairy", ">=", 0.2 } }, score = 8, feedback = "taster_feedback_coffee_golden_milk", unique = true, voids = { "taster_feedback_turmeric_solo" } },
	{ requires = { "turmeric", "ginger" }, score = 5, feedback = "taster_feedback_turmeric_ginger", unique = true, voids = { "taster_feedback_turmeric_solo", "taster_feedback_ginger_solo" } },
	{ requires = { "turmeric" }, score = 0, feedback = "taster_feedback_turmeric_solo", unique = true },

	-- VANILLA ---------------------------------------------------------------
	{ requires = { "vanilla" }, counts = { { "vanilla", ">=", 2 } }, score = -18, feedback = "taster_feedback_vanilla_overuse", voids = { "taster_feedback_vanilla_solo" } },
	{ requires = { "vanilla" }, forbids = { "espresso", "kon_coffee" }, counts = { { "vanilla", "==", 1 } }, ratios = { { "coffee", ">", 0 } }, score = 6, feedback = "taster_feedback_coffee_vanilla", unique = true, voids = { "taster_feedback_vanilla_solo" } },
	{ requires = { "vanilla", "caramel" }, score = 8, feedback = "taster_feedback_vanilla_sweet", unique = true, voids = { "taster_feedback_vanilla_solo" } },
	{ requires = { "vanilla", "maple" }, score = 8, feedback = "taster_feedback_vanilla_sweet", unique = true, voids = { "taster_feedback_vanilla_solo", "taster_feedback_maple_solo" } },
	{ requires = { "vanilla" }, forbids = { "espresso" }, ratios = { { "coffee", ">", 0 } }, score = 6, feedback = "taster_feedback_coffee_vanilla", unique = true, voids = { "taster_feedback_vanilla_solo" } },
	{ requires = { "vanilla" }, score = 0, feedback = "taster_feedback_vanilla_solo", unique = true },

	-- WAFER -----------------------------------------------------------------
	{ requires = { "wafer", "hazelnut" }, score = 5, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_hazelnut_solo", "taster_feedback_wafer_solo" } },
	{ requires = { "wafer", "almond" }, score = 5, feedback = "taster_feedback_crunchy_smooth", unique = true, voids = { "taster_feedback_almond_solo", "taster_feedback_wafer_solo" } },
	{ requires = { "wafer" }, score = 0, feedback = "taster_feedback_wafer_solo", unique = true },

	-- WALNUT ----------------------------------------------------------------
	{ requires = { "walnut" }, score = 0, feedback = "taster_feedback_walnut_solo", unique = true },

	-- WASABI ----------------------------------------------------------------
	{ requires = { "wasabi" }, counts = { { "wasabi", ">=", 2 } }, score = -32, feedback = "taster_feedback_wasabi_overuse", voids = { "taster_feedback_wasabi_solo" } },
	{ requires = { "wasabi" }, ratios = { { "coffee", ">", 0 } }, score = -40, feedback = "taster_feedback_coffee_wasabi_bad", voids = { "taster_feedback_wasabi_solo" } },
	{ requires = { "wasabi", "cayenne" }, score = -36, feedback = "taster_feedback_wasabi_cayenne_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_cayenne_solo" } },
	{ requires = { "wasabi", "lavender" }, score = -24, feedback = "taster_feedback_wasabi_lavender_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_lavender_solo" } },
	{ requires = { "wasabi", "chamomile" }, score = -24, feedback = "taster_feedback_chamomile_wasabi_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_chamomile_solo" } },
	{ requires = { "wasabi", "earl_grey" }, score = -22, feedback = "taster_feedback_earl_grey_wasabi_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_earl_grey_solo" } },
	{ requires = { "wasabi", "marshmallow" }, score = -28, feedback = "taster_feedback_wasabi_marshmallow_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_marshmallow_solo" } },
	{ requires = { "wasabi", "oat" }, score = -18, feedback = "taster_feedback_wasabi_oat_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_oat_solo" } },
	{ requires = { "wasabi", "saffron" }, score = -24, feedback = "taster_feedback_wasabi_saffron_bad", voids = { "taster_feedback_wasabi_solo", "taster_feedback_saffron_solo" } },
	{ requires = { "wasabi" }, score = 0, feedback = "taster_feedback_wasabi_solo", unique = true },

	-- WHIPPED CREAM ---------------------------------------------------------
	-- In finished beverages whipped cream behaves as a topping/temperature layer,
	-- not merely another generic dairy ingredient.
	{ requires = { "whipped_cream" }, counts = { { "whipped_cream", ">=", 2 } }, score = -20, feedback = "taster_feedback_whipped_cream_overuse", voids = { "taster_coffee_alldairy", "taster_feedback_whipped_cream_solo", "taster_feedback_coffee_whipped_cream", "taster_feedback_espresso_whipped_cream", "taster_feedback_irish_coffee_whipped", "taster_feedback_mocha_whipped_cream", "taster_feedback_hot_chocolate_whipped", "taster_feedback_caramel_coffee_whipped", "taster_feedback_pumpkin_coffee_whipped", "taster_feedback_chai_whipped_cream", "taster_feedback_whipped_cream_matcha" } },
	{ requires = { "espresso", "whipped_cream" }, categories = { "beverage" }, score = 18, feedback = "taster_feedback_espresso_whipped_cream", voids = { "taster_feedback_coffee_whipped_cream", "taster_feedback_espresso_profile", "taster_feedback_espresso_solo", "taster_feedback_whipped_cream_solo" } },
	{ requires = { "whiskey", "whipped_cream" }, categories = { "beverage" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", ">", 0 } }, score = 20, feedback = "taster_feedback_irish_coffee_whipped", voids = { "taster_feedback_coffee_whipped_cream", "taster_feedback_coffee_whiskey", "taster_feedback_whiskey_solo", "taster_feedback_whipped_cream_solo" } },
	{ requires = { "whipped_cream" }, categories = { "beverage" }, ratios = { { "coffee", ">", 0 }, { "cacao", ">", 0 } }, score = 16, feedback = "taster_feedback_mocha_whipped_cream", voids = { "taster_feedback_mocha", "taster_feedback_coffee_whipped_cream", "taster_feedback_whipped_cream_solo" } },
	{ requires = { "milk", "whipped_cream" }, categories = { "beverage" }, ratios = { { "coffee", "==", 0 }, { "cacao", ">", 0 } }, score = 18, feedback = "taster_feedback_hot_chocolate_whipped", voids = { "taster_feedback_hot_chocolate", "taster_feedback_whipped_cream_solo" } },
	{ requires = { "caramel", "whipped_cream" }, categories = { "beverage" }, ratios = { { "coffee", ">", 0 } }, score = 14, feedback = "taster_feedback_caramel_coffee_whipped", unique = true, voids = { "taster_feedback_coffee_caramel", "taster_feedback_coffee_whipped_cream", "taster_feedback_whipped_cream_solo" } },
	{ requires = { "pumpkin", "cinnamon", "whipped_cream" }, categories = { "beverage" }, ratios = { { "coffee", ">", 0 } }, score = 20, feedback = "taster_feedback_pumpkin_coffee_whipped", voids = { "taster_feedback_autumn_spice", "taster_feedback_coffee_whipped_cream", "taster_feedback_pumpkin_solo", "taster_feedback_cinnamon_solo", "taster_feedback_whipped_cream_solo" } },
	{ requires = { "tea", "cinnamon", "whipped_cream" }, categories = { "beverage" }, ratios = { { "coffee", "==", 0 } }, score = 12, feedback = "taster_feedback_chai_whipped_cream", unique = true, voids = { "taster_feedback_tea_chai", "taster_feedback_blacktea_solo", "taster_feedback_cinnamon_solo", "taster_feedback_whipped_cream_solo" } },
	{ requires = { "matcha", "whipped_cream" }, categories = { "beverage" }, ratios = { { "coffee", "==", 0 } }, score = 10, feedback = "taster_feedback_whipped_cream_matcha", unique = true, voids = { "taster_feedback_matcha_latte", "taster_feedback_matcha_solo", "taster_feedback_whipped_cream_solo" } },
	{ requires = { "whipped_cream" }, ratios = { { "coffee", ">", 0 } }, score = 10, feedback = "taster_feedback_coffee_whipped_cream", voids = { "taster_feedback_whipped_cream_solo" } },
	{ requires = { "whipped_cream" }, score = 0, feedback = "taster_feedback_whipped_cream_solo", unique = true },

	-- WHISKEY ---------------------------------------------------------------
	{ requires = { "whiskey", "cream" }, forbids = { "espresso" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", ">", 0 } }, score = 20, feedback = "taster_feedback_coffee_nutty_irish", voids = { "taster_feedback_cream_solo", "taster_feedback_whiskey_solo" } },
	{ requires = { "whiskey" }, forbids = { "cream" }, trait_counts = { { "alcohol", "==", 1 } }, ratios = { { "coffee", ">", 0 } }, score = 7, feedback = "taster_feedback_coffee_whiskey", unique = true, voids = { "taster_feedback_whiskey_solo" } },
	{ requires = { "whiskey" }, score = 0, feedback = "taster_feedback_whiskey_solo", unique = true },

	-- YUZU ------------------------------------------------------------------
	{ requires = { "yuzu" }, counts = { { "yuzu", ">=", 2 } }, score = -16, feedback = "taster_feedback_yuzu_overuse", voids = { "taster_feedback_yuzu_solo" } },
	{ requires = { "yuzu" }, score = 0, feedback = "taster_feedback_yuzu_solo", unique = true },
}

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
	local validTraits = { alcohol = true }
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

			for _, countCondition in ipairs(rule.counts or {}) do
				local ingredientName = countCondition[1]
				local operator = countCondition[2]
				local value = countCondition[3]

				ValidateIngredientList(poolName, ruleIndex, "counts", { ingredientName })
				if not validOperators[operator] then
					Report(string.format("%s rule %d uses unsupported count operator '%s'.",
						poolName, ruleIndex, tostring(operator)))
				end
				if type(value) ~= "number" then
					Report(string.format("%s rule %d has a non-numeric ingredient count value.", poolName, ruleIndex))
				end
			end

			for _, traitCondition in ipairs(rule.trait_counts or {}) do
				local traitName = traitCondition[1]
				local operator = traitCondition[2]
				local value = traitCondition[3]

				if not validTraits[traitName] then
					Report(string.format("%s rule %d references unsupported ingredient trait '%s'.",
						poolName, ruleIndex, tostring(traitName)))
				end
				if not validOperators[operator] then
					Report(string.format("%s rule %d uses unsupported trait-count operator '%s'.",
						poolName, ruleIndex, tostring(operator)))
				end
				if type(value) ~= "number" then
					Report(string.format("%s rule %d has a non-numeric trait count value.", poolName, ruleIndex))
				end
			end

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
