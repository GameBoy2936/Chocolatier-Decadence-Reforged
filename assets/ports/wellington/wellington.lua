--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Wellington, New Zealand
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("wellington")
wellington.mapx = 776
wellington.mapy = 365
wellington.align = "left"
wellington.popupX = 526
wellington.popupY = 310
wellington.hemisphere="south"
wellington.region="oceania"
wellington.country = "new_zealand"
wellington.culture = "western"
wellington.locked = true

--
CreateSprite("wel_foregroundmask", wellington)
wel_foregroundmask.x = 400
wel_foregroundmask.y = 446.5
wel_foregroundmask.layer = 990
--
--

CreateBuilding("wel_factory", wellington, Factory)
wel_factory:SetCharacters(1, {"main_whit"})
wel_factory.x = 710
wel_factory.y = 115
wel_factory.layer = 910
wel_factory.defaultConfiguration = "e01"
wel_factory.windowX =48 
wel_factory.windowY =70
--
--
CreateSprite("wel_fartree", wellington)
wel_fartree.x = 764.5
wel_fartree.y = 140.5
wel_fartree.layer = 920
--
--
CreateBuilding("wel_market", wellington, Market)
wel_market.inventory = {sugar, milk, mint, salt, pumpkin, espresso, butter, raspberry, strawberry, vanilla, whiskey, currant, cherry, pistachio, apple, honey }
wel_market.x = 693
wel_market.y = 264
wel_market.layer = 930
--
--
CreateSprite("wel_tree1", wellington)
wel_tree1.x = 739.5
wel_tree1.y = 374
wel_tree1.layer = 940
--
--
EmptyBuilding("wel_emptybld2", wellington)
wel_emptybld2.x = 71
wel_emptybld2.y = 209
wel_emptybld2.layer = 942
--
--
CreateSprite("wel_emptybld1", wellington)
wel_emptybld1.x = 173
wel_emptybld1.y = 198
wel_emptybld1.layer = 944
--
CreateBuilding("wel_shop", wellington, Shop)
wel_shop.x = 305.5
wel_shop.y = 199.5
wel_shop.layer = 950
--
--
CreateSprite("wel_lights", wellington)
wel_lights.x = 388
wel_lights.y = 333.5
wel_lights.layer = 960
--
--

CreateSprite("wel_wires", wellington)
wel_wires.x = 400
wel_wires.y = 351
wel_wires.layer = 980
--

--(TO BE) ANIMATED
--Trolleys
CreateSprite("wel_cablecar1", wellington)
wel_cablecar1.image = "ports/wellington/wel_cablecar"
wel_cablecar1.time = 9000
--wel_cablecar1.hold=8000 --hold param doesn't do anything
wel_cablecar1.motion = 'loop' --motion can be "bounce" "loop" or "oneway"
wel_cablecar1.layer = 970
wel_cablecar1.yNear = 600
wel_cablecar1.yFar = 200
wel_cablecar1.scaleFar=0.01
wel_cablecar1.scaleNear=1.7
wel_cablecar1.path={{-134,350},{-134,350},{948,430},{948,430}}

CreateSprite("wel_cablecar2", wellington)
wel_cablecar2.image = "ports/wellington/wel_cablecar"
wel_cablecar2.time = 9000
--wel_cablecar2.hold=8000 --hold param doesn't do anything
wel_cablecar2.motion = 'loop' --motion can be "bounce" "loop" or "oneway"
wel_cablecar2.layer = 971
wel_cablecar2.yNear = 600
wel_cablecar2.yFar = 230
wel_cablecar2.scaleFar=0.01
wel_cablecar2.scaleNear=2.0
wel_cablecar2.path={{948,450},{948,450},{-134,355},{-134,355}}

--Cars
--L to R
CreateSprite("wel_car1",wellington)
wel_car1.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
wel_car1.time=8000
wel_car1.frequency = 100
wel_car1.motion='loop'
wel_car1.layer=968
wel_car1.scaleFar=0.01
wel_car1.scaleNear=1.5
wel_car1.speedFar=1
wel_car1.speedNear=2
wel_car1.yFar=100
wel_car1.yNear=600
wel_car1.path= {{-68,326},{-68,326},{900,439},{900,439}}
wel_car1.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
wel_car1.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--R to L
CreateSprite("wel_car2",wellington)
wel_car2.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
wel_car2.time=8000
wel_car2.frequency = 100
wel_car2.motion='loop'
wel_car2.layer=968
wel_car2.scaleFar=0.01
wel_car2.scaleNear=1.5
wel_car2.speedFar=1
wel_car2.speedNear=2
wel_car2.yFar=100
wel_car2.yNear=600
wel_car2.path= {{900,448},{900,448},{-98,338},{-98,338}}
wel_car2.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
wel_car2.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }


--
CreateSprite("wel_farboat", wellington)
wel_farboat.x = 615
wel_farboat.y = 139
wel_farboat.layer = 900
wel_farboat.frequency = 50
--
--
