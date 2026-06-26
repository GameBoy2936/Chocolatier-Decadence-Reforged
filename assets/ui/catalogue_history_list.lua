--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (History List Panel)
	Copyright (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- Initialize global state toggle for rendering locked historical documents
gShowLockedHistory = gShowLockedHistory or false

-------------------------------------------------------------------------------
-- State Management & Data Gathering
-------------------------------------------------------------------------------

-- Master Array of all lore documents available in the game
local allHistoryArticles = {
	"catalogue_history_baumeister_1",
	"catalogue_history_baumeister_2",
	"catalogue_history_baumeister_3",
	"catalogue_history_baumeister_4",
	"catalogue_history_baumeister_5",
	"catalogue_history_letter_alex_sean_1",
	"catalogue_history_journal_felix_coffee",
	"catalogue_history_letter_alex_sean_2",
	"catalogue_history_letter_wolf_memo_1",
	"catalogue_history_letter_alex_sean_3",
	"catalogue_history_letter_hardy_sean",
}

Player.catalogue.unlockedHistory = Player.catalogue.unlockedHistory or {}

-- 1. Default Articles (Automatically unlocked on start)
-- We perform this verification here so older pre-mod save files automatically 
-- receive these entries the first time they open the History tab.
local defaultHistoryArticles = {
	"catalogue_history_baumeister_1",
	"catalogue_history_baumeister_2",
	"catalogue_history_baumeister_3",
	"catalogue_history_baumeister_4",
	"catalogue_history_baumeister_5",
}

for _, articleKey in ipairs(defaultHistoryArticles) do
	if not Player.catalogue.unlockedHistory[articleKey] then
		Player.catalogue.unlockedHistory[articleKey] = true
		DebugOut("CATALOGUE", string.format("MIGRATION/DEFAULT: Unlocked base history article '%s'.", articleKey))
	end
end

-- 2. Retroactive Quest Articles 
-- Automatically grants lore documents if the player already completed the 
-- prerequisite quest on an older version of the mod.
local retroactiveHistoryUnlocks = {
	{ quest = "tut_over", article = "catalogue_history_letter_alex_sean_1" },
	{ quest = "tut_over_notut", article = "catalogue_history_letter_alex_sean_1" }
}

for _, retro in ipairs(retroactiveHistoryUnlocks) do
	if Player.questsComplete[retro.quest] and not Player.catalogue.unlockedHistory[retro.article] then
		Player.catalogue.unlockedHistory[retro.article] = true
		DebugOut("CATALOGUE", string.format("MIGRATION: Retroactively unlocked '%s' because quest '%s' was already complete.", retro.article, retro.quest))
	end
end

-- 3. Filter Valid Articles
local displayArticles = {}
for _, key in ipairs(allHistoryArticles) do
	local isUnlocked = Player.catalogue.unlockedHistory[key] or gDevForceReveal
	if isUnlocked or gShowLockedHistory then
		table.insert(displayArticles, { key = key, unlocked = isUnlocked })
	end
end

-- Force select the top article if none is currently active
if not gCatalogueSelection and table.getn(displayArticles) > 0 then
	gCatalogueSelection = displayArticles[1].key
end

-------------------------------------------------------------------------------
-- UI Action Handlers
-------------------------------------------------------------------------------

local function SelectArticle(articleKey)
	if gCatalogueSelection ~= articleKey then
		gCatalogueSelection = articleKey
		DebugOut("UI", string.format("Catalogue selection changed to history article: %s", articleKey))

		-- Force UI redraw to update button states and detail panel
		FillWindow("catalogue_list", "ui/catalogue_history_list.lua")
		FillWindow("catalogue_detail", "ui/catalogue_detail.lua")
	end
end

local function ToggleLocked()
	gShowLockedHistory = not gShowLockedHistory
	SoundEvent("cadi/ui_click.ogg")
	FillWindow("catalogue_list", "ui/catalogue_history_list.lua")
end

local function ToggleDevViewList()
	gDevForceReveal = not gDevForceReveal
	DebugOut("DEV", string.format("Catalogue developer reveal forced to: %s", tostring(gDevForceReveal)))
	SoundEvent("cadi/ui_click.ogg")
	
	FillWindow("catalogue_list", "ui/catalogue_history_list.lua")
	FillWindow("catalogue_detail", "ui/catalogue_detail.lua")
end

-------------------------------------------------------------------------------
-- Custom Button Engine
-------------------------------------------------------------------------------
-- Standard radio buttons visually shift their text down 2px when selected.
-- Since the history list acts like a scrolling file directory, this looks messy.
-- This custom wrapper prevents the text from shifting during state changes.

local HistorySelectButtonStyle =
{
	type = kRadio,
	graphics = {
		"image/button_quest_title_up",
		"image/button_quest_title_selected_2", 
		"image/button_quest_title_over",
		"image/button_quest_title_selected_2"  
	},
}

function CatalogueListButton(button)
	return function()
		local command = GetTag(button, "command")
		if command then
			button.command = function() if not gButtonsDisabled then command() end end
		end

		local label = GetTag(button, "label")
		if label then
			local tx = GetTag(button, "tx") or 0
			local ty = GetTag(button, "ty") or 0
			local tw = GetTag(button, "tw") or kMax
			local th = GetTag(button, "th") or kMax

			local listFont = { uiFontName, 16, Color(0, 0, 0, 255) }

			table.insert(button, SelectLayer(kAllLayers))
			table.insert(button, AppendStyle { defflags = kVAlignCenter + kHAlignLeft })
			
			-- Render text firmly anchored at identical X/Y offsets across all 4 states
			table.insert(button, SelectLayer(0))
			table.insert(button, Text{ x = tx + 27, y = ty, w = tw, h = th, name = "label0", label = label, font = listFont })
			
			table.insert(button, SelectLayer(1))
			table.insert(button, Text{ x = tx + 27, y = ty, w = tw, h = th, name = "label1", label = label, font = listFont })
			
			table.insert(button, SelectLayer(2))
			table.insert(button, Text{ x = tx + 27, y = ty, w = tw, h = th, name = "label2", label = label, font = listFont })
			
			table.insert(button, SelectLayer(3))
			table.insert(button, Text{ x = tx + 27, y = ty, w = tw, h = th, name = "label3", label = label, font = listFont })
		end

		button.typename = 'Button'
		DoWindow(button)
	end
end

-------------------------------------------------------------------------------
-- UI Construction & Layout Grid
-------------------------------------------------------------------------------

local contents = {}

-- Establish pagination metrics explicitly for the text-heavy History list
local layout = {
	x_start = -305, y_start = 10,
	x_spacing = 0, y_spacing = 30,
	items_per_row = 1,
	rows_per_page = 13, -- Designed to fit perfectly within the ~400px height bounding box
}
layout.items_per_page = layout.items_per_row * layout.rows_per_page

-- Share layout metrics with parent container for scroll button calculation
gCatalogueLayout = layout

local listItems = { BeginGroup(), AppendStyle(HistorySelectButtonStyle) }
local x, y = layout.x_start, layout.y_start
local items_drawn_this_page = 0

-- Generate Interactive Rows
if table.getn(displayArticles) > 0 then
	for i = gCatalogueTopIndex, gCatalogueTopIndex + layout.items_per_page - 1 do
		local article = displayArticles[i]
		if article then
			local tempKey = article.key
			
			-- Obfuscate locked titles dynamically
			local labelText = article.unlocked and GetString(tempKey .. "_title") or GetString("catalogue_locked_title")
			
			table.insert(listItems, CatalogueListButton { 
				x = x, y = y, 
				name = "article_" .. tempKey, 
				label = "#" .. labelText, 
				command = function() SelectArticle(tempKey) end 
			})
			
			y = y + layout.y_spacing
			items_drawn_this_page = items_drawn_this_page + 1
		end
	end
else
	-- Safe Error State
	table.insert(listItems, Text { 
		x = 0, y = 0, w = kMax, h = kMax, 
		label = "#No history entries found.", 
		flags = kVAlignCenter + kHAlignCenter 
	})
end

table.insert(contents, Window { x = 0, y = 0, w = kMax, h = 390, Group(listItems) })

-- -----------------------------------------------------
-- Toggles & Modifiers
-- -----------------------------------------------------
table.insert(contents, SetStyle(C3SmallRoundButtonStyle))
table.insert(contents, BeginGroup())
table.insert(contents, Button { x = 5, y = 405, name = "showLocked", type = kToggle, command = ToggleLocked })
table.insert(contents, Text { x = 50, y = 400, h = 40, w = 215, label = "#Show Locked Entries", flags = kVAlignCenter + kHAlignLeft, font = { uiFontName, 14, BlackColor } })

if CheckConfig("dev") then
	table.insert(contents, SetStyle(C3ButtonStyle))
	table.insert(contents, Button { x = 140, y = 445, w = 140, h = 25, label = "#DEV UNLOCK", command = ToggleDevViewList })
end

MakeDialog(contents)

-- Final state execution
if gCatalogueSelection then
	SetButtonToggleState("article_" .. gCatalogueSelection, true)
end
SetButtonToggleState("showLocked", gShowLockedHistory)

local canScrollUp = gCatalogueTopIndex > 1
local canScrollDown = (gCatalogueTopIndex + layout.items_per_page) <= table.getn(displayArticles)
UpdateCatalogueScrollButtons(canScrollUp, canScrollDown)