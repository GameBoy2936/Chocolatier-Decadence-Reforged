--[[---------------------------------------------------------------------------
	Chocolatier Three: Catalogue Detail - Ingredients
	Copyright (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local ing = gCatalogueSelection

if not ing then
	DebugOut("ERROR", "Catalogue Ingredient Detail initialized without a selected ingredient.")
	return
end

local isUnlocked = Player.catalogue.unlockedIngredients[ing.name]
local showUnlockedView = isUnlocked or gDevForceReveal

local contents = {}

DebugOut("UI", "Initializing Catalogue UI Ingredient Detail panel.", { selection = ing.name, unlocked = showUnlockedView })

-------------------------------------------------------------------------------
-- State Management (Right Column Scrolling)
-------------------------------------------------------------------------------

local ingKey = ing.name
if gCatalogueIngLast ~= ingKey then
	DebugOut("UI", string.format("New ingredient selected (%s). Resetting scroll stack.", tostring(ingKey)))
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
		DebugOut("UI", "Scrolling UP ingredient description.", { newPage = gCatalogueIngPage })
		SoundEvent("cadi/ui_click.ogg")
		FillWindow("catalogue_detail", "ui/catalogue_ingredient_detail.lua")
	end
end

local function ScrollDown()
	if not showUnlockedView then return end
	
	local rawBody = GetString("catalogue_ingredient_" .. ing.name .. "_text")
	if rawBody == "#####" then return end
	
	if gCatalogueIngPage == table.getn(gCatalogueIngOffsets) then
		local current_offset = gCatalogueIngOffsets[gCatalogueIngPage]
		local next_offset = GetNextSafeOffset(rawBody, current_offset, chars_per_scroll)
		table.insert(gCatalogueIngOffsets, next_offset)
		DebugOut("UI", "Calculated safe scroll offset.", { offset = next_offset })
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
	DebugOut("UI", "Building layout: Unlocked Ingredient.", { ingredient = ing.name })
	
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
	local rawBody = GetString("catalogue_ingredient_" .. ing.name .. "_text")
	if rawBody == "#####" then rawBody = "Text not found." end

	local current_offset = gCatalogueIngOffsets[gCatalogueIngPage]
	local visibleText = string.sub(rawBody, current_offset + 1)

	if current_offset > 0 then
		local openTags = GetOpenTagsForOffset(rawBody, current_offset)
		visibleText = openTags .. visibleText
		DebugOut("UI", "Injected persistent formatting tags.", { tags = openTags })
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
	DebugOut("UI", "Building layout: Locked Ingredient Fallback.", { ingredient = ing.name })
	
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
		local rawBody = GetString("catalogue_ingredient_" .. ing.name .. "_text")
		local chars_remaining = string.len(rawBody) - gCatalogueIngOffsets[gCatalogueIngPage]
		
		local canScrollUp = gCatalogueIngPage > 1
		local canScrollDown = chars_remaining > chars_per_page
		
		EnableWindow("ing_scrollUp", canScrollUp)
		EnableWindow("ing_scrollDown", canScrollDown)
		
		DebugOut("UI", "Post-render scroll states evaluated.", { 
			canScrollUp = canScrollUp, 
			canScrollDown = canScrollDown, 
			charsRemaining = chars_remaining 
		})
	end)
end