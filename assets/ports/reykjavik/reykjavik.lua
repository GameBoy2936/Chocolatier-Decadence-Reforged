--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Reykjavík, Iceland
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("reykjavik")
reykjavik.mapx = 340
reykjavik.mapy = 34
reykjavik.align = "left"
reykjavik.hemisphere = "north"
reykjavik.region = "europe"
reykjavik.culture = "european"
reykjavik.hidden = true

CreateBuilding("rey_kitchen", reykjavik, Kitchen)
rey_kitchen.x = 505
rey_kitchen.y = 192
rey_kitchen.layer = 900
rey_kitchen:SetCharacters(1, {"main_tedd"})

CreateBuilding("rey_market", reykjavik, Market)
rey_market.x = 274
rey_market.y = 220
rey_market.layer = 902
rey_market.inventory = { sugar, milk, cream, butter, blueberry, blackberry, raspberry, salt, honey, brandy }

CreateBuilding("rey_shop", reykjavik, Shop)
rey_shop.x = 80
rey_shop.y = 218
rey_shop.layer = 901

EmptyBuilding("rey_inn", reykjavik)
rey_inn.x = 736
rey_inn.y = 216
rey_inn.layer = 901

--
--
CreateSprite("rey_streetmask", reykjavik)
rey_streetmask.x = 400
rey_streetmask.y = 249.5
rey_streetmask.layer = 960

--ANIMATIONS
--Ice flow -Yes Bears
CreateSprite("rey_iceflow_bear", reykjavik)
rey_iceflow_bear.images = {"ports/reykjavik/rey_icebear1","ports/reykjavik/rey_icebear2"}
rey_iceflow_bear.time=60000
rey_iceflow_bear.frequency = 33 --a bit rare
rey_iceflow_bear.motion='loop'
rey_iceflow_bear.layer=964
rey_iceflow_bear.scale=1.0
rey_iceflow_bear.path= {{-150,283},{-9,283},{836,283},{825,283}}

--Ice flows -No Bears
CreateSprite("rey_iceflow1", reykjavik)
rey_iceflow1.images = {"ports/reykjavik/rey_ice1","ports/reykjavik/rey_ice2","ports/reykjavik/rey_ice3","ports/reykjavik/rey_ice4"}
rey_iceflow1.time=50000
rey_iceflow1.frequency = 75
rey_iceflow1.motion='loop'
rey_iceflow1.layer=965
rey_iceflow1.scale=1.0
rey_iceflow1.path= {{-78,285},{-9,285},{836,285},{893,285}}

CreateSprite("rey_iceflow2", reykjavik)
rey_iceflow2.images = {"ports/reykjavik/rey_ice1","ports/reykjavik/rey_ice2","ports/reykjavik/rey_ice3","ports/reykjavik/rey_ice4"}
rey_iceflow2.time=47500
rey_iceflow2.frequency = 80
rey_iceflow2.motion='loop'
rey_iceflow2.layer=966
rey_iceflow2.scale=1.0
rey_iceflow2.path= {{-178,288},{-9,288},{836,288},{900,288}}

CreateSprite("rey_iceflow3", reykjavik)
rey_iceflow3.images = {"ports/reykjavik/rey_ice1","ports/reykjavik/rey_ice2","ports/reykjavik/rey_ice3","ports/reykjavik/rey_ice4"}
rey_iceflow3.time=46000
rey_iceflow3.frequency = 85
rey_iceflow3.motion='loop'
rey_iceflow3.layer=967
rey_iceflow3.scale=1.0
rey_iceflow3.path= {{-200,291},{-9,291},{836,291},{950,291}}

CreateSprite("rey_iceflow4", reykjavik)
rey_iceflow4.images = {"ports/reykjavik/rey_ice1","ports/reykjavik/rey_ice2","ports/reykjavik/rey_ice3","ports/reykjavik/rey_ice4"}
rey_iceflow4.time=45000
rey_iceflow4.frequency = 70
rey_iceflow4.motion='loop'
rey_iceflow4.layer=968
rey_iceflow4.scale=1.0
rey_iceflow4.path= {{-150,294},{-9,294},{836,294},{825,294}}

--Star Twinkles
CreateSprite("rey_startwinkle1", reykjavik)
rey_startwinkle1.image = "ports/animations/startwinkleb.xml"
rey_startwinkle1.frequency = 100
rey_startwinkle1.x = 700
rey_startwinkle1.y = 20
rey_startwinkle1.scale = 0.4
rey_startwinkle1.layer = 700

CreateSprite("rey_startwinkle2", reykjavik)
rey_startwinkle2.image = "ports/animations/startwinkle.xml"
rey_startwinkle2.frequency = 100
rey_startwinkle2.x = 587
rey_startwinkle2.y = 32
rey_startwinkle2.scale = 0.2
rey_startwinkle2.layer = 701

CreateSprite("rey_startwinkle3", reykjavik)
rey_startwinkle3.image = "ports/animations/startwinkle.xml"
rey_startwinkle3.frequency = 100
rey_startwinkle3.x = 623
rey_startwinkle3.y = 85
rey_startwinkle3.scale = 0.2
rey_startwinkle3.layer = 702

CreateSprite("rey_startwinkle4", reykjavik)
rey_startwinkle4.image = "ports/animations/startwinkleb.xml"
rey_startwinkle4.frequency = 100
rey_startwinkle4.x = 742
rey_startwinkle4.y = 65
rey_startwinkle4.scale = 0.4
rey_startwinkle4.layer = 703

CreateSprite("rey_startwinkle5", reykjavik)
rey_startwinkle5.image = "ports/animations/startwinkle.xml"
rey_startwinkle5.frequency = 100
rey_startwinkle5.x = 697
rey_startwinkle5.y = 60
rey_startwinkle5.scale = 0.3
rey_startwinkle5.layer = 704

CreateSprite("rey_startwinkle6", reykjavik)
rey_startwinkle6.image = "ports/animations/startwinkleb.xml"
rey_startwinkle6.frequency = 100
rey_startwinkle6.x = 500
rey_startwinkle6.y = 38
rey_startwinkle6.scale = 0.4
rey_startwinkle6.layer = 705
