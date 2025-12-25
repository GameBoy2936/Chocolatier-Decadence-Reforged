--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Zürich, Switzerland
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("zurich")
zurich.mapx = 400
zurich.mapy = 55 - 5
zurich.hemisphere = "north"
zurich.region = "europe"
zurich.country = "switzerland"
zurich.culture = "european"

--Begin Clickable Locations===================

CreateBuilding("zur_market", zurich, Market)
zur_market.x = 534.5 
zur_market.y = 230.5 
zur_market.layer = 860
zur_market.inventory = { sugar, milk, almond, cherry, clove, caramel, orange, lemon, whiskey, grand_marnier, espresso, amaretto, honey, rose, lavender, walnut }

CreateBuilding("zur_shop", zurich, Shop)
zur_shop.x = 107
zur_shop.y = 209.5
zur_shop.layer = 900

-- Analiese Rausis, late 20s
zur_shopkeep.likes = {
    categories = { bar=true, truffle=true },
    ingredients = { caramel=true, almond=true, hazelnut=true }
}
zur_shopkeep.dislikes = {
    ingredients = { pepper=true } -- Her clientele might be more traditional.
}

CreateBuilding("zur_factory", zurich, Factory)
zur_factory.x = 428.5 
zur_factory.y = 255 
zur_factory.layer = 820
zur_factory.windowX =57 
zur_factory.windowY =20

CreateBuilding("zur_station", zurich, TrainStation)
zur_station.x = 211
zur_station.y = 261
zur_station.labely = 260
zur_station.layer = 830
zur_station:SetCharacters(1, {"main_alex"})
zur_station:SetCharacters(2, {"zur_stationkeep"})

CreateBuilding("zur_tower", zurich)
zur_tower.x = 178.5
zur_tower.y = 133
zur_tower.layer = 790

-- Liridona Gygax, mid 20s
zur_towerkeep.likes = {
    ingredients = { almond=true, milk=true, cream=true, lavender=true }
}

CreateBuilding("zur_mountain", zurich, Wilderness)
zur_mountain.x = 498.5
zur_mountain.y = 98.5
zur_mountain.layer = 770

CreateBuilding("zur_school", zurich)
zur_school.x = 288
zur_school.y = 226.5
zur_school.labely = 230
zur_school.layer = 800

CreateBuilding("zur_bank", zurich, Bank)
zur_bank.x = 687.5
zur_bank.y = 204
zur_bank.layer = 920

--End Clickable Locations=============================
--
--Begin Non-Animated Sprites=======================================
CreateSprite("zur_mountain_mask", zurich)
zur_mountain_mask.x = 489
zur_mountain_mask.y = 124
zur_mountain_mask.layer = 780

CreateSprite("zur_background_trees", zurich)
zur_background_trees.x = 324
zur_background_trees.y = 285.5
zur_background_trees.layer = 810

CreateSprite("zur_street_right", zurich)
zur_street_right.x = 547.5
zur_street_right.y = 314
zur_street_right.layer = 880

CreateSprite("zur_building_left2", zurich)
zur_building_left2.x = 160
zur_building_left2.y = 233.5
zur_building_left2.layer = 890

CreateSprite("zur_building_left1", zurich)
zur_building_left1.x = 53
zur_building_left1.y = 216
zur_building_left1.layer = 910

CreateSprite("zur_bridge_far", zurich)
zur_bridge_far.x = 337.5
zur_bridge_far.y = 306.5
zur_bridge_far.layer = 930

CreateSprite("zur_bridge", zurich)
zur_bridge.x = 500
zur_bridge.y = 338
zur_bridge.layer = 940

CreateSprite("zur_bridge_mask", zurich)
zur_bridge_mask.x = 513.5
zur_bridge_mask.y = 325
zur_bridge_mask.layer = 950

CreateSprite("zur_railing", zurich)
zur_railing.x = 534
zur_railing.y = 454.5
zur_railing.layer = 960

CreateSprite("zur_trees", zurich)
zur_trees.x = 136
zur_trees.y = 372.5
zur_trees.layer = 970
--
--CreateSprite("zur_carfar", zurich)
--zur_carfar.x = 741
--zur_carfar.y = 325
--zur_carfar.layer = 915
--
CreateSprite("zur_carsparked", zurich)
zur_carsparked.x = 316.5
zur_carsparked.y = 365
zur_carsparked.layer = 965
-- 

--End Non-Animated Sprites=======================================
--
--Begin Animated Sprites=======================================

--animate boat1 red on river
CreateSprite("zur_boat1", zurich)
zur_boat1.time = 9000
zur_boat1.motion = 'loop' --motion can be "bounce" "loop" or "oneway"
zur_boat1.layer = 928
zur_boat1.yFar=280
zur_boat1.scaleFar=0.01
zur_boat1.scaleNear=3.000
zur_boat1.speedFar=0.05
zur_boat1.speedNear=1.5
zur_boat1.path={{904,582},{520,420},{510,420},{276,306},}

--animate boat2 white on river
CreateSprite("zur_boat2", zurich)
zur_boat2.time = 12000
zur_boat2.motion ='loop' --motion can be "bounce" "loop" or "oneway"
zur_boat2.layer = 927
zur_boat2.yFar=280
zur_boat2.scaleFar=0.01
zur_boat2.scaleNear=4.0
zur_boat2.speedFar=0.05
zur_boat2.speedNear=1.5
zur_boat2.path={{260,301},{260,301},{940,437},{940,437}}

--Car on Bridge
CreateSprite("zur_car1",zurich)
zur_car1.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
zur_car1.time=4000
zur_car1.motion='loop'
zur_car1.layer=948
zur_car1.scaleFar=0.01
zur_car1.speedFar=0.05
zur_car1.speedNear=1.5
zur_car1.yFar=260
zur_car1.scaleNear=3.5
zur_car1.yNear=600
zur_car1.path= {{84,682},{104,622},{146,506},{200,440},{234,400},{290,350},{354,320},{414,308},{494,300},{576,300},{628,300},{694,318},{740,322},{808,328},{876,338},{908,340}}
zur_car1.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
zur_car1.tints = { Color(200,0,0,255), Color(0,200,0,255), Color(0,0,200,255),Color(200,200,0,255),Color(200,0,200,255),Color(0,200,200,255), }

--cars moving on z-axis street
CreateSprite("zur_car2",zurich)
zur_car2.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
zur_car2.time=6000
zur_car2.motion='loop'
zur_car2.layer=875
zur_car2.scaleFar=0.01
zur_car2.speedFar=0.05
zur_car2.speedNear=1.5
zur_car2.yFar=260
zur_car2.scaleNear=3.5
zur_car2.yNear=600
zur_car2.path= {{96,666},{110,630},{234,318},{236,302},{232,300},{214,300},{194,300},{146,300},{104,300},{74,300}}
zur_car2.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
zur_car2.tints = { Color(200,0,0,255), Color(0,200,0,255), Color(0,0,200,255),Color(200,200,0,255),Color(200,0,200,255),Color(0,200,200,255), }
--
CreateSprite("zur_car5",zurich)
zur_car5.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
zur_car5.time=5000
zur_car5.motion='loop'
zur_car5.layer=876
zur_car5.scaleFar=0.01
zur_car5.speedFar=0.05
zur_car5.speedNear=1.5
zur_car5.yFar=260
zur_car5.scaleNear=3.5
zur_car5.yNear=600
zur_car5.path= {{270,296},{235,304},{235,328},{265,378},{300,456},{370,614},{400,690}}
zur_car5.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
zur_car5.tints = { Color(200,0,0,255), Color(0,200,0,255), Color(0,0,200,255),Color(200,200,0,255),Color(200,0,200,255),Color(0,200,200,255), }

--cars moving on far parallel street
CreateSprite("zur_car3",zurich)
zur_car3.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3"}--No truck
zur_car3.time=1200
zur_car3.motion='loop'
zur_car3.layer=832
zur_car3.scaleFar=0.01
zur_car3.speedFar=0.05
zur_car3.speedNear=1.5
zur_car3.yFar=260
zur_car3.scaleNear=3.5
zur_car3.yNear=600
zur_car3.path= {{97,300},{144,300},{544,300},{573,300}}
zur_car3.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask"}--No truck
zur_car3.tints = { Color(200,0,0,255), Color(0,200,0,255), Color(0,0,200,255),Color(200,200,0,255),Color(200,0,200,255),Color(0,200,200,255), }
--
CreateSprite("zur_car4",zurich)
zur_car4.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3"}--No truck
zur_car4.time=1500
zur_car4.motion='loop'
zur_car4.layer=832
zur_car4.scaleFar=0.01
zur_car4.speedFar=0.05
zur_car4.speedNear=1.5
zur_car4.yFar=260
zur_car4.scaleNear=3.5
zur_car4.yNear=600
zur_car4.path= {{573,303},{573,303},{97,303},{97,303}}
zur_car4.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask"}--No truck
zur_car4.tints = { Color(200,0,0,255), Color(0,200,0,255), Color(0,0,200,255),Color(200,200,0,255),Color(200,0,200,255),Color(0,200,200,255), }


--cars on far street

--animate clouds
CreateSprite("zur_clouds1", zurich)
zur_clouds1.x = 131
zur_clouds1.y = 100
zur_clouds1.layer = 775
zur_clouds1.path = { {0,100},{100,100},{700,100},{800,100} }
zur_clouds1.time = 100000
zur_clouds1.motion = "loop"		-- This is the default, other options are "bounce" and "oneway"
zur_clouds1.htile = 400			-- Horizontal tiling to the left and right
zur_clouds1.frequency = 60		-- Only show this cloud 50% of the timel. Default is 100%.
--kon_cloud1.random = false		-- Keeping this in means kon_cloud1 will always start at the beginning of the path

CreateSprite("zur_clouds2", zurich)
zur_clouds2.x = 131
zur_clouds2.y = 80
zur_clouds2.layer = 765
zur_clouds2.path = { {0,80},{100,80},{700,80},{800,80} }
zur_clouds2.time = 190000
zur_clouds2.motion = "loop"		-- This is the default, other options are "bounce" and "oneway"
zur_clouds2.htile = 400			-- Horizontal tiling to the left and right
zur_clouds2.frequency = 80		-- Only show this cloud 50% of the timel. Default is 100%.
--kon_cloud1.random = false		-- Keeping this in means kon_cloud1 will always start at the beginning of the path


--End Animated Sprites=======================================
