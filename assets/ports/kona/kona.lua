--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Kona, Hawaii, United States
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("kona")
kona.mapx = 40
kona.mapy = 185
kona.hemisphere="north"
kona.region="oceania"
kona.country = "usa"
kona.culture = "western"
kona.locked = true

--
--LOCATIONS-------------------------
CreateBuilding("kon_plantation", kona, Farm)
kon_plantation.x = 164.5
kon_plantation.y = 184.5
kon_plantation.layer = 910
kon_plantation.inventory = {kon_coffee}
--
CreateBuilding("kon_market", kona, Market)
kon_market.inventory = {cream, sugar, milk, macadamia, cashew, orange, mint, honey, pineapple, salt, ginger, cacao, powder, pecan, passionfruit, banana }
kon_market.x = 102.5
kon_market.y = 286.5
kon_market.layer = 930
--
CreateBuilding("kon_shop", kona, Shop)
kon_shop.x = 232.5
kon_shop.y = 272
kon_shop.layer = 941
--
EmptyBuilding("kon_hut", kona)
kon_hut.x = 412
kon_hut.y = 287
kon_hut.layer = 940
--
--STATIC SPRITES AND MASKS---------------------------
CreateSprite("kon_plantationmask", kona)
kon_plantationmask.x = 288.5
kon_plantationmask.y = 254
kon_plantationmask.layer = 920
--
CreateSprite("kon_volcano", kona)
kon_volcano.x = 183.5
kon_volcano.y = 98.5
kon_volcano.layer = 870
--
CreateSprite("kon_palmback", kona)
kon_palmback.x = 500.5
kon_palmback.y = 236.5
kon_palmback.layer = 980
--

CreateSprite("kon_palmfore", kona)
kon_palmfore.x = 101.5
kon_palmfore.y = 175.5
kon_palmfore.layer = 990
--
CreateSprite("kon_palmmid", kona)
kon_palmmid.x = 305.5
kon_palmmid.y = 198.5
kon_palmmid.layer = 970
--
CreateSprite("kon_bush", kona)
kon_bush.x = 23
kon_bush.y = 356
kon_bush.layer = 950
--
CreateSprite("kon_volcanomask", kona)
kon_volcanomask.x = 297
kon_volcanomask.y = 139
kon_volcanomask.layer = 880
--

--(TO BE) ANIMATED SPRITES

--Cars
--Towards
CreateSprite("kon_car1",kona)
kon_car1.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
kon_car1.time=3500
kon_car1.frequency = 80
kon_car1.motion='loop'
kon_car1.layer=945
kon_car1.scaleFar=0.1
kon_car1.speedFar=0.05
kon_car1.speedNear=3.5
kon_car1.yFar=290
kon_car1.scaleNear=5.5
kon_car1.yNear=600
kon_car1.path= {{869,291},{806,291},{731,291},{221,329},{134,332},{-21,332},{-108,332}}
kon_car1.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
kon_car1.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--Aways
CreateSprite("kon_car2",kona)
kon_car2.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
kon_car2.time=3500
kon_car2.frequency = 90
kon_car2.motion='loop'
kon_car2.layer=946
kon_car2.scaleFar=0.1
kon_car2.speedFar=0.05
kon_car2.speedNear=3.5
kon_car2.yFar=290
kon_car2.scaleNear=5.5
kon_car2.yNear=600
kon_car2.path= {{-108,336},{-108,336},{221,336},{221,336},{731,300},{731,292},{806,300},{869,300},{869,300}}
kon_car2.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
kon_car2.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--Clouds
CreateSprite("kon_cloud1", kona)
kon_cloud1.image = "ports/kona/kon_cloud1"	-- This is the default image used for the sprite called "kon_cloud1" in the kona port
kon_cloud1.x = 165
kon_cloud1.y = 108
kon_cloud1.layer = 890
kon_cloud1.path = { {0,102},{100,102},{700,102},{800,102} }
kon_cloud1.time = 60000
kon_cloud1.motion = "loop"		-- This is the default, other options are "bounce" and "oneway"
kon_cloud1.htile = 800			-- Horizontal tiling to the left and right
kon_cloud1.frequency = 85
--kon_cloud3.random = false		-- Keeping this in means kon_cloud1 will always start at the beginning of the path

-- Here's an example that will randomly choose from the three cloud graphics:
-- kon_cloud1.images = { "ports/kona/kon_cloud1", "ports/kona/kon_cloud2", "ports/kona/kon_cloud3" }

CreateSprite("kon_cloud2", kona)
kon_cloud2.image = "ports/kona/kon_cloud2"	-- This is the default image used for the sprite called "kon_cloud1" in the kona port
kon_cloud2.x = 391.5
kon_cloud2.y = 94
kon_cloud2.layer = 860
kon_cloud2.path = { {0,142},{100,142},{700,142},{800,142} }
kon_cloud2.time = 180000
kon_cloud2.motion = "loop"		-- This is the default, other options are "bounce" and "oneway"
kon_cloud2.htile = 400			-- Horizontal tiling to the left and right
kon_cloud2.frequency = 80		
--kon_cloud2.random = false		-- Keeping this in means kon_cloud1 will always start at the beginning of the path

--
CreateSprite("kon_cloud3", kona)
kon_cloud3.image = "ports/kona/kon_cloud3"
kon_cloud3.x = 610
kon_cloud3.y = 124.5
kon_cloud3.layer = 889
kon_cloud3.path = { {0,132},{100,132},{700,132},{800,132} }
kon_cloud3.time = 80000
kon_cloud3.motion = "loop"		-- This is the default, other options are "bounce" and "oneway"
kon_cloud3.htile = 400			-- Horizontal tiling to the left and right
kon_cloud3.frequency = 75		
--kon_cloud3.random = false		-- Keeping this in means kon_cloud1 will always start at the beginning of the path
--

--Surfer Girl!
CreateSprite("kon_surfer", kona)
kon_surfer.time = 5000
kon_surfer.scale = 0.5
kon_surfer.x = 742
kon_surfer.y = 370
kon_surfer.layer = 958
kon_surfer.frequency = 20 --rare
kon_surfer.path={{1100,372},{1024,374},{944,368},{821,372},{786,370},{734,370},{658,376},{556,384},{473,387},{409,390},{381,393}}

--Surfer rock mask
CreateSprite("kon_surfmask", kona)
kon_surfmask.x = 457
kon_surfmask.y = 379
kon_surfmask.layer = 959
--
--

--boat
CreateSprite("kon_boat", kona)
kon_boat.time = 2000
kon_boat.x = 705
kon_boat.y = 347.5
kon_boat.motion = 'bounce' --motion can be "bounce" "loop" or "oneway"
kon_boat.layer = 960
kon_boat.frequency = 50
kon_boat.path={{716,359},{715,362},{716,358},{715,363},{716,359}}
--
--Waves
CreateSprite("kon_wave1", kona)
kon_wave1.image = "ports/animations/wave1.xml"
kon_wave1.frequency = 100
kon_wave1.x = 650
kon_wave1.y = 375
kon_wave1.scale = 2.0
kon_wave1.layer = 702

CreateSprite("kon_wave2", kona)
kon_wave2.image = "ports/animations/wave1b.xml"
kon_wave2.frequency = 100
kon_wave2.x = 750
kon_wave2.y = 350
kon_wave2.scale = 1.0
kon_wave2.layer = 701