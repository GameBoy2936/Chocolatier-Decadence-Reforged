--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged (Centralized Character Data)
	Copyright (c) 2025-2026 Michael Lane.
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
			products = { m04=true },
			ingredients = { anise=true, cayenne=true, clove=true, currant=true, lime=true, pumpkin=true, saffron=true }
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
			products = { c04=true, m11=true },
			ingredients = { cardamom=true, cinnamon=true, mint=true, tan_coffee=true }
		}
	},

	main_loud = {
		gender = "male", nationality = "usa",
		likes = {
			categories = { blend=true },
			products = { m07=true },
			ingredients = { espresso=true, kahlua=true, rum=true }
		},
		dislikes = { categories = { truffle=true } }
	},

	main_jose = {
		gender = "male", nationality = "usa", religion = "christian",
		likes = {
			categories = { blend=true, truffle=true },
			products = { t02=true, t10=true },
			ingredients = { brandy=true, hazelnut=true, pecan=true, pumpkin=true }
		},
		dislikes = { ingredients = { hibiscus=true, lavender=true, rose=true } }
	},

	main_elen = {
		gender = "female", nationality = "usa",
		likes = {
			categories = { infusion=true },
			products = { i08=true },
			ingredients = { chamomile=true, vanilla=true }
		}
	},

	main_evan = {
		gender = "female", nationality = "usa", religion = "christian",
		likes = {
			categories = { truffle=true },
			products = { t12=true },
			ingredients = { earl_grey=true, lavender=true, lemon=true, rose=true, tea=true, vanilla=true }
		},
		dislikes = { ingredients = { peanut=true, wasabi=true } }
	},

	main_deit = {
		gender = "male", nationality = "usa",
		likes = {
			categories = { infusion=true },
			products = { t06=true },
			ingredients = { cashew=true, ginger=true, lime=true, macadamia=true, matcha=true, wasabi=true }
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
			products = { b03=true, b09=true },
			ingredients = { almond=true, caramel=true, raspberry=true }
		},
		dislikes = { categories = { beverage=true } }
	},

	main_whit = {
		gender = "female", nationality = "usa",
		likes = {
			categories = { exotic=true },
			products = { e11=true },
			ingredients = { dragonfruit=true, ginger=true, lime=true, lychee=true, mango=true, passionfruit=true, salt=true }
		},
		dislikes = { products = { b01=true, b02=true } }
	},

	main_feli = {
		gender = "male", nationality = "usa",
		likes = {
			categories = { beverage=true, blend=true },
			products = { m09=true },
			ingredients = { caramel=true, espresso=true, hav_coffee=true, kon_coffee=true, tan_coffee=true }
		},
		dislikes = { ingredients = { cayenne=true, wasabi=true } }
	},

	-- ------------------------------------------------------------------------
	-- ANTAGONISTS
	-- ------------------------------------------------------------------------

	evil_tyso = {
		gender = "male", nationality = "usa",
		likes = {
			categories = { exotic=true },
			ingredients = { saffron=true }
		},
		dislikes = {
			categories = { bar=true },
			ingredients = { apple=true, peanut=true }
		}
	},

	evil_kath = {
		gender = "female", nationality = "greece", dietaryreqs = { alcohol_free=true },
		likes = {
			categories = { beverage=true },
			ingredients = { almond=true, chamomile=true, lemon=true, mint=true, tea=true }
		}
	},

	evil_bian = {
		gender = "female", nationality = "italy",
		likes = {
			categories = { truffle=true },
			products = { t02=true },
			ingredients = { amaretto=true, grand_marnier=true, hibiscus=true, honey=true, lavender=true, rose=true, saffron=true }
		},
		dislikes = { ingredients = { coconut=true, peanut=true } }
	},

	evil_wolf = {
		gender = "male", nationality = "germany",
		likes = {
			categories = { infusion=true },
			products = { i02=true },
			ingredients = { brandy=true, cacao=true, cherry=true, grand_marnier=true, plum=true, whipped_cream=true }
		},
		dislikes = {
			categories = { blend=true },
			ingredients = { caramel=true, mango=true, rose=true, toffee=true }
		}
	},

	-- ------------------------------------------------------------------------
	-- TRAVELERS
	-- ------------------------------------------------------------------------

	trav_01 = {
		gender = "female", nationality = "india", religion = "hindu", dietaryreqs = { no_beef=true },
		likes = {
			products = { e08=true },
			ingredients = { bal_cacao=true, bal_coffee=true, cinnamon=true, jasmine=true, tea=true, turmeric=true }
		},
		dislikes = {
			products = { b01=true },
			ingredients = { lemon=true, lime=true }
		}
	},

	trav_02 = {
		gender = "female", nationality = "brazil",
		likes = {
			categories = { infusion=true },
			products = { i07=true },
			ingredients = { bog_coffee=true, cayenne=true, guava=true, lime=true, passionfruit=true, rum=true }
		},
		dislikes = { ingredients = { mint=true, pumpkin=true } }
	},

	trav_03 = {
		gender = "male", nationality = "pakistan", religion = "muslim", dietaryreqs = { halal=true, alcohol_free=true },
		likes = { ingredients = { apricot=true, blueberry=true, date=true, espresso=true, pistachio=true, tan_coffee=true } }
	},

	trav_04 = {
		gender = "female", nationality = "usa",
		likes = {
			products = { b04=true },
			ingredients = { apple=true, blueberry=true, maple=true, peanut=true, strawberry=true }
		},
		dislikes = {
			categories = { exotic=true },
			ingredients = { sumac=true, turmeric=true, wasabi=true }
		}
	},

	trav_05 = {
		gender = "female", nationality = "burkina_faso",
		likes = { ingredients = { banana=true, coconut=true, dou_cacao=true, mango=true, nutmeg=true, tamarind=true } },
		dislikes = { ingredients = { caramel=true, maple=true } }
	},

	trav_06 = {
		gender = "male", nationality = "japan",
		likes = {
			products = { t09=true },
			ingredients = { caramel=true, ginger=true, matcha=true, sesame=true, tea=true, wasabi=true, yuzu=true }
		}
	},

	trav_07 = {
		gender = "male", nationality = "usa",
		likes = {
			categories = { blend=true },
			ingredients = { espresso=true, fig=true, grand_marnier=true, macadamia=true, whiskey=true }
		},
		dislikes = {
			products = { b01=true },
			ingredients = { honey=true }
		}
	},

	trav_08 = {
		gender = "female", nationality = "japan",
		likes = {
			categories = { exotic=true },
			ingredients = { cherry=true, jasmine=true, lavender=true, lychee=true, matcha=true, rose=true, tea=true }
		},
		dislikes = {
			categories = { beverage=true, blend=true },
			ingredients = { cayenne=true, espresso=true }
		}
	},

	trav_09 = {
		gender = "male", nationality = "france",
		likes = {
			products = { b12=true, t02=true },
			ingredients = { almond=true, brandy=true, pumpkin=true, tan_coffee=true, walnut=true }
		},
		dislikes = { ingredients = { mango=true, passionfruit=true, raspberry=true, strawberry=true } }
	},

	trav_10 = {
		gender = "female", nationality = "iran", religion = "muslim", dietaryreqs = { halal=true, alcohol_free=true },
		likes = {
			products = { e02=true },
			ingredients = { apricot=true, cardamom=true, date=true, fig=true, pistachio=true, saffron=true }
		}
	},

	trav_11 = {
		gender = "female", nationality = "italy",
		likes = {
			categories = { truffle=true },
			products = { m07=true, t02=true },
			ingredients = { amaretto=true, espresso=true, hazelnut=true, lim_cacao=true, orange=true, rosemary=true }
		},
		dislikes = { ingredients = { coconut=true, peanut=true } }
	},

	trav_13 = { -- Bergit Sjöström
		gender = "female", nationality = "sweden",
		likes = {
			categories = { beverage=true, blend=true },
			ingredients = { blueberry=true, earl_grey=true, espresso=true, oat=true, raspberry=true, vanilla=true }
		},
		dislikes = { ingredients = { clove=true } }
	},

	trav_16 = {
		gender = "female", nationality = "russia",
		likes = {
			categories = { blend=true, truffle=true },
			ingredients = { brandy=true, cherry=true, espresso=true, hazelnut=true, honey=true, plum=true, tea=true }
		},
		dislikes = { ingredients = { cayenne=true, passionfruit=true, wasabi=true } }
	},

	trav_21 = {
		gender = "male", nationality = "greece",
		likes = {
			categories = { bar=true },
			products = { b06=true },
			ingredients = { almond=true, cacao=true, hazelnut=true, lemon=true, orange=true, walnut=true }
		}
	},

	-- ------------------------------------------------------------------------
	-- SHOPKEEPERS & LOCALS
	-- ------------------------------------------------------------------------

	-- BAGHDAD (Iraq)
	bag_bldg2keep = { gender = "female", nationality = "iraq", religion = "muslim", dietaryreqs = { halal=true, alcohol_free=true },
		likes = { ingredients = { cardamom=true, date=true, fig=true, sumac=true, tan_coffee=true } },
		dislikes = { products = { b02=true, t01=true } }
	},
	bag_marketkeep = { gender = "female", nationality = "iraq", religion = "muslim", dietaryreqs = { halal=true, alcohol_free=true },
		likes = {
			categories = { exotic=true },
			products = { e02=true },
			ingredients = { apricot=true, date=true, sesame=true, sumac=true }
		},
		dislikes = { ingredients = { marshmallow=true } }
	},
	bag_shopkeep   = { gender = "male", nationality = "iraq", religion = "muslim", dietaryreqs = { halal=true, alcohol_free=true },
		likes = {
			products = { t08=true },
			ingredients = { apricot=true, honey=true, pistachio=true }
		},
		dislikes = { ingredients = { cayenne=true, wasabi=true } }
	},
	bag_towerkeep  = { gender = "male", nationality = "iraq", religion = "muslim", dietaryreqs = { halal=true, alcohol_free=true },
		likes = {
			categories = { infusion=true },
			ingredients = { almond=true, date=true, saffron=true }
		}
	},

	-- BALI (Indonesia)
	bal_marketkeep = { gender = "male", nationality = "indonesia", religion = "hindu",
		likes = {
			categories = { bar=true },
			ingredients = { clove=true, coconut=true, lemongrass=true, lime=true, milk=true, nutmeg=true, salt=true }
		}
	},
	bal_shopkeep   = { gender = "female", nationality = "indonesia", religion = "hindu", dietaryreqs = { alcohol_free=true },
		likes = {
			categories = { infusion=true },
			ingredients = { cashew=true, hibiscus=true, honey=true, jasmine=true, lychee=true, tea=true }
		}
	},
	bal_xxxkeep    = { gender = "male", nationality = "indonesia", religion = "hindu",
		likes = {
			categories = { exotic=true },
			ingredients = { bal_cacao=true, bal_coffee=true, ginger=true, lemon=true, lime=true, salt=true }
		},
		dislikes = {
			products = { t01=true },
			ingredients = { caramel=true, toffee=true, whipped_cream=true }
		}
	},

	-- XUNANTUNICH (Belize)
	bel_hutkeep = { gender = "female", nationality = "belize",
		likes = {
			categories = { bar=true, infusion=true },
			ingredients = { bel_cacao=true, cayenne=true, guava=true, hibiscus=true, honey=true, pineapple=true, tamarind=true }
		},
		dislikes = {
			categories = { truffle=true },
			ingredients = { cream=true, milk=true }
		}
	},

	-- BOGOTA (Colombia)
	bog_churchkeep     = { gender = "female", nationality = "colombia", religion = "christian", dietaryreqs = { alcohol_free=true },
		likes = {
			categories = { infusion=true, truffle=true },
			ingredients = { blackberry=true, bog_cacao=true, honey=true, macadamia=true, milk=true, orange=true }
		},
		dislikes = { ingredients = { anise=true, mint=true, star_anise=true } }
	},
	bog_customskeep    = { gender = "male", nationality = "colombia",
		likes = {
			categories = { infusion=true },
			products = { e03=true },
			ingredients = { guava=true, lime=true, orange=true, passionfruit=true, raspberry=true }
		}
	},
	bog_marketkeep     = { gender = "male", nationality = "colombia",
		likes = { ingredients = { almond=true, cashew=true, peanut=true, salt=true } },
		dislikes = { ingredients = { caramel=true, honey=true, mango=true } }
	},
	bog_mountainkeep   = { gender = "male", nationality = "colombia",
		likes = {
			products = { t09=true },
			ingredients = { cayenne=true, cinnamon=true, ginger=true, sesame=true, vanilla=true }
		}
	},
	bog_plantationkeep = { gender = "male", nationality = "colombia",
		likes = { ingredients = { bog_cacao=true, bog_coffee=true, pecan=true } }
	},
	bog_shopkeep       = { gender = "female", nationality = "colombia",
		likes = {
			categories = { exotic=true, user=true },
			ingredients = { lychee=true, matcha=true, pistachio=true }
		}
	},

	-- CAPE TOWN (South Africa)
	cap_marketkeep   = { gender = "male", nationality = "south_africa", religion = "jewish", dietaryreqs = { kosher=true },
		likes = { ingredients = { caramel=true, honey=true, mint=true, rooibos=true, whipped_cream=true } }
	},
	cap_mountainkeep = { gender = "female", nationality = "south_africa",
		likes = {
			products = { i05=true },
			ingredients = { blackberry=true, plum=true, rooibos=true }
		},
		dislikes = { ingredients = { marshmallow=true } }
	},
	cap_shopkeep     = { gender = "female", nationality = "south_africa", religion = "christian",
		likes = {
			categories = { exotic=true, infusion=true },
			ingredients = { caramel=true, dou_cacao=true, ice_cream=true, milk=true, rooibos=true, tea=true }
		}
	},

	-- DOUALA (Cameroon)
	dou_bldg1keep      = { gender = "male", nationality = "cameroon", dietaryreqs = { lactose_free=true },
		likes = {
			categories = { bar=true, infusion=true },
			products = { b04=true, b12=true },
			ingredients = { allspice=true, cayenne=true, dou_cacao=true, ginger=true, peanut=true, tamarind=true }
		},
		dislikes = {
			categories = { truffle=true },
			ingredients = { butter=true, cream=true, milk=true, whipped_cream=true }
		}
	},
	dou_marketkeep     = { gender = "female", nationality = "cameroon", dietaryreqs = { alcohol_free=true },
		likes = {
			categories = { bar=true },
			ingredients = { allspice=true, banana=true, cacao=true, mango=true, vanilla=true }
		},
		dislikes = { categories = { user=true } }
	},
	dou_plantationkeep = { gender = "male", nationality = "cameroon",
		likes = {
			categories = { bar=true },
			products = { b12=true },
			ingredients = { allspice=true, banana=true, dou_cacao=true, ginger=true, vanilla=true }
		},
		dislikes = {
			categories = { blend=true, exotic=true },
			ingredients = { salt=true }
		}
	},
	dou_shopkeep       = { gender = "male", nationality = "cameroon",
		likes = {
			categories = { exotic=true, infusion=true, user=true },
			products = { e07=true },
			ingredients = { cinnamon=true, dou_cacao=true, grand_marnier=true, mint=true, saffron=true }
		},
		dislikes = {
			products = { b01=true, b02=true },
			ingredients = { apple=true, peanut=true }
		}
	},

	-- GOBI (Mongolia)
	gob_xxxkeep = { gender = "male", nationality = "mongolia",
		likes = {
			categories = { bar=true },
			ingredients = { date=true, milk=true, peach=true, rhubarb=true, salt=true, tea=true }
		}
	},

	-- HAVANA (Cuba)
	hav_casinokeep     = { gender = "male", nationality = "cuba",
		likes = {
			categories = { exotic=true },
			products = { m07=true },
			ingredients = { grand_marnier=true, kahlua=true, mint=true, rum=true, whiskey=true }
		},
		dislikes = {
			categories = { bar=true },
			ingredients = { apple=true, peanut=true }
		}
	},
	hav_hotelkeep      = { gender = "female", nationality = "cuba",
		likes = {
			categories = { beverage=true, infusion=true },
			products = { c08=true, c11=true },
			ingredients = { cinnamon=true, cream=true, hav_coffee=true, sugar=true }
		},
		dislikes = { ingredients = { cayenne=true, wasabi=true } }
	},
	hav_marketkeep     = { gender = "male", nationality = "cuba",
		likes = {
			categories = { bar=true },
			ingredients = { almond=true, cacao=true, hav_coffee=true }
		},
		dislikes = {
			categories = { exotic=true },
			ingredients = { hibiscus=true, lavender=true, rose=true, saffron=true }
		}
	},
	hav_plantationkeep = { gender = "female", nationality = "nigeria",
		likes = {
			categories = { blend=true },
			products = { c03=true },
			ingredients = { dou_cacao=true, hav_coffee=true, kon_coffee=true, tan_coffee=true }
		},
		dislikes = { ingredients = { caramel=true, toffee=true } }
	},
	hav_shopkeep       = { gender = "female", nationality = "cuba",
		likes = {
			categories = { infusion=true, truffle=true },
			products = { t07=true, t08=true, t10=true },
			ingredients = { cherry=true, raspberry=true, rum=true, vanilla=true }
		},
		dislikes = { ingredients = { sumac=true, turmeric=true, wasabi=true } }
	},

	-- KONA (Hawaii, USA)
	kon_bldg2keep      = { gender = "female", nationality = "usa",
		likes = { ingredients = { coconut=true, kon_coffee=true, mango=true, passionfruit=true, pineapple=true } },
		dislikes = { ingredients = { clove=true, nutmeg=true, pumpkin=true } }
	},
	kon_hutkeep        = { gender = "male", nationality = "usa",
		likes = {
			categories = { bar=true },
			products = { i10=true, m06=true },
			ingredients = { kon_coffee=true, hibiscus=true, guava=true, pineapple=true }
		},
		dislikes = { ingredients = { lavender=true, rose=true } }
	},
	kon_marketkeep     = { gender = "male", nationality = "usa",
		likes = {
			categories = { beverage=true },
			products = { c01=true },
			ingredients = { kon_coffee=true, macadamia=true, mango=true }
		},
		dislikes = { ingredients = { sumac=true } }
	},
	kon_plantationkeep = { gender = "male", nationality = "usa",
		likes = {
			categories = { beverage=true, blend=true },
			products = { c10=true },
			ingredients = { cacao=true, kon_coffee=true, vanilla=true }
		},
		dislikes = { categories = { truffle=true } }
	},
	kon_shopkeep       = { gender = "female", nationality = "usa",
		likes = { ingredients = { coconut=true, passionfruit=true, pineapple=true } }
	},

	-- LAS VEGAS (USA)
	las_casinokeep = { gender = "female", nationality = "yugoslavia",
		likes = {
			categories = { exotic=true, truffle=true },
			ingredients = { amaretto=true, cherry=true, ice_cream=true, toffee=true, whiskey=true }
		},
		dislikes = {
			categories = { bar=true },
			products = { b01=true }
		}
	},
	las_marketkeep = { gender = "female", nationality = "costa_rica",
		likes = {
			categories = { beverage=true },
			products = { b09=true, e07=true },
			ingredients = { espresso=true, strawberry=true, sugar=true, vanilla=true, wafer=true }
		},
		dislikes = { ingredients = { cayenne=true, ginger=true, wasabi=true } }
	},

	-- LIMA (Peru)
	lim_churchkeep   = { gender = "female", nationality = "peru", religion = "christian",
		likes = { ingredients = { cacao=true, cinnamon=true } },
		dislikes = { ingredients = { rum=true } }
	},
	lim_marketkeep   = { gender = "female", nationality = "peru",
		likes = {
			categories = { exotic=true },
			products = { e03=true },
			ingredients = { cayenne=true, guava=true, lime=true }
		},
		dislikes = { ingredients = { lavender=true } }
	},
	lim_mountainkeep = { gender = "male", nationality = "peru",
		likes = { ingredients = { lim_cacao=true, salt=true, walnut=true } },
		dislikes = { categories = { beverage=true } }
	},
	lim_plazakeep    = { gender = "female", nationality = "peru",
		likes = { ingredients = { passionfruit=true, vanilla=true } },
		dislikes = { ingredients = { wasabi=true } }
	},
	lim_shopkeep     = { gender = "male", nationality = "italy",
		likes = {
			categories = { beverage=true, blend=true },
			products = { c09=true },
			ingredients = { amaretto=true, espresso=true, hazelnut=true, rosemary=true }
		},
		dislikes = { ingredients = { guava=true } }
	},

	-- MAHAJANGA (Madagascar)
	mah_shopkeep = { gender = "male", nationality = "madagascar",
		likes = {
			categories = { bar=true, exotic=true },
			ingredients = { cacao=true, coconut=true, vanilla=true }
		},
		dislikes = { ingredients = { maple=true } }
	},

	-- REYKJAVIK (Iceland)
	rey_marketkeep = { gender = "female", nationality = "iceland",
		likes = { ingredients = { blueberry=true, cranberry=true, oat=true } },
		dislikes = { ingredients = { cayenne=true } }
	},
	rey_shopkeep   = { gender = "male", nationality = "iceland",
		likes = { ingredients = { cream=true, plum=true, rhubarb=true } }
	},
	rey_xxxxkeep   = { gender = "male", nationality = "iceland",
		likes = {
			categories = { truffle=true },
			ingredients = { blackberry=true, blueberry=true, cream=true, rhubarb=true, salt=true }
		},
		dislikes = { ingredients = { lychee=true, mango=true, passionfruit=true, pineapple=true } }
	},

	-- SAN FRANCISCO (USA)
	san_barkeep    = { gender = "female", nationality = "usa",
		likes = {
			categories = { beverage=true, blend=true },
			products = { m09=true },
			ingredients = { espresso=true, whiskey=true }
		},
		dislikes = { ingredients = { chamomile=true } }
	},
	san_marketkeep = { gender = "female", nationality = "usa",
		likes = { ingredients = { almond=true, pear=true, plum=true } },
		dislikes = { ingredients = { cayenne=true, rose=true } }
	},
	san_shopkeep   = { gender = "female", nationality = "usa",
		likes = {
			categories = { truffle=true, user=true },
			products = { t02=true },
			ingredients = { marshmallow=true, vanilla=true, wafer=true }
		},
		dislikes = { ingredients = { sumac=true } }
	},

	-- TANGIERS (Morocco)
	tan_hotelkeep  = { gender = "male", nationality = "morocco", religion = "muslim", dietaryreqs = { halal=true, alcohol_free=true },
		likes = {
			products = { b07=true, c01=true, c05=true, c07=true },
			ingredients = { mint=true }
		},
		dislikes = { ingredients = { cayenne=true } }
	},
	tan_marketkeep = { gender = "female", nationality = "netherlands", religion = "christian",
		likes = {
			categories = { infusion=true },
			products = { i08=true },
			ingredients = { apricot=true, honey=true, rosemary=true, tea=true }
		}
	},
	tan_portkeep   = { gender = "male", nationality = "morocco", religion = "jewish", dietaryreqs = { kosher=true },
		likes = {
			products = { b12=true, i09=true },
			ingredients = { raspberry=true, cinnamon=true }
		}
	},

	-- TOKYO (Japan)
	tok_marketkeep   = { gender = "female", nationality = "japan", dietaryreqs = { alcohol_free=true },
		likes = {
			categories = { bar=true, infusion=true },
			products = { t09=true },
			ingredients = { chestnut=true, ginger=true, matcha=true, salt=true, tea=true, wasabi=true, yuzu=true }
		},
		dislikes = { categories = { blend=true } }
	},
	tok_mountainkeep = { gender = "male", nationality = "usa", religion = "christian",
		likes = {
			categories = { bar=true, blend=true },
			ingredients = { apple=true, espresso=true, maple=true, peanut=true, pecan=true, whiskey=true }
		},
		dislikes = { ingredients = { matcha=true, sumac=true, wasabi=true } }
	},
	tok_palacekeep   = { gender = "male", nationality = "japan",
		likes = {
			categories = { infusion=true, user=true },
			ingredients = { bog_coffee=true, cinnamon=true, lime=true, lychee=true, saffron=true, vanilla=true }
		},
		dislikes = { ingredients = { butter=true, cream=true, milk=true, whipped_cream=true } }
	},
	tok_shopkeep     = { gender = "male", nationality = "japan",
		likes = {
			categories = { beverage=true, blend=true },
			products = { c10=true },
			ingredients = { almond=true, chestnut=true, espresso=true, hazelnut=true, toffee=true }
		},
		dislikes = { ingredients = { cayenne=true, ginger=true, wasabi=true } }
	},
	tok_stationkeep  = { gender = "male", nationality = "japan",
		likes = {
			categories = { bar=true },
			ingredients = { allspice=true, ginger=true, matcha=true, milk=true, salt=true, tea=true }
		},
		dislikes = { ingredients = { amaretto=true, brandy=true, grand_marnier=true, kahlua=true, sugar=true } }
	},
	tok_towerkeep    = { gender = "female", nationality = "japan",
		likes = {
			categories = { blend=true, exotic=true, user=true },
			products = { e11=true },
			ingredients = { lychee=true, passionfruit=true, pomegranate=true, raspberry=true, tea=true, yuzu=true }
		},
		dislikes = {
			products = { b01=true, b02=true },
			ingredients = { pumpkin=true }
		}
	},

	-- TORONTO (Canada)
	tor_bldg1keep   = { gender = "female", nationality = "uk",
		likes = {
			categories = { beverage=true, blend=true },
			products = { t01=true },
			ingredients = { almond=true, earl_grey=true, hibiscus=true, lavender=true, matcha=true, pistachio=true, rose=true, tea=true }
		},
		dislikes = { ingredients = { bal_coffee=true, bog_coffee=true, espresso=true, hav_coffee=true, kon_coffee=true, tan_coffee=true } }
	},
	tor_bldg2keep   = { gender = "female", nationality = "canada",
		likes = {
			products = { b02=true },
			ingredients = { apple=true, butter=true, maple=true, oat=true, pecan=true, walnut=true }
		},
		dislikes = { ingredients = { cayenne=true, wasabi=true } }
	},
	tor_factorykeep = { gender = "female", nationality = "canada",
		likes = {
			categories = { bar=true, user=true },
			products = { b03=true },
			ingredients = { caramel=true, hazelnut=true }
		},
		dislikes = { ingredients = { rose=true } }
	},
	tor_marketkeep  = { gender = "female", nationality = "canada",
		likes = {
			categories = { bar=true },
			products = { b02=true, m08=true },
			ingredients = { blueberry=true, milk=true, raisin=true, toffee=true, vanilla=true }
		},
		dislikes = {
			products = { e07=true },
			ingredients = { blackberry=true, mango=true, raspberry=true }
		}
	},
	tor_shopkeep    = { gender = "female", nationality = "canada",
		likes = { ingredients = { maple=true, pear=true, vanilla=true } },
		dislikes = { ingredients = { cayenne=true } }
	},

	-- ULURU (Australia)
	ulu_hutkeep  = { gender = "female", nationality = "australia",
		likes = {
			categories = { bar=true },
			ingredients = { lime=true }
		}
	},
	ulu_rockkeep = { gender = "male", nationality = "australia",
		likes = { ingredients = { ginger=true, lime=true, salt=true } },
		dislikes = { categories = { truffle=true } }
	},

	-- WELLINGTON (New Zealand)
	wel_bldg1keep  = { gender = "female", nationality = "new_zealand",
		likes = {
			categories = { beverage=true },
			ingredients = { caramel=true, earl_grey=true, peanut=true, raspberry=true, toffee=true }
		}
	},
	wel_marketkeep = { gender = "female", nationality = "new_zealand",
		likes = { ingredients = { honey=true, oat=true, pear=true } }
	},
	wel_shopkeep   = { gender = "female", nationality = "germany",
		likes = {
			categories = { beverage=true },
			products = { c04=true },
			ingredients = { earl_grey=true, hazelnut=true, plum=true }
		},
		dislikes = { ingredients = { wasabi=true } }
	},

	-- ZURICH (Switzerland)
	zur_bankkeep     = { gender = "male", nationality = "switzerland",
		likes = {
			categories = { truffle=true },
			products = { t02=true },
			ingredients = { almond=true, espresso=true, hazelnut=true }
		},
		dislikes = { ingredients = { cayenne=true } }
	},
	zur_factorykeep  = { gender = "male", nationality = "albania",
		likes = {
			categories = { bar=true, user=true },
			ingredients = { cacao=true, walnut=true }
		}
	},
	zur_marketkeep   = { gender = "female", nationality = "switzerland",
		likes = { ingredients = { hazelnut=true, milk=true, pear=true } },
		dislikes = { ingredients = { wasabi=true } }
	},
	zur_mountainkeep = { gender = "female", nationality = "switzerland",
		likes = {
			categories = { infusion=true },
			ingredients = { chestnut=true, honey=true }
		},
		dislikes = { ingredients = { cayenne=true } }
	},
	zur_riverkeep    = { gender = "male", nationality = "switzerland",
		likes = {
			categories = { bar=true, beverage=true },
			ingredients = { cherry=true, grand_marnier=true, lemon=true }
		}
	},
	zur_schoolkeep   = { gender = "male", nationality = "switzerland",
		likes = { ingredients = { almond=true, earl_grey=true } },
		dislikes = { ingredients = { rum=true } }
	},
	zur_shopkeep     = { gender = "female", nationality = "switzerland",
		likes = {
			categories = { bar=true, user=true },
			products = { b05=true },
			ingredients = { almond=true, caramel=true, chestnut=true, hazelnut=true }
		}
	},
	zur_stationkeep  = { gender = "male", nationality = "switzerland",
		likes = {
			categories = { beverage=true, blend=true },
			products = { c10=true },
			ingredients = { chestnut=true, espresso=true }
		}
	},
	zur_towerkeep    = { gender = "female", nationality = "switzerland",
		likes = { ingredients = { almond=true, cream=true, lavender=true, milk=true } }
	},

	-- ------------------------------------------------------------------------
	-- ANNOUNCER
	-- ------------------------------------------------------------------------
	announcer = {
		gender = "male", nationality = "canada",
		likes = { categories = { user=true } }
	},

	-- ------------------------------------------------------------------------
	-- STAGED / INACTIVE CHARACTER PROFILES
	-- ------------------------------------------------------------------------
	-- These profiles are deliberately block-commented so they have zero runtime
	-- effect. They collect data for characters that already have names/lore or
	-- planned port roles but are not fully integrated yet. Remove the surrounding
	-- block markers only after that character is instantiated and asset-ready.
	--
	-- A few fields are intentionally left unsettled where the current lore does
	-- not establish them. It is safer to keep those facts open than to turn a
	-- guess into canon simply because the data entry existed first.

	--[[
	-- FUTURE / DORMANT TRAVELERS

	trav_12 = { -- David Golder; remains dormant for v2.0
		gender = "male", nationality = "usa", religion = "jewish",
		likes = {
			categories = { bar=true, blend=true },
			ingredients = { almond=true, cacao=true, espresso=true, sugar=true, walnut=true }
		},
		dislikes = { ingredients = { cayenne=true, lavender=true, rose=true } }
	},

	trav_14 = { -- Eduardo Tavares
		gender = "male", nationality = "portugal",
		likes = {
			categories = { bar=true, blend=true },
			ingredients = { almond=true, cacao=true, cinnamon=true, espresso=true, orange=true, sugar=true }
		},
		dislikes = { ingredients = { lavender=true, wasabi=true } }
	},

	trav_15 = { -- Gustav Maier
		gender = "male", nationality = "austria",
		likes = {
			categories = { beverage=true, truffle=true },
			ingredients = { cinnamon=true, cream=true, espresso=true, hazelnut=true, vanilla=true, whipped_cream=true }
		},
		dislikes = { ingredients = { cayenne=true, wasabi=true } }
	},

	trav_17 = { -- Wally Hammersmith; nationality remains open in current lore
		gender = "male",
		likes = {
			categories = { bar=true, user=true },
			ingredients = { caramel=true, espresso=true, hazelnut=true, peanut=true, whiskey=true }
		},
		dislikes = { ingredients = { rose=true } }
	},

	trav_18 = { -- Oscar Segura; nationality remains open in current lore
		gender = "male",
		likes = {
			categories = { exotic=true },
			ingredients = { cacao=true, guava=true, mango=true, passionfruit=true, tamarind=true }
		},
		dislikes = { ingredients = { cream=true, whipped_cream=true } }
	},

	trav_19 = { -- Alfredo Gamata
		gender = "male", nationality = "philippines",
		likes = {
			categories = { bar=true, exotic=true },
			ingredients = { banana=true, cacao=true, coconut=true, mango=true, pineapple=true, sugar=true }
		},
		dislikes = { ingredients = { maple=true } }
	},

	trav_20 = { -- Wu Xiuying
		gender = "female", nationality = "china",
		likes = {
			categories = { beverage=true, infusion=true },
			ingredients = { earl_grey=true, ginger=true, jasmine=true, lychee=true, sesame=true, star_anise=true, tea=true }
		},
		dislikes = { ingredients = { marshmallow=true } }
	},

	-- DORMANT HOME-PORT LOCALS

	bag_xxxkeep = { -- Shatha Aboubakr
		gender = "female", nationality = "iraq",
		likes = { ingredients = { apricot=true, cardamom=true, date=true, pomegranate=true, saffron=true, tea=true } },
		dislikes = { ingredients = { marshmallow=true } }
	},

	dou_xxxxkeep = { -- Adele Salla
		gender = "female", nationality = "cameroon",
		likes = { ingredients = { banana=true, dou_cacao=true, mango=true, peanut=true, tamarind=true, vanilla=true } },
		dislikes = { ingredients = { maple=true } }
	},

	lim_xxxxkeep = { -- César Farje
		gender = "male", nationality = "peru",
		likes = { ingredients = { cayenne=true, cinnamon=true, lim_cacao=true, passionfruit=true, salt=true } },
		dislikes = { ingredients = { lavender=true } }
	},

	tor_xxxxkeep = { -- Sheridan Munro; gender remains open in current lore
		nationality = "canada",
		likes = { ingredients = { apple=true, cranberry=true, maple=true, oat=true, walnut=true } },
		dislikes = { ingredients = { cayenne=true } }
	},

	wel_xxxxkeep = { -- Robert Daley
		gender = "male", nationality = "new_zealand",
		likes = {
			categories = { bar=true, blend=true },
			ingredients = { almond=true, caramel=true, espresso=true, hazelnut=true, walnut=true }
		},
		dislikes = { ingredients = { rose=true } }
	},

	zur_lakekeep = { -- Beate Lautens
		gender = "female", nationality = "switzerland",
		likes = { ingredients = { almond=true, chestnut=true, earl_grey=true, hazelnut=true, honey=true, tea=true } },
		dislikes = { ingredients = { cayenne=true } }
	},

	-- DORMANT FIXED-ROLE CHARACTERS
	-- These are not intended for the ambient local pool merely because their old
	-- role strings still exist. Their profiles are staged for a future role return.

	cap_factorykeep = { -- Alice van Niekerk
		gender = "female", nationality = "south_africa",
		likes = { ingredients = { caramel=true, cream=true, rooibos=true, vanilla=true } },
		dislikes = { ingredients = { cayenne=true } }
	},

	san_factorykeep = { -- Ilya Bajanov
		gender = "male", nationality = "russia",
		likes = { ingredients = { cacao=true, cherry=true, espresso=true, hazelnut=true } },
		dislikes = { ingredients = { hibiscus=true } }
	},

	tok_factorykeep = { -- Hitoshi Akimoto
		gender = "male", nationality = "japan",
		likes = { ingredients = { ginger=true, matcha=true, sesame=true, tea=true, yuzu=true } },
		dislikes = { ingredients = { cayenne=true } }
	},

	-- FUTURE PORT CHARACTERS
	-- Port nationality and role come from the reserved string IDs / planned port
	-- grouping. Taste profiles are staging designs and remain inert until activation.

	-- Addis Ababa / Ethiopia
	add_marketkeep = { -- Abeba Tadesse
		gender = "female", nationality = "ethiopia",
		likes = { ingredients = { add_coffee=true, cardamom=true, honey=true, peach=true, tea=true } },
		dislikes = { ingredients = { cayenne=true } }
	},
	add_shopkeep = { -- Ephrem Mekonnen
		gender = "male", nationality = "ethiopia",
		likes = {
			categories = { beverage=true, truffle=true },
			ingredients = { add_coffee=true, almond=true, honey=true, vanilla=true }
		},
		dislikes = { ingredients = { wasabi=true } }
	},
	add_plantationkeep = { -- Zewdu Haile
		gender = "male", nationality = "ethiopia",
		likes = { ingredients = { add_coffee=true, blueberry=true, cardamom=true, honey=true, jasmine=true, peach=true } },
		dislikes = { ingredients = { clove=true, cayenne=true } }
	},
	add_stationkeep = { -- Fikre Tesfaye
		gender = "male", nationality = "ethiopia",
		likes = {
			categories = { beverage=true },
			ingredients = { add_coffee=true, cinnamon=true, milk=true, sugar=true }
		}
	},

	-- Istanbul / Turkey
	ist_marketkeep = { -- Kenan Süleymanoğlu
		gender = "male", nationality = "turkey",
		likes = { ingredients = { apricot=true, fig=true, honey=true, pistachio=true, saffron=true, sesame=true } },
		dislikes = { ingredients = { wasabi=true } }
	},
	ist_shopkeep = { -- Ayla Yıldız
		gender = "female", nationality = "turkey",
		likes = {
			categories = { infusion=true, truffle=true },
			ingredients = { apricot=true, honey=true, pistachio=true, rose=true, tea=true }
		},
		dislikes = { ingredients = { peanut=true } }
	},
	ist_hotelkeep = { -- Tarık Arslan
		gender = "male", nationality = "turkey",
		likes = { ingredients = { cinnamon=true, espresso=true, fig=true, honey=true, tea=true } },
		dislikes = { ingredients = { marshmallow=true } }
	},
	ist_towerkeep = { -- Feride Gürpınar
		gender = "female", nationality = "turkey",
		likes = {
			categories = { exotic=true },
			ingredients = { pomegranate=true, rose=true, saffron=true, star_anise=true }
		}
	},

	-- Mahajanga / Madagascar
	mah_marketkeep = { -- Voary Tsirebika; gender remains open in current lore
		nationality = "madagascar",
		likes = { ingredients = { cacao=true, coconut=true, lychee=true, mango=true, vanilla=true } },
		dislikes = { ingredients = { maple=true } }
	},
	mah_postofficekeep = { -- Jamal Vassanji
		gender = "male", nationality = "madagascar",
		likes = { ingredients = { cacao=true, coconut=true, espresso=true, vanilla=true } }
	},
	mah_plantationkeep = { -- Lalao Rakotomalala
		gender = "female", nationality = "madagascar",
		likes = {
			categories = { bar=true },
			ingredients = { banana=true, mah_cacao=true, mango=true, orange=true, raspberry=true, vanilla=true }
		},
		dislikes = { ingredients = { cayenne=true } }
	},
	mah_xxxkeep = { -- Sahondra Befanonana; gender remains open in current lore
		nationality = "madagascar",
		likes = { ingredients = { coconut=true, honey=true, mango=true, pineapple=true, vanilla=true } }
	},

	-- Naples / Italy
	nap_marketkeep = { -- Gennaro Esposito
		gender = "male", nationality = "italy",
		likes = { ingredients = { almond=true, espresso=true, hazelnut=true, lemon=true, orange=true } },
		dislikes = { ingredients = { wasabi=true } }
	},
	nap_shopkeep = { -- Isabella Ricci
		gender = "female", nationality = "italy",
		likes = {
			categories = { beverage=true, truffle=true },
			ingredients = { amaretto=true, espresso=true, hazelnut=true, vanilla=true }
		},
		dislikes = { ingredients = { cayenne=true } }
	},
	nap_mountainkeep = { -- Salvatore Coppola
		gender = "male", nationality = "italy",
		likes = { ingredients = { almond=true, lemon=true, rosemary=true, walnut=true } },
		dislikes = { ingredients = { marshmallow=true } }
	},
	nap_castlekeep = { -- Vincenzo Marino
		gender = "male", nationality = "italy",
		likes = {
			categories = { truffle=true },
			ingredients = { amaretto=true, brandy=true, cacao=true, espresso=true, orange=true }
		}
	},
	]]
}

------------------------------------------------------------------------------
-- Character Preference Schema
------------------------------------------------------------------------------
-- Preferences live directly in CharacterData. Version 3 is the v2 release
-- rebalance that restores mixed product-line, product, and ingredient tastes.
CharacterPreferenceVersion = 3

------------------------------------------------------------------------------
-- Living Character Mobility Data
------------------------------------------------------------------------------
-- Static identity belongs here; the current location is stored in Player.
-- "local" means permanently home-port bound and available across that port.
-- "global" means one specific building whenever settled, otherwise travel.

CharacterMobilityData = {
	-- Legacy/global travelers
	trav_01 = { class="global", travelWeight=50, settledWeight=50, affinities={ business=4, lodging=3, transit=3, social=2 } },
	trav_02 = { class="global", travelWeight=50, settledWeight=50, affinities={ transit=4, social=3, lodging=3, business=2 } },
	trav_03 = { class="global", travelWeight=50, settledWeight=50, affinities={ academic=6, business=3, social=2, lodging=2 } },
	trav_04 = { class="global", travelWeight=50, settledWeight=50, affinities={ transit=5, landmark=5, social=4, cultural=3, lodging=3 } },
	trav_05 = { class="global", travelWeight=50, settledWeight=50, affinities={ transit=6, business=5, finance=3, lodging=3 } },
	trav_06 = { class="global", travelWeight=50, settledWeight=50, affinities={ academic=5, transit=4, landmark=3, business=2 }, portAffinity={ tokyo=5 } },
	trav_07 = { class="global", travelWeight=50, settledWeight=50, affinities={ lodging=6, social=5, formal=4, landmark=2 } },
	trav_08 = { class="global", travelWeight=50, settledWeight=50, affinities={ transit=6, lodging=4, business=4, landmark=2 }, portAffinity={ tokyo=5 } },
	trav_09 = { class="global", travelWeight=50, settledWeight=50, affinities={ lodging=5, social=5, cultural=3, business=2 } },
	trav_10 = { class="global", travelWeight=50, settledWeight=50, affinities={ business=5, finance=5, transit=5, lodging=3 } },
	trav_11 = { class="global", travelWeight=50, settledWeight=50, affinities={ formal=6, lodging=5, social=5, business=4 } },
	trav_13 = { class="global", travelWeight=75, settledWeight=25, affinities={ transit=8, lodging=6, business=3, social=3 } },
	trav_16 = { class="global", travelWeight=50, settledWeight=50, affinities={ business=6, formal=5, transit=5, lodging=4, finance=3, social=2 } },
	trav_21 = { class="global", travelWeight=60, settledWeight=40, affinities={ transit=6, landmark=6, cultural=5, social=4, lodging=3 } },
	mah_shopkeep = { class="global", travelWeight=50, settledWeight=50 },
	main_loud = { class="global", travelWeight=50, settledWeight=50, affinities={ landmark=6, wilderness=5, cultural=4, transit=3, lodging=2 } },
	main_sara = { class="global", travelWeight=50, settledWeight=50, affinities={ business=6, finance=4, transit=3, lodging=3 } },

	-- Local characters. They remain PORT-wide within their home port and never
	-- enter ambient travel or settle in another port.
	bag_bldg2keep = { class="local", homePort="baghdad" },
	dou_bldg1keep = { class="local", homePort="douala" },
	kon_hutkeep = { class="local", homePort="kona" },
	kon_bldg2keep = { class="local", homePort="kona" },
	rey_xxxxkeep = { class="local", homePort="reykjavik" },
	tor_bldg1keep = { class="local", homePort="toronto" },
	tor_bldg2keep = { class="local", homePort="toronto" },
	wel_bldg1keep = { class="local", homePort="wellington" },
	zur_riverkeep = { class="local", homePort="zurich" },

	-- ------------------------------------------------------------------------
	-- STAGED / INACTIVE MOBILITY PROFILES
	-- ------------------------------------------------------------------------
	-- These mirror the staged CharacterData entries above and remain completely
	-- inert while block-commented. The current mobility system already supports
	-- per-character travel/settled weighting, affinity tags and stay lengths.

	--[[
	-- Future / dormant travelers
	trav_12 = { class="global", travelWeight=50, settledWeight=50, affinities={ business=7, finance=7, transit=5, lodging=4, formal=2 } },
	trav_14 = { class="global", travelWeight=55, settledWeight=45, affinities={ transit=7, business=6, lodging=4, finance=3, social=3 } },
	trav_15 = { class="global", travelWeight=40, settledWeight=60, affinities={ social=7, lodging=6, formal=5, cultural=4, business=2 } },
	trav_17 = { class="global", travelWeight=55, settledWeight=45, affinities={ transit=7, business=6, social=5, lodging=4, civic=2 } },
	trav_18 = { class="global", travelWeight=70, settledWeight=30, minStay=2, maxStay=4, affinities={ wilderness=9, landmark=8, cultural=3, transit=2, lodging=2 } },
	trav_19 = { class="global", travelWeight=55, settledWeight=45, affinities={ transit=6, business=5, social=4, lodging=4 } },
	trav_20 = { class="global", travelWeight=50, settledWeight=50, affinities={ business=7, transit=6, formal=5, lodging=4, cultural=3 } },

	-- Dormant home-port locals
	bag_xxxkeep = { class="local", homePort="baghdad", affinities={ social=5, business=3, cultural=2 } },
	dou_xxxxkeep = { class="local", homePort="douala", affinities={ social=7, lodging=3, business=2 } },
	lim_xxxxkeep = { class="local", homePort="lima", affinities={ social=5, cultural=3, landmark=2 } },
	tor_xxxxkeep = { class="local", homePort="toronto", affinities={ lodging=5, business=4, social=3 } },
	wel_xxxxkeep = { class="local", homePort="wellington", affinities={ business=7, social=3, transit=2 } },
	zur_lakekeep = { class="local", homePort="zurich", affinities={ academic=5, social=3, cultural=2 } },
	]]

	-- When Mahajanga becomes an active port, Patrick Ratsimbazafy should stop
	-- using his current global profile and become a Mahajanga-local character:
	-- mah_shopkeep = { class="local", homePort="mahajanga" },
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

	for charName, mobility in pairs(CharacterMobilityData or {}) do
		local char = _AllCharacters[charName]
		if char then
			char.mobility = mobility
		else
			DebugOut("WARNING", string.format("Mobility data ignored for uninstantiated character: %s", charName))
		end
	end

	DebugOut("LOAD", string.format("Successfully applied data to %d characters.", count))
end

------------------------------------------------------------------------------
-- Preference Discovery Reconciliation
------------------------------------------------------------------------------
-- Existing saves may contain discoveries from an older preference matrix. Keep
-- only discoveries that are still true, and rebuild hidden dislikes without
-- touching character unlock state. Safe to run after every save load.

local function BuildPreferenceLookup(preferenceTable)
	local lookup = {}
	if not preferenceTable then return lookup end
	if preferenceTable.categories then for key, value in pairs(preferenceTable.categories) do if value then lookup[key] = true end end end
	if preferenceTable.products then for key, value in pairs(preferenceTable.products) do if value then lookup[key] = true end end end
	if preferenceTable.ingredients then for key, value in pairs(preferenceTable.ingredients) do if value then lookup[key] = true end end end
	return lookup
end

local function FilterDiscoveredPreferences(source, validLookup)
	local result = {}
	local seen = {}
	for _, key in ipairs(source or {}) do
		if validLookup[key] and not seen[key] then
			table.insert(result, key)
			seen[key] = true
		end
	end
	return result, seen
end

function ReconcileCharacterPreferenceDiscovery()
	if not Player or not Player.catalogue or not Player.catalogue.unlockedCharacters then return end

	local reconciled = 0
	for charName, catalogueData in pairs(Player.catalogue.unlockedCharacters) do
		local char = _AllCharacters[charName]
		if char and catalogueData then
			local validLikes = BuildPreferenceLookup(char.likes)
			local validDislikes = BuildPreferenceLookup(char.dislikes)

			catalogueData.discovered_likes = FilterDiscoveredPreferences(catalogueData.discovered_likes, validLikes)
			local filteredDislikes, knownDislikes = FilterDiscoveredPreferences(catalogueData.discovered_dislikes, validDislikes)
			catalogueData.discovered_dislikes = filteredDislikes

			catalogueData.undiscovered_dislikes_pool = {}
			if catalogueData.unlocked then
				for preferenceName, _ in pairs(validDislikes) do
					if not knownDislikes[preferenceName] then
						table.insert(catalogueData.undiscovered_dislikes_pool, preferenceName)
					end
				end
				table.sort(catalogueData.undiscovered_dislikes_pool)
			end

			reconciled = reconciled + 1
		end
	end

	DebugOut("CATALOGUE", string.format("Reconciled preference discovery data for %d characters (preference schema v%d).", reconciled, CharacterPreferenceVersion or 0))
end
