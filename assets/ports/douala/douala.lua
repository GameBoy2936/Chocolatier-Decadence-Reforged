--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Douala, Cameroon
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("douala")
douala.mapx = 404
douala.mapy = 155
douala.hemisphere="north"
douala.region="africa"
douala.culture = "western"
douala.locked = true

--LOCATIONS-----------------------------
CreateBuilding("dou_market", douala, Market)
dou_market.inventory = { sugar, cacao, ginger, pepper, hazelnut, banana, peanut, cashew, mint, cinnamon, cardamom, anise, currant, vanilla, mango, powder }
dou_market.labely = 250
dou_market.x = 741.5
dou_market.y = 428.5
dou_market.layer = 890
--
--
CreateBuilding("dou_plantation", douala, Farm)
dou_plantation.inventory = { dou_cacao }
dou_plantation.x = 177
dou_plantation.y = 116.5
dou_plantation.layer = 930

-- Guy Etame, late 30s cacao farmer
dou_plantationkeep.likes = {
    ingredients = { dou_cacao=true }
}
dou_plantationkeep.dislikes = {
    categories = { exotic=true } -- He has simple tastes and might dislike overly complex things.
}
--
--
CreateBuilding("dou_shop", douala, Shop)
dou_shop.x = 328.5
dou_shop.y = 157
dou_shop.layer = 950
--
--


--EMPTY BUILDING LOCATIONS-----------

EmptyBuilding("dou_emptybuilding2", douala)
dou_emptybuilding2.x = 500
dou_emptybuilding2.y = 191
dou_emptybuilding2.layer = 910
--
--
EmptyBuilding("dou_emptybuilding1", douala)
dou_emptybuilding1.x = 88
dou_emptybuilding1.y = 221
dou_emptybuilding1.layer = 970
--


--SPRITES-----------------------
CreateSprite("dou_marketmask", douala)
dou_marketmask.x = 712.5
dou_marketmask.y = 280
dou_marketmask.layer = 900
--
--
CreateSprite("dou_plantationmask", douala)
dou_plantationmask.x = 122.5
dou_plantationmask.y = 146
dou_plantationmask.layer = 940
--
--
CreateSprite("dou_shopmask", douala)
dou_shopmask.x = 459.5
dou_shopmask.y = 196.5
dou_shopmask.layer = 960
--
--
CreateSprite("dou_farbuildings", douala)
dou_farbuildings.x = 754.5
dou_farbuildings.y = 191
dou_farbuildings.layer = 880
--
CreateSprite("dou_palms", douala)
dou_palms.x = 502
dou_palms.y = 196.5
dou_palms.layer = 920
--
CreateSprite("dou_building1", douala)
dou_building1.x = 537.5
dou_building1.y = 167
dou_building1.layer = 905
--
--
CreateSprite("dou_treeright", douala)
dou_treeright.x = 702.5
dou_treeright.y = 188.5
dou_treeright.layer = 888
--



--(TO BE) ANIMATED SPRITES
--Clouds
CreateSprite("dou_clouds1", douala)
dou_clouds1.image = "ports/douala/dou_clouds"
dou_clouds1.x = 131
dou_clouds1.y = 70
dou_clouds1.layer = 775
dou_clouds1.path = { {0,70},{100,70},{700,70},{800,70} }
dou_clouds1.time = 130000
dou_clouds1.motion = "loop"		-- This is the default, other options are "bounce" and "oneway"
dou_clouds1.htile = 800			-- Horizontal tiling to the left and right
dou_clouds1.frequency = 80		-- Only show this cloud 80% of the time. Default is 100%.

CreateSprite("dou_clouds2", douala)
dou_clouds2.image = "ports/douala/dou_clouds"
dou_clouds2.x = 300
dou_clouds2.y = 150
dou_clouds2.layer = 776
dou_clouds2.path = { {0,20},{100,20},{700,20},{800,20} }
dou_clouds2.time = 83000
dou_clouds2.motion = "loop"		-- This is the default, other options are "bounce" and "oneway"
dou_clouds2.htile = 800			-- Horizontal tiling to the left and right
dou_clouds2.frequency = 60		-- Only show this cloud 80% of the time. Default is 100%.

--Far cars

--Z-axis cars
--Z towards
CreateSprite("dou_car1",douala)
dou_car1.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
dou_car1.time=6500
dou_car1.frequency = 60
dou_car1.motion='loop'
dou_car1.layer=971
dou_car1.scaleFar=0.01
dou_car1.speedFar=0.05
dou_car1.speedNear=9.5
dou_car1.yFar=190
dou_car1.scaleNear=7.000
dou_car1.yNear=600
dou_car1.path= {{620,216},{582,232},{512,246},{376,284},{218,322},{36,374},{-260,450}}
dou_car1.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
dou_car1.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }


CreateSprite("dou_car2",douala)
dou_car2.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
dou_car2.time=5800
dou_car2.frequency = 40
dou_car2.motion='loop'
dou_car2.layer=877
dou_car2.scaleFar=0.01
dou_car2.speedFar=0.01
dou_car2.speedNear=9.5
dou_car2.yFar=190
dou_car2.scaleNear=7.000
dou_car2.yNear=600
dou_car2.path= {{192,752},{298,624},{650,220},{674,210},{698,206},{732,206},{756,206},{778,206}}
dou_car2.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
dou_car2.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--Boat
CreateSprite("dou_boat", douala)
dou_boat.time=48000
dou_boat.frequency = 50
dou_boat.motion='oneway'
dou_boat.layer=876
dou_boat.yNear=600
dou_boat.path= {{100,172},{100,172},{900,172},{900,172}}
dou_boat.x = 667.5
dou_boat.y = 174
dou_boat.layer = 850
--
--
--
--Puddle Drops
CreateSprite("dou_drop1", douala)
dou_drop1.image = "ports/animations/rainring1.xml"
dou_drop1.frequency = 60
dou_drop1.x = 500
dou_drop1.y = 290
dou_drop1.scale = 1.0
dou_drop1.layer = 701

CreateSprite("dou_drop2", douala)
dou_drop2.image = "ports/animations/rainring2.xml"
dou_drop2.frequency = 70
dou_drop2.x = 540
dou_drop2.y = 290
dou_drop2.scale = 0.7
dou_drop2.layer = 702

CreateSprite("dou_drop3", douala)
dou_drop3.image = "ports/animations/rainring3.xml"
dou_drop3.frequency = 80
dou_drop3.x = 580
dou_drop3.y = 300
dou_drop3.scale = 1.2
dou_drop3.layer = 703

CreateSprite("dou_drop4", douala)
dou_drop4.image = "ports/animations/rainring2.xml"
dou_drop4.frequency = 50
dou_drop4.x = 500
dou_drop4.y = 345
dou_drop4.scale = 1.2
dou_drop4.layer = 704

CreateSprite("dou_drop5", douala)
dou_drop5.image = "ports/animations/rainring3.xml"
dou_drop5.frequency = 70
dou_drop5.x = 550
dou_drop5.y = 350
dou_drop5.scale = 0.5
dou_drop5.layer = 705

CreateSprite("dou_drop6", douala)
dou_drop6.image = "ports/animations/rainring1.xml"
dou_drop6.frequency = 80
dou_drop6.x = 560
dou_drop6.y = 360
dou_drop6.scale = 1.4
dou_drop6.layer = 706

CreateSprite("dou_drop7", douala)
dou_drop7.image = "ports/animations/rainring2.xml"
dou_drop7.frequency = 90
dou_drop7.x = 30
dou_drop7.y = 550
dou_drop7.scale = 3.0
dou_drop7.layer = 707

CreateSprite("dou_drop8", douala)
dou_drop8.image = "ports/animations/rainring3.xml"
dou_drop1.frequency = 40
dou_drop8.x = 300
dou_drop8.y = 300
dou_drop8.scale = 0.5
dou_drop8.layer = 708
--