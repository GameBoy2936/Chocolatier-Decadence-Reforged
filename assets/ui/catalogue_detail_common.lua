--[[---------------------------------------------------------------------------
	Chocolatier Three: Catalogue Detail - Common Helpers
	Copyright (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- Global toggle for developer reveal mode.
-- If true, all locked/unmet items will be rendered as if they are unlocked.
gDevForceReveal = gDevForceReveal or false

-------------------------------------------------------------------------------
-- Scrolling State Management (Generic Fallback)
-------------------------------------------------------------------------------
-- Note: Individual panels (Ports, Characters, History, Ingredients) currently 
-- maintain their own isolated scroll state variables, but this is kept as a 
-- generic fallback for new or simpler panels.

gCatalogueDetailOffsets = gCatalogueDetailOffsets or { 0 }
gCatalogueDetailPage = gCatalogueDetailPage or 1
gCatalogueDetailLastSelection = gCatalogueDetailLastSelection or nil

-- Call this at the start of a detail script to ensure the scroll resets
-- when the player clicks a different item.
function HandleDetailScrollReset(currentID)
	if gCatalogueDetailLastSelection ~= currentID then
		DebugOut("UI", string.format("Generic Detail Scroll Reset triggered for: %s", tostring(currentID)))
		gCatalogueDetailOffsets = { 0 }
		gCatalogueDetailPage = 1
		gCatalogueDetailLastSelection = currentID
	end
end

-------------------------------------------------------------------------------
-- Helper Functions
-------------------------------------------------------------------------------

function ToggleDevView()
	gDevForceReveal = not gDevForceReveal
	DebugOut("DEV", "Catalogue Dev Reveal toggled.", { forceReveal = gDevForceReveal })
	
	-- Reload the current detail view to reflect the change.
	-- WARNING: Depending on how the UI tree is built, this generic path may 
	-- need to be overridden by the specific detail script invoking it (e.g., 
	-- pointing to "ui/catalogue_port_detail.lua" directly).
	FillWindow("catalogue_detail", "ui/catalogue_detail.lua")
end

-- HELPER: Converts a week number (1-52) into a descriptive date string.
-- Used primarily by Ingredient and Port views for seasonality/holidays.
function ConvertWeekToDateString(week)
	-- 1. Calculate the Month (approx 4.33 weeks per month)
	local month_index = Floor((week - 1) / 4.33) + 1
	if month_index > 12 then month_index = 12 end
	local month_name = GetString("month_" .. month_index)

	-- 2. Calculate the approximate week within that month
	local week_in_month_approx = Mod(week, 4)
	if week_in_month_approx == 0 then week_in_month_approx = 4 end

	-- 3. Return the descriptive localized string
	if week_in_month_approx == 1 then
		return GetString("catalogue_date_early", month_name)
	elseif week_in_month_approx == 4 then
		return GetString("catalogue_date_late", month_name)
	else
		return GetString("catalogue_date_middle", month_name)
	end
end

-- HELPER: Dynamic Text Sizing (Legacy/Fallback)
-- Adjusts font size based on text length to ensure it fits in a fixed-size box.
-- Note: Most panels have migrated to HTML-aware scrolling and static font sizes, 
-- but this remains available for smaller UI elements.
function SetDynamicDetailText(textKey, fontMapOverride)
	local text = GetReplacedString(textKey)
	if text == "#####" then 
		text = "" 
		DebugOut("ERROR", "SetDynamicDetailText: Missing localization string.", { key = textKey })
	end

	local function Ceil(x) return Floor(x + 0.99999) end

	-- Default configuration (originally tuned for the character bio box)
	local font_sizes_to_check = {14, 13, 12}
	local chars_per_line_map = { [14] = 45, [13] = 50, [12] = 55 }
	local line_thresholds = { [14] = 11, [13] = 12, [12] = 999 }

	-- Allow overrides for different panel dimensions
	if fontMapOverride then
		font_sizes_to_check = fontMapOverride.sizes or font_sizes_to_check
		chars_per_line_map = fontMapOverride.chars or chars_per_line_map
		line_thresholds = fontMapOverride.thresholds or line_thresholds
	end
	
	-- Split text by <br> tags to count lines accurately
	local segments = {}
	local current_pos = 1
	
	if text then
		local start_pos, end_pos = string.find(text, "<br>", current_pos, true)
		while start_pos do
			table.insert(segments, string.sub(text, current_pos, start_pos - 1))
			current_pos = end_pos + 1
			start_pos, end_pos = string.find(text, "<br>", current_pos, true)
		end
		table.insert(segments, string.sub(text, current_pos))
	end
	
	-- Fallback if no tags are found
	if table.getn(segments) == 0 then segments = { text or "" } end

	-- Find the largest font that fits within the target line threshold
	local final_font_size = 12
	for _, current_font_size in ipairs(font_sizes_to_check) do
		local chars_per_line = chars_per_line_map[current_font_size]
		local line_threshold = line_thresholds[current_font_size]
		
		-- Start at total_lines = (segments - 1) to account for the explicit <br> breaks
		local total_lines = table.getn(segments) - 1
		for _, segment in ipairs(segments) do
			total_lines = total_lines + Ceil(string.len(segment) / chars_per_line)
		end

		if total_lines <= line_threshold then
			final_font_size = current_font_size
			break 
		end
	end
	
	DebugOut("UI", "Dynamic text size evaluated.", { 
		key = textKey, 
		selectedSize = final_font_size 
	})
	
	local formatted_text = string.format("<font size='%d'>%s</font>", final_font_size, text)
	SetLabel("catalogue_description_text", formatted_text)
end