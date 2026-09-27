--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Creations)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Creation Schema
-------------------------------------------------------------------------------

CommunityCreation = CommunityCreation or {}
CommunityCreation.SchemaVersion = 1
CommunityCreation.GameId = "c3_dbd"

local categoryLimits =
{
	bar = { 2, 4 },
	beverage = { 3, 4 },
	infusion = { 4, 5 },
	truffle = { 5, 6 },
	blend = { 3, 5 },
	exotic = { 5, 6 },
}

-- Number of shipped, selectable base images in each Secret Test Kitchen layer.
-- Highlights/mugs/rims are derived presentation assets and never travel over
-- the wire.  These values come directly from the current Reforged assets.
local appearanceCounts =
{
	bar = { 4, 7, 5, 11 },
	beverage = { 4, 5, 6, 7 },
	infusion = { 2, 5, 6, 10 },
	truffle = { 2, 6, 7, 10 },
	blend = { 2, 3, 5, 8 },
	exotic = { 2, 2, 6, 10 },
}

-------------------------------------------------------------------------------
-- Validation Helpers
-------------------------------------------------------------------------------

local function IsInteger(value)
	return type(value) == "number" and Floor(value) == value
end

local function Channel(value)
	return IsInteger(value) and value >= 0 and value <= 255
end

local function ValidIngredient(value)
	if type(value) ~= "string" or string.len(value) < 1 or string.len(value) > 64 then
		return false
	end
	if string.find(value, "^[a-z0-9_]+$") == nil then
		return false
	end
	if _AllIngredients and not _AllIngredients[value] then
		return false
	end
	return true
end

local function AppearanceLayerNumber(category, image)
	if type(image) ~= "string" then
		return nil
	end
	local _, _, layerText, optionText = string.find(image, "^" .. category .. "/layer([1-4])_([0-9]+)$")
	if not layerText then
		return nil
	end
	local layer = tonumber(layerText)
	local option = tonumber(optionText)
	if not layer or not option then
		return nil
	end
	local counts = appearanceCounts[category]
	if not counts or option < 1 or option > counts[layer] then
		return nil
	end
	return layer
end

local function NormalizedLayer(category, value)
	if type(value) ~= "table" then
		return nil, "Creation appearance layer must be a table."
	end

	-- Accept both the named JSON representation and the Test Kitchen's saved
	-- positional tuple: { image, red, green, blue }.
	local image = value.image or value[1]

	-- A blank selector is a valid visual choice in the Test Kitchen. Older
	-- saves may persist it as layerN_0/layerN_00 rather than omitting the layer.
	-- Blank layers carry no visual data over the wire, so normalize them to a
	-- sentinel which the caller simply skips. Empty/nil images are equivalent.
	if image == nil or image == "" then
		return { blank = true }, nil
	end
	if type(image) == "string" then
		local _, _, blankLayer, blankOption = string.find(image, "^" .. category .. "/layer([1-4])_([0-9]+)$")
		if blankLayer and tonumber(blankOption) == 0 then
			return { blank = true, layer_number = tonumber(blankLayer) }, nil
		end
	end
	local red = value.red
	local green = value.green
	local blue = value.blue
	if red == nil then
		red = value[2]
	end
	if green == nil then
		green = value[3]
	end
	if blue == nil then
		blue = value[4]
	end

	local layerNumber = AppearanceLayerNumber(category, image)
	if not layerNumber then
		return nil, "Creation contains an unknown appearance asset."
	end

	-- Depending on the engine build, indexing a Color object can expose either
	-- byte channels (0..255) or normalized channels (0..1). Saved UGRs come
	-- from Color objects, while JSON always carries bytes. Normalize both.
	if type(red) == "number" and type(green) == "number" and type(blue) == "number"
		and red >= 0 and red <= 1 and green >= 0 and green <= 1 and blue >= 0 and blue <= 1 then
		red = Floor((red * 255) + 0.5)
		green = Floor((green * 255) + 0.5)
		blue = Floor((blue * 255) + 0.5)
	end
	if not Channel(red) or not Channel(green) or not Channel(blue) then
		return nil, "Creation appearance RGB values must be integers from 0 to 255."
	end

	return {
		image = image,
		red = red,
		green = green,
		blue = blue,
		layer_number = layerNumber,
	}, nil
end

-------------------------------------------------------------------------------
-- CreationData Conversion
-------------------------------------------------------------------------------

function CommunityCreation.Normalize(value)
	if type(value) ~= "table" then
		return nil, "Creation payload must be a table."
	end
	if value.schema_version ~= CommunityCreation.SchemaVersion then
		return nil, "Unsupported creation schema version."
	end
	if value.game_id ~= CommunityCreation.GameId then
		return nil, "Unsupported creation game_id."
	end
	if type(value.name) ~= "string" or string.len(value.name) < 1 or string.len(value.name) > 100 then
		return nil, "Creation name must contain 1 to 100 bytes."
	end
	if type(value.description) ~= "string" or string.len(value.description) > 400 then
		return nil, "Creation description may contain at most 400 bytes."
	end

	local limits = categoryLimits[value.category]
	if not limits then
		return nil, "Unsupported creation category."
	end
	if type(value.ingredients) ~= "table" then
		return nil, "Creation ingredients must be a table."
	end

	local ingredientCount = table.getn(value.ingredients)
	if ingredientCount < limits[1] or ingredientCount > limits[2] then
		return nil, string.format("%s creations must contain %d to %d ingredients.", value.category, limits[1], limits[2])
	end
	local ingredients = {}
	for i = 1, ingredientCount do
		local ingredient = value.ingredients[i]
		if not ValidIngredient(ingredient) then
			return nil, "Creation contains an unknown ingredient identifier."
		end
		table.insert(ingredients, ingredient)
	end

	if type(value.appearance) ~= "table" then
		return nil, "Creation appearance must be a table."
	end
	local layerCount = table.getn(value.appearance)
	if layerCount > 4 then
		return nil, "Creation appearance may contain at most 4 layers."
	end
	local byLayer = {}
	for i = 1, layerCount do
		local layer, layerError = NormalizedLayer(value.category, value.appearance[i])
		if not layer then
			return nil, layerError
		end
		if not layer.blank then
			if byLayer[layer.layer_number] then
				return nil, "Creation cannot contain two appearance choices for the same layer."
			end
			byLayer[layer.layer_number] = layer
		end
	end

	-- Canonical wire ordering is layer 1 -> 4 regardless of how a payload was
	-- received or how a save happened to enumerate its appearance table.
	local appearance = {}
	for i = 1, 4 do
		local layer = byLayer[i]
		if layer then
			table.insert(appearance, {
				image = layer.image,
				red = layer.red,
				green = layer.green,
				blue = layer.blue,
			})
		end
	end

	return {
		schema_version = CommunityCreation.SchemaVersion,
		game_id = CommunityCreation.GameId,
		name = value.name,
		description = value.description,
		category = value.category,
		ingredients = ingredients,
		appearance = appearance,
	}, nil
end

function CommunityCreation.FromKitchenData(value)
	value = value or {}
	return CommunityCreation.Normalize {
		schema_version = CommunityCreation.SchemaVersion,
		game_id = CommunityCreation.GameId,
		name = value.name,
		description = value.description or "",
		category = value.category,
		ingredients = value.ingredients,
		appearance = value.appearance or {},
	}
end

function CommunityCreation.ToKitchenData(value)
	local creation, err = CommunityCreation.Normalize(value)
	if not creation then
		return nil, err
	end
	local appearance = {}
	for _, layer in ipairs(creation.appearance) do
		table.insert(appearance, { layer.image, layer.red, layer.green, layer.blue })
	end
	return {
		name = creation.name,
		description = creation.description,
		category = creation.category,
		ingredients = creation.ingredients,
		appearance = appearance,
	}, nil
end

local function ProductCodeFromCodeTable(codeTable)
	local parts = {}
	for i = 1, table.getn(codeTable) do
		parts[i] = string.lower(tostring(codeTable[i]))
	end
	return table.concat(parts, "_")
end

-------------------------------------------------------------------------------
-- Community Provenance
-------------------------------------------------------------------------------

-- A Community recipe's core identity is its machinery category plus ordered
-- ingredients. Names, descriptions, artwork and tints are intentionally not
-- included: repainting or renaming someone else's recipe does not turn it into
-- a new recipe, while changing the recipe itself does.
function CommunityCreation.CoreSignature(value)
	if type(value) ~= "table" then
		return nil, "Creation signature source must be a table."
	end

	local canonical, err
	if value.schema_version ~= nil then
		canonical, err = CommunityCreation.Normalize(value)
	else
		canonical, err = CommunityCreation.FromKitchenData(value)
	end
	if not canonical then
		return nil, err
	end

	local parts = { string.lower(tostring(canonical.category or "")) }
	for _, ingredient in ipairs(canonical.ingredients or {}) do
		table.insert(parts, string.lower(tostring(ingredient)))
	end
	return table.concat(parts, "|")
end

-- Store the origin of a saved UGR after a Community creation has travelled
-- through the Test Kitchen. Player fields are deliberately used so provenance
-- follows the campaign save rather than one UI session.
function CommunityCreation.RecordSavedRecipeSource(product, source, savedCreation)
	if not Player or not product or type(product.code) ~= "string" or product.code == "" then
		return false, "Could not attach Community provenance to this saved recipe."
	end
	if type(source) ~= "table" then
		return false, "Community source metadata is missing."
	end

	local savedSignature, savedError = CommunityCreation.CoreSignature(savedCreation)
	if not savedSignature then
		return false, savedError
	end
	local sourceSignature = tostring(source.core_signature or "")
	if sourceSignature == "" then
		return false, "Community source recipe signature is missing."
	end

	Player.itemCommunitySources = Player.itemCommunitySources or {}
	local code = string.lower(product.code)
	Player.itemCommunitySources[code] =
	{
		source_creation_id = tostring(source.creation_id or ""),
		source_profile_id = tostring(source.profile_id or ""),
		source_public_name = tostring(source.public_name or ""),
		source_is_owned = source.is_owned == true,
		source_core_signature = sourceSignature,
		saved_core_signature = savedSignature,
	}
	return true, nil
end

-- Locate source information for a creation reconstructed from the local Recipe
-- Book. Duplicate recipe signatures are already rejected by the Test Kitchen,
-- so a saved signature maps cleanly to one provenance record.
function CommunityCreation.GetShareDisposition(value)
	local currentSignature, signatureError = CommunityCreation.CoreSignature(value)
	if not currentSignature then
		return nil, "original", signatureError
	end
	if not Player or type(Player.itemCommunitySources) ~= "table" then
		return nil, "original", nil
	end

	for productCode, source in pairs(Player.itemCommunitySources) do
		if type(source) == "table" and tostring(source.saved_core_signature or "") == currentSignature then
			local copy =
			{
				product_code = tostring(productCode or ""),
				source_creation_id = tostring(source.source_creation_id or ""),
				source_profile_id = tostring(source.source_profile_id or ""),
				source_public_name = tostring(source.source_public_name or ""),
				source_is_owned = source.source_is_owned == true,
				source_core_signature = tostring(source.source_core_signature or ""),
				saved_core_signature = currentSignature,
			}

			local ownedByCurrentProfile = copy.source_is_owned
			if copy.source_profile_id ~= "" and CommunityAccount and CommunityAccount.GetProfileId then
				local currentProfileId = tostring(CommunityAccount.GetProfileId() or "")
				if currentProfileId ~= "" then
					ownedByCurrentProfile = currentProfileId == copy.source_profile_id
				else
					ownedByCurrentProfile = false
				end
			end
			if ownedByCurrentProfile then
				return copy, "owned", nil
			end
			if copy.source_core_signature ~= "" and copy.source_core_signature == currentSignature then
				return copy, "foreign_copy", nil
			end
			return copy, "remix", nil
		end
	end
	return nil, "original", nil
end

-------------------------------------------------------------------------------
-- Saved Recipe Conversion
-------------------------------------------------------------------------------

-- Convert saved User Generated Recipes from ingredient codes to stable names.

function CommunityCreation.FromSavedRecipe(index)
	if not Player or type(Player.itemRecipes) ~= "table" then
		return nil, "This save has no custom recipe table."
	end
	local codeTable = Player.itemRecipes[index]
	if type(codeTable) ~= "table" or table.getn(codeTable) < 2 then
		return nil, "Saved custom recipe is malformed."
	end

	local productCode = ProductCodeFromCodeTable(codeTable)
	local category = nil
	if Player.itemMachinery then
		category = Player.itemMachinery[productCode]
	end
	if not category or category == "" then
		category = codeTable[1]
	end
	if not categoryLimits[category] then
		return nil, "Saved custom recipe has an unsupported confection category."
	end

	local ingredients = {}
	for i = 2, table.getn(codeTable) do
		local ingredient = _IngredientCodes and _IngredientCodes[codeTable[i]] or nil
		if not ingredient then
			return nil, "Saved custom recipe contains an unknown ingredient code."
		end
		table.insert(ingredients, ingredient.name)
	end

	local name = Player.itemNames and Player.itemNames[productCode] or nil
	local description = Player.itemDescriptions and Player.itemDescriptions[productCode] or ""
	local appearance = Player.itemAppearance and Player.itemAppearance[productCode] or {}
	if not name or name == "" then
		return nil, "Saved custom recipe has no public name."
	end

	local creation, err = CommunityCreation.Normalize {
		schema_version = CommunityCreation.SchemaVersion,
		game_id = CommunityCreation.GameId,
		name = name,
		description = description or "",
		category = category,
		ingredients = ingredients,
		appearance = appearance,
	}
	if not creation then
		return nil, err
	end
	local provenance = nil
	if Player.itemCommunitySources and type(Player.itemCommunitySources[productCode]) == "table" then
		provenance = Player.itemCommunitySources[productCode]
	end
	return creation, nil, { index = index, product_code = productCode, provenance = provenance }
end

function CommunityCreation.FindSavedRecipeIndex(product)
	if not product or type(product.code) ~= "string" then
		return nil, "No saved custom recipe is selected."
	end
	if not Player or type(Player.itemRecipes) ~= "table" then
		return nil, "This save has no custom recipe table."
	end

	local wanted = string.lower(product.code)
	for i = 1, table.getn(Player.itemRecipes) do
		local codeTable = Player.itemRecipes[i]
		if type(codeTable) == "table" and table.getn(codeTable) >= 2 then
			if string.lower(ProductCodeFromCodeTable(codeTable)) == wanted then
				return i, nil
			end
		end
	end
	return nil, "The selected custom recipe could not be matched to its saved recipe data."
end

function CommunityCreation.FromProduct(product)
	local index, err = CommunityCreation.FindSavedRecipeIndex(product)
	if not index then
		return nil, err
	end
	return CommunityCreation.FromSavedRecipe(index)
end

function CommunityCreation.FirstSavedCreation()
	if not Player or type(Player.itemRecipes) ~= "table" then
		return nil, "This save has no custom recipes."
	end
	local lastError = nil
	for i = 1, table.getn(Player.itemRecipes) do
		local creation, err, meta = CommunityCreation.FromSavedRecipe(i)
		if creation then
			return creation, nil, meta
		end
		lastError = err
	end
	return nil, lastError or "This save has no custom recipes to upload."
end

-------------------------------------------------------------------------------
-- Progression Checks
-------------------------------------------------------------------------------

-- Check discovery state only; current inventory does not affect recipe access.
function CommunityCreation.GetAvailability(value)
	local creation, err = CommunityCreation.Normalize(value)
	if not creation then
		return nil, err
	end

	local categoryUnlocked = Player and Player.categoryCount and Player.categoryCount[creation.category] ~= nil
	local missing = {}
	local availableCount = 0
	for _, ingredient in ipairs(creation.ingredients) do
		local unlocked = Player and Player.labIngredients and Player.labIngredients[ingredient]
		if unlocked then
			availableCount = availableCount + 1
		else
			table.insert(missing, ingredient)
		end
	end

	return {
		category_unlocked = categoryUnlocked and true or false,
		available_ingredients = availableCount,
		total_ingredients = table.getn(creation.ingredients),
		missing_ingredients = missing,
		can_load = (categoryUnlocked and table.getn(missing) == 0) and true or false,
	}, nil
end
