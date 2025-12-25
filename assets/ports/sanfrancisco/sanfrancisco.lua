--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: San Francisco, CA, United States
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("sanfrancisco")
sanfrancisco.cadikey = "san_francisco"
sanfrancisco.mapx = 115
sanfrancisco.mapy = 115 - 15
sanfrancisco.align = "left"
sanfrancisco.hemisphere = "north"
sanfrancisco.region = "north_america"
sanfrancisco.country = "usa"
sanfrancisco.culture = "north_american"
sanfrancisco.locked = true

--LOCATIONS
CreateBuilding("san_market", sanfrancisco, Market)
san_market.inventory = { sugar, milk, almond, raspberry, mint, cherry, blueberry, kahlua, espresso, pistachio, fig, walnut, salt, raisin }
san_market.x = 683.5
san_market.y = 133.5
san_market.layer = 860
--
--
CreateBuilding("san_shop", sanfrancisco, Shop)
san_shop.x = 512
san_shop.y = 240.5
san_shop.layer = 920
san_shop.labelx = 450
san_shop.labely = 300
--
--
CreateBuilding("san_bar", sanfrancisco, Saloon)
san_bar.x = 602.5
san_bar.y = 198.5
san_bar.layer = 910
--
--
CreateBuilding("san_factory", sanfrancisco, Factory)
san_factory.defaultConfiguration = "t01"
san_factory:SetCharacters(1, {"main_chas"})
san_factory.x = 242
san_factory.y = 244.5
san_factory.layer = 930
san_factory.windowX =47 
san_factory.windowY =18
--
--
CreateBuilding("san_bchq", sanfrancisco)
san_bchq:SetCharacters(1, {"main_evan"})
san_bchq.x = 431
san_bchq.y = 217.5
san_bchq.layer = 960
san_bchq.labely = 260
--
--
EmptyBuilding("san_alcatraz", sanfrancisco)
san_alcatraz.x = 560
san_alcatraz.y = 119
san_alcatraz.layer = 826
--
--

--NON ANIMATED SPRITES
CreateSprite("san_bridgefar", sanfrancisco)
san_bridgefar.x = 152
san_bridgefar.y = 84
san_bridgefar.layer = 820
--
--
CreateSprite("san_backhills", sanfrancisco)
san_backhills.x = 400
san_backhills.y = 169
san_backhills.layer = 790
--
--
CreateSprite("san_markettreemask", sanfrancisco)
san_markettreemask.x = 685.5
san_markettreemask.y = 190
san_markettreemask.layer = 870
--
--
CreateSprite("san_backbuildingsfar", sanfrancisco)
san_backbuildingsfar.x = 193.5
san_backbuildingsfar.y = 140.5
san_backbuildingsfar.layer = 880
--
--
CreateSprite("san_foregroundtrees", sanfrancisco)
san_foregroundtrees.x = 194.5
san_foregroundtrees.y = 471.5
san_foregroundtrees.layer = 990
--
--
CreateSprite("san_backbuildingsnear", sanfrancisco)
san_backbuildingsnear.x = 195.5
san_backbuildingsnear.y = 246
san_backbuildingsnear.layer = 900
--
--
CreateSprite("san_factorytreemask", sanfrancisco)
san_factorytreemask.x = 148
san_factorytreemask.y = 322
san_factorytreemask.layer = 940
--
--
CreateSprite("san_building2", sanfrancisco)
san_building2.x = 768
san_building2.y = 197.5
san_building2.layer = 950
--
--
CreateSprite("san_bridgenear", sanfrancisco)
san_bridgenear.x = 121.5
san_bridgenear.y = 78.5
san_bridgenear.layer = 850
--
--
CreateSprite("san_building1", sanfrancisco)
san_building1.x = 756.5
san_building1.y = 426
san_building1.layer = 980
--
--
CreateSprite("san_bookstore", sanfrancisco)
san_bookstore.x = 107
san_bookstore.y = 449.5
san_bookstore.layer = 970
--
--
CreateSprite("san_fogfar", sanfrancisco)
san_fogfar.x = 400
san_fogfar.y = 104.5
san_fogfar.layer = 810
san_fogfar.frequency = 50 --some days are foggier

-- 
 --TO BE ANIMATED SPRITES
 --Clouds
CreateSprite("san_cloud1", sanfrancisco) --Med dist. clouds
san_cloud1.image = "ports/kona/kon_cloud1" --Use Kona Clouds
san_cloud1.layer = 819
san_cloud1.path = { {0,70},{100,70},{700,70},{800,70} }
san_cloud1.time = 100000
san_cloud1.motion = "loop"		
san_cloud1.htile = 800		
san_cloud1.frequency = 100

CreateSprite("san_cloud2", sanfrancisco) --Close dist. clouds
san_cloud2.image = "ports/kona/kon_cloud2" --Use Kona Clouds
san_cloud2.layer = 821
san_cloud2.path = { {0,70},{100,70},{700,70},{800,70} }
san_cloud2.time = 60000
san_cloud2.motion = "loop"		
san_cloud2.htile = 800		
san_cloud2.frequency = 100

CreateSprite("san_cloud3", sanfrancisco) -- Far dist. clouds
san_cloud3.image = "ports/kona/kon_cloud3" --Use Kona Clouds
san_cloud3.layer = 789
san_cloud3.path = { {0,60},{100,60},{700,60},{800,60} }
san_cloud3.time = 200000
san_cloud3.motion = "loop"		
san_cloud3.htile = 800
san_cloud3.frequency = 100
--
--
--Vehicles
--car far L to R
CreateSprite("san_car1",sanfrancisco)
san_car1.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
san_car1.time=7000
san_car1.frequency = 100
san_car1.motion='loop'
san_car1.layer=865
san_car1.scaleFar=0.3
san_car1.scaleNear=0.3
san_car1.path= {{107,215},{107,215},{346,215},{585,215},{824,215},{824,215}}
san_car1.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
san_car1.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }
--
--car far R to L
CreateSprite("san_car2",sanfrancisco)
san_car2.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
san_car2.time=7000
san_car2.frequency = 100
san_car2.motion='loop'
san_car2.layer=864
san_car2.scaleFar=0.28
san_car2.scaleNear=0.28
san_car2.path= {{824,210},{824,210},{585,210},{585,210},{346,215},{107,215},{107,215}}
san_car2.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
san_car2.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }
--
--car Z back to Front
CreateSprite("san_car3",sanfrancisco)
san_car3.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3"}--no truck
san_car3.time=8000
san_car3.frequency = 100
san_car3.motion='loop'
san_car3.layer=866
san_car3.scaleFar=0.01
san_car3.scaleNear=1.5
san_car3.speedFar=1
san_car3.speedNear=2
san_car3.yFar=100
san_car3.yNear=600
san_car3.path= {{549,210},{571,210},{593,213},{644,214},{673,216},{682,230},{671,257},{658,275},{635,309},{613,338},{584,373},{545,390},{503,407},{431,407},{381,407},{329,407},{253,407},{164,407},{95,407}}
san_car3.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask"}--no truck
san_car3.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--car Z front to Back
CreateSprite("san_car4",sanfrancisco)
san_car4.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
san_car4.time=8000
san_car4.frequency = 100
san_car4.motion='loop'
san_car4.layer=866
san_car4.scaleFar=0.01
san_car4.scaleNear=1.5
san_car4.speedFar=1
san_car4.speedNear=2
san_car4.yFar=100
san_car4.yNear=600
san_car4.path= {{506,700},{532,630},{588,508},{618,428},{672,312},{696,252},{706,228},{726,212},{764,211},{826,212}}
san_car4.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
san_car4.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--cablecar
CreateSprite("san_cablecar", sanfrancisco)
san_cablecar.time=5000
san_cablecar.motion='bounce'
san_cablecar.x = 24
san_cablecar.y = 151
san_cablecar.layer = 890
san_cablecar.path = { {156,216},{153,216},{-44,121},{-44,121} }
--
--
--Ships in distance
--Use Wellington Ship
CreateSprite("san_ship1", sanfrancisco)
san_ship1.image = "ports/wellington/wel_farboat"--use wellington far boat
san_ship1.time=57200
san_ship1.frequency = 100
san_ship1.motion='loop'
san_ship1.layer=825
san_ship1.scale=2.0
san_ship1.path= {{900,130},{900,130},{-100,140},{-100,140}}

