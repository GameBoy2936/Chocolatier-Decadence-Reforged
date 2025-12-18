--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Havana, Cuba
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("havana")
havana.mapx = 195
havana.mapy = 129
havana.hemisphere="north"
havana.region="caribbean"
havana.culture = "latin"
havana.locked = true

--LOCATIONS-----------------------------------
CreateBuilding("hav_market", havana, Market)
hav_market.inventory = { sugar, rum, mint, orange, allspice, cacao, powder, cinnamon, tea, honey }
hav_market.x = 496
hav_market.y = 181
hav_market.layer = 910
--
--
CreateBuilding("hav_shop", havana, Shop)
hav_shop.x = 735.5
hav_shop.y = 227
hav_shop.layer = 950
--
--
CreateBuilding("hav_plantation", havana, Farm)
hav_plantation.x = 89.5
hav_plantation.y = 157.5
hav_plantation.layer = 880
hav_plantation.inventory = { hav_coffee }
--
--
CreateBuilding("hav_casino", havana, Casino)
hav_casino.x = 437
hav_casino.y = 149.5
hav_casino.layer = 890
--  hav_casinokeep.actions = { PlayCrates(), PlaySlots() }
-- hav_casinokeep.actions = { PlaySlots() 
--
--
CreateBuilding("hav_hotel", havana)
hav_hotel.x = 635.5
hav_hotel.y = 153
hav_hotel.layer = 920
--
--
--NON ANIMATED SPRITES-------------------------------------
CreateSprite("hav_cloudmask", havana)
hav_cloudmask.x = 372.5
hav_cloudmask.y = 123
hav_cloudmask.layer = 870
--
--
CreateSprite("hav_palm3", havana)
hav_palm3.x = 443.5
hav_palm3.y = 176.5
hav_palm3.layer = 900
--
--
CreateSprite("hav_hotelmask", havana)
hav_hotelmask.x = 599
hav_hotelmask.y = 187.5
hav_hotelmask.layer = 930
--
--
CreateSprite("hav_palms2", havana)
hav_palms2.x = 747
hav_palms2.y = 148.5
hav_palms2.layer = 940
--
--
CreateSprite("hav_bush", havana)
hav_bush.x = 764
hav_bush.y = 306
hav_bush.layer = 960
--
--
CreateSprite("hav_streetmask", havana)
hav_streetmask.x = 369
hav_streetmask.y = 202
hav_streetmask.layer = 970
--
--
CreateSprite("hav_light1", havana)
hav_light1.x = 494
hav_light1.y = 349
hav_light1.layer = 980
--
--
CreateSprite("hav_foregroundmask", havana)
hav_foregroundmask.x = 707
hav_foregroundmask.y = 200
hav_foregroundmask.layer = 991
--

--(TO BE) ANIMATED SPRITES---------------------------------
--Cars
--Back to Front
CreateSprite("hav_car1",havana)
hav_car1.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
hav_car1.time=8500
hav_car1.frequency = 100
hav_car1.motion='loop'
hav_car1.layer=965
hav_car1.scaleFar=0.01
hav_car1.scaleNear=3.0
hav_car1.speedFar=0.5
hav_car1.speedNear=3.5
hav_car1.yFar=160
hav_car1.yNear=600
hav_car1.path= {{288,181},{288,181},{337,197},{388,211},{461,233},{521,249},{568,261},{600,271},{597,293},{595,323},{589,373},{584,454},{578,527},{572,627},{566,689},{566,690}}
hav_car1.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
hav_car1.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--Front to Back
CreateSprite("hav_car2",havana)
hav_car2.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
hav_car2.time=8500
hav_car2.frequency = 100
hav_car2.motion='loop'
hav_car2.layer=966
hav_car2.scaleFar=0.01
hav_car2.scaleNear=3.0
hav_car2.speedFar=0.5
hav_car2.speedNear=3.5
hav_car2.yFar=160
hav_car2.yNear=600
hav_car2.path= {{820,715},{801,668},{774,608},{736,508},{681,365},{649,289},{620,265},{565,251},{491,231},{297,182}}
hav_car2.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
hav_car2.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--Side to Back
CreateSprite("hav_car3",havana)
hav_car3.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
hav_car3.time=8500
hav_car3.frequency = 100
hav_car3.motion='loop'
hav_car3.layer=967
hav_car3.scaleFar=0.01
hav_car3.scaleNear=3.0
hav_car3.speedFar=0.5
hav_car3.speedNear=3.5
hav_car3.yFar=160
hav_car3.yNear=600
hav_car3.path= {{884,329},{870,329},{808,331},{721,331},{679,321},{658,294},{637,272},{607,256},{554,243},{496,232},{348,196},{300,184},{288,181}}
hav_car3.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
hav_car3.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--Back to Side
CreateSprite("hav_car4",havana)
hav_car4.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
hav_car4.time=8500
hav_car4.frequency = 100
hav_car4.motion='loop'
hav_car4.layer=968
hav_car4.scaleFar=0.01
hav_car4.scaleNear=3.0
hav_car4.speedFar=0.5
hav_car4.speedNear=3.5
hav_car4.yFar=160
hav_car4.yNear=600
hav_car4.path= {{288,181},{288,181},{337,197},{388,211},{461,233},{521,249},{568,261},{590,267},{597,293},{595,323},{602,344},{662,340},{760,342},{835,339},{881,335},{931,335}}
hav_car4.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
hav_car4.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--Clouds
CreateSprite("hav_cloud1", havana)--near
hav_cloud1.layer = 860
hav_cloud1.path = { {800,100},{800,100},{0,100},{0,100} }
hav_cloud1.time = 100000
hav_cloud1.motion = "loop"		
hav_cloud1.htile = 400			
hav_cloud1.frequency = 60		

CreateSprite("hav_cloud2", havana)--far
hav_cloud2.layer = 850
hav_cloud2.path = { {800,110},{800,110},{0,110},{0,110}}
hav_cloud2.time = 190000
hav_cloud2.motion = "loop"		
hav_cloud2.htile = 400			
hav_cloud2.frequency = 80		

-- 
--Waves
CreateSprite("hav_wave1", havana)--mid
hav_wave1.image = "ports/animations/wave2.xml"
hav_wave1.frequency = 100
hav_wave1.x = 295
hav_wave1.y = 285
hav_wave1.scale = 0.6
hav_wave1.layer = 701

CreateSprite("hav_wave2", havana)--near
hav_wave2.image = "ports/animations/wave1.xml"
hav_wave2.frequency = 100
hav_wave2.x = 270
hav_wave2.y = 370
hav_wave2.scale = -2.0
hav_wave2.layer = 702

CreateSprite("hav_wave3", havana)--far
hav_wave3.image = "ports/animations/wave1.xml"
hav_wave3.frequency = 100
hav_wave3.x = 245
hav_wave3.y = 220
hav_wave3.scale = -0.6
hav_wave3.layer = 703

--Ships
CreateSprite("hav_boat1", havana)
hav_boat1.image = "ports/kona/kon_boat"--use kona fishing boat
hav_boat1.time = 10000
hav_boat1.motion = 'oneway' 
hav_boat1.layer = 866 
hav_boat1.scaleFar=0.01
hav_boat1.scaleNear=3.0
hav_boat1.speedFar=0.5
hav_boat1.speedNear=3.5
hav_boat1.yFar=160
hav_boat1.yNear=600
hav_boat1.frequency = 60
hav_boat1.path={{369,178},{333,177},{299,175},{268,173},{238,174},{215,182},{194,189},{133,205},{43,215},{-85,219}}

CreateSprite("hav_boat2", havana)
hav_boat2.image = "ports/falklands/fal_ship"--use falklands ship
hav_boat2.time = 15000
hav_boat2.motion = 'oneway' 
hav_boat2.layer = 865
hav_boat2.scaleFar=0.1
hav_boat2.scaleNear=3.0
hav_boat2.speedFar=0.5
hav_boat2.speedNear=3.5
hav_boat2.yFar=160
hav_boat2.yNear=600
hav_boat2.frequency = 30
hav_boat2.path={{-17,170},{-17,170},{463,170},{463,170}}
