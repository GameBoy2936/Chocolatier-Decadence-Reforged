--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Bogotá, Colombia
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("bogota")
bogota.mapx = 210
bogota.mapy = 175
bogota.hemisphere = "north"
bogota.region = "south_america"
bogota.country = "colombia"
bogota.culture = "latin"
bogota.locked = true

--LOCATIONS
CreateBuilding("bog_market", bogota, Market)
bog_market.inventory = {allspice, sugar, cashew, butter, saffron, clove, espresso, pecan, pumpkin, cacao, powder, hazelnut }
bog_market.x = 105
bog_market.y = 290.5
bog_market.layer = 930
--
--
CreateBuilding("bog_shop", bogota, Shop)
bog_shop.x = 394
bog_shop.y = 274
bog_shop.layer = 900
--
--
CreateBuilding("bog_plantation", bogota, Farm)
bog_plantation.inventory = {bog_cacao, bog_coffee}
bog_plantation.x = 474
bog_plantation.y = 176
bog_plantation.layer = 870
--
--
CreateBuilding("bog_mountain", bogota, Wilderness)
bog_mountain.x = 523.5
bog_mountain.y = 102.5
bog_mountain.layer = 840
--
--
CreateBuilding("bog_church", bogota)
bog_church.x = 686
bog_church.y = 174.5
bog_church.layer = 940
--
--
CreateBuilding("bog_customs", bogota, Bank)
bog_customs.x = 304.5
bog_customs.y = 256.5
bog_customs.layer = 910
bog_customs.labely = 250
--
--
EmptyBuilding("bog_hotel", bogota)
bog_hotel.x = 485.5
bog_hotel.y = 275
bog_hotel.layer = 890
bog_hotel.labelx = 460
bog_hotel.labely = 270
--
--

--NON ANIMATED SPRITES
CreateSprite("bog_streetlight_med", bogota)
bog_streetlight_med.x = 32
bog_streetlight_med.y = 261.5
bog_streetlight_med.layer = 970
--
--
CreateSprite("bog_purplehouse", bogota)
bog_purplehouse.x = 224
bog_purplehouse.y = 285
bog_purplehouse.layer = 920
--
--
CreateSprite("bog_streetlight_front", bogota)
bog_streetlight_front.x = 202
bog_streetlight_front.y = 300
bog_streetlight_front.layer = 980
--
--
CreateSprite("bog_mountainmask", bogota)
bog_mountainmask.x = 197
bog_mountainmask.y = 116.5
bog_mountainmask.layer = 860
--
--
CreateSprite("bog_forgroundbush", bogota)
bog_forgroundbush.x = 161.5
bog_forgroundbush.y = 496.5
bog_forgroundbush.layer = 990
--
--
CreateSprite("bog_backgroundbuildings", bogota)
bog_backgroundbuildings.x = 276
bog_backgroundbuildings.y = 262
bog_backgroundbuildings.layer = 880
--
--
CreateSprite("bog_trees", bogota)
bog_trees.x = 540
bog_trees.y = 275
bog_trees.layer = 950

CreateSprite("bog_waterfall", bogota)
bog_waterfall.x = 407
bog_waterfall.y = 140
bog_waterfall.layer = 850
--

--(TO BE) ANIMATED SPRITES
CreateSprite("bog_tram", bogota)
bog_tram.layer = 960
bog_tram.time = 15000
--bog_tram.hold=8000 --hold param doesn't do anything
bog_tram.motion = 'loop' 
bog_tram.yNear = 600
bog_tram.yFar = 240
bog_tram.scaleFar=0.1
bog_tram.scaleNear=2.7
bog_tram.speedFar=0.5
bog_tram.speedNear=3.0
bog_tram.path={{-152,290},{-152,290},{1080,450},{1080,450}}
--
--
--Car R to L
CreateSprite("bog_car1",bogota)
bog_car1.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
bog_car1.time=6200
bog_car1.frequency = 100
bog_car1.motion='loop'
bog_car1.layer=949
bog_car1.scaleNear=0.8
bog_car1.path= {{952,348},{958,348},{574,330},{574,332},{226,332},{-192,334},{-188,336}}
bog_car1.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
bog_car1.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--Chooses bad angle for car.  Why?
--[[--Car Front to Back
CreateSprite("bog_car2",bogota)
bog_car2.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
bog_car2.time=6200
bog_car2.frequency = 75
bog_car2.motion='loop'
bog_car2.layer=952
bog_car2.yNear = 600
bog_car2.yFar = 240
bog_car2.scaleFar=0.1
bog_car2.scaleNear=2.7
bog_car2.speedFar=0.5
bog_car2.speedNear=3.0
bog_car2.path= {{946,448},{-100,314},{-100,314},{-100,314}}
bog_car2.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
bog_car2.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }
]]
--Mist Layers
CreateSprite("bog_mist_near", bogota)
bog_mist_near.image = "ports/bogota/bog_mist"
bog_mist_near.layer = 872
bog_mist_near.path = { {-200,200},{-200,200},{1000,200},{1000,200} }
bog_mist_near.time = 100000
bog_mist_near.motion = "loop"		
bog_mist_near.htile = 1200			
bog_mist_near.frequency = 100

CreateSprite("bog_mist_far", bogota)
bog_mist_far.image = "ports/bogota/bog_mist"
bog_mist_far.layer = 852
bog_mist_far.path = { {-200,130},{-200,130},{1000,130},{1000,130} }
bog_mist_far.time = 150000
bog_mist_far.motion = "loop"		
bog_mist_far.htile = 1200			
bog_mist_far.frequency = 100


