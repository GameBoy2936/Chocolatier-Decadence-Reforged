--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Centralized Character Data)
	Copyright (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- This file serves as the single source of truth for all static character lore.
-- It maps demographics, religions, and specific likes/dislikes for the economy engine.
-- It is loaded after all characters have been instantiated but before the game loop starts.

CharacterData = {

	-- ------------------------------------------------------------------------
	-- MAIN CHARACTERS (The Baumeister/Tangye Clan)
	-- ------------------------------------------------------------------------
	
	main_alex = {
		gender = "female", nationality = "usa", religion = "christian",
		likes = {
			categories = { exotic=true, user=true }, 
			ingredients = { pepper=true, currant=true, lime=true, saffron=true, pumpkin=true, anise=true, clove=true } 
		},
		dislikes = { products = { b01=true } }
	},

	main_sean = {
		gender = "male", nationality = "usa", religion = "christian",
		likes = { ingredients = { bel_cacao=true, honey=true, whiskey=true } }
	},

	main_zach = {
		gender = "male", nationality = "usa", 
		likes = {
			categories = { beverage=true, blend=true, user=true },
			ingredients = { tan_coffee=true, mint=true, cinnamon=true, cardamom=true }
		}
	},

	main_loud = {
		gender = "male", nationality = "usa",
		likes = {
			categories = { blend=true }, 
			ingredients = { kahlua=true, espresso=true, rum=true } 
		},
		dislikes = { categories = { truffle=true } } 
	},

	main_jose = {
		gender = "male", nationality = "usa", religion = "christian",
		likes = {
			categories = { truffle=true, blend=true },
			ingredients = { brandy=true, pecan=true, blend=true, hazelnut=true, pumpkin=true }
		},
		dislikes = { ingredients = { rose=true, lavender=true, hibiscus=true } } 
	},

	main_elen = {
		gender = "female", nationality = "usa",
		likes = { categories = { infusion=true } }
	},

	main_evan = {
		gender = "female", nationality = "usa", religion = "christian",
		likes = {
			categories = { truffle=true },
			products = { t12=true }, 
			ingredients = { lemon=true, tea=true, rose=true, lavender=true, vanilla=true }
		},
		dislikes = { ingredients = { peanut=true, wasabi=true } } 
	},

	main_deit = {
		gender = "male", nationality = "usa", 
		likes = {
			categories = { infusion=true },
			ingredients = { lime=true, ginger=true, macadamia=true, wasabi=true, cashew=true, matcha=true }
		}
	},

	main_sara = {
		gender = "female", nationality = "usa", 
		likes = { ingredients = { bog_cacao=true, bog_coffee=true } } 
	},

	main_tedd = {
		gender = "male", nationality = "usa", 
		likes = { categories = { user=true } } 
	},

	main_chas = {
		gender = "male", nationality = "usa",
		likes = {
			categories = { bar=true, user=true }, 
			ingredients = { raspberry=true, almond=true, caramel=true } 
		},
		dislikes = { categories = { beverage=true } } 
	},

	main_whit = {
		gender = "female", nationality = "usa",
		likes = {
			categories = { exotic=true },
			ingredients = { lime=true, mango=true, lychee=true, passionfruit=true, ginger=true, salt=true }
		},
		dislikes = { products = { b01=true, b02=true } } 
	},

	main_feli = {
		gender = "male", nationality = "usa", 
		likes = {
			categories = { beverage=true, blend=true },
			ingredients = { kon_coffee=true, hav_coffee=true, tan_coffee=true, espresso=true, caramel=true }
		},
		dislikes = { ingredients = { wasabi=true, pepper=true } } 
	},

	-- ------------------------------------------------------------------------
	-- ANTAGONISTS
	-- ------------------------------------------------------------------------

	evil_tyso = { 
		gender = "male", nationality = "usa",
		likes = { categories = { exotic=true }, ingredients = { saffron=true } },
		dislikes = { categories = { bar=true }, ingredients = { peanut=true, apple=true } }
	},

	evil_kath = { 
		gender = "female", nationality = "greece", dietaryreqs = { alcohol_free=true }, 
		likes = { categories = { beverage=true }, ingredients = { tea=true, mint=true, lemon=true } }
	},

	evil_bian = {
		gender = "female", nationality = "italy",
		likes = { categories = { truffle=true }, ingredients = { saffron=true, rose=true, honey=true, hibiscus=true, lavender=true, amaretto=true, grand_marnier=true } },
		dislikes = { ingredients = { peanut=true, coconut=true } }
	},

	evil_wolf = { 
		gender = "male", nationality = "germany",
		likes = { categories = { infusion=true }, ingredients = { cherry=true, whipped_cream=true, grand_marnier=true, brandy=true, cacao=true } },
		dislikes = { categories = { blend=true }, ingredients = { caramel=true, toffee=true, mango=true, rose=true } }
	},

	-- ------------------------------------------------------------------------
	-- TRAVELERS
	-- ------------------------------------------------------------------------

	trav_01 = { 
		gender = "female", nationality = "india", religion = "hindu", dietaryreqs = { no_beef=true },
		likes = { products = { e08=true }, ingredients = { tea=true, turmeric=true, cinnamon=true, bal_coffee=true, bal_cacao=true } },
		dislikes = { products = { b01=true }, ingredients = { lemon=true, lime=true } }
	},

	trav_02 = { 
		gender = "female", nationality = "brazil",
		likes = { categories = { infusion=true }, ingredients = { lime=true, passionfruit=true, pepper=true, bog_coffee=true, rum=true } },
		dislikes = { ingredients = { mint=true, pumpkin=true } }
	},

	trav_03 = { 
		gender = "male", nationality = "pakistan", religion = "muslim", dietaryreqs = { halal=true, alcohol_free=true },
		likes = { ingredients = { tan_coffee=true, espresso=true, blueberry=true, date=true, pistachio=true } }
	},

	trav_04 = { 
		gender = "female", nationality = "usa", 
		likes = { ingredients = { apple=true, blueberry=true, maple=true, peanut=true, strawberry=true } },
		dislikes = { categories = { exotic=true }, ingredients = { wasabi=true, turmeric=true, sumac=true } }
	},

	trav_05 = { 
		gender = "female", nationality = "burkina_faso",
		likes = { ingredients = { dou_cacao=true, banana=true, coconut=true, mango=true, nutmeg=true } },
		dislikes = { ingredients = { caramel=true, maple=true } }
	},

	trav_06 = { 
		gender = "male", nationality = "japan",
		likes = { ingredients = { matcha=true, wasabi=true, sesame=true, tea=true, ginger=true, caramel=true } }
	},

	trav_07 = { 
		gender = "male", nationality = "usa", 
		likes = { categories = { blend=true }, ingredients = { whiskey=true, grand_marnier=true, espresso=true, macadamia=true, fig=true } },
		dislikes = { products = { b01=true }, ingredients = { honey=true } }
	},

	trav_08 = { 
		gender = "female", nationality = "japan",
		likes = { categories = { exotic=true }, ingredients = { rose=true, lavender=true, cherry=true, tea=true, matcha=true, lychee=true } },
		dislikes = { categories = { beverage=true, blend=true }, ingredients = { pepper=true, espresso=true } }
	},

	trav_09 = { 
		gender = "male", nationality = "france",
		likes = { products = { b12=true }, ingredients = { brandy=true, tan_coffee=true, almond=true, walnut=true, pumpkin=true } },
		dislikes = { ingredients = { strawberry=true, raspberry=true, mango=true, passionfruit=true } }
	},

	trav_10 = { 
		gender = "female", nationality = "iran", religion = "muslim", dietaryreqs = { halal=true, alcohol_free=true },
		likes = { ingredients = { saffron=true, pistachio=true, date=true, cardamom=true, fig=true } }
	},

	trav_11 = { 
		gender = "female", nationality = "italy",
		likes = { categories = { truffle=true }, products = { m07=true }, ingredients = { amaretto=true, espresso=true, hazelnut=true, orange=true, lim_cacao=true } },
		dislikes = { ingredients = { peanut=true, coconut=true } }
	},

	-- ------------------------------------------------------------------------
	-- SHOPKEEPERS & LOCALS
	-- ------------------------------------------------------------------------
	
	-- BAGHDAD (Iraq)
	bag_bldg2keep = { gender = "female", nationality = "iraq", religion = "muslim", dietaryreqs = { halal=true, alcohol_free=true },
		likes = { ingredients = { cardamom=true, sumac=true, fig=true, date=true, tan_coffee=true } }, dislikes = { products = { b02=true, t01=true } } },
	bag_marketkeep = { gender = "female", nationality = "iraq", religion = "muslim", dietaryreqs = { halal=true, alcohol_free=true } },
	bag_shopkeep   = { gender = "male", nationality = "iraq", religion = "muslim", dietaryreqs = { halal=true, alcohol_free=true } },
	bag_towerkeep  = { gender = "male", nationality = "iraq", religion = "muslim", dietaryreqs = { halal=true, alcohol_free=true } },
	
	-- BALI (Indonesia)
	bal_marketkeep = { gender = "male", nationality = "indonesia", religion = "hindu", likes = { categories = { bar=true }, ingredients = { lime=true, nutmeg=true, clove=true, coconut=true, salt=true, milk=true } } },
	bal_shopkeep   = { gender = "female", nationality = "indonesia", religion = "hindu", dietaryreqs = { alcohol_free=true }, likes = { categories = { infusion=true }, ingredients = { honey=true, cashew=true, lychee=true, tea=true, hibiscus=true } } },
	bal_xxxkeep    = { gender = "male", nationality = "indonesia", religion = "hindu", likes = { categories = { exotic=true }, ingredients = { bal_cacao=true, bal_coffee=true, lime=true, lemon=true, ginger=true, salt=true } }, dislikes = { products = { t01=true }, ingredients = { caramel=true, whipped_cream=true, toffee=true } } },
	
	-- XUNANTUNICH (Belize)
	bel_hutkeep = { gender = "female", nationality = "belize", likes = { categories = { bar=true, infusion=true }, ingredients = { bel_cacao=true, honey=true, pepper=true, hibiscus=true, pineapple=true } }, dislikes = { categories = { truffle=true }, ingredients = { milk=true, cream=true } } },
	
	-- BOGOTA (Colombia)
	bog_churchkeep     = { gender = "female", nationality = "colombia", religion = "christian", dietaryreqs = { alcohol_free=true }, likes = { categories = { truffle=true, infusion=true }, ingredients = { blackberry=true, macadamia=true, orange=true, milk=true, honey=true, bog_cacao=true } }, dislikes = { ingredients = { anise=true, star_anise=true, mint=true } } },
	bog_customskeep    = { gender = "male", nationality = "colombia", likes = { categories = { infusion=true }, ingredients = { passionfruit=true, lime=true, raspberry=true, orange=true } } },
	bog_marketkeep     = { gender = "male", nationality = "colombia", likes = { ingredients = { almond=true, peanut=true, cashew=true, salt=true } }, dislikes = { ingredients = { honey=true, caramel=true, mango=true } } },
	bog_mountainkeep   = { gender = "male", nationality = "colombia", likes = { products = { t09=true }, ingredients = { sesame=true, pepper=true, cinnamon=true, vanilla=true, ginger=true } } },
	bog_plantationkeep = { gender = "male", nationality = "colombia", likes = { ingredients = { bog_cacao=true, bog_coffee=true, pecan=true } } },
	bog_shopkeep       = { gender = "female", nationality = "colombia", likes = { categories = { user=true, exotic=true }, ingredients = { matcha=true, lychee=true, pistachio=true } } },
	
	-- CAPE TOWN (South Africa)
	cap_marketkeep   = { gender = "male", nationality = "south_africa", religion = "jewish", dietaryreqs = { kosher=true }, likes = { ingredients = { whipped_cream=true, caramel=true, mint=true, honey=true } } },
	cap_mountainkeep = { gender = "female", nationality = "south_africa" },
	cap_shopkeep     = { gender = "female", nationality = "south_africa", religion = "christian", likes = { categories = { infusion=true, exotic=true }, ingredients = { tea=true, caramel=true, milk=true, dou_cacao=true } } },
	
	-- DOUALA (Cameroon)
	dou_bldg1keep      = { gender = "male", nationality = "cameroon", dietaryreqs = { lactose_free=true }, likes = { categories = { bar=true, infusion=true }, products = { b04=true, b12=true }, ingredients = { dou_cacao=true, allspice=true, ginger=true, peanut=true, pepper=true } }, dislikes = { categories = { truffle=true }, ingredients = { milk=true, cream=true, butter=true, whipped_cream=true } } },
	dou_marketkeep     = { gender = "female", nationality = "cameroon", dietaryreqs = { alcohol_free=true }, likes = { categories = { bar=true }, ingredients = { vanilla=true, mango=true, allspice=true, cacao=true, banana=true } }, dislikes = { categories = { user=true } } },
	dou_plantationkeep = { gender = "male", nationality = "cameroon", likes = { categories = { bar=true }, products = { b12=true }, ingredients = { dou_cacao=true, allspice=true, ginger=true, vanilla=true, banana=true } }, dislikes = { categories = { exotic=true, blend=true }, ingredients = { salt=true } } },
	dou_shopkeep       = { gender = "male", nationality = "cameroon", likes = { categories = { infusion=true, exotic=true, user=true }, products = { e07=true }, ingredients = { dou_cacao=true, grand_marnier=true, mint=true, coffee=true, cinnamon=true, saffron=true } }, dislikes = { products = { b01=true, b02=true }, ingredients = { peanut=true, apple=true } } },
	
	-- GOBI (Mongolia)
	gob_xxxkeep = { gender = "male", nationality = "mongolia", likes = { categories = { bar=true }, ingredients = { date=true, milk=true, tea=true, salt=true } } },
	
	-- HAVANA (Cuba)
	hav_casinokeep     = { gender = "male", nationality = "cuba", likes = { categories = { exotic=true }, ingredients = { rum=true, whiskey=true, mint=true, kahlua=true, grand_marnier=true } }, dislikes = { categories = { bar=true }, ingredients = { peanut=true, apple=true } } },
	hav_hotelkeep      = { gender = "female", nationality = "cuba", likes = { categories = { beverage=true, infusion=true }, products = { c11=true, c08=true }, ingredients = { hav_coffee=true, sugar=true, cinnamon=true, cream=true } }, dislikes = { ingredients = { wasabi=true, pepper=true } } },
	hav_marketkeep     = { gender = "male", nationality = "cuba", likes = { categories = { bar=true }, ingredients = { hav_coffee=true, cacao=true, almond=true } }, dislikes = { categories = { exotic=true }, ingredients = { lavender=true, rose=true, hibiscus=true, saffron=true } } },
	hav_plantationkeep = { gender = "female", nationality = "nigeria", likes = { categories = { blend=true }, products = { c03=true }, ingredients = { hav_coffee=true, tan_coffee=true, kon_coffee=true, dou_cacao=true } }, dislikes = { ingredients = { toffee=true, caramel=true } } },
	hav_shopkeep       = { gender = "female", nationality = "cuba", likes = { categories = { truffle=true, infusion=true }, products = { t07=true, t08=true, t10=true }, ingredients = { vanilla=true, raspberry=true, cherry=true, rum=true } }, dislikes = { ingredients = { turmeric=true, sumac=true, wasabi=true } } },
	
	-- KONA (Hawaii, USA)
	kon_bldg2keep      = { gender = "female", nationality = "usa", likes = { ingredients = { pineapple=true, passionfruit=true, coconut=true, mango=true, kon_coffee=true } }, dislikes = { ingredients = { nutmeg=true, clove=true, pumpkin=true } } },
	kon_marketkeep     = { gender = "male", nationality = "usa" },
	kon_plantationkeep = { gender = "male", nationality = "usa" },
	kon_shopkeep       = { gender = "female", nationality = "usa" },
	
	-- LAS VEGAS (USA)
	las_casinokeep = { gender = "female", nationality = "yugoslavia", likes = { categories = { exotic=true, truffle=true }, ingredients = { cherry=true, whiskey=true, amaretto=true, toffee=true } }, dislikes = { categories = { bar=true }, products = { b01=true } } },
	las_marketkeep = { gender = "female", nationality = "costa_rica", likes = { categories = { beverage=true }, products = { e07=true }, ingredients = { strawberry=true, sugar=true, vanilla=true, espresso=true } }, dislikes = { ingredients = { pepper=true, wasabi=true, ginger=true } } },
	
	-- LIMA (Peru)
	lim_churchkeep   = { gender = "female", nationality = "peru", religion = "christian" },
	lim_marketkeep   = { gender = "female", nationality = "peru" },
	lim_mountainkeep = { gender = "male", nationality = "peru" },
	lim_plazakeep    = { gender = "female", nationality = "peru" },
	lim_shopkeep     = { gender = "male", nationality = "italy" },
	
	-- MAHAJANGA (Madagascar)
	mah_shopkeep = { gender = "male", nationality = "madagascar" },
	
	-- REYKJAVIK (Iceland)
	rey_marketkeep = { gender = "female", nationality = "iceland" },
	rey_shopkeep   = { gender = "male", nationality = "iceland" },
	rey_xxxxkeep   = { gender = "male", nationality = "iceland", likes = { categories = { truffle=true }, ingredients = { salt=true, blueberry=true, blackberry=true, cream=true } }, dislikes = { ingredients = { lychee=true, mango=true, passionfruit=true, pineapple=true } } },
	
	-- SAN FRANCISCO (USA)
	san_barkeep    = { gender = "female", nationality = "usa" },
	san_marketkeep = { gender = "female", nationality = "usa" },
	san_shopkeep   = { gender = "female", nationality = "usa" },
	
	-- TANGIERS (Morocco)
	tan_hotelkeep  = { gender = "male", nationality = "morocco", religion = "muslim", dietaryreqs = { halal=true, alcohol_free=true } },
	tan_marketkeep = { gender = "female", nationality = "netherlands", religion = "muslim", dietaryreqs = { halal=true, alcohol_free=true } },
	tan_portkeep   = { gender = "male", nationality = "morocco" },
	
	-- TOKYO (Japan)
	tok_marketkeep   = { gender = "female", nationality = "japan", dietaryreqs = { alcohol_free=true }, likes = { categories = { bar=true, infusion=true }, ingredients = { matcha=true, tea=true, wasabi=true, ginger=true, chestnut=true, salt=true } }, dislikes = { categories = { blend=true } } },
	tok_mountainkeep = { gender = "male", nationality = "usa", religion = "christian", likes = { categories = { bar=true, blend=true }, ingredients = { peanut=true, espresso=true, whiskey=true, pecan=true, maple=true, apple=true } }, dislikes = { ingredients = { wasabi=true, matcha=true, sumac=true } } },
	tok_palacekeep   = { gender = "male", nationality = "japan", likes = { categories = { infusion=true, user=true }, ingredients = { bog_coffee=true, lime=true, saffron=true, cinnamon=true, vanilla=true, lychee=true } }, dislikes = { ingredients = { milk=true, cream=true, whipped_cream=true, butter=true } } },
	tok_shopkeep     = { gender = "male", nationality = "japan", likes = { categories = { beverage=true, blend=true }, ingredients = { almond=true, hazelnut=true, chestnut=true, espresso=true, toffee=true } }, dislikes = { ingredients = { pepper=true, wasabi=true, ginger=true } } },
	tok_stationkeep  = { gender = "male", nationality = "japan", likes = { categories = { bar=true }, ingredients = { matcha=true, ginger=true, allspice=true, milk=true, tea=true, salt=true } }, dislikes = { ingredients = { amaretto=true, kahlua=true, brandy=true, grand_marnier=true, sugar=true } } },
	tok_towerkeep    = { gender = "female", nationality = "japan", likes = { categories = { exotic=true, blend=true, user=true }, ingredients = { lychee=true, pomegranate=true, passionfruit=true, raspberry=true, coffee=true, tea=true } }, dislikes = { products = { b01=true, b02=true }, ingredients = { pumpkin=true } } },
	
	-- TORONTO (Canada)
	tor_bldg1keep   = { gender = "female", nationality = "uk", likes = { categories = { coffee=true, blend=true }, products = { t01=true }, ingredients = { tea=true, matcha=true, hibiscus=true, lavender=true, rose=true, almond=true, pistachio=true } }, dislikes = { ingredients = { espresso=true, bal_coffee=true, bog_coffee=true, hav_coffee=true, kon_coffee=true, tan_coffee=true } } },
	tor_bldg2keep   = { gender = "female", nationality = "canada", likes = { products = { b02=true }, ingredients = { maple=true, apple=true, butter=true, pecan=true, walnut=true } }, dislikes = { ingredients = { pepper=true, wasabi=true } } },
	tor_factorykeep = { gender = "female", nationality = "canada" },
	tor_marketkeep  = { gender = "female", nationality = "canada", likes = { categories = { bar=true }, products = { m08=true, b02=true }, ingredients = { vanilla=true, toffee=true, blueberry=true, raisin=true, milk=true } }, dislikes = { ingredients = { raspberry=true, blackberry=true, mango=true }, products = { e07=true } } },
	tor_shopkeep    = { gender = "female", nationality = "canada" },
	
	-- ULURU (Australia)
	ulu_hutkeep  = { gender = "female", nationality = "australia", likes = { categories = { bar=true }, ingredients = { lime=true } } },
	ulu_rockkeep = { gender = "male", nationality = "australia" },
	
	-- WELLINGTON (New Zealand)
	wel_bldg1keep  = { gender = "female", nationality = "new_zealand", likes = { categories = { beverage=true }, ingredients = { peanut=true, raspberry=true, toffee=true, caramel=true } }, dislikes = {} },
	wel_marketkeep = { gender = "female", nationality = "new_zealand" },
	wel_shopkeep   = { gender = "female", nationality = "germany" },
	
	-- ZURICH (Switzerland)
	zur_bankkeep     = { gender = "male", nationality = "switzerland" },
	zur_factorykeep  = { gender = "male", nationality = "albania" },
	zur_marketkeep   = { gender = "female", nationality = "switzerland" },
	zur_mountainkeep = { gender = "female", nationality = "switzerland" },
	zur_riverkeep    = { gender = "male", nationality = "switzerland", likes = { categories = { bar=true, beverage=true }, ingredients = { cherry=true, lemon=true, grand_marnier=true } } },
	zur_schoolkeep   = { gender = "male", nationality = "switzerland" },
	zur_shopkeep     = { gender = "female", nationality = "switzerland", likes = { categories = { bar=true, user=true }, ingredients = { caramel=true, almond=true, chestnut=true, hazelnut=true } } },
	zur_stationkeep  = { gender = "male", nationality = "switzerland" },
	zur_towerkeep    = { gender = "female", nationality = "switzerland", likes = { ingredients = { almond=true, milk=true, cream=true, lavender=true } } },
	
	-- ------------------------------------------------------------------------
	-- ANNOUNCER
	-- ------------------------------------------------------------------------
	announcer = { 
		gender = "male", nationality = "canada", 
		likes = { categories = { user=true } } 
	},
}

------------------------------------------------------------------------------
-- Application Logic
------------------------------------------------------------------------------

-- Hooks into the global _AllCharacters array and overrides the base configurations 
-- with the detailed profiles listed above.
function ApplyCharacterData()
	DebugOut("LOAD", "Applying centralized character data dictionaries...")
	local count = 0
	
	for charName, data in pairs(CharacterData) do
		local char = _AllCharacters[charName]
		if char then
			-- Apply economic preferences
			char.likes = data.likes or {}
			char.dislikes = data.dislikes or {}
			
			-- Apply grammar/demographic metadata
			char.firstname = data.firstname
			char.lastname = data.lastname
			char.honorific = data.honorific
			char.gender = data.gender
			char.nationality = data.nationality
			char.religion = data.religion
			char.dietaryreqs = data.dietaryreqs or {}
			
			count = count + 1
		else
			DebugOut("ERROR", string.format("CharacterData contains entry for unknown/uninstantiated character: %s", charName))
		end
	end
	
	DebugOut("LOAD", string.format("Successfully applied data to %d characters.", count))
end