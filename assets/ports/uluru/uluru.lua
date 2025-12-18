--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Uluru, Australia
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("uluru")
uluru.mapx = 691
uluru.mapy = 275
uluru.popupX = 441
uluru.hemisphere="south"
uluru.region="oceania"
uluru.culture = "western"
uluru.hidden = true

--LOCATIONS
CreateBuilding("ulu_hut", uluru, Market)
ulu_hut.inventory = {lime }
ulu_hut.x = 189
ulu_hut.y = 284.5
ulu_hut.layer = 980
ulu_hut.labely = 300

-- Kowaki, Aboriginal woman
ulu_hutkeep.likes = {
    categories = { bar=true },
    ingredients = { lime=true }
}

CreateBuilding("ulu_rock", uluru)
ulu_rock.x = 564
ulu_rock.y = 168.5
ulu_rock.layer = 940
--
--
EmptyBuilding("ulu_hutright", uluru)
ulu_hutright.x = 632.5
ulu_hutright.y = 322.5
ulu_hutright.layer = 960
--
--

--NON ANIMATED SPRITES
CreateSprite("ulu_backtrees", uluru)
ulu_backtrees.x = 310
ulu_backtrees.y = 141.5
ulu_backtrees.layer = 950
--
--
CreateSprite("ulu_otherhuts", uluru)
ulu_otherhuts.x = 216.5
ulu_otherhuts.y = 296
ulu_otherhuts.layer = 970
--
--
CreateSprite("ulu_treeright", uluru)
ulu_treeright.x = 692.5
ulu_treeright.y = 239
ulu_treeright.layer = 990
--
--
--(TO BE) ANIMATED SPRITES
--Fire
CreateSprite("ulu_firepit", uluru)
ulu_firepit.image = "ports/animations/flame.xml"
ulu_firepit.frequency = 100
ulu_firepit.x = 490
ulu_firepit.y = 357
ulu_firepit.scale = 0.8
ulu_firepit.layer = 975

--Embers
CreateSprite("ulu_ember1", uluru)
ulu_ember1.image = "ports/uluru/ulu_ember.png"
ulu_ember1.frequency = 100
ulu_ember1.time=8000
ulu_ember1.x = 487
ulu_ember1.y = 361
ulu_ember1.layer = 976
ulu_ember1.scaleFar=1.0
ulu_ember1.scaleNear=0.5
ulu_ember1.speedFar=2
ulu_ember1.speedNear=1
ulu_ember1.yFar=1
ulu_ember1.yNear=600
ulu_ember1.path= {{487,361},{487,343},{486,328},{496,315},{514,314},{525,314},{542,305},{553,290},{546,275},{533,259},{522,242},{518,220},{528,192},{545,170},{570,148},{592,132},{624,125},{661,120},{707,101},{723,80},{725,50},{733,30},{759,10},{766,1},{783,-28},{807,-46},{822,-54},{845,-65}}


CreateSprite("ulu_ember2", uluru)
ulu_ember2.image = "ports/uluru/ulu_ember.png"
ulu_ember2.frequency = 100
ulu_ember2.time=8000
ulu_ember2.x = 487
ulu_ember2.y = 361
ulu_ember2.layer = 977
ulu_ember2.scaleFar=1.0
ulu_ember2.scaleNear=0.5
ulu_ember2.speedFar=2
ulu_ember2.speedNear=1
ulu_ember2.yFar=1
ulu_ember2.yNear=600
ulu_ember2.path= {{479,357},{472,338},{465,309},{472,291},{504,266},{539,263},{580,250},{614,228},{626,192},{661,154},{710,133},{751,125},{791,118},{836,112},{872,86},{856,77}}

CreateSprite("ulu_ember3", uluru)
ulu_ember3.image = "ports/uluru/ulu_ember.png"
ulu_ember3.frequency = 100
ulu_ember3.time=8000
ulu_ember3.x = 487
ulu_ember3.y = 361
ulu_ember3.layer = 978
ulu_ember3.scaleFar=1.0
ulu_ember3.scaleNear=0.5
ulu_ember3.speedFar=2
ulu_ember3.speedNear=1
ulu_ember3.yFar=1
ulu_ember3.yNear=600
ulu_ember3.path= {{498,365},{526,344},{540,319},{542,286},{556,246},{573,189},{638,147},{646,102},{589,72},{593,38},{647,7},{646,-22},{657,-59}}

CreateSprite("ulu_ember4", uluru)
ulu_ember4.image = "ports/uluru/ulu_ember"
ulu_ember4.frequency = 100
ulu_ember4.time=8000
ulu_ember4.x = 487
ulu_ember4.y = 361
ulu_ember4.layer = 979
ulu_ember4.scaleFar=1.0
ulu_ember4.scaleNear=0.5
ulu_ember4.speedFar=2
ulu_ember4.speedNear=1
ulu_ember4.yFar=1
ulu_ember4.yNear=600
ulu_ember4.path= {{490,363},{481,341},{482,310},{505,287},{513,241},{491,212},{474,190},{454,163},{451,113},{489,85},{554,60},{618,46},{659,38},{730,16},{796,-16},{832,-46}}

CreateSprite("ulu_ember5", uluru)
ulu_ember5.image = "ports/uluru/ulu_ember"
ulu_ember5.frequency = 100
ulu_ember5.time=8000
ulu_ember5.x = 487
ulu_ember5.y = 361
ulu_ember5.layer = 974
ulu_ember5.scaleFar=1.0
ulu_ember5.scaleNear=0.5
ulu_ember5.speedFar=2
ulu_ember5.speedNear=1
ulu_ember5.yFar=1
ulu_ember5.yNear=600
ulu_ember5.path= {{494,361},{485,337},{464,312},{480,297},{510,289},{533,294},{593,297},{637,273},{646,245},{620,197},{597,166},{621,140},{658,124},{706,116},{742,94},{754,65},{789,54},{837,52},{868,40}}
