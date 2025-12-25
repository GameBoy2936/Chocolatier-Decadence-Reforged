--[[--------------------------------------------------------------------------
	Chocolatier Three: Player-Created recipe helpers
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

require("sim/recipe_feedback.lua")

local function GetRandomFeedbackString(feedbackData, ...)
    local baseKey
    local weights

    if type(feedbackData) == "table" then
        baseKey = feedbackData.key
        weights = feedbackData.weights
    else
        -- Fallback for simple string keys
        baseKey = feedbackData
    end

    -- Count how many numbered variations exist
    local count = 1
    while GetReplacedString(baseKey .. "_" .. (count + 1)) ~= "#####" do
        count = count + 1
    end
    -- If only the base key exists (no _1), usage of GetReplacedString handles it,
    -- but we check _1 to be safe for our loop logic.
    if count == 1 and GetReplacedString(baseKey .. "_1") == "#####" then 
        return GetReplacedString(baseKey, unpack(arg or {})) 
    end
    
    local randomIndex = 1
    if weights and table.getn(weights) == count then
        -- Weighted random selection
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
        -- Standard random selection
        randomIndex = RandRange(1, count)
    end
    
    -- Pass the optional arguments (like product name) to GetReplacedString
    return GetReplacedString(baseKey .. "_" .. randomIndex, unpack(arg or {}))
end

function BuildCustomProduct(codeTable, appearance)
	-- Product code is a concatenated list of ingredient codes
	local code = table.concat(codeTable, "_")
	code = string.lower(code)
	appearance = appearance or Player.itemAppearance[code]

	-- Gather ingredients into <name>=<count> pairs as the recipe
	-- first item in the recipe is the selected category
	local recipe = {}
	for i=2,table.getn(codeTable) do
		local ing = _IngredientCodes[codeTable[i]]
		recipe[ing.name] = 1 + (recipe[ing.name] or 0)
	end
	
	-- Create (or replace) the product itself within the normal system
	local prod = CreateProduct { code=code, category="user", appearance=appearance, recipe=recipe }

	-- include it in the "user" category
	local category = _AllCategories["user"]
	category:AddProduct(prod)
	prod.category = category
	
	-- And in the player's string table
	local n = table.getn(Player.itemNames)
	Player.stringTable["user"..tostring(n)] = prod:GetName()
	
	-- Unlock it... making sure the category count is correct.
	-- Normally, Unlock() will increment the category count, but not when restoring a saved game,
	-- so I'm just overriding the count here to make sure it happens and happens correctly.
	local n = (Player.categoryCount["user"] or 0) + 1
	prod:Unlock()
	Player.categoryCount["user"] = n
	Player.questVariables.ugr_slots = Player.customSlots - n
	
	return prod
end

function BuildCodeTable(ingredients, categoryName)
	-- Create a text-only list of ingredient codes, sorted alphabetically
	local codeTable = {}
	for _,ing in ipairs(ingredients) do table.insert(codeTable, ing.code) end
	table.sort(codeTable)
	
	-- First entry in the code table is the name of the product category
	categoryName = categoryName or "error"
	table.insert(codeTable, 1, categoryName)

	return codeTable
end

function CreateCustomRecipe(name, description, ingredients, appearance, category)
    DebugOut("RECIPE", "Creating custom recipe '" .. name .. "' in category '" .. category .. "'.")

	-- Turn the ingredient list into a code table
	local codeTable = BuildCodeTable(ingredients, category)

	-- Create the product within the system
	local prod = BuildCustomProduct(codeTable, appearance)
-- TODO: NEED TO CALCULATE AND SAVE LOW/HIGH PRICES IN SAVE GAMES...
	local productCategory = _AllCategories[category]
	local f,r,lowPrice,highPrice = EvaluatePlayerRecipe(productCategory, ingredients, table.getn(ingredients))
	prod.price_low = lowPrice
	prod.price_high = highPrice
	
	-- Add the recipe to the Player profile
	table.insert(Player.itemRecipes, codeTable)
	Player.itemAppearance[prod.code] = appearance
	Player.itemNames[prod.code] = name
	Player.itemDescriptions[prod.code] = description
	Player.itemPrices[prod.code] = prod.price_low
	Player.itemMachinery[prod.code] = category
	
	local i = table.getn(Player.itemRecipes)
	Player.stringTable["user"..tostring(i)] = name

	Player.questVariables.ugr_slots = Player.customSlots - (Player.categoryCount.user or 0)

--	Player:QueueMessage("recipe_invent", prod:GetName())
	return prod
end

------------------------------------------------------------------------------

local function FindSystemRecipe(productCategory, ingredientCounts, slotCount)
	local found = nil
	for _,prod in ipairs(productCategory.products) do
		-- Make sure the recipes match: all ingredients in
		--   A are the same as B, and all in B are the same as A
		local ok = true
		for name,count in pairs(prod.counts) do
			local c2 = ingredientCounts[name]
			if count ~= ingredientCounts[name] then ok = false; break; end
		end
		if ok then
			for name,count in pairs(ingredientCounts) do
				if count ~= prod.counts[name] then ok = false; break; end
			end
		end
		if ok then found=prod; break; end
	end
	return found
end

------------------------------------------------------------------------------

-- returns: feedback, response, lowPrice, highPrice, allow
function EvaluatePlayerRecipe(productCategory, ingredients, slotCount)
    local ingredientNames = {}
    for _, ing in ipairs(ingredients) do table.insert(ingredientNames, ing.name) end
    DebugOut("RECIPE", "Evaluating recipe in category '" .. productCategory.name .. "' with ingredients: " .. table.concat(ingredientNames, ", "))

	local allow = true
	local hints = {}

    -- "First Time" Comment Logic
    for _, ing in ipairs(ingredients) do
        if not Player.labFirstUse[ing.name] then
            local first_use_key = "taster_feedback_firstuse_" .. ing.name
            if GetReplacedString(first_use_key .. "_1") ~= "#####" or GetReplacedString(first_use_key) ~= "#####" then
                table.insert(hints, first_use_key)
                Player.labFirstUse[ing.name] = true
                DebugOut("RECIPE", "First time use of " .. ing.name .. " detected. Adding special feedback.")
                break 
            else
                Player.labFirstUse[ing.name] = true
            end
        end
    end
	
	-- Analyze the recipe:
	--  Track the total low/high prices of the ingredients in the recipe
	--  Count the number of each ingredient in the recipe
	--  Count the number of ingredients in each category
	--  Count the number of different ingredients represented in each category
	--  Count the number of different ingredients used
	local lowPrice = 0
	local highPrice = 0
	local ingredientCount = {}
	local categoryCount = {}
	local categoryDiversity = {}
	local differentCount = 0
	for _,ing in ipairs(ingredients) do
		if not ingredientCount[ing.name] then
			-- This is the first of this kind of ingredient -- give a diversity point within its category
			ingredientCount[ing.name] = 1
			categoryCount[ing.category] = (categoryCount[ing.category] or 0) + 1
			categoryDiversity[ing.category] = (categoryDiversity[ing.category] or 0) + 1
			differentCount = differentCount + 1
		else
			ingredientCount[ing.name] = ingredientCount[ing.name] + 1
			categoryCount[ing.category] = (categoryCount[ing.category] or 0) + 1
		end
		
		lowPrice = lowPrice + ing.price_low
		highPrice = highPrice + ing.price_high
	end
	
	-- Build the unique recipe code now for use in multiple checks
	local codeTable = BuildCodeTable(ingredients, productCategory.name)
	local code = table.concat(codeTable, "_")
	code = string.lower(code)

	-- Determine whether this recipe matches any other game-defined recipes
	local existingProduct = FindSystemRecipe(productCategory, ingredientCount)
	
	-- Determine whether this recipe matches any user-created recipes
	if not existingProduct then
		existingProduct = _AllProducts[code]
		if existingProduct then
			if (not Player.itemNames[code]) or (not existingProduct:IsKnown()) then existingProduct = nil
			else allow = false
			end
		end
	end
	
	-- Calculate some useful ratios:
	local ratios = {}
	ratios["cacao"] = (categoryCount["cacao"] or 0) / slotCount
	ratios["coffee"] = (categoryCount["coffee"] or 0) / slotCount
	ratios["dairy"] = (categoryCount["dairy"] or 0) / slotCount
	ratios["flavor"] = (categoryCount["flavor"] or 0) / slotCount
	ratios["fruit"] = (categoryCount["fruit"] or 0) / slotCount
	ratios["nut"] = (categoryCount["nut"] or 0) / slotCount
	ratios["sugar"] = (categoryCount["sugar"] or 0) / slotCount

	-- Evaluate the recipe by point count, starting with the baseline. Collect hints and apply pricing options.
	local points = 140
	
    local used_feedback_keys = {}
	
	-- General: Look for variety. Hit them especially if they're using all of one ingredient...
	local variety = differentCount / slotCount
	if differentCount == 1 then
        table.insert(hints, "taster_variety"); points=30;
        used_feedback_keys["taster_variety"] = true
	elseif variety < .5 then
        table.insert(hints, "taster_variety"); points=points-60;
        used_feedback_keys["taster_variety"] = true
	elseif variety < .6 then
        table.insert(hints, "taster_variety"); points=points-30;
        used_feedback_keys["taster_variety"] = true
	end
	
--DebugOut("different:"..tostring(differentCount))
--DebugOut("variety:"..tostring(variety))	

    local evaluators = {}
    if productCategory.factory == "coffee" then
        evaluators = CoffeeEvaluators
    elseif productCategory.factory == "chocolate" then
        evaluators = ChocolateEvaluators
    end

    local unique_hints = {}
    local non_unique_hints = {}
	local voided_keys = {}

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
                if rule.unique then table.insert(unique_hints, rule.feedback)
                else table.insert(non_unique_hints, rule.feedback) end
                if rule.voids then
                    for _, void_key in ipairs(rule.voids) do voided_keys[void_key] = true end
                end
                used_feedback_keys[rule.feedback] = true
            end
        end
    end

	local final_non_unique = {}
	for _, hint in ipairs(non_unique_hints) do
		if not voided_keys[hint] then table.insert(final_non_unique, hint) end
	end
    hints = final_non_unique
    if table.getn(unique_hints) > 0 then
        local randomIndex = RandRange(1, table.getn(unique_hints))
        table.insert(hints, unique_hints[randomIndex])
    end

	-- Chocolate Products Base Requirements
	if productCategory.factory == "chocolate" then
		if ratios["cacao"] == 0 then table.insert(hints, "taster_cacao"); points=30;
		elseif (ratios["sugar"] == 0 and ratios["fruit"] == 0) then table.insert(hints, "taster_sugar"); points=30;
		elseif productCategory.name == "truffle" and (not ingredientCount["powder"]) then table.insert(hints, "taster_powder"); points=30;
		end
	end

    -- Check for Repetition
    if code == Player.lastTastedRecipeCode and points < 50 then
        hints = { "taster_feedback_repetition" }
        DebugOut("RECIPE", "Repeated bad recipe detected. Teddy comments.")
    end

    -- Update Teddy's memory for the next evaluation
    if points < 50 then Player.lastTastedRecipeCode = code
    else Player.lastTastedRecipeCode = nil end
	
	local feedback
	if existingProduct then
		if existingProduct:IsKnown() then 
            feedback = GetRandomFeedbackString("taster_feedback_tasteslike_known", existingProduct:GetName())
		else 
            feedback = GetRandomFeedbackString("taster_feedback_tasteslike_unknown", existingProduct:GetName())
		end
		points = 50
	else
		local feedback_lines = {}
		if table.getn(hints) > 0 then
			for _, hint_key in ipairs(hints) do
				table.insert(feedback_lines, "" .. GetRandomFeedbackString(hint_key))
			end
		else
			local category = _AllCategories.user
			if category and table.getn(category.products) < Player.customSlots then
				table.insert(feedback_lines, GetReplacedString("taster_feedback_default"))
			else
				table.insert(feedback_lines, GetReplacedString("taster_feedback_default_noslots"))
			end
		end
		feedback = table.concat(feedback_lines, "<br>")
	end
	
	-- Determine the markup value based on point score. Cap between 10% and 300%
	-- TODO: What is the appropriate upper limit??
	if points < 10 then points = 10
	elseif points > 300 then points = 300
	end

	-- DebugOut("Calculating markup - productCategory:"..tostring(productCategory))
	-- DebugOut("Normal category markup:"..tostring(productCategory.markup))
	local markup = productCategory.markup or 1
	markup = markup * points / 100

	-- DebugOut("This recipe markup: "..tostring(markup))

	-- Determine how far off we are from the maximum category markup
	-- local response = markup / productCategory.markup

	-- DebugOut("Ingredient pricing: "..tostring(lowPrice).." - "..tostring(highPrice))

	lowPrice = Floor(lowPrice * markup + .5)
	if lowPrice < 1 then lowPrice = 1 end
	highPrice = Floor(highPrice * markup + .5)
	if highPrice < 1 then highPrice = 1 end

	-- DebugOut("Recipe pricing: "..tostring(lowPrice).." - "..tostring(highPrice))
    DebugOut("RECIPE", "Evaluation complete. Final score: " .. points .. ". Feedback keys: " .. table.concat(hints, ", "))

    if feedback and string.find(feedback, "<player>") then
        feedback = string.gsub(feedback, "<player>", Player.name or "")
    end

	return feedback, response, lowPrice, highPrice, allow
end