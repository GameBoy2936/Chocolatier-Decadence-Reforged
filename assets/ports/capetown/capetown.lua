--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Cape Town, South Africa
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("capetown")
capetown.mapx = 426
capetown.mapy = 270
capetown.hemisphere="south"
capetown.region="africa"
capetown.country = "south_africa"
capetown.culture = "western"
capetown.locked = true

--LOCATIONS
CreateBuilding("cap_factory", capetown, Factory)
cap_factory.defaultConfiguration = "c01"
cap_factory:SetCharacters(1, {"main_feli"})
cap_factory.x = 144
cap_factory.y = 221
cap_factory.layer = 850
cap_factory.windowX =47 
cap_factory.windowY =31
--
--
CreateBuilding("cap_market", capetown, Market)
cap_market.inventory = { sugar, milk, peanut, hazelnut, almond, caramel, cashew, mint, raspberry, whipped_cream }
cap_market.x = 540.5
cap_market.y = 306.5
cap_market.layer = 880

-- Gavin Hotz, late 40s man
cap_marketkeep.likes = {
    ingredients = { mint=true }
}
--
--
CreateBuilding("cap_shop", capetown, Shop)
cap_shop.x = 326.5
cap_shop.y = 290
cap_shop.layer = 890
cap_shop.labely = 300
--
--
CreateBuilding("cap_mountain", capetown, Wilderness)
cap_mountain.x = 401.5
cap_mountain.y = 130
cap_mountain.layer = 810
--
--
EmptyBuilding("cap_building3", capetown)
cap_building3.x = 705
cap_building3.y = 295
cap_building3.layer = 920
cap_building3.labely = 300
--
--
--NON ANIMATED SPRITES
CreateSprite("cap_mountainmask", capetown)
cap_mountainmask.x = 521.5
cap_mountainmask.y = 205
cap_mountainmask.layer = 825
--
--
CreateSprite("cap_building6", capetown)
cap_building6.x = 200.5
cap_building6.y = 312.5
cap_building6.layer = 870
--
--
CreateSprite("cap_building1", capetown)
cap_building1.x = 452
cap_building1.y = 261.5
cap_building1.layer = 900
--
--
CreateSprite("cap_building2", capetown)
cap_building2.x = 377.5
cap_building2.y = 311.5
cap_building2.layer = 910
--
--
CreateSprite("cap_building4", capetown)
cap_building4.x = 229.5
cap_building4.y = 355.5
cap_building4.layer = 930
--
--
CreateSprite("cap_building5", capetown)
cap_building5.x = 92.5
cap_building5.y = 303
cap_building5.layer = 940
--
--
CreateSprite("cap_foregroundmask", capetown)
cap_foregroundmask.x = 400
cap_foregroundmask.y = 325.5
cap_foregroundmask.layer = 960
--
--

CreateSprite("cap_pier", capetown)
cap_pier.x = 360.5
cap_pier.y = 443.5
cap_pier.layer = 980
--
--

--ANIMATIONS
--Cable Cars
--Cable overlay cablecars
CreateSprite("cap_cables", capetown)
cap_cables.x = 518.5
cap_cables.y = 112
cap_cables.layer = 822

  --Going Up
CreateSprite("cap_cablecar_up", capetown)
cap_cablecar_up.image = "ports/capetown/cap_cablecar"
cap_cablecar_up.x = 531
cap_cablecar_up.y = 174
cap_cablecar_up.layer = 820
cap_cablecar_up.time=9500
cap_cablecar_up.frequency = 100
cap_cablecar_up.motion='loop'
cap_cablecar_up.scaleFar=0.01
cap_cablecar_up.speedFar=0.05
cap_cablecar_up.speedNear=3.5
cap_cablecar_up.yFar=20
cap_cablecar_up.scaleNear=3.0
cap_cablecar_up.yNear=400
cap_cablecar_up.path= {{598,210},{575,198},{551,180},{536,166},{514,150},{499,133},{482,112},{464,89},{449,60},{444,38},{442,30},{440,25}}

  --Coming Down
CreateSprite("cap_cablecar_down", capetown)
cap_cablecar_down.image = "ports/capetown/cap_cablecar"
cap_cablecar_down.x = 531
cap_cablecar_down.y = 174
cap_cablecar_down.layer = 821
cap_cablecar_down.time=9500
cap_cablecar_down.frequency = 100
cap_cablecar_down.motion='loop'
cap_cablecar_down.scaleFar=0.01
cap_cablecar_down.speedFar=0.05
cap_cablecar_down.speedNear=3.5
cap_cablecar_down.yFar=20
cap_cablecar_down.scaleNear=3.0
cap_cablecar_down.yNear=400
cap_cablecar_down.path= {{439,24},{445,39},{448,53},{455,71},{465,95},{481,116},{493,135},{510,152},{520,168},{551,190},{571,208},{587,218},{606,228}}
--

--Boats
--Tug Leaves
CreateSprite("cap_boat2", capetown)
cap_boat2.x = 165
cap_boat2.y = 398.5
cap_boat2.layer = 970
cap_boat2.time=20000
cap_boat2.frequency = 60
cap_boat2.motion='oneway'
cap_boat2.scaleNear=1.0
cap_boat2.random = false
cap_boat2.path= {{357,387},{290,397},{215,408},{142,420},{38,432},{-38,437},{-96,441}}
--

--
--Yacht Leaves
CreateSprite("cap_boat1", capetown)
cap_boat1.x = 543
cap_boat1.y = 442.5
cap_boat1.layer = 990
cap_boat1.time=25000
cap_boat1.frequency = 40
cap_boat1.motion='oneway'
cap_boat1.scaleNear=1.0
cap_boat1.random = false
cap_boat1.path= {{538,414},{458,428},{376,444},{272,470},{160,496},{52,524},{-98,586},{-176,626},{-206,646},{-224,662}}
--
--
--Clouds
--
--Cars
--R to L front
CreateSprite("cap_car1",capetown)
cap_car1.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3"}
cap_car1.time=4200
cap_car1.frequency = 100
cap_car1.motion='loop'
cap_car1.layer=951
cap_car1.scaleNear=0.5
cap_car1.path= {{857,358},{815,356},{-13,362},{-88,362}}
cap_car1.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask"}
cap_car1.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--L to R front
CreateSprite("cap_car2",capetown)
cap_car2.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3"}
cap_car2.time=4000
cap_car2.frequency = 100
cap_car2.motion='loop'
cap_car2.layer=952
cap_car2.scaleNear=0.5
cap_car2.path= {{-88,362},{-13,362},{815,356},{857,358}}
cap_car2.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask"}
cap_car2.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--L to R back
CreateSprite("cap_car3",capetown)
cap_car3.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
cap_car3.time=4500
cap_car3.frequency = 100
cap_car3.motion='loop'
cap_car3.layer=905
cap_car3.scaleNear=0.3
cap_car3.path= {{100,353},{100,352},{700,347},{700,346}}
cap_car3.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask"}
cap_car3.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--R to L back
CreateSprite("cap_car4",capetown)
cap_car4.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
cap_car4.time=5200
cap_car4.frequency = 100
cap_car4.motion='loop'
cap_car4.layer=906
cap_car4.scaleNear=0.3
cap_car4.path= {{700,346},{700,347},{100,352},{100,353}}
cap_car4.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
cap_car4.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }
