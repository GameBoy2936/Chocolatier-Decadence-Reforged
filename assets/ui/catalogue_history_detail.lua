--[[---------------------------------------------------------------------------
	Chocolatier Three: Catalogue UI (History Detail Panel)
	Copyright (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local articleKey = gCatalogueSelection
local contents = {}

DebugOut("UI", "Initializing Catalogue UI History Detail panel.", { selection = articleKey })

local isUnlocked = false
if articleKey then
	isUnlocked = Player.catalogue.unlockedHistory[articleKey] or gDevForceReveal
	DebugOut("CATALOGUE", "Article lock state evaluated.", { article = articleKey, unlocked = isUnlocked })
end

-------------------------------------------------------------------------------
-- State Management
-------------------------------------------------------------------------------
if gCatalogueHistoryLastArticle ~= articleKey then
	DebugOut("UI", string.format("New article selected (%s). Resetting offset stack.", tostring(articleKey)))
	gCatalogueHistoryOffsets = { 0 }
	gCatalogueHistoryPage = 1
	gCatalogueHistoryLastArticle = articleKey
end

gCatalogueHistoryOffsets = gCatalogueHistoryOffsets or { 0 }
gCatalogueHistoryPage = gCatalogueHistoryPage or 1

local view_w = 406
local view_h = 330 
local chars_per_scroll = 150
local chars_per_page = 900 

-------------------------------------------------------------------------------
-- HTML Tag Parsing & Safe Pagination Utilities
-------------------------------------------------------------------------------

-- Calculates the next safe string index to break at, avoiding cutting tags in half.
local function GetNextSafeOffset(text, start_offset, advance_chars)
	local target = start_offset + advance_chars
	local text_len = string.len(text)
	if target >= text_len then return text_len end
	
	local in_tag = false
	local i = start_offset + 1
	
	-- Fast-forward to our target minimum length
	while i <= target do
		local char = string.sub(text, i, i)
		if char == "<" then in_tag = true
		elseif char == ">" then in_tag = false
		end
		i = i + 1
	end
	
	-- Scan forward from target to find the next space or <br> completely outside of any tag
	while i <= text_len do
		local char = string.sub(text, i, i)
		
		if char == "<" then
			in_tag = true
			if string.lower(string.sub(text, i, i+3)) == "<br>" then
				-- Safe to break immediately after the full <br>
				return i + 3
			end
		elseif char == ">" then
			in_tag = false
		elseif char == " " and not in_tag then
			-- Safe to break immediately after a space
			return i
		end
		
		i = i + 1
	end
	
	return text_len
end

-- Scans from the beginning of the text to the current offset, returning a string 
-- of all currently open formatting tags so they can be prepended to the new page.
local function GetOpenTagsForOffset(text, offset)
	local in_tag = false
	local current_tag = ""
	local is_closing_tag = false
	local active_format_tags = {}
	
	local i = 1
	while i <= offset do
		local char = string.sub(text, i, i)
		
		if char == "<" then
			in_tag = true
			current_tag = ""
			is_closing_tag = (string.sub(text, i + 1, i + 1) == "/")
		elseif char == ">" and in_tag then
			in_tag = false
			if is_closing_tag then
				-- Pop the last tag (assumes valid HTML pairing)
				if table.getn(active_format_tags) > 0 then
					table.remove(active_format_tags)
				end
			elseif string.lower(string.sub(current_tag, 1, 2)) ~= "br" then
				-- Push opening formatting tags (ignore <br> as it is self-closing)
				table.insert(active_format_tags, "<" .. current_tag .. ">")
			end
		elseif in_tag then
			current_tag = current_tag .. char
		end
		i = i + 1
	end
	
	-- Concatenate all open tags to inject at the start of the next page
	local prefix = ""
	for j = 1, table.getn(active_format_tags) do
		prefix = prefix .. active_format_tags[j]
	end
	
	return prefix
end

-------------------------------------------------------------------------------
-- Scroll Actions
-------------------------------------------------------------------------------

local function ScrollUp()
	if gCatalogueHistoryPage > 1 then
		gCatalogueHistoryPage = gCatalogueHistoryPage - 1
		DebugOut("UI", "Scrolling UP history detail.", { newPage = gCatalogueHistoryPage })
		SoundEvent("cadi/ui_click.ogg")
		FillWindow("catalogue_detail", "ui/catalogue_history_detail.lua")
	end
end

local function ScrollDown()
	if not isUnlocked then return end
	
	local rawBody = GetString(articleKey .. "_text")
	if rawBody == "#####" then return end
	
	-- Calculate and cache the next safe offset using our new HTML-aware utility
	if gCatalogueHistoryPage == table.getn(gCatalogueHistoryOffsets) then
		local current_offset = gCatalogueHistoryOffsets[gCatalogueHistoryPage]
		local next_offset = GetNextSafeOffset(rawBody, current_offset, chars_per_scroll)
		
		table.insert(gCatalogueHistoryOffsets, next_offset)
		DebugOut("UI", "Calculated safe scroll offset.", { offset = next_offset })
	end
	
	gCatalogueHistoryPage = gCatalogueHistoryPage + 1
	SoundEvent("cadi/ui_click.ogg")
	FillWindow("catalogue_detail", "ui/catalogue_history_detail.lua")
end

-------------------------------------------------------------------------------
-- Main View Logic
-------------------------------------------------------------------------------

if articleKey then
	if isUnlocked then
		local articleTitle = GetString(articleKey .. "_title")
		local rawBody = GetString(articleKey .. "_text")
		
		if rawBody == "#####" then 
			rawBody = "Text not found." 
			DebugOut("ERROR", "Missing localization string.", { key = articleKey .. "_text" })
		end
		
		local current_offset = gCatalogueHistoryOffsets[gCatalogueHistoryPage]
		local visibleText = string.sub(rawBody, current_offset + 1)
		
		-- Inject formatting persistence so bolding/colors don't break on new pages
		if current_offset > 0 then
			local openTags = GetOpenTagsForOffset(rawBody, current_offset)
			visibleText = openTags .. visibleText
			DebugOut("UI", "Injected persistent formatting tags.", { tags = openTags })
		end

		table.insert(contents, Text { 
			x = 24, y = 19, w = 406, h = 44, 
			label = "#" .. articleTitle, 
			font = { labelFontName, 22, BlackColor }, 
			flags = kVAlignCenter + kHAlignCenter 
		})

		table.insert(contents, Text { 
			x = 24, y = 70, w = view_w, h = view_h, 
			name = "history_body_text", 
			label = "#" .. visibleText, 
			font = { uiFontName, 16, BlackColor }, 
			flags = kVAlignTop + kHAlignLeft 
		})

		local btn_y = 400
		table.insert(contents, Button { 
			x = 150, y = btn_y, w = 25, h = 25, name = "hist_scrollUp", command = ScrollUp, 
			graphics = {"image/button_arrow_up_up", "image/button_arrow_up_down", "image/button_arrow_up_over"}, 
			scale = 0.8
		})
		
		table.insert(contents, Button { 
			x = 225, y = btn_y, w = 25, h = 25, name = "hist_scrollDown", command = ScrollDown, 
			graphics = {"image/button_arrow_down_up", "image/button_arrow_down_down", "image/button_arrow_down_over"}, 
			scale = 0.8
		})
	else
		table.insert(contents, Text { 
			x = 24, y = 19, w = 406, h = 44, 
			label = "#" .. GetString("catalogue_locked_title"), 
			font = { labelFontName, 26, BlackColor }, 
			flags = kVAlignCenter + kHAlignCenter 
		})
		table.insert(contents, Text { 
			x = 24, y = 70, w = view_w, h = view_h, 
			label = "#" .. GetString("catalogue_locked_default_desc"), 
			font = { uiFontName, 16, BlackColor }, 
			flags = kVAlignTop + kHAlignLeft 
		})
	end
else
	table.insert(contents, Text { x = 0, y = 0, w = kMax, h = kMax, label ="#"..GetString("catalogue_no_selection"), flags = kVAlignCenter + kHAlignCenter })
end

MakeDialog(contents)

-------------------------------------------------------------------------------
-- Post-Render Button State Updates
-------------------------------------------------------------------------------
if articleKey and isUnlocked then
	QueueCommand(function()
		local rawBody = GetString(articleKey .. "_text")
		local chars_remaining = string.len(rawBody) - gCatalogueHistoryOffsets[gCatalogueHistoryPage]
		
		EnableWindow("hist_scrollUp", gCatalogueHistoryPage > 1)
		EnableWindow("hist_scrollDown", chars_remaining > chars_per_page)
	end)
end