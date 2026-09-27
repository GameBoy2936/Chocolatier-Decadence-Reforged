--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Catalogue UI (History Detail Panel))
	Copyright (c) 2026 Michael Lane.
--]]---------------------------------------------------------------------------

local articleKey = gCatalogueSelection
local contents = {}
local historyDocuments = require("ui/catalogue_history_documents")
local articleDocument = articleKey and historyDocuments[articleKey] or nil

DebugOut("UI", "Initializing Catalogue UI History Detail panel.", { selection = articleKey })

local function Localized(id, fallback)
	local value = GetString(id)
	if value == "#####" then return fallback end
	return value
end

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

local function GetNextSafeOffset(text, start_offset, advance_chars)
	local target = start_offset + advance_chars
	local text_len = string.len(text)
	if target >= text_len then return text_len end

	local in_tag = false
	local i = start_offset + 1

	while i <= target do
		local char = string.sub(text, i, i)
		if char == "<" then in_tag = true
		elseif char == ">" then in_tag = false
		end
		i = i + 1
	end

	while i <= text_len do
		local char = string.sub(text, i, i)

		if char == "<" then
			in_tag = true
			if string.lower(string.sub(text, i, i + 3)) == "<br>" then
				return i + 3
			end
		elseif char == ">" then
			in_tag = false
		elseif char == " " and not in_tag then
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
		local char = string.sub(text, i, i)

		if char == "<" then
			in_tag = true
			current_tag = ""
			is_closing_tag = (string.sub(text, i + 1, i + 1) == "/")
		elseif char == ">" and in_tag then
			in_tag = false
			if is_closing_tag then
				if table.getn(active_format_tags) > 0 then
					table.remove(active_format_tags)
				end
			elseif string.lower(string.sub(current_tag, 1, 2)) ~= "br" then
				table.insert(active_format_tags, "<" .. current_tag .. ">")
			end
		elseif in_tag then
			current_tag = current_tag .. char
		end
		i = i + 1
	end

	local prefix = ""
	for j = 1, table.getn(active_format_tags) do
		prefix = prefix .. active_format_tags[j]
	end

	return prefix
end

-------------------------------------------------------------------------------
-- Scroll / document actions
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

local function OpenDocumentViewer()
	if not articleDocument then return end
	SoundEvent("cadi/ui_click.ogg")
	local selectedKey = articleKey
	QueueCommand(function()
		DisplayDialog {
			"ui/catalogue_history_document.lua",
			articleKey = selectedKey,
		}
	end)
end

-------------------------------------------------------------------------------
-- Main View Logic
-------------------------------------------------------------------------------

if articleKey then
	if isUnlocked then
		local articleTitle = GetString(articleKey .. "_title")
		if articleTitle == "#####" then articleTitle = articleKey end

		table.insert(contents, Text {
			x = 24, y = 19, w = 406, h = 44,
			label = "#" .. articleTitle,
			font = { labelFontName, 22, BlackColor },
			flags = kVAlignCenter + kHAlignCenter,
		})

		-- Physical documents keep their localized transcript visible at all times.
		-- The facsimile is an optional overlay, never a replacement for the text.
		local rawBody = GetString(articleKey .. "_text")

		if rawBody == "#####" then
			rawBody = "Text not found."
			DebugOut("ERROR", "Missing localization string.", { key = articleKey .. "_text" })
		end

		local current_offset = gCatalogueHistoryOffsets[gCatalogueHistoryPage]
		local visibleText = string.sub(rawBody, current_offset + 1)

		if current_offset > 0 then
			local openTags = GetOpenTagsForOffset(rawBody, current_offset)
			visibleText = openTags .. visibleText
			DebugOut("UI", "Injected persistent formatting tags.", { tags = openTags })
		end

		table.insert(contents, Text {
			x = 24, y = 70, w = view_w, h = view_h,
			name = "history_body_text",
			label = "#" .. visibleText,
			font = { uiFontName, 16, BlackColor },
			flags = kVAlignTop + kHAlignLeft,
		})

		local btn_y = 400
		table.insert(contents, Button {
			x = 135, y = btn_y, w = 25, h = 25,
			name = "hist_scrollUp",
			command = ScrollUp,
			graphics = { "image/button_arrow_up_up", "image/button_arrow_up_down", "image/button_arrow_up_over" },
			scale = 0.8,
		})
		table.insert(contents, Button {
			x = 205, y = btn_y, w = 25, h = 25,
			name = "hist_scrollDown",
			command = ScrollDown,
			graphics = { "image/button_arrow_down_up", "image/button_arrow_down_down", "image/button_arrow_down_over" },
			scale = 0.8,
		})

		if articleDocument then
			table.insert(contents, SetStyle(C3ButtonStyle))
			table.insert(contents, Button {
				x = 6, y = 398,
				label = "#" .. Localized("catalogue_history_view_document", "View Document"),
				command = OpenDocumentViewer,
				scale = 1,
			})
		end
	else
		table.insert(contents, Text {
			x = 24, y = 19, w = 406, h = 44,
			label = "#" .. GetString("catalogue_locked_title"),
			font = { labelFontName, 26, BlackColor },
			flags = kVAlignCenter + kHAlignCenter,
		})
		table.insert(contents, Text {
			x = 24, y = 70, w = view_w, h = view_h,
			label = "#" .. GetString("catalogue_locked_default_desc"),
			font = { uiFontName, 16, BlackColor },
			flags = kVAlignTop + kHAlignLeft,
		})
	end
else
	table.insert(contents, Text {
		x = 0, y = 0, w = kMax, h = kMax,
		label = "#" .. GetString("catalogue_no_selection"),
		flags = kVAlignCenter + kHAlignCenter,
	})
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
