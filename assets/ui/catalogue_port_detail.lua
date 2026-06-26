--[[---------------------------------------------------------------------------
	Chocolatier Three: Catalogue Detail - Ports
	Copyright (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local port = gCatalogueSelection

if not port then
	DebugOut("ERROR", "Catalogue Port Detail initialized without a selected port.")
	return
end

local isUnlocked = Player.catalogue.unlockedPorts[port.name]
local showUnlockedView = isUnlocked or gDevForceReveal
local contents = {}

DebugOut("UI", "Initializing Catalogue UI Ports Detail panel.", { selection = port.name, unlocked = showUnlockedView })

-------------------------------------------------------------------------------
-- State Management (Right Column Scrolling)
-------------------------------------------------------------------------------

local portKey = port.name
if gCataloguePortLast ~= portKey then
	DebugOut("UI", string.format("New port selected (%s). Resetting scroll stack.", tostring(portKey)))
	gCataloguePortOffsets = { 0 }
	gCataloguePortPage = 1
	gCataloguePortLast = portKey
end

gCataloguePortOffsets = gCataloguePortOffsets or { 0 }
gCataloguePortPage = gCataloguePortPage or 1

-- Scrolling Constants (Tuned for the narrower right column)
local right_col_x = 210
local right_col_w = 230
local right_col_h = 340      -- Reduced from 420 to accommodate bottom scroll buttons
local chars_per_scroll = 130 -- Slightly less than History due to narrower column
local chars_per_page = 750 

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
	if gCataloguePortPage > 1 then
		gCataloguePortPage = gCataloguePortPage - 1
		DebugOut("UI", "Scrolling UP port description.", { newPage = gCataloguePortPage })
		SoundEvent("cadi/ui_click.ogg")
		
		-- FIX: Ensure this perfectly matches your actual .lua file name
		FillWindow("catalogue_detail", "ui/catalogue_port_detail.lua") 
	end
end

local function ScrollDown()
	if not showUnlockedView then return end
	
	local rawBody = GetString("catalogue_port_" .. port.name .. "_text")
	if rawBody == "#####" then return end
	
	if gCataloguePortPage == table.getn(gCataloguePortOffsets) then
		local current_offset = gCataloguePortOffsets[gCataloguePortPage]
		local next_offset = GetNextSafeOffset(rawBody, current_offset, chars_per_scroll)
		table.insert(gCataloguePortOffsets, next_offset)
		DebugOut("UI", "Calculated safe scroll offset.", { offset = next_offset })
	end
	
	gCataloguePortPage = gCataloguePortPage + 1
	SoundEvent("cadi/ui_click.ogg")
	
	-- FIX: Ensure this perfectly matches your actual .lua file name
	FillWindow("catalogue_detail", "ui/catalogue_port_detail.lua") 
end

-------------------------------------------------------------------------------
-- Helper: Gather Port Data
-------------------------------------------------------------------------------
local function GatherPortData(port)
	DebugOut("CATALOGUE", "Gathering local data for port.", { port = port.name })
	local data = { buildings = {}, ingredients = {}, characters = {} }
	local ing_seen = {}
	local char_seen = {}
	local bldg_seen = {}

	if port.buildings then
		for _, building in ipairs(port.buildings) do
			
			-- 1. Buildings
			if building.type ~= "special" and not bldg_seen[building.name] then
				if gDevForceReveal or Player.buildingsVisited[building.name] then
					table.insert(data.buildings, building)
					bldg_seen[building.name] = true
				end
			end

			-- 2. Ingredients
			if building.inventory and (building.type == "market" or building.type == "farm") then
				for _, ing in ipairs(building.inventory) do
					if not ing_seen[ing.name] then
						local locs = Player.catalogue.discoveredIngredientLocations[ing.name]
						if gDevForceReveal or (locs and locs[port.name]) then
							table.insert(data.ingredients, ing)
							ing_seen[ing.name] = true
						end
					end
				end
			end

			-- 3. Characters
			local charList = building:GetCharacterList()
			if charList then
				for _, char in ipairs(charList) do
					if not char_seen[char.name] then
						local isEmptyChar = false
						if _EmptyCharacters then
							for _, emptyName in ipairs(_EmptyCharacters) do
								if char.name == emptyName then isEmptyChar = true; break; end
							end
						end

						if not isEmptyChar then
							local charData = Player.catalogue.unlockedCharacters[char.name]
							if gDevForceReveal or (charData and charData.met) then
								table.insert(data.characters, char)
								char_seen[char.name] = true
							end
						end
					end
				end
			end
		end
	end
	
	table.sort(data.buildings, function(a,b) return GetString(a.name) < GetString(b.name) end)
	table.sort(data.ingredients, function(a,b) return a.name < b.name end)
	table.sort(data.characters, function(a,b) return a.name < b.name end)
	
	return data
end

-- Determine which holidays a port celebrates based on its culture tag.
local function GetCelebratedHolidays(port)
	local culture = port.culture or "western"
	local portName = port.name
	local holidays = {}

	if culture == "muslim" then table.insert(holidays, "ramadan"); table.insert(holidays, "eid_ul_fitr") end
	if culture == "east_asian" or portName == "sanfrancisco" then table.insert(holidays, "lunar_new_year") end
	if culture == "hindu" then table.insert(holidays, "diwali") end
	if culture == "latin" then table.insert(holidays, "carnival") end
	if culture == "north_american" then table.insert(holidays, "thanksgiving") end
	if culture ~= "muslim" and culture ~= "east_asian" and culture ~= "hindu" then
		table.insert(holidays, "christmas"); table.insert(holidays, "easter")
	end
	if culture == "western" or culture == "north_american" or culture == "european" or culture == "latin" then
		table.insert(holidays, "lent")
	end

	table.insert(holidays, "valentine")
	table.insert(holidays, "halloween")

	return holidays
end

-------------------------------------------------------------------------------
-- View Construction
-------------------------------------------------------------------------------

if showUnlockedView then
	-- STATE 2: UNLOCKED PORT VIEW
	DebugOut("UI", "Building layout: Unlocked Port.", { port = port.name })
	
	-- 1. OVERLAY IMAGE
	local overlay_x_offset = -462
	local overlay_y_offset = -488 
	table.insert(contents, Bitmap { x = overlay_x_offset, y = overlay_y_offset, w = 457, h = 480, image = "image/catalogue_overlay_ports_" .. port.name .. ".png" })
	
	-- 2. TITLE
	table.insert(contents, Text { x = 24, y = 10, w = 406, h = 40, label = "#" .. GetString(port.name), font = { labelFontName, 28, BlackColor }, flags = kVAlignCenter + kHAlignCenter })
	
	-- 3. LEFT COLUMN: PASSPORT DATA
	local left_col_x = 14
	local left_col_w = 194
	local sub_header_font = { labelFontName, 16, BlackColor }
	local info_font = { uiFontName, 13, BlackColor }
	local info_font2 = { uiFontName, 12, BlackColor }
	local tiny_font = { uiFontName, 12, BlackColor }
	local passport_y = 50
	
	local countryKey = port.country or "unknown"
	table.insert(contents, Bitmap { x = left_col_x, y = passport_y, w = 40, h = 25, image = "image/flags/flag_" .. countryKey, scale = 0.3, flags = kVAlignCenter + kHAlignCenter })
	
	local locationStr = GetString("country_" .. countryKey)
	if port.region then locationStr = locationStr .. "<br>" .. GetString("region_" .. port.region) end
	table.insert(contents, Text { x = left_col_x + 55, y = passport_y, w = 125, h = 40, label = "#" .. locationStr, font = info_font, flags = kVAlignTop + kHAlignLeft })
	
	passport_y = passport_y + 35
	
	local hemiStr = GetString("hemisphere_" .. (port.hemisphere or "north"))
	local cultStr = GetString("culture_" .. (port.culture or "western"))
	table.insert(contents, Text { x = left_col_x, y = passport_y, w = 200, h = 30, label = "#" .. hemiStr .. " / " .. cultStr, font = info_font2, flags = kVAlignTop + kHAlignLeft })
	
	passport_y = passport_y + 20
	
	-- 4. LEFT COLUMN LOWER: DATA TABLES
	local portData = GatherPortData(port)
	local data_y = passport_y
	local sub_col_w = Floor(left_col_w / 2)
	local row_height = 12
	
	-- Holidays
	local holidays = GetCelebratedHolidays(port)
	if table.getn(holidays) > 0 then
		table.insert(contents, Text { x = left_col_x, y = data_y, w = left_col_w, h = 20, label = "#<b>" .. GetString("catalogue_holidays_label") .. "</b>", font = sub_header_font, flags = kVAlignTop + kHAlignLeft })
		data_y = data_y + 20
		
		local h_names = {}
		for _, h_key in ipairs(holidays) do table.insert(h_names, GetString("holiday_" .. h_key)) end
		local holidayStr = table.concat(h_names, ", ")
		
		local est_height = 30
		if string.len(holidayStr) > 30 then est_height = 30 end
		
		table.insert(contents, Text { x = left_col_x, y = data_y, w = left_col_w, h = est_height, label = "#" .. holidayStr, font = info_font, flags = kVAlignTop + kHAlignLeft })
		data_y = data_y + est_height + 10
	end
	
	-- Buildings
	if table.getn(portData.buildings) > 0 then
		table.insert(contents, Text { x = left_col_x, y = data_y, w = left_col_w, h = 20, label = "#<b>" .. GetString("catalogue_buildings_label") .. "</b>", font = sub_header_font, flags = kVAlignTop + kHAlignLeft })
		data_y = data_y + 20
		
		for i, bldg in ipairs(portData.buildings) do
			local col_offset = Mod(i-1, 2) * sub_col_w
			local row_offset = Floor((i-1)/2) * row_height
			table.insert(contents, Text { x = left_col_x + col_offset, y = data_y + row_offset, w = sub_col_w - 2, h = row_height, label = "#" .. GetString(bldg.name), font = tiny_font, flags = kVAlignTop + kHAlignLeft })
		end
		data_y = data_y + (Floor((table.getn(portData.buildings) + 1) / 2) * row_height) + 10
	end
	
	-- Ingredients
	if table.getn(portData.ingredients) > 0 then
		table.insert(contents, Text { x = left_col_x, y = data_y, w = left_col_w, h = 20, label = "#<b>" .. GetString("catalogue_ingredients_label") .. "</b>", font = sub_header_font, flags = kVAlignTop + kHAlignLeft })
		data_y = data_y + 20
		
		for i, ing in ipairs(portData.ingredients) do
			local col_offset = Mod(i-1, 2) * sub_col_w
			local row_offset = Floor((i-1)/2) * row_height
			table.insert(contents, Text { x = left_col_x + col_offset, y = data_y + row_offset, w = sub_col_w - 2, h = row_height, label = "#" .. GetString(ing.name), font = tiny_font, flags = kVAlignTop + kHAlignLeft })
		end
		data_y = data_y + (Floor((table.getn(portData.ingredients) + 1) / 2) * row_height) + 10
	end

	-- Residents
	if table.getn(portData.characters) > 0 then
		table.insert(contents, Text { x = left_col_x, y = data_y, w = left_col_w, h = 20, label = "#<b>" .. GetString("catalogue_residents_label") .. "</b>", font = sub_header_font, flags = kVAlignTop + kHAlignLeft })
		data_y = data_y + 20
		
		for i, char in ipairs(portData.characters) do
			local col_offset = Mod(i-1, 2) * sub_col_w
			local row_offset = Floor((i-1)/2) * row_height
			table.insert(contents, Text { x = left_col_x + col_offset, y = data_y + row_offset, w = sub_col_w - 2, h = row_height, label = "#" .. GetString(char.name), font = tiny_font, flags = kVAlignTop + kHAlignLeft })
		end
	end

	-- 5. RIGHT COLUMN: DESCRIPTION (Scrolling Text)
	local rawBody = GetString("catalogue_port_" .. port.name .. "_text")
	if rawBody == "#####" then rawBody = "Text not found." end

	local current_offset = gCataloguePortOffsets[gCataloguePortPage]
	local visibleText = string.sub(rawBody, current_offset + 1)

	if current_offset > 0 then
		local openTags = GetOpenTagsForOffset(rawBody, current_offset)
		visibleText = openTags .. visibleText
		DebugOut("UI", "Injected persistent formatting tags.", { tags = openTags })
	end

	table.insert(contents, Text { 
		x = right_col_x, y = 55, w = right_col_w, h = right_col_h, 
		name = "catalogue_description_text", 
		label = "#" .. visibleText,
		font = { uiFontName, 15, BlackColor }, -- Statically set font size
		flags = kVAlignTop + kHAlignLeft 
	})
	
	-- 6. SCROLL CONTROLS
	local btn_y = 395
	local btn_spacing = 40
	local btn_center_x = right_col_x + (right_col_w / 2) - 36 -- Center over the right column

	table.insert(contents, Button { 
		x = btn_center_x - btn_spacing, y = btn_y, w = 25, h = 25, 
		name = "port_scrollUp", command = ScrollUp, 
		graphics = {"image/button_arrow_up_up", "image/button_arrow_up_down", "image/button_arrow_up_over"}, 
		scale = 0.8
	})
	
	table.insert(contents, Button { 
		x = btn_center_x + btn_spacing, y = btn_y, w = 25, h = 25, 
		name = "port_scrollDown", command = ScrollDown, 
		graphics = {"image/button_arrow_down_up", "image/button_arrow_down_down", "image/button_arrow_down_over"}, 
		scale = 0.8
	})

else
	-- STATE 1: LOCKED PORT VIEW
	DebugOut("UI", "Building layout: Locked Port Fallback.", { port = port.name })
	table.insert(contents, Text { x = 24, y = 19, w = 406, h = 44, label ="#"..GetString("catalogue_locked_title"), font = { labelFontName, 22, BlackColor }, flags = kVAlignCenter + kHAlignCenter })
	
	table.insert(contents, Text { 
		x = 192, y = 69, w = 238, h = 157, 
		name = "catalogue_description_text", 
		label = "#" .. GetString("catalogue_locked_default_desc"),
		font = { uiFontName, 14, BlackColor },
		flags = kVAlignTop + kHAlignLeft 
	})
end

-- Add the developer toggle button if dev mode is active
if CheckConfig("dev") then
	table.insert(contents, Button { x = 320, y = 0, w = 150, h = 20, label = "#LOCK/UNLOCK", command = ToggleDevView })
end

MakeDialog(contents)

-------------------------------------------------------------------------------
-- Post-Render Button State Updates
-------------------------------------------------------------------------------
if showUnlockedView then
	QueueCommand(function()
		local rawBody = GetString("catalogue_port_" .. port.name .. "_text")
		local chars_remaining = string.len(rawBody) - gCataloguePortOffsets[gCataloguePortPage]
		
		local canScrollUp = gCataloguePortPage > 1
		local canScrollDown = chars_remaining > chars_per_page
		
		EnableWindow("port_scrollUp", canScrollUp)
		EnableWindow("port_scrollDown", canScrollDown)
		
		DebugOut("UI", "Post-render scroll states evaluated.", { 
			canScrollUp = canScrollUp, 
			canScrollDown = canScrollDown, 
			charsRemaining = chars_remaining 
		})
	end)
end