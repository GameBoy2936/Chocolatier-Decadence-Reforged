--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Score Details)
	Dedicated local and community Company Score / campaign-statistics viewer
---------------------------------------------------------------------------]]

require("ui/hiscore_countries.lua")
local context = gDialogTable or {}
local isRemoteSnapshot = type(context.snapshot) == "table"
local isCompactRemote = isRemoteSnapshot and (context.compactRemote or (context.snapshot and context.snapshot.remoteCompact))

local snapshot
local stats
local best
local pbHistory
local displayName
local integrityStatus

if isRemoteSnapshot then
	snapshot = context.snapshot
	stats = context.stats or {}
	best = context.personalBest or snapshot
	pbHistory = context.pbHistory or {}
	displayName = context.publicName or context.name or ""
	integrityStatus = context.integrityStatus or "legacy_unverified"
else
	HighScoreModel:EnsureStats(Player, Player.stats, false)
	snapshot = HighScoreModel:BuildSnapshot(Player)
	HighScoreModel:UpdatePersonalBest(Player, snapshot)

	stats = Player.stats or {}
	best = stats.personalBest or snapshot
	pbHistory = stats.pbHistory or {}
	displayName = Player.highScoreDisplayName or Player.name or ""
	if displayName == "" then displayName = Player.name or "" end
	integrityStatus = Player:GetIntegrityStatus()
end

-------------------------------------------------------------------------------
-- Typography
-------------------------------------------------------------------------------

local HeaderFont       = { labelFontName, 24, MaroonColor }
local ProfileFont      = { standardFont, 12.5, BlackColor }
local ScoreLabelFont   = { standardFont, 14, BlackColor }
local ScoreFont        = { standardFont, 35, MaroonColor }
local MetaFont         = { standardFont, 11.5, BlackColor }
local PageFont         = { labelFontName, 13.5, MaroonColor }
local SectionFont      = { labelFontName, 16.5, MaroonColor }
local LabelFont        = { standardFont, 12.5, BlackColor }
local ValueFont        = { standardFont, 13, BlackColor }
local FooterFont       = { standardFont, 10.5, BlackColor }
local RuleColor        = Color(116, 82, 54, 85)

local function Num(v) return HighScoreModel:FormatNumber(v or 0) end
local function Money(v) return Dollars(v or 0) end

local function IntegrityKey(status)
	if status == "ranked" then return "hiscore_integrity_ranked" end
	if status == "unranked_dev" then return "hiscore_integrity_dev" end
	return "hiscore_integrity_legacy"
end

local difficultyName = GetString(HighScoreModel:DifficultyNameKey(snapshot.difficulty))
local campaignMode = snapshot.campaignMode or context.campaignMode or "story"
local rankName = GetString("rank_" .. tostring(snapshot.rank))
local nationalityCode = context.nationality or snapshot.nationality or ""
local countrySuffix = ""
local nationalityFlag = ""
if nationalityCode ~= "" and HighScoreCountries:IsValid(nationalityCode) then
	countrySuffix = "  -  " .. HighScoreCountries:GetName(nationalityCode)
	nationalityFlag = HighScoreCountries:GetFlag(nationalityCode)
end
local profileLine
if campaignMode == "free" then
	profileLine = displayName .. countrySuffix .. "  -  " .. GetString("hiscore_mode_free_play") .. "  -  " .. difficultyName .. "  -  " .. GetString("hiscore_week_short") .. " " .. tostring(snapshot.week)
else
	profileLine = displayName .. countrySuffix .. "  -  " .. rankName .. "  -  " .. difficultyName .. "  -  " .. GetString("hiscore_week_short") .. " " .. tostring(snapshot.week)
end
local multiplierText = string.format("x%.2f", snapshot.difficultyMultiplier or 1)

local trackingText
if isCompactRemote then
	trackingText = GetString("hiscore_details_remote_snapshot")
elseif stats.legacyBaseline or snapshot.statsLegacyBaseline then
	trackingText = GetString("hiscore_details_tracking_legacy", tostring(snapshot.trackingStartedWeek or snapshot.week))
else
	trackingText = GetString("hiscore_details_tracking_full")
end

local page = 1
local pageCount = isRemoteSnapshot and 2 or 3

local function SetPair(slot, label, value)
	SetLabel("detail_label" .. tostring(slot), label or "")
	SetLabel("detail_value" .. tostring(slot), value or "")
end

local function ClearPairs()
	for i=1,16 do SetPair(i, "", "") end
end

local function SetPageHeaders(left, right)
	SetLabel("details_left_header", left or "")
	SetLabel("details_right_header", right or "")
end

local function SetOverviewPage()
	SetPageHeaders(GetString("hiscore_details_snapshot"), GetString("hiscore_details_career_stats"))

	SetPair(1, GetString("hiscore_details_company_value"), Money(snapshot.companyValue))
	SetPair(2, GetString("hiscore_details_cash"), Money(snapshot.money))
	SetPair(3, GetString("hiscore_details_inventory"), Money((snapshot.ingredientValue or 0) + (snapshot.productValue or 0)))
	SetPair(4, GetString("hiscore_details_machinery"), Money(snapshot.machineryValue))
	SetPair(5, GetString("hiscore_details_earnings_pace"), Money(snapshot.earningsPace) .. "/" .. GetString("hiscore_week_short"))

	if not isCompactRemote then
		SetPair(6, GetString("hiscore_details_highest_cash"), Money(snapshot.highestCash))
		SetPair(7, GetString("hiscore_details_lifetime_revenue"), Money(snapshot.lifetimeRevenue))
		SetPair(8, GetString("hiscore_details_lifetime_spend"), Money(snapshot.lifetimeSpend))
	end

	SetPair(9, GetString("hiscore_details_cases_made"), Num(snapshot.casesMade))
	SetPair(10, GetString("hiscore_details_cases_sold"), Num(snapshot.casesSold))
	SetPair(11, GetString("hiscore_details_factories"), Num(snapshot.factories))
	SetPair(12, GetString("hiscore_details_shops"), Num(snapshot.shops))
	SetPair(13, GetString("hiscore_details_ports"), Num(snapshot.portsVisited))
	if campaignMode == "free" then
		SetPair(14, GetString("hiscore_details_recipes_made"), Num(snapshot.recipesMade))
		SetPair(15, GetString("hiscore_details_free_creations"), Num(snapshot.customRecipes))
		SetPair(16, GetString("hiscore_details_special_orders"), Num(snapshot.specialOrdersCompleted) .. " / " .. Num(snapshot.specialOrdersFailed))
	else
		SetPair(14, GetString("hiscore_details_recipes_known"), Num(snapshot.recipesKnown))
		SetPair(15, GetString("hiscore_details_recipes_made"), Num(snapshot.recipesMade))
		SetPair(16, GetString("hiscore_details_custom_medals"), Num(snapshot.customRecipes) .. " / " .. Num(snapshot.medals))
	end
end

local function SetBreakdownPage()
	if isCompactRemote then
		SetPageHeaders(GetString("hiscore_details_breakdown"), GetString("hiscore_details_snapshot"))
	else
		SetPageHeaders(GetString("hiscore_details_breakdown"), GetString("hiscore_details_performance"))
	end

	SetPair(1, GetString("hiscore_details_value_points"), Num(snapshot.valuePoints))
	SetPair(2, GetString("hiscore_details_commerce_points"), Num(snapshot.commercePoints))
	SetPair(3, GetString("hiscore_details_expansion_points"), Num(snapshot.expansionPoints))
	SetPair(4, GetString("hiscore_details_mastery_points"), Num(snapshot.masteryPoints))
	if campaignMode == "free" then
		SetPair(5, GetString("hiscore_details_operations_points"), Num(snapshot.operationsPoints))
	else
		SetPair(5, GetString("hiscore_details_progression_points"), Num(snapshot.progressionPoints))
	end
	SetPair(6, GetString("hiscore_details_efficiency_points"), Num(snapshot.efficiencyPoints))
	SetPair(7, GetString("hiscore_details_base_score"), Num(snapshot.baseScore))
	SetPair(8, GetString("hiscore_details_difficulty"), multiplierText)

	if isCompactRemote then
		SetPair(9, GetString("hiscore_details_company_value"), Money(snapshot.companyValue))
		SetPair(10, GetString("hiscore_details_cash"), Money(snapshot.money))
		SetPair(11, GetString("hiscore_details_earnings_pace"), Money(snapshot.earningsPace) .. "/" .. GetString("hiscore_week_short"))
		SetPair(12, GetString("hiscore_details_factories"), Num(snapshot.factories))
		SetPair(13, GetString("hiscore_details_shops"), Num(snapshot.shops))
		SetPair(14, GetString("hiscore_details_ports"), Num(snapshot.portsVisited))
		if campaignMode == "free" then
			SetPair(15, GetString("hiscore_details_free_creations"), Num(snapshot.customRecipes))
			SetPair(16, GetString("hiscore_details_special_orders"), Num(snapshot.specialOrdersCompleted) .. " / " .. Num(snapshot.specialOrdersFailed))
		else
			SetPair(15, GetString("hiscore_details_recipes_known"), Num(snapshot.recipesKnown))
			SetPair(16, GetString("hiscore_details_recipes_made"), Num(snapshot.recipesMade))
		end
	else
		SetPair(9, GetString("hiscore_details_sales_revenue"), Money(snapshot.salesRevenue))
		SetPair(10, GetString("hiscore_details_largest_sale"), Money(snapshot.largestSale))
		SetPair(11, GetString("hiscore_details_special_revenue"), Money(snapshot.specialOrderRevenue))
		SetPair(12, GetString("hiscore_details_largest_special"), Money(snapshot.largestSpecialOrder))
		SetPair(13, GetString("hiscore_details_quests"), Num(snapshot.questsCompleted))
		SetPair(14, GetString("hiscore_details_special_orders"), Num(snapshot.specialOrdersCompleted) .. " / " .. Num(snapshot.specialOrdersFailed))
		SetPair(15, GetString("hiscore_details_travel"), Num(snapshot.travelTrips))
		SetPair(16, GetString("hiscore_details_spending_mix"), Money((snapshot.ingredientSpend or 0) + (snapshot.travelSpend or 0) + (snapshot.machinerySpend or 0) + (snapshot.factorySpend or 0)))
	end
end

local function SetPBPage()
	SetPageHeaders(GetString("hiscore_details_pb_history"), GetString("hiscore_details_pb_summary"))

	local total = table.getn(pbHistory)
	local shown = total
	if shown > 8 then shown = 8 end

	for slot=1,8 do
		local historyOffset = slot - 1
		local index = total - historyOffset
		if index >= 1 then
			local entry = pbHistory[index]
			local prefix = "#" .. tostring(historyOffset + 1)
			local label = prefix .. "  " .. GetString("hiscore_week_short") .. " " .. tostring(entry.week or 1)
			SetPair(slot, label, Num(entry.companyScore or 0))
		else
			SetPair(slot, "", "")
		end
	end

	if total == 0 then
		SetPair(1, GetString("hiscore_details_no_pb_history"), "")
	end

	local first = pbHistory[1]
	local latest = pbHistory[total]
	local previous = pbHistory[total - 1]
	local firstScore = first and (first.companyScore or 0) or 0
	local latestScore = latest and (latest.companyScore or 0) or (best.companyScore or snapshot.companyScore or 0)
	local latestGain = 0
	if previous and latest then latestGain = (latest.companyScore or 0) - (previous.companyScore or 0) end

	SetPair(9, GetString("hiscore_details_pb_count"), Num(total))
	SetPair(10, GetString("hiscore_details_first_pb"), Num(firstScore))
	SetPair(11, GetString("hiscore_details_first_pb_week"), first and tostring(first.week or 1) or "-")
	SetPair(12, GetString("hiscore_details_current_pb"), Num(latestScore))
	SetPair(13, GetString("hiscore_details_current_pb_week"), latest and tostring(latest.week or snapshot.week) or tostring(snapshot.week))
	SetPair(14, GetString("hiscore_details_total_gain"), Num(latestScore - firstScore))
	SetPair(15, GetString("hiscore_details_latest_gain"), Num(latestGain))
	SetPair(16, "", "")
end

local function PageNameKey()
	if page == 1 then return "hiscore_details_page_overview" end
	if page == 2 then return "hiscore_details_page_breakdown" end
	return "hiscore_details_page_history"
end

local function RefreshPage()
	ClearPairs()
	SetLabel("details_page", GetString(PageNameKey()) .. "  -  " .. tostring(page) .. "/" .. tostring(pageCount))

	if page == 1 then
		SetOverviewPage()
	elseif page == 2 then
		SetBreakdownPage()
	else
		SetPBPage()
	end

	EnableWindow("details_previous", page > 1)
	EnableWindow("details_next", page < pageCount)
end

local function PreviousPage()
	if page > 1 then
		page = page - 1
		RefreshPage()
	end
end

local function NextPage()
	if page < pageCount then
		page = page + 1
		RefreshPage()
	end
end

local function DetailRow(slot, x, y, w)
	-- Keep each row anchored on the exact same visual centre as the original
	-- 19px label, but give the label enough height to wrap onto a second line.
	-- Original centre: y + 9.5.  New centre: (y - 7) + 16.5 = y + 9.5.
	-- The numeric value remains a single-line 19px field in its old position.
	return Group {
		Text { x=x, y=y-7, w=w*0.62, h=33, name="detail_label" .. tostring(slot), label="", font=LabelFont, flags=kHAlignLeft + kVAlignCenter },
		Text { x=x+(w*0.62), y=y, w=w*0.38, h=19, name="detail_value" .. tostring(slot), label="", font=ValueFont, flags=kHAlignRight + kVAlignCenter },
	}
end

MakeDialog
{
	Bitmap
	{
		name = "hiscoredetailspanel",
		x = 1000, y = kCenter,
		image = "image/popup_back_generic_tall",

		-- Header / score card
		Text { x=34, y=27, w=434, h=36, label="hiscore_details_header", font=HeaderFont, flags=kHAlignCenter + kVAlignCenter },
		Text { x=34, y=63, w=434, h=20, label="#" .. profileLine, font=ProfileFont, flags=kHAlignCenter + kVAlignCenter },

		Text { x=34, y=89, w=434, h=17, label="hiscore_company_score", font=ScoreLabelFont, flags=kHAlignCenter + kVAlignCenter },
		Text { x=34, y=104, w=434, h=42, label="#" .. Num(snapshot.companyScore), font=ScoreFont, flags=kHAlignCenter + kVAlignCenter },
		Text { x=34, y=141, w=434, h=16, label="#" .. (isRemoteSnapshot and GetString("hiscore_details_remote_snapshot") or GetString("hiscore_details_best", Num(best.companyScore or snapshot.companyScore), tostring(best.week or snapshot.week))), font=MetaFont, flags=kHAlignCenter + kVAlignCenter },
		Text { x=34, y=157, w=434, h=16, label="#" .. GetString("hiscore_integrity_label") .. " " .. GetString(IntegrityKey(integrityStatus)) .. "  |  " .. GetString("hiscore_details_formula_version", tostring(snapshot.scoreVersion or 1)), font=MetaFont, flags=kHAlignCenter + kVAlignCenter },
		Text { x=34, y=171, w=434, h=20, name="details_page", label="", font=PageFont, flags=kHAlignCenter + kVAlignCenter },

		Rectangle { x=37, y=195, w=428, h=1, color=RuleColor },
		Rectangle { x=250, y=204, w=1, h=178, color=RuleColor },

		-- Two-column details grid
		Text { x=38, y=197, w=196, h=34, name="details_left_header", label="", font=SectionFont, flags=kHAlignLeft + kVAlignCenter },
		Text { x=265, y=197, w=198, h=34, name="details_right_header", label="", font=SectionFont, flags=kHAlignLeft + kVAlignCenter },

		DetailRow(1, 38, 229, 196),
		DetailRow(2, 38, 249, 196),
		DetailRow(3, 38, 269, 196),
		DetailRow(4, 38, 289, 196),
		DetailRow(5, 38, 309, 196),
		DetailRow(6, 38, 329, 196),
		DetailRow(7, 38, 349, 196),
		DetailRow(8, 38, 369, 196),

		DetailRow(9, 265, 229, 198),
		DetailRow(10, 265, 249, 198),
		DetailRow(11, 265, 269, 198),
		DetailRow(12, 265, 289, 198),
		DetailRow(13, 265, 309, 198),
		DetailRow(14, 265, 329, 198),
		DetailRow(15, 265, 349, 198),
		DetailRow(16, 265, 369, 198),

		Rectangle { x=37, y=393, w=428, h=1, color=RuleColor },

		-- Navigation stays symmetric even when an edge button is unavailable.
		SetStyle(C3ButtonStyle),
		Button { x = kCenter - 135, y=410, name="details_previous", label="previous", command=PreviousPage },
		Button { x = kCenter, y=410, name="ok", label="ok", default=true, cancel=true, command=function() FadeCloseWindow("hiscoredetailspanel", "ok") end },
		Button { x = kCenter + 135, y=410, name="details_next", label="next", command=NextPage },
	}
}

RefreshPage()
CenterFadeIn("hiscoredetailspanel")
