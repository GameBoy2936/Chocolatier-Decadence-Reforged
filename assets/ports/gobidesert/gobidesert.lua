--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Gobi Desert, Mongolia
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("gobidesert")
gobidesert.cadikey = "gobi_desert"
gobidesert.music_key = "gobidesert_sting"
gobidesert.mapx = 620
gobidesert.mapy = 90
gobidesert.popupX = 370
gobidesert.hemisphere="north"
gobidesert.region="asia"
gobidesert.culture = "east_asian"
gobidesert.hidden = true

--LOCATIONS
CreateBuilding("gob_xxx", gobidesert, Market)
gob_xxx.inventory = { sugar, date, milk, fig, currant, ginger, sumac, saffron, cardamom, clove }
gob_xxx.x = 198.5
gob_xxx.y = 284
gob_xxx.layer = 990
--
--

EmptyBuilding("gob_greatwall", gobidesert)
gob_greatwall.x = 279.5
gob_greatwall.y = 189.5
gob_greatwall.layer = 960
--
--
EmptyBuilding("gob_building1", gobidesert)
gob_building1.x = 609
gob_building1.y = 243.5
gob_building1.layer = 970
--

--NON ANIMATED SPRITES
CreateSprite("gob_backmountain", gobidesert)
gob_backmountain.x = 546.5
gob_backmountain.y = 137.5
gob_backmountain.layer = 950
--
--
CreateSprite("gob_buildingmask", gobidesert)
gob_buildingmask.x = 704
gob_buildingmask.y = 314
gob_buildingmask.layer = 980
--
--

--(TO BE) ANIMATED SPRITES
--Clouds
CreateSprite("gob_clouds", gobidesert)
gob_clouds.layer = 940
gob_clouds.path = { {800,36},{800,36},{0,36},{0,36}}
gob_clouds.time = 29000
gob_clouds.motion = "loop"		
gob_clouds.htile = 800			
gob_clouds.frequency = 100		
--
--Dust Clouds
CreateSprite("gob_dustcloud1", gobidesert)
gob_dustcloud1.image = "ports/gobidesert/gob_dustcloud"
gob_dustcloud1.layer = 951 --front of mountain
gob_dustcloud1.path = { {800,180},{800,180},{0,180},{0,180} }
gob_dustcloud1.time = 6000
gob_dustcloud1.motion = "loop"		
gob_dustcloud1.htile = 800			
gob_dustcloud1.frequency = 85		

CreateSprite("gob_dustcloud2", gobidesert)
gob_dustcloud2.image = "ports/gobidesert/gob_dustcloud"
gob_dustcloud2.layer = 949 --behind mountain
gob_dustcloud2.path = { {800,150},{800,150},{0,150},{0,150}}
gob_dustcloud1.scale = 0.5
gob_dustcloud2.time = 12000
gob_dustcloud2.motion = "loop"		
gob_dustcloud2.htile = 400			
gob_dustcloud2.frequency = 80		
--
CreateSprite("gob_dustcloud3", gobidesert)
gob_dustcloud3.image = "ports/gobidesert/gob_dustcloud"
gob_dustcloud3.layer = 961 --front of wall
gob_dustcloud3.path = { {1000,220},{1000,220},{-200,220},{-200,220} }
gob_dustcloud3.scale = 1.5
gob_dustcloud3.time = 3000
gob_dustcloud3.motion = "loop"		
gob_dustcloud3.htile = 800			
gob_dustcloud3.frequency = 70		

CreateSprite("gob_dustcloud4", gobidesert)
gob_dustcloud4.image = "ports/gobidesert/gob_dustcloud"
gob_dustcloud4.layer = 995 --front of everything
gob_dustcloud4.path = { {1000,450},{1000,450},{-200,450},{-200,450} }
gob_dustcloud4.scale = 2.0
gob_dustcloud4.time = 1000
gob_dustcloud4.motion = "loop"		
gob_dustcloud4.htile = 800			
gob_dustcloud4.frequency = 60		
