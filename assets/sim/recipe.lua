--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Custom Recipe Engine)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
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
function BuildCustomProduct(codeTable, appearance)
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
	
	-- Unlock the recipe and increment the player's active custom recipe count.
	-- (Overriding the count manually here ensures that restoring a saved game 
	-- doesn't infinitely compound the slot usage tally.)
	local n = (Player.categoryCount["user"] or 0) + 1
	prod:Unlock()
	Player.categoryCount["user"] = n
	Player.questVariables.ugr_slots = Player.customSlots - n
	
	DebugOut("RECIPE", string.format("Registered custom product: %s (Signature: %s)", prod:GetName(), code))
	return prod
end

-- Master function to finalize, score, price, and permanently save a new UGR to the player's profile.
function CreateCustomRecipe(name, description, ingredients, appearance, category)
	DebugOut("RECIPE", string.format("Finalizing custom recipe creation: '%s' (Category: %s)", name, category))

	local codeTable = BuildCodeTable(ingredients, category)
	local prod = BuildCustomProduct(codeTable, appearance)
	
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
	Player.questVariables.ugr_slots = Player.customSlots - (Player.categoryCount.user or 0)

	return prod
end

------------------------------------------------------------------------------
-- Recipe Evaluation & Scoring Algorithm
------------------------------------------------------------------------------

-- Scans the global product registry to see if the player accidentally 
-- created a recipe that already exists in the standard game.
local function FindSystemRecipe(productCategory, ingredientCounts, slotCount)
	local found = nil
	
	for _, prod in ipairs(productCategory.products) do
		local ok = true
		
		-- Check A: Do all ingredients in the system recipe exist in the player's recipe?
		for name, count in pairs(prod.counts) do
			if count ~= ingredientCounts[name] then ok = false; break; end
		end
		
		-- Check B: Do all ingredients in the player's recipe exist in the system recipe?
		if ok then
			for name, count in pairs(ingredientCounts) do
				if count ~= prod.counts[name] then ok = false; break; end
			end
		end
		
		if ok then 
			found = prod 
			break 
		end
	end
	
	return found
end

-- The master evaluation loop for Teddy's taste-testing. 
-- Analyzes ingredients, flags system duplicates, tallies points based on culinary logic,
-- selects dynamic dialogue, and computes the final market value of the product.
-- Returns: feedbackText, _, lowPrice, highPrice, allowCreationBool
function EvaluatePlayerRecipe(productCategory, ingredients, slotCount)
	local ingredientNames = {}
	for _, ing in ipairs(ingredients) do table.insert(ingredientNames, ing.name) end
	DebugOut("RECIPE", string.format("Evaluating recipe in category '%s' with ingredients: %s", productCategory.name, table.concat(ingredientNames, ", ")))

	local allow = true
	local hints = {}

	-- 1. "First Time Use" Triggers
	-- If Teddy has never tasted this ingredient before, prioritize his specialized dialogue.
	for _, ing in ipairs(ingredients) do
		if not Player.labFirstUse[ing.name] then
			local first_use_key = "taster_feedback_firstuse_" .. ing.name
			
			if HasString(first_use_key .. "_1") or HasString(first_use_key) then
				table.insert(hints, first_use_key)
				Player.labFirstUse[ing.name] = true
				DebugOut("RECIPE", string.format("First-time use of '%s' detected. Injecting special lore feedback.", ing.name))
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
	local categoryCount = {}
	local categoryDiversity = {}
	local differentCount = 0
	
	for _, ing in ipairs(ingredients) do
		if not ingredientCount[ing.name] then
			-- First instance of this specific ingredient
			ingredientCount[ing.name] = 1
			categoryCount[ing.category] = (categoryCount[ing.category] or 0) + 1
			categoryDiversity[ing.category] = (categoryDiversity[ing.category] or 0) + 1
			differentCount = differentCount + 1
		else
			-- Duplicate instance of this specific ingredient
			ingredientCount[ing.name] = ingredientCount[ing.name] + 1
			categoryCount[ing.category] = (categoryCount[ing.category] or 0) + 1
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
	ratios["cacao"]  = (categoryCount["cacao"] or 0) / slotCount
	ratios["coffee"] = (categoryCount["coffee"] or 0) / slotCount
	ratios["dairy"]  = (categoryCount["dairy"] or 0) / slotCount
	ratios["flavor"] = (categoryCount["flavor"] or 0) / slotCount
	ratios["fruit"]  = (categoryCount["fruit"] or 0) / slotCount
	ratios["nut"]    = (categoryCount["nut"] or 0) / slotCount
	ratios["sugar"]  = (categoryCount["sugar"] or 0) / slotCount

	-- 5. SCORING MATRIX
	-- Base score starts at 140 (Standard quality). Penalties and bonuses adjust this multiplier.
	local points = 140
	local used_feedback_keys = {}
	
	-- Penalty: Lack of Diversity
	local variety = differentCount / slotCount
	if differentCount == 1 then
		table.insert(hints, "taster_variety")
		points = 30 -- Brutal penalty for a single-ingredient block
		used_feedback_keys["taster_variety"] = true
	elseif variety < 0.5 then
		table.insert(hints, "taster_variety")
		points = points - 60
		used_feedback_keys["taster_variety"] = true
	elseif variety < 0.6 then
		table.insert(hints, "taster_variety")
		points = points - 30
		used_feedback_keys["taster_variety"] = true
	end
	
	-- Fetch external logic rules from recipe_feedback.lua
	local evaluators = {}
	if productCategory.factory == "coffee" then
		evaluators = CoffeeEvaluators
	elseif productCategory.factory == "chocolate" then
		evaluators = ChocolateEvaluators
	end

	local unique_hints = {}
	local non_unique_hints = {}
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
			if not used_feedback_keys[rule.feedback] then
				if rule.unique then 
					table.insert(unique_hints, rule.feedback)
				else 
					table.insert(non_unique_hints, rule.feedback) 
				end
				
				if rule.voids then
					for _, void_key in ipairs(rule.voids) do 
						voided_keys[void_key] = true 
					end
				end
				used_feedback_keys[rule.feedback] = true
			end
		end
	end

	-- Consolidate Valid Hints
	local final_non_unique = {}
	for _, hint in ipairs(non_unique_hints) do
		if not voided_keys[hint] then table.insert(final_non_unique, hint) end
	end

	hints = final_non_unique
	
	-- Select one random unique hint (if any exist) that wasn't voided by a stronger rule
	local valid_unique_hints = {}
	for _, hint in ipairs(unique_hints) do
		if not voided_keys[hint] then
			table.insert(valid_unique_hints, hint)
		end
	end

	if table.getn(valid_unique_hints) > 0 then
		local randomIndex = RandRange(1, table.getn(valid_unique_hints))
		table.insert(hints, valid_unique_hints[randomIndex])
	end

	-- 6. Hard Coded Chocolate Fatal Flaws
	if productCategory.factory == "chocolate" then
		if ratios["cacao"] == 0 then 
			table.insert(hints, "taster_cacao")
			points = 30 -- Massive penalty for chocolate with no cacao
		elseif (ratios["sugar"] == 0 and ratios["fruit"] == 0) then 
			table.insert(hints, "taster_sugar")
			points = 30 -- Massive penalty for entirely unsweetened chocolate
		elseif productCategory.name == "truffle" and (not ingredientCount["powder"]) then 
			table.insert(hints, "taster_powder")
			points = 30 -- Truffles require powder
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
		-- Assemble the dynamic feedback string
		local feedback_lines = {}
		if table.getn(hints) > 0 then
			for _, hint_key in ipairs(hints) do
				table.insert(feedback_lines, "" .. GetRandomFeedbackString(hint_key))
			end
		else
			-- No hints generated. Supply generic response based on slot availability.
			local category = _AllCategories.user
			if category and table.getn(category.products) < Player.customSlots then
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