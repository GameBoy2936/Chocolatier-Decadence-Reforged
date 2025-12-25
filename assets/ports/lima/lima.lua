--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Lima, Peru
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("lima")
lima.mapx = 200
lima.mapy = 218
lima.hemisphere = "south"
lima.region = "south_america"
lima.country = "peru"
lima.culture = "latin"
lima.locked = true

--LOCATIONS
CreateBuilding("lim_market", lima, Market)
lim_market.inventory = {powder, cacao, pecan, sugar, milk, honey, pepper, passionfruit, hazelnut, cinnamon, mint, lim_cacao }
lim_market.x = 96.5
lim_market.y = 222
lim_market.layer = 970
--
--
CreateBuilding("lim_shop", lima, Shop)
lim_shop.x = 432
lim_shop.y = 224
lim_shop.layer = 960
--
--
CreateBuilding("lim_plaza", lima)
lim_plaza.x = 225.5
lim_plaza.y = 327.5
lim_plaza.layer = 990
lim_plaza.labely = 325
--
--
CreateBuilding("lim_church", lima)
lim_church.x = 240.5
lim_church.y = 206.5
lim_church.layer = 910
--
--
CreateBuilding("lim_mountain", lima, Wilderness)
lim_mountain.x = 215
lim_mountain.y = 97.5
lim_mountain.layer = 870
--
--
EmptyBuilding("lim_redbuilding", lima)
lim_redbuilding.x = 614
lim_redbuilding.y = 207
lim_redbuilding.layer = 880
--

--NON ANIMATED SPRITES
CreateSprite("lim_backbuildings", lima)
lim_backbuildings.x = 259
lim_backbuildings.y = 182
lim_backbuildings.layer = 900
--
--
CreateSprite("lim_building1", lima)
lim_building1.x = 299
lim_building1.y = 223.5
lim_building1.layer = 950
--
--
CreateSprite("lim_building3", lima)
lim_building3.x = 540.5
lim_building3.y = 209.5
lim_building3.layer = 930
--
--
CreateSprite("_lim_building2", lima)
_lim_building2.x = 341
_lim_building2.y = 215
_lim_building2.layer = 940
--
--
CreateSprite("lim_lights", lima)
lim_lights.x = 331.5
lim_lights.y = 338.5
lim_lights.layer = 980
--
--
CreateSprite("lim_building4", lima)
lim_building4.x = 180
lim_building4.y = 222
lim_building4.layer = 920
--
--
CreateSprite("lim_palms", lima)
lim_palms.x = 694.5
lim_palms.y = 408.5
lim_palms.layer = 890
--
--

--(TO BE) ANIMATED SPRITES
--Fountain
CreateSprite("lim_fountain", lima)
lim_fountain.image = "ports/lima/lim_fountain.xml"
lim_fountain.x = 225.5
lim_fountain.y = 327.5
lim_fountain.layer = 991

--
--Clouds
CreateSprite("lim_clouds1", lima) 
lim_clouds1.image = "ports/zurich/zur_clouds1"--use zurich clouds
lim_clouds1.x = 0
lim_clouds1.y = 50
lim_clouds1.layer = 871
lim_clouds1.path = {{800,20},{800,20},{0,20},{0,20}}
lim_clouds1.time = 140000
lim_clouds1.motion = "loop"		
lim_clouds1.htile = 400			
lim_clouds1.frequency = 100		

CreateSprite("lim_clouds2", lima)
lim_clouds2.image = "ports/zurich/zur_clouds2"--use zurich clouds
lim_clouds2.x = 0
lim_clouds2.y = 120
lim_clouds2.layer = 869
lim_clouds2.path = {{800,60},{800,60},{0,60},{0,60}}
lim_clouds2.time = 250000
lim_clouds2.motion = "loop"		
lim_clouds2.htile = 400			
lim_clouds2.frequency = 100		

--Cars
--Curve Away
CreateSprite("lim_car1",lima)
lim_car1.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
lim_car1.time=10000
lim_car1.frequency = 90
lim_car1.motion='loop'
lim_car1.layer=879
lim_car1.scaleFar=0.01
lim_car1.scaleNear=3
lim_car1.speedFar=1
lim_car1.speedNear=3
lim_car1.yFar=250
lim_car1.yNear=600
lim_car1.path= {{574,714},{560,670},{550,570},{552,474},{560,380},{586,316},{612,274},{631,261},{648,252},{661,246},{650,239},{635,238},{615,238},{600,238},{600,238},{600,238}}
lim_car1.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
lim_car1.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--Straight Away
CreateSprite("lim_car2",lima)
lim_car2.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
lim_car2.time=14000
lim_car2.frequency = 90
lim_car2.motion='loop'
lim_car2.layer=918
lim_car2.scaleFar=0.1
lim_car2.scaleNear=3
lim_car2.speedFar=1
lim_car2.speedNear=4
lim_car2.yFar=230
lim_car2.yNear=600
lim_car2.path= {{350,675},{345,643},{340,584},{324,505},{305,371},{290,317},{280,290},{269,258},{257,241},{285,243},{297,241},{305,242},{340,243}}
lim_car2.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
lim_car2.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--Straight Forward
CreateSprite("lim_car3",lima)
lim_car3.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
lim_car3.time=12000
lim_car3.frequency = 90
lim_car3.motion='loop'
lim_car3.layer=919
lim_car3.scaleFar=0.1
lim_car3.scaleNear=3
lim_car3.speedFar=1
lim_car3.speedNear=4
lim_car3.yFar=230
lim_car3.yNear=600
lim_car3.path= {{156,244},{176,244},{192,242},{205,242},{220,242},{226,250},{221,258},{206,276},{193,297},{182,308},{163,333},{134,372},{113,409},{77,445},{9,494},{-60,525}}
lim_car3.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
lim_car3.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--Small Ship
