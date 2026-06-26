--[[---------------------------------------------------------------------------
	Chocolatier Three: Catalogue Detail - Characters
	Copyright (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local char = gCatalogueSelection

if not char then
	DebugOut("ERROR", "Catalogue Character Detail initialized without a selected character.")
	return
end

local charData = Player.catalogue.unlockedCharacters[char.name]
local isMet = charData and charData.met
local isUnlocked = charData and charData.unlocked
local assetInfo = CharacterAssetManifest[char.name] or {}

-- Logic: Evaluate display state based on player progress or dev override
local showUnlockedView = isUnlocked or gDevForceReveal
local showMetView = (isMet and not showUnlockedView)

DebugOut("UI", "Initializing Catalogue UI Character Detail panel.", { 
	selection = char.name, 
	unlocked = showUnlockedView, 
	met = showMetView 
})

-- Asset positioning defaults
local portrait_x = assetInfo.x_detail or assetInfo.x or 10
local portrait_y = assetInfo.y_detail or assetInfo.y or 40
local portrait_w = assetInfo.w_detail or assetInfo.w or 178
local portrait_h = assetInfo.h_detail or assetInfo.h or 254
local portrait_scale = assetInfo.scale_detail or assetInfo.scale or 1.0

local contents = {}

-------------------------------------------------------------------------------
-- State Management (Biography Scrolling)
-------------------------------------------------------------------------------

local charKey = char.name
if gCatalogueCharLast ~= charKey then
	DebugOut("UI", string.format("New character selected (%s). Resetting scroll stack.", tostring(charKey)))
	gCatalogueCharOffsets = { 0 }
	gCatalogueCharPage = 1
	gCatalogueCharLast = charKey
end

-- Fallbacks
gCatalogueCharOffsets = gCatalogueCharOffsets or { 0 }
gCatalogueCharPage = gCatalogueCharPage or 1

-- Font Definitions
local title_font = { labelFontName, 26, BlackColor }
local header_font = { labelFontName, 16, BlackColor }
local data_font = { uiFontName, 14, BlackColor }

-- Layout Constants
local left_col_x = 10
local left_col_w = 170
local right_col_x = 200
local right_col_w = 240

-- Grid Anchors
local data_start_y = portrait_y + 260 
local alignment_y_row2 = data_start_y + 48 -- Anchors "Gender" & "Likes"
local alignment_y_row3 = alignment_y_row2 + 48 -- Anchors "Notes" & "Dislikes"

-- Scrolling Layout Constants
local bio_y = 55
local bio_h = 260 -- Capped so we have ~30px for scroll buttons before alignment_y_row2
local chars_per_scroll = 140
local chars_per_page = 700

-------------------------------------------------------------------------------
-- HTML Tag Parsing & Safe Pagination Utilities
-------------------------------------------------------------------------------

local function GetNextSafeOffset(text, start_offset, advance_chars)
	local target = start_offset + advance_chars
	local text_len = string.len(text)
	if target >= text_len then return text_len end
	
	local in_tag = false
	local i = start_offset + 1
	
	while i <= target do
		local c = string.sub(text, i, i)
		if c == "<" then in_tag = true elseif c == ">" then in_tag = false end
		i = i + 1
	end
	
	while i <= text_len do
		local c = string.sub(text, i, i)
		if c == "<" then
			in_tag = true
			if string.lower(string.sub(text, i, i+3)) == "<br>" then return i + 3 end
		elseif c == ">" then
			in_tag = false
		elseif c == " " and not in_tag then
			return i
		end
		i = i + 1
	end
	return text_len
end

local function GetOpenTagsForOffset(text, offset)
	local in_tag = false
	local current_tag = ""
	local is_closing_tag = false
	local active_format_tags = {}
	
	local i = 1
	while i <= offset do
		local c = string.sub(text, i, i)
		if c == "<" then
			in_tag = true; current_tag = ""; is_closing_tag = (string.sub(text, i + 1, i + 1) == "/")
		elseif c == ">" and in_tag then
			in_tag = false
			if is_closing_tag then
				if table.getn(active_format_tags) > 0 then table.remove(active_format_tags) end
			elseif string.lower(string.sub(current_tag, 1, 2)) ~= "br" then
				table.insert(active_format_tags, "<" .. current_tag .. ">")
			end
		elseif in_tag then
			current_tag = current_tag .. c
		end
		i = i + 1
	end
	
	local prefix = ""
	for j = 1, table.getn(active_format_tags) do prefix = prefix .. active_format_tags[j] end
	return prefix
end

-------------------------------------------------------------------------------
-- Biography Key Resolution
-------------------------------------------------------------------------------
-- Determine which description string to load based on the view state.
local description_key = "catalogue_locked_default_desc"

if showUnlockedView then
	description_key = "catalogue_character_" .. char.name .. "_text"
elseif showMetView then
	description_key = "catalogue_character_met_not_unlocked"
else
	local locked_text_key = "catalogue_character_" .. char.name .. "_locked_text"
	if GetString(locked_text_key) ~= "#####" then
		description_key = locked_text_key
	end
end

-------------------------------------------------------------------------------
-- Scroll Actions
-------------------------------------------------------------------------------

local function ScrollUp()
	if gCatalogueCharPage > 1 then
		gCatalogueCharPage = gCatalogueCharPage - 1
		DebugOut("UI", "Scrolling UP character bio.", { newPage = gCatalogueCharPage })
		SoundEvent("cadi/ui_click.ogg")
		FillWindow("catalogue_detail", "ui/catalogue_character_detail.lua")
	end
end

local function ScrollDown()
	local rawBody = GetString(description_key)
	if rawBody == "#####" then return end
	
	if gCatalogueCharPage == table.getn(gCatalogueCharOffsets) then
		local current_offset = gCatalogueCharOffsets[gCatalogueCharPage]
		local next_offset = GetNextSafeOffset(rawBody, current_offset, chars_per_scroll)
		table.insert(gCatalogueCharOffsets, next_offset)
		DebugOut("UI", "Calculated safe scroll offset.", { offset = next_offset })
	end
	
	gCatalogueCharPage = gCatalogueCharPage + 1
	SoundEvent("cadi/ui_click.ogg")
	FillWindow("catalogue_detail", "ui/catalogue_character_detail.lua")
end

-------------------------------------------------------------------------------
-- Helper Functions (Height Estimation & Preferences)
-------------------------------------------------------------------------------

local function EstimateTextHeight(txt, width, font_size)
	if not txt or txt == "" then return 0 end
	
	local char_width = font_size * 0.45
	local chars_per_line = Floor(width / char_width)
	if chars_per_line < 10 then chars_per_line = 10 end
	local line_height = font_size + 2
	
	local segments = {}
	local pos = 1
	local start_pos, end_pos = string.find(txt, "<br>", pos, true)
	while start_pos do
		table.insert(segments, string.sub(txt, pos, start_pos - 1))
		pos = end_pos + 1
		start_pos, end_pos = string.find(txt, "<br>", pos, true)
	end
	table.insert(segments, string.sub(txt, pos))
	
	local total_lines = 0
	for _, seg in ipairs(segments) do
		local lines = Floor(string.len(seg) / chars_per_line) + 1
		total_lines = total_lines + lines
	end
	return total_lines * line_height
end

local function BuildPreferenceString(masterList, discoveredList)
	if gDevForceReveal then discoveredList = masterList end
	
	if not masterList or table.getn(masterList) == 0 then return GetString("catalogue_none") end
	
	local displayItems = {}
	for _, key in ipairs(masterList) do
		local found = false
		if discoveredList then
			for _, discoveredKey in ipairs(discoveredList) do
				if discoveredKey == key then found = true; break; end
			end
		end
		
		if found then table.insert(displayItems, GetString(key))
		else table.insert(displayItems, GetString("catalogue_unknown"))
		end
	end
	return table.concat(displayItems, ", ")
end

-------------------------------------------------------------------------------
-- Data Preparation
-------------------------------------------------------------------------------
DebugOut("CATALOGUE", "Gathering data fields for character.", { character = char.name })

-- 1. Nationality
local countryKey = char.nationality or "unknown"
local nat_string = GetString("catalogue_unknown")
if showUnlockedView then nat_string = GetString("country_" .. countryKey .. "_adj") end

-- 2. Gender
local genderKey = char.gender or "unknown"
local gender_string = GetString("catalogue_unknown")
if showMetView or showUnlockedView then gender_string = GetString("gender_" .. genderKey) end

-- 3. Notes (Religion + Diet)
local notes_string = GetString("catalogue_unknown")
if showUnlockedView then
	local notes = {}
	if char.religion then
		local religionKey = "culture_" .. char.religion 
		if GetString(religionKey) == "#####" then religionKey = "religion_"..char.religion end 
		table.insert(notes, GetString(religionKey))
	end
	if char.dietaryreqs then
		for req, val in pairs(char.dietaryreqs) do
			if val then table.insert(notes, GetString("diet_" .. req)) end
		end
	end
	notes_string = (table.getn(notes) > 0) and table.concat(notes, ", ") or GetString("catalogue_none")
end

-- 4. Preferences (Likes & Dislikes)
local likes_string = GetString("catalogue_unknown")
local dislikes_string = GetString("catalogue_unknown")

if showMetView or showUnlockedView then
	local master_likes_list = {}
	if char.likes then
		if char.likes.categories then for k,_ in pairs(char.likes.categories) do table.insert(master_likes_list, k) end end
		if char.likes.products then for k,_ in pairs(char.likes.products) do table.insert(master_likes_list, k) end end
		if char.likes.ingredients then for k,_ in pairs(char.likes.ingredients) do table.insert(master_likes_list, k) end end
	end
	table.sort(master_likes_list)
	
	local master_dislikes_list = {}
	if char.dislikes then
		if char.dislikes.categories then for k,_ in pairs(char.dislikes.categories) do table.insert(master_dislikes_list, k) end end
		if char.dislikes.products then for k,_ in pairs(char.dislikes.products) do table.insert(master_dislikes_list, k) end end
		if char.dislikes.ingredients then for k,_ in pairs(char.dislikes.ingredients) do table.insert(master_dislikes_list, k) end end
	end
	table.sort(master_dislikes_list)
	
	likes_string = BuildPreferenceString(master_likes_list, charData and charData.discovered_likes or {})
	dislikes_string = BuildPreferenceString(master_dislikes_list, charData and charData.discovered_dislikes or {})
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

-- 1. TITLE (Top Center)
local titleLabel = (showMetView or showUnlockedView) and GetString(char.name) or GetString("catalogue_locked_title")
table.insert(contents, Text { x = 24, y = 10, w = 406, h = 40, label = "#" .. titleLabel, font = title_font, flags = kVAlignCenter + kHAlignCenter })

-- 2. PORTRAIT (Left Column)
if showMetView or showUnlockedView then
	table.insert(contents, CharWindow { x = portrait_x, y = portrait_y, w = portrait_w, h = portrait_h, name = char.name, scale = portrait_scale })
else
	local silhouetteDisplay
	if assetInfo and assetInfo.silhouette then
		silhouetteDisplay = CharWindow { x = portrait_x - 10, y = portrait_y - 22, w = portrait_w, h = portrait_h, name = char.name .. ".silhouette" }
	elseif assetInfo and assetInfo.mask then
		silhouetteDisplay = BitmapTint { x = portrait_x, y = portrait_y, w = portrait_w, h = portrait_h, image = "characters/" .. char.name .. ".jpg", mask = "characters/" .. char.name .. ".mask.png", tint = Color(0, 0, 0, 255) }
	elseif assetInfo and assetInfo.png then
		silhouetteDisplay = BitmapTint { image = "characters/" .. char.name .. ".png", tint = Color(0, 0, 0, 255) }
	end
	if silhouetteDisplay then
		table.insert(contents, Window { 
			x = portrait_x, y = portrait_y, w = portrait_w, h = portrait_h, 
			scale = portrait_scale, silhouetteDisplay, 
			Bitmap { x = 0, y = 0, image = "image/catalogue_portrait_mask.png" } 
		})
	end
end

-- 3. BIO (Right Column Top - Scrolling)
local rawBody = GetString(description_key)
if rawBody == "#####" then rawBody = "Text not found." end

local current_offset = gCatalogueCharOffsets[gCatalogueCharPage]
local visibleText = string.sub(rawBody, current_offset + 1)

if current_offset > 0 then
	local openTags = GetOpenTagsForOffset(rawBody, current_offset)
	visibleText = openTags .. visibleText
	DebugOut("UI", "Injected persistent formatting tags.", { tags = openTags })
end

table.insert(contents, Text { 
	x = right_col_x, y = bio_y, w = right_col_w, h = bio_h, 
	name = "catalogue_description_text", 
	label = "#" .. visibleText,
	font = { uiFontName, 14, BlackColor },
	flags=kVAlignTop+kHAlignLeft 
})

-- 3b. BIO SCROLL CONTROLS (Positioned below the bio, above the Right Column Data Grid)
local btn_y = bio_y + bio_h
local btn_spacing = 30
local btn_center_x = right_col_x + (right_col_w / 2) 

table.insert(contents, Button { 
	x = btn_center_x - btn_spacing, y = btn_y, w = 25, h = 25, 
	name = "char_scrollUp", command = ScrollUp, 
	graphics = {"image/button_arrow_up_up", "image/button_arrow_up_down", "image/button_arrow_up_over"}, 
	scale = 0.8
})

table.insert(contents, Button { 
	x = btn_center_x + btn_spacing, y = btn_y, w = 25, h = 25, 
	name = "char_scrollDown", command = ScrollDown, 
	graphics = {"image/button_arrow_down_up", "image/button_arrow_down_down", "image/button_arrow_down_over"}, 
	scale = 0.8
})

-- 4. DATA GRID (Bottom Area)
local cur_left_y
local cur_right_y

-- ROW 1: NATIONALITY
cur_left_y = data_start_y

table.insert(contents, Text { x = left_col_x + 10, y = cur_left_y, w = left_col_w, h = 18, label = "#<b>"..GetString("catalogue_nationality").."</b>", font = header_font, flags = kVAlignTop + kHAlignLeft })
cur_left_y = cur_left_y + 18

if showUnlockedView then
	table.insert(contents, Bitmap { x = left_col_x + 10, y = cur_left_y, w = 30, h = 20, image = "image/flags/flag_" .. countryKey, scale = 0.25 })
	table.insert(contents, Text { x = left_col_x + 55, y = cur_left_y, w = left_col_w - 45, h = 20, label = "#" .. nat_string, font = data_font, flags = kVAlignCenter + kHAlignLeft })
else
	table.insert(contents, Text { x = left_col_x + 10, y = cur_left_y, w = left_col_w, h = 20, label = "#" .. nat_string, font = data_font, flags = kVAlignCenter + kHAlignLeft })
end

-- ROW 2: GENDER & LIKES
cur_left_y = alignment_y_row2
cur_right_y = alignment_y_row2 - 20

-- Gender (Left)
table.insert(contents, Text { x = left_col_x + 10, y = cur_left_y, w = left_col_w, h = 18, label = "#<b>"..GetString("catalogue_gender").."</b>", font = header_font, flags = kVAlignTop + kHAlignLeft })
cur_left_y = cur_left_y + 18
table.insert(contents, Text { x = left_col_x + 10, y = cur_left_y, w = left_col_w, h = 16, label = "#" .. gender_string, font = data_font, flags = kVAlignTop + kHAlignLeft })

-- Likes (Right)
local likes_h = EstimateTextHeight(likes_string, right_col_w, 14) + 5
table.insert(contents, Text { x = right_col_x, y = cur_right_y, w = right_col_w, h = 20, label = "#<b>"..GetString("catalogue_likes").."</b>", font = header_font, flags = kVAlignTop + kHAlignLeft })
cur_right_y = cur_right_y + 20
table.insert(contents, Text { x = right_col_x, y = cur_right_y, w = right_col_w, h = likes_h, label = "#" .. likes_string, font = data_font, flags = kVAlignTop + kHAlignLeft })

-- ROW 3: NOTES & DISLIKES
cur_left_y = alignment_y_row3
cur_right_y = alignment_y_row3

-- Notes (Left)
local notes_h = EstimateTextHeight(notes_string, left_col_w, 14) + 5
table.insert(contents, Text { x = left_col_x + 10, y = cur_left_y, w = left_col_w, h = 18, label = "#<b>"..GetString("catalogue_notes").."</b>", font = header_font, flags = kVAlignTop + kHAlignLeft })
cur_left_y = cur_left_y + 18
table.insert(contents, Text { x = left_col_x + 10, y = cur_left_y, w = left_col_w, h = notes_h, label = "#" .. notes_string, font = data_font, flags = kVAlignTop + kHAlignLeft })

-- Dislikes (Right)
local dislikes_h = EstimateTextHeight(dislikes_string, right_col_w, 14) + 5
table.insert(contents, Text { x = right_col_x, y = cur_right_y, w = right_col_w, h = 20, label = "#<b>"..GetString("catalogue_dislikes").."</b>", font = header_font, flags = kVAlignTop + kHAlignLeft })
cur_right_y = cur_right_y + 20
-- Updated font to data_font (size 14)
table.insert(contents, Text { x = right_col_x, y = cur_right_y, w = right_col_w, h = dislikes_h, label = "#" .. dislikes_string, font = data_font, flags = kVAlignTop + kHAlignLeft })

-------------------------------------------------------------------------------
-- Finalize
-------------------------------------------------------------------------------

if CheckConfig("dev") then
	table.insert(contents, Button { x = 320, y = 0, w = 150, h = 20, label = "#LOCK/UNLOCK", command = ToggleDevView })
end

MakeDialog(contents)

-------------------------------------------------------------------------------
-- Post-Render Scroll State Update
-------------------------------------------------------------------------------
QueueCommand(function()
	local rawString = GetString(description_key)
	local chars_remaining = string.len(rawString) - gCatalogueCharOffsets[gCatalogueCharPage]
	
	local canScrollUp = gCatalogueCharPage > 1
	local canScrollDown = chars_remaining > chars_per_page
	
	EnableWindow("char_scrollUp", canScrollUp)
	EnableWindow("char_scrollDown", canScrollDown)
	
	DebugOut("UI", "Post-render scroll states evaluated.", { 
		canScrollUp = canScrollUp, 
		canScrollDown = canScrollDown, 
		charsRemaining = chars_remaining 
	})
end)