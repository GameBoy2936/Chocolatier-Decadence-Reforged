CreateQuest
{
	name = "nomoney",
	starter = "las_casinokeep",
	ender = "las_casinokeep",
	accept = "yeswedo",
	defer = "noimgood",
	reject = "none",
	require = {RequireMinRank(2), RequireMaxMoney(399)},
	onaccept = {AwardMoney(5000)},
	ondefer = {AwardDelayQuest("nomoney", 1)},
	goals = { RequireRelativeTime(5), RequireMinMoney(7500)},
	goals_medium = { RequireRelativeTime(5), RequireMinMoney(8500)},
	goals_hard = { RequireRelativeTime(5), RequireMinMoney(10000)},
	oncomplete ={ AwardMoney(-7500), IncrementVariable("broke"), AwardUnlockCharacter("las_casinokeep")},
	oncomplete_medium ={ AwardMoney(-8500), IncrementVariable("broke"), AwardUnlockCharacter("las_casinokeep")},
	oncomplete_hard ={ AwardMoney(-10000), IncrementVariable("broke"), AwardUnlockCharacter("las_casinokeep")},
	alwaysAvailable = true,
}

CreateQuest
{
	name = "nomoney2",
	starter = "las_casinokeep",
	ender = "las_casinokeep",
	accept = "yeswedo",
	defer = "imfinethanks",
	reject = "none",
	require = {RequireMinRank(2), RequireMaxMoney(399), RequireVariableEqual("broke", 1)},
	onaccept = {AwardMoney(5000)},
	ondefer = {AwardDelayQuest("nomoney2", 1)},
	goals = { RequireRelativeTime(6) , RequireMinMoney(10000)},
	goals_medium = { RequireRelativeTime(6), RequireMinMoney(12500)},
	goals_hard = { RequireRelativeTime(6), RequireMinMoney(15000)},
	oncomplete ={ AwardMoney(-10000), IncrementVariable("broke")},
	oncomplete_medium ={ AwardMoney(-12500), IncrementVariable("broke")},
	oncomplete_hard ={ AwardMoney(-15000), IncrementVariable("broke")},
	alwaysAvailable = true,
}

CreateQuest
{
	name = "nomoney3",
	starter = "las_casinokeep",
	ender = "las_casinokeep",
	accept = "deal",
	defer = "illpass",
	reject = "none",
	require = {RequireMinRank(2), RequireMaxMoney(399), RequireVariableEqual("broke", 2)},
	onaccept = {AwardMoney(5000)},
	ondefer = {AwardDelayQuest("nomoney3", 1)},
	goals = { RequireRelativeTime(6), RequireMinMoney(10000)},
	goals_medium = { RequireRelativeTime(6), RequireMinMoney(12500)},
	goals_hard = { RequireRelativeTime(6), RequireMinMoney(15000)},
	oncomplete ={ AwardMoney(-10000), IncrementVariable("broke")},
	oncomplete_medium ={ AwardMoney(-12500), IncrementVariable("broke")},
	oncomplete_hard ={ AwardMoney(-15000), IncrementVariable("broke")},
	alwaysAvailable = true,
}

CreateQuest
{
	name = "nomoney4",
	starter = "las_casinokeep",
	ender = "las_casinokeep",
	accept = "iagree",
	defer = "laterperhaps",
	reject = "none",
	require = {RequireMinRank(2), RequireMaxMoney(399), RequireVariableEqual("broke", 3), RequireVariableEqual("loaned", 0)},
	onaccept = {AwardMoney(5000), SetVariable("loaned", 1) },
	ondefer = {AwardDelayQuest("nomoney4", 1)},
	goals = { RequireRelativeTime(6), RequireMinMoney(20000)},
	goals_medium = { RequireRelativeTime(6), RequireMinMoney(22500)},
	goals_hard = { RequireRelativeTime(6), RequireMinMoney(25000)},
	oncomplete ={ AwardMoney(-20000), IncrementVariable("broke"), SetVariable("loaned", 0)},
	oncomplete_medium ={ AwardMoney(-22500), IncrementVariable("broke"), SetVariable("loaned", 0)},
	oncomplete_hard ={ AwardMoney(-25000), IncrementVariable("broke"), SetVariable("loaned", 0)},
	repeatable = 0,
	alwaysAvailable = true,
}

CreateQuest
{
	name = "nomoney5",
	starter = "las_casinokeep",
	ender = "las_casinokeep",
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireMinRank(2), RequireMaxMoney(399), RequireVariableEqual("broke", 4)},
	onaccept = {AwardMoney(2500)},
--	goals = { RequireRelativeTime(21) , RequireMinMoney(20000)},
	visible = false,
	repeatable = 0,
	alwaysAvailable = true,
}

CreateQuest
{
	name = "gambling",
	starter = "hav_casinokeep",
	accept = "itsadeal",
	defer = "illpass",
	reject = "none",
	require = {RequireMinRank(2), RequireRecipe("user1")},
	goals = { RequireItem("user1", 35)},
	goals_medium = { RequireItem("user1", 60)},
	goals_hard = { RequireItem("user1", 85)},
	oncomplete ={ AwardItem("user1", -35), IncrementVariable("gambler"), AwardUnblockBuilding("hav_casino"), AwardEnableOrderForChar("hav_casinokeep"), AwardEnableOrderForBuilding("hav_casino"), AwardUnlockCharacter("hav_casinokeep")},
	oncomplete_medium ={ AwardItem("user1", -60), IncrementVariable("gambler"), AwardUnblockBuilding("hav_casino"), AwardEnableOrderForChar("hav_casinokeep"), AwardEnableOrderForBuilding("hav_casino"), AwardUnlockCharacter("hav_casinokeep")},
	oncomplete_hard ={ AwardItem("user1", -85), IncrementVariable("gambler"), AwardUnblockBuilding("hav_casino"), AwardEnableOrderForChar("hav_casinokeep"), AwardEnableOrderForBuilding("hav_casino"), AwardUnlockCharacter("hav_casinokeep")},
}

CreateQuest
{
	name = "airplane",
	starter = "announcer",
	accept = "illtakeit",
	defer = "laterperhaps",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireMinMoney(1000000), RequireQuestComplete("telegraph"), RequireShopsOwned(2)},
	require_medium = {RequireMinRank(2), RequireMinMoney(1500000), RequireQuestComplete("telegraph"), RequireShopsOwned(3)},
	require_hard = {RequireMinRank(2), RequireMinMoney(2500000), RequireQuestComplete("telegraph"), RequireShopsOwned(4)},
	oncomplete ={ AwardMoney(-500000), IncrementVariable("ownplane")},
	oncomplete_medium ={ AwardMoney(-850000), IncrementVariable("ownplane")},
	oncomplete_hard ={ AwardMoney(-1500000), IncrementVariable("ownplane")},
	ondefer = {AwardText("airplane_deferred"), AwardDelayQuest("airplane", 35)},
}

CreateQuest
{
	name = "telegraph",
	starter = "announcer",
	accept = "youbet",
	defer = "nonotforme",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireFactoriesOwned(3), RequireRecipesKnown(3, "infusion"), RequireMinMoney(300000)},
	require_medium = {RequireMinRank(2), RequireFactoriesOwned(3), RequireRecipesKnown(3, "infusion"), RequireMinMoney(450000)},
	require_hard = {RequireMinRank(2), RequireFactoriesOwned(3), RequireRecipesKnown(3, "infusion"), RequireMinMoney(600000)},
	oncomplete = { AwardMoney(-100000), SetVariable("ownphone", 1), AwardDelayQuest("airplane", 20)},
	oncomplete_medium = { AwardMoney(-175000), SetVariable("ownphone", 1), AwardDelayQuest("airplane", 20)},
	oncomplete_hard = { AwardMoney(-250000), SetVariable("ownphone", 1), AwardDelayQuest("airplane", 20)},
	ondefer = {AwardText("telegraph_deferred"), AwardDelayQuest("telegraph", 25)},
}

CreateQuest
{
	name = "dou_shop_own_tease",
	starter = "dou_shopkeep",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireAbsoluteTime(127), RequireQuestNotActive("rank3_10"), RequireQuestIncomplete("rank3_10"), RequireQuestComplete("shop_tease_00")},
	visible = false,
	oncomplete ={AwardDelayQuest("shop_tease_01", 5), AwardDelayQuest("shop_tease_02", 8), AwardDelayQuest("shop_tease_03", 8), AwardUnlockCharacter("dou_shopkeep")},
}

CreateQuest
{
	name = "shop_tease_00",
	starter = "announcer",
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireNoOffers(2), RequireNoCompletes(2), RequireMinRank(2), RequireQuestNotActive("tanshop_02"), RequireQuestComplete("ugr_02"), RequireQuestIncomplete("tanshop_02"), RequireAbsoluteTime(27)},
	visible = false,
    isReal = true,
	oncomplete ={AwardDelayQuest("shop_tease_01", 14), AwardDelayQuest("shop_tease_02", 14), AwardDelayQuest("shop_tease_03", 14), AwardDelayQuest("shop_tease_04", 14), AwardDelayQuest("shop_tease_05", 14), AwardDelayQuest("shop_tease_06", 14), AwardDelayQuest("shop_tease_07", 14)},
}

CreateQuest
{
	name = "shop_tease_01",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	repeatable = 14,
	require = {RequireMinRank(2), RequireQuestNotActive("tanshop_02"), RequireQuestIncomplete("tanshop_02"), RequireQuestComplete("shop_tease_00")},
	visible = false,
    isReal = false,
	oncomplete ={IncrementVariable("shop_tease"), AwardDelayQuest("shop_tease_01", 28), AwardDelayQuest("shop_tease_02", 14), AwardDelayQuest("shop_tease_03", 14), AwardDelayQuest("shop_tease_04", 14), AwardDelayQuest("shop_tease_05", 14), AwardDelayQuest("shop_tease_06", 14), AwardDelayQuest("shop_tease_07", 14)},
}

CreateQuest
{
	name = "shop_tease_02",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	repeatable = 14,
	require = {RequireMinRank(2), RequireQuestNotActive("tanshop_02"), RequireQuestIncomplete("tanshop_02"), RequireQuestComplete("shop_tease_00")},
	visible = false,
    isReal = false,
	oncomplete ={IncrementVariable("shop_tease"), AwardDelayQuest("shop_tease_01", 14), AwardDelayQuest("shop_tease_02", 28), AwardDelayQuest("shop_tease_03", 14), AwardDelayQuest("shop_tease_04", 14), AwardDelayQuest("shop_tease_05", 14), AwardDelayQuest("shop_tease_06", 14), AwardDelayQuest("shop_tease_07", 14)},
}

CreateQuest
{
	name = "shop_tease_03",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	repeatable = 14,
	require = {RequireMinRank(2), RequireQuestNotActive("tanshop_02"), RequireQuestIncomplete("tanshop_02"), RequireQuestComplete("shop_tease_00")},
	visible = false,
    isReal = false,
	oncomplete ={IncrementVariable("shop_tease"), AwardDelayQuest("shop_tease_01", 14), AwardDelayQuest("shop_tease_02", 14), AwardDelayQuest("shop_tease_03", 28), AwardDelayQuest("shop_tease_04", 14), AwardDelayQuest("shop_tease_05", 14), AwardDelayQuest("shop_tease_06", 14), AwardDelayQuest("shop_tease_07", 14)},
}

CreateQuest
{
	name = "shop_tease_04",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	repeatable = 14,
	require = {RequireMinRank(2), RequireQuestNotActive("tanshop_02"), RequireQuestIncomplete("tanshop_02"), RequireQuestComplete("shop_tease_00")},
	visible = false,
    isReal = false,
	oncomplete ={IncrementVariable("shop_tease"), AwardDelayQuest("shop_tease_01", 14), AwardDelayQuest("shop_tease_02", 14), AwardDelayQuest("shop_tease_03", 14), AwardDelayQuest("shop_tease_04", 28), AwardDelayQuest("shop_tease_05", 14), AwardDelayQuest("shop_tease_06", 14), AwardDelayQuest("shop_tease_07", 14)},
}

CreateQuest
{
	name = "shop_tease_05",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	repeatable = 14,
	require = {RequireMinRank(2), RequireQuestNotActive("tanshop_02"), RequireQuestIncomplete("tanshop_02"), RequireQuestComplete("shop_tease_00")},
	visible = false,
    isReal = false,
	oncomplete ={IncrementVariable("shop_tease"), AwardDelayQuest("shop_tease_01", 14), AwardDelayQuest("shop_tease_02", 14), AwardDelayQuest("shop_tease_03", 14), AwardDelayQuest("shop_tease_04", 14), AwardDelayQuest("shop_tease_05", 28), AwardDelayQuest("shop_tease_06", 14), AwardDelayQuest("shop_tease_07", 14)},
}

CreateQuest
{
	name = "shop_tease_06",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	repeatable = 28,
	require = {RequireMinRank(2), RequireQuestNotActive("tanshop_02"), RequireQuestIncomplete("tanshop_02"), RequireQuestComplete("shop_tease_00"), RequireVariableMoreThan("shop_tease", 5)},
	visible = false,
    isReal = false,
	oncomplete ={AwardDelayQuest("shop_tease_01", 14), AwardDelayQuest("shop_tease_02", 14), AwardDelayQuest("shop_tease_03", 14), AwardDelayQuest("shop_tease_04", 14), AwardDelayQuest("shop_tease_05", 14), AwardDelayQuest("shop_tease_06", 28), AwardDelayQuest("shop_tease_07", 14)},
}

CreateQuest
{
	name = "shop_tease_07",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	repeatable = 28,
	require = {RequireMinRank(2), RequireQuestNotActive("tanshop_02"), RequireQuestIncomplete("tanshop_02"), RequireQuestComplete("shop_tease_00"), RequireVariableMoreThan("shop_tease", 5)},
	visible = false,
    isReal = false,
	oncomplete ={AwardDelayQuest("shop_tease_01", 14), AwardDelayQuest("shop_tease_02", 14), AwardDelayQuest("shop_tease_03", 14), AwardDelayQuest("shop_tease_04", 14), AwardDelayQuest("shop_tease_05", 14), AwardDelayQuest("shop_tease_06", 14), AwardDelayQuest("shop_tease_07", 28)},
}

CreateQuest
{
	name = "shop_owned_00",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireMinRank(2), RequireQuestComplete("tanshop_02")},
	visible = false,
--	oncomplete ={AwardDelayQuest("shop_tease_01", 7)},
}

CreateQuest
{
	name = "tan_shop_owned_00",
	starter = "main_zach",
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireBuildingOwned("tan_shop"), RequireVariableLessThan("tanshop_stop", 4)},
	onaccept = {IncrementVariable("tanshop_stop")},
	visible = false,
	repeatable = 24,
}

CreateQuest
{
	name = "rank2_tease_00",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	onaccept = {IncrementVariable("rank2_tease_00")},
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(2), RequireVariableLessThan("rank2_tease_00", 3), RequireQuestIncomplete("open_bali")},
	visible = false,
	repeatable = 29,
}

CreateQuest
{
	name = "rank2_tease_01",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(2)},
	visible = false,
	repeatable = 24,
}

CreateQuest
{
	name = "rank2_tease_02",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(2)},
	visible = false,
	repeatable = 22,
}

CreateQuest
{
	name = "rank2_tease_03",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	onaccept = {IncrementVariable("rank2_tease_03")},
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(2), RequireVariableLessThan("rank2_tease_03", 4), RequireQuestIncomplete("open_bali")},
	visible = false,
	repeatable = 25,
}

CreateQuest
{
	name = "rank2_tease_04",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	onaccept = {IncrementVariable("rank2_tease_04")},
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(2), RequireVariableLessThan("rank2_tease_04", 3), RequireQuestIncomplete("open_bali")},
	visible = false,
	repeatable = 35,
}

CreateQuest
{
	name = "rank2_tease_05",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(2), RequireQuestIncomplete("ugr_03")},
	visible = false,
	repeatable = 27,
}

CreateQuest
{
	name = "rank2_tease_06",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(2)},
	visible = false,
}

CreateQuest
{
	name = "rank2_tease_06e",
	starter = {"evil_wolf", "evil_kath", "evil_tyso", "evil_bian"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(2)},
	visible = false,
	repeatable = 32,
}

CreateQuest
{
	name = "rank2_tease_07",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(4), RequireQuestComplete("ugr_02")},
	visible = false,
	repeatable = 38,
}

CreateQuest
{
	name = "rank2_tease_08",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(2), RequireQuestIncomplete("rank2_coffee03")},
	visible = false,
	repeatable = 38,
}


CreateQuest
{
	name = "rank2_tease_09",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	priority = 13,
	require = {RequireMinRank(2), RequireMaxRank(2)},
	visible = false,
}

CreateQuest
{
	name = "rank2_tease_10",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(2)},
	visible = false,
	repeatable = 38,
}

CreateQuest
{
	name = "rank2_tease_11",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(2)},
	visible = false,
	repeatable = 30,
}

CreateQuest
{
	name = "rank2b_tease_00",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(2), RequireQuestComplete("open_bali")},
	visible = false,
}

CreateQuest
{
	name = "rank2b_tease_01",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(2), RequireQuestComplete("open_bali"), RequireBuildingOwned("tan_shop")},
	visible = false,
	repeatable = 24,
}

CreateQuest
{
	name = "rank2b_tease_02",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(2), RequireQuestComplete("open_bali")},
	visible = false,
	repeatable = 42,
}

CreateQuest
{
	name = "rank2b_tease_03",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	onaccept = {IncrementVariable("rank2b_tease_03")},
	autoComplete = true,
	require = {RequireMinRank(2), RequireVariableLessThan("rank2b_tease_03", 2), RequireQuestComplete("bali_01")},
	visible = false,
	repeatable = 30,
}

CreateQuest
{
	name = "rank2b_tease_04",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	onaccept = {IncrementVariable("rank2b_tease_04")},
	autoComplete = true,
	require = {RequireMinRank(2), RequirePort("havana"), RequireVariableLessThan("rank2b_tease_04", 4), RequireQuestComplete("open_bali")},
	visible = false,
	repeatable = 35,
}

CreateQuest
{
	name = "rank2b_tease_05",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireRecipeMade("user2"), RequireQuestComplete("open_bali")},
	visible = false,
}

CreateQuest
{
	name = "rank2b_tease_06",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(4), RequireQuestComplete("ugr_03"), RequireQuestComplete("open_bali")},
	visible = false,
	repeatable = 49,
}

CreateQuest
{
	name = "rank2b_tease_07",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(4), RequireQuestIncomplete("airplane"), RequireAbsoluteTime(44)},
	visible = false,
	repeatable = 38,
}

CreateQuest
{
	name = "rank3_tease_00",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(3), RequireMaxRank(4)},
	visible = false,
	repeatable = 29,
}

CreateQuest
{
	name = "rank3_tease_01",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(3), RequireMaxRank(3)},
	visible = false,
	repeatable = 31,
}

CreateQuest
{
	name = "rank3_tease_02",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(3), RequireMaxRank(3)},
	visible = false,
	repeatable = 35,
}

CreateQuest
{
	name = "rank3_tease_03",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(3), RequireMaxRank(4)},
	visible = false,
	repeatable = 27,
}

CreateQuest
{
	name = "rank3_tease_04",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(3), RequireMaxRank(4)},
	visible = false,
	repeatable = 30,
}

CreateQuest
{
	name = "rank3_tease_05",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(3), RequireMaxRank(3)},
	visible = false,
	repeatable = 20,
}

CreateQuest
{
	name = "rank4_tease_00",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(4), RequireMaxRank(4)},
	visible = false,
	repeatable = 22,
}

CreateQuest
{
	name = "rank4_tease_01",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(4), RequireMaxRank(4)},
	visible = false,
	repeatable = 20,
}

CreateQuest
{
	name = "rank4_tease_02",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(4), RequireMaxRank(4)},
	visible = false,
	repeatable = 24,
}

CreateQuest
{
	name = "rank4_tease_03",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(4), RequireMaxRank(4)},
	visible = false,
	repeatable = 23,
}

CreateQuest
{
	name = "rank4_tease_04",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(4), RequireMaxRank(4)},
	visible = false,
	repeatable = 26,
}

CreateQuest
{
	name = "rank4_tease_05",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(4), RequireMaxRank(4)},
	visible = false,
	repeatable = 29,
}

CreateQuest
{
	name = "travel_tease_00",
	starter = {"trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireAbsoluteTime(27), RequireQuestIncomplete("airplane"), },
	visible = false,
	onaccept ={AwardDelayQuest("travel_tease_01", 17)},
}

CreateQuest
{
	name = "travel_tease_01",
	starter = {"trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireQuestIncomplete("airplane"), RequireQuestComplete("travel_tease_00")},
	visible = false,
	onaccept ={AwardDelayQuest("travel_tease_02", 21)},
}

CreateQuest
{
	name = "travel_tease_02",
	starter = {"trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireQuestIncomplete("airplane"), RequireQuestComplete("travel_tease_01")},
	visible = false,
	onaccept ={AwardDelayQuest("travel_tease_03", 29)},
}

CreateQuest
{
	name = "travel_tease_03",
	starter = {"trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11"},
	accept = "ok",
	defer = "none",
	reject = "none",
	onaccept = {IncrementVariable("travel_tease_03")},
	autoComplete = true,
	require = {RequireMinRank(2), RequireQuestIncomplete("airplane"), RequireQuestComplete("travel_tease_02")},
	visible = false,
	onaccept ={AwardDelayQuest("travel_tease_04", 31)},
}

CreateQuest
{
	name = "travel_tease_04",
	starter = {"trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11"},
	accept = "ok",
	defer = "none",
	reject = "none",
	onaccept = {IncrementVariable("travel_tease_04")},
	autoComplete = true,
	require = {RequireMinRank(2), RequireQuestIncomplete("airplane"), RequireQuestComplete("travel_tease_03")},
	visible = false,
}

CreateQuest
{
	name = "expire_tease_00",
	starter = {"trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireAbsoluteTime(23) },
	visible = false,
	onaccept ={AwardDelayQuest("expire_tease_01", 7)},
}

CreateQuest
{
	name = "expire_tease_01",
	starter = {"trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireQuestComplete("expire_tease_00")},
	visible = false,
	onaccept ={AwardDelayQuest("expire_tease_02", 21)},
}

CreateQuest
{
	name = "expire_tease_02",
	starter = {"trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireQuestComplete("expire_tease_01")},
	visible = false,
}

CreateQuest
{
	name = "plot_points_00",
	starter = "trav_10",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireNoOffers(2), RequireMinRank(2),  RequireAbsoluteTime(75)},
	visible = false,
	onaccept ={AwardDelayQuest("plot_points_01", 14), AwardUnlockCharacter("trav_10")},
}

CreateQuest
{
	name = "plot_points_01",
	starter = "evil_tyso",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireQuestComplete("plot_points_00")},
	visible = false,
	onaccept ={AwardDelayQuest("plot_points_02", 15)},
}

CreateQuest
{
	name = "plot_points_02",
	starter = {"trav_02", "trav_04", "trav_06", "trav_08", "trav_07", "trav_11"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2),  RequireQuestComplete("plot_points_01")},
	visible = false,
	onaccept ={AwardDelayQuest("plot_points_03", 21)},
}

CreateQuest
{
	name = "plot_points_03",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "mah_shopkeep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_elen", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	priority = 100,
	require = {RequireMinRank(2), RequireQuestComplete("plot_points_02")},
	visible = false,
	onaccept ={AwardUnlockIngredient("lavender"), AwardDelayQuest("plot_points_04", 28)},
}

CreateQuest
{
	name = "plot_points_04",
	starter = "evil_kath",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(3),  RequireQuestComplete("plot_points_03")},
	visible = false,
	onaccept ={AwardUnlockIngredient("kahlua"), AwardDelayQuest("plot_points_05", 8), IncrementVariable("gameover")},
}

CreateQuest
{
	name = "plot_points_05",
	starter = "trav_03",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	priority = 66,
	require = {RequireMinRank(3),  RequireQuestComplete("plot_points_04")},
	visible = false,
	onaccept ={AwardUnlockIngredient("grand_marnier"), AwardDelayQuest("plot_points_06", 15), IncrementVariable("gameover")},
}

CreateQuest
{
	name = "plot_points_06",
	starter = "trav_06",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	priority = 5,
	require = {RequireMinRank(3),  RequireQuestComplete("plot_points_05")},
	visible = false,
	onaccept ={AwardUnlockIngredient("brandy"), AwardDelayQuest("plot_points_07", 7)},
}

CreateQuest
{
	name = "plot_points_07",
	starter = "wel_bldg1keep",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	priority = 33,
	require = {RequireMinRank(4),  RequireQuestComplete("plot_points_06")},
	onaccept ={IncrementVariable("gameover")},
	visible = false,
}

CreateQuest
{
	name = "itsover_alex",
	starter = "main_alex",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(5)},
	visible = false,
	repeatable = 24,
}

CreateQuest
{
	name = "rank4_boardspew",
	starter = {"main_whit", "main_feli", "main_jose", "main_deit"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(4), RequireMaxRank(4)},
	visible = false,
	repeatable = 0,
}

CreateQuest
{
	name = "itsover_bc",
	starter = {"main_whit", "main_feli", "main_tedd", "main_jose", "main_deit", "main_zach"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(5)},
	visible = false,
	repeatable = 34,
}

CreateQuest
{
	name = "itsover_evil",
	starter = {"evil_bian", "evil_wolf", "evil_tyso", "evil_kath"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(5)},
	visible = false,
	repeatable = 20,
}

CreateQuest
{
	name = "evan_endorsed_rank2",
	starter = "main_evan",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireQuestComplete("meta_evan"), RequireMaxRank(4)},
	visible = false,
	repeatable = 0,
}

CreateQuest
{
	name = "itsover_evan",
	starter = "main_evan",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(5)},
	visible = false,
	repeatable = 0,
}

CreateQuest
{
	name = "rank2_bianspew",
	starter = "evil_bian",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireMaxRank(2)},
	visible = false,
	repeatable = 1,
}


CreateQuest
{
	name = "rank3_bianspew",
	starter = "evil_bian",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(3), RequireMaxRank(3)},
	visible = false,
	repeatable = 1,
}

CreateQuest
{
	name = "rank4_bianspew",
	starter = "evil_bian",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(4), RequireMaxRank(4)},
	visible = false,
	repeatable = 1,
}

CreateQuest
{
	name = "rank5_bianspew",
	starter = "evil_bian",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(5)},
	visible = false,
	repeatable = 1,
}

CreateQuest
{
	name = "whit_premeta_spew",
	starter = "main_whit",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireQuestIncomplete("off_to_whitney")},
	visible = false,
	repeatable = 1,
}

CreateQuest
{
	name = "jose_endorsed_spew",
	starter = "main_jose",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(3), RequireMaxRank(3), RequireQuestComplete("meta_joseph")},
	visible = false,
	repeatable = 1,
}