--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Tokyo, Japan
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("tokyo")
tokyo.mapx = 689
tokyo.mapy = 118
tokyo.popupX = 439
tokyo.hemisphere = "north"
tokyo.region = "asia"
tokyo.culture = "east_asian"
tokyo.locked = true

--LOCATIONS---------------------------
CreateBuilding("tok_mountain", tokyo, Wilderness)
tok_mountain.x = 253.5
tok_mountain.y = 102.5
tok_mountain.layer = 730
--
--
CreateBuilding("tok_tower", tokyo)
tok_tower.x = 512.5
tok_tower.y = 92.5
tok_tower.layer = 750
--
--
CreateBuilding("tok_factory", tokyo, Factory)
tok_factory.x = 206.5
tok_factory.y = 164.5
tok_factory.layer = 800
tok_factory:SetCharacters(1, {"main_deit"})
tok_factory.defaultConfiguration = "i01"
tok_factory.windowX =47 
tok_factory.windowY =19
--
--
CreateBuilding("tok_palace", tokyo)
tok_palace.x = 83
tok_palace.y = 208
tok_palace.layer = 830
--
--
CreateBuilding("tok_station", tokyo, TrainStation)
tok_station.x = 662
tok_station.y = 255.5
tok_station.layer = 850
--
--
EmptyBuilding("tok_shrine", tokyo)
tok_shrine.x = 370.5
tok_shrine.y = 229
tok_shrine.layer = 890
--
--
CreateBuilding("tok_market", tokyo, Market)
tok_market.x = 555
tok_market.y = 328
tok_market.layer = 940
tok_market.inventory = { wasabi, sugar, milk, cherry, clove, orange, lemon, salt, ginger, mint, tea, pumpkin, matcha, strawberry }
--
--
CreateBuilding("tok_shop", tokyo, Shop)
tok_shop.x = 205.5
tok_shop.y = 305.5
tok_shop.labely = 305
tok_shop.layer = 950
-- 
--SPRITES------------------------------
--
CreateSprite("tok_backgroundbuildings", tokyo)
tok_backgroundbuildings.x = 365
tok_backgroundbuildings.y = 126.5
tok_backgroundbuildings.layer = 770
--
--
CreateSprite("tok_backgroundtrees", tokyo)
tok_backgroundtrees.x = 400
tok_backgroundtrees.y = 204.5
tok_backgroundtrees.layer = 790
--
--
CreateSprite("tok_factorymask", tokyo)
tok_factorymask.x = 216
tok_factorymask.y = 232
tok_factorymask.layer = 820
--
--
CreateSprite("tok_palacemask", tokyo)
tok_palacemask.x = 85
tok_palacemask.y = 258.5
tok_palacemask.layer = 840
--
--
CreateSprite("tok_track", tokyo)
tok_track.x = 636.5
tok_track.y = 191.5
tok_track.layer = 860
--
--
CreateSprite("tok_backgroundshops", tokyo)
tok_backgroundshops.x = 493.5
tok_backgroundshops.y = 279.5
tok_backgroundshops.layer = 910
--
--
CreateSprite("tok_lantern5", tokyo)
tok_lantern5.x = 515
tok_lantern5.y = 275
tok_lantern5.layer = 920
--
--
CreateSprite("tok_lantern6", tokyo)
tok_lantern6.x = 285.5
tok_lantern6.y = 273
tok_lantern6.layer = 930
--
--
CreateSprite("tok_lantern3", tokyo)
tok_lantern3.x = 583.5
tok_lantern3.y = 320.5
tok_lantern3.layer = 960
--
--
CreateSprite("tok_lantern4", tokyo)
tok_lantern4.x = 168.5
tok_lantern4.y = 320
tok_lantern4.layer = 970
--
--
CreateSprite("tok_lantern1", tokyo)
tok_lantern1.x = 752
tok_lantern1.y = 300
tok_lantern1.layer = 980
--
--
CreateSprite("tok_lantern2", tokyo)
tok_lantern2.x = 43
tok_lantern2.y = 298
tok_lantern2.layer = 990
--

CreateSprite("tok_backsignglow", tokyo)
tok_backsignglow.x = 580
tok_backsignglow.y = 158.5
tok_backsignglow.layer = 780
--

--(TO BE)ANIMATED SPRITES--------------
--
--CreateSprite("tok_clouds", tokyo)
--tok_clouds.x = 400
--tok_clouds.y = 66
--tok_clouds.layer = 740

--animate clouds
CreateSprite("tok_clouds1", tokyo)
tok_clouds1.image = "ports/zurich/zur_clouds1"
tok_clouds1.x = 0
tok_clouds1.y = 50
tok_clouds1.layer = 731
tok_clouds1.path = { {0,90},{100,90},{700,90},{800,90} }
tok_clouds1.time = 130000
tok_clouds1.motion = "loop"		
tok_clouds1.htile = 400			
tok_clouds1.frequency = 75		

CreateSprite("tok_clouds2", tokyo)
tok_clouds2.image = "ports/zurich/zur_clouds2"
tok_clouds2.x = 0
tok_clouds2.y = 120
tok_clouds2.layer = 729
tok_clouds2.path = { {0,125},{100,125},{700,125},{800,125} }
tok_clouds2.time = 200000
tok_clouds2.motion = "loop"		
tok_clouds2.htile = 400			
tok_clouds2.frequency = 60		
--
--
CreateSprite("tok_monorail", tokyo)
tok_monorail.x = 596
tok_monorail.y = 161.5
tok_monorail.layer = 870
tok_monorail.frequency = 100
tok_monorail.time=12000
tok_monorail.motion='loop'
tok_monorail.x = 487
tok_monorail.y = 361
tok_monorail.scaleFar=0.01
tok_monorail.scaleNear=2.0
tok_monorail.speedFar=1
tok_monorail.speedNear=6
tok_monorail.yFar=260
tok_monorail.yNear=0
tok_monorail.path= {{404,248},{404,248},{990,-25},{990,-25}}
--
--
CreateSprite("tok_boat", tokyo)--bob it
tok_boat.x = 96
tok_boat.y = 267.5
tok_boat.layer = 880
tok_boat.frequency = 50
--
--
CreateSprite("tok_lanternglow", tokyo)
tok_lanternglow.image = "ports/tokyo/tok_lanternglow.xml"
tok_lanternglow.x = 372
tok_lanternglow.y = 287.5
tok_lanternglow.layer = 900
--
--
--
CreateSprite("tok_stacklight", tokyo)
tok_stacklight.image = "ports/tokyo/tok_stacklights.xml"
tok_stacklight.x = 201.5
tok_stacklight.y = 109.5
tok_stacklight.layer = 810
--
--
CreateSprite("tok_towerlights", tokyo)
tok_towerlights.image = "ports/tokyo/tok_towerlights.xml"
tok_towerlights.x = 512
tok_towerlights.y = 76.5
tok_towerlights.layer = 760
--
--
--Car Z back to front
CreateSprite("tok_car1",tokyo)
tok_car1.images = {"ports/animations/car1","ports/animations/car4"} --small car and truck only
tok_car1.time=5500
tok_car1.frequency = 100
tok_car1.motion='loop'
tok_car1.layer=861
tok_car1.scaleFar=0.01
tok_car1.scaleNear=4.0
tok_car1.speedFar=1
tok_car1.speedNear=6
tok_car1.yFar=260
tok_car1.yNear=600
tok_car1.path= {{441,276},{490,297},{553,318},{645,357},{708,379},{776,398},{830,419},{867,431},{879,434},{879,434},{879,434}}
tok_car1.masks = {"ports/animations/car1_colormask","ports/animations/car4_colormask",}
tok_car1.tints = { Color(100,0,0,255), Color(0,100,0,255), Color(0,0,100,255),Color(100,100,0,255),Color(100,0,100,255),Color(0,100,100,255), }--darker colors

--Car Z side to back
CreateSprite("tok_car2",tokyo)
tok_car2.images = {"ports/animations/car1","ports/animations/car4"} --small car and truck only
tok_car2.time=5500
tok_car2.frequency = 100
tok_car2.motion='loop'
tok_car2.layer=859
tok_car2.scaleFar=0.01
tok_car2.scaleNear=4.0
tok_car2.speedFar=1
tok_car2.speedNear=6
tok_car2.yFar=260
tok_car2.yNear=600
tok_car2.path= {{875,360},{810,355},{777,355},{718,352},{665,352},{633,350},{576,331},{525,310},{485,299},{467,287}}
tok_car2.masks = {"ports/animations/car1_colormask","ports/animations/car4_colormask",}
tok_car2.tints = { Color(100,0,0,255), Color(0,100,0,255), Color(0,0,100,255),Color(100,100,0,255),Color(100,0,100,255),Color(0,100,100,255), }--darker colors
