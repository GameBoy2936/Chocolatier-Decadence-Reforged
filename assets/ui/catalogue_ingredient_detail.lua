--[[---------------------------------------------------------------------------
	Chocolatier Three: Catalogue Detail - Ingredients
	Copyright (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local ing = gCatalogueSelection

if not ing then
	DebugOut("ERROR", "Ingredient detail panel opened without a catalogue selection.")
	return
end

local isUnlocked = Player.catalogue.unlockedIngredients[ing.name]
local showUnlockedView = isUnlocked or gDevForceReveal

local contents = {}

DebugOut("UI", string.format("Opening Ingredient Detail panel: %s", ing.name), { unlocked = showUnlockedView })

-------------------------------------------------------------------------------
-- State Management (Right Column Scrolling)
-------------------------------------------------------------------------------

local ingKey = ing.name
if gCatalogueIngLast ~= ingKey then
	DebugOut("UI", string.format("Ingredient selection changed to %s. Resetting detail scroll state.", tostring(ingKey)))
	gCatalogueIngOffsets = { 0 }
	gCatalogueIngPage = 1
	gCatalogueIngLast = ingKey
end

-- Fallbacks
gCatalogueIngOffsets = gCatalogueIngOffsets or { 0 }
gCatalogueIngPage = gCatalogueIngPage or 1

-- Scrolling Constants
local right_col_x = 182
local right_col_w = 250
local right_col_h = 320      -- Static height, leaving room for scroll buttons below
local chars_per_scroll = 140 -- Approx text capacity of 3 lines at this width
local chars_per_page = 800   -- Approx capacity of the bounding box

-------------------------------------------------------------------------------
-- Ingredient Article Assembly
-------------------------------------------------------------------------------
-- Reforged v2 catalogue entries are split into smaller localization strings.
-- This script owns the generated headers, colors, section order, and legacy
-- fallback path so entries can be migrated one ingredient at a time.

local IngredientCatalogueColors =
{
	add_coffee = { primary = "#89431F", secondary = "#642E17" },
	allspice = { primary = "#8B4513", secondary = "#A0522D" },
	almond = { primary = "#A67C52", secondary = "#C49A6C" },
	amaretto = { primary = "#CC7722", secondary = "#E69926" },
	anise = { primary = "#5E2C04", secondary = "#8C4A11" },
	apple = { primary = "#C9082A", secondary = "#E32636" },
	apricot = { primary = "#E67E22", secondary = "#F39C12" },
	bal_cacao = { primary = "#CBC137", secondary = "#6B4423" },
	bal_coffee = { primary = "#12110A", secondary = "#29291B" },
	banana = { primary = "#B7950B", secondary = "#D4AC0D" },
	bel_cacao = { primary = "#387E40", secondary = "#6B4423" },
	blackberry = { primary = "#4B0082", secondary = "#6A0DAD" },
	blueberry = { primary = "#2A52BE", secondary = "#4169E1" },
	bog_cacao = { primary = "#AF8110", secondary = "#6B4423" },
	bog_coffee = { primary = "#2F0F07", secondary = "#5B2214" },
	brandy = { primary = "#87410E", secondary = "#B05C1A" },
	butter = { primary = "#D4AC0D", secondary = "#F4D03F" },
	cacao = { primary = "#992412", secondary = "#6B4423" },
	caramel = { primary = "#AF6E4D", secondary = "#C68E17" },
	cardamom = { primary = "#7B855D", secondary = "#9DA77A" },
	cashew = { primary = "#A08B5D", secondary = "#C1AA7F" },
	cayenne = { primary = "#C21807", secondary = "#E3242B" },
	chamomile = { primary = "#BDB76B", secondary = "#D4CE82" },
	cherry = { primary = "#790604", secondary = "#9E1B11" },
	chestnut = { primary = "#954535", secondary = "#B35A47" },
	cinnamon = { primary = "#8B4513", secondary = "#A0522D" },
	clove = { primary = "#5C3A21", secondary = "#7E5335" },
	coconut = { primary = "#5D4037", secondary = "#795548" },
	cranberry = { primary = "#9E001C", secondary = "#C00021" },
	cream = { primary = "#A69C82", secondary = "#C2B89D" },
	currant = { primary = "#5C0A1F", secondary = "#801A36" },
	date = { primary = "#5A311D", secondary = "#7C462C" },
	dou_cacao = { primary = "#C26045", secondary = "#6B4423" },
	dragonfruit = { primary = "#C2185B", secondary = "#E91E63" },
	earl_grey = { primary = "#595454", secondary = "#7B7777" },
	espresso = { primary = "#2B1B17", secondary = "#4A362E" },
	fig = { primary = "#6B3FA0", secondary = "#8954C6" },
	ginger = { primary = "#B06500", secondary = "#D47A00" },
	grand_marnier = { primary = "#CC5500", secondary = "#E66C1A" },
	guava = { primary = "#C94F7C", secondary = "#E07A9A" },
	hav_coffee = { primary = "#3F131E", secondary = "#5C4033" },
	hazelnut = { primary = "#624A2E", secondary = "#846542" },
	hibiscus = { primary = "#B8336A", secondary = "#D44784" },
	honey = { primary = "#C5A017", secondary = "#E5C138" },
	ice_cream = { primary = "#7FB3D5", secondary = "#BFE3F2" },
	jasmine = { primary = "#A9A57C", secondary = "#C1BD98" },
	kahlua = { primary = "#492B1D", secondary = "#69412F" },
	kon_coffee = { primary = "#6E3A1E", secondary = "#895334" },
	lavender = { primary = "#7B68EE", secondary = "#9370DB" },
	lemon = { primary = "#B7950B", secondary = "#D4AC0D" },
	lemongrass = { primary = "#7B9A6D", secondary = "#94B585" },
	lim_cacao = { primary = "#C9C4A4", secondary = "#6B4423" },
	lime = { primary = "#228B22", secondary = "#2E8B57" },
	lychee = { primary = "#DC143C", secondary = "#F08080" },
	macadamia = { primary = "#8B7355", secondary = "#A08A6B" },
	mah_cacao = { primary = "#D99A25", secondary = "#6B4423" },
	mango = { primary = "#D35400", secondary = "#E67E22" },
	maple = { primary = "#C53004", secondary = "#E84A1C" },
	marshmallow = { primary = "#B09090", secondary = "#CFA9A9" },
	matcha = { primary = "#4A7023", secondary = "#739E3E" },
	milk = { primary = "#4682B4", secondary = "#5F9EA0" },
	mint = { primary = "#2E8B57", secondary = "#3CB371" },
	nutmeg = { primary = "#8B5A2B", secondary = "#A06B3E" },
	oat = { primary = "#B89A78", secondary = "#D2B48C" },
	orange = { primary = "#E65C00", secondary = "#FF7F00" },
	passionfruit = { primary = "#6A0DAD", secondary = "#8B008B" },
	peach = { primary = "#E67345", secondary = "#FF8C61" },
	peanut = { primary = "#B5651D", secondary = "#CD853F" },
	pear = { primary = "#8A9A30", secondary = "#A6B83A" },
	pecan = { primary = "#4A2511", secondary = "#6B3A20" },
	pistachio = { primary = "#7BA85C", secondary = "#96CC70" },
	pineapple = { primary = "#B89C00", secondary = "#D4B600" },
	plum = { primary = "#6C3483", secondary = "#8E44AD" },
	pomegranate = { primary = "#8B0000", secondary = "#A52A2A" },
	powder = { primary = "#3D2314", secondary = "#5C351F" },
	pumpkin = { primary = "#D35400", secondary = "#E67E22" },
	raisin = { primary = "#403142", secondary = "#5A455C" },
	raspberry = { primary = "#C2185B", secondary = "#E91E63" },
	rhubarb = { primary = "#A42A04", secondary = "#C2431E" },
	rooibos = { primary = "#9E3B1C", secondary = "#C15330" },
	rose = { primary = "#C21E56", secondary = "#E04B7B" },
	rosemary = { primary = "#4A6B53", secondary = "#668F72" },
	rum = { primary = "#6E3A1A", secondary = "#8F542D" },
	saffron = { primary = "#D98719", secondary = "#F5A023" },
	salt = { primary = "#8A9BA8", secondary = "#B8C3CC" },
	sesame = { primary = "#BCA37F", secondary = "#D4BC9B" },
	star_anise = { primary = "#5C2C16", secondary = "#7A4226" },
	strawberry = { primary = "#C82536", secondary = "#E74C3C" },
	sugar = { primary = "#C19A6B", secondary = "#DAB88C" },
	sumac = { primary = "#8B1C2A", secondary = "#A82E3E" },
	tamarind = { primary = "#5D3A1A", secondary = "#7D522B" },
	tan_coffee = { primary = "#AD684A", secondary = "#CA8263" },
	tea = { primary = "#4A2511", secondary = "#6B3A20" },
	toffee = { primary = "#B57434", secondary = "#D6944E" },
	turmeric = { primary = "#E69A0B", secondary = "#FFB82E" },
	vanilla = { primary = "#C3B091", secondary = "#DFCDAF" },
	wafer = { primary = "#C49A6C", secondary = "#E0C28A" },
	walnut = { primary = "#5C4033", secondary = "#7B5C4D" },
	wasabi = { primary = "#7B9A5B", secondary = "#96BA72" },
	whipped_cream = { primary = "#A3B5C1", secondary = "#C4D4DE" },
	whiskey = { primary = "#C77926", secondary = "#E89D46" },
	yuzu = { primary = "#D4A017", secondary = "#F0C64A" },
}

local function GetSafeString(key, fallback)
	local text = GetString(key)
	if not text or text == "#####" or text == key then
		return fallback
	end
	return text
end

local function GetOptionalCatalogueString(key)
	local text = GetString(key)
	if not text or text == "#####" or text == key then
		return nil
	end
	return text
end

local function GetIngredientCatalogueColors(ingredientName)
	return IngredientCatalogueColors[ingredientName] or {
		primary = "#8B4513",
		secondary = "#A0522D"
	}
end

local function MakeIngredientHeader(text, color)
	return "<font size='18' color='" .. color .. "'><b>" .. text .. "</b></font><br><br>"
end

local function MakeIngredientSubHeader(text, color)
	return "<font size='15' color='" .. color .. "'><b>" .. text .. "</b></font><br>"
end

local function AppendSection(parts, titleKey, titleFallback, bodyKey, primaryColor)
	local body = GetOptionalCatalogueString(bodyKey)
	if body then
		table.insert(parts, MakeIngredientHeader(GetSafeString(titleKey, titleFallback), primaryColor))
		table.insert(parts, body)
		table.insert(parts, "<br><br>")
	end
end

local function AppendSubSection(parts, titleKey, titleFallback, bodyKey, secondaryColor)
	local body = GetOptionalCatalogueString(bodyKey)
	if body then
		table.insert(parts, MakeIngredientSubHeader(GetSafeString(titleKey, titleFallback), secondaryColor))
		table.insert(parts, body)
		table.insert(parts, "<br><br>")
	end
end

local function BuildIngredientArticleText(ingredient)
	local ingredientName = ingredient.name
	local ingredientLabel = GetSafeString(ingredient.name, ingredient.name)
	local baseKey = "catalogue_ingredient_" .. ingredientName .. "_text"
	local colors = GetIngredientCatalogueColors(ingredientName)
	local parts = {}

	-- Intro has no generated header.
	local intro = GetOptionalCatalogueString(baseKey .. "_intro")
	if intro then
		table.insert(parts, intro)
		table.insert(parts, "<br><br>")
	else
		-- Compatibility fallback for old entries not yet split.
		local legacy = GetOptionalCatalogueString(baseKey)
		if legacy then return legacy end

		DebugOut("ERROR", string.format("Catalogue article missing for Ingredient: %s", ingredientName))
		return GetSafeString("catalogue_ingredient_missing_text", "No catalogue article has been written for this ingredient yet.")
	end

	AppendSection(parts, "catalogue_section_production", "Production and Locality", baseKey .. "_production", colors.primary)
	AppendSection(parts, "catalogue_section_flavor", "Flavor Profile", baseKey .. "_flavor", colors.primary)

	-- Usage section groups three smaller strings under one generated parent header.
	local usageChocolate = GetOptionalCatalogueString(baseKey .. "_usage_chocolate")
	local usageCoffee = GetOptionalCatalogueString(baseKey .. "_usage_coffee")
	local usageTea = GetOptionalCatalogueString(baseKey .. "_usage_tea")

	if usageChocolate or usageCoffee or usageTea then
		local usageTitle = GetSafeString("catalogue_section_usage", "Using %s")
		usageTitle = string.format(usageTitle, ingredientLabel)
		table.insert(parts, MakeIngredientHeader(usageTitle, colors.primary))

		AppendSubSection(parts, "catalogue_section_usage_chocolate", "In Chocolate", baseKey .. "_usage_chocolate", colors.secondary)
		AppendSubSection(parts, "catalogue_section_usage_coffee", "In Coffee", baseKey .. "_usage_coffee", colors.secondary)
		AppendSubSection(parts, "catalogue_section_usage_tea", "In Tea", baseKey .. "_usage_tea", colors.secondary)
	end

	AppendSection(parts, "catalogue_section_strengths", "Synergies and Strengths", baseKey .. "_strengths", colors.primary)
	AppendSection(parts, "catalogue_section_weaknesses", "Clashes and Weaknesses", baseKey .. "_weaknesses", colors.primary)
	AppendSection(parts, "catalogue_section_trivia", "Fun Facts", baseKey .. "_trivia", colors.primary)

	local article = ""
	for _, part in ipairs(parts) do
		article = article .. part
	end

	return article
end

-------------------------------------------------------------------------------
-- HTML Tag Parsing & Safe Pagination Utilities
-------------------------------------------------------------------------------

-- Fast-forwards to find a safe breaking point that won't split an HTML tag.
local function GetNextSafeOffset(text, start_offset, advance_chars)
	local target = start_offset + advance_chars
	local text_len = string.len(text)
	if target >= text_len then return text_len end
	
	local in_tag = false
	local i = start_offset + 1
	
	while i <= target do
		local char = string.sub(text, i, i)
		if char == "<" then in_tag = true elseif char == ">" then in_tag = false end
		i = i + 1
	end
	
	while i <= text_len do
		local char = string.sub(text, i, i)
		if char == "<" then
			in_tag = true
			if string.lower(string.sub(text, i, i+3)) == "<br>" then return i + 3 end
		elseif char == ">" then
			in_tag = false
		elseif char == " " and not in_tag then
			return i
		end
		i = i + 1
	end
	
	return text_len
end

-- Extracts open formatting tags from previous pages to inject into the current page.
local function GetOpenTagsForOffset(text, offset)
	local in_tag = false
	local current_tag = ""
	local is_closing_tag = false
	local active_format_tags = {}
	
	local i = 1
	while i <= offset do
		local char = string.sub(text, i, i)
		if char == "<" then
			in_tag = true; current_tag = ""; is_closing_tag = (string.sub(text, i + 1, i + 1) == "/")
		elseif char == ">" and in_tag then
			in_tag = false
			if is_closing_tag then
				if table.getn(active_format_tags) > 0 then table.remove(active_format_tags) end
			elseif string.lower(string.sub(current_tag, 1, 2)) ~= "br" then
				table.insert(active_format_tags, "<" .. current_tag .. ">")
			end
		elseif in_tag then
			current_tag = current_tag .. char
		end
		i = i + 1
	end
	
	local prefix = ""
	for j = 1, table.getn(active_format_tags) do prefix = prefix .. active_format_tags[j] end
	return prefix
end

-------------------------------------------------------------------------------
-- Scroll Actions
-------------------------------------------------------------------------------

local function ScrollUp()
	if gCatalogueIngPage > 1 then
		gCatalogueIngPage = gCatalogueIngPage - 1
		DebugOut("UI", string.format("Ingredient article scrolled up to page %d.", gCatalogueIngPage))
		SoundEvent("cadi/ui_click.ogg")
		FillWindow("catalogue_detail", "ui/catalogue_ingredient_detail.lua")
	end
end

local function ScrollDown()
	if not showUnlockedView then return end
	
	local rawBody = BuildIngredientArticleText(ing)
	if not rawBody or rawBody == "#####" then return end
	
	if gCatalogueIngPage == table.getn(gCatalogueIngOffsets) then
		local current_offset = gCatalogueIngOffsets[gCatalogueIngPage]
		local next_offset = GetNextSafeOffset(rawBody, current_offset, chars_per_scroll)
		
		if next_offset >= string.len(rawBody) then return end
		
		table.insert(gCatalogueIngOffsets, next_offset)
		DebugOut("UI", string.format("Ingredient article prepared next scroll offset: %d", next_offset))
	end
	
	gCatalogueIngPage = gCatalogueIngPage + 1
	SoundEvent("cadi/ui_click.ogg")
	FillWindow("catalogue_detail", "ui/catalogue_ingredient_detail.lua")
end

-------------------------------------------------------------------------------
-- View Construction
-------------------------------------------------------------------------------

if showUnlockedView then
	-- STATE 2: UNLOCKED INGREDIENT VIEW
	DebugOut("UI", string.format("Rendering unlocked Ingredient detail view: %s", ing.name))
	
	-- Header: Icon & Name
	table.insert(contents, ing:GetAppearanceBig(35, 25))
	
	local nameLabel = GetString(ing.name)
	table.insert(contents, Text { x = 105, y = 15, w = 306, h = 54, label = "#"..nameLabel, font = { labelFontName, 22, BlackColor }, flags = kVAlignCenter + kHAlignCenter })
	
	-- Column 1: Structured Data (Left Side)
	-- Uses dynamic vertical stacking to prevent overlapping text
	local data_y = 110
	local data_x = 18
	local data_w = 160
	local data_font = { uiFontName, 14, BlackColor }
	local header_font = { labelFontName, 16, BlackColor }
	local section_padding = 12

	-- Helper: Adds a text-only data section and pushes the Y cursor down appropriately
	local function AddDataSection(titleKey, contentString)
		local header_h = 20
		
		-- Add Header
		table.insert(contents, Text { 
			x = data_x, y = data_y, w = data_w, h = header_h, 
			label = "#<b>"..GetString(titleKey).."</b>", 
			font = header_font, flags = kVAlignTop + kHAlignLeft 
		})
		
		-- Estimate Content Height (Approx 28 chars per line at this width/font)
		local chars_per_line = 28
		local text_len = string.len(contentString)
		local num_lines = Floor(text_len / chars_per_line) + 1
		
		local _, br_count = string.gsub(contentString, "<br>", "")
		num_lines = num_lines + br_count
		
		local line_height = 16
		local content_h = num_lines * line_height
		if content_h < 20 then content_h = 20 end
		
		-- Add Content
		table.insert(contents, Text { 
			x = data_x, y = data_y + header_h, w = data_w, h = content_h, 
			label = "#" .. contentString, 
			font = data_font, flags = kVAlignTop + kHAlignLeft 
		})
		
		-- Advance Cursor
		data_y = data_y + header_h + content_h + section_padding
	end

	-- Data Block 1: Category
	AddDataSection("catalogue_category_label", GetString(ing.category))

	-- Data Block 2: Origin 
	-- Uses a custom layout to insert the flag bitmap next to the text
	if ing.origin then
		local header_h = 20
		local content_h = 20
		
		table.insert(contents, Text { 
			x = data_x, y = data_y, w = data_w, h = header_h, 
			label = "#<b>"..GetString("catalogue_origin_label").."</b>", 
			font = header_font, flags = kVAlignTop + kHAlignLeft 
		})

		-- Resolve Localized String (Country -> Region -> Raw)
		local origin_text = GetString("country_" .. ing.origin)
		if origin_text == "#####" then origin_text = GetString("region_" .. ing.origin) end
		if origin_text == "#####" then origin_text = GetString(ing.origin) end

		local content_y = data_y + header_h
		
		-- Add Flag
		table.insert(contents, Bitmap { 
			x = data_x, y = content_y, w = 30, h = 20, 
			image = "image/flags/flag_" .. ing.origin, 
			scale = 0.25 
		})
		
		-- Add Name
		table.insert(contents, Text { 
			x = data_x + 45, y = content_y, w = data_w - 35, h = content_h, 
			label = "#" .. origin_text, 
			font = data_font, flags = kVAlignCenter + kHAlignLeft 
		})

		data_y = data_y + header_h + content_h + section_padding
	end

	-- Data Block 3: Seasonality
	local season_text
	if ing.season_start == 1 and ing.season_end == 52 then
		season_text = GetString("catalogue_season_year_round")
	else
		-- Hide exact dates if undiscovered, unless Dev Reveal is active
		local seasonData = Player.catalogue.discoveredIngredientSeasons[ing.name] or {}
		if gDevForceReveal then seasonData = { start=true, end_=true } end
		
		local start_text = seasonData.start and ConvertWeekToDateString(ing.season_start) or GetString("catalogue_unknown")
		local end_text = seasonData.end_ and ConvertWeekToDateString(ing.season_end) or GetString("catalogue_unknown")
		season_text = GetString("catalogue_season_format", start_text, end_text)
	end
	AddDataSection("catalogue_season_label", season_text)

	-- Data Block 4: Price Range
	local low, high = ing.price_low, ing.price_high
	local low_ns, high_ns = ing.price_low_notinseason, ing.price_high_notinseason
	
	-- Display accuracy based on current save difficulty
	local cost_multiplier = 1.0
	if Player.difficulty == 2 then cost_multiplier = 1.25
	elseif Player.difficulty == 3 then cost_multiplier = 1.50
	end
	
	if cost_multiplier > 1.0 then
		low = Floor(low * cost_multiplier)
		high = Floor(high * cost_multiplier)
		if low_ns then low_ns = Floor(low_ns * cost_multiplier) end
		if high_ns then high_ns = Floor(high_ns * cost_multiplier) end
	end
	
	local price_text = GetString("catalogue_price_format", Dollars(low), Dollars(high))
	if low_ns and (ing.season_start ~= 1 or ing.season_end ~= 52) then
		local out_of_season_price = GetString("catalogue_price_format", Dollars(low_ns), Dollars(high_ns))
		price_text = GetString("catalogue_price_format_seasonal", price_text, out_of_season_price)
	end
	AddDataSection("catalogue_price_label", price_text)
	
	-- Data Block 5: Where to Find
	local locations = {}
	local discoveredLocations = Player.catalogue.discoveredIngredientLocations[ing.name] or {}
	
	for _, port in pairs(_AllPorts) do
		if port.buildings then
			for _, building in ipairs(port.buildings) do
				if building.inventory then
					for _, market_ing in ipairs(building.inventory) do
						if market_ing.name == ing.name then
							if discoveredLocations[port.name] or gDevForceReveal then
								table.insert(locations, GetString(port.name))
							else
								table.insert(locations, GetString("catalogue_unknown"))
							end
							break
						end
					end
				end
			end
		end
	end
	
	local location_str = table.concat(locations, ", ")
	if location_str == "" then location_str = GetString("catalogue_unknown") end
	AddDataSection("catalogue_locations_label", location_str)

	-- Column 2: Description (Right Side - Scrolling Text)
	local rawBody = BuildIngredientArticleText(ing)
	if rawBody == "#####" then rawBody = "Text not found." end

	local current_offset = gCatalogueIngOffsets[gCatalogueIngPage] or 0
	local visibleText = string.sub(rawBody, current_offset + 1)

	if current_offset > 0 then
		local openTags = GetOpenTagsForOffset(rawBody, current_offset)
		visibleText = openTags .. visibleText
		DebugOut("UI", "Carrying active HTML formatting into paged ingredient text.", { ingredient = ing.name, tags = openTags })
	end

	table.insert(contents, Text { 
		x = right_col_x, y = 69, w = right_col_w, h = right_col_h, 
		name = "catalogue_description_text", 
		label = "#" .. visibleText,
		font = { uiFontName, 15, BlackColor }, -- Statically set font size
		flags = kVAlignTop + kHAlignLeft 
	})

	-- Scroll Controls
	local btn_y = 395
	local btn_spacing = 40
	local btn_center_x = right_col_x + (right_col_w / 2) - 36 -- Center over the right column

	table.insert(contents, Button { 
		x = btn_center_x - btn_spacing, y = btn_y, w = 25, h = 25, 
		name = "ing_scrollUp", command = ScrollUp, 
		graphics = {"image/button_arrow_up_up", "image/button_arrow_up_down", "image/button_arrow_up_over"}, 
		scale = 0.8
	})
	
	table.insert(contents, Button { 
		x = btn_center_x + btn_spacing, y = btn_y, w = 25, h = 25, 
		name = "ing_scrollDown", command = ScrollDown, 
		graphics = {"image/button_arrow_down_up", "image/button_arrow_down_down", "image/button_arrow_down_over"}, 
		scale = 0.8
	})

else
	-- STATE 1: LOCKED INGREDIENT VIEW
	DebugOut("UI", string.format("Rendering locked Ingredient detail view: %s", ing.name))
	
	table.insert(contents, BitmapTint { x=35, y=25, image="items/"..ing.name.."_big", tint=Color(0,0,0,255) })
	table.insert(contents, Text { x = 55, y = 25, w = 406, h = 44, label ="#"..GetString("catalogue_locked_title"), font = { labelFontName, 22, BlackColor }, flags = kVAlignCenter + kHAlignCenter })
	
	table.insert(contents, Text { 
		x = 192, y = 69, w = 238, h = 157, 
		name = "catalogue_description_text", 
		label = "#" .. GetString("catalogue_ingredient_locked_desc"),
		font = { uiFontName, 14, BlackColor },
		flags = kVAlignTop + kHAlignLeft 
	})
end

-- Developer override toggle button
if CheckConfig("dev") then
	table.insert(contents, Button { x = 320, y = 0, w = 150, h = 20, label = "#LOCK/UNLOCK", command = ToggleDevView })
end

MakeDialog(contents)

-------------------------------------------------------------------------------
-- Post-Render Button State Updates
-------------------------------------------------------------------------------
if showUnlockedView then
	QueueCommand(function()
		local rawBody = BuildIngredientArticleText(ing)
		local currentOffset = gCatalogueIngOffsets[gCatalogueIngPage] or 0
		local chars_remaining = string.len(rawBody) - currentOffset
		
		local canScrollUp = gCatalogueIngPage > 1
		local canScrollDown = chars_remaining > chars_per_page
		
		EnableWindow("ing_scrollUp", canScrollUp)
		EnableWindow("ing_scrollDown", canScrollDown)
		
		DebugOut("UI", "Ingredient detail scroll controls updated.", { 
			ingredient = ing.name,
			canScrollUp = canScrollUp, 
			canScrollDown = canScrollDown, 
			charsRemaining = chars_remaining 
		})
	end)
end
