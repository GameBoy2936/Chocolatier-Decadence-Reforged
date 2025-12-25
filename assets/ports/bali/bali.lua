--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Bali, Indonesia
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("bali")
bali.mapx = 648
bali.mapy = 218
bali.popupX = 398
bali.hemisphere = "south"
bali.region = "asia"
bali.country = "indonesia"
bali.culture = "hindu"
bali.hidden = true

--LOCATIONS
CreateBuilding("bal_plantation", bali, Farm)
bal_plantation.inventory = { bal_coffee, bal_cacao}
bal_plantation:SetCharacters(1, {"bal_xxxkeep"})
bal_plantation.x = 573.5
bal_plantation.y = 159.5
bal_plantation.layer = 870
bal_plantation.labely = 150
--
--
EmptyBuilding("bal_temple", bali)
bal_temple.x = 115
bal_temple.y = 131.5
bal_temple.layer = 930
--
--
CreateBuilding("bal_market", bali, Market)
bal_market.inventory = { coconut, cacao, powder, espresso, allspice, cardamom, cinnamon, clove, ginger, mango, salt, sugar, lychee, turmeric, star_anise, nutmeg }
bal_market.x = 632.5
bal_market.y = 212
bal_market.layer = 880
--
--
CreateBuilding("bal_shop", bali, Shop)
bal_shop.x = 745
bal_shop.y = 231.5
bal_shop.layer = 900
bal_shop.labely = 305
--
--

--NON ANIMATED SPRITES
--
CreateSprite("bal_marketmask", bali)
bal_marketmask.x = 657.5
bal_marketmask.y = 261
bal_marketmask.layer = 890
--
----
--
CreateSprite("bal_palms", bali)
bal_palms.x = 507
bal_palms.y = 189.5
bal_palms.layer = 950
--
--
CreateSprite("bal_templemask", bali)
bal_templemask.x = 110.5
bal_templemask.y = 157
bal_templemask.layer = 940
--
--
CreateSprite("bal_neardock", bali)
bal_neardock.x = 294.5
bal_neardock.y = 283.5
bal_neardock.layer = 980
--
--
CreateSprite("bal_shopmask", bali)
bal_shopmask.x = 775
bal_shopmask.y = 308
bal_shopmask.layer = 910
--
--
CreateSprite("bal_island", bali)
bal_island.x = 208
bal_island.y = 175
bal_island.layer = 920
--
--
CreateSprite("bal_fardock", bali)
bal_fardock.x = 286
bal_fardock.y = 241
bal_fardock.layer = 960
--
--
CreateSprite("bal_cloudmask", bali)
bal_cloudmask.x = 564
bal_cloudmask.y = 94.5
bal_cloudmask.layer = 860
--
--
CreateSprite("bal_volcano", bali)
bal_volcano.x = 376.5
bal_volcano.y = 96
bal_volcano.layer = 830
--

--(TO BE) ANIMATED

--Boats
--Junk L to R
CreateSprite("bal_junk", bali)
bal_junk.time=15000
bal_junk.frequency = 70
bal_junk.motion='oneway'
bal_junk.random = false
bal_junk.layer= 831 --in front of volcano
bal_junk.scaleFar=0.5
bal_junk.scaleNear=0.5
bal_junk.speedFar=1
bal_junk.speedNear=1
bal_junk.yFar=100
bal_junk.yNear=600
bal_junk.path= {{-110,178},{-32,180},{78,180},{150,172},{248,174},{314,176},{380,176},{450,170},{450,170},{450,170}}

--Docked
CreateSprite("bal_boat2", bali)
bal_boat2.x = 269.5
bal_boat2.y = 259
bal_boat2.layer = 970
bal_boat2.frequency = 60
--
--
CreateSprite("bal_boat1", bali)
bal_boat1.x = 345
bal_boat1.y = 304.5
bal_boat1.layer = 990
bal_boat1.frequency = 70
--

--Clouds
CreateSprite("bal_cloud1", bali)
bal_cloud1.image = "ports/kona/kon_cloud1"	
bal_cloud1.x = 165
bal_cloud1.y = 108
bal_cloud1.layer = 832 --in front of volcano
bal_cloud1.path = { {0,42},{100,42},{700,42},{800,42} }
bal_cloud1.time = 60000
bal_cloud1.motion = "loop"		
bal_cloud1.htile = 800			
bal_cloud1.frequency = 85


CreateSprite("bal_cloud2", bali)
bal_cloud2.image = "ports/kona/kon_cloud2"	
bal_cloud2.x = 391.5
bal_cloud2.y = 94
bal_cloud2.layer = 825 --behind volcano
bal_cloud2.path = { {0,92},{100,92},{700,92},{800,92} }
bal_cloud2.time = 180000
bal_cloud2.motion = "loop"		
bal_cloud2.htile = 400			
bal_cloud2.frequency = 80		

--
CreateSprite("bal_cloud3", bali)
bal_cloud3.image = "ports/bali/bal_cloud1"
bal_cloud3.x = 610
bal_cloud3.y = 124.5
bal_cloud3.layer = 824 --behind volcano
bal_cloud3.path = { {0,82},{100,82},{700,82},{800,82} }
bal_cloud3.time = 80000
bal_cloud3.motion = "loop"		
bal_cloud3.htile = 400		
bal_cloud3.frequency = 75		
--
--
--Waves
CreateSprite("bal_wave1", bali)
bal_wave1.image = "ports/animations/wave1.xml"
bal_wave1.frequency = 100
bal_wave1.x = 250
bal_wave1.y = 230
bal_wave1.scale = -1.0
bal_wave1.layer = 958

CreateSprite("bal_wave2", bali)
bal_wave2.image = "ports/animations/wave2.xml"
bal_wave2.frequency = 100
bal_wave2.x = 320
bal_wave2.y = 340
bal_wave2.scale = 2.0
bal_wave2.layer = 959
