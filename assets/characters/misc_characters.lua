--[[---------------------------------------------------------------------------
	Chocolatier Three: Travelers and Misc characters
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Main Characters

CreateCharacter("main_alex")
CreateCharacter("main_chas")
CreateCharacter("main_deit")
CreateCharacter("main_elen")
CreateCharacter("main_evan")
CreateCharacter("main_feli")
CreateCharacter("main_jose")
CreateCharacter("main_sean")
CreateCharacter("main_tedd")
CreateCharacter("main_whit")
CreateCharacter("main_zach")
CreateCharacter("evil_bian")
CreateCharacter("evil_kath")
CreateCharacter("evil_wolf")
CreateCharacter("evil_tyso")

-------------------------------------------------------------------------------
-- "Primary" characters

CreatePrimaryCharacter("las_casinokeep")
CreatePrimaryCharacter("announcer")

-------------------------------------------------------------------------------
-- Travelers

CreateCharacter("trav_01")
CreateCharacter("trav_02")
CreateCharacter("trav_03")
CreateCharacter("trav_04")
CreateCharacter("trav_05")
CreateCharacter("trav_06")
CreateCharacter("trav_07")
CreateCharacter("trav_08")
CreateCharacter("trav_09")
CreateCharacter("trav_10")
CreateCharacter("trav_11")
CreateCharacter("main_loud")
CreateCharacter("main_sara")
CreateCharacter("dou_bldg1keep")
CreateCharacter("bag_bldg2keep")
CreateCharacter("kon_bldg2keep")
CreateCharacter("mah_shopkeep")
CreateCharacter("rey_xxxxkeep")
CreateCharacter("tor_bldg1keep")
CreateCharacter("tor_bldg2keep")
CreateCharacter("wel_bldg1keep")
CreateCharacter("zur_riverkeep")

-------------------------------------------------------------------------------
-- The "travelers" building

-- Note: one character must ALWAYS be in the travel set -- I'm arbitrarily choosing trav_01,
-- but you can make this whatever you want

EmptyBuilding("_travelers")
_travelers.type = "special"
_travelers.characters[1] = { "trav_01" }
_travelers.characters[2] = { "trav_02" }
_travelers.characters[3] = { "trav_03" }
_travelers.characters[4] = { "trav_04" }
_travelers.characters[5] = { "trav_05" }
_travelers.characters[6] = { "trav_06" }
_travelers.characters[7] = { "trav_07" }
_travelers.characters[8] = { "trav_08" }
_travelers.characters[9] = { "trav_09" }
_travelers.characters[10] = { "trav_10" }
_travelers.characters[11] = { "trav_11" }
_travelers.characters[12] = { "mah_shopkeep" }
_travelers.characters[13] = { "main_loud" }
_travelers.characters[14] = { "main_sara" }
_TravelCharacters = { "trav_01", "trav_02", "trav_03", "trav_04", "trav_05", "trav_06", "trav_07", "trav_08", "trav_09", "trav_10", "trav_11", "mah_shopkeep", "main_loud", "main_sara" }

-------------------------------------------------------------------------------
-- The "empty" building

EmptyBuilding("_empty")
_empty.type = "special"
_empty.characters[1] = { "tor_bldg2keep" }
_empty.characters[2] = { "wel_bldg1keep" }
_empty.characters[3] = { "dou_bldg1keep" }
_empty.characters[4] = { "bag_bldg2keep" }
_empty.characters[5] = { "kon_bldg2keep" }
_empty.characters[6] = { "rey_xxxxkeep" }
_empty.characters[7] = { "tor_bldg1keep" }
_empty.characters[8] = { "zur_riverkeep" }

-- NOTE: As long as these are defined with CreateCharacter above, do NOT use quotation marks
_EmptyCharacters = { "tor_bldg2keep", "wel_bldg1keep", "dou_bldg1keep", "bag_bldg2keep", "kon_bldg2keep", "rey_xxxxkeep", "tor_bldg1keep", "zur_riverkeep", }

-------------------------------------------------------------------------------
-- Character Preferences

-- bag_bldg2keep: Salwa Tooma
bag_bldg2keep.likes = {
    ingredients = { cardamom=true, sumac=true, fig=true, date=true, tan_coffee=true }
}
bag_bldg2keep.dislikes = {
    products = { b02=true }, -- Milk Chocolate Bars
    ingredients = { amaretto=true, brandy=true, grand_marnier=true, kahlua=true, rum=true, whiskey=true } -- Muslim, cannot drink alcohol
}

-- dou_bldg1keep: Ernest Mimboe
dou_bldg1keep.likes = {
	products = { b04=true, t02=true },
    ingredients = { dou_cacao=true, allspice=true, ginger=true }
}
dou_bldg1keep.dislikes = {
    ingredients = { whipped_cream=true, cream=true, butter=true, milk=true } -- Lactose-intolerant
}

-- kon_bldg2keep: Onaona Waipa
kon_bldg2keep.likes = {
    ingredients = { pineapple=true, passionfruit=true, mango=true, kon_coffee=true }
}
kon_bldg2keep.dislikes = {
    ingredients = { nutmeg=true, clove=true, pumpkin=true }
}

-- rey_xxxxkeep: Hjálmar Helguson
rey_xxxxkeep.likes = {
    ingredients = { salt=true, blueberry=true, blackberry=true }
}
rey_xxxxkeep.dislikes = {
    ingredients = { lychee=true }
}

-- tor_bldg1keep: Valerie McGill
tor_bldg1keep.likes = {
	products = { t01=true },
    ingredients = { salt=true, almond=true, pistachio=true }
}
tor_bldg1keep.dislikes = {}

-- tor_bldg2keep: Syd Birchmore
tor_bldg2keep.likes = {
    products = { b02=true }, -- Milk Chocolate Bars
    ingredients = { maple=true, apple=true, butter=true, pecan=true, walnut=true }
}
tor_bldg2keep.dislikes = {
    ingredients = { pepper=true, wasabi=true }
}

-- wel_bldg1keep: Sissy Pickston
wel_bldg1keep.likes = {
	categories = { beverage=true },
    ingredients = { peanut=true, raspberry=true, toffee=true, caramel=true }
}
wel_bldg1keep.dislikes = {}

-- zur_riverkeep: Gilles Zuelle
zur_riverkeep.likes = {
    categories = { bar=true, beverage=true },
    ingredients = { cherry=true, lemon=true, grand_marnier=true }
}
zur_riverkeep.dislikes = {}

-- trav_01: Shobha Mudaliar
trav_01.likes = {
    products = { e08=true },
    ingredients = { tea=true, turmeric=true, cinnamon=true, bal_coffee=true, bal_cacao=true }
}
trav_01.dislikes = {
    products = { b01=true }, -- Basic Chocolate Bars
    ingredients = { lemon=true, lime=true }
}

-- trav_02: Surea Siqueira
trav_02.likes = {
	categories = { infusion=true },
    ingredients = { lime=true, passionfruit=true, pepper=true, bog_coffee=true, rum=true }
}
trav_02.dislikes = {
    ingredients = { mint=true, pumpkin=true }
}

-- trav_03: Rahim Talib
trav_03.likes = {
    ingredients = { tan_coffee=true, espresso=true, blueberry=true, date=true, pistachio=true }
}
trav_03.dislikes = {
    ingredients = { amaretto=true, brandy=true, grand_marnier=true, kahlua=true, rum=true, whiskey=true } -- Muslim, cannot drink alcohol
}

-- trav_04: Pamela Harrington
trav_04.likes = {
    ingredients = { apple=true, blueberry=true, maple=true, peanut=true, strawberry=true }
}
trav_04.dislikes = {
    categories = { exotic=true },
    ingredients = { wasabi=true, turmeric=true, sumac=true }
}

-- trav_05: Mariama Nana
trav_05.likes = {
    ingredients = { dou_cacao=true, banana=true, coconut=true, mango=true, nutmeg=true }
}
trav_05.dislikes = {
    ingredients = { caramel=true, maple=true }
}

-- trav_06: Motochika Haneda
trav_06.likes = {
    ingredients = { matcha=true, wasabi=true, sesame=true, tea=true, ginger=true, caramel=true }
}
trav_06.dislikes = {}

-- trav_07: Rufus Loddington
trav_07.likes = {
    categories = { blend=true },
    ingredients = { whiskey=true, grand_marnier=true, espresso=true, macadamia=true, fig=true }
}
trav_07.dislikes = {
    products = { b01=true },
    ingredients = { honey=true }
}

-- trav_08: Yuriko Haneda
trav_08.likes = {
    categories = { exotic=true },
    ingredients = { rose=true, lavender=true, cherry=true, tea=true, matcha=true, lychee=true }
}
trav_08.dislikes = {
	categories = { beverage=true, blend=true },
    ingredients = { pepper=true, espresso=true }
}

-- trav_09: François Moreau
trav_09.likes = {
    products = { b12=true },
    ingredients = { brandy=true, tan_coffee=true, almond=true, walnut=true }
}
trav_09.dislikes = {
    ingredients = { strawberry=true, raspberry=true, mango=true, passionfruit=true }
}

-- trav_10: Soraya Taheri
trav_10.likes = {
    ingredients = { saffron=true, pistachio=true, date=true, cardamom=true, fig=true }
}
trav_10.dislikes = {
    ingredients = { amaretto=true, brandy=true, grand_marnier=true, kahlua=true, rum=true, whiskey=true } -- Muslim, cannot drink alcohol
}

-- trav_11: Agostina Calvino
trav_11.likes = {
    categories = { truffle=true },
	products = { m07=true },
    ingredients = { amaretto=true, espresso=true, hazelnut=true, orange=true, lim_cacao=true }
}
trav_11.dislikes = {
    ingredients = { peanut=true, coconut=true }
}

main_alex.likes = {
    categories = { exotic=true, user=true }, -- She loves player creations!
    ingredients = { anise=true, pepper=true, currant=true, lime=true, saffron=true, pumpkin=true, clove=true } -- Some of these are the secret ingredients she helped pioneer in her earlier years
}
main_alex.dislikes = {
    products = { b01=true } -- Finds the most basic bar uninspired.
}

main_deit.likes = {
    categories = { infusion=true },
    ingredients = { lime=true, ginger=true, macadamia=true, wasabi=true, cashew=true, matcha=true }
}
-- No dislikes; he enjoys new experiences.

main_elen.likes = {
    categories = { truffle=true },
    products = { t05=true },
    ingredients = { amaretto=true, fig=true, rose=true, raspberry=true, tea=true }
}
main_elen.dislikes = {
    ingredients = { whiskey=true, passionfruit=true, coconut=true, peanut=true }
}

main_evan.likes = {
    categories = { truffle=true },
    products = { t12=true }, -- Blended Varietal Cacao Dark Truffles
    ingredients = { lemon=true, tea=true, rose=true, lavender=true, vanilla=true }
}
main_evan.dislikes = {
    ingredients = { peanut=true, wasabi=true } -- Prefers elegance over novelty or common flavors.
}

main_feli.likes = {
    categories = { beverage=true, blend=true },
    ingredients = { kon_coffee=true, hav_coffee=true, tan_coffee=true, espresso=true }
}
main_feli.dislikes = {
    ingredients = { wasabi=true, pepper=true } -- He's a traditionalist, no spicy stuff.
}

main_jose.likes = {
    categories = { truffle=true, blend=true },
    products = { m03=true },
    ingredients = { whiskey=true, pecan=true, maple=true, pumpkin=true, hazelnut=true, bog_coffee=true, cinnamon=true }
}
main_jose.dislikes = {
    ingredients = { rose=true, lavender=true, lemon=true, lime=true }
}

main_loud.likes = {
    categories = { beverage=true, bar=true },
    products = { m01=true, b11=true },
    ingredients = { espresso=true, coffee=true, kon_coffee=true, peanut=true, almond=true }
}

main_loud.dislikes = {
    categories = { truffle=true },
    ingredients = { caramel=true, maple=true, mango=true, whipped_cream=true }
}

main_tedd.likes = {
    categories = { user=true } -- He is most interested in what YOU create.
}
-- Teddy has no dislikes; he's a true connoisseur of all things chocolate and coffee.

main_whit.likes = {
    categories = { exotic=true },
    ingredients = { lime=true, mango=true, passionfruit=true, ginger=true }
}
main_whit.dislikes = {
    products = { b01=true, b02=true } -- She finds simple bars boring.
}

main_zach.likes = {
    categories = { bar=true, beverage=true, user=true },
    products = { b12=true, c07=true },
    ingredients = { tan_coffee=true, cacao=true, cinnamon=true, orange=true, almond=true, saffron=true, sumac=true }
}

main_zach.dislikes = {
    ingredients = { toffee=true, maple=true }
}