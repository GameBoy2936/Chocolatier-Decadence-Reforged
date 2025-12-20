--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Xunantunich, Belize
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("belize")
belize.mapx = 179
belize.mapy = 146
belize.align = "left"
belize.hemisphere="north"
belize.region="caribbean"
belize.culture = "latin"
belize.hidden = true

--LOCATIONS
EmptyBuilding("bel_ruins", belize)
bel_ruins.x = 232
bel_ruins.y = 226.5
bel_ruins.layer = 970
--
--
CreateBuilding("bel_hut", belize, Market)
bel_hut.inventory = {sugar, bel_cacao, hibiscus }
bel_hut.x = 697
bel_hut.y = 311
bel_hut.layer = 950
--
--

--NON ANIMATED SPRITES
--
CreateSprite("bel_treehill", belize)
bel_treehill.x = 665.5
bel_treehill.y = 226
bel_treehill.layer = 930
--
--
CreateSprite("bel_treefront", belize)
bel_treefront.x = 521.5
bel_treefront.y = 475.5
bel_treefront.layer = 975
--
--
CreateSprite("bel_forruins", belize)
bel_forruins.x = 156
bel_forruins.y = 477
bel_forruins.layer = 990
--
--
CreateSprite("bel_backhill", belize)
bel_backhill.x = 458.5
bel_backhill.y = 164.5
bel_backhill.layer = 900
--
--
CreateSprite("bel_backtrees", belize)
bel_backtrees.x = 555
bel_backtrees.y = 208
bel_backtrees.layer = 920
--
--
CreateSprite("bel_farhuts", belize)
bel_farhuts.x = 542.5
bel_farhuts.y = 281.5
bel_farhuts.layer = 940
--
--
CreateSprite("bel_treeruinmask", belize)
bel_treeruinmask.x = 99.5
bel_treeruinmask.y = 311
bel_treeruinmask.layer = 980
--

--(TO BE) ANIMATED SPRITES

--Mist Layers
CreateSprite("bel_mist_near", belize)
bel_mist_near.image = "ports/bogota/bog_mist"--use bogota mist
bel_mist_near.layer = 910
bel_mist_near.path = { {-200,200},{-200,200},{1000,200},{1000,200} }
bel_mist_near.time = 80000
bel_mist_near.motion = "loop"		
bel_mist_near.htile = 1200			
bel_mist_near.frequency = 100

CreateSprite("bel_mist_far", belize)
bel_mist_far.image = "ports/bogota/bog_mist" --use bogota mist
bel_mist_far.layer = 895
bel_mist_far.path = { {-200,130},{-200,130},{1000,130},{1000,130} }
bel_mist_far.time = 130000
bel_mist_far.motion = "loop"		
bel_mist_far.htile = 1200			
bel_mist_far.frequency = 100
--
--
--Parting Mist Layers
CreateSprite("bel_partingmist_go_left", belize)
bel_partingmist_go_left.image = "ports/belize/bel_partingmists"
bel_partingmist_go_left.layer = 971
bel_partingmist_go_left.path = { {300,300},{300,300},{-400,300},{-400,300} }
bel_partingmist_go_left.time = 4000
bel_partingmist_go_left.motion = "oneway"--do it once
bel_partingmist_go_left.random = false--always start from beginning of path					
bel_partingmist_go_left.frequency = 100

CreateSprite("bel_partingmist_go_right", belize)
bel_partingmist_go_right.image = "ports/belize/bel_partingmists"
bel_partingmist_go_right.layer = 972
bel_partingmist_go_right.path = { {500,320},{500,320},{1200,320},{1200,320} }
bel_partingmist_go_right.time = 4000
bel_partingmist_go_right.motion = "oneway"--do it once
bel_partingmist_go_right.random = false--always start from beginning of path					
bel_partingmist_go_right.frequency = 100

