--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Las Vegas, NV, United States
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("lasvegas")
lasvegas.cadikey = "las_vegas"
lasvegas.mapx = 135 + 5
lasvegas.mapy = 115 - 5
lasvegas.hemisphere = "north"
lasvegas.region = "north_america"
lasvegas.culture = "north_american"
lasvegas.hidden = true

--LOCATIONS
CreateBuilding("las_market", lasvegas, Market)
las_market.inventory = { sugar, milk, whiskey, amaretto, grand_marnier, kahlua, espresso, strawberry, rum, brandy }
las_market.x = 70
las_market.y = 171.5
las_market.layer = 940
--
--
CreateBuilding("las_casino", lasvegas, Casino)
las_casino:SetCharacters(1, {"las_casinokeep"})
--las_casinokeep.actions = { PlaySlots(), PlayCrates()}
las_casino.x = 188
las_casino.y = 135.5
las_casino.layer = 920
--
--
EmptyBuilding("las_hotel", lasvegas)
las_hotel.x = 523
las_hotel.y = 125
las_hotel.layer = 910
--
--

--NON ANIMATED SPRITES
--
CreateSprite("las_backbuildings", lasvegas)
las_backbuildings.x = 293.5
las_backbuildings.y = 177.5
las_backbuildings.layer = 880
--
--
CreateSprite("las_welcome", lasvegas)
las_welcome.x = 616.5
las_welcome.y = 353
las_welcome.layer = 960
--
--
CreateSprite("las_streetlights", lasvegas)
las_streetlights.x = 254.5
las_streetlights.y = 224
las_streetlights.layer = 950
--
--

--(TO BE) ANIMATED SPRITES
--Animate sign lights to flicker
--Welcome Star
CreateSprite("las_star", lasvegas)
las_star.image = "ports/lasvegas/las_star.xml"
las_star.x = 607
las_star.y = 168
las_star.layer = 965
--
--Welcome Bulbs
CreateSprite("las_bulb", lasvegas)
las_bulb.image = "ports/lasvegas/las_bulb.xml"
las_bulb.x = 633
las_bulb.y = 372
las_bulb.layer = 970
--
--Stan's Sign
CreateSprite("las_stans", lasvegas)
las_stans.image = "ports/lasvegas/las_stans.xml"
las_stans.x = 52
las_stans.y = 92
las_stans.layer = 949
--
--Pelicana's
CreateSprite("las_pelicana", lasvegas)
las_pelicana.image = "ports/lasvegas/las_pelicana.xml"
las_pelicana.x = 736
las_pelicana.y = 193
las_pelicana.layer = 915

--Cars
--Z Away
CreateSprite("las_car1",lasvegas)
las_car1.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
las_car1.time=3000
las_car1.frequency = 50
las_car1.motion='loop'
las_car1.layer=942
las_car1.scaleFar=0.01
las_car1.speedFar=0.05
las_car1.speedNear=2.5
las_car1.yFar=150
las_car1.scaleNear=4.000
las_car1.yNear=600
las_car1.path= {{312,788},{344,548},{392,202},{390,162}}
las_car1.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
las_car1.tints = { Color(80,0,0,255), Color(0,80,0,255), Color(0,0,80,255),Color(80,80,0,255),Color(80,0,80,255),Color(0,80,80,255), }		-- This will randomly assign a tint
--
--Z towards
CreateSprite("las_car2",lasvegas)
las_car2.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
las_car2.time=2500
las_car2.frequency = 60
las_car2.motion='loop'
las_car2.layer=944
las_car2.scaleFar=0.01
las_car2.speedFar=0.05
las_car2.speedNear=2.5
las_car2.yFar=150
las_car2.scaleNear=4.000
las_car2.yNear=600
las_car2.path= {{386,164},{350,196},{230,314},{38,492},{-172,694}}
las_car2.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
las_car2.tints = { Color(80,0,0,255), Color(0,80,0,255), Color(0,0,80,255),Color(80,80,0,255),Color(80,0,80,255),Color(0,80,80,255), }

--L to R
CreateSprite("las_car3",lasvegas)
las_car3.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
las_car3.time=3000
las_car3.frequency = 70
las_car3.motion='loop'
las_car3.layer=937
las_car3.scaleFar=0.01
las_car3.yFar=150
las_car3.scaleNear=4.000
las_car3.yNear=600
las_car3.path= {{-132,246},{68,246},{280,248},{528,252}, {754,250},{900,250},{900,250} }
las_car3.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
las_car3.tints = { Color(80,0,0,255), Color(0,80,0,255), Color(0,0,80,255),Color(80,80,0,255),Color(80,0,80,255),Color(0,80,80,255), }

--R to L
CreateSprite("las_car4",lasvegas)
las_car4.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
las_car4.time=3300
las_car4.frequency = 50
las_car4.motion='loop'
las_car4.layer=936
las_car4.scaleFar=0.01
las_car4.yFar=150
las_car4.scaleNear=4.000
las_car4.yNear=600
las_car4.path= {{926,246},{798,248},{570,246},{414,248},{298,248},{144,248},{-106,246}}
las_car4.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
las_car4.tints = { Color(80,0,0,255), Color(0,80,0,255), Color(0,0,80,255),Color(80,80,0,255),Color(80,0,80,255),Color(0,80,80,255), }

--Turns 1
CreateSprite("las_car5",lasvegas)
las_car5.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
las_car5.time=2500
las_car5.frequency = 60
las_car5.motion='loop'
las_car5.layer=922
las_car5.scaleFar=0.01
las_car5.speedFar=0.05
las_car5.speedNear=1.5
las_car5.yFar=150
las_car5.scaleNear=4.000
las_car5.yNear=600
las_car5.path= {{389,161},{362,181},{332,205},{303,219},{274,249},{314,285},{410,275},{489,251},{559,251},{634,250},{712,250},{778,254},{838,254},{908,256}}
las_car5.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
las_car5.tints = { Color(80,0,0,255), Color(0,80,0,255), Color(0,0,80,255),Color(80,80,0,255),Color(80,0,80,255),Color(0,80,80,255), }

--Turns 2
CreateSprite("las_car6",lasvegas)
las_car6.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
las_car6.time=2500
las_car6.frequency = 70
las_car6.motion='loop'
las_car6.layer=921
las_car6.scaleFar=0.01
las_car6.speedFar=0.05
las_car6.speedNear=1.5
las_car6.yFar=150
las_car6.scaleNear=4.000
las_car6.yNear=600
las_car6.path= {{-24,696},{28,618},{62,544},{98,434},{152,378},{210,338},{274,308},{356,262},{326,246},{242,248},{178,250},{100,248},{-30,244},{-102,240}}
las_car6.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
las_car6.tints = { Color(80,0,0,255), Color(0,80,0,255), Color(0,0,80,255),Color(80,80,0,255),Color(80,0,80,255),Color(0,80,80,255), }
