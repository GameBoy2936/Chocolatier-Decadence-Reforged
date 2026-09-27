--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Community Cookbook)
	Copyright (c) 2026 Michael Lane. All Rights Reserved.
--]]---------------------------------------------------------------------------

require("community/api.lua")
ClearStringCache()
require("community/render.lua")

-------------------------------------------------------------------------------
-- UI State
-------------------------------------------------------------------------------

local context = gDialogTable or {}
local allowLoad = context.allow_load == true

local categoryOrder = { "all", "bar", "beverage", "infusion", "truffle", "blend", "exotic" }
local sortOrder = { "newest", "most_loaded", "top_rated", "name" }
local filterLabels =
{
	all = "community_filter_all",
	bar = "bar",
	beverage = "beverage",
	infusion = "infusion",
	truffle = "truffle",
	blend = "community_filter_blend",
	exotic = "exotic",
}
local sortLabels =
{
	newest = "community_sort_newest",
	most_loaded = "community_sort_most_loaded",
	top_rated = "community_sort_top_rated",
	name = "community_sort_name",
}

local titleFont = { standardFont, 24, BlackColor }
local filterFont = { labelFontName, 8.5, BlackColor }
local statusFont = { standardFont, 14, BlackColor }
local sortFont = { labelFontName, 16, MaroonColor }
local ruleColor = Color(116, 82, 54, 65)

local leftArrowGraphics =
{
	"image/button_arrow_up_up",
	"image/button_arrow_up_down",
	"image/button_arrow_up_over",
	"image/button_arrow_up_down",
}
local rightArrowGraphics =
{
	"image/button_arrow_down_up",
	"image/button_arrow_down_down",
	"image/button_arrow_down_over",
	"image/button_arrow_down_down",
}

-- FillWindow child scripts read the current Cookbook state from this global.
gCommunityCookbook =
{
	category = "all",
	q = "",
	sort = "newest",
	page = 1,
	page_size = 7,
	pages = 0,
	total = 0,
	items = {},
	selected_index = nil,
	loading = false,
	allow_load = allowLoad,
	source = context.source or "browser",
}

-------------------------------------------------------------------------------
-- UI Logic
-------------------------------------------------------------------------------

local function CurrentItem()
	local state = gCommunityCookbook
	if not state or not state.selected_index then
		return nil
	end
	return state.items[state.selected_index]
end

local function SetStatus(text)
	SetLabel("community_cookbook_status", tostring(text or ""))
end

local function RefreshChildren()
	FillWindow("community_results", "ui/community_cookbook_results.lua")
	FillWindow("community_selected", "ui/community_cookbook_selected.lua")
end

local function UpdateControls()
	local state = gCommunityCookbook
	if not state then
		return
	end

	local pageText
	if state.pages and state.pages > 0 then
		pageText = GetTextParams("community_cookbook_page", { tostring(state.page), tostring(state.pages) })
	else
		pageText = GetString("community_cookbook_page_empty")
	end
	SetLabel("community_page", pageText)
	SetLabel("community_sort_label", GetString(sortLabels[state.sort]))

	EnableWindow("community_prev", (not state.loading) and state.page > 1)
	EnableWindow("community_next", (not state.loading) and state.pages > 0 and state.page < state.pages)

	local item = CurrentItem()
	EnableWindow("community_details", (not state.loading) and item ~= nil)

	local profileId = item and item.author and tostring(item.author.profile_id or "") or ""
	EnableWindow("community_view_profile", (not state.loading) and profileId ~= "")

	for _, category in ipairs(categoryOrder) do
		SetButtonToggleState("community_filter_" .. category, category == state.category)
	end
end

local function RequestPage()
	local state = gCommunityCookbook
	if not state or state.loading then
		return
	end
	if CommunityTransport.IsBusy() then
		SetStatus(GetString("community_cookbook_busy"))
		return
	end

	state.loading = true
	state.items = {}
	state.selected_index = nil
	SetStatus(GetString("community_cookbook_loading"))
	RefreshChildren()
	UpdateControls()

	CommunityApi.Browse({
		category = state.category,
		q = state.q,
		sort = state.sort,
		page = state.page,
		page_size = state.page_size,
	}, function(result, response, err)
		if not gCommunityCookbook then
			return
		end
		state.loading = false
		if err then
			state.pages = 0
			state.total = 0
			SetStatus(GetString("community_cookbook_error") .. " " .. tostring(err))
			RefreshChildren()
			UpdateControls()
			return
		end

		state.items = result.items
		state.page = result.page
		state.pages = result.pages
		state.total = result.total
		if table.getn(state.items) > 0 then
			state.selected_index = 1
		end

		if state.total == 0 then
			SetStatus(GetString("community_cookbook_none"))
		elseif state.total == 1 then
			SetStatus(GetString("community_cookbook_one_result"))
		else
			SetStatus(GetString("community_stats_creations") .. ": " .. tostring(state.total))
		end
		RefreshChildren()
		UpdateControls()
	end)
end

function CommunityCookbookSelect(index)
	local state = gCommunityCookbook
	if not state or not state.items[index] then
		return
	end
	state.selected_index = index
	RefreshChildren()
	UpdateControls()
end

local function SelectCategory(category)
	local state = gCommunityCookbook
	if not state or state.loading or state.category == category then
		return
	end
	state.category = category
	state.page = 1
	RequestPage()
end

local function Search()
	local state = gCommunityCookbook
	if not state or state.loading then
		return
	end
	state.q = GetLabel("community_search_edit") or ""
	state.q = string.gsub(state.q, "^%s*(.-)%s*$", "%1")
	state.page = 1
	RequestPage()
end

local function ChangeSort(delta)
	local state = gCommunityCookbook
	if not state or state.loading then
		return
	end
	local current = 1
	for i, value in ipairs(sortOrder) do
		if value == state.sort then
			current = i break
		end
	end
	current = current + delta
	if current < 1 then
		current = table.getn(sortOrder)
	end
	if current > table.getn(sortOrder) then
		current = 1
	end
	state.sort = sortOrder[current]
	state.page = 1
	RequestPage()
end

local function PreviousPage()
	local state = gCommunityCookbook
	if state and not state.loading and state.page > 1 then
		state.page = state.page - 1
		RequestPage()
	end
end

local function NextPage()
	local state = gCommunityCookbook
	if state and not state.loading and state.pages > 0 and state.page < state.pages then
		state.page = state.page + 1
		RequestPage()
	end
end

local function CloseForKitchenLoad(item)
	if not item then
		return
	end
	gCommunityKitchenImport =
	{
		creation = item.creation,
		id = item.id,
		metadata =
		{
			rating_average = item.rating_average or 0,
			rating_count = item.rating_count or 0,
			load_count = item.load_count or 0,
			tags = item.tags or {},
			author = item.author or {},
			is_owned = item.is_owned == true,
		},
	}
	gCommunityCookbook = nil
	FadeCloseWindow("community_cookbook", "load")
end

local function OpenDetails()
	local state = gCommunityCookbook
	local item = CurrentItem()
	if not item then
		return
	end
	gCommunityCreationDeleted = nil
	local detailsResult = DisplayDialog {
		"ui/community_creation_details.lua",
		item = item,
		allow_load = allowLoad,
	}

	if detailsResult == "account_required" then
		-- Refresh ownership state after an expired session.
		RequestPage()
		return
	end

	-- Step back when deletion empties the current page.
	if gCommunityCreationDeleted then
		gCommunityCreationDeleted = nil
		if state and state.page > 1 and table.getn(state.items or {}) <= 1 then
			state.page = state.page - 1
		end
		RequestPage()
		return
	end

	-- Keep the existing Test Kitchen open for a selected Community load.
	if allowLoad and gCommunityKitchenImport then
		gCommunityCookbook = nil
		FadeCloseWindow("community_cookbook", "load")
	end
end

local function OpenSelectedProfile()
	local item = CurrentItem()
	local profileId = item and item.author and tostring(item.author.profile_id or "") or ""
	if profileId == "" or CommunityTransport.IsBusy() then
		return
	end
	DisplayDialog { "ui/community_public_profile.lua", profile_id = profileId }
end

-- Entry point used by the selected-result FillWindow.
function CommunityCookbookLoadSelected()
	local state = gCommunityCookbook
	if not state or state.loading or not state.allow_load then
		return
	end
	local item = CurrentItem()
	if not item then
		return
	end
	local availability = CommunityCreation.GetAvailability(item.creation)
	if not availability or not availability.can_load then
		return
	end
	CloseForKitchenLoad(item)
end

local function CloseCookbook()
	gCommunityCookbook = nil
	FadeCloseWindow("community_cookbook", "ok")
end

-- Use the seven native Recipe Book category tabs for Community filters.
local filterX = { 22, 89, 152, 215, 278, 341, 404 }
local filterButtons = { BeginGroup() }
for i, category in ipairs(categoryOrder) do
	local label = GetString(filterLabels[category])
	local temp = category
	local enabledGraphic = "image/recipes_category_" .. tostring(i) .. "_enabled"
	local selectedGraphic = "image/recipes_category_" .. tostring(i) .. "_used"
	table.insert(filterButtons, Button {
		x = filterX[i], y = 99,
		name = "community_filter_" .. category,
		graphics = { enabledGraphic, selectedGraphic, selectedGraphic, selectedGraphic },
		scale = 0.65,
		type = kRadio,
		sound = "cadi/ui_click.ogg",
		command = function() SelectCategory(temp) end,
		Text {
			x = 2, y = 16, w = 60, h = 20,
			label = "#" .. label,
			font = filterFont,
			flags = kHAlignCenter + kVAlignCenter,
		},
	})
end

local actionContents = { BeginGroup(), SetStyle(C3ButtonLongStyle) }
table.insert(actionContents, Button {
	x = 521, y = 304,
	name = "community_details",
	label = "#" .. GetString("community_view_details"),
	command = OpenDetails,
})
table.insert(actionContents, Button {
	x = 521, y = 350,
	name = "community_view_profile",
	label = "#" .. GetString("community_view_profile"),
	command = OpenSelectedProfile,
})

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Window
	{
		x = 1000, y = 9, name = "community_cookbook", fit = true,
		Bitmap
		{
			x = 0, y = 13, image = "image/popup_back_highscores",

			Text {
				x = 34, y = 32, w = 426, h = 31,
				label = "#" .. GetString("community_cookbook_header"),
				font = titleFont,
				flags = kHAlignCenter + kVAlignCenter,
			},

			-- Search field.
			Bitmap
			{
				x = 28, y = 68, w = 306, h = 30, image = "image/entername", scale = "0.8",
				TextEdit {
					x = 7, y = 0, w = 292, h = 30,
					name = "community_search_edit",
					label = "",
					utf8 = true,
					length = 50,
					font = { standardFont, 13, BlackColor },
					flags = kHAlignLeft + kVAlignCenter,
				},
			},
			SetStyle(C3ButtonStyle),
			Button {
				x = 367, y = 66, scale = 0.75,
				label = "#" .. GetString("community_search"),
				command = Search,
			},

			Group(filterButtons),
			Rectangle { x = 29, y = 149, w = 432, h = 1, color = ruleColor },
			Window { name = "community_results", x = 28, y = 151, w = 432, h = 266 },

			Button { x = 322, y = 416, name = "community_prev", graphics = leftArrowGraphics, scale = 0.7, command = PreviousPage },
			Text { x = 144, y = 415, w = 180, h = 24, name = "community_page", label = "", font = statusFont, flags = kHAlignCenter + kVAlignCenter },
			Button { x = 382, y = 416, name = "community_next", graphics = rightArrowGraphics, scale = 0.7, command = NextPage },

			Window
			{
				x = 477, y = 0, w = 289, h = 291,
				Button { x = 10, y = 30, graphics = leftArrowGraphics, scale = 0.5, command = function() ChangeSort(-1) end },
				Text { x = 120, y = 27, w = 179, h = 27, name = "community_sort_label", label = "", font = sortFont, flags = kHAlignLeft + kVAlignCenter },
				Button { x = 50, y = 30, graphics = rightArrowGraphics, scale = 0.5, command = function() ChangeSort(1) end },
				Text {
					x = 19, y = 55, w = 251, h = 30,
					label = "#" .. GetString("community_selected_header"),
					font = { labelFontName, 18, MaroonColor },
					flags = kHAlignCenter + kVAlignCenter,
				},
				Window { name = "community_selected", x = 10, y = 80, w = 269, h = 207 },
			},

			Group(actionContents),

			Text {
				x = 494, y = 411, w = 257, h = 18,
				name = "community_cookbook_status",
				label = "",
				font = statusFont,
				flags = kHAlignCenter + kVAlignTop,
			},
		},

		Bitmap
		{
			image = "image/popup_nameplate", x = 223, y = 0,
			Text {
				x = 34, y = 10, w = 270, h = 38,
				label = "#" .. GetString("community_cookbook_nameplate"),
				font = nameplateFont,
				flags = kHAlignCenter + kVAlignCenter,
			},
		},

		SetStyle(C3RoundButtonStyle),
		Button { x = 704, y = 426, name = "ok", label = "ok", default = true, cancel = true, command = CloseCookbook },
	}
}

RefreshChildren()
UpdateControls()
CenterFadeIn("community_cookbook")
QueueCommand(RequestPage)
