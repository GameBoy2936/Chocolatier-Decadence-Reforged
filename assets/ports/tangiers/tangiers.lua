--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Tangiers, Morocco
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("tangiers")
tangiers.mapx = 370
tangiers.mapy = 84
tangiers.hemisphere = "north"
tangiers.region = "middle_east"
tangiers.country = "morocco"
tangiers.culture = "muslim"
tangiers.cadikey = "morocco"
tangiers.locked = true

--LOCATIONS-----------------

CreateBuilding("tan_market", tangiers, Market)
tan_market.inventory = { sugar, milk, nutmeg, saffron, sesame, clove, sumac, cashew, mint, orange, raspberry, tan_coffee, cinnamon, blueberry, cherry, fig }
tan_market.x = 417.5
tan_market.y = 302.5
tan_market.layer = 990
--
--
CreateBuilding("tan_shop", tangiers, Shop)
tan_shop.buys = { beverage=true, blend=true }
tan_shop.x = 738.5
tan_shop.y = 226.5
tan_shop.layer = 940
-- temporary character for testing
tan_shop:SetCharacters(2, {"main_zach"})
--
--
CreateBuilding("tan_bar", tangiers, Saloon)
tan_bar.x = 603
tan_bar.y = 49.5
tan_bar.layer = 930
--tan_bar.labely = 250
-- temporary character for testing
tan_bar:SetCharacters(2, {"evil_bian"})


CreateBuilding("tan_hotel", tangiers)
tan_hotel.x = 96
tan_hotel.y = 260.5
tan_hotel.layer = 960
tan_hotel.labely = 260
--
--
CreateBuilding("tan_port", tangiers)
tan_port.x = 396
tan_port.y = 170.5
tan_port.layer = 900


--NON ANIMATED SPRITES-----------------------------
CreateSprite("tan_cloudmask2", tangiers)
tan_cloudmask2.x = 671.5
tan_cloudmask2.y = 228
tan_cloudmask2.layer = 910
--
--
CreateSprite("tan_cloudmask1", tangiers)
tan_cloudmask1.x = 438
tan_cloudmask1.y = 160.5
tan_cloudmask1.layer = 920
--
--
CreateSprite("tan_shopmask", tangiers)
tan_shopmask.x = 723.5
tan_shopmask.y = 218
tan_shopmask.layer = 950
--
--
CreateSprite("tan_palms", tangiers)
tan_palms.x = 433.5
tan_palms.y = 227
tan_palms.layer = 970
--
--
CreateSprite("tan_hotelmask", tangiers)
tan_hotelmask.x = 128
tan_hotelmask.y = 239
tan_hotelmask.layer = 980
--
--
CreateSprite("tan_barmask", tangiers)
tan_barmask.x = 600
tan_barmask.y = 65
tan_barmask.layer = 934

CreateSprite("tan_tunnelmask", tangiers)
tan_tunnelmask.x = 680
tan_tunnelmask.y = 296.5
tan_tunnelmask.layer = 939
--

--(TO BE) ANIMATED SPRITES------------------------
--Clouds
CreateSprite("tan_cloud1", tangiers)--Near
tan_cloud1.image = "ports/kona/kon_cloud1"	
tan_cloud1.x = 165
tan_cloud1.y = 108
tan_cloud1.layer = 876
tan_cloud1.path = { {800,42},{700,42},{100,42},{0,42} }
tan_cloud1.time = 120000
tan_cloud1.motion = "loop"		-- This is the default, other options are "bounce" and "oneway"
tan_cloud1.htile = 400			-- Horizontal tiling to the left and right
tan_cloud1.frequency = 50

CreateSprite("tan_cloud2", tangiers)--far
tan_cloud2.image = "ports/kona/kon_cloud2"	
tan_cloud2.x = 391.5
tan_cloud2.y = 94
tan_cloud2.layer = 875
tan_cloud2.path = { {800,32},{700,32},{100,32},{0,32} }
tan_cloud2.time = 360000
tan_cloud2.motion = "loop"		-- This is the default, other options are "bounce" and "oneway"
tan_cloud2.htile = 400			-- Horizontal tiling to the left and right
tan_cloud2.frequency = 80		


CreateSprite("tan_cloud3", tangiers)--mid
tan_cloud3.image = "ports/kona/kon_cloud3"
tan_cloud3.x = 610
tan_cloud3.y = 124.5
tan_cloud3.layer = 875
tan_cloud3.path = { {800,35},{700,35},{100,35},{0,35} }
tan_cloud3.time = 160000
tan_cloud3.motion = "loop"		-- This is the default, other options are "bounce" and "oneway"
tan_cloud3.htile = 400			-- Horizontal tiling to the left and right
tan_cloud3.frequency = 60	


--Cars
--Z-axis
--R Back to Front
CreateSprite("tan_car1",tangiers)
tan_car1.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
tan_car1.time=5500
tan_car1.frequency = 90
tan_car1.motion='loop'
tan_car1.layer=700
tan_car1.scaleFar=0.309
tan_car1.scaleNear=2.0
tan_car1.speedFar=1
tan_car1.speedNear=2
tan_car1.yFar=150
tan_car1.yNear=600
tan_car1.path= {{506,206},{534,250},{590,340},{675,454},{738,548},{802,640},{836,696}}
tan_car1.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
tan_car1.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--L Front to Back
CreateSprite("tan_car2",tangiers)
tan_car2.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
tan_car2.time=5500
tan_car2.frequency = 95
tan_car2.motion='loop'
tan_car2.layer=701
tan_car2.scaleFar=0.309
tan_car2.scaleNear=2.0
tan_car2.speedFar=1
tan_car2.speedNear=2
tan_car2.yFar=150
tan_car2.yNear=600
tan_car2.path= {{-18,697},{37,614},{137,473},{218,363},{272,292},{300,250},{313,227}}
tan_car2.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
tan_car2.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--Horizontal
--L to R
CreateSprite("tan_car3",tangiers)
tan_car3.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
tan_car3.time=3500
tan_car3.frequency = 85
tan_car3.motion='loop'
tan_car3.layer=932
tan_car3.scaleNear=0.6
tan_car3.path= {{99,295},{168,297},{222,298},{302,297},{402,300},{476,300},{537,302},{587,313},{626,312},{679,311},{750,316},{813,318},{852,315}}
tan_car3.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
tan_car3.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--R to L
CreateSprite("tan_car4",tangiers)
tan_car4.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
tan_car4.time=3200
tan_car4.frequency = 75
tan_car4.motion='loop'
tan_car4.layer=931
tan_car4.scaleNear=0.6
tan_car4.path= {{863,319},{809,321},{719,312},{642,315},{588,316},{535,304},{458,298},{303,299},{55,299},{13,299}}
tan_car4.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
tan_car4.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--Ships in distance
--Use Wellington Ship
CreateSprite("tan_ship1", tangiers)
tan_ship1.image = "ports/wellington/wel_farboat"
tan_ship1.time=57200
tan_ship1.frequency = 70
tan_ship1.motion='loop'
tan_ship1.layer=898
tan_ship1.scale=1.0
tan_ship1.path= {{600,103},{600,103},{393,103},{309,103},{210,103},{175,103}}

--Use Falklands ship
CreateSprite("tan_ship2", tangiers)
tan_ship2.image = "ports/falklands/fal_ship"
tan_ship2.time=57200
tan_ship2.frequency = 100
tan_ship2.motion='loop'
tan_ship2.layer=899
tan_ship2.scale=0.1
tan_ship2.path= {{175,105},{210,105},{309,105},{393,105},{600,105},{600,105}}



