--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Simulation Data Validation)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Reforged modifications (c) 2026 Michael Lane.
--]]---------------------------------------------------------------------------

-- Cross-checks the data layers that feed the Secret Test Kitchen and factory
-- simulation: ingredients, categories, stock products, recipe feedback rules,
-- and localization.  This is deliberately read-only.

local function _RecipeValidationCompare(actual, operator, expected)
	if operator == ">" then return actual > expected end
	if operator == "<" then return actual < expected end
	if operator == "==" then return actual == expected end
	if operator == ">=" then return actual >= expected end
	if operator == "<=" then return actual <= expected end
	return false
end

local function _RecipeValidationAnalyzeCounts(counts)
	local total = 0
	local familyCounts = {}
	local traitCounts = {}

	for ingredientName, count in pairs(counts or {}) do
		count = tonumber(count) or 0
		total = total + count
		local ing = _AllIngredients[ingredientName]
		if ing then
			local family = ing.GetRecipeFamily and ing:GetRecipeFamily() or ing.category
			familyCounts[family] = (familyCounts[family] or 0) + count
			if ing.alcohol then
				traitCounts.alcohol = (traitCounts.alcohol or 0) + count
			end
		end
	end

	local ratios = {}
	local families = { "cacao", "coffee", "dairy", "flavor", "fruit", "nut", "sugar" }
	for _, family in ipairs(families) do
		if total > 0 then ratios[family] = (familyCounts[family] or 0) / total
		else ratios[family] = 0 end
	end

	return { total = total, familyCounts = familyCounts, traitCounts = traitCounts, ratios = ratios }
end

local function _RecipeValidationRuleMatches(rule, category, counts, analysis)
	if rule.categories then
		local found = false
		for _, categoryName in ipairs(rule.categories) do
			if categoryName == category.name then found = true; break end
		end
		if not found then return false end
	end

	for _, ingredientName in ipairs(rule.requires or {}) do
		if not counts[ingredientName] then return false end
	end
	for _, ingredientName in ipairs(rule.forbids or {}) do
		if counts[ingredientName] then return false end
	end

	for _, condition in ipairs(rule.counts or {}) do
		if not _RecipeValidationCompare(counts[condition[1]] or 0, condition[2], condition[3]) then return false end
	end
	for _, condition in ipairs(rule.trait_counts or {}) do
		if not _RecipeValidationCompare(analysis.traitCounts[condition[1]] or 0, condition[2], condition[3]) then return false end
	end
	for _, condition in ipairs(rule.ratios or {}) do
		if not _RecipeValidationCompare(analysis.ratios[condition[1]] or 0, condition[2], condition[3]) then return false end
	end

	return true
end

function ValidateSimulationData()
	local errors = 0
	local warnings = 0
	local validDrawers = { cacao=true, coffee=true, tea=true, dairy=true, sugar=true, fruit=true, nut=true, flavor=true, liqueur=true }
	local validFamilies = { cacao=true, coffee=true, dairy=true, sugar=true, fruit=true, nut=true, flavor=true, special=true }
	local validFeedbackPools = { chocolate=true, coffee=true }

	local function Error(message)
		errors = errors + 1
		DebugOut("ERROR", "Simulation validation: " .. message)
	end
	local function Warn(message)
		warnings = warnings + 1
		DebugOut("WARNING", "Simulation validation: " .. message)
	end

	-- Ingredient metadata / Test Kitchen drawer mapping.
	for _, ing in ipairs(_IngredientOrder or {}) do
		local drawer = ing.GetKitchenCategory and ing:GetKitchenCategory() or ing.category
		local family = ing.GetRecipeFamily and ing:GetRecipeFamily() or ing.category
		if not validDrawers[drawer] then
			Error(string.format("ingredient '%s' maps to unknown Kitchen drawer '%s'.", tostring(ing.name), tostring(drawer)))
		end
		if not validFamilies[family] then
			Error(string.format("ingredient '%s' maps to unknown recipe family '%s'.", tostring(ing.name), tostring(family)))
		end
		if (tonumber(ing.price_low) or 0) > (tonumber(ing.price_high) or 0) then
			Error(string.format("ingredient '%s' has price_low above price_high.", tostring(ing.name)))
		end
	end

	-- Category data.
	for _, category in ipairs(_CategoryOrder or {}) do
		if category.name ~= "user" then
			if not category:IsRecipeSlotCountValid(category.min_ingredients) or not category:IsRecipeSlotCountValid(category.max_ingredients) then
				Error(string.format("category '%s' has invalid ingredient bounds %s-%s.", tostring(category.name), tostring(category.min_ingredients), tostring(category.max_ingredients)))
			end
			local pool = category.feedback_pool or category.factory
			if not validFeedbackPools[pool] then
				Error(string.format("category '%s' has unsupported feedback pool '%s'.", tostring(category.name), tostring(pool)))
			end
		end
	end

	-- Stock products: recipe references, slot bounds, structural requirements,
	-- duplicate signatures, and negative-feedback contradictions.
	local signatures = {}
	local productCount = 0
	for _, product in pairs(_AllProducts or {}) do
		-- Player UGRs can already exist by the time validation runs after LoadGame;
		-- only static stock products belong in this data integrity pass.
		if product.category and product.category.name ~= "user" then
			productCount = productCount + 1
			local productErrors = product.ValidateRecipeDefinition and product:ValidateRecipeDefinition() or 0
			errors = errors + productErrors

			local parts = {}
			for ingredientName, count in pairs(product.counts or {}) do
				if not _AllIngredients[ingredientName] then
					Error(string.format("stock product '%s' references missing ingredient '%s'.", tostring(product.code), tostring(ingredientName)))
				end
				table.insert(parts, tostring(ingredientName) .. "=" .. tostring(count))
			end
			table.sort(parts)
			local signature = tostring(product.category.name) .. ":" .. table.concat(parts, ",")
			if signatures[signature] then
				Error(string.format("stock products '%s' and '%s' share an identical recipe signature.", tostring(signatures[signature]), tostring(product.code)))
			else
				signatures[signature] = product.code
			end

			local analysis = _RecipeValidationAnalyzeCounts(product.counts)
			local evaluators = product.category.GetFeedbackEvaluators and product.category:GetFeedbackEvaluators() or {}
			for _, rule in ipairs(evaluators) do
				if (rule.score or 0) < 0 and _RecipeValidationRuleMatches(rule, product.category, product.counts, analysis) then
					Warn(string.format("stock product '%s' matches negative feedback '%s' (%d).", tostring(product.code), tostring(rule.feedback), tonumber(rule.score) or 0))
				end
			end
		end
	end

	-- Feedback keys, rule ingredients, ratios, count operators and void targets.
	if ValidateRecipeFeedbackRules then
		errors = errors + (ValidateRecipeFeedbackRules() or 0)
	end

	DebugOut("LOAD", string.format("Simulation validation complete: %d stock products checked, %d error(s), %d warning(s).", productCount, errors, warnings))
	return errors, warnings
end
