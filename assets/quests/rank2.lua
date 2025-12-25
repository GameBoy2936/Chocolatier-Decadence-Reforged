--[[--------------------------------------------------------------------------
	Chocolatier Three: Quests
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------


CreateQuest
{
	name = "rank2_precoffee_hint",
	starter = "main_feli",
	accept = "ok",
	defer = "none",
	reject = "none",
	require = { RequireMinRank(2), RequireQuestComplete("rank2_01"), RequireQuestIncomplete("rank2_coffee01") },
  	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "rank2_01",
	starter = "main_feli",
	accept = "thankyou",
	accept_length = "short",
	defer = "none",
	reject = "none",
	onaccept = {AwardText("rank2_01_extra01"), AwardUnlockIngredient("peanut"), AwardUnlockIngredient("hazelnut"), AwardUnlockIngredient("almond")},
	require = { RequireMinRank(2)},
	oncomplete = {AwardOfferQuest("rank2_02"), AwardDelayQuest("rank2_precoffee_hint", 4), AwardUnlockCharacter("main_feli")},  
}

CreateQuest
{
	name = "rank2_02",
	starter = "main_feli",
	ender = "zur_schoolkeep",
	accept = "iwill",
	accept_length = "medium",
	defer = "later",
	defer_length = "medium",
	reject = "none",
	goals = { RequireItem("b04", 20), HintPerson("zur_schoolkeep", "zur_school", "zurich")},
    goals_medium = { RequireItem("b04", 30), HintPerson("zur_schoolkeep", "zur_school", "zurich")},
    goals_hard = { RequireItem("b04", 45), HintPerson("zur_schoolkeep", "zur_school", "zurich")},
	onaccept = {AwardUnlockIngredient("peanut"), AwardUnlockIngredient("hazelnut"), AwardUnlockIngredient("almond")},
	require = { RequireMinRank(2), RequireQuestComplete("rank2_01")},
	oncomplete = { AwardItem("b04", -20), AwardOfferQuest("rank2_03"), IncrementVariable("lab"), IncrementVariable("rank2_work"), AwardUnlockCharacter("zur_schoolkeep")},
    oncomplete_medium = { AwardItem("b04", -30), AwardOfferQuest("rank2_03"), IncrementVariable("lab"), IncrementVariable("rank2_work"), AwardUnlockCharacter("zur_schoolkeep")},
    oncomplete_hard = { AwardItem("b04", -45), AwardOfferQuest("rank2_03"), IncrementVariable("lab"), IncrementVariable("rank2_work"), AwardUnlockCharacter("zur_schoolkeep")},
}

CreateQuest
{
	name = "rank2_03",
	starter = "zur_schoolkeep",
	ender = "cap_mountainkeep",
	accept = "goodidea",
	accept_length = "medium",
	defer = "maybelater",
	defer_length = "medium",
	reject = "none",
	goals = { RequireItem("b04", 30), HintPerson("cap_mountainkeep", "cap_mountain", "capetown")},
    goals_medium = { RequireItem("b04", 45), HintPerson("cap_mountainkeep", "cap_mountain", "capetown")},
    goals_hard = { RequireItem("b04", 60), HintPerson("cap_mountainkeep", "cap_mountain", "capetown")},
	oncomplete = {AwardItem("b04", -30), IncrementVariable("rank2_work"), IncrementVariable("lab"), AwardUnlockIngredient("mint"), AwardUnlockIngredient("orange"), AwardUnlockIngredient("lemon"), AwardUnlockCharacter("cap_mountainkeep"), AwardDiscoverPreference("cap_mountainkeep", "like", "peanut")},
	oncomplete_medium = {AwardItem("b04", -45), IncrementVariable("rank2_work"), IncrementVariable("lab"), AwardUnlockIngredient("mint"), AwardUnlockIngredient("orange"), AwardUnlockIngredient("lemon"), AwardUnlockCharacter("cap_mountainkeep"), AwardDiscoverPreference("cap_mountainkeep", "like", "peanut")},
	oncomplete_hard = {AwardItem("b04", -60), IncrementVariable("rank2_work"), IncrementVariable("lab"), AwardUnlockIngredient("mint"), AwardUnlockIngredient("orange"), AwardUnlockIngredient("lemon"), AwardUnlockCharacter("cap_mountainkeep"), AwardDiscoverPreference("cap_mountainkeep", "like", "peanut")},
	require = { RequireMinRank(2), RequireQuestComplete("rank2_02")}, 
}

CreateQuest
{
	name = "rank2_04",
	starter = "zur_towerkeep",
	accept = "iam",
	accept_length = "medium",
	defer = "anothertime",
	defer_length = "medium",
	reject = "none",
	goals = { RequireItem("b06", 15), HintPerson("zur_towerkeep", "zur_tower", "zurich")},
	goals_medium = { RequireItem("b06", 25), HintPerson("zur_towerkeep", "zur_tower", "zurich")},
	goals_hard = { RequireItem("b06", 40), HintPerson("zur_towerkeep", "zur_tower", "zurich")},
	oncomplete = {IncrementVariable("rank2_work"),  IncrementVariable("lab"), AwardItem("b06", -15), AwardMoney(12000), AwardDiscoverPreference("zur_towerkeep", "like", "almond")},
	oncomplete_medium = {IncrementVariable("rank2_work"),  IncrementVariable("lab"), AwardItem("b06", -25), AwardMoney(20000), AwardDiscoverPreference("zur_towerkeep", "like", "almond")},
	oncomplete_hard = {IncrementVariable("rank2_work"),  IncrementVariable("lab"), AwardItem("b06", -40), AwardMoney(32500), AwardDiscoverPreference("zur_towerkeep", "like", "almond")},
	require = { RequireMinRank(2) },
}

CreateQuest
{
	name = "rank2_05",
	starter = "zur_schoolkeep",
	ender = "zur_mountainkeep",
	accept = "itsadeal",
	accept_length = "medium",
	defer = "laterperhaps",
	defer_length = "medium",
	reject = "none",
	onaccept = {AwardMoney(20000)},
	onaccept_medium = {AwardMoney(25000)},
	onaccept_hard = {AwardMoney(30000)},
	goals = { RequireItem("b08", 32), HintPerson("zur_mountainkeep", "zur_mountain", "zurich")},
	goals_medium = { RequireItem("b08", 45), HintPerson("zur_mountainkeep", "zur_mountain", "zurich")},
	goals_hard = { RequireItem("b08", 58), HintPerson("zur_mountainkeep", "zur_mountain", "zurich")},
	oncomplete = {IncrementVariable("rank2_work"), IncrementVariable("lab"), AwardItem("b08", -32), AwardUnlockCharacter("zur_mountainkeep")},
	oncomplete_medium = {IncrementVariable("rank2_work"),  IncrementVariable("lab"), AwardItem("b08", -45), AwardUnlockCharacter("zur_mountainkeep")},
	oncomplete_hard = {IncrementVariable("rank2_work"),  IncrementVariable("lab"), AwardItem("b08", -58), AwardUnlockCharacter("zur_mountainkeep")},
	require = { RequireMinRank(2), RequireQuestComplete("rank2_03")},
}

CreateQuest
{
	name = "rank2_06",
	starter = "cap_marketkeep",
	accept = "sure",
	accept_length = "medium",
	defer = "askmelater",
	defer_length = "medium",
	reject = "none",
	onaccept = {AwardUnlockCharacter("cap_marketkeep")},
	goals = {RequireItem("b10", 18), HintPerson("cap_marketkeep", "cap_market", "capetown")},
	goals_medium = {RequireItem("b10", 32), HintPerson("cap_marketkeep", "cap_market", "capetown")},
	goals_hard = {RequireItem("b10", 46), HintPerson("cap_marketkeep", "cap_market", "capetown")},
	oncomplete = {AwardHappiness("cap_marketkeep", 100), IncrementVariable("lab"), IncrementVariable("rank2_work"), AwardItem("b10", -18), AwardItem("sugar", 1000), AwardDiscoverPreference("cap_marketkeep", "like", "mint")},
	oncomplete_medium = {AwardHappiness("cap_marketkeep", 100), IncrementVariable("lab"), IncrementVariable("rank2_work"), AwardItem("b10", -32), AwardItem("sugar", 1500), AwardDiscoverPreference("cap_marketkeep", "like", "mint")},
	oncomplete_hard = {AwardHappiness("cap_marketkeep", 100), IncrementVariable("lab"), IncrementVariable("rank2_work"), AwardItem("b10", -46), AwardItem("sugar", 2000), AwardDiscoverPreference("cap_marketkeep", "like", "mint")},
	require = {RequireMinRank(2), RequireQuestComplete("rank2_03")},
}

CreateQuest
{
	name = "rank2_07",
	starter = "evil_bian",
	accept = "deal",
	defer = "maybelater",
	reject = "never",
	goals = { RequireItem("b11", 25), HintPerson("evil_bian", "tan_bar", "tangiers")},
	goals_medium = { RequireItem("b11", 50), HintPerson("evil_bian", "tan_bar", "tangiers")},
	goals_hard = { RequireItem("b11", 100), HintPerson("evil_bian", "tan_bar", "tangiers")},
	onaccept = {AwardItem("honey", 100), AwardUnlockIngredient("honey")},
	onreject = {AwardText("rank2_07_rejected")},
	oncomplete = {AwardHappiness("evil_bian", 100), IncrementVariable("rank2_work"), IncrementVariable("lab"), AwardItem("b11", -25), AwardDiscoverPreference("evil_bian", "like", "honey")},
	oncomplete_medium = {AwardHappiness("evil_bian", 100), IncrementVariable("rank2_work"), IncrementVariable("lab"), AwardItem("b11", -50), AwardDiscoverPreference("evil_bian", "like", "honey")},
	oncomplete_hard = {AwardHappiness("evil_bian", 100), IncrementVariable("rank2_work"), IncrementVariable("lab"), AwardItem("b11", -100), AwardDiscoverPreference("evil_bian", "like", "honey")},
	require = { RequireMinRank(2)},
}

CreateQuest
{
	name = "rank2_08",
	starter = "tan_portkeep",
	accept = "yeswecan",
	accept_length = "medium",
	defer = "anothertime",
	defer_length = "medium",
	reject = "none",
	goals = {RequireItem("b09", 2), HintPerson("tan_portkeep", "tan_port", "tangiers")},
	goals_medium = {RequireItem("b09", 10), HintPerson("tan_portkeep", "tan_port", "tangiers")},
	goals_hard = {RequireItem("b09", 25), HintPerson("tan_portkeep", "tan_port", "tangiers")},
	onaccept = {AwardText("rank2_08_extra01"), AwardUnlockIngredient("raspberry"), AwardUnlockCharacter("tan_portkeep")},
	oncomplete = {AwardDelayQuest("rank2_coffee16", 2), IncrementVariable("rank2_work"), IncrementVariable("lab"), AwardItem("b09", -2)},
	oncomplete_medium = {AwardDelayQuest("rank2_coffee16", 2), IncrementVariable("rank2_work"), IncrementVariable("lab"), AwardItem("b09", -10)},
	oncomplete_hard = {AwardDelayQuest("rank2_coffee16", 2), IncrementVariable("rank2_work"), IncrementVariable("lab"), AwardItem("b09", -25)},
	require = {RequireMinRank(2)},
}

CreateQuest
{
	name = "rank2_09_wait",
	starter = "dou_plantationkeep",
	accept = "ok",
	defer = "none",
	reject = "none",
	repeatable = 0,
	require = {RequireMinRank(2), RequireQuestIncomplete("rank2_09"), RequireQuestNotActive("rank2_09")},
	visible = false,
}

CreateQuest
{
	name = "rank2_09",
	starter = "dou_plantationkeep",
	accept = "iagree",
	accept_length = "medium",
	defer = "laterperhaps",
	defer_length = "medium",
	reject = "none",
	priority = 3,
	goals = {RequireItem("b12", 25), HintPerson("dou_plantationkeep", "dou_plantation", "douala")},
	goals_medium = {RequireItem("b12", 40), HintPerson("dou_plantationkeep", "dou_plantation", "douala")},
	goals_hard = {RequireItem("b12", 60), HintPerson("dou_plantationkeep", "dou_plantation", "douala")},
	onaccept = {AwardUnblockBuilding("dou_plantation"), AwardUnlockIngredient("dou_cacao"), AwardUnlockCharacter("dou_plantationkeep")},
	oncomplete = {AwardHappiness("dou_plantationkeep", 100), IncrementVariable("rank2_work"), IncrementVariable("lab"), AwardItem("b12", -25), AwardMoney(40000), AwardDiscoverPreference("dou_plantationkeep", "like", "dou_cacao")},
	oncomplete_medium = {AwardHappiness("dou_plantationkeep", 100), IncrementVariable("rank2_work"), IncrementVariable("lab"), AwardItem("b12", -40), AwardMoney(60000), AwardDiscoverPreference("dou_plantationkeep", "like", "dou_cacao")},
	oncomplete_hard = {AwardHappiness("dou_plantationkeep", 100), IncrementVariable("rank2_work"), IncrementVariable("lab"), AwardItem("b12", -60), AwardMoney(85000), AwardDiscoverPreference("dou_plantationkeep", "like", "dou_cacao")},
	require = {RequireMinRank(2), RequireAbsoluteTime(24)},
}

CreateQuest
{
	name = "rank2_10",
	starter = "zur_mountainkeep",
	ender = "zur_schoolkeep",
	accept = "iwill",
	accept_length = "medium",
	defer = "noimtoobusy",
	defer_length = "medium",
	reject = "none",
	onaccept = {AwardMoney(12000), AwardUnlockIngredient("orange"), AwardUnlockCharacter("zur_mountainkeep")},
	onaccept_medium = {AwardMoney(15000), AwardUnlockIngredient("orange"), AwardUnlockCharacter("zur_mountainkeep")},
	onaccept_hard = {AwardMoney(20000), AwardUnlockIngredient("orange"), AwardUnlockCharacter("zur_mountainkeep")},
	goals = { RequireItem("b07", 11), HintPerson("zur_schoolkeep", "zur_school", "zurich")},
	goals_medium = { RequireItem("b07", 22), HintPerson("zur_schoolkeep", "zur_school", "zurich")},
	goals_hard = { RequireItem("b07", 33), HintPerson("zur_schoolkeep", "zur_school", "zurich")},
	oncomplete = {IncrementVariable("rank2_work"),  AwardItem("b07", -11)},
	oncomplete_medium = {IncrementVariable("rank2_work"),  AwardItem("b07", -22)},
	oncomplete_hard = {IncrementVariable("rank2_work"),  AwardItem("b07", -33)},
	require = { RequireMinRank(2), RequireQuestComplete("tedd_welcome")},
}

CreateQuest
{
	name = "rank2_11",
	starter = "zur_bankkeep",
	accept = "iwill",
	defer = "notnow",
	reject = "nosorry",
	onaccept = {AwardUnlockIngredient("lemon"), AwardUnlockCharacter("zur_bankkeep")},
	goals = { RequireItem("b08", 20), HintPerson("zur_bankkeep", "zur_bank", "zurich")},
	goals_medium = { RequireItem("b08", 35), HintPerson("zur_bankkeep", "zur_bank", "zurich")},
	goals_hard = { RequireItem("b08", 50), HintPerson("zur_bankkeep", "zur_bank", "zurich")},
	oncomplete = {IncrementVariable("rank2_work"), AwardMoney(15000), AwardItem("b08", -20)},
	oncomplete_medium = {IncrementVariable("rank2_work"), AwardMoney(25000), AwardItem("b08", -35)},
	oncomplete_hard = {IncrementVariable("rank2_work"), AwardMoney(32500), AwardItem("b08", -50)},
	require = { RequireMinRank(2), RequireQuestComplete("tedd_welcome")},
}

CreateQuest
{
	name = "rank2_12",
	starter = "zur_stationkeep",
	accept = "yes",
	accept_length = "medium",
	defer = "inawhile",
	defer_length = "medium",
	reject = "notinterested",
	reject_length = "medium",
	onaccept = {AwardUnlockCharacter("zur_stationkeep")},
	goals = { RequireItem("b01", 40), HintPerson("zur_stationkeep", "zur_station", "zurich")},
	goals_medium = { RequireItem("b01", 60), HintPerson("zur_stationkeep", "zur_station", "zurich")},
	goals_hard = { RequireItem("b01", 80), HintPerson("zur_stationkeep", "zur_station", "zurich")},
	oncomplete = {IncrementVariable("rank2_work"), AwardMoney(5000), AwardItem("b01", -40), AwardDiscoverPreference("zur_stationkeep", "like", "b01")},
	oncomplete_medium = {IncrementVariable("rank2_work"), AwardMoney(7500), AwardItem("b01", -60), AwardDiscoverPreference("zur_stationkeep", "like", "b01")},
	oncomplete_hard = {IncrementVariable("rank2_work"), AwardMoney(11000), AwardItem("b01", -80), AwardDiscoverPreference("zur_stationkeep", "like", "b01")},
	require = {RequireMinRank(2), RequireQuestComplete("tedd_welcome")},
}

CreateQuest
{
	name = "new_ingredients",
	starter = "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11",
	accept = "ok",
	defer = "none",
	reject = "none",
	visible = false,
	onaccept = {AwardUnlockIngredient("anise"), AwardUnlockIngredient("currant"), AwardUnlockIngredient("pepper")},
	require = { RequireMinRank(2), RequireVariableMoreThan("lab", 3)}, 
}

CreateQuest
{
	name = "open_reyk_prompt",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	ender = "main_feli",
	priority = 1,
	accept = "ok",
	defer = "none",
	reject = "none",
	repeatable = 6,
	onaccept = {AwardDelayQuest("rank2_precoffee_hint", 5)},
	goals = {HintPerson("main_feli", "cap_factory", "capetown")},
	require = { RequireMinRank(2),  RequireVariableMoreThan("rank2_work", 1), RequireQuestNotActive("open_reyk"), RequireQuestIncomplete("open_reyk")},
	require_medium = { RequireMinRank(2),  RequireVariableMoreThan("rank2_work", 2), RequireQuestNotActive("open_reyk"), RequireQuestIncomplete("open_reyk")},
	require_hard = { RequireMinRank(2),  RequireVariableMoreThan("rank2_work", 3), RequireQuestNotActive("open_reyk"), RequireQuestIncomplete("open_reyk")},
	oncomplete = {AwardOfferQuest("open_reyk")},
}

CreateQuest
{
	name = "open_reyk",
	starter = "main_feli",
	ender = "main_tedd",
	accept = "imlistening",
	defer = "none",
	reject = "none",
	priority = 2,
	require = { RequireMinRank(2),  RequireVariableMoreThan("rank2_work", 1)},
	require_medium = { RequireMinRank(2),  RequireVariableMoreThan("rank2_work", 2)},
	require_hard = { RequireMinRank(2),  RequireVariableMoreThan("rank2_work", 3)},
	onaccept = {AwardText("open_reyk_extra01"), AwardUnlockPort("reykjavik"), AwardCustomSlot(), AwardDelayQuest("ugr_prompt", 15), AwardDelayQuest("open_reyk_prompt", 28)},
	goals = {HintPerson("main_tedd", "rey_kitchen", "reykjavik")},
	oncomplete = {AwardOfferQuest("tedd_welcome")},  
}

CreateQuest
{
	name = "tedd_welcome",
	starter = "main_tedd",
	accept = "thankyou",
	defer = "none",
	reject = "none",
	onaccept = {AwardText("tedd_welcome_extra01"), AwardDelayQuest("ugr_01", 1), AwardDelayQuest("rank2_coffee01_prompt", 6), AwardDelayQuest("rank2_coffee01", 6), AwardUnlockCharacter("main_tedd"), AwardDiscoverPreference("main_tedd", "like", "user")},
}

CreateQuest
{
	name = "ugr_prompt",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	priority = 2,
	require = { RequireMinRank(2), RequireVariableMoreThan("ugr_slots", 0), RequirePort("reykjavik")},
	repeatable = 14,
	visible = false,
}

CreateQuest
{
	name = "ugr_01",
	starter = "announcer",
	ender = "zur_shopkeep",
	accept = "nicetomeetyou",
	defer = "none",
	reject = "none",
	onaccept = {AwardText("ugr_01_extra01"), AwardUnlockCharacter("announcer")},
	require = { RequireMinRank(2), RequireQuestComplete("tedd_welcome"), RequireRecipesKnown(1, "user")},
	goals = { RequireItem("user1", 10), HintPerson("zur_shopkeep", "zur_shop", "zurich")},
	goals_medium = { RequireItem("user1", 15), HintPerson("zur_shopkeep", "zur_shop", "zurich")},
	goals_hard = { RequireItem("user1", 25), HintPerson("zur_shopkeep", "zur_shop", "zurich")},
	oncomplete = {AwardHappiness("zur_shopkeep", 100), AwardItem("user1", -10), AwardMoney(10000), AwardDelayQuest("ugr_02", 8), AwardDiscoverPreference("announcer", "like", "user")},  
	oncomplete_medium = {AwardHappiness("zur_shopkeep", 100), AwardItem("user1", -15), AwardMoney(15000), AwardDelayQuest("ugr_02", 8), AwardDiscoverPreference("announcer", "like", "user")},  
	oncomplete_hard = {AwardHappiness("zur_shopkeep", 100), AwardItem("user1", -25), AwardMoney(25000), AwardDelayQuest("ugr_02", 8), AwardDiscoverPreference("announcer", "like", "user")},
    isReal = true,
}

CreateQuest
{
	name = "rank2_coffee01_prompt",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	priority = 20,
	repeatable = 8,
	visible = false,
	require = { RequireMinRank(2), RequireQuestComplete("tedd_welcome"), RequireRecipe("user1"), RequireVariableMoreThan("rank2_work", 4), RequireQuestNotActive("rank2_coffee01"), RequireQuestIncomplete("rank2_coffee01")}, 
}

CreateQuest
{
	name = "rank2_coffee01_ugr_prompt",
	starter = "main_feli",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	priority = 1,
	repeatable = 0,
	visible = false,
	require = { RequireMinRank(2), RequireQuestComplete("tedd_welcome"), RequireVariableMoreThan("rank2_work", 3), RequireVariableMoreThan("ugr_slots", 0), RequireQuestNotActive("rank2_coffee01"), RequireQuestIncomplete("rank2_coffee01")}, 
}

CreateQuest
{
	name = "rank2_coffee01",
	starter = "main_feli",
	priority = 2,
	accept = "indeed",
	defer = "notnow",
	reject = "none",
	autoComplete = true,
	onaccept = {AwardUnlockPort("kona"), AwardUnlockIngredient("kon_coffee"), AwardUnlockIngredient("cream"), AwardOfferQuest("rank2_coffee02")},
	require = { RequireMinRank(2), RequireQuestComplete("tedd_welcome"), RequireRecipe("user1"), RequireVariableMoreThan("rank2_work", 3)}, 
}

CreateQuest
{
	name = "rank2_coffee02",
	starter = "main_feli",
	ender = "kon_marketkeep",
	accept = "thanks",
	defer = "none",
	reject = "none",
	onaccept = {AwardMoney(15000)},
	onaccept_medium = {AwardMoney(20000)},
	onaccept_hard = {AwardMoney(25000)},
	require = { RequireMinRank(2), RequireQuestActive("rank2_coffee01")},
	goals = { HintPerson("kon_marketkeep", "kon_market", "kona")},
	oncomplete = {AwardHappiness("kon_marketkeep", 100), AwardItem("kon_coffee", 75), AwardDialog("inventory"), AwardOfferQuest("rank2_coffee02b"), AwardUnlockCharacter("kon_marketkeep")},
	oncomplete_medium = {AwardHappiness("kon_marketkeep", 100), AwardItem("kon_coffee", 60), AwardDialog("inventory"), AwardOfferQuest("rank2_coffee02b"), AwardUnlockCharacter("kon_marketkeep")},
	oncomplete_hard = {AwardHappiness("kon_marketkeep", 100), AwardItem("kon_coffee", 45), AwardDialog("inventory"), AwardOfferQuest("rank2_coffee02b"), AwardUnlockCharacter("kon_marketkeep")},
}

CreateQuest
{
	name = "rank2_coffee02_help_feli",
	starter = "main_feli",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	priority = 1,
	repeatable = 0,
	visible = false,
	require = { RequireMinRank(2), RequireQuestActive("rank2_coffee02"), RequireQuestIncomplete("rank2_coffee02")},
}

CreateQuest
{
	name = "rank2_coffee02b",
	starter = "kon_marketkeep",
	ender = "main_feli",
	accept = "understood",
	defer = "none",
	reject = "none",
	require = { RequireMinRank(2), RequireQuestComplete("rank2_coffee02")},
	goals = {RequireItem("kon_coffee", 1), RequireItem("cream", 1), RequireItem("sugar", 1), HintPerson("main_feli", "cap_factory", "capetown")},
	oncomplete = {AwardOfferQuest("rank2_coffee03"), AwardUnlockIngredient("honey")},
}

CreateQuest
{
	name = "rank2_coffee03",
	starter = "main_feli",
	ender = "zur_schoolkeep",	
	accept = "imready",
	defer = "none",
	reject = "none",
	require = { RequireMinRank(2), RequireQuestComplete("rank2_coffee02b")},
	onaccept = {AwardUnblockBuilding("cap_factory"), AwardBuildingOwned("cap_factory"), AwardRecipe("c01")},
	goals = {RequireItem("c01", 20),  HintPerson("zur_schoolkeep", "zur_school", "zurich")},
	goals_medium = {RequireItem("c01", 35),  HintPerson("zur_schoolkeep", "zur_school", "zurich")},
	goals_hard = {RequireItem("c01", 50),  HintPerson("zur_schoolkeep", "zur_school", "zurich")},
	oncomplete = {AwardMoney(10000), AwardItem("c01", -20), AwardRecipe("c05"), AwardDialog("recipes"), IncrementVariable("coffee"), AwardDelayQuest("rank2_coffee13", 5), AwardDelayQuest("ugr_02", 7)},
	oncomplete_medium = {AwardMoney(16000), AwardItem("c01", -35), AwardRecipe("c05"), AwardDialog("recipes"), IncrementVariable("coffee"), AwardDelayQuest("rank2_coffee13", 5), AwardDelayQuest("ugr_02", 7)},
	oncomplete_hard = {AwardMoney(20000), AwardItem("c01", -50), AwardRecipe("c05"), AwardDialog("recipes"), IncrementVariable("coffee"), AwardDelayQuest("rank2_coffee13", 5), AwardDelayQuest("ugr_02", 7)},
}


CreateQuest
{
	name = "meta_feli",
	starter = "main_feli",
	accept = "imlistening",
	defer = "none",
	reject = "none",
	require = { RequireMinRank(2), RequireQuestComplete("rank2_coffee03")},
	onaccept = {AwardText("meta_feli_extra01"), AwardOfferQuest("rank2_coffee04")},
	goals = {RequireRecipesMade(5, "beverage"), RequireShopsOwned(1), HintPerson("main_feli", "cap_factory", "capetown")},
	goals_medium = {RequireRecipesMade(6, "beverage"), RequireShopsOwned(1), HintPerson("main_feli", "cap_factory", "capetown")},
	goals_hard = {RequireRecipesMade(8, "beverage"), RequireShopsOwned(1), HintPerson("main_feli", "cap_factory", "capetown")},
	oncomplete = {IncrementVariable("endorsed"), AwardEnableOrderForChar("main_feli"), AwardEnableOrderForBuilding("cap_factory")},
}

CreateQuest
{
	name = "rank2_coffee04",
	starter = "main_feli",
	ender = "zur_schoolkeep",	
	accept = "sure",
	defer = "anothertime",
	reject = "nothankyou",
	require = { RequireQuestActive("meta_feli")},
--	onaccept = {AwardUnblockBuilding("cap_factory"), AwardBuildingOwned("cap_factory"), AwardRecipe("c01")},
	goals = {RequireItem("c05", 75),  HintPerson("zur_schoolkeep", "zur_school", "zurich")},
	goals_medium = {RequireItem("c05", 100),  HintPerson("zur_schoolkeep", "zur_school", "zurich")},
	goals_hard = {RequireItem("c05", 125),  HintPerson("zur_schoolkeep", "zur_school", "zurich")},
	oncomplete = {AwardMoney(50000), AwardItem("c05", -75), IncrementVariable("coffee")},
	oncomplete_medium = {AwardMoney(62500), AwardItem("c05", -100), IncrementVariable("coffee")},
	oncomplete_hard = {AwardMoney(75000), AwardItem("c05", -125), IncrementVariable("coffee")},
}

CreateQuest
{
	name = "rank2_coffee05",
	starter = "tan_hotelkeep",	
	accept = "illdoit",
	defer = "maybelater",
--	reject = "none",
	require = { RequireRecipe("c01"), RequireRecipe("c05"), RequireRecipe("c07")},
	goals = {RequireItem("c01", 65), RequireItem("c05", 65), RequireItem("c07", 65), HintPerson("tan_hotelkeep", "tan_hotel", "tangiers")},
	goals_medium = {RequireItem("c01", 80), RequireItem("c05", 80), RequireItem("c07", 80), HintPerson("tan_hotelkeep", "tan_hotel", "tangiers")},
	goals_hard = {RequireItem("c01", 100), RequireItem("c05", 100), RequireItem("c07", 100), HintPerson("tan_hotelkeep", "tan_hotel", "tangiers")},
	oncomplete = {AwardItem("c01", -65), AwardItem("c05", -65), AwardItem("c07", -65), AwardMoney(80000), IncrementVariable("coffee"), AwardUnlockCharacter("tan_hotelkeep")},
	oncomplete_medium = {AwardItem("c01", -80), AwardItem("c05", -80), AwardItem("c07", -80), AwardMoney(95000), IncrementVariable("coffee"), AwardUnlockCharacter("tan_hotelkeep")},
	oncomplete_hard = {AwardItem("c01", -100), AwardItem("c05", -100), AwardItem("c07", -100), AwardMoney(110000), IncrementVariable("coffee"), AwardUnlockCharacter("tan_hotelkeep")},
}

CreateQuest
{
	name = "rank2_coffee06",
	starter = "kon_marketkeep",	
	accept = "itsadeal",
	defer = "maybelater",
--	reject = "none",
	require = { RequireRecipe("c01"), RequireRecipe("c05")},
	goals = {RequireItem("c01", 75), RequireItem("c05", 75), HintPerson("kon_marketkeep", "kon_market", "kona")},
	goals_medium = {RequireItem("c01", 90), RequireItem("c05", 90), HintPerson("kon_marketkeep", "kon_market", "kona")},
	goals_hard = {RequireItem("c01", 110), RequireItem("c05", 110), HintPerson("kon_marketkeep", "kon_market", "kona")},
	oncomplete = {AwardHappiness("kon_marketkeep", 100), AwardItem("c01", -75), AwardItem("c05", -75), AwardMoney(25000), IncrementVariable("coffee")},
	oncomplete_medium = {AwardHappiness("kon_marketkeep", 100), AwardItem("c01", -90), AwardItem("c05", -90), AwardMoney(30000), IncrementVariable("coffee")},
	oncomplete_hard = {AwardHappiness("kon_marketkeep", 100), AwardItem("c01", -110), AwardItem("c05", -110), AwardMoney(35000), IncrementVariable("coffee")},
}

CreateQuest
{
	name = "rank2_coffee13",
	starter = "trav_01",
	ender = "hav_plantationkeep",
	accept = "yeswedo",
	defer = "askmelater",
	reject = "none",
	priority = 88,
	require = { RequireMinRank(2), RequireQuestComplete("rank2_coffee03"), RequirePort("tangiers"), RequireVariableMoreThan("coffee", 0), RequireCharHasNoActiveOrder("trav_01")},
	onaccept = {AwardText("rank2_coffee13_extra01"), AwardRecipe("c02"), AwardDialog("recipes"), AwardText("rank2_coffee13_extra02"), AwardUnlockPort("havana"), AwardUnlockIngredient("hav_coffee"), AwardUnlockIngredient("allspice"), AwardUnlockIngredient("tea"), AwardUnlockIngredient("banana")},
	goals = {HintPerson("hav_plantationkeep", "hav_plantation", "havana")},
	oncomplete = {AwardHappiness("hav_plantationkeep", 100), IncrementVariable("coffee"), AwardOfferQuest("rank2_coffee14"), AwardUnlockCharacter("hav_marketkeep")},
}

CreateQuest
{
	name = "rank2_coffee14",
	starter = "hav_plantationkeep",
	ender = "trav_01",
	accept = "goodidea",
	defer = "none",
	reject = "none",
	require = { RequireMinRank(2), RequireQuestComplete("rank2_coffee13"), RequireVariableMoreThan("coffee", 0)},
	goals = {RequireItem("c02", 24), RequireRelativeTime(9,false), HintPerson("trav_01", "_travelers")},
	goals_medium = {RequireItem("c02", 36), RequireRelativeTime(9,false), HintPerson("trav_01", "_travelers")},
	goals_hard = {RequireItem("c02", 50), RequireRelativeTime(9,false), HintPerson("trav_01", "_travelers")},
	oncomplete = {AwardItem("c02", -24),  IncrementVariable("coffee"), AwardUnlockCharacter("trav_01")},
	oncomplete_medium = {AwardItem("c02", -36),  IncrementVariable("coffee"), AwardUnlockCharacter("trav_01")},
	oncomplete_hard = {AwardItem("c02", -50),  IncrementVariable("coffee"), AwardUnlockCharacter("trav_01")},
}

CreateQuest
{
	name = "rank2_coffee15",
	starter = "main_feli",
	ender = "tan_portkeep",
	accept = "youbet",
	defer = "anothertime",
	reject = "none",
	require = { RequireMinRank(2), RequireQuestComplete("rank2_coffee13"), RequireQuestComplete("rank2_09"), RequireVariableMoreThan("coffee", 0), RequirePort("tangiers") },
	goals = {RequireItem("b12", 34), HintPerson("tan_portkeep", "tan_port", "tangiers")},
	goals_medium = {RequireItem("b12", 54), HintPerson("tan_portkeep", "tan_port", "tangiers")},
	goals_hard = {RequireItem("b12", 74), HintPerson("tan_portkeep", "tan_port", "tangiers")},
	oncomplete = {AwardUnlockIngredient("rum"), AwardDelayQuest("rank2_coffee16", 2), AwardDelayQuest("rank2_08", 5), AwardItem("b12", -34), AwardRecipe("c03"), AwardDialog("recipes"), AwardUnlockIngredient("tan_coffee"), IncrementVariable("coffee")},
	oncomplete_medium = {AwardUnlockIngredient("rum"), AwardDelayQuest("rank2_coffee16", 2), AwardDelayQuest("rank2_08", 5), AwardItem("b12", -54), AwardRecipe("c03"), AwardDialog("recipes"), AwardUnlockIngredient("tan_coffee"), IncrementVariable("coffee")},
	oncomplete_hard = {AwardUnlockIngredient("rum"), AwardDelayQuest("rank2_coffee16", 2), AwardDelayQuest("rank2_08", 5), AwardItem("b12", -74), AwardRecipe("c03"), AwardDialog("recipes"), AwardUnlockIngredient("tan_coffee"), IncrementVariable("coffee")},
}

CreateQuest
{
	name = "rank2_coffee16",
	starter = "tan_portkeep",
	ender = "tan_marketkeep",
	accept = "iwould",
	defer = "notrightnow",
	reject = "none",
	require = { RequireMinRank(2), RequireQuestComplete("rank2_coffee15")},
	onaccept = {AwardRecipe("c04"), AwardDialog("recipes"), AwardText("rank2_coffee16_extra01"),},
	goals = {RequireItem("b03", 60), HintPerson("tan_marketkeep", "tan_market", "tangiers")},
	goals_medium = {RequireItem("b03", 80), HintPerson("tan_marketkeep", "tan_market", "tangiers")},
	goals_hard = {RequireItem("b03", 100), HintPerson("tan_marketkeep", "tan_market", "tangiers")},
	oncomplete = {AwardUnlockIngredient("cinnamon"), AwardItem("b03", -60), AwardItem("cinnamon", 200), IncrementVariable("coffee"), AwardUnlockCharacter("tan_marketkeep")},
	oncomplete_medium = {AwardUnlockIngredient("cinnamon"), AwardItem("b03", -80), AwardItem("cinnamon", 250), IncrementVariable("coffee"), AwardUnlockCharacter("tan_marketkeep")},
	oncomplete_hard = {AwardUnlockIngredient("cinnamon"), AwardItem("b03", -100), AwardItem("cinnamon", 300), IncrementVariable("coffee"), AwardUnlockCharacter("tan_marketkeep")},
}

CreateQuest
{
	name = "rank2_coffee17a_prompt",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = { RequireMinRank(2), RequireVariableMoreThan("coffee", 5), RequireQuestIncomplete("rank2_coffee17a")},
	visible = false,
	repeatable = 30,
}

CreateQuest
{
	name = "rank2_coffee17a",
	starter = "cap_marketkeep",
	accept = "thankyou",
	defer = "none",
	reject = "none",
	require = { RequireMinRank(2), RequireVariableMoreThan("coffee", 3) },
	onaccept = {AwardUnlockIngredient("whipped_cream"), AwardDelayQuest("rank2_coffee17b", 4)},
	visible = false,
}

CreateQuest
{
	name = "rank2_coffee17b",
	starter = "trav_11",
	ender = "zur_bankkeep",
	accept = "ofcourse",
	defer = "askmelater",
	reject = "none",
	priority = 333,
	require = { RequireMinRank(2), RequireQuestComplete("rank2_coffee17a")},
	onaccept = {AwardRecipe("c08"), AwardDialog("recipes")},
	goals = {RequireItem("c08", 28), HintPerson("zur_bankkeep", "zur_bank", "zurich")},
	goals_medium = {RequireItem("c08", 40), HintPerson("zur_bankkeep", "zur_bank", "zurich")},
	goals_hard = {RequireItem("c08", 55), HintPerson("zur_bankkeep", "zur_bank", "zurich")},
	oncomplete = {AwardUnlockIngredient("nutmeg"), AwardItem("c08", -28), AwardMoney(45000), IncrementVariable("coffee")},
	oncomplete_medium = {AwardUnlockIngredient("nutmeg"), AwardItem("c08", -40), AwardMoney(60000), IncrementVariable("coffee")},
	oncomplete_hard = {AwardUnlockIngredient("nutmeg"), AwardItem("c08", -55), AwardMoney(75000), IncrementVariable("coffee")},
}

CreateQuest
{
	name = "rank2_tangiers",
	starter = "trav_11",
	accept = "sure",
	defer = "maybelater",
	reject = "none",
	priority = 1,
	require = {RequireNoOffers(2), RequireNoCompletes(1), RequireRecipe("c05"), RequireMinRank(2), RequireVariableMoreThan("rank2_work", 3), RequireAbsoluteTime(35), RequireQuestComplete("rank2_coffee03") },
	onaccept = {AwardText("rank2_tangiers_extra01"), AwardDelayQuest("rank2_coffee13", 12)},
	goals = {RequireItem("b05", 10), RequireRelativeTime(5,false), HintPerson("trav_11", "_travelers")},
	goals_medium = {RequireItem("b05", 20), RequireRelativeTime(6,false), HintPerson("trav_11", "_travelers")},
	goals_hard = {RequireItem("b05", 30), RequireRelativeTime(7,false), HintPerson("trav_11", "_travelers")},
	oncomplete = {AwardItem("b05", -10), AwardMoney(5000), AwardUnlockPort("tangiers"), AwardUnlockIngredient("tan_coffee"), IncrementVariable("lab"), IncrementVariable("rank2_work"), AwardOfferQuest("rank2_tangiersb"), AwardUnlockCharacter("trav_11")},
	oncomplete_medium = {AwardItem("b05", -20), AwardMoney(7500), AwardUnlockPort("tangiers"), AwardUnlockIngredient("tan_coffee"), IncrementVariable("lab"), IncrementVariable("rank2_work"), AwardOfferQuest("rank2_tangiersb"), AwardUnlockCharacter("trav_11")},
	oncomplete_hard = {AwardItem("b05", -30), AwardMoney(10000), AwardUnlockPort("tangiers"), AwardUnlockIngredient("tan_coffee"), IncrementVariable("lab"), IncrementVariable("rank2_work"), AwardOfferQuest("rank2_tangiersb"), AwardUnlockCharacter("trav_11")},
}

CreateQuest
{
	name = "rank2_tangiersb",
	starter = "trav_11",
	ender = "tan_hotelkeep",
	accept = "soundsgood",
	defer = "notnow",
	reject = "none",
	goals = { RequireItem("b07", 12), HintPerson("tan_hotelkeep", "tan_hotel", "tangiers")},
	goals_medium = { RequireItem("b07", 20), HintPerson("tan_hotelkeep", "tan_hotel", "tangiers")},
	goals_hard = { RequireItem("b07", 30), HintPerson("tan_hotelkeep", "tan_hotel", "tangiers")},
	oncomplete = {AwardItem("b07", -12), AwardMoney(15000),  IncrementVariable("lab"), IncrementVariable("rank2_work")},
	oncomplete_medium = {AwardItem("b07", -20), AwardMoney(22500),  IncrementVariable("lab"), IncrementVariable("rank2_work")},
	oncomplete_hard = {AwardItem("b07", -30), AwardMoney(30000),  IncrementVariable("lab"), IncrementVariable("rank2_work")},
	require = { RequireMinRank(2), RequireQuestComplete("rank2_tangiers")},
}

CreateQuest
{
	name = "rank2_coffee18_prompt",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	priority = 15,
	onaccept = {AwardDelayQuest("rank2_coffee18_prompt", 19)},
	require = { RequireNoCompletes(2), RequireMinRank(2), RequireIngredientAvailable("tan_coffee"), RequireRecipe("c01"), RequireRecipe("user2"), RequirePort("tangiers"), RequireQuestIncomplete("rank2_coffee18"), RequireQuestNotActive("rank2_coffee18")},
	repeatable = 7,
	visible = false,
}

CreateQuest
{
	name = "rank2_coffee18",
	starter = "main_zach",
	accept = "itsadeal",
	defer = "later",
	reject = "none",
	onaccept = {AwardMoney(10000), AwardRecipe("c07"), AwardDialog("recipes"), AwardText("rank2_coffee18_extra01"), AwardUnlockCharacter("main_loud")},
	onaccept_medium = {AwardMoney(12500), AwardRecipe("c07"), AwardDialog("recipes"), AwardText("rank2_coffee18_extra01"), AwardUnlockCharacter("main_loud")},
	onaccept_hard = {AwardMoney(15000), AwardRecipe("c07"), AwardDialog("recipes"), AwardText("rank2_coffee18_extra01"), AwardUnlockCharacter("main_loud")},
	goals = { RequireItem("c07", 40), HintPerson("main_zach", "tan_shop", "tangiers")},
	goals_medium = { RequireItem("c07", 55), HintPerson("main_zach", "tan_shop", "tangiers")},
	goals_hard = { RequireItem("c07", 75), HintPerson("main_zach", "tan_shop", "tangiers")},
	oncomplete = {IncrementVariable("coffee"), IncrementVariable("tanshop"), AwardItem("c07", -40), AwardRecipe("c12"), AwardDialog("recipes"), AwardText("rank2_coffee18_extra02"), AwardText("rank2_coffee18_extra03"), AwardOfferQuest("tanshop_01"), AwardUnlockIngredient("fig")},
	oncomplete_medium = {IncrementVariable("coffee"), IncrementVariable("tanshop"), AwardItem("c07", -55), AwardRecipe("c12"), AwardDialog("recipes"), AwardText("rank2_coffee18_extra02"), AwardText("rank2_coffee18_extra03"), AwardOfferQuest("tanshop_01"), AwardUnlockIngredient("fig")},
	oncomplete_hard = {IncrementVariable("coffee"), IncrementVariable("tanshop"), AwardItem("c07", -75), AwardRecipe("c12"), AwardDialog("recipes"), AwardText("rank2_coffee18_extra02"), AwardText("rank2_coffee18_extra03"), AwardOfferQuest("tanshop_01"), AwardUnlockIngredient("fig")},
	require = {RequireMinRank(2), RequireIngredientAvailable("tan_coffee"), RequireRecipe("c01"), RequireRecipe("user2")},
}

CreateQuest
{
	name = "tanshop_01",
	starter = "main_zach",
	accept = "ofcourse",
	defer = "maybelater",
	reject = "none",
	goals = { RequireItem("b12", 100), HintPerson("main_zach", "tan_shop", "tangiers")},
	goals_medium = { RequireItem("b12", 150), HintPerson("main_zach", "tan_shop", "tangiers")},
	goals_hard = { RequireItem("b12", 200), HintPerson("main_zach", "tan_shop", "tangiers")},
	onaccept = {AwardText("tanshop_01_extra01")},
	oncomplete = {AwardItem("b12", -100), IncrementVariable("tanshop"), AwardOfferQuest("tanshop_02")},
	oncomplete_medium = {AwardItem("b12", -150), IncrementVariable("tanshop"), AwardOfferQuest("tanshop_02")},
	oncomplete_hard = {AwardItem("b12", -200), IncrementVariable("tanshop"), AwardOfferQuest("tanshop_02")},
	require = {RequireQuestComplete("rank2_coffee18")},
}

CreateQuest
{
	name = "tanshop_02",
	starter = "main_zach",
	accept = "iunderstand",
	defer = "none",
	reject = "none",
	goals = { RequireItem("c05", 100), RequireItem("user2", 100), HintPerson("main_zach", "tan_shop", "tangiers")},
	goals_medium = { RequireItem("c05", 150), RequireItem("user2", 150), HintPerson("main_zach", "tan_shop", "tangiers")},
	goals_hard = { RequireItem("c05", 200), RequireItem("user2", 200), HintPerson("main_zach", "tan_shop", "tangiers")},
	oncomplete = { IncrementVariable("tanshop"), AwardItem("user2", -100), AwardItem("c05", -100), AwardBuildingOwned("tan_shop"), IncrementVariable("shopsowned"), AwardText("tanshop_02_extra01"), AwardDelayQuest("tan_shop_owned_00", 11), AwardUnlockCharacter("main_zach"), AwardUnlockCharacter("tor_bldg2keep"), AwardUnlockCharacter("wel_bldg1keep"), AwardUnlockCharacter("dou_bldg1keep"), AwardUnlockCharacter("bag_bldg2keep"), AwardUnlockCharacter("kon_bldg2keep"), AwardUnlockCharacter("rey_xxxxkeep"), AwardUnlockCharacter("tor_bldg1keep"), AwardUnlockCharacter("zur_riverkeep"), AwardUnlockCharacter("tor_bldg2keep")},
	oncomplete_medium = { IncrementVariable("tanshop"), AwardItem("user2", -150), AwardItem("c05", -150), AwardBuildingOwned("tan_shop"), IncrementVariable("shopsowned"), AwardText("tanshop_02_extra01"), AwardDelayQuest("tan_shop_owned_00", 11), AwardUnlockCharacter("main_zach"), AwardUnlockCharacter("tor_bldg2keep"), AwardUnlockCharacter("wel_bldg1keep"), AwardUnlockCharacter("dou_bldg1keep"), AwardUnlockCharacter("bag_bldg2keep"), AwardUnlockCharacter("kon_bldg2keep"), AwardUnlockCharacter("rey_xxxxkeep"), AwardUnlockCharacter("tor_bldg1keep"), AwardUnlockCharacter("zur_riverkeep"), AwardUnlockCharacter("tor_bldg2keep")},
	oncomplete_hard = { IncrementVariable("tanshop"), AwardItem("user2", -200), AwardItem("c05", -200), AwardBuildingOwned("tan_shop"), IncrementVariable("shopsowned"), AwardText("tanshop_02_extra01"), AwardDelayQuest("tan_shop_owned_00", 11), AwardUnlockCharacter("main_zach"), AwardUnlockCharacter("tor_bldg2keep"), AwardUnlockCharacter("wel_bldg1keep"), AwardUnlockCharacter("dou_bldg1keep"), AwardUnlockCharacter("bag_bldg2keep"), AwardUnlockCharacter("kon_bldg2keep"), AwardUnlockCharacter("rey_xxxxkeep"), AwardUnlockCharacter("tor_bldg1keep"), AwardUnlockCharacter("zur_riverkeep"), AwardUnlockCharacter("tor_bldg2keep")},
	require = {RequireQuestComplete("tanshop_01")},
}

CreateQuest
{
	name = "rank2_coffee19_prompt",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	accept = "illdoit",
	defer = "none",
	reject = "none",
	repeatable = 25,
	autoComplete = true,
	visible = false,
	require = { RequireMinRank(2), RequireQuestComplete("rank2_coffee17b"), RequirePort("tangiers"), RequireQuestIncomplete("rank2_coffee19"), RequireQuestNotActive("rank2_coffee19")},
}

CreateQuest
{
	name = "rank2_coffee19",
	starter = "hav_hotelkeep",
	accept = "certainly",
	defer = "askmelater",
	reject = "none",
	onaccept = {AwardRecipe("c11"), AwardDialog("recipes")},
	goals = { RequireItem("c11", 15), RequireItem("c08", 15), HintPerson("hav_hotelkeep", "hav_hotel", "havana")},
	goals_medium = { RequireItem("c11", 25), RequireItem("c08", 25), HintPerson("hav_hotelkeep", "hav_hotel", "havana")},
	goals_hard = { RequireItem("c11", 40), RequireItem("c08", 40), HintPerson("hav_hotelkeep", "hav_hotel", "havana")},
	oncomplete = {IncrementVariable("coffee"), AwardItem("c11", -15),  AwardItem("c08", -15), AwardUnlockIngredient("whiskey"), AwardRecipe("c06"), AwardDialog("recipes"), AwardUnlockCharacter("hav_hotelkeep")},
	oncomplete_medium = {IncrementVariable("coffee"), AwardItem("c11", -25),  AwardItem("c08", -25), AwardUnlockIngredient("whiskey"), AwardRecipe("c06"), AwardDialog("recipes"), AwardUnlockCharacter("hav_hotelkeep")},
	oncomplete_hard = {IncrementVariable("coffee"), AwardItem("c11", -40),  AwardItem("c08", -40), AwardUnlockIngredient("whiskey"), AwardRecipe("c06"), AwardDialog("recipes"), AwardUnlockCharacter("hav_hotelkeep")},
	require = { RequireMinRank(2), RequireQuestComplete("rank2_coffee17b"), RequirePort("tangiers")},
}

CreateQuest
{
	name = "rank2_coffee20",
	starter = "hav_plantationkeep",
	accept = "soundsgood",
	defer = "laterperhaps",
--	reject = "none",
	require = { RequireMinRank(2), RequireRecipe("c03"), RequireIngredientAvailable("kon_coffee"), RequireIngredientAvailable("hav_coffee"), RequireIngredientAvailable("tan_coffee"), RequireNoOffers(1) },
	onaccept = {AwardText("rank2_coffee20_extra01")},
	goals = {RequireItem("c03", 75), HintPerson("hav_plantationkeep", "hav_plantation", "havana")},
	goals_medium = {RequireItem("c03", 90), HintPerson("hav_plantationkeep", "hav_plantation", "havana")},
	goals_hard = {RequireItem("c03", 110), HintPerson("hav_plantationkeep", "hav_plantation", "havana")},
	oncomplete = {AwardItem("c03", -75), AwardItem("hav_coffee", 5000), IncrementVariable("coffee"), AwardUnlockCharacter("hav_plantationkeep")},
	oncomplete_medium = {AwardItem("c03", -90), AwardItem("hav_coffee", 6000), IncrementVariable("coffee"), AwardUnlockCharacter("hav_plantationkeep")},
	oncomplete_hard = {AwardItem("c03", -110), AwardItem("hav_coffee", 7500), IncrementVariable("coffee"), AwardUnlockCharacter("hav_plantationkeep")},
}

CreateQuest
{
	name = "rank2_coffee21",
	starter = "trav_04",
	ender = "ulu_hutkeep",
	accept = "indeed",
	defer = "notinterested",
	reject = "none",
	priority = 99,
	require = {RequireMinRank(2), RequireNoOffers(2), RequireQuestComplete("rank2_38"), RequireCharHasNoActiveOrder("trav_04")},
	onaccept = {AwardText("rank2_coffee21_extra01"), AwardUnlockCharacter("trav_04")},
	goals = {HintPerson("ulu_hutkeep", "ulu_hut", "uluru")},
	followup = "rank2_coffee21b",
}

CreateQuest
{
	name = "rank2_coffee21b",
	starter = "ulu_hutkeep",
	ender = "ulu_hutkeep",
	accept = "iwill",
	defer = "maybelater",
	reject = "none",
	require = {RequireQuestComplete("rank2_coffee21")},
	onaccept = {AwardText("rank2_coffee21b_extra01")},
	goals = {RequireItem("b01", 150), RequireItem("b02", 150), HintPerson("ulu_hutkeep", "ulu_hut", "uluru")},
	goals_medium = {RequireItem("b01", 300), RequireItem("b02", 300), HintPerson("ulu_hutkeep", "ulu_hut", "uluru")},
	goals_hard = {RequireItem("b01", 400), RequireItem("b02", 400), RequireItem("i07", 200), HintPerson("ulu_hutkeep", "ulu_hut", "uluru")},
	oncomplete = {AwardItem("b01", -150), AwardItem("b02", -150), AwardItem("cacao", 5000), AwardHappiness("ulu_hutkeep", 100), IncrementVariable("coffee")},
	oncomplete_medium = {AwardItem("b01", -300), AwardItem("b02", -300), AwardItem("cacao", 7500), AwardHappiness("ulu_hutkeep", 100), IncrementVariable("coffee")},
	oncomplete_hard = {AwardItem("b01", -400), AwardItem("b02", -400), AwardItem("i07", -200), AwardItem("cacao", 10000), AwardHappiness("ulu_hutkeep", 100), IncrementVariable("coffee")},
}

CreateQuest
{
	name = "rank2_coffee22",
	starter = "cap_shopkeep",
	ender = "cap_mountainkeep",
	accept = "sure",
	defer = "none",
	reject = "nothanks",
	require = { RequireMinRank(2), RequireRecipe("c02"), RequireRecipe("c03"), RequireRecipe("c06"), RequireIngredientAvailable("whiskey"), RequireIngredientAvailable("hav_coffee"), RequireIngredientAvailable("tan_coffee"), RequireNoOffers(1) },
	onaccept = {AwardText("rank2_coffee22_extra01"), AwardUnlockCharacter("cap_shopkeep")},
	goals = {RequireItem("c02", 70), RequireItem("c03", 70), RequireItem("c06", 70), HintPerson("cap_mountainkeep", "cap_mountain", "capetown")},
	goals_medium = {RequireItem("c02", 85), RequireItem("c03", 85), RequireItem("c06", 85), HintPerson("cap_mountainkeep", "cap_mountain", "capetown")},
	goals_hard = {RequireItem("c02", 100), RequireItem("c03", 100), RequireItem("c06", 100), HintPerson("cap_mountainkeep", "cap_mountain", "capetown")},
	oncomplete = {AwardItem("c02", -70), AwardItem("c03", -70), AwardItem("c06", -70), AwardMoney(100000), IncrementVariable("coffee")},
	oncomplete_medium = {AwardItem("c02", -85), AwardItem("c03", -85), AwardItem("c06", -85), AwardMoney(115000), IncrementVariable("coffee")},
	oncomplete_hard = {AwardItem("c02", -100), AwardItem("c03", -100), AwardItem("c06", -100), AwardMoney(125000), IncrementVariable("coffee")},
}

CreateQuest
{
	name = "rank2_coffee23",
	starter = "main_feli",
	ender = "trav_07",
	accept = "sure",
	defer = "maybelater",
	reject = "nonever",
	expires = 20,
	expires_medium = 18,
	expires_hard = 16,
	require = { RequireMinRank(2), RequireRecipe("c09"), RequireCharHasNoActiveOrder("trav_07"), RequireBuildingHasNoActiveOrder("cap_building3")},
	onaccept = {AwardText("rank2_coffee23_extra01"), AwardItem("amaretto", 160), AwardUnlockIngredient("amaretto"), AwardRemoveCharacter("trav_07","_travelers"), AwardPlaceCharacter("trav_07","cap_building3"), AwardDisableOrderForChar("trav_07"), AwardDisableOrderForBuilding("cap_building3")},
	goals = {RequireItem("c09", 80), HintPerson("trav_07", "cap_building3", "capetown"), HintExpirationDate()},
	goals_medium = {RequireItem("c09", 95), HintPerson("trav_07", "cap_building3", "capetown"), HintExpirationDate()},
	goals_hard = {RequireItem("c09", 110), HintPerson("trav_07", "cap_building3", "capetown"), HintExpirationDate()},
	oncomplete = {AwardItem("c09", -80), AwardMoney(50000), AwardRemoveCharacter("trav_07", "cap_building3"), AwardPlaceCharacter("trav_07","_travelers"), IncrementVariable("coffee"), AwardEnableOrderForChar("trav_07"), AwardEnableOrderForBuilding("cap_building3"), AwardUnlockCharacter("trav_07")},
	oncomplete_medium = {AwardItem("c09", -95), AwardMoney(57500), AwardRemoveCharacter("trav_07", "cap_building3"), AwardPlaceCharacter("trav_07","_travelers"), IncrementVariable("coffee"), AwardEnableOrderForChar("trav_07"), AwardEnableOrderForBuilding("cap_building3"), AwardUnlockCharacter("trav_07")},
	oncomplete_hard = {AwardItem("c09", -110), AwardMoney(65000), AwardRemoveCharacter("trav_07", "cap_building3"), AwardPlaceCharacter("trav_07","_travelers"), IncrementVariable("coffee"), AwardEnableOrderForChar("trav_07"), AwardEnableOrderForBuilding("cap_building3"), AwardUnlockCharacter("trav_07")},
	onexpire = {AwardRemoveCharacter("trav_07", "cap_building3"), AwardPlaceCharacter("trav_07","_travelers"), AwardEnableOrderForChar("trav_07"), AwardEnableOrderForBuilding("cap_building3")},
}

CreateQuest
{
	name = "ugr_02",
	starter = "announcer",
	ender = "main_alex",
	accept = "understood",
	defer = "none",
	reject = "none",
	goals = {HintPerson("main_alex", "ulu_rock", "uluru")},
	onaccept = {AwardUnlockPort("uluru"), AwardPlaceCharacter("main_alex", "ulu_rock")},
	oncomplete = {AwardCustomSlot(), AwardDialog("recipes"), AwardText("ugr_02_extra01"), AwardText("ugr_02_extra02"), AwardRemoveCharacter("main_alex", "ulu_rock"), AwardDelayQuest("ugr_prompt", 15), AwardDelayQuest("ugr_02b_prompt", 29)},
	require = { RequireMinRank(2), RequireQuestComplete("ugr_01"), RequireRecipe("c01"), RequireRecipe("c05"), RequireQuestComplete("rank2_coffee03"), RequireNoOffers(2), RequireNoCompletes(1), RequireVariableEqual("ugr_slots", 0)},
	require_medium = { RequireMinRank(2), RequireQuestComplete("ugr_01"), RequireRecipe("c01"), RequireRecipe("c05"), RequireRecipesMade(2, "beverage"), RequireQuestComplete("rank2_coffee03"), RequireNoOffers(2), RequireNoCompletes(1), RequireVariableEqual("ugr_slots", 0)},
	require_hard = { RequireMinRank(2), RequireQuestComplete("ugr_01"), RequireRecipe("c01"), RequireRecipe("c05"), RequireRecipesMade(4, "beverage"), RequireQuestComplete("rank2_coffee03"), RequireNoOffers(2), RequireNoCompletes(1), RequireVariableEqual("ugr_slots", 0)},
    isReal = true,
}

CreateQuest
{
    name = "rank2_ulu_hut",
    starter = "ulu_hutkeep",
    accept = "yesido",
    defer = "notnow",
    reject = "none",
    require = { RequireQuestComplete("ugr_02") },
    onaccept = { AwardText("rank2_ulu_hut_extra01")},
    goals = {RequireItem("b12", 50), HintPerson("ulu_hutkeep", "ulu_hut", "uluru")},
    goals_medium = {RequireItem("b12", 75), HintPerson("ulu_hutkeep", "ulu_hut", "uluru")},
	goals_hard = {RequireItem("b12", 100), HintPerson("ulu_hutkeep", "ulu_hut", "uluru")},
    oncomplete = {AwardItem("b12", -50), AwardUnblockBuilding("ulu_hut"), AwardUnlockIngredient("lime"), AwardUnlockCharacter("ulu_hutkeep"), AwardDiscoverPreference("ulu_hutkeep", "like", "bar"), AwardDiscoverPreference("ulu_hutkeep", "like", "lime")},
    oncomplete_medium = {AwardItem("b12", -75), AwardUnblockBuilding("ulu_hut"), AwardUnlockIngredient("lime"), AwardUnlockCharacter("ulu_hutkeep"), AwardDiscoverPreference("ulu_hutkeep", "like", "bar"), AwardDiscoverPreference("ulu_hutkeep", "like", "lime")},
    oncomplete_hard = {AwardItem("b12", -100), AwardUnblockBuilding("ulu_hut"), AwardUnlockIngredient("lime"), AwardUnlockCharacter("ulu_hutkeep"), AwardDiscoverPreference("ulu_hutkeep", "like", "bar"), AwardDiscoverPreference("ulu_hutkeep", "like", "lime")},
}

CreateQuest
{
	name = "ugr_02b_prompt",
	starter = "announcer",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	visible = false,
	require = { RequireNoOffers(2), RequireQuestIncomplete("ugr_02b"), RequireNoCompletes(1), RequireMinRank(2), RequireQuestComplete("ugr_02"), RequireRecipe("c01"), RequireRecipesKnown(4, "beverage"), RequireVariableEqual("ugr_slots", 0)},
	require_medium = { RequireNoOffers(2), RequireQuestIncomplete("ugr_02b"), RequireNoCompletes(1), RequireMinRank(2), RequireQuestComplete("ugr_02"), RequireRecipe("c01"), RequireRecipesKnown(5, "beverage"), RequireVariableEqual("ugr_slots", 0)},
	require_hard = { RequireNoOffers(2), RequireQuestIncomplete("ugr_02b"), RequireNoCompletes(1), RequireMinRank(2), RequireQuestComplete("ugr_02"), RequireRecipe("c01"), RequireRecipesKnown(6, "beverage"), RequireVariableEqual("ugr_slots", 0)},
    isReal = true,
}

CreateQuest
{
	name = "ugr_02b",
	starter = "announcer",
	accept = "thanks",
	defer = "none",
	reject = "none",
	autoComplete = true,
	onaccept = {AwardCustomSlot(), AwardDialog("recipes"), AwardDelayQuest("ugr_prompt", 10)},
	require = { RequireNoOffers(2), RequireNoCompletes(2), RequireMinRank(2), RequireQuestComplete("ugr_02"), RequireQuestComplete("bali_01"), RequireUserRecipeMade(2,1), RequireRecipe("c01"), RequireRecipesKnown(4, "beverage"), RequireVariableEqual("ugr_slots", 0), AwardUnlockCharacter("rey_marketkeep"), AwardUnlockCharacter("rey_shopkeep")},
	require_medium = { RequireNoOffers(2), RequireNoCompletes(2), RequireMinRank(2), RequireQuestComplete("ugr_02"), RequireQuestComplete("bali_01"), RequireUserRecipeMade(2,1), RequireRecipe("c01"), RequireRecipesKnown(5, "beverage"), RequireVariableEqual("ugr_slots", 0), AwardUnlockCharacter("rey_marketkeep"), AwardUnlockCharacter("rey_shopkeep")},
	require_hard = { RequireNoOffers(2), RequireNoCompletes(2), RequireMinRank(2), RequireQuestComplete("ugr_02"), RequireQuestComplete("bali_01"), RequireUserRecipeMade(2,1), RequireRecipe("c01"), RequireRecipesKnown(6, "beverage"), RequireVariableEqual("ugr_slots", 0), AwardUnlockCharacter("rey_marketkeep"), AwardUnlockCharacter("rey_shopkeep")},
    isReal = true,
}

CreateQuest
{
	name = "ugr_03",
	starter = "announcer",
	accept = "iappreciateit",
	defer = "none",
	reject = "none",
	autoComplete = true,
	onaccept = {AwardCustomSlot(), AwardDialog("recipes"), AwardDelayQuest("ugr_prompt", 15)},
	require = { RequireNoOffers(2), RequireNoCompletes(1), RequireMinRank(2),  RequireQuestComplete("ugr_02b"), RequireRecipe("c01"), RequireRecipesKnown(3, "infusion"), RequireVariableEqual("ugr_slots", 0)},
	require_medium = { RequireNoOffers(2), RequireNoCompletes(1), RequireMinRank(2),  RequireQuestComplete("ugr_02b"), RequireRecipe("c01"), RequireRecipesMade(4, "infusion"), RequireVariableEqual("ugr_slots", 0)},
	require_hard = { RequireNoOffers(2), RequireNoCompletes(1), RequireMinRank(2),  RequireQuestComplete("ugr_02b"), RequireRecipe("c01"), RequireRecipesMade(6, "infusion"), RequireVariableEqual("ugr_slots", 0)},
    isReal = true,
}

CreateQuest
{
	name = "ugr_tease_00",
	starter = "trav_04",
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireMinRank(2), RequireQuestNotActive("open_reyk"), RequireQuestIncomplete("open_reyk")},
	visible = false,
	autoComplete = true,
}

CreateQuest
{
	name = "ugr_tease_01",
	starter = "trav_02",
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireMinRank(2), RequireQuestComplete("rank2_03"), RequireRecipesKnown(0, "user")},
	visible = false,
	autoComplete = true,
}

CreateQuest
{
	name = "ugr_tease_02",
	starter = "zur_shopkeep",
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireMinRank(2), RequireQuestComplete("rank2_03"), RequireQuestIncomplete("ugr_01"), RequireQuestNotActive("ugr_01")},
	visible = false,
	autoComplete = true,
}

CreateQuest
{
	name = "ugr_tease_03",
	starter = {"trav_11", "cap_mountainkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireMinRank(2), RequireRecipesKnown(0, "user"), RequireVariableMoreThan("ugr_slots", 0)},
	visible = false,
	autoComplete = true,
}

CreateQuest
{
	name = "ugr_tease_04",
	starter = "trav_10",
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireMinRank(2), RequireRecipesKnown(0, "user"), RequireVariableMoreThan("ugr_slots", 0)},
	visible = false,
	autoComplete = true,
}

CreateQuest
{
	name = "ugr_tease_05",
	starter = "trav_06",
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireMinRank(2), RequireRecipesKnown(1, "user"), RequireVariableMoreThan("ugr_slots", 0)},
	priority = 3,
	visible = false,
	autoComplete = true,
}

CreateQuest
{
	name = "to_open_bali",
	starter = "announcer",
	ender = "main_alex",
	accept = "loudandclear",
	defer = "none",
	reject = "none",
	require = {RequireNoOffers(3), RequireNoCompletes(1), RequirePort("havana"), RequireMinRank(2), RequireRecipe("user1"), RequireRecipe("user2"), RequireUserRecipeMade(2,1), RequireAbsoluteTime(76)},
	require_medium = {RequireNoOffers(3), RequireNoCompletes(1), RequirePort("havana"), RequireMinRank(2), RequireRecipe("user1"), RequireRecipe("user2"), RequireUserRecipeMade(2,25), RequireAbsoluteTime(76)},
	require_hard = {RequireNoOffers(3), RequireNoCompletes(1), RequirePort("havana"), RequireMinRank(2), RequireRecipe("user1"), RequireRecipe("user2"), RequireUserRecipeMade(2,50), RequireAbsoluteTime(76)},
	onaccept = {AwardPlaceCharacter("main_alex", "hav_hotel")},
	goals = {HintPerson("main_alex", "hav_hotel", "havana")},
	oncomplete = {AwardOfferQuest("open_bali")},
}

CreateQuest
{
	name = "open_bali",
	starter = "main_alex",
	accept = "ihearyou",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireMinRank(2), RequireQuestComplete("to_open_bali")},
	onaccept = {AwardText("open_bali_extra01"), AwardUnlockPort("bali"), AwardRemoveCharacter("main_alex", "hav_hotel"), AwardPlaceCharacter("evil_tyso","_travelers"), AwardPlaceCharacter("evil_kath","_travelers"), AwardPlaceCharacter("evil_wolf","_travelers")},
}

CreateQuest
{
	name = "bali_01",
	starter = "bal_xxxkeep",
	accept = "iwill",
	defer = "later",
	reject = "none",
	goals = { RequireItem("user1", 10), RequireItem("user2", 10), HintPerson("bal_xxxkeep", "bal_plantation", "bali")},
	goals_medium = { RequireItem("user1", 30), RequireItem("user2", 30), HintPerson("bal_xxxkeep", "bal_plantation", "bali")},
	goals_hard = { RequireItem("user1", 50), RequireItem("user2", 50), HintPerson("bal_xxxkeep", "bal_plantation", "bali")},
	oncomplete = {AwardItem("user1", - 10), AwardItem("user2", -10), AwardUnblockBuilding("bal_plantation"), AwardUnlockIngredient("bal_coffee"), AwardUnlockIngredient("bal_cacao"), AwardRecipe("c09"), AwardRecipe("c10"), AwardDialog("recipes"), AwardDelayQuest("ugr_02b", 5), AwardEnableOrderForChar("bal_xxxkeep"), AwardEnableOrderForBuilding("bal_plantation"), AwardUnlockCharacter("bal_xxxkeep")},
	oncomplete_medium = {AwardItem("user1", - 30), AwardItem("user2", -30), AwardUnblockBuilding("bal_plantation"), AwardUnlockIngredient("bal_coffee"), AwardUnlockIngredient("bal_cacao"), AwardRecipe("c09"), AwardRecipe("c10"), AwardDialog("recipes"), AwardDelayQuest("ugr_02b", 5), AwardEnableOrderForChar("bal_xxxkeep"), AwardEnableOrderForBuilding("bal_plantation"), AwardUnlockCharacter("bal_xxxkeep")},
	oncomplete_hard = {AwardItem("user1", - 50), AwardItem("user2", -50), AwardUnblockBuilding("bal_plantation"), AwardUnlockIngredient("bal_coffee"), AwardUnlockIngredient("bal_cacao"), AwardRecipe("c09"), AwardRecipe("c10"), AwardDialog("recipes"), AwardDelayQuest("ugr_02b", 5), AwardEnableOrderForChar("bal_xxxkeep"), AwardEnableOrderForBuilding("bal_plantation"), AwardUnlockCharacter("bal_xxxkeep")},
}

CreateQuest
{
	name = "rank2_tokyo_prompt",
	starter = "main_feli",
	accept = "ok",
	defer = "none",
	reject = "none",
	visible = false,
	repeatable = 5,
	autoComplete = true,
	require = {RequireQuestComplete("meta_feli"), RequireQuestNotActive("rank2_tokyo"), RequireQuestIncomplete("rank2_tokyo")},
}

CreateQuest
{
	name = "rank2_tokyo",
	starter = "main_feli",
	ender = "main_deit",
	accept = "letsgo",
	defer = "none",
	reject = "none",
-- would like to add RequireNoQuestsActive to this quest reqs list
	require = {RequireRecipesMade(6, "beverage"), RequireQuestComplete("meta_feli"), RequireBuildingOwned("tan_shop")},
	require_medium = {RequireRecipesMade(7, "beverage"), RequireQuestComplete("meta_feli"), RequireBuildingOwned("tan_shop")},
	require_hard = {RequireRecipesMade(8, "beverage"), RequireQuestComplete("meta_feli"), RequireBuildingOwned("tan_shop")},
	onaccept = {AwardUnlockPort("tokyo"), AwardUnlockIngredient("chestnut"), AwardUnlockIngredient("wasabi"), AwardUnlockIngredient("matcha"), AwardUnlockIngredient("pecan"), AwardUnlockIngredient("ginger")},
	goals = { HintPerson("main_deit", "tok_factory", "tokyo")},
	oncomplete = {AwardOfferQuest("tokyo_01"), AwardUnlockCharacter("main_deit")},	
}

CreateQuest
{
	name = "tokyo_01",
	starter = "main_deit",
	accept = "thankyou",
	defer = "none",
	reject = "none",
	onaccept = {AwardRecipe("i01"), AwardDialog("recipes"), AwardOfferQuest("meta_deiter")},
}

CreateQuest
{
	name = "meta_deiter",
	starter = "main_deit",
	accept = "understood",
	defer = "none",
	reject = "none",
	onaccept = {AwardUnblockBuilding("tok_factory"), AwardBuildingOwned("tok_factory"), AwardOfferQuest("tokyo_02")},
	goals = {RequireRecipesKnown(9, "infusion"), RequireShopsOwned(2), HintPerson("main_deit", "tok_factory", "tokyo")},
	goals_medium = {RequireRecipesKnown(10, "infusion"), RequireShopsOwned(2), HintPerson("main_deit", "tok_factory", "tokyo")},
	goals_hard = {RequireRecipesKnown(12, "infusion"), RequireShopsOwned(2), HintPerson("main_deit", "tok_factory", "tokyo")},
	oncomplete = {IncrementVariable("endorsed"), AwardEnableOrderForChar("main_deit"), AwardEnableOrderForBuilding("tok_factory"), AwardUnlockCharacter("main_sara")},
}

CreateQuest
{
	name = "tokyo_02",
	starter = "main_deit",
	ender = "evil_bian",
	accept = "illdoit",
	defer = "anothertime",
	reject = "none",
	require = {RequireQuestActive("meta_deiter"), RequireRecipe("i01")},
	onaccept = {AwardText("tokyo_02_extra01")},
	goals = {RequireItem("i01", 32), HintPerson("evil_bian", "tan_bar", "tangiers")},
	goals_medium = {RequireItem("i01", 45), HintPerson("evil_bian", "tan_bar", "tangiers")},
	goals_hard = {RequireItem("i01", 60), HintPerson("evil_bian", "tan_bar", "tangiers")},
	oncomplete = {AwardItem("i01", -32), AwardMoney(20000), AwardUnlockCharacter("evil_bian")},
	oncomplete_medium = {AwardItem("i01", -45), AwardMoney(28000), AwardUnlockCharacter("evil_bian")},
	oncomplete_hard = {AwardItem("i01", -60), AwardMoney(35000), AwardUnlockCharacter("evil_bian")},
}

CreateQuest
{
	name = "rank2_sanfrancisco_prompt",
	starter = {"tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep"},
	ender = "main_evan",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	visible = false,
	require = {RequireRecipesKnown(10, "infusion"), RequireRecipesKnown(3, "user"), RequireQuestIncomplete("konshop_05"), RequireQuestIncomplete("rank2_sanfrancisco"), RequireQuestNotActive("rank2_sanfrancisco"), RequireVariableMoreThan("endorsed", 1)},
	repeatable = 20,
}

CreateQuest
{
	name = "rank2_sanfrancisco",
	starter = {"main_deit", "main_feli"},
	ender = "main_evan",
	accept = "willdo",
	defer = "none",
	reject = "none",
	require = {RequireRecipesKnown(10, "infusion"), RequireRecipesMade(6, "infusion"), RequireRecipesKnown(3, "user"), RequireBuildingOwned("kon_shop"), RequireVariableMoreThan("endorsed", 1)},
	require_medium = {RequireRecipesKnown(10, "infusion"), RequireRecipesMade(7, "infusion"), RequireRecipesKnown(3, "user"), RequireBuildingOwned("kon_shop"), RequireVariableMoreThan("endorsed", 1)},
	require_hard = {RequireRecipesKnown(12, "infusion"), RequireRecipesMade(8, "infusion"), RequireRecipesKnown(3, "user"), RequireBuildingOwned("kon_shop"), RequireVariableMoreThan("endorsed", 1)},
	onaccept = {AwardUnlockPort("sanfrancisco"), AwardUnlockIngredient("raisin")},
	goals = { HintPerson("main_evan", "san_bchq", "sanfrancisco")},
}

CreateQuest
{
	name = "rank2_30",
	starter = "tok_towerkeep",
	accept = "ofcourse",
	defer = "maybelater",
	reject = "none",
	onaccept = {AwardText("rank2_30_extra01"), AwardUnlockIngredient("cherry"), AwardUnlockIngredient("blueberry")},
	goals = { RequireItem("c04", 45),  RequireItem("b09", 45), HintPerson("tok_towerkeep", "tok_tower", "tokyo")},
	goals_medium = { RequireItem("c04", 55),  RequireItem("b09", 55), HintPerson("tok_towerkeep", "tok_tower", "tokyo")},
	goals_hard = { RequireItem("c04", 75),  RequireItem("b09", 75), HintPerson("tok_towerkeep", "tok_tower", "tokyo")},
	oncomplete = {AwardDelayQuest("rank2_32", 10), IncrementVariable("rank2_work"), AwardMoney(50000), AwardItem("b09", -45), AwardItem("c04", -45), AwardRecipe("i02"), AwardRecipe("i05"), AwardDialog("recipes"), AwardOfferQuest("rank2_31")},
	oncomplete_medium = {AwardDelayQuest("rank2_32", 10), IncrementVariable("rank2_work"), AwardMoney(65000), AwardItem("b09", -55), AwardItem("c04", -55), AwardRecipe("i02"), AwardRecipe("i05"), AwardDialog("recipes"), AwardOfferQuest("rank2_31")},
	oncomplete_hard = {AwardDelayQuest("rank2_32", 10), IncrementVariable("rank2_work"), AwardMoney(80000), AwardItem("b09", -75), AwardItem("c04", -75), AwardRecipe("i02"), AwardRecipe("i05"), AwardDialog("recipes"), AwardOfferQuest("rank2_31")},
	require = {RequireMinRank(2), RequireRecipe("c04")},
}

CreateQuest
{
	name = "rank2_31",
	starter = "tok_towerkeep",
	accept = "illdoit",
	defer = "maybelater",
	reject = "nothanks",
	goals = { RequireItem("i02", 45), RequireItem("i05", 45), HintPerson("tok_towerkeep", "tok_tower", "tokyo")},
	goals_medium = { RequireItem("i02", 55), RequireItem("i05", 55), HintPerson("tok_towerkeep", "tok_tower", "tokyo")},
	goals_hard = { RequireItem("i02", 75), RequireItem("i05", 75), HintPerson("tok_towerkeep", "tok_tower", "tokyo")},
	oncomplete = {IncrementVariable("rank2_work"), AwardMoney(100000), AwardItem("i05", -45), AwardItem("i02", -45), AwardUnlockCharacter("tok_towerkeep")},
	oncomplete_medium = {IncrementVariable("rank2_work"), AwardMoney(125000), AwardItem("i05", -55), AwardItem("i02", -55), AwardUnlockCharacter("tok_towerkeep")},
	oncomplete_hard = {IncrementVariable("rank2_work"), AwardMoney(150000), AwardItem("i05", -75), AwardItem("i02", -75), AwardUnlockCharacter("tok_towerkeep")},
	require = {RequireMinRank(2), RequireQuestComplete("rank2_30")},
}

CreateQuest
{
	name = "rank2_32",
	starter = "trav_03",
	priority = 99,
	accept = "iagree",
	defer = "laterperhaps",
	reject = "none",
	goals = { RequireRelativeTime(6), RequireItem("i05", 26), HintPerson("trav_03",  "_travelers")},
	goals_medium = { RequireRelativeTime(6), RequireItem("i05", 42), HintPerson("trav_03",  "_travelers")},
	goals_hard = { RequireRelativeTime(6), RequireItem("i05", 58), HintPerson("trav_03",  "_travelers")},
	oncomplete = {IncrementVariable("rank2_work"), AwardUnlockIngredient("turmeric"), AwardUnlockIngredient("star_anise"), AwardItem("i05", -26), AwardRecipe("i03"), AwardDialog("recipes"), AwardText("rank2_32_extra01"), AwardUnlockCharacter("trav_03"), AwardUnlockCharacter("bal_marketkeep"), AwardUnlockCharacter("bal_shopkeep"), AwardDiscoverPreference("trav_03", "like", "blueberry")},
	oncomplete_medium = {IncrementVariable("rank2_work"), AwardUnlockIngredient("turmeric"), AwardUnlockIngredient("star_anise"), AwardItem("i05", -42), AwardRecipe("i03"), AwardDialog("recipes"), AwardText("rank2_32_extra01"), AwardUnlockCharacter("trav_03"), AwardUnlockCharacter("bal_marketkeep"), AwardUnlockCharacter("bal_shopkeep"), AwardDiscoverPreference("trav_03", "like", "blueberry")},
	oncomplete_hard = {IncrementVariable("rank2_work"), AwardUnlockIngredient("turmeric"), AwardUnlockIngredient("star_anise"), AwardItem("i05", -58), AwardRecipe("i03"), AwardDialog("recipes"), AwardText("rank2_32_extra01"), AwardUnlockCharacter("trav_03"), AwardUnlockCharacter("bal_marketkeep"), AwardUnlockCharacter("bal_shopkeep"), AwardDiscoverPreference("trav_03", "like", "blueberry")},
	require = {RequireMinRank(2), RequireQuestComplete("rank2_30"), RequireCharHasNoActiveOrder("trav_03")},
}

CreateQuest
{
	name = "rank2_33",
	starter = "trav_02",
	accept = "sure",
	defer = "maybelater",
	reject = "none",
	priority = 99,
	onaccept = {AwardText("rank2_33_extra01"), AwardItem("pepper", 100), AwardItem("anise", 100), AwardRecipe("i04"), AwardDialog("recipes"), AwardRemoveCharacter("trav_02", "_travelers"), AwardPlaceCharacter("trav_02", "dou_emptybuilding1"), AwardDisableOrderForChar("trav_02"), AwardDisableOrderForBuilding("dou_emptybuilding1")},
	goals = { RequireRelativeTime(2), RequireItem("i04", 75), HintPerson("trav_02", "dou_emptybuilding1", "douala")},
	goals_medium = { RequireRelativeTime(2), RequireItem("i04", 85), HintPerson("trav_02", "dou_emptybuilding1", "douala")},
	goals_hard = { RequireRelativeTime(2), RequireItem("i04", 100), HintPerson("trav_02", "dou_emptybuilding1", "douala")},
	oncomplete = {IncrementVariable("rank2_work"), AwardItem("i04", -75), AwardRemoveCharacter("trav_02", "dou_emptybuilding1"), AwardPlaceCharacter("trav_02", "_travelers"), AwardEnableOrderForChar("trav_02"), AwardEnableOrderForBuilding("dou_emptybuilding1"), AwardUnlockCharacter("trav_02")},
	oncomplete_medium = {IncrementVariable("rank2_work"), AwardItem("i04", -85), AwardRemoveCharacter("trav_02", "dou_emptybuilding1"), AwardPlaceCharacter("trav_02", "_travelers"), AwardEnableOrderForChar("trav_02"), AwardEnableOrderForBuilding("dou_emptybuilding1"), AwardUnlockCharacter("trav_02")},
	oncomplete_hard = {IncrementVariable("rank2_work"), AwardItem("i04", -100), AwardRemoveCharacter("trav_02", "dou_emptybuilding1"), AwardPlaceCharacter("trav_02", "_travelers"), AwardEnableOrderForChar("trav_02"), AwardEnableOrderForBuilding("dou_emptybuilding1"), AwardUnlockCharacter("trav_02")},
	require = {RequireMinRank(2), RequireRecipe("i01"), RequireIngredientAvailable("anise"), RequireIngredientAvailable("pepper"), RequireCharHasNoActiveOrder("trav_02"), RequireBuildingHasNoActiveOrder("dou_emptybuilding1")},
}

CreateQuest
{
	name = "rank2_34",
	starter = "tok_shopkeep",
	ender = "tok_stationkeep",
	accept = "itsadeal",
	accept_length = "medium",
	defer = "maybelater",
	defer_length = "medium",
	reject = "none",
	onaccept = {AwardRecipe("i06"), AwardDialog("recipes"), AwardUnlockCharacter("tok_shopkeep")},
	goals = {RequireItem("i06", 50), HintPerson("tok_stationkeep", "tok_station", "tokyo")},
	goals_medium = {RequireItem("i06", 65), HintPerson("tok_stationkeep", "tok_station", "tokyo")},
	goals_hard = {RequireItem("i06", 80), HintPerson("tok_stationkeep", "tok_station", "tokyo")},
	oncomplete = {IncrementVariable("rank2_work"), AwardItem("i06", -50), AwardRecipe("i08"), AwardUnlockIngredient("vanilla"), AwardDialog("recipes"), AwardOfferQuest("rank2_35"), AwardUnlockCharacter("tok_stationkeep")},
	oncomplete_medium = {IncrementVariable("rank2_work"), AwardItem("i06", -65), AwardRecipe("i08"), AwardUnlockIngredient("vanilla"), AwardDialog("recipes"), AwardOfferQuest("rank2_35"), AwardUnlockCharacter("tok_stationkeep")},
	oncomplete_hard = {IncrementVariable("rank2_work"), AwardItem("i06", -80), AwardRecipe("i08"), AwardUnlockIngredient("vanilla"), AwardDialog("recipes"), AwardOfferQuest("rank2_35"), AwardUnlockCharacter("tok_stationkeep")},
	require = {RequireMinRank(2), RequireRecipe("i01"), RequireIngredientAvailable("allspice"), RequireIngredientAvailable("cinnamon")},
}

CreateQuest
{
	name = "rank2_35",
	starter = "tok_stationkeep",
	ender = "tok_marketkeep",
	accept = "absolutely",
	accept_length = "medium",
	defer = "none",
	reject = "icantdothat",
	reject_length = "medium",
	expires = 11,
	expires_medium = 10,
	expires_hard = 9,
	goals = {RequireItem("i08", 31), HintPerson("tok_marketkeep", "tok_market", "tokyo"), HintExpirationDate()},
	goals_medium = {RequireItem("i08", 63), HintPerson("tok_marketkeep", "tok_market", "tokyo"), HintExpirationDate()},
	goals_hard = {RequireItem("i08", 97), HintPerson("tok_marketkeep", "tok_market", "tokyo"), HintExpirationDate()},
	oncomplete = {IncrementVariable("rank2_work"), AwardItem("i08", -31), AwardItem("cacao", 10000), AwardUnlockCharacter("tok_marketkeep")},
	oncomplete_medium = {IncrementVariable("rank2_work"), AwardItem("i08", -63), AwardItem("cacao", 15000), AwardUnlockCharacter("tok_marketkeep")},
	oncomplete_hard = {IncrementVariable("rank2_work"), AwardItem("i08", -97), AwardItem("cacao", 20000), AwardUnlockCharacter("tok_marketkeep")},
--	onexpire = {AwardText("rank2_35_expire", "tok_marketkeep")},
	require = {RequireQuestComplete("rank2_34"), RequireMinRank(2), RequireRecipe("i01"), RequireIngredientAvailable("vanilla"), RequireIngredientAvailable("allspice"), RequireIngredientAvailable("cinnamon")},
}

CreateQuest
{
	name = "rank2_36_prompt",
	starter = {"tok_marketkeep", "tok_mountainkeep", "tok_towerkeep", "tok_shopkeep", "main_deit", "tok_shrinekeep", "tok_stationkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	onaccept = {AwardDelayQuest("rank2_36_prompt", 15)},
--	require = {RequireMinRank(2), RequireRecipe("i01"), RequireMinMoney(25000), RequireRecipesKnown(3, "infusion"), RequireQuestIncomplete("rank2_36"), RequireQuestNotActive("rank2_36")},
	require = {RequireMinRank(2), RequireIngredientAvailable("lime"), RequireRecipe("i01"), RequireRecipe("user2"), RequireMinMoney(25000), RequireRecipesKnown(4, "infusion"), RequireQuestIncomplete("rank2_36"), RequireQuestNotActive("rank2_36")},
	require_medium = {RequireMinRank(2), RequireIngredientAvailable("lime"), RequireRecipe("i01"), RequireRecipe("user2"), RequireMinMoney(25000), RequireRecipesKnown(6, "infusion"), RequireQuestIncomplete("rank2_36"), RequireQuestNotActive("rank2_36")},
	require_hard = {RequireMinRank(2), RequireIngredientAvailable("lime"), RequireRecipe("i01"), RequireRecipe("user2"), RequireMinMoney(25000), RequireRecipesKnown(8, "infusion"), RequireQuestIncomplete("rank2_36"), RequireQuestNotActive("rank2_36")},
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "rank2_36",
	starter = "tok_palacekeep",
	ender = "bog_churchkeep",
	accept = "illtakeit",
	accept_length = "medium",
	defer = "notnow",
	defer_length = "medium",
	reject = "none",
	onaccept = {AwardMoney(-10000), AwardText("rank2_36_extra01"), AwardUnlockPort("bogota"), AwardUnlockIngredient("bog_cacao"), AwardUnlockIngredient("bog_coffee"), AwardUnlockIngredient("pumpkin")},
	onaccept_medium = {AwardMoney(-50000), AwardText("rank2_36_extra01"), AwardUnlockPort("bogota"), AwardUnlockIngredient("bog_cacao"), AwardUnlockIngredient("bog_coffee"), AwardUnlockIngredient("pumpkin")},
	onaccept_hard = {AwardMoney(-100000), AwardText("rank2_36_extra01"), AwardUnlockPort("bogota"), AwardUnlockIngredient("bog_cacao"), AwardUnlockIngredient("bog_coffee"), AwardUnlockIngredient("pumpkin")},
	goals = { HintPerson("bog_churchkeep", "bog_church", "bogota")},
	oncomplete = {AwardOfferQuest("rank2_37"), AwardUnlockCharacter("tok_palacekeep"), AwardUnlockCharacter("bog_marketkeep"), AwardUnlockCharacter("bog_shopkeep")},
	require = {RequireMinRank(2), RequireIngredientAvailable("lime"), RequireRecipe("i01"), RequireRecipe("user2"), RequireMinMoney(25000), RequireRecipesKnown(4, "infusion")},
	require_medium = {RequireMinRank(2), RequireIngredientAvailable("lime"), RequireRecipe("i01"), RequireRecipe("user2"), RequireMinMoney(50000), RequireRecipesKnown(5, "infusion")},
	require_hard = {RequireMinRank(2), RequireIngredientAvailable("lime"), RequireRecipe("i01"), RequireRecipe("user2"), RequireMinMoney(100000), RequireRecipesKnown(6, "infusion")},
}

CreateQuest
{
	name = "rank2_37",
	starter = "bog_churchkeep",
	accept = "gotit",
	accept_length = "medium",
	defer = "notnow",
	defer_length = "medium",
	reject = "none",
--	onaccept = {AwardMoney(-10000), AwardUnlockPort("bogota")},
	goals = { RequireItem("user2", 25), HintPerson("bog_churchkeep", "bog_church", "bogota")},
	goals_medium = { RequireItem("user2", 40), HintPerson("bog_churchkeep", "bog_church", "bogota")},
	goals_hard = { RequireItem("user2", 55), HintPerson("bog_churchkeep", "bog_church", "bogota")},
	oncomplete = {AwardItem("user2", -25), AwardRecipe("i07"), AwardDialog("recipes"), AwardOfferQuest("rank2_38"), AwardUnlockCharacter("bog_customskeep")},
	oncomplete_medium = {AwardItem("user2", -40), AwardRecipe("i07"), AwardDialog("recipes"), AwardOfferQuest("rank2_38"), AwardUnlockCharacter("bog_customskeep")},
	oncomplete_hard = {AwardItem("user2", -55), AwardRecipe("i07"), AwardDialog("recipes"), AwardOfferQuest("rank2_38"), AwardUnlockCharacter("bog_customskeep")},
	require = {RequireMinRank(2), RequireQuestComplete("rank2_36")},
}

CreateQuest
{
	name = "rank2_38",
	starter = "bog_churchkeep",
	accept = "yesplease",
	accept_length = "medium",
	defer = "maybelater",
	defer_length = "medium",
	reject = "none",
	goals = { RequireItem("i07", 45), HintPerson("bog_churchkeep", "bog_church", "bogota")},
	goals_medium = { RequireItem("i07", 60), HintPerson("bog_churchkeep", "bog_church", "bogota")},
	goals_hard = { RequireItem("i07", 75), HintPerson("bog_churchkeep", "bog_church", "bogota")},
	oncomplete = {AwardItem("i07", -45), AwardRecipe("i10"), AwardDialog("recipes"), AwardUnlockIngredient("macadamia"), AwardUnlockCharacter("bog_churchkeep"), AwardUnlockCharacter("bog_plantationkeep")},
	oncomplete_medium = {AwardItem("i07", -60), AwardRecipe("i10"), AwardDialog("recipes"), AwardUnlockIngredient("macadamia"), AwardUnlockCharacter("bog_churchkeep"), AwardUnlockCharacter("bog_plantationkeep")},
	oncomplete_hard = {AwardItem("i07", -75), AwardRecipe("i10"), AwardDialog("recipes"), AwardUnlockIngredient("macadamia"), AwardUnlockCharacter("bog_churchkeep"), AwardUnlockCharacter("bog_plantationkeep")},
	require = {RequireMinRank(2), RequireQuestComplete("rank2_37")},
}

CreateQuest
{
	name = "rank2_39_prompt",
	starter = {"trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11"},
	accept = "ok",
	defer = "none",
	reject = "none",
	onaccept = {AwardDelayQuest("rank2_39_prompt", 21), AwardUnlockIngredient("mango"), AwardUnlockIngredient("clove")},
--	need to add to reqs:  RequireQuestNotActive("rank2_39")},
	require = {RequireMinRank(2), RequirePort("tangiers"), RequireRecipe("i01"), RequireRecipe("user2"), RequireRecipesKnown(7, "infusion"), RequireQuestIncomplete("rank2_39")},
	require_medium = {RequireMinRank(2), RequirePort("tangiers"), RequireRecipe("i01"), RequireRecipe("user2"), RequireRecipesKnown(8, "infusion"), RequireQuestIncomplete("rank2_39")},
	require_hard = {RequireMinRank(2), RequirePort("tangiers"), RequireRecipe("i01"), RequireRecipe("user2"), RequireRecipesKnown(9, "infusion"), RequireQuestIncomplete("rank2_39")},
	priority = 10,
	repeatable = 20,
	visible = false,
}

CreateQuest
{
	name = "rank2_39",
	starter = "tan_portkeep",
	accept = "deal",
	accept_length = "medium",
	defer = "notnow",
	defer_length = "medium",
	reject = "none",
	onaccept = {AwardRecipe("i09"), AwardDialog("recipes")},
	goals = { RequireItem("i09", 40), HintPerson("tan_portkeep", "tan_port", "tangiers")},
	goals_medium = { RequireItem("i09", 60), HintPerson("tan_portkeep", "tan_port", "tangiers")},
	goals_hard = { RequireItem("i09", 80), HintPerson("tan_portkeep", "tan_port", "tangiers")},
	oncomplete = {AwardDelayQuest("rank2_coffee16", 2), AwardItem("i09", -40), AwardRecipe("i12"), AwardDialog("recipes")},
	oncomplete_medium = {AwardDelayQuest("rank2_coffee16", 2), AwardItem("i09", -60), AwardRecipe("i12"), AwardDialog("recipes")},
	oncomplete_hard = {AwardDelayQuest("rank2_coffee16", 2), AwardItem("i09", -80), AwardRecipe("i12"), AwardDialog("recipes")},
	require = {RequireQuestComplete("rank2_39_prompt"), RequireMinRank(2), RequireRecipe("i01"), RequireRecipe("user2"), RequireRecipesKnown(7, "infusion")},
}

CreateQuest
{
	name = "rank2_40",
	starter = "trav_08",
	accept = "tellmemore",
	accept_length = "medium",
	defer = "notinterested",
	defer_length = "medium",
	reject = "none",
	priority = 99,
	onaccept = {AwardText("rank2_40_extra01"), AwardUnlockPort("lasvegas"), AwardUnlockIngredient("strawberry")},
	goals = {RequireRelativeTime(10, false), RequireItem("strawberry", 100), HintPerson("trav_08", "_travelers")},
	goals_medium = {RequireRelativeTime(9, false), RequireItem("strawberry", 150), HintPerson("trav_08", "_travelers")},
	goals_hard = {RequireRelativeTime(8, false), RequireItem("strawberry", 200), HintPerson("trav_08", "_travelers")},
	oncomplete = {AwardItem("strawberry", - 100), AwardRecipe("i11"), AwardDialog("recipes"), AwardUnlockCharacter("trav_08"), AwardUnlockCharacter("las_casinokeep"), AwardDiscoverPreference("trav_08", "like", "strawberry"), AwardUnlockIngredient("sumac")},
	oncomplete_medium = {AwardItem("strawberry", - 150), AwardRecipe("i11"), AwardDialog("recipes"), AwardUnlockCharacter("trav_08"), AwardUnlockCharacter("las_casinokeep"), AwardDiscoverPreference("trav_08", "like", "strawberry"), AwardUnlockIngredient("sumac")},
	oncomplete_hard = {AwardItem("strawberry", - 200), AwardRecipe("i11"), AwardDialog("recipes"), AwardUnlockCharacter("trav_08"), AwardUnlockCharacter("las_casinokeep"), AwardDiscoverPreference("trav_08", "like", "strawberry"), AwardUnlockIngredient("sumac")},
	require = {RequirePort("havana"), RequirePort("tangiers"), RequirePort("kona"), RequireMinRank(2), RequireRecipe("i01"), RequireRecipe("user2"), RequireRecipesKnown(4, "infusion"), RequireCharHasNoActiveOrder("trav_08")},
}

CreateQuest
{
	name = "konshop_01_prompt",
	starter = { "tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "bag_towerkeep", "bag_churchkeep", "bog_churchkeep", "bog_customskeep", "bog_mountainkeep", "cap_bldg1keep", "cap_mountainkeep", "fal_xxxkeep", "hav_hotelkeep", "lim_churchkeep", "lim_mountainkeep", "lim_plazakeep", "main_loud", "main_sara", "san_barkeep", "tan_hotelkeep", "tan_portkeep", "tok_mountainkeep", "tok_palacekeep", "tok_stationkeep", "tok_towerkeep", "ulu_rockkeep", "zur_bankkeep", "zur_mountainkeep", "zur_schoolkeep", "zur_stationkeep", "zur_towerkeep", "main_zach" },
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	visible = false,
	repeatable = 31,
	priority = 100,
	require = {RequireBuildingOwned("tan_shop"), RequireIngredientAvailable("honey"), RequireRecipe("b11"), RequireRecipe("c07"), RequireRecipe("c05"), RequireRecipe("user2"), RequireRecipe("user3"), RequireQuestIncomplete("konshop_01"), RequireQuestNotActive("konshop_01")},
}

CreateQuest
{
	name = "konshop_01",
	starter = "kon_shopkeep",
	ender = "main_zach",
	accept = "iam",
	accept_length = "medium",
	defer = "maybelater",
	defer_length = "medium",
	reject = "none",
	ondefer = {AwardText("konshop_01_deferred")},
	goals = { RequireItem("user1", 120), HintPerson("main_zach", "tan_shop", "tangiers")},
	goals_medium = { RequireItem("user1", 150), HintPerson("main_zach", "tan_shop", "tangiers")},
	goals_hard = { RequireItem("user1", 180), HintPerson("main_zach", "tan_shop", "tangiers")},
	onaccept = {AwardText("konshop_01_extra01"), AwardDelayQuest("tan_shop_owned_00", 15)},
	oncomplete = {AwardItem("user1", -120),  AwardOfferQuest("konshop_02")},
	oncomplete_medium = {AwardItem("user1", -150),  AwardOfferQuest("konshop_02")},
	oncomplete_hard = {AwardItem("user1", -180),  AwardOfferQuest("konshop_02")},
	require = {RequireBuildingOwned("tan_shop"), RequireIngredientAvailable("honey"), RequireRecipe("b11"), RequireRecipe("c07"), RequireRecipe("c05"), RequireRecipe("user2"), RequireRecipe("user3")},
}

CreateQuest
{
	name = "konshop_02",
	starter = "main_zach",
	ender = "kon_shopkeep",	
	accept = "allright",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	goals = { HintPerson("kon_shopkeep", "kon_shop", "kona")},
	oncomplete = {AwardOfferQuest("konshop_03"), AwardDelayQuest("tan_shop_owned_00", 5)},
	require = {RequireQuestComplete("konshop_01")},
}


CreateQuest
{
	name = "konshop_03",
	starter = "kon_shopkeep",
	ender = "kon_plantationkeep",
	accept = "imonit",
	accept_length = "medium",
	defer = "notnow",
	defer_length = "medium",
	reject = "none",
	goals = { RequireItem("c01", 60), RequireItem("c05", 60), HintPerson("kon_plantationkeep", "kon_plantation", "kona")},
	goals_medium = { RequireItem("c01", 75), RequireItem("c05", 75), HintPerson("kon_plantationkeep", "kon_plantation", "kona")},
	goals_hard = { RequireItem("c01", 90), RequireItem("c05", 90), HintPerson("kon_plantationkeep", "kon_plantation", "kona")},
	oncomplete = {AwardItem("c01", -60),  AwardItem("c05", -60), AwardOfferQuest("konshop_04"), AwardUnlockCharacter("kon_plantationkeep")},
	oncomplete_medium = {AwardItem("c01", -75),  AwardItem("c05", -75), AwardOfferQuest("konshop_04"), AwardUnlockCharacter("kon_plantationkeep")},
	oncomplete_hard = {AwardItem("c01", -90),  AwardItem("c05", -90), AwardOfferQuest("konshop_04"), AwardUnlockCharacter("kon_plantationkeep")},
	require = {RequireQuestComplete("konshop_02")},
}


CreateQuest
{
	name = "konshop_04",
	starter = "kon_plantationkeep",
	ender = "kon_shopkeep",	
	accept = "soundsgood",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	goals = { HintPerson("kon_shopkeep", "kon_shop", "kona")},
	oncomplete = {AwardOfferQuest("konshop_05")},
	require = {RequireQuestComplete("konshop_03")},
}

CreateQuest
{
	name = "konshop_05",
	starter = "kon_shopkeep",	
	accept = "loudandclear",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	goals = { RequireItem("b11", 50),  RequireItem("c07", 50), RequireItem("user3", 50), HintPerson("kon_shopkeep", "kon_shop", "kona")},
	goals_medium = { RequireItem("b11", 100),  RequireItem("c07", 100), RequireItem("user3", 100), HintPerson("kon_shopkeep", "kon_shop", "kona")},
	goals_hard = { RequireItem("b11", 200),  RequireItem("c07", 200), RequireItem("user3", 200), HintPerson("kon_shopkeep", "kon_shop", "kona")},
	oncomplete = {AwardHappiness("kon_shopkeep", 100), AwardItem("b11", -50), AwardItem("c07", -50), AwardItem("user3", -50), AwardBuildingOwned("kon_shop"), IncrementVariable("shopsowned"), AwardUnlockCharacter("kon_shopkeep")},
	oncomplete_medium = {AwardHappiness("kon_shopkeep", 100), AwardItem("b11", -100), AwardItem("c07", -100), AwardItem("user3", -100), AwardBuildingOwned("kon_shop"), IncrementVariable("shopsowned"), AwardUnlockCharacter("kon_shopkeep")},
	oncomplete_hard = {AwardHappiness("kon_shopkeep", 100), AwardItem("b11", -200), AwardItem("c07", -200), AwardItem("user3", -200), AwardBuildingOwned("kon_shop"), IncrementVariable("shopsowned"), AwardUnlockCharacter("kon_shopkeep")},
	require = {RequireQuestComplete("konshop_04")},
}

CreateQuest
{
	name = "meta_evan",
	starter = "main_evan",
	accept = "understood",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	goals = {RequireRecipesKnown(12, "truffle"), RequireShopsOwned(3), HintPerson("main_evan", "san_bchq", "sanfrancisco")},
	onaccept ={AwardOfferQuest("rank2_50"), AwardDisableOrderForChar("main_feli"), AwardDisableOrderForChar("main_deit"), AwardDisableOrderForBuilding("cap_factory"), AwardDisableOrderForBuilding("tok_factory"), AwardUnlockCharacter("main_evan")},
	oncomplete = {AwardRank(3), AwardText("meta_evan_extra01"), AwardCustomSlot(2), AwardDialog("recipes"), AwardDelayQuest("ugr_prompt", 16), IncrementVariable("endorsed"), AwardEnableOrderForChar("main_evan"), AwardEnableOrderForBuilding("san_bchq")},
}

CreateQuest
{
	name = "rank2_50",
	starter = "main_evan",
	accept = "thankyou",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	onaccept = {AwardBuildingOwned("san_factory"), AwardFactoryPowerup("san_factory", "truffle", "recycler"), AwardUnlockIngredient("powder"), AwardUnlockIngredient("currant"), AwardUnlockIngredient("honey"), AwardUnlockIngredient("pepper"), AwardUnlockIngredient("lemon"), AwardUnlockIngredient("raspberry"), AwardUnlockIngredient("cashew"), AwardUnlockIngredient("wasabi"), AwardRecipe("t01"), AwardDialog("recipes"), AwardText("rank2_50_extra01")},
	goals = {RequireItem("t01", 1), HintPerson("main_evan", "san_bchq", "sanfrancisco")},
	goals_medium = {RequireItem("t01", 10), HintPerson("main_evan", "san_bchq", "sanfrancisco")},
	goals_hard = {RequireItem("t01", 50), HintPerson("main_evan", "san_bchq", "sanfrancisco")},
	oncomplete = {AwardRecipe("t02"), AwardRecipe("t03"), AwardRecipe("t04"), AwardRecipe("t05"), AwardRecipe("t06"), AwardDialog("recipes"), AwardOfferQuest("rank2_51"), AwardUnlockCharacter("main_chas"), AwardUnlockCharacter("san_marketkeep"), AwardUnlockCharacter("san_shopkeep"), AwardUnlockCharacter("san_barkeep")},
	require = {RequireQuestActive("meta_evan")},
}

CreateQuest
{
	name = "rank2_51",
	starter = "main_evan",
	accept = "imlistening",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	onaccept ={AwardText("rank2_51_extra01"), AwardText("rank2_51_extra02"), AwardUnlockPort("toronto"), AwardUnlockPort("wellington"), AwardPlaceCharacter("main_alex", "zur_school")},
	goals = { RequireRecipesKnown(11, "truffle"), RequireVariableEqual("metatruf", 5), HintPerson("main_evan", "san_bchq", "sanfrancisco")},
	oncomplete = {AwardRecipe("t12"), AwardDialog("recipes"), AwardRemoveCharacter("main_alex", "zur_school"), AwardOfferQuest("hav_shop_01")},
	require = {RequireQuestComplete("rank2_50")},
}

CreateQuest
{
	name = "meta_truf_01",
	starter = "main_feli",
	accept = "thankyou",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	autoComplete = true,
	priority = 1,
	goals = {RequireItem("t03", 1)},
	goals_medium = {RequireItem("t03", 10)},
	goals_hard = {RequireItem("t03", 50)},
	oncomplete ={AwardItem("t03", -1), AwardRecipe("t11"), AwardDialog("recipes"), AwardUnlockIngredient("espresso"), IncrementVariable("metatruf"), AwardDelayQuest("rank2_51_done_hint", 6), AwardEnableOrderForChar("main_feli"), AwardEnableOrderForBuilding("cap_factory")},
	oncomplete_medium ={AwardItem("t03", -10), AwardRecipe("t11"), AwardDialog("recipes"), AwardUnlockIngredient("espresso"), IncrementVariable("metatruf"), AwardDelayQuest("rank2_51_done_hint", 6), AwardEnableOrderForChar("main_feli"), AwardEnableOrderForBuilding("cap_factory")},
	oncomplete_hard ={AwardItem("t03", -50), AwardRecipe("t11"), AwardDialog("recipes"), AwardUnlockIngredient("espresso"), IncrementVariable("metatruf"), AwardDelayQuest("rank2_51_done_hint", 6), AwardEnableOrderForChar("main_feli"), AwardEnableOrderForBuilding("cap_factory")},
	require = {RequireItem("t03", 1), RequireQuestActive("rank2_51")},
	require_medium = {RequireItem("t03", 10), RequireQuestActive("rank2_51")},
	require_hard = {RequireItem("t03", 50), RequireQuestActive("rank2_51")},
}

CreateQuest
{
	name = "meta_truf_01_hint",
	starter = "main_feli",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireQuestIncomplete("meta_truf_01"), RequireQuestActive("rank2_51")},
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "meta_truf_02",
	starter = "main_deit",
	accept = "iappreciateit",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	autoComplete = true,
	priority = 1,
	goals = {RequireItem("t06", 1)},
	goals_medium = {RequireItem("t06", 10)},
	goals_hard = {RequireItem("t06", 50)},
	oncomplete ={AwardItem("t06", -1), AwardRecipe("t09"), AwardDialog("recipes"), IncrementVariable("metatruf"), AwardDelayQuest("rank2_51_done_hint", 6), AwardEnableOrderForChar("main_deit"), AwardEnableOrderForBuilding("tok_factory")},
	oncomplete_medium ={AwardItem("t06", -10), AwardRecipe("t09"), AwardDialog("recipes"), IncrementVariable("metatruf"), AwardDelayQuest("rank2_51_done_hint", 6), AwardEnableOrderForChar("main_deit"), AwardEnableOrderForBuilding("tok_factory")},
	oncomplete_hard ={AwardItem("t06", -50), AwardRecipe("t09"), AwardDialog("recipes"), IncrementVariable("metatruf"), AwardDelayQuest("rank2_51_done_hint", 6), AwardEnableOrderForChar("main_deit"), AwardEnableOrderForBuilding("tok_factory")},
	require = {RequireItem("t06", 1), RequireQuestActive("rank2_51")},
	require_medium = {RequireItem("t06", 10), RequireQuestActive("rank2_51")},
	require_hard = {RequireItem("t06", 50), RequireQuestActive("rank2_51")},
}

CreateQuest
{
	name = "meta_truf_02_hint",
	starter = "main_deit",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireQuestIncomplete("meta_truf_02"), RequireQuestActive("rank2_51")},
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "meta_truf_03",
	starter = "main_jose",
	accept = "thankyou",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	autoComplete = true,
	priority = 1,
	goals = {RequireItem("t02", 1)},
	goals_medium = {RequireItem("t02", 10)},
	goals_hard = {RequireItem("t02", 50)},
	oncomplete = {AwardItem("t02", -1), AwardRecipe("t10"), AwardDialog("recipes"), IncrementVariable("metatruf"), AwardDelayQuest("rank2_51_done_hint", 6), AwardUnlockCharacter("tor_marketkeep"), AwardUnlockCharacter("tor_shopkeep")},
	oncomplete_medium = {AwardItem("t02", -10), AwardRecipe("t10"), AwardDialog("recipes"), IncrementVariable("metatruf"), AwardDelayQuest("rank2_51_done_hint", 6), AwardUnlockCharacter("tor_marketkeep"), AwardUnlockCharacter("tor_shopkeep")},
	oncomplete_hard = {AwardItem("t02", -50), AwardRecipe("t10"), AwardDialog("recipes"), IncrementVariable("metatruf"), AwardDelayQuest("rank2_51_done_hint", 6), AwardUnlockCharacter("tor_marketkeep"), AwardUnlockCharacter("tor_shopkeep")},
	require = {RequireItem("t02", 1), RequireQuestActive("rank2_51")},
	require_medium = {RequireItem("t02", 10), RequireQuestActive("rank2_51")},
	require_hard = {RequireItem("t02", 50), RequireQuestActive("rank2_51")},
}

CreateQuest
{
	name = "meta_truf_03_hint",
	starter = "main_jose",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireQuestIncomplete("meta_truf_03"), RequireQuestActive("rank2_51")},
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "meta_truf_04",
	starter = "main_whit",
	accept = "metoo",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	autoComplete = true,
	priority = 1,
	goals = {RequireItem("t05", 1)},
	goals_medium = {RequireItem("t05", 10)},
	goals_hard = {RequireItem("t05", 50)},
	oncomplete ={AwardItem("t05", -1), AwardRecipe("t07"), AwardUnlockIngredient("saffron"), AwardDialog("recipes"), IncrementVariable("metatruf"), AwardDelayQuest("rank2_51_done_hint", 6), AwardUnlockCharacter("wel_marketkeep"), AwardUnlockCharacter("wel_shopkeep")},
	oncomplete_medium ={AwardItem("t05", -10), AwardRecipe("t07"), AwardUnlockIngredient("saffron"), AwardDialog("recipes"), IncrementVariable("metatruf"), AwardDelayQuest("rank2_51_done_hint", 6), AwardUnlockCharacter("wel_marketkeep"), AwardUnlockCharacter("wel_shopkeep")},
	oncomplete_hard ={AwardItem("t05", -50), AwardRecipe("t07"), AwardUnlockIngredient("saffron"), AwardDialog("recipes"), IncrementVariable("metatruf"), AwardDelayQuest("rank2_51_done_hint", 6), AwardUnlockCharacter("wel_marketkeep"), AwardUnlockCharacter("wel_shopkeep")},
	require = {RequireItem("t05", 1), RequireQuestActive("rank2_51")},
	require_medium = {RequireItem("t05", 10), RequireQuestActive("rank2_51")},
	require_hard = {RequireItem("t05", 50), RequireQuestActive("rank2_51")},
}

CreateQuest
{
	name = "meta_truf_04_hint",
	starter = "main_whit",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireQuestIncomplete("meta_truf_04"), RequireQuestActive("rank2_51")},
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "meta_truf_05",
	starter = "main_alex",
	accept = "thanks",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	autoComplete = true,
	priority = 1,
	goals = {RequireItem("t04", 1)},
	goals_medium = {RequireItem("t04", 10)},
	goals_hard = {RequireItem("t04", 50)},
	oncomplete ={AwardItem("t04", -1), AwardUnlockPort("lima"), AwardUnlockIngredient("lim_cacao"), AwardUnlockIngredient("passionfruit"), AwardUnlockIngredient("cardamom"), AwardRecipe("t08"), AwardDialog("recipes"), IncrementVariable("metatruf"), AwardDelayQuest("rank2_51_done_hint", 6), AwardUnlockCharacter("lim_marketkeep"), AwardUnlockCharacter("lim_shopkeep"), AwardUnlockCharacter("lim_plantationkeep")},
	oncomplete_medium ={AwardItem("t04", -10), AwardUnlockPort("lima"), AwardUnlockIngredient("lim_cacao"), AwardUnlockIngredient("passionfruit"), AwardUnlockIngredient("cardamom"), AwardRecipe("t08"), AwardDialog("recipes"), IncrementVariable("metatruf"), AwardDelayQuest("rank2_51_done_hint", 6), AwardUnlockCharacter("lim_marketkeep"), AwardUnlockCharacter("lim_shopkeep"), AwardUnlockCharacter("lim_plantationkeep")},
	oncomplete_hard ={AwardItem("t04", -50), AwardUnlockPort("lima"), AwardUnlockIngredient("lim_cacao"), AwardUnlockIngredient("passionfruit"), AwardUnlockIngredient("cardamom"), AwardRecipe("t08"), AwardDialog("recipes"), IncrementVariable("metatruf"), AwardDelayQuest("rank2_51_done_hint", 6), AwardUnlockCharacter("lim_marketkeep"), AwardUnlockCharacter("lim_shopkeep"), AwardUnlockCharacter("lim_plantationkeep")},
	require = {RequireItem("t04", 1), RequireQuestActive("rank2_51")},
	require_medium = {RequireItem("t04", 10), RequireQuestActive("rank2_51")},
	require_hard = {RequireItem("t04", 50), RequireQuestActive("rank2_51")},
}

CreateQuest
{
	name = "meta_truf_05_hint",
	starter = "main_alex",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	priority = 1,
	require = {RequireQuestIncomplete("meta_truf_05"), RequireQuestActive("rank2_51")},
	repeatable = 0,
	visible = false,
}


CreateQuest
{
	name = "rank2_51_done_hint",
	starter = {"trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11"},
	accept = "ihearyou",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	autoComplete = true,
	priority = 11,
	require = { RequireQuestActive("rank2_51"), RequireRecipesKnown(11, "truffle")},
	repeatable = 12,
	visible = false,
}

CreateQuest
{
	name = "hav_shop_tease",
	starter = "hav_shopkeep",
	accept = "isee",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	visible = false,
	repeatable = 33,
	autoComplete = true,
	require = {RequirePort("sanfrancisco"), RequireQuestNotActive("hav_shop_01"), RequireQuestIncomplete("hav_shop_01")},
}

CreateQuest
{
	name = "hav_shop_01",
	starter = "main_evan",
	ender = "hav_shopkeep",
	accept = "yesindeed",
	accept_length = "medium",
	defer = "laterperhaps",
	defer_length = "medium",
	reject = "none",
	onaccept = {AwardText("hav_shop_01_extra01")},
	goals = {RequireItem("t07", 100), RequireItem("t08", 100), RequireItem("t10", 100), RequireItem("user4", 100), HintPerson("hav_shopkeep", "hav_shop", "havana")},
	goals_medium = {RequireItem("t07", 150), RequireItem("t08", 150), RequireItem("t10", 150), RequireItem("user4", 150), HintPerson("hav_shopkeep", "hav_shop", "havana")},
	goals_hard = {RequireItem("t07", 200), RequireItem("t08", 200), RequireItem("t10", 200), RequireItem("user4", 200), HintPerson("hav_shopkeep", "hav_shop", "havana")},
	oncomplete = {AwardHappiness("hav_shopkeep", 100), AwardItem("t07", -100), AwardItem("t08", -100), AwardItem("t10", -100),AwardItem("user4", -100), AwardMoney(100000), AwardBuildingOwned("hav_shop"), AwardText("hav_shop_01_extra03"), AwardUnlockCharacter("hav_shopkeep")},
	oncomplete_medium = {AwardHappiness("hav_shopkeep", 100), AwardItem("t07", -150), AwardItem("t08", -150), AwardItem("t10", -150),AwardItem("user4", -150), AwardMoney(150000), AwardBuildingOwned("hav_shop"), AwardText("hav_shop_01_extra03"), AwardUnlockCharacter("hav_shopkeep")},
	oncomplete_hard = {AwardHappiness("hav_shopkeep", 100), AwardItem("t07", -200), AwardItem("t08", -200), AwardItem("t10", -200),AwardItem("user4", -200), AwardMoney(200000), AwardBuildingOwned("hav_shop"), AwardText("hav_shop_01_extra03"), AwardUnlockCharacter("hav_shopkeep")},
	require = {RequireQuestComplete("rank2_51")},
}

CreateQuest
{
	name = "rank2_opt_01",
	starter = "trav_06",
	accept = "takethem",
	defer = "anothertime",
	reject = "nosorry",
	onaccept = {AwardItem("b03",- 25), AwardMoney(10000), AwardUnlockCharacter("trav_06"), AwardDiscoverPreference("trav_06", "like", "caramel")},
	goals = {RequireItem("b03", 25)},
	require = { RequireMinRank(2), RequireItem("b03", 25)},
}

CreateQuest
{
	name = "rank2_exp01",
	starter = "trav_11",
	accept = "imin",
	accept_length = "medium",
	defer = "maybelater",
	defer_length = "medium",
	reject = "none",
	onaccept = {AwardRemoveCharacter("trav_11", "_travelers"), AwardPlaceCharacter("trav_11", "dou_emptybuilding1"), AwardDisableOrderForChar("trav_11"), AwardDisableOrderForBuilding("dou_emptybuilding1")},
	goals = { RequireItem("c05", 60), HintPerson("trav_11", "dou_emptybuilding1", "douala"), HintExpirationDate()},
	goals = { RequireItem("c05", 75), HintPerson("trav_11", "dou_emptybuilding1", "douala"), HintExpirationDate()},
	goals = { RequireItem("c05", 90), HintPerson("trav_11", "dou_emptybuilding1", "douala"), HintExpirationDate()},
	expires = 19,
	expires_medium = 16,
	expires_hard = 13,
	onexpire = {AwardRemoveCharacter("trav_11", "dou_emptybuilding1"), AwardPlaceCharacter("trav_11", "_travelers"), AwardEnableOrderForChar("trav_11"), AwardEnableOrderForBuilding("dou_emptybuilding1")},
	oncomplete = {AwardItem("c05", -60), AwardMoney(60000), AwardRemoveCharacter("trav_11", "dou_emptybuilding1"), AwardPlaceCharacter("trav_11", "_travelers"), AwardEnableOrderForChar("trav_11"), AwardEnableOrderForBuilding("dou_emptybuilding1")},
	oncomplete = {AwardItem("c05", -75), AwardMoney(75000), AwardRemoveCharacter("trav_11", "dou_emptybuilding1"), AwardPlaceCharacter("trav_11", "_travelers"), AwardEnableOrderForChar("trav_11"), AwardEnableOrderForBuilding("dou_emptybuilding1")},
	oncomplete = {AwardItem("c05", -90), AwardMoney(90000), AwardRemoveCharacter("trav_11", "dou_emptybuilding1"), AwardPlaceCharacter("trav_11", "_travelers"), AwardEnableOrderForChar("trav_11"), AwardEnableOrderForBuilding("dou_emptybuilding1")},
	require = {RequireNoOffers(3), RequireMinRank(2), RequireRecipe("c05"), RequireCharHasNoActiveOrder("trav_11"), RequireBuildingHasNoActiveOrder("dou_emptybuilding1"), RequireQuestComplete("rank2_tangiersb")},
}

CreateQuest
{
	name = "rank2_story_ulu_rockkeep_1",
	starter = "ulu_rockkeep",
	accept = "isee",
	defer = "none",
	reject = "none",
	require = {RequireQuestComplete("ugr_02")},
	onaccept = {AwardDelayQuest("rank2_story_ulu_rockkeep_2", 8)},
	priority = 1,
	visible = false,
	autoComplete = true,
}

CreateQuest
{
	name = "rank2_story_ulu_rockkeep_2",
	starter = "ulu_rockkeep",
	accept = "ok",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	require = {RequireQuestComplete("ugr_02"), RequireQuestComplete("rank2_story_ulu_rockkeep_1")},
	onaccept = {AwardUnlockCharacter("ulu_rockkeep")},
	priority = 1,
	visible = false,
	autoComplete = true,
}

CreateQuest
{
	name = "rank2_story_tok_mountainkeep_1",
	starter = "tok_mountainkeep",
	accept = "ok",
	accept_length = "nicetomeetyou",
	defer = "none",
	reject = "none",
	require = {RequireQuestComplete("tokyo_01")},
	onaccept = {AwardDelayQuest("rank3_story_tok_mountainkeep_1", 15)},
	priority = 1,
	visible = false,
	autoComplete = true,
}

CreateQuest
{
	name = "rank2_story_lim_churchkeep_1",
	starter = "lim_churchkeep",
	accept = "isee",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	require = {RequireQuestComplete("rank2_51"), RequireVariableLessThan("endorsed", 4)},
	onaccept = {AwardUnlockCharacter("lim_churchkeep")},
	priority = 1,
	visible = false,
	autoComplete = true,
}