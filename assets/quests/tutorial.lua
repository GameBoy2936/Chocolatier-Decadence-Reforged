--[[--------------------------------------------------------------------------
	Chocolatier Three: Tutorial Quests
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

CreateQuest
{
	name = "tut_01",
	priority = 1,
	starter = "main_alex",
	accept = "understood",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	onaccept = {AwardOfferQuest("tut_02"), AwardUnlockCharacter("main_alex"), AwardBlockBuilding("dou_plantation"), AwardBlockBuilding("cap_factory"), AwardBlockBuilding("ulu_hut"), AwardBlockBuilding("tok_factory"), AwardBlockBuilding("bal_plantation"), AwardBlockBuilding("hav_casino"), AwardDisableOrderForChar("main_alex"), AwardDisableOrderForChar("main_feli"), AwardDisableOrderForChar("main_deit"), AwardDisableOrderForChar("main_evan"), AwardDisableOrderForChar("main_jose"), AwardDisableOrderForChar("main_whit"), AwardDisableOrderForChar("main_sean"), AwardDisableOrderForChar("evil_kath"), AwardDisableOrderForChar("evil_tyso"), AwardDisableOrderForChar("evil_wolf"), AwardDisableOrderForChar("announcer"), AwardDisableOrderForChar("bal_xxxkeep"), AwardDisableOrderForChar("bel_hutkeep"), AwardDisableOrderForChar("hav_casinokeep"), AwardDisableOrderForBuilding("cap_factory"), AwardDisableOrderForBuilding("tok_factory"), AwardDisableOrderForBuilding("san_bchq"), AwardDisableOrderForBuilding("tor_office"), AwardDisableOrderForBuilding("wel_factory"), AwardDisableOrderForBuilding("bel_ruins"), AwardDisableOrderForBuilding("bel_hut"), AwardDisableOrderForBuilding("fal_board"), AwardDisableOrderForBuilding("bal_plantation"), AwardDisableOrderForBuilding("hav_casino")},
	autoComplete = true,
}

CreateQuest
{
	name = "tut_02",
	starter = "main_alex",
    accept = "yesplease",
	accept_length = "medium",
    defer = "none",
	reject = "imgood",
	reject_length = "medium",
	onaccept = {AwardBlockBuilding("zur_market"), AwardBlockBuilding("zur_shop"), AwardItem("sugar", 100), AwardItem("cacao", 100), AwardOfferQuest("tut_03")},
	goals = { RequireMinMoney(10000), RequireRecipeMade("b03", 1),  RequireQuestComplete("tut_11")},
	goals_medium = { RequireMinMoney(15000), RequireRecipeMade("b03", 1),  RequireQuestComplete("tut_11")},
	goals_hard = { RequireMinMoney(25000), RequireRecipeMade("b03", 1),  RequireQuestComplete("tut_11")},
	oncomplete = {AwardOfferQuest("tut_over")},
    onreject = {AwardOfferQuest("tut_over_notut")},
	priority = 3,
}

CreateQuest
{
	name = "tut_03",
	starter = "main_alex",
	ender = "zur_factorykeep",
	accept = "imonit",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	goals = {HintPerson("zur_factorykeep", "zur_factory", "zurich") },
	require = { RequireQuestActive("tut_02")},
	followup = "tut_04",
}

CreateQuest
{
	name = "tut_story_alex_01",
	starter = "main_alex",
	accept = "isee",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	require = {RequireQuestIncomplete("tut_02")},
	priority = 2,
	visible = false,
	autoComplete = true,
	onaccept = {AwardDelayQuest("tut_story_alex_02", 2)},
}

CreateQuest
{
	name = "tut_story_alex_02",
	starter = "main_alex",
	accept = "isee",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	require = {RequireQuestComplete("tut_story_alex_01"), RequireQuestIncomplete("tut_02")},
	priority = 2,
	visible = false,
	autoComplete = true,
}

CreateQuest
{
	name = "tut_03_help",
	starter = {"main_alex", "zur_marketkeep", "zur_shopkeep", "zur_towerkeep", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_03") },
	repeatable = 0,
	visible = false,
}	

CreateQuest
{
	name = "tut_04",
	starter = "zur_factorykeep",
	accept = "understood",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	goals = { RequireItem("b01", 5),},
	goals_medium = { RequireItem("b01", 20),},
	goals_hard = { RequireItem("b01", 40),},
	onaccept = {AwardBuildingOwned("zur_factory"), AwardUnlockCharacter("zur_factorykeep")},
	oncomplete = {AwardDialog("inventory"), AwardOfferQuest("tut_05")},
	require = { RequireItem("sugar",100), RequireItem("cacao",100), RequireQuestActive("tut_02")},

}

CreateQuest
{
	name = "tut_04_help",
	starter = {"main_alex", "zur_marketkeep", "zur_shopkeep", "zur_towerkeep", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_04") },
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "tut_05",
	starter = "zur_factorykeep",
	ender = "zur_shopkeep",
	accept = "ok",
	defer = "none",
	reject = "none",
	onaccept = {AwardText("tut_05_extra01"), AwardUnblockBuilding("zur_shop")},
	goals = {HintPerson("zur_shopkeep", "zur_shop", "zurich") },
	oncomplete = {AwardHappiness("zur_shopkeep", 80), AwardUnlockCharacter("zur_shopkeep")},	
	require = { RequireQuestComplete("tut_04") },
	followup = "tut_06",
}

CreateQuest
{
	name = "tut_05_help",
	starter = {"main_alex", "zur_marketkeep", "zur_factorykeep", "zur_towerkeep", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_05") },
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "tut_06",
	starter = "zur_shopkeep",
	accept = "thankyou",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	goals = {RequireMinMoney(10), HintPerson("zur_shopkeep", "zur_shop", "zurich") },
	oncomplete = {AwardHappiness("zur_shopkeep", 80)},	
	require = { RequireQuestComplete("tut_04") },
	followup = "tut_07",
}

CreateQuest
{
	name = "tut_07",
	starter = "zur_shopkeep",
	ender = "main_alex",
	accept = "sure",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	require = { RequireQuestComplete("tut_06")},
	followup = "tut_08",
}

CreateQuest
{
	name = "tut_07_help",
	starter = {"zur_shopkeep", "zur_marketkeep", "zur_factorykeep", "zur_towerkeep", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_07") },
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "tut_08",
	starter = "main_alex",
	accept = "isee",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	onaccept = {AwardOfferQuest("tut_09")},
--	goals = {RequireItem("sugar",100), RequireItem("cacao",100), HintPerson("main_alex", "zur_station", "zurich") },
	require = { RequireQuestComplete("tut_07")},
	autoComplete = true,
}


CreateQuest
{
	name = "tut_09",
	starter = "main_alex",
	ender = "zur_marketkeep",
	accept = "understood",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	require = { RequireQuestComplete("tut_07")},
	onaccept = {AwardMoney(5000), AwardUnblockBuilding("zur_market")},
--	onaccept = {AwardMoney(5000), AwardUnblockBuilding("zur_market"), AwardText("tut_09_extra01"), AwardDialog("quests"),},
	goals = {HintPerson("zur_marketkeep", "zur_market", "zurich")},
	oncomplete = { AwardOfferQuest("tut_10"), AwardUnlockCharacter("zur_marketkeep")},
}

CreateQuest
{
	name = "tut_09_help",
	starter = {"zur_shopkeep", "zur_factorykeep", "zur_towerkeep", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_09")},
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "tut_10",
	starter = "zur_marketkeep",
	accept = "thankyou",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	goals = { RequireItem("sugar", 200)},
--	onaccept = {AwardDialog("inventory")},
	oncomplete = {AwardHappiness("zur_marketkeep", 80), AwardOfferQuest("tut_11")},
--	onincomplete ={AwardDialog("inventory")},
	require = { RequireQuestComplete("tut_09")},
}

CreateQuest
{
	name = "tut_10_help",
	starter = {"zur_shopkeep", "zur_factorykeep", "zur_towerkeep", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep", "main_alex"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_10") },
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "tut_11",
	starter = "zur_marketkeep",
	ender = "dou_marketkeep",
	accept = "sure",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	onaccept = {AwardUnlockPort("douala")},
	require = { RequireQuestComplete("tut_10")},
	goals = {HintPerson("dou_marketkeep", "dou_market", "douala")},
	followup = "tut_12",
}

CreateQuest
{
	name = "tut_11_help",
	starter = {"zur_shopkeep", "zur_marketkeep", "zur_factorykeep", "zur_towerkeep", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep", "main_alex"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_11") },
	repeatable = 0,
	visible = false,
}


CreateQuest
{
	name = "tut_11_helpb",
	starter = {"dou_shopkeep", "dou_bldg1keep", "bag_bldg2keep", "trav_09", "trav_05"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_11") },
	repeatable = 0,
	visible = false,
}
CreateQuest
{
	name = "tut_12",
	starter = "dou_marketkeep",
	accept = "thankyou",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	goals = { RequireItem("cacao", 200)},
	onaccept = {AwardUnlockCharacter("dou_marketkeep")},
	oncomplete = {AwardHappiness("dou_marketkeep", 80), AwardOfferQuest("tut_13")},
--	onincomplete ={AwardDialog("inventory")},
	require = { RequireQuestActive("tut_02"),  RequireQuestComplete("tut_11") },
}

CreateQuest
{
	name = "tut_12_help",
	starter = {"trav_05", "trav_09", "dou_bldg1keep", "bag_bldg2keep", "zur_shopkeep", "zur_marketkeep", "zur_factorykeep", "zur_towerkeep", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep", "main_alex", "dou_shopkeep", "dou_plantationkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_12") },
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "tut_13",
	starter = "dou_marketkeep",
	ender = "main_alex",
	accept = "iwill",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	goals = {HintPerson("main_alex", "zur_station", "zurich")},
	require = { RequireQuestComplete("tut_12")},
	followup = "tut_14",
}

CreateQuest
{
	name = "tut_13_help",
	starter = {"trav_10", "trav_07",  "dou_bldg1keep", "bag_bldg2keep", "zur_shopkeep", "zur_marketkeep", "zur_factorykeep", "zur_towerkeep", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep", "dou_marketkeep", "dou_shopkeep", "dou_plantationkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_13") },
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "tut_14",
	starter = "main_alex",
	ender = "zur_marketkeep",
	accept = "soundsgood",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	onaccept = {AwardUnlockIngredient("milk")},
	goals = { HintPerson("zur_marketkeep", "zur_market", "zurich") },
	require = { RequireQuestComplete("tut_13") },
	oncomplete = {AwardOfferQuest("tut_15")},
}

CreateQuest
{
	name = "tut_14_help",
	starter = { "trav_03", "trav_04",  "dou_bldg1keep", "bag_bldg2keep", "zur_factorykeep", "zur_shopkeep", "zur_towerkeep", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep", "dou_marketkeep", "dou_shopkeep", "dou_plantationkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_14") },
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "tut_15",
	starter = "zur_marketkeep",
	ender = "zur_factorykeep",
	accept = "iwill",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	goals = { RequireItem("sugar",1), RequireItem("cacao",1), RequireItem("milk",1), HintPerson("zur_factorykeep", "zur_factory", "zurich")},
--	onincomplete ={AwardDialog("inventory")},
	require = { RequireQuestComplete("tut_14") },
	oncomplete = {AwardOfferQuest("tut_16")},
}

CreateQuest
{
	name = "tut_15_help",
	starter = {"trav_07", "trav_09", "dou_bldg1keep", "bag_bldg2keep", "zur_marketkeep", "main_alex", "zur_shopkeep", "zur_towerkeep", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep", "dou_marketkeep", "dou_shopkeep", "dou_plantationkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_15") },
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "tut_16",
	starter = "zur_factorykeep",
	accept = "loudandclear",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	goals = { RequireItem("b02", 10)},
	goals_medium = { RequireItem("b02", 20)},
	goals_hard = { RequireItem("b02", 30)},
	oncomplete = {AwardOfferQuest("tut_16b")},
	require = { RequireQuestComplete("tut_15")},
}

CreateQuest
{
	name = "tut_16_help",
	starter = { "zur_marketkeep", "main_alex", "zur_shopkeep",  "dou_bldg1keep", "bag_bldg2keep", "trav_03", "trav_05", "zur_schoolkeep",  "zur_bankkeep", "zur_mountainkeep", "dou_marketkeep", "dou_shopkeep", "dou_plantationkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_16") },
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "tut_16b",
	starter = "zur_factorykeep",
	ender = "zur_towerkeep",
	accept = "goodidea",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	goals = { RequireItem("b02", 10), HintPerson("zur_towerkeep", "zur_tower", "zurich")},
	goals_medium = { RequireItem("b02", 20), HintPerson("zur_towerkeep", "zur_tower", "zurich")},
	goals_hard = { RequireItem("b02", 30), HintPerson("zur_towerkeep", "zur_tower", "zurich")},
	oncomplete = {AwardUnlockCharacter("zur_towerkeep"), AwardItem("b02", -10), AwardMoney(3000), AwardItem("caramel", 200), AwardUnlockIngredient("caramel"), AwardOfferQuest("tut_17")},
	oncomplete_medium = {AwardUnlockCharacter("zur_towerkeep"), AwardItem("b02", -20), AwardMoney(6500), AwardItem("caramel", 200), AwardUnlockIngredient("caramel"), AwardOfferQuest("tut_17")},
	oncomplete_hard = {AwardUnlockCharacter("zur_towerkeep"), AwardItem("b02", -30), AwardMoney(10000), AwardItem("caramel", 200), AwardUnlockIngredient("caramel"), AwardOfferQuest("tut_17")},
	require = { RequireQuestComplete("tut_16")},
}

CreateQuest
{
	name = "tut_16b_help",
	starter = { "zur_marketkeep", "main_alex", "zur_shopkeep", "zur_factorykeep", "dou_bldg1keep", "bag_bldg2keep", "trav_04", "trav_08", "zur_schoolkeep",  "zur_bankkeep", "zur_mountainkeep", "dou_marketkeep", "dou_shopkeep", "dou_plantationkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_16b") },
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "tut_17",
	starter = "zur_towerkeep",
	ender = "zur_factorykeep",
	accept = "sure",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	goals = { RequireItem("sugar",1), RequireItem("cacao",1), RequireItem("caramel",1), HintPerson("zur_factorykeep", "zur_factory", "zurich")},
	oncomplete = {AwardOfferQuest("tut_18")},
	require = { RequireQuestComplete("tut_16") },
}

CreateQuest
{
	name = "tut_17_help",
	starter = { "zur_marketkeep", "main_alex", "zur_shopkeep", "dou_bldg1keep", "bag_bldg2keep", "trav_01", "trav_11", "zur_factorykeep", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep", "dou_marketkeep", "dou_shopkeep", "dou_plantationkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_17") },
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "tut_18",
	starter = "zur_factorykeep",
	accept = "ok",
	accept = "letsgo",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	onaccept = {AwardText("tut_18_extra01"), AwardFactoryPowerup("zur_factory", "bar", "recycler")},
	goals = {RequireRecipeMade("b03")},
	oncomplete = {AwardOfferQuest("tut_19")},
	require = { RequireQuestComplete("tut_17") },	
}


CreateQuest
{
	name = "tut_18_help",
	starter = { "zur_marketkeep", "main_alex", "zur_shopkeep", "dou_bldg1keep", "bag_bldg2keep", "trav_03", "trav_04", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep", "dou_marketkeep", "dou_shopkeep", "dou_plantationkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_18") },
	repeatable = 0,
	visible = false,
}	

CreateQuest
{
	name = "tut_19_prompt",
	starter = {"zur_marketkeep", "zur_shopkeep", "zur_towerkeep", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep", "dou_marketkeep", "dou_shopkeep", "dou_plantationkeep", "trav_06", "trav_08"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = { RequireQuestActive("tut_19")},
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "tut_19",
	starter = "zur_factorykeep",
	accept = "thankyou",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	require = {RequireQuestComplete("tut_18"), RequireRecipeMade("b03") },
	visible = false,
	autoComplete = true,
}	

CreateQuest
{
	name = "tut_over_prompt",
	starter = { "dou_bldg1keep", "bag_bldg2keep", "zur_marketkeep", "zur_shopkeep", "zur_towerkeep", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep", "dou_marketkeep", "dou_shopkeep", "dou_plantationkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestComplete("tut_19"), RequireQuestIncomplete("tut_over") , RequireQuestNotActive("tut_over")},
	repeatable = 2,
	visible = false,
}

CreateQuest
{
	name = "tut_really_over_prompt",
	starter = {"zur_marketkeep", "zur_shopkeep", "dou_bldg1keep", "bag_bldg2keep", "trav_06", "trav_09", "zur_towerkeep", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep", "dou_marketkeep", "dou_shopkeep", "dou_plantationkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = { RequireQuestComplete("tut_19"), RequireQuestIncomplete("tut_over"), RequireQuestActive("tut_02"), RequireMinMoney(10000)},
	require_medium = { RequireQuestComplete("tut_19"), RequireQuestIncomplete("tut_over"), RequireQuestActive("tut_02"), RequireMinMoney(15000)},
	require_hard = { RequireQuestComplete("tut_19"), RequireQuestIncomplete("tut_over"), RequireQuestActive("tut_02"), RequireMinMoney(25000)},
	repeatable = 0,
	visible = false,
}
CreateQuest
{
	name = "tut_over_cap_help",
	starter = { "cap_shopkeep", "cap_mountainkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_over") },
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "tut_over_notut_cap_help",
	starter = { "cap_shopkeep", "cap_mountainkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestActive("tut_over_notut") },
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "tut_over_help",
	starter = { "trav_02", "trav_04",  "dou_bldg1keep", "bag_bldg2keep", "trav_01", "trav_07", "zur_towerkeep", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep", "dou_marketkeep", "dou_shopkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	priority = 5,
	require = {RequireQuestActive("tut_over") },
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "tut_over_notut_help",
	starter = { "trav_02", "trav_04",  "dou_bldg1keep", "bag_bldg2keep", "trav_01", "trav_07", "zur_towerkeep", "zur_schoolkeep", "zur_mountainkeep", "zur_bankkeep", "dou_marketkeep", "dou_shopkeep"},
	accept = "ok",
	defer = "none",
	reject = "none",
	priority = 5,
	require = {RequireQuestActive("tut_over_notut") },
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "tut_over_byealex",
	starter = "zur_stationkeep",
	accept = "ok",
	defer = "none",
	reject = "none",
	priority = 4,
	require = {RequireQuestActive("tut_over")},
	autoComplete = true,
	visible = false,
}

CreateQuest
{
	name = "tut_over_notut_byealex",
	starter = "zur_stationkeep",
	accept = "ok",
	defer = "none",
	reject = "none",
	priority = 4,
	require = {RequireQuestActive("tut_over_notut")},
	autoComplete = true,
	visible = false,
}

CreateQuest
{
	name = "tut_story_zur_towerkeep",
	starter = "zur_towerkeep",
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireMinRank(1), RequireQuestComplete("tut_04"), RequireQuestNotActive("tut_16b"), RequireMaxRank(1)},
	priority = 1,
	visible = false,
	autoComplete = true,
}

CreateQuest
{
	name = "tut_over",
	starter = "main_alex",
	ender = "main_feli",
	onaccept = {AwardRank(2), AwardText("tut_over_extra01"), AwardText("tut_over_extra03"), AwardText("tut_over_extra04"), AwardDelayQuest("tut_over_prompt", 500), AwardDelayQuest("rank2_12", 1), AwardDelayQuest("ugr_tease_00", 5), AwardUnlockPort("capetown")},
	accept = "iappreciateit",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	goals = {HintPerson("main_feli", "cap_factory", "capetown")},
	require = { RequireQuestComplete("tut_02"), RequireQuestComplete("tut_10") },
	oncomplete = {AwardOfferQuest("rank2_01")},
}

CreateQuest
{
	name = "tut_over_notut",
	starter = "main_alex",
	ender = "main_feli",
	accept = "thankyou",
	accept_length = "medium",
	defer = "none",
	reject = "none",
	onaccept = {AwardMoney(20000), AwardRank(2), AwardBuildingOwned("zur_factory"), AwardText("tut_over_extra01"), AwardText("tut_over_extra03"), AwardText("tut_over_extra04"), AwardUnlockIngredient("milk"), AwardUnlockIngredient("caramel"), AwardFactoryPowerup("zur_factory", "bar", "recycler"), AwardUnlockPort("douala"), AwardUnlockPort("capetown"), AwardUnlockCharacter("zur_factorykeep"), AwardUnlockCharacter("zur_shopkeep"), AwardUnlockCharacter("zur_marketkeep"), AwardUnlockCharacter("dou_marketkeep"), AwardUnlockCharacter("zur_towerkeep")},
	onaccept_medium = {AwardMoney(25000), AwardRank(2), AwardBuildingOwned("zur_factory"), AwardText("tut_over_extra01"), AwardText("tut_over_extra03"), AwardText("tut_over_extra04"), AwardUnlockIngredient("milk"), AwardUnlockIngredient("caramel"), AwardFactoryPowerup("zur_factory", "bar", "recycler"), AwardUnlockPort("douala"), AwardUnlockPort("capetown"), AwardUnlockCharacter("zur_factorykeep"), AwardUnlockCharacter("zur_shopkeep"), AwardUnlockCharacter("zur_marketkeep"), AwardUnlockCharacter("dou_marketkeep"), AwardUnlockCharacter("zur_towerkeep")},
	onaccept_hard = {AwardMoney(30000), AwardRank(2), AwardBuildingOwned("zur_factory"), AwardText("tut_over_extra01"), AwardText("tut_over_extra03"), AwardText("tut_over_extra04"), AwardUnlockIngredient("milk"), AwardUnlockIngredient("caramel"), AwardFactoryPowerup("zur_factory", "bar", "recycler"), AwardUnlockPort("douala"), AwardUnlockPort("capetown"), AwardUnlockCharacter("zur_factorykeep"), AwardUnlockCharacter("zur_shopkeep"), AwardUnlockCharacter("zur_marketkeep"), AwardUnlockCharacter("dou_marketkeep"), AwardUnlockCharacter("zur_towerkeep")},
	goals = {HintPerson("main_feli", "cap_factory", "capetown")},
	require = { RequireQuestNotActive("tut_02"), RequireMaxRank(1) },
	oncomplete = {AwardOfferQuest("rank2_01")},
}

CreateQuest
{
	name = "dou_plantationkeep_hint",
	starter = "dou_plantationkeep",
	accept = "ok",
	defer = "none",
	reject = "none",
	repeatable = 0,
	require = {RequireMinRank(1), RequireQuestIncomplete("rank2_01"), RequireMaxRank(1)},
	visible = false,
}