--[[--------------------------------------------------------------------------
	Chocolatier Three: Quests
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

CreateQuest
{
	name = "meta_joseph_prompt",
	starter = {"main_elen", "main_evan", "main_feli", "main_deit", "main_loud", "main_sara", "main_chas", "main_zach", "main_whit", "zur_factorykeep", "kon_shopkeep", "hav_shopkeep"},
	ender = "main_jose",
	accept = "ok",
	defer = "notnow",
	reject = "none",
	priority = 50,
	goals = {HintPerson("main_jose", "tor_office", "toronto")},
	oncomplete = {AwardOfferQuest("meta_joseph")},
	require = { RequireMinRank(3), RequirePort("bali"), RequireVariableMoreThan("endorsed", 2), RequireQuestIncomplete("meta_joseph"), RequireQuestNotActive("meta_joseph")},
}

CreateQuest
{
	name = "meta_joseph",
	starter = "main_jose",
	accept = "ok",
	defer = "none",
	reject = "none",
	onaccept = {AwardText("meta_joseph_extra01"), AwardText("meta_joseph_extra02"), AwardUnblockBuilding("tor_factory"), AwardBuildingOwned("tor_factory"), AwardDelayQuest("rank3_05", 20), AwardOfferQuest("off_to_whitney"), AwardUnlockIngredient("apple"), AwardUnlockIngredient("blackberry"), AwardUnlockIngredient("walnut"), AwardUnlockCharacter("main_jose")},
	goals = {RequireRecipesKnown(11, "blend"), RequireMinMoney(3000000), HintPerson("main_jose", "tor_office", "toronto")},
	goals_medium = {RequireRecipesKnown(11, "blend"), RequireMinMoney(4500000), HintPerson("main_jose", "tor_office", "toronto")},
	goals_hard = {RequireRecipesKnown(11, "blend"), RequireMinMoney(7500000), HintPerson("main_jose", "tor_office", "toronto")},
	oncomplete = {IncrementVariable("endorsed"), AwardRecipe("m12"), AwardDialog("recipes"), AwardText("meta_joseph_extra03"), AwardEnableOrderForChar("main_jose"), AwardEnableOrderForBuilding("tor_office")},
	require = { RequireMinRank(3), RequirePort("bali"), RequireVariableMoreThan("endorsed", 2)},
}

CreateQuest
{
	name = "meta_jose_middle",
	starter = "main_jose",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireQuestActive("meta_joseph")},
	visible = false,
	repeatable = 0,
}

CreateQuest
{
	name = "off_to_whitney",
	starter = "main_jose",
	ender = "main_whit",
	accept = "ok",
	defer = "none",
	reject = "none",
	onaccept = {AwardRecipe("m01"), AwardDialog("recipes"), AwardText("off_to_whitney_extra01")},
	goals = {RequireItem("m01", 1), HintPerson("main_whit", "wel_factory", "wellington")},
	goals_medium = {RequireItem("m01", 10), HintPerson("main_whit", "wel_factory", "wellington")},
	goals_hard = {RequireItem("m01", 25), HintPerson("main_whit", "wel_factory", "wellington")},
	oncomplete = {AwardItem("m01", -1), AwardOfferQuest("meta_whitney")},
	oncomplete_medium = {AwardItem("m01", -10), AwardOfferQuest("meta_whitney")},
	oncomplete_hard = {AwardItem("m01", -25), AwardOfferQuest("meta_whitney")},
	require = { RequireQuestActive("meta_joseph")},
}

CreateQuest
{
	name = "brooke_welcome",
	starter = "tor_factorykeep",
	accept = "ok",
	defer = "none",
	reject = "none",
	visible = false,
	onaccept = {AwardUnlockCharacter("tor_factorykeep")},
	require = {RequireQuestActive("off_to_whitney")},
}
	
CreateQuest
{
	name = "meta_whitney",
	starter = "main_whit",
	accept = "ok",
	defer = "none",
	reject = "none",
	goals = {RequireRecipesKnown(11, "exotic"), RequireRecipesKnown(7, "user"), HintPerson("main_whit", "wel_factory", "wellington")},
	goals_medium = {RequireRecipesKnown(11, "exotic"), RequireRecipesKnown(8, "user"), RequireRecipesMade(4, "exotic"), HintPerson("main_whit", "wel_factory", "wellington")},
	goals_hard = {RequireRecipesKnown(11, "exotic"), RequireRecipesKnown(9, "user"), RequireRecipesMade(6, "exotic"), HintPerson("main_whit", "wel_factory", "wellington")},
	onaccept = {AwardUnblockBuilding("wel_factory"), AwardBuildingOwned("wel_factory"), AwardFactoryPowerup("wel_factory", "exotic", "recycler"), AwardRecipe("e01"), AwardUnlockIngredient("salt"), AwardUnlockIngredient("lychee"), AwardOfferQuest("back_to_joseph"), AwardUnlockCharacter("main_whit")},
	oncomplete = {IncrementVariable("endorsed"), AwardRecipe("e12"), AwardDialog("recipes"), AwardEnableOrderForChar("main_whit"), AwardEnableOrderForBuilding("wel_factory")},
	require = { RequireMinRank(3), RequireVariableMoreThan("endorsed", 2), RequireQuestComplete("off_to_whitney")},
}

CreateQuest
{
	name = "back_to_joseph",
	starter = "main_whit",
	ender = "main_jose",
	accept = "gotit",
	defer = "none",
	reject = "none",
	goals = {RequireItem("e01", 1), HintPerson("main_jose", "tor_office", "toronto")},
	goals_medium = {RequireItem("e01", 10), HintPerson("main_jose", "tor_office", "toronto")},
	goals_hard = {RequireItem("e01", 25), HintPerson("main_jose", "tor_office", "toronto")},
	oncomplete = {AwardItem("e01", -1)},
	oncomplete_medium = {AwardItem("e01", -10)},
	oncomplete_hard = {AwardItem("e01", -25)},
	require = { RequireQuestActive("meta_whitney")},
}

CreateQuest
{
	name = "rank3_04",
	starter = "main_jose",
	ender = "main_feli",
	accept = "iam",
	defer = "laterperhaps",
	reject = "none",
	onaccept = {AwardText("rank3_04_extra01"), AwardRecipe("m02"), AwardRecipe("m03"), AwardDialog("recipes")},
	goals = {RequireItem("m01", 20), RequireItem("m02", 20), RequireItem("m03", 20), HintPerson("main_feli", "cap_factory", "capetown")},
	goals = {RequireItem("m01", 50), RequireItem("m02", 50), RequireItem("m03", 50), HintPerson("main_feli", "cap_factory", "capetown")},
	goals = {RequireItem("m01", 100), RequireItem("m02", 100), RequireItem("m03", 100), HintPerson("main_feli", "cap_factory", "capetown")},
	oncomplete = {IncrementVariable("rank3_work"), AwardItem("m01", -2), AwardItem("m02", -2), AwardItem("m03", -2), AwardRecipe("m04"), AwardUnlockIngredient("maple"), AwardRecipe("m05"), AwardDialog("recipes")},
	oncomplete_medium = {IncrementVariable("rank3_work"), AwardItem("m01", -5), AwardItem("m02", -5), AwardItem("m03", -5), AwardRecipe("m04"), AwardUnlockIngredient("maple"), AwardRecipe("m05"), AwardDialog("recipes")},
	oncomplete_hard = {IncrementVariable("rank3_work"), AwardItem("m01", -10), AwardItem("m02", -10), AwardItem("m03", -10), AwardRecipe("m04"), AwardUnlockIngredient("maple"), AwardRecipe("m05"), AwardDialog("recipes")},
	require = {RequireQuestComplete("off_to_whitney")},
}

CreateQuest
{
	name = "rank3_01",
	starter = "main_jose",
	ender = "lim_plazakeep",
	accept = "loudandclear",
	defer = "maybelater",
	reject = "none",
	goals = {RequireItem("t06", 60), HintPerson("lim_plazakeep", "lim_plaza", "lima")},
	goals_medium = {RequireItem("t06", 90), HintPerson("lim_plazakeep", "lim_plaza", "lima")},
	goals_hard = {RequireItem("t06", 150), HintPerson("lim_plazakeep", "lim_plaza", "lima")},
	oncomplete = {IncrementVariable("rank3_work"), AwardItem("t06", -60), AwardOfferQuest("rank3_02")},
	oncomplete_medium = {IncrementVariable("rank3_work"), AwardItem("t06", -90), AwardOfferQuest("rank3_02")},
	oncomplete_hard = {IncrementVariable("rank3_work"), AwardItem("t06", -150), AwardOfferQuest("rank3_02")},
	require = {RequireMinRank(3), RequireQuestComplete("back_to_joseph"), RequireIngredientAvailable("lime")},
}

CreateQuest
{
	name = "rank3_02",
	starter = "lim_plazakeep",
	accept = "willdo",
	defer = "maybelater",
	reject = "none",
	onaccept = {AwardText("rank3_02_extra01"), AwardRecipe("e03"), AwardDialog("recipes")},
	goals = {RequireItem("e03", 50), HintPerson("lim_plazakeep", "lim_plaza", "lima")},
	goals_medium = {RequireItem("e03", 75), HintPerson("lim_plazakeep", "lim_plaza", "lima")},
	goals_hard = {RequireItem("e03", 125), HintPerson("lim_plazakeep", "lim_plaza", "lima")},
	oncomplete = {IncrementVariable("rank3_work"), AwardItem("e03", -50), AwardRecipe("e02"), AwardDialog("recipes"), AwardText("rank3_02_extra02"), AwardDelayQuest("rank3_03", 17), AwardUnlockIngredient("toffee"), AwardUnlockCharacter("lim_plazakeep")},
	oncomplete_medium = {IncrementVariable("rank3_work"), AwardItem("e03", -75), AwardRecipe("e02"), AwardDialog("recipes"), AwardText("rank3_02_extra02"), AwardDelayQuest("rank3_03", 17), AwardUnlockIngredient("toffee"), AwardUnlockCharacter("lim_plazakeep")},
	oncomplete_hard = {IncrementVariable("rank3_work"), AwardItem("e03", -125), AwardRecipe("e02"), AwardDialog("recipes"), AwardText("rank3_02_extra02"), AwardDelayQuest("rank3_03", 17), AwardUnlockIngredient("toffee"), AwardUnlockCharacter("lim_plazakeep")},
	require = {RequireQuestComplete("rank3_01")},
}

CreateQuest
{
	name = "rank3_03",
	starter = "trav_05",
	accept = "imin",
	defer = "maybelater",
	reject = "none",
	onaccept = {AwardText("rank3_03_extra01"), AwardUnlockPort("gobidesert"), AwardUnlockIngredient("date"), AwardRemoveCharacter("trav_05", "_travelers"), AwardPlaceCharacter("trav_05", "lim_plaza")},
	goals = {RequireItem("e02", 50), HintPerson("trav_05", "lim_plaza", "lima")},
	goals_medium = {RequireItem("e02", 75), HintPerson("trav_05", "lim_plaza", "lima")},
	goals_hard = {RequireItem("e02", 125), HintPerson("trav_05", "lim_plaza", "lima")},
	oncomplete = {IncrementVariable("rank3_work"), AwardItem("e02", -50), AwardRecipe("e05"), AwardUnlockIngredient("pistachio"), AwardRecipe("e08"), AwardDialog("recipes"), AwardRemoveCharacter("trav_05", "lim_plaza"), AwardPlaceCharacter("trav_05", "_travelers"), AwardUnlockCharacter("trav_05"), AwardUnlockCharacter("gob_xxxkeep")},
	oncomplete_medium = {IncrementVariable("rank3_work"), AwardItem("e02", -75), AwardRecipe("e05"), AwardUnlockIngredient("pistachio"), AwardRecipe("e08"), AwardDialog("recipes"), AwardRemoveCharacter("trav_05", "lim_plaza"), AwardPlaceCharacter("trav_05", "_travelers"), AwardUnlockCharacter("trav_05"), AwardUnlockCharacter("gob_xxxkeep")},
	oncomplete_hard = {IncrementVariable("rank3_work"), AwardItem("e02", -125), AwardRecipe("e05"), AwardUnlockIngredient("pistachio"), AwardRecipe("e08"), AwardDialog("recipes"), AwardRemoveCharacter("trav_05", "lim_plaza"), AwardPlaceCharacter("trav_05", "_travelers"), AwardUnlockCharacter("trav_05"), AwardUnlockCharacter("gob_xxxkeep")},
	require = {RequireQuestComplete("rank3_02"), RequireCharHasNoActiveOrder("trav_05")},
}

CreateQuest
{
	name = "rank3_05",
	starter = "trav_06",
	accept = "yeslets",
	defer = "laterperhaps",
	reject = "none",
	onaccept = {AwardText("rank3_05_extra01"), AwardMoney(100000)},
	onaccept_medium = {AwardText("rank3_05_extra01"), AwardMoney(150000)},
	onaccept_hard = {AwardText("rank3_05_extra01"), AwardMoney(250000)},
	goals = {RequireRelativeTime(12,false), RequireItem("user4", 35), RequireItem("user5", 35), HintPerson("trav_06", "_travelers")},
	goals_medium = {RequireRelativeTime(12,false), RequireItem("user4", 60), RequireItem("user5", 60), HintPerson("trav_06", "_travelers")},
	goals_hard = {RequireRelativeTime(12,false), RequireItem("user4", 100), RequireItem("user5", 100), HintPerson("trav_06", "_travelers")},
	oncomplete = {IncrementVariable("rank3_work"), AwardItem("user4", -35), AwardItem("user5", -35), AwardRecipe("e04"), AwardRecipe("m06"), AwardDialog("recipes"), AwardText("rank3_05_extra02"), AwardUnlockIngredient("coconut"), AwardUnlockIngredient("rose"), AwardUnlockCharacter("trav_06")},
	oncomplete_medium = {IncrementVariable("rank3_work"), AwardItem("user4", -60), AwardItem("user5", -60), AwardRecipe("e04"), AwardRecipe("m06"), AwardDialog("recipes"), AwardText("rank3_05_extra02"), AwardUnlockIngredient("coconut"), AwardUnlockIngredient("rose"), AwardUnlockCharacter("trav_06")},
	oncomplete_hard = {IncrementVariable("rank3_work"), AwardItem("user4", -100), AwardItem("user5", -100), AwardRecipe("e04"), AwardRecipe("m06"), AwardDialog("recipes"), AwardText("rank3_05_extra02"), AwardUnlockIngredient("coconut"), AwardUnlockIngredient("rose"), AwardUnlockCharacter("trav_06")},
	require = {RequireQuestComplete("off_to_whitney"), RequireRecipe("m01"), RequireRecipe("e01"), RequireRecipe("user4"), RequireRecipe("user5"), RequireCharHasNoActiveOrder("trav_06")},
}

CreateQuest
{
	name = "rank3_06",
	starter = "main_evan",
	ender = "bog_mountainkeep",
	accept = "absolutely",
	defer = "noimtoobusy",
	reject = "none",
	onaccept = {AwardText("rank3_06_extra01"), AwardRecipe("m10"), AwardDialog("recipes"), AwardText("rank3_06_extra02"), AwardUnlockIngredient("sesame")},
	goals = { RequireItem("m10", 25), RequireItem("t09", 65), HintPerson("bog_mountainkeep", "bog_mountain", "bogota")},
	goals_medium = { RequireItem("m10", 40), RequireItem("t09", 100), HintPerson("bog_mountainkeep", "bog_mountain", "bogota")},
	goals_hard = { RequireItem("m10", 60), RequireItem("t09", 150), HintPerson("bog_mountainkeep", "bog_mountain", "bogota")},
	oncomplete = {IncrementVariable("rank3_work"), AwardItem("m10", -25), AwardItem("t09", -65), AwardRecipe("e10"), AwardDialog("recipes"), AwardUnlockIngredient("pecan"), AwardOfferQuest("rank3_07"), AwardUnlockCharacter("bog_mountainkeep")},
	oncomplete_medium = {IncrementVariable("rank3_work"), AwardItem("m10", -40), AwardItem("t09", -100), AwardRecipe("e10"), AwardDialog("recipes"), AwardUnlockIngredient("pecan"), AwardOfferQuest("rank3_07"), AwardUnlockCharacter("bog_mountainkeep")},
	oncomplete_hard = {IncrementVariable("rank3_work"), AwardItem("m10", -60), AwardItem("t09", -150), AwardRecipe("e10"), AwardDialog("recipes"), AwardUnlockIngredient("pecan"), AwardOfferQuest("rank3_07"), AwardUnlockCharacter("bog_mountainkeep")},
	require = {RequireRecipe("i11"), RequireQuestComplete("off_to_whitney"), RequireRecipe("m01"), RequireRecipe("e01"), RequireIngredientAvailable("anise"), RequireIngredientAvailable("ginger"), RequirePort("bogota"), RequirePort("lima")},
}

CreateQuest
{
	name = "rank3_07",
	starter = "bog_mountainkeep",
	ender = "bog_churchkeep",
	accept = "iwill",
	defer = "maybelater",
	reject = "none",
	goals = { RequireItem("e10", 12), RequireItem("i11", 12), HintPerson("bog_churchkeep", "bog_church", "bogota")},
	goals_medium = { RequireItem("e10", 30), RequireItem("i11", 30), HintPerson("bog_churchkeep", "bog_church", "bogota")},
	goals_hard = { RequireItem("e10", 50), RequireItem("i11", 50), HintPerson("bog_churchkeep", "bog_church", "bogota")},
	oncomplete = {IncrementVariable("rank3_work"), AwardItem("e10", -12), AwardItem("i11", -12), AwardRecipe("e06"), AwardUnlockIngredient("butter"), AwardRecipe("e11"), AwardDialog("recipes")},
	oncomplete_medium = {IncrementVariable("rank3_work"), AwardItem("e10", -30), AwardItem("i11", -30), AwardRecipe("e06"), AwardUnlockIngredient("butter"), AwardRecipe("e11"), AwardDialog("recipes")},
	oncomplete_hard = {IncrementVariable("rank3_work"), AwardItem("e10", -50), AwardItem("i11", -50), AwardRecipe("e06"), AwardUnlockIngredient("butter"), AwardRecipe("e11"), AwardDialog("recipes")},
	require = {RequireQuestComplete("rank3_06")},
}

CreateQuest
{
	name = "rank3_08",
	starter = "trav_11",
	accept = "iam",
	defer = "notreally",
	reject = "none",
	onaccept = {AwardText("rank3_08_extra01"), AwardRecipe("m07"), AwardDialog("recipes"), AwardUnlockIngredient("pineapple")},
	require = {RequireQuestComplete("rank3_01"), RequireMinRank(3), RequireRecipe("m01"), RequireRecipe("e01"), RequireVariableMoreThan("rank3_work", 5), RequireCharHasNoActiveOrder("trav_11")},
}

CreateQuest
{
	name = "rank3_09_prep",
	starter = {"trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11"},
	accept = "quest_yes",
	defer = "none",
	reject = "none",
	onaccept = {SetVariable("rank3_09_ready", 5)},
	autoComplete = true,
	visible = false,
	repeatable = 30,
	priority = 12,
	require = {RequireNoOffers(2), RequireMinMoney(80000), RequireQuestIncomplete("rank3_09"), RequireQuestNotActive("rank3_09"), RequireQuestComplete("rank3_01"), RequireMinRank(3), RequireRecipe("m01"), RequireRecipe("e01"), RequireRecipe("c06"), RequireRecipe("user2"), RequirePort("lasvegas"), RequirePort("bali"), RequireIngredientAvailable("whiskey")},
}

CreateQuest
{
	name = "rank3_09",
	starter = "las_marketkeep",
	ender = "dou_shopkeep",
	accept = "iwill",
	defer = "anothertime",
	reject = "none",
	onaccept = {AwardText("rank3_09_extra01"), AwardMoney(-25000), AwardRecipe("e07"), AwardDialog("recipes"), AwardUnlockCharacter("las_marketkeep")},
	onaccept = {AwardText("rank3_09_extra01"), AwardMoney(-40000), AwardRecipe("e07"), AwardDialog("recipes"), AwardUnlockCharacter("las_marketkeep")},
	onaccept = {AwardText("rank3_09_extra01"), AwardMoney(-65000), AwardRecipe("e07"), AwardDialog("recipes"), AwardUnlockCharacter("las_marketkeep")},
	goals = { RequireItem("e07", 78), HintPerson("dou_shopkeep", "dou_shop", "douala")},
	goals_medium = { RequireItem("e07", 116), HintPerson("dou_shopkeep", "dou_shop", "douala")},
	goals_hard = { RequireItem("e07", 172), HintPerson("dou_shopkeep", "dou_shop", "douala")},
	oncomplete = {IncrementVariable("rank3_work"), AwardItem("e07", -78), AwardRecipe("e09"), AwardDialog("recipes"), AwardOfferQuest("rank3_10")},
	oncomplete_medium = {IncrementVariable("rank3_work"), AwardItem("e07", -110), AwardRecipe("e09"), AwardDialog("recipes"), AwardOfferQuest("rank3_10")},
	oncomplete_hard = {IncrementVariable("rank3_work"), AwardItem("e07", -175), AwardRecipe("e09"), AwardDialog("recipes"), AwardOfferQuest("rank3_10")},
	require = {RequireVariableEqual("rank3_09_ready", 5), RequireMinMoney(80000)},
}

CreateQuest
{
	name = "rank3_10",
	starter = "dou_shopkeep",
	accept = "ofcourse",
	defer = "later",
	reject = "none",
	goals = { RequireItem("e09", 100), RequireItem("c06", 100), RequireItem("user2", 100), HintPerson("dou_shopkeep", "dou_shop", "douala")},
	goals_medium = { RequireItem("e09", 150), RequireItem("c06", 150), RequireItem("user2", 150), HintPerson("dou_shopkeep", "dou_shop", "douala")},
	goals_hard = { RequireItem("e09", 250), RequireItem("c06", 250), RequireItem("user2", 250), RequireItem("user3", 250), HintPerson("dou_shopkeep", "dou_shop", "douala")},
	oncomplete = {IncrementVariable("rank3_work"), AwardItem("e09", -100), AwardItem("c06", -100), AwardItem("user2", -100), AwardBuildingOwned("dou_shop"), IncrementVariable("shopsowned")},
	oncomplete_medium = {IncrementVariable("rank3_work"), AwardItem("e09", -150), AwardItem("c06", -150), AwardItem("user2", -150), AwardBuildingOwned("dou_shop"), IncrementVariable("shopsowned")},
	oncomplete_hard = {IncrementVariable("rank3_work"), AwardItem("e09", -250), AwardItem("c06", -250), AwardItem("user2", -250), AwardBuildingOwned("dou_shop"), IncrementVariable("shopsowned")},
	require = {RequireQuestComplete("rank3_09")},
}

CreateQuest
{
	name = "rank3_11",
	starter = "trav_09",
	ender = "bag_shopkeep",
	accept = "iwould",
	defer = "maybelater",
	reject = "none",
	priority = 900,
	onaccept = {AwardUnlockIngredient("pomegranate"), AwardText("rank3_11_extra01"), AwardUnlockIngredient("amaretto"), AwardUnlockPort("baghdad"), AwardBlockBuilding("bag_shop"), AwardRecipe("m08"), AwardDialog("recipes"), AwardUnlockCharacter("trav_09")},
	goals = { RequireItem("m08", 50), RequireItem("c12", 50), HintPerson("bag_shopkeep", "bag_shop", "baghdad")},
	goals_medium = { RequireItem("m08", 85), RequireItem("c12", 85), HintPerson("bag_shopkeep", "bag_shop", "baghdad")},
	goals_hard = { RequireItem("m08", 130), RequireItem("c12", 130), HintPerson("bag_shopkeep", "bag_shop", "baghdad")},
	oncomplete = {IncrementVariable("rank3_work"), AwardItem("m08", -50), AwardItem("c12", -50), AwardRecipe("m09"), AwardDialog("recipes"), AwardUnblockBuilding("bag_shop"), AwardOfferQuest("rank3_12"), AwardUnlockCharacter("bag_marketkeep")},
	oncomplete_medium = {IncrementVariable("rank3_work"), AwardItem("m08", -85), AwardItem("c12", -85), AwardRecipe("m09"), AwardDialog("recipes"), AwardUnblockBuilding("bag_shop"), AwardOfferQuest("rank3_12"), AwardUnlockCharacter("bag_marketkeep")},
	oncomplete_hard = {IncrementVariable("rank3_work"), AwardItem("m08", -130), AwardItem("c12", -130), AwardRecipe("m09"), AwardDialog("recipes"), AwardUnblockBuilding("bag_shop"), AwardOfferQuest("rank3_12"), AwardUnlockCharacter("bag_marketkeep")},
	require = {RequireNoOffers(2), RequireRecipesKnown(6, "user"), RequireQuestComplete("rank3_01"), RequireRecipesKnown(36), RequireMinRank(3), RequireRecipe("m01"), RequireRecipe("e01"), RequireRecipe("c12"),  RequirePort("lasvegas"), RequireCharHasNoActiveOrder("trav_09")},
}

CreateQuest
{
	name = "rank3_12",
	starter = "bag_shopkeep",
	ender = "bag_towerkeep",
	accept = "indeed",
	defer = "notnow",
	reject = "none",
	onaccept = {AwardText("rank3_12_extra01")},
	goals = { RequireItem("m09", 200), HintPerson("bag_towerkeep", "bag_tower", "baghdad")},
	goals_medium = { RequireItem("m09", 280), HintPerson("bag_towerkeep", "bag_tower", "baghdad")},
	goals_hard = { RequireItem("m09", 440), HintPerson("bag_towerkeep", "bag_tower", "baghdad")},
	oncomplete = {IncrementVariable("rank3_work"), AwardItem("m09", -200), AwardHappiness("bag_towerkeep", 100), AwardRecipe("m11"), AwardDialog("recipes"), AwardOfferQuest("rank3_13"), AwardUnlockCharacter("bag_towerkeep")},
	oncomplete_medium = {IncrementVariable("rank3_work"), AwardItem("m09", -280), AwardHappiness("bag_towerkeep", 100), AwardRecipe("m11"), AwardDialog("recipes"), AwardOfferQuest("rank3_13"), AwardUnlockCharacter("bag_towerkeep")},
	oncomplete_hard = {IncrementVariable("rank3_work"), AwardItem("m09", -440), AwardHappiness("bag_towerkeep", 100), AwardRecipe("m11"), AwardDialog("recipes"), AwardOfferQuest("rank3_13"), AwardUnlockCharacter("bag_towerkeep")},
	require = {RequireQuestComplete("rank3_11")},
}

CreateQuest
{
	name = "rank3_13",
	starter = "bag_towerkeep",
	ender = "bag_shopkeep",
	accept = "imonit",
	defer = "none",
	reject = "none",
	goals = { RequireItem("m11", 200), RequireItem("user4", 50), RequireItem("user5", 50), RequireItem("user6", 50), HintPerson("bag_shopkeep", "bag_shop", "baghdad")},
	goals_medium = { RequireItem("m11", 300), RequireItem("user4", 80), RequireItem("user5", 80), RequireItem("user6", 80), HintPerson("bag_shopkeep", "bag_shop", "baghdad")},
	goals_hard = { RequireItem("m11", 460), RequireItem("user4", 130), RequireItem("user5", 130), RequireItem("user6", 130), HintPerson("bag_shopkeep", "bag_shop", "baghdad")},
	oncomplete = {IncrementVariable("rank3_work"), AwardItem("m11", -200), AwardItem("user4", -50), AwardItem("user5", -50), AwardItem("user6", -50), AwardBuildingOwned("bag_shop"), IncrementVariable("shopsowned"), AwardUnlockCharacter("bag_shopkeep")},
	oncomplete_medium = {IncrementVariable("rank3_work"), AwardItem("m11", -300), AwardItem("user4", -80), AwardItem("user5", -80), AwardItem("user6", -80), AwardBuildingOwned("bag_shop"), IncrementVariable("shopsowned"), AwardUnlockCharacter("bag_shopkeep")},
	oncomplete_hard = {IncrementVariable("rank3_work"), AwardItem("m11", -460), AwardItem("user4", -130), AwardItem("user5", -130), AwardItem("user6", -130), AwardBuildingOwned("bag_shop"), IncrementVariable("shopsowned"), AwardUnlockCharacter("bag_shopkeep")},
	require = {RequireQuestComplete("rank3_12")},
}


CreateQuest
{
	name = "ugr_04",
	starter = "main_whit",
	accept = "thankyou",
	defer = "none",
	reject = "none",
	autoComplete = true,
	onaccept = {AwardCustomSlot(2), AwardDialog("recipes"), AwardDelayQuest("ugr_prompt", 15)},
	require = { RequireMinRank(3), RequireQuestComplete("ugr_03"), RequireRecipe("e01"), RequireRecipesKnown(7, "exotic")},
	require_medium = { RequireMinRank(3), RequireQuestComplete("ugr_03"), RequireRecipe("e01"), RequireRecipesKnown(8, "exotic"), RequireRecipesMade(4, "exotic")},
	require_hard = { RequireMinRank(3), RequireQuestComplete("ugr_03"), RequireRecipe("e01"), RequireRecipesKnown(9, "exotic"), RequireRecipesMade(6, "exotic")},
	visible = false,
}

CreateQuest
{
	name = "ugr_05",
	starter = "main_jose",
	accept = "understood",
	defer = "none",
	reject = "none",
	autoComplete = true,
	onaccept = {AwardCustomSlot(), AwardDialog("recipes"), AwardDelayQuest("ugr_prompt", 12)},
	require = { RequireMinRank(3), RequireQuestComplete("ugr_03"), RequireRecipe("m01"), RequireRecipesKnown(5, "blend")},
	require_medium = { RequireMinRank(3), RequireQuestComplete("ugr_03"), RequireRecipe("m01"), RequireRecipesKnown(6, "blend"), RequireRecipesMade(3, "blend")},
	require_hard = { RequireMinRank(3), RequireQuestComplete("ugr_03"), RequireRecipe("m01"), RequireRecipesKnown(7, "blend"), RequireRecipesMade(5, "blend")},
	visible = false,
}

CreateQuest
{
	name = "rank4_promo_prompt",
	starter = "announcer",
	accept = "verywell",
	defer = "none",
	reject = "none",
	autoComplete = true,
	priority = 1,
	require = {RequireNoOffers(2), RequireNoCompletes(2), RequireShopsOwned(5), RequireRecipesMade(4, "user"), RequireRecipesKnown(9, "user"), RequireVariableMoreThan("endorsed", 4), RequireVariableEqual("ugr_slots", 0), RequireQuestIncomplete("rank4_promo"), RequireQuestNotActive("rank4_promo")},
	onaccept = {AwardPlaceCharacter("main_alex", "_travelers"), AwardDelayQuest("rank4_promo", 6)},
	repeatable = 25,
	visible = false,
}

CreateQuest
{
	name = "rank4_promo",
	starter = "main_alex",
	accept = "thankyou",
	defer = "none",
	reject = "none",
	autoComplete = true,
	priority = 1,
	onaccept ={AwardText("rank4_promo_extra01"), AwardRank(4), AwardCustomSlot(2), AwardDialog("recipes"), AwardDelayQuest("ugr_prompt", 19), AwardRemoveCharacter("main_alex", "_travelers"), AwardUnlockCharacter("evil_tyso")},
	require = {RequireQuestComplete("rank4_promo_prompt")},
	visible = false,
}

CreateQuest
{
	name = "rank3_story_main_elen_1",
	starter = "main_elen",
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireMinRank(2), RequirePort("bali")},
	onaccept = {AwardUnlockCharacter("main_elen")},
	priority = 1,
	visible = false,
	autoComplete = true,
}

CreateQuest
{
	name = "rank3_story_tok_mountainkeep_1",
	starter = "tok_mountainkeep",
	accept = "ok",
	defer = "none",
	reject = "none",
	onaccept = {AwardText("rank3_story_tok_mountainkeep_1_extra01"), AwardUnlockCharacter("tok_mountainkeep")},
	require = {RequireQuestComplete("plot_points_05"), RequireQuestComplete("rank2_story_tok_mountainkeep_1")},
	priority = 1,
	visible = false,
	autoComplete = true,
}


--[[--------------------------------------------------------------------------

CreateQuest
{
	name = "ugr_06",
	starter = "announcer",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	onaccept = {AwardCustomSlot(2), AwardDialog("recipes"), AwardDelayQuest("ugr_prompt", 19)},
	require = { RequireMinRank(4), RequireQuestComplete("ugr_05"), RequireRecipe("e01"), RequireRecipesKnown(9, "user"), RequireRecipesKnown(6, "exotic")},
	visible = false,
}

--]]--------------------------------------------------------------------------