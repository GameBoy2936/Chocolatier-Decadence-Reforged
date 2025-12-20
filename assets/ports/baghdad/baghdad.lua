--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Baghdad, Iraq
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("baghdad")
baghdad.mapx = 484
baghdad.mapy = 90
baghdad.hemisphere = "north"
baghdad.region = "middle_east"
baghdad.culture = "muslim"
baghdad.locked = true

--LOCATIONS
CreateBuilding("bag_market", baghdad, Market)
bag_market.inventory = { anise, sugar, milk, cardamom, espresso, pistachio, saffron, allspice, cinnamon, sumac, nutmeg, clove, fig, pomegranate }
bag_market.x = 247
bag_market.y = 298
bag_market.layer = 890
bag_market.labely = 305
--
--
CreateBuilding("bag_shop", baghdad, Shop)
bag_shop.x = 547.5
bag_shop.y = 292.5
bag_shop.layer = 920
bag_shop.labely = 360
--
--
CreateBuilding("bag_tower", baghdad)
bag_tower.x = 296.5
bag_tower.y = 83
bag_tower.layer = 850
--
--
EmptyBuilding("bag_buildingreddoor", baghdad)
bag_buildingreddoor.x = 660.5
bag_buildingreddoor.y = 268
bag_buildingreddoor.layer = 930
--
--


--NON ANIMATED SPRITES
--
CreateSprite("bag_telephonefront", baghdad)
bag_telephonefront.x = 212
bag_telephonefront.y = 447
bag_telephonefront.layer = 980
--
--
CreateSprite("bag_palmmask1", baghdad)
bag_palmmask1.x = 39.5
bag_palmmask1.y = 233
bag_palmmask1.layer = 970
--
--
CreateSprite("bag_telephoneback", baghdad)
bag_telephoneback.x = 424.5
bag_telephoneback.y = 287.5
bag_telephoneback.layer = 910
--
--
CreateSprite("bag_house", baghdad)
bag_house.x = 577.5
bag_house.y = 223
bag_house.layer = 900
--
--
CreateSprite("bag_forbuildings", baghdad)
bag_forbuildings.x = 461
bag_forbuildings.y = 496
bag_forbuildings.layer = 990
--
--
CreateSprite("bag_building2", baghdad)
bag_building2.x = 751.5
bag_building2.y = 302
bag_building2.layer = 950
--
--
CreateSprite("bag_backbuildings", baghdad)
bag_backbuildings.x = 400
bag_backbuildings.y = 189.5
bag_backbuildings.layer = 860
--
--
CreateSprite("bag_palmmask2", baghdad)
bag_palmmask2.x = 282
bag_palmmask2.y = 158
bag_palmmask2.layer = 870
--
--
CreateSprite("bag_building1", baghdad)
bag_building1.x = 504.5
bag_building1.y = 165.5
bag_building1.layer = 880
--
--
CreateSprite("bag_farshore", baghdad)
bag_farshore.x = 407
bag_farshore.y = 83
bag_farshore.layer = 830
--
--
CreateSprite("bag_nearshore", baghdad)
bag_nearshore.x = 168
bag_nearshore.y = 109.5
bag_nearshore.layer = 840
--
--
CreateSprite("bag_palmright", baghdad)
bag_palmright.x = 767.5
bag_palmright.y = 213.5
bag_palmright.layer = 960
--
--

--(TO BE) ANIMATED
CreateSprite("bag_cart", baghdad)
bag_cart.x = 646
bag_cart.y = 372
bag_cart.layer = 940
bag_cart.frequency = 50 --cart is not always there
--
--
--Cars
--F to B
CreateSprite("bag_car1",baghdad)
bag_car1.images = {"ports/animations/car1","ports/animations/car4"} --only small car and truck
bag_car1.time=15500
bag_car1.frequency = 90
bag_car1.motion='loop'
bag_car1.layer=876
bag_car1.scaleFar=0.01
bag_car1.scaleNear=2.0
bag_car1.speedFar=1
bag_car1.speedNear=6
bag_car1.yFar=100
bag_car1.yNear=600
bag_car1.path= {{-49,672},{77,574},{166,513},{286,434},{392,362},{490,281},{538,232},{560,194},{581,164},{558,152},{526,145},{486,138},{464,136}}
bag_car1.masks = {"ports/animations/car1_colormask","ports/animations/car4_colormask",} --only small car and truck
bag_car1.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--B to Side
CreateSprite("bag_car2",baghdad)
bag_car2.images = {"ports/animations/car1","ports/animations/car4"} --only small car and truck
bag_car2.time=15000
bag_car2.frequency = 90
bag_car2.motion='loop'
bag_car2.layer=875
bag_car2.scaleFar=0.01
bag_car2.scaleNear=2.0
bag_car2.speedFar=1
bag_car2.speedNear=6
bag_car2.yFar=100
bag_car2.yNear=600
bag_car2.path= {{460,144},{494,144},{515,148},{535,151},{555,157},{562,167},{562,180},{542,195},{500,225},{465,255},{435,281},{420,331},{423,364},{433,392},{456,416},{503,424},{593,425},{764,425},{901,421}}
bag_car2.masks = {"ports/animations/car1_colormask","ports/animations/car4_colormask",} --only small car and truck
bag_car2.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--River boat
CreateSprite("bag_riverboat",baghdad)
bag_riverboat.image = "ports/zurich/zur_boat1"--use red zurich boat
bag_riverboat.time=25000
bag_riverboat.frequency = 70
bag_riverboat.motion='oneway'
bag_riverboat.layer=839
bag_riverboat.scaleFar=0.01
bag_riverboat.scaleNear=3.0
bag_riverboat.speedFar=0.3
bag_riverboat.speedNear=6
bag_riverboat.yFar=75
bag_riverboat.yNear=600
bag_riverboat.random=false
bag_riverboat.path= {{370,130},{343,109},{235,100},{152,96},{94,95},{56,83},{21,67},{-40,69}}

--Sandstorm
CreateSprite("bag_dustcloud1", baghdad)
bag_dustcloud1.image = "ports/gobidesert/gob_dustcloud"
bag_dustcloud1.layer = 825 --distant sandstorm
bag_dustcloud1.path = { {0,65},{0,65},{800,65},{800,65}}
bag_dustcloud1.scale = 0.5
bag_dustcloud1.time = 18000
bag_dustcloud1.motion = "loop"		
bag_dustcloud1.htile = 800			
bag_dustcloud1.frequency = 60	

CreateSprite("bag_dustcloud2", baghdad)
bag_dustcloud2.image = "ports/gobidesert/gob_dustcloud"
bag_dustcloud2.layer = 861 --close sandstorm
bag_dustcloud2.path = { {0,120},{0,120},{800,120},{800,120}}
bag_dustcloud2.scale = 1.0
bag_dustcloud2.time = 5000
bag_dustcloud2.motion = "loop"		
bag_dustcloud2.htile = 800			
bag_dustcloud2.frequency = 40			
--
