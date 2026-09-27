--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Custom Recipe Engine)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Reforged modifications (c) 2026 Michael Lane.
--]]---------------------------------------------------------------------------

require("sim/recipe_feedback.lua")

------------------------------------------------------------------------------
-- Feedback Text Processing
------------------------------------------------------------------------------

-- Dynamically fetches and processes a localized string for Teddy's feedback.
-- Supports both standard randomization (picking from _1, _2, _3) and weighted
-- randomization if the feedbackData is provided as a table with weight values.
local function GetRandomFeedbackString(feedbackData, ...)
	local baseKey
	local weights

	-- Determine if we are using a weighted table or a simple string key
	if type(feedbackData) == "table" then
		baseKey = feedbackData.key
		weights = feedbackData.weights
	else
		baseKey = feedbackData
	end

	-- Count how many numbered variations exist in the localization files (e.g., key_1, key_2)
	local count = 1
	while HasString(baseKey .. "_" .. (count + 1)) do
		count = count + 1
	end

	-- Fallback: If no _1 variation exists, assume it's a standalone key
	if count == 1 and not HasString(baseKey .. "_1") then
		return GetReplacedString(baseKey, unpack(arg or {}))
	end

	local randomIndex = 1

	if weights and table.getn(weights) == count then
		-- Execute weighted random selection
		local totalWeight = 0
		for _, w in ipairs(weights) do totalWeight = totalWeight + w end

		local roll = RandRange(1, totalWeight)
		local cumulativeWeight = 0

		for i, w in ipairs(weights) do
			cumulativeWeight = cumulativeWeight + w
			if roll <= cumulativeWeight then
				randomIndex = i
				break
			end
		end
	else
		-- Execute standard uniform random selection
		randomIndex = RandRange(1, count)
	end

	-- Inject any optional formatting arguments (like the product name) into the chosen string
	return GetReplacedString(baseKey .. "_" .. randomIndex, unpack(arg or {}))
end

------------------------------------------------------------------------------
-- Recipe Registration & Memory Handling
------------------------------------------------------------------------------

-- Utility: Converts a raw array of ingredient objects into a sorted array of
-- ingredient ID codes, prepended with the product category.
function BuildCodeTable(ingredients, categoryName)
	local codeTable = {}
	for _, ing in ipairs(ingredients) do
		table.insert(codeTable, ing.code)
	end

	-- Sorting alphabetically guarantees that identical ingredient combinations
	-- always generate the exact same recipe signature.
	table.sort(codeTable)

	categoryName = categoryName or "error"
	table.insert(codeTable, 1, categoryName)

	return codeTable
end

-- Constructs the actual systemic Product object for a custom recipe, allowing
-- it to be manufactured in factories and sold in shops.
function BuildCustomProduct(codeTable, appearance, creationLibrary)
	-- The product code acts as its unique ID signature (e.g., "bar_c_m_v")
	local code = table.concat(codeTable, "_")
	code = string.lower(code)
	appearance = appearance or Player.itemAppearance[code]

	-- Tally the ingredients into a {name = count} pairs table.
	-- Skip index 1, as it contains the category string.
	local recipe = {}
	for i = 2, table.getn(codeTable) do
		local ing = _IngredientCodes[codeTable[i]]
		recipe[ing.name] = 1 + (recipe[ing.name] or 0)
	end

	-- CRITICAL FIX: Prevent memory collisions.
	-- If CreateProduct finds a duplicate, it returns a dummy table without a metatable,
	-- causing a crash later. We explicitly nuke the old version here.
	if _AllProducts[code] then
		_AllProducts[code] = nil
	end

	-- Register the custom product within the global game architecture
	local prod = CreateProduct {
		code = code,
		category = "user",
		appearance = appearance,
		recipe = recipe
	}

	-- Inject it into the "user" category container
	local category = _AllCategories["user"]
	category:AddProduct(prod)
	prod.category = category
	prod.creationLibrary = creationLibrary or ((Player.IsFreePlay and Player:IsFreePlay()) and "free" or "story")

	-- Unlock the recipe and increment the player's active custom recipe count.
	-- (Overriding the count manually here ensures that restoring a saved game
	-- doesn't infinitely compound the slot usage tally.)
	local n = (Player.categoryCount["user"] or 0) + 1
	prod:Unlock()
	Player.categoryCount["user"] = n
	if Player.IsFreePlay and Player:IsFreePlay() then
		Player.questVariables.ugr_slots = 999999
	else
		Player.questVariables.ugr_slots = Player.customSlots - n
	end

	DebugOut("RECIPE", string.format("Registered custom product: %s (Signature: %s)", prod:GetName(), code))
	return prod
end

-- Master function to finalize, score, price, and permanently save a new UGR to the player's profile.
function CreateCustomRecipe(name, description, ingredients, appearance, category)
	DebugOut("RECIPE", string.format("Finalizing custom recipe creation: '%s' (Category: %s)", name, category))

	local codeTable = BuildCodeTable(ingredients, category)
	local library = (Player.IsFreePlay and Player:IsFreePlay()) and "free" or "story"
	local prod = BuildCustomProduct(codeTable, appearance, library)

	-- Re-evaluate the recipe silently to lock in its permanent Low and High market prices
	local productCategory = _AllCategories[category]
	local f, r, lowPrice, highPrice = EvaluatePlayerRecipe(productCategory, ingredients, table.getn(ingredients))

	prod.price_low = lowPrice
	prod.price_high = highPrice

	-- Bind the recipe metadata to the Player's save profile
	table.insert(Player.itemRecipes, codeTable)
	Player.itemAppearance[prod.code] = appearance
	Player.itemNames[prod.code] = name
	Player.itemDescriptions[prod.code] = description
	Player.itemPrices[prod.code] = prod.price_low
	Player.itemMachinery[prod.code] = category

	-- Map the dynamically generated string reference for UI rendering
	local i = table.getn(Player.itemRecipes)
	Player.stringTable["user" .. tostring(i)] = name
	if Player.IsFreePlay and Player:IsFreePlay() then
		Player.questVariables.ugr_slots = 999999
	else
		Player.questVariables.ugr_slots = Player.customSlots - (Player.categoryCount.user or 0)
	end

	return prod
end

------------------------------------------------------------------------------
-- Recipe Evaluation & Scoring Algorithm
------------------------------------------------------------------------------

-- Scans the global product registry to see if the player accidentally
-- created a recipe that already exists in the standard game.
local function FindSystemRecipe(productCategory, ingredientCounts)
	for _, prod in ipairs(productCategory.products or {}) do
		if prod.MatchesIngredientCounts and prod:MatchesIngredientCounts(ingredientCounts) then
			return prod
		end
	end
	return nil
end

-- The master evaluation loop for Teddy's taste-testing.
-- Analyzes ingredients, flags system duplicates, tallies points based on culinary logic,
-- selects dynamic dialogue, and computes the final market value of the product.
-- Returns: feedbackText, _, lowPrice, highPrice, allowCreationBool
function EvaluatePlayerRecipe(productCategory, ingredients, slotCount)
	local ingredientNames = {}
	for _, ing in ipairs(ingredients) do table.insert(ingredientNames, ing.name) end
	DebugOut("RECIPE", string.format("Evaluating recipe in category '%s' with ingredients: %s", productCategory.name, table.concat(ingredientNames, ", ")))

	-- Treat the actual submitted array as authoritative.  The UI normally passes
	-- the same slot count, but imported/community recipes should not be able to
	-- distort category ratios by supplying stale metadata.
	local actualSlotCount = table.getn(ingredients)
	if slotCount ~= actualSlotCount then
		DebugOut("WARNING", string.format("Recipe slot-count mismatch: caller supplied %s, actual recipe contains %d. Using actual count.", tostring(slotCount), actualSlotCount))
		slotCount = actualSlotCount
	end

	local allow = true
	local hints = {}
	local first_use_hint = nil
	local first_use_ingredient = nil

	-- 1. "First Time Use" Triggers
	-- If Teddy has never tasted this ingredient before, stage his specialized dialogue.
	-- Actual recipe faults still take priority and leave the first-use line available for later.
	for _, ing in ipairs(ingredients) do
		if not Player.labFirstUse[ing.name] then
			local first_use_key = "taster_feedback_firstuse_" .. ing.name

			if HasString(first_use_key .. "_1") or HasString(first_use_key) then
				first_use_hint = first_use_key
				first_use_ingredient = ing.name
				DebugOut("RECIPE", string.format("First-time use of '%s' detected. Holding special lore feedback until recipe faults are checked.", ing.name))
				break
			else
				Player.labFirstUse[ing.name] = true
			end
		end
	end

	-- 2. Statistical Analysis
	-- We track raw costs and diversity to feed into the scoring matrix.
	local lowPrice = 0
	local highPrice = 0
	local ingredientCount = {}
	local ratioCategoryCount = {}
	local traitCount = {}
	local differentCount = 0

	for _, ing in ipairs(ingredients) do
		if not ingredientCount[ing.name] then
			-- First instance of this specific ingredient
			ingredientCount[ing.name] = 1
			differentCount = differentCount + 1
		else
			-- Duplicate instance of this specific ingredient
			ingredientCount[ing.name] = ingredientCount[ing.name] + 1
		end

		local ratioCategory = ing.GetRecipeFamily and ing:GetRecipeFamily() or ing.category
		ratioCategoryCount[ratioCategory] = (ratioCategoryCount[ratioCategory] or 0) + 1

		if ing.alcohol then
			traitCount["alcohol"] = (traitCount["alcohol"] or 0) + 1
		end

		lowPrice = lowPrice + ing.price_low
		highPrice = highPrice + ing.price_high
	end

	local codeTable = BuildCodeTable(ingredients, productCategory.name)
	local code = string.lower(table.concat(codeTable, "_"))

	-- 3. Collision Checks
	-- Did they accidentally rebuild an existing game recipe?
	local existingProduct = FindSystemRecipe(productCategory, ingredientCount)

	-- Did they accidentally rebuild one of their OWN previously created recipes?
	if not existingProduct then
		existingProduct = _AllProducts[code]
		if existingProduct then
			if (not Player.itemNames[code]) or (not existingProduct:IsKnown()) then
				existingProduct = nil
			else
				allow = false
			end
		end
	end

	-- 4. Ratio Calculations
	-- Determine what percentage of the recipe is made up of specific ingredient families.
	local ratios = {}
	ratios["cacao"]  = (ratioCategoryCount["cacao"] or 0) / slotCount
	ratios["coffee"] = (ratioCategoryCount["coffee"] or 0) / slotCount
	ratios["dairy"]  = (ratioCategoryCount["dairy"] or 0) / slotCount
	ratios["flavor"] = (ratioCategoryCount["flavor"] or 0) / slotCount
	ratios["fruit"]  = (ratioCategoryCount["fruit"] or 0) / slotCount
	ratios["nut"]    = (ratioCategoryCount["nut"] or 0) / slotCount
	ratios["sugar"]  = (ratioCategoryCount["sugar"] or 0) / slotCount

	-- 5. SCORING MATRIX
	-- Base score starts at 140 (Standard quality). Penalties and bonuses adjust this multiplier.
	local points = 140
	local used_feedback_keys = {}
	local variety_hint = nil

	-- Penalty: Lack of Diversity
	local variety = differentCount / slotCount
	if differentCount == 1 then
		variety_hint = "taster_variety"
		points = 30 -- Brutal penalty for a single-ingredient block
		used_feedback_keys["taster_variety"] = true
	elseif variety < 0.5 then
		variety_hint = "taster_variety"
		points = points - 60
		used_feedback_keys["taster_variety"] = true
	elseif variety < 0.6 then
		variety_hint = "taster_variety"
		points = points - 30
		used_feedback_keys["taster_variety"] = true
	end

	-- Fetch external logic rules through the product-category definition.
	-- Older/modded categories still fall back to their factory family.
	local evaluators = {}
	if productCategory.GetFeedbackEvaluators then
		evaluators = productCategory:GetFeedbackEvaluators()
	elseif productCategory.factory == "coffee" then
		evaluators = CoffeeEvaluators
	elseif productCategory.factory == "chocolate" then
		evaluators = ChocolateEvaluators
	end

	local unique_hints = {}
	local non_unique_hints = {}
	local negative_unique_hints = {}
	local negative_non_unique_hints = {}
	local voided_keys = {}

	-- Apply External Culinary Rules
	for _, rule in ipairs(evaluators) do
		local conditions_met = true

		if rule.categories then
			local category_match = false
			for _, cat_name in ipairs(rule.categories) do
				if cat_name == productCategory.name then
					category_match = true
					break
				end
			end
			if not category_match then conditions_met = false end
		end

		if conditions_met and rule.requires then
			for _, req_ing in ipairs(rule.requires) do
				if not ingredientCount[req_ing] then
					conditions_met = false
					break
				end
			end
		end

		if conditions_met and rule.forbids then
			for _, fob_ing in ipairs(rule.forbids) do
				if ingredientCount[fob_ing] then
					conditions_met = false
					break
				end
			end
		end

		if conditions_met and rule.counts then
			for _, count_cond in ipairs(rule.counts) do
				local ing_name, op, val = count_cond[1], count_cond[2], count_cond[3]
				local count_val = ingredientCount[ing_name] or 0
				local passed = false

				if op == ">" then passed = count_val > val
				elseif op == "<" then passed = count_val < val
				elseif op == "==" then passed = count_val == val
				elseif op == ">=" then passed = count_val >= val
				elseif op == "<=" then passed = count_val <= val
				end

				if not passed then
					conditions_met = false
					break
				end
			end
		end

		if conditions_met and rule.trait_counts then
			for _, trait_cond in ipairs(rule.trait_counts) do
				local trait_name, op, val = trait_cond[1], trait_cond[2], trait_cond[3]
				local count_val = traitCount[trait_name] or 0
				local passed = false

				if op == ">" then passed = count_val > val
				elseif op == "<" then passed = count_val < val
				elseif op == "==" then passed = count_val == val
				elseif op == ">=" then passed = count_val >= val
				elseif op == "<=" then passed = count_val <= val
				end

				if not passed then
					conditions_met = false
					break
				end
			end
		end

		if conditions_met and rule.ratios then
			for _, ratio_cond in ipairs(rule.ratios) do
				local cat, op, val = ratio_cond[1], ratio_cond[2], ratio_cond[3]
				local ratio_val = ratios[cat] or 0
				local passed = false

				if op == ">" then passed = ratio_val > val
				elseif op == "<" then passed = ratio_val < val
				elseif op == "==" then passed = ratio_val == val
				elseif op == ">=" then passed = ratio_val >= val
				elseif op == "<=" then passed = ratio_val <= val
				end

				if not passed then
					conditions_met = false
					break
				end
			end
		end

		if conditions_met then
			points = points + rule.score

			-- Every matching rule contributes its suppression list, even when another
			-- rule already supplied the same feedback key. Otherwise shared feedback
			-- families can leave behind contradictory solo observations.
			if rule.voids then
				for _, void_key in ipairs(rule.voids) do
					voided_keys[void_key] = true
				end
			end

			if not used_feedback_keys[rule.feedback] then
				-- Negative feedback owns the tasting response. A rule can opt into
				-- negative treatment explicitly when it is a zero-score wording
				-- override for a separate structural penalty.
				local is_negative_feedback = (rule.score < 0) or rule.negative
				if is_negative_feedback then
					if rule.unique then
						table.insert(negative_unique_hints, rule.feedback)
					else
						table.insert(negative_non_unique_hints, rule.feedback)
					end
				else
					if rule.unique then
						table.insert(unique_hints, rule.feedback)
					else
						table.insert(non_unique_hints, rule.feedback)
					end
				end
				used_feedback_keys[rule.feedback] = true
			end
		end
	end

	-- Consolidate Valid Hints. If any surviving negative feedback exists,
	-- Teddy stays focused on the problem instead of immediately following it
	-- with praise, ingredient trivia, or a pleasant pairing observation.
	local final_non_unique = {}
	for _, hint in ipairs(non_unique_hints) do
		if not voided_keys[hint] then table.insert(final_non_unique, hint) end
	end

	local valid_unique_hints = {}
	for _, hint in ipairs(unique_hints) do
		if not voided_keys[hint] then table.insert(valid_unique_hints, hint) end
	end

	local final_negative_non_unique = {}
	for _, hint in ipairs(negative_non_unique_hints) do
		if not voided_keys[hint] then table.insert(final_negative_non_unique, hint) end
	end

	local valid_negative_unique_hints = {}
	for _, hint in ipairs(negative_unique_hints) do
		if not voided_keys[hint] then table.insert(valid_negative_unique_hints, hint) end
	end

	-- A specific ingredient-overuse diagnosis is more useful than the generic
	-- low-variety line that duplicate slots naturally trigger. Keep the variety
	-- score penalty, but let Teddy explain the actual culinary problem instead.
	local has_specific_overuse = false
	for _, hint in ipairs(final_negative_non_unique) do
		if string.find(hint, "_overuse", 1, true) then
			has_specific_overuse = true
			break
		end
	end
	if not has_specific_overuse then
		for _, hint in ipairs(valid_negative_unique_hints) do
			if string.find(hint, "_overuse", 1, true) then
				has_specific_overuse = true
				break
			end
		end
	end
	if has_specific_overuse then
		variety_hint = nil

		-- Repeating one concentrated ingredient can also trip broad ratio-based
		-- complaints such as "all sugar" or "all flavors". Those generic balance
		-- lines are less useful than the ingredient-specific dosage diagnosis, so
		-- suppress only the broad chocolate/coffee structural families here.
		-- Specific clashes and other taster_feedback_* faults remain eligible.
		local overuse_priority_hints = {}
		for _, hint in ipairs(final_negative_non_unique) do
			local is_generic_balance = string.find(hint, "taster_choco_", 1, true) == 1
				or string.find(hint, "taster_coffee_", 1, true) == 1
			if not is_generic_balance then
				table.insert(overuse_priority_hints, hint)
			end
		end
		final_negative_non_unique = overuse_priority_hints
	end

	local has_negative_feedback = (variety_hint ~= nil)
		or table.getn(final_negative_non_unique) > 0
		or table.getn(valid_negative_unique_hints) > 0

	if has_negative_feedback then
		if variety_hint then table.insert(hints, variety_hint) end

		for _, hint in ipairs(final_negative_non_unique) do
			table.insert(hints, hint)
		end

		if table.getn(valid_negative_unique_hints) > 0 then
			local randomIndex = RandRange(1, table.getn(valid_negative_unique_hints))
			table.insert(hints, valid_negative_unique_hints[randomIndex])
		end
	else
		-- First-use lore and positive/neutral observations are only useful when
		-- Teddy has no actual fault to call out in the recipe.
		if first_use_hint then table.insert(hints, first_use_hint) end

		for _, hint in ipairs(final_non_unique) do
			table.insert(hints, hint)
		end

		if table.getn(valid_unique_hints) > 0 then
			local randomIndex = RandRange(1, table.getn(valid_unique_hints))
			table.insert(hints, valid_unique_hints[randomIndex])
		end
	end

	-- 6. Category-Defining Structural Requirements
	-- Category data owns these rules so stock products and Test Kitchen recipes
	-- are judged by one source of truth.  In particular, I12/T12 establish that
	-- deliberately pure-cacao infusion/truffle recipes are legal without sugar.

	-- A surviving ingredient-specific overuse diagnosis is deliberately more
	-- useful as the immediate Teddy response than a broad category requirement.
	-- Keep the structural failure score so the recipe is still judged invalid/poor,
	-- but do not erase the overuse feedback that already matched. Once the player
	-- corrects the dosage, the cacao/sweetener/coating requirement can surface on
	-- the next tasting. Other structural failures retain their whole-response
	-- override behavior exactly as before.
	if productCategory.GetRecipeStructuralFailure then
		local structuralFeedback, structuralScore = productCategory:GetRecipeStructuralFailure(ingredientCount)
		if structuralFeedback then
			points = structuralScore or 30
			if not has_specific_overuse then
				hints = { structuralFeedback }
			else
				DebugOut("RECIPE", string.format(
					"Structural fault '%s' detected, but preserving the more specific ingredient-overuse feedback for this tasting.",
					tostring(structuralFeedback)
				))
			end
		end
	end

	-- 7. Repetition Spam Defense
	-- If the player submits the same bad recipe twice in a row, Teddy gets annoyed.
	if code == Player.lastTastedRecipeCode and points < 50 then
		hints = { "taster_feedback_repetition" }
		DebugOut("RECIPE", "Repeated bad recipe detected. Teddy overrides standard feedback.")
	end

	if points < 50 then
		Player.lastTastedRecipeCode = code
	else
		Player.lastTastedRecipeCode = nil
	end

	-- 8. Dialogue Generation
	local feedback
	if existingProduct then
		-- Recipe is identical to an existing product
		if existingProduct:IsKnown() then
			feedback = GetRandomFeedbackString("taster_feedback_tasteslike_known", existingProduct:GetName())
		else
			feedback = GetRandomFeedbackString("taster_feedback_tasteslike_unknown", existingProduct:GetName())
		end
		points = 50 -- Heavy penalty for plagiarism
	else
		-- Only consume first-use lore when it actually survives all negative/
		-- structural overrides and is about to be shown to the player.
		if first_use_hint and first_use_ingredient then
			for _, hint_key in ipairs(hints) do
				if hint_key == first_use_hint then
					Player.labFirstUse[first_use_ingredient] = true
					break
				end
			end
		end

		-- Assemble the dynamic feedback string
		local feedback_lines = {}
		if table.getn(hints) > 0 then
			for _, hint_key in ipairs(hints) do
				table.insert(feedback_lines, "" .. GetRandomFeedbackString(hint_key))
			end
		else
			-- No hints generated. Supply generic response based on slot availability.
			local category = _AllCategories.user
			if (Player.IsFreePlay and Player:IsFreePlay()) or (category and table.getn(category.products) < Player.customSlots) then
				table.insert(feedback_lines, GetRandomString("taster_feedback_default"))
			else
				table.insert(feedback_lines, GetRandomString("taster_feedback_default_noslots"))
			end
		end
		feedback = table.concat(feedback_lines, "<br>")
	end

	-- 9. Economic Computations
	-- Determine the markup multiplier based on point score. Capped between 10% and 300%
	if points < 10 then
		points = 10
	elseif points > 300 then
		points = 300
	end

	local markup = productCategory.markup or 1
	DebugOut("RECIPE", string.format("Calculating economy for category: %s (Base Category Markup: %.2f)", productCategory.name, markup))

	-- Final markup applies the recipe's point score as a percentage multiplier
	markup = markup * (points / 100)
	DebugOut("RECIPE", string.format("Final Recipe Point Score: %d | Computed Recipe Markup Multiplier: %.2f", points, markup))

	-- Price Calculation: Take the raw cost of the combined ingredients and multiply by the markup
	DebugOut("RECIPE", string.format("Raw Ingredient Cost Bracket: %s - %s", Dollars(lowPrice), Dollars(highPrice)))

	lowPrice = Floor(lowPrice * markup + 0.5)
	if lowPrice < 1 then lowPrice = 1 end

	highPrice = Floor(highPrice * markup + 0.5)
	if highPrice < 1 then highPrice = 1 end

	DebugOut("RECIPE", string.format("Final Retail Value Bracket: %s - %s", Dollars(lowPrice), Dollars(highPrice)))
	DebugOut("RECIPE", string.format("Evaluation complete. Active Feedback Keys: %s", table.concat(hints, ", ")))

	-- Resolve any dynamic <player> name tags
	if feedback and string.find(feedback, "<player>") then
		feedback = string.gsub(feedback, "<player>", Player.name or "")
	end

	-- Note: 'response' is a legacy unused variable (originally representing markup ratio)
	-- It is maintained here strictly to satisfy the return signature expected by the UI.
	local response = markup / (productCategory.markup or 1)

	return feedback, response, lowPrice, highPrice, allow
end
