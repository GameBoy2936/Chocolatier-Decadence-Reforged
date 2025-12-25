--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Falkland Islands, Great Britain
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("falklands")
falklands.cadikey = "falkland_islands"
falklands.music_key = "falklands_sting"
falklands.mapx = 244
falklands.mapy = 345
falklands.hemisphere = "south"
falklands.region = "south_america"
falklands.country = "uk"
falklands.culture = "western"
falklands.hidden = true

--LOCATIONS
CreateBuilding("fal_board", falklands)
fal_board:SetCharacters(1, {"evil_kath", "fal_xxxkeep"})
fal_board.x = 656.5
fal_board.y = 178.5
fal_board.layer = 900
--
--

--NON ANIMATED SPRITES
CreateSprite("fal_boardmask", falklands)
fal_boardmask.x = 666.5
fal_boardmask.y = 201.5
fal_boardmask.layer = 910
--
--
CreateSprite("fal_backhill", falklands)
fal_backhill.x = 400
fal_backhill.y = 138.5
fal_backhill.layer = 880
--
--
CreateSprite("fal_frontsand", falklands)
fal_frontsand.x = 400
fal_frontsand.y = 456.5
fal_frontsand.layer = 930
--
-- 
--(TO BE) ANIMATED
--Penguin Groups to be randomized visible
CreateSprite("fal_penguingroup1", falklands)
fal_penguingroup1.x = 123
fal_penguingroup1.y = 381.5
fal_penguingroup1.layer = 960
fal_penguingroup1.frequency = 80
--
--
CreateSprite("fal_penguingroup2", falklands)
fal_penguingroup2.x = 331.5
fal_penguingroup2.y = 351.5
fal_penguingroup2.layer = 961
fal_penguingroup2.frequency = 70
--
--
CreateSprite("fal_penguingroup3", falklands)
fal_penguingroup3.x = 539.5
fal_penguingroup3.y = 351
fal_penguingroup3.layer = 962
fal_penguingroup3.frequency = 60
--
--
CreateSprite("fal_penguin2", falklands)
fal_penguin2.x = 319.5
fal_penguin2.y = 306.5
fal_penguin2.layer = 963
fal_penguin2.frequency = 50
--
--
CreateSprite("fal_penguin3", falklands)
fal_penguin3.x = 409.5
fal_penguin3.y = 306.5
fal_penguin3.layer = 964
fal_penguin3.frequency = 50
--
--
CreateSprite("fal_penguin1", falklands)
fal_penguin1.x = 578
fal_penguin1.y = 359.5
fal_penguin1.layer = 965
fal_penguin1.frequency = 50
--
-- --Not penguins
--Errant bear
CreateSprite("fal_iceflow_bear", falklands)
fal_iceflow_bear.images = {"ports/reykjavik/rey_icebear1","ports/reykjavik/rey_icebear2"}
fal_iceflow_bear.time=50000
fal_iceflow_bear.frequency = 10 --very rare
fal_iceflow_bear.motion='oneway'--one time
fal_iceflow_bear.random = false --comes in from off screen all the time
fal_iceflow_bear.layer=922
fal_iceflow_bear.scale=1.0
fal_iceflow_bear.path= {{825,270},{825,270},{-150,270},{-150,270}}

--Mist Layers
CreateSprite("fal_mist_near", falklands)--Go Right
fal_mist_near.image = "ports/falklands/fal_cloudfront"
fal_mist_near.layer = 890
fal_mist_near.path = { {-200,100},{-200,100},{1000,100},{1000,100} }
fal_mist_near.time = 100000
fal_mist_near.motion = "loop"		
fal_mist_near.htile = 1200			
fal_mist_near.frequency = 100

CreateSprite("fal_mist_near2", falklands)--Go Left
fal_mist_near2.image = "ports/falklands/fal_cloudfront"
fal_mist_near2.layer = 891
fal_mist_near2.path = {{800,90},{800,90},{0,90},{0,90}}
fal_mist_near2.time = 100000
fal_mist_near2.motion = "loop"		
fal_mist_near2.htile = 800			
fal_mist_near2.frequency = 100

CreateSprite("fal_mist_far", falklands)
fal_mist_far.image = "ports/douala/dou_clouds"--use douala clouds
fal_mist_far.layer = 875
fal_mist_far.path = { {0,0},{100,0},{700,0},{800,0} }
fal_mist_far.time = 63000
fal_mist_far.motion = "loop"		
fal_mist_far.htile = 800			
fal_mist_far.frequency = 100		

--
--
CreateSprite("fal_ship", falklands)
fal_ship.image = "ports/falklands/fal_ship"
fal_ship.time=57200
fal_ship.frequency = 40
fal_ship.motion= "oneway"
fal_ship.scale=1.5
fal_ship.path= {{-328,244},{-328,244},{1068,240},{1068,240}}
fal_ship.layer = 920
fal_ship.frequency = 50
--
--
