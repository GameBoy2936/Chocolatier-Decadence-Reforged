--[[--------------------------------------------------------------------------
	Chocolatier Three: Quests
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

CreateQuest
{
	name = "rank4_kath_bribe_prep",
	starter = "trav_02",
	accept = "ok",
	defer = "none",
	reject = "none",
	autoComplete = true,
	require = {RequireNoOffers(2), RequireNoCompletes(2), RequireVariableEqual("ugr_slots", 0), RequireMinRank(4), RequireVariableEqual("gameover", 3), RequirePort("baghdad")},
	priority = 1,
	onaccept = {AwardPlaceCharacter("main_alex", "_travelers")},
	visible = false,
}

CreateQuest
{
	name = "rank4_kath_bribe_intro",
	starter = "main_alex",
	accept = "imlistening",
	defer = "none",
	reject = "none",
	require = {RequireQuestComplete("rank4_kath_bribe_prep"), RequireMinRank(4), RequireVariableEqual("gameover", 3), RequirePort("baghdad")},
	priority = 20,
	onaccept = {AwardOfferQuest("rank4_kath_bribe")},
	autoComplete = true,
	visible = false,
}

CreateQuest
{
	name = "rank4_kath_bribe",
	starter = "main_alex",
	ender = "evil_kath",
	accept = "iam",
	defer = "none",
	reject = "none",
	require = {RequireQuestComplete("rank4_kath_bribe_prep"), RequireQuestComplete("rank4_kath_bribe_intro"), RequireMinRank(4), RequireVariableEqual("gameover", 3), RequirePort("baghdad")},
	priority = 20,
	onaccept = {AwardRemoveCharacter("evil_kath","_travelers"), AwardUnlockPort("falklands")},
	goals = { RequireItem("b12", 25), RequireItem("c10", 25), RequireItem("i12", 25), RequireItem("t11", 25), RequireItem("m07", 25), RequireItem("e12", 25), HintPerson("evil_kath", "fal_board", "falklands")},
	goals_medium = { RequireItem("b12", 100), RequireItem("c10", 100), RequireItem("i12", 100), RequireItem("t11", 100), RequireItem("m07", 100), RequireItem("e12", 100), HintPerson("evil_kath", "fal_board", "falklands")},
	goals_hard = { RequireItem("b12", 250), RequireItem("c10", 250), RequireItem("i12", 250), RequireItem("t11", 250), RequireItem("m07", 250), RequireItem("e12", 250), HintPerson("evil_kath", "fal_board", "falklands")},
	oncomplete = {IncrementVariable("gameover"), AwardItem("b12", -25), AwardItem("c10", -25), AwardItem("i12", -25), AwardItem("t11", -25), AwardItem("m07", -25), AwardItem("e12", -25), AwardText("rank4_kath_bribe_extra01"), AwardUnlockPort("belize"), AwardBlockBuilding("bel_hut"), AwardRemoveCharacter("bel_hutkeep", "bel_hut"), AwardPlaceCharacter("bel_hutkeep", "bel_ruins"), AwardPlaceCharacter("trav_03", "bel_hut"), AwardEnableOrderForChar("evil_kath"), AwardEnableOrderForBuilding("fal_board"), AwardUnlockCharacter("evil_kath"), AwardUnlockCharacter("evil_wolf"), AwardUnlockCharacter("fal_xxxkeep")},
	oncomplete_medium = {IncrementVariable("gameover"), AwardItem("b12", -100), AwardItem("c10", -100), AwardItem("i12", -100), AwardItem("t11", -100), AwardItem("m07", -100), AwardItem("e12", -100), AwardText("rank4_kath_bribe_extra01"), AwardUnlockPort("belize"), AwardBlockBuilding("bel_hut"), AwardRemoveCharacter("bel_hutkeep", "bel_hut"), AwardPlaceCharacter("bel_hutkeep", "bel_ruins"), AwardPlaceCharacter("trav_03", "bel_hut"), AwardEnableOrderForChar("evil_kath"), AwardEnableOrderForBuilding("fal_board"), AwardUnlockCharacter("evil_kath"), AwardUnlockCharacter("evil_wolf"), AwardUnlockCharacter("fal_xxxkeep")},
	oncomplete_hard = {IncrementVariable("gameover"), AwardItem("b12", -250), AwardItem("c10", -250), AwardItem("i12", -250), AwardItem("t11", -250), AwardItem("m07", -250), AwardItem("e12", -250), AwardText("rank4_kath_bribe_extra01"), AwardUnlockPort("belize"), AwardBlockBuilding("bel_hut"), AwardRemoveCharacter("bel_hutkeep", "bel_hut"), AwardPlaceCharacter("bel_hutkeep", "bel_ruins"), AwardPlaceCharacter("trav_03", "bel_hut"), AwardEnableOrderForChar("evil_kath"), AwardEnableOrderForBuilding("fal_board"), AwardUnlockCharacter("evil_kath"), AwardUnlockCharacter("evil_wolf"), AwardUnlockCharacter("fal_xxxkeep")},
}

CreateQuest
{
	name = "rank4_sean_ransom_01",
	starter = "bel_hutkeep",
	accept = "ok",
	defer = "none",
	reject = "none",
	visible = false,
	autoComplete = true,
	require = {RequireMinRank(4), RequireVariableEqual("gameover", 4)},
}

CreateQuest
{
	name = "rank4_sean_ransom_morecash",
	starter = "bel_hutkeep",
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestComplete("rank4_sean_ransom_01"), RequireQuestIncomplete("rank4_sean_ransom_02"), RequireMaxMoney(999999), RequireQuestNotActive("rank4_sean_ransom_02"),},
	require_medium = {RequireQuestComplete("rank4_sean_ransom_01"), RequireQuestIncomplete("rank4_sean_ransom_02"), RequireMaxMoney(9999999), RequireQuestNotActive("rank4_sean_ransom_02"),},
	require_hard = {RequireQuestComplete("rank4_sean_ransom_01"), RequireQuestIncomplete("rank4_sean_ransom_02"), RequireMaxMoney(49999999), RequireQuestNotActive("rank4_sean_ransom_02"),},
	autoComplete = true,
	repeatable = 0,
	visible = false,
}

CreateQuest
{
	name = "rank4_sean_ransom_02",
	starter = "bel_hutkeep",
	accept = "quest_yes",
	defer = "maybelater",
	reject = "none",
	require = {RequireQuestComplete("rank4_sean_ransom_01"), RequireMinMoney(1000000)},
	require_medium = {RequireQuestComplete("rank4_sean_ransom_01"), RequireMinMoney(10000000)},
	require_hard = {RequireQuestComplete("rank4_sean_ransom_01"), RequireMinMoney(50000000)},
	onaccept = {AwardMoney(-1000000), AwardText("rank4_sean_ransom_02_extra01"), AwardRemoveCharacter("bel_hutkeep", "bel_ruins"), AwardDelayQuest("rank4_sean_return", 11)},
	onaccept_medium = {AwardMoney(-10000000), AwardText("rank4_sean_ransom_02_extra01"), AwardRemoveCharacter("bel_hutkeep", "bel_ruins"), AwardDelayQuest("rank4_sean_return", 11)},
	onaccept_hard = {AwardMoney(-50000000), AwardText("rank4_sean_ransom_02_extra01"), AwardRemoveCharacter("bel_hutkeep", "bel_ruins"), AwardDelayQuest("rank4_sean_return", 11)},
}

CreateQuest
{
	name = "rank4_sean_return",
	starter = "trav_11",
	ender = "bel_hutkeep",
	accept = "letsgo",
	defer = "none",
	reject = "none",
	priority = 1,
	onaccept = {AwardPlaceCharacter("bel_hutkeep", "bel_ruins")},
	goals = {HintPerson("bel_hutkeep", "bel_ruins", "belize")},
	require = {RequireQuestComplete("rank4_sean_ransom_02")},
	oncomplete = {IncrementVariable("gameover"), AwardText("rank4_sean_thanks_text01", "main_sean"), AwardText("rank4_sean_thanks_text02", "main_sean"), AwardText("rank4_sean_thanks_text03", "main_sean"), AwardHappiness("main_sean", 100), AwardText("rank4_sean_thanks_text04", "main_sean"), AwardRemoveCharacter("bel_hutkeep", "bel_ruins"), AwardRemoveCharacter("trav_03", "bel_hut"), AwardPlaceCharacter("bel_hutkeep", "bel_hut"), AwardUnblockBuilding("bel_hut"), AwardUnlockIngredient("bel_cacao"), AwardPlaceCharacter("main_sean", "zur_mountain"), AwardEnableOrderForChar("main_sean"), AwardEnableOrderForChar("bel_hutkeep"), AwardEnableOrderForBuilding("bel_ruins"), AwardEnableOrderForBuilding("bel_hut"), AwardUnlockCharacter("main_sean"), AwardUnlockCharacter("bel_hutkeep")},
}

CreateQuest
{
	name = "rank4_final_quest_part1",
	starter = "main_alex",
	ender = "main_evan",
	accept = "ok",
	defer = "none",
	reject = "none",
	priority = 1,
	onaccept ={AwardText("rank4_final_quest_part1_extra01"), AwardText("rank4_final_quest_part1_extra02"), AwardCustomSlot(), AwardDialog("recipes"), AwardDelayQuest("ugr_prompt", 15), AwardText("rank4_final_quest_part1_extra03"), AwardText("rank4_final_quest_part1_extra04"), AwardDisableOrderForChar("main_evan")},
	require = {RequireRecipesKnown(83), RequireMinRank(4), RequireVariableEqual("gameover", 5)},
	goals = {RequireItem("user1", 200), RequireItem("user2", 200), RequireItem("user3", 200), RequireItem("user4", 200), RequireItem("user5", 200), RequireItem("user6", 200), RequireRecipe("user12"), HintPerson("main_evan", "san_bchq", "sanfrancisco")},
	goals_medium = {RequireItem("user1", 500), RequireItem("user2", 500), RequireItem("user3", 500), RequireItem("user4", 500), RequireItem("user5", 500), RequireItem("user6", 500), RequireRecipe("user12"), HintPerson("main_evan", "san_bchq", "sanfrancisco")},
	goals_hard = {RequireItem("user1", 1000), RequireItem("user2", 1000), RequireItem("user3", 1000), RequireItem("user4", 1000), RequireItem("user5", 1000), RequireItem("user6", 1000), RequireRecipe("user12"), HintPerson("main_evan", "san_bchq", "sanfrancisco")},
	oncomplete = {AwardItem("user1", -200), AwardItem("user2", -200), AwardItem("user3", -200), AwardItem("user4", -200), AwardItem("user5", -200), AwardItem("user6", -200), AwardOfferQuest("rank4_final_quest_part2")},
	oncomplete_medium = {AwardItem("user1", -500), AwardItem("user2", -500), AwardItem("user3", -500), AwardItem("user4", -500), AwardItem("user5", -500), AwardItem("user6", -500), AwardOfferQuest("rank4_final_quest_part2")},
	oncomplete_hard = {AwardItem("user1", -1000), AwardItem("user2", -1000), AwardItem("user3", -1000), AwardItem("user4", -1000), AwardItem("user5", -1000), AwardItem("user6", -1000), AwardOfferQuest("rank4_final_quest_part2")},
}

CreateQuest
{
	name = "rank4_final_quest_part2",
	starter = "main_evan",
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestComplete("final_quest")},
	goals = {RequireItem("user7", 200), RequireItem("user8", 200), RequireItem("user9", 200), RequireItem("user10", 200), RequireItem("user11", 200), RequireItem("user12", 200), HintPerson("main_evan", "san_bchq", "sanfrancisco")},
	goals = {RequireItem("user7", 500), RequireItem("user8", 500), RequireItem("user9", 500), RequireItem("user10", 500), RequireItem("user11", 500), RequireItem("user12", 500), HintPerson("main_evan", "san_bchq", "sanfrancisco")},
	goals = {RequireItem("user7", 1000), RequireItem("user8", 1000), RequireItem("user9", 1000), RequireItem("user10", 1000), RequireItem("user11", 1000), RequireItem("user12", 1000), HintPerson("main_evan", "san_bchq", "sanfrancisco")},
	oncomplete = {AwardItem("user7", -200), AwardItem("user8", -200), AwardItem("user9", -200), AwardItem("user10", -200), AwardItem("user11", -200), AwardItem("user12", -200), AwardDelayQuest("rank5_promo", 5), AwardEnableOrderForChar("main_evan")},
	oncomplete = {AwardItem("user7", -500), AwardItem("user8", -500), AwardItem("user9", -500), AwardItem("user10", -500), AwardItem("user11", -500), AwardItem("user12", -500), AwardDelayQuest("rank5_promo", 5), AwardEnableOrderForChar("main_evan")},
	oncomplete = {AwardItem("user7", -1000), AwardItem("user8", -1000), AwardItem("user9", -1000), AwardItem("user10", -1000), AwardItem("user11", -1000), AwardItem("user12", -1000), AwardDelayQuest("rank5_promo", 5), AwardEnableOrderForChar("main_evan")},
}

CreateQuest
{
	name = "rank5_promo",
	starter = "announcer",
	accept = "ok",
	defer = "none",
	reject = "none",
	automcomplete = true,
	visible = false,
	onaccept ={AwardRank(5), AwardDelayQuest("rank4_alex_thanks", 3), AwardText("rank5_promo_extra01"), AwardMoney(10000000), AwardEnableOrderForChar("main_alex"), AwardEnableOrderForChar("announcer"), AwardPlaceCharacter("announcer", "_travelers"), AwardCustomSlot(12)},
	onaccept_medium ={AwardRank(5), AwardDelayQuest("rank4_alex_thanks", 3), AwardText("rank5_promo_extra01"), AwardMoney(25000000), AwardEnableOrderForChar("main_alex"), AwardEnableOrderForChar("announcer"), AwardPlaceCharacter("announcer", "_travelers"), AwardCustomSlot(12)},
	onaccept_hard ={AwardRank(5), AwardDelayQuest("rank4_alex_thanks", 3), AwardText("rank5_promo_extra01"), AwardMoney(100000000), AwardEnableOrderForChar("main_alex"), AwardEnableOrderForChar("announcer"), AwardPlaceCharacter("announcer", "_travelers"), AwardCustomSlot(12)},
	require = {RequireQuestComplete("rank4_final_quest_part2")},
}

CreateQuest
{
	name = "rank4_alex_thanks",
	starter = "main_alex",
	accept = "ok",
	defer = "none",
	reject = "none",
	automcomplete = true,
	visible = false,
	require = {RequireQuestComplete("rank5_promo")},
}

CreateQuest
{
	name = "rank4_story_tok_mountainkeep_1",
	starter = "tok_mountainkeep",
	accept = "ok",
	defer = "none",
	reject = "none",
	require = {RequireQuestComplete("seans_ransom_02"), RequireQuestNotActive("rank4_sean_return"), RequireQuestIncomplete("rank4_sean_return")},
	priority = 1,
	visible = false,
	autoComplete = true,
}

CreateQuest
{
	name = "rank4_story_tok_mountainkeep_2",
	starter = "tok_mountainkeep",
	ender = "main_sean",
	accept = "willdo",
	defer = "notnow",
	reject = "none",
	goals = {HintPerson("main_sean", "zur_mountain", "zurich")},
	oncomplete = {AwardItem("bel_cacao", 200), AwardHappiness("main_sean", 100), AwardText("rank4_story_tok_mountainkeep_2_extra01"), AwardDialog("inventory"),},
	require = {RequireQuestComplete("rank4_sean_return")},
	priority = 1,
}