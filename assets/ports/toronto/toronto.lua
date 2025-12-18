--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Toronto, Canada
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

CreatePort("toronto")
toronto.mapx = 212
toronto.mapy = 83
toronto.hemisphere = "north"
toronto.region = "north_america"
toronto.culture = "north_american"
toronto.locked = true

--LOCATIONS
CreateBuilding("tor_market", toronto, Market)
tor_market.inventory = { maple, whiskey, sugar, milk, cream, pecan, raspberry, blueberry, butter, cashew, espresso, honey, walnut, toffee, apple, blackberry }
tor_market.x = 457
tor_market.y = 218.5
tor_market.layer = 900

-- Abbey Gilbraith, early 20s or late 10s
tor_marketkeep.likes = {
    categories = { bar=true },
    products = { m08=true, b02=true },
    ingredients = { vanilla=true, toffee=true, blueberry=true, milk=true }
}
tor_marketkeep.dislikes = {
    ingredients = { raspberry=true, blackberry=true, mango=true },
    products = { e07=true }
}
--
--
CreateBuilding("tor_shop", toronto, Shop)
tor_shop.x = 97
tor_shop.y = 250.5
tor_shop.labely = 305
tor_shop.layer = 970
--
--
CreateBuilding("tor_factory", toronto, Factory)
tor_factory.defaultConfiguration = "m01"
tor_factory.x = 250
tor_factory.y = 160.5
tor_factory.layer = 920
tor_factory.windowX =59 
tor_factory.windowY =30
--
--

CreateBuilding("tor_office", toronto)
tor_office:SetCharacters(1, {"main_jose"})
tor_office.x = 356
tor_office.y = 131.5
tor_office.labely = 130
tor_office.layer = 880
--
--
EmptyBuilding("tor_hotel", toronto)
tor_hotel.x = 52.5
tor_hotel.y = 240.5
tor_hotel.layer = 980
tor_hotel.labely = 255
tor_hotel:SetCharacters(1, { "main_elen" })
tor_hotel.includeEmpty = true
--
--

--NON ANIMATED SPRITES
CreateSprite("tor_treeleft", toronto)
tor_treeleft.x = 482.5
tor_treeleft.y = 223.5
tor_treeleft.layer = 930
--
--
CreateSprite("tor_treeright", toronto)
tor_treeright.x = 766
tor_treeright.y = 225.5
tor_treeright.layer = 940
--
--
CreateSprite("tor_backbuildings", toronto)
tor_backbuildings.x = 415.5
tor_backbuildings.y = 137.5
tor_backbuildings.layer = 870
--
--
CreateSprite("tor_farbush", toronto)
tor_farbush.x = 578.5
tor_farbush.y = 247
tor_farbush.layer = 950
--
--
CreateSprite("tor_house1", toronto)
tor_house1.x = 141.5
tor_house1.y = 213
tor_house1.layer = 960
--
--
CreateSprite("tor_treesandlamps", toronto)
tor_treesandlamps.x = 529.5
tor_treesandlamps.y = 360.5
tor_treesandlamps.layer = 990
-- 
--(TO BE) ANIMATED SPRITES
--Cars
--L to R Distant
CreateSprite("tor_car1", toronto)
tor_car1.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
tor_car1.time=9600
tor_car1.frequency = 100
tor_car1.motion='loop'
tor_car1.layer=956
tor_car1.scaleFar=0.3
tor_car1.scaleNear=0.3
tor_car1.path= {{100,256},{100,256},{860,256},{860,256}}
tor_car1.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
tor_car1.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }
--
--R to L Distant
CreateSprite("tor_car2", toronto)
tor_car2.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
tor_car2.time=10110
tor_car2.frequency = 100
tor_car2.motion='loop'
tor_car2.layer=955
tor_car2.scaleFar=0.3
tor_car2.scaleNear=0.3
tor_car2.path= {{860,253},{860,253},{100,253},{100,253}}
tor_car2.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
tor_car2.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }
--
--L to R Distant2
CreateSprite("tor_car3", toronto)
tor_car3.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
tor_car3.time=10220
tor_car3.frequency = 100
tor_car3.motion='loop'
tor_car3.layer=957
tor_car3.scaleFar=0.3
tor_car3.scaleNear=0.3
tor_car3.path= {{100,256},{100,256},{860,256},{860,256}}
tor_car3.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
tor_car3.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }
--
--R to L Distant2
CreateSprite("tor_car4", toronto)
tor_car4.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
tor_car4.time=9800
tor_car4.frequency = 100
tor_car4.motion='loop'
tor_car4.layer=958
tor_car4.scaleFar=0.3
tor_car4.scaleNear=0.3
tor_car4.path= {{860,253},{860,253},{100,253},{100,253}}
tor_car4.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
tor_car4.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }
--
--Front to Back
CreateSprite("tor_car5",toronto)
tor_car5.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
tor_car5.time=5500
tor_car5.frequency = 100
tor_car5.motion='loop'
tor_car5.layer=969
tor_car5.scaleFar=0.1
tor_car5.scaleNear=2.0
tor_car5.speedFar=1
tor_car5.speedNear=2
tor_car5.yFar=200
tor_car5.yNear=600
tor_car5.path= {{427,709},{395,638},{345,530},{284,387},{253,313},{208,287},{172,282},{113,279},{60,279},{11,277}}
tor_car5.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
tor_car5.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

--Back to Front
CreateSprite("tor_car6",toronto)
tor_car6.images = {"ports/animations/car1","ports/animations/car2","ports/animations/car3","ports/animations/car4"}
tor_car6.time=5500
tor_car6.frequency = 100
tor_car6.motion='loop'
tor_car6.layer=959
tor_car6.scaleFar=0.1
tor_car6.scaleNear=2.0
tor_car6.speedFar=1
tor_car6.speedNear=2
tor_car6.yFar=200
tor_car6.yNear=600
tor_car6.path= {{132,253},{170,252},{206,249},{202,265},{192,291},{171,352},{147,424},{110,524},{75,622},{55,669}}
tor_car6.masks = {"ports/animations/car1_colormask","ports/animations/car2_colormask","ports/animations/car3_colormask","ports/animations/car4_colormask",}
tor_car6.tints = { Color(150,0,0,255), Color(0,150,0,255), Color(0,0,150,255),Color(150,150,0,255),Color(150,0,150,255),Color(0,150,150,255), }

CreateSprite("tor_fog", toronto)
tor_fog.x = 402
tor_fog.y = 190
tor_fog.layer = 890
tor_fog.frequency = 50 --some days are foggier
--
--
--Clouds
CreateSprite("tor_cloud1", toronto)
tor_cloud1.layer = 875
tor_cloud1.path = { {0,20},{100,20},{700,20},{800,20} }
tor_cloud1.time = 200000
tor_cloud1.motion = "loop"		
tor_cloud1.htile = 400			
tor_cloud1.frequency = 100

CreateSprite("tor_cloud2", toronto)
tor_cloud2.layer = 865
tor_cloud2.path = { {0,50},{100,50},{700,50},{800,50} }
tor_cloud2.time = 390000
tor_cloud2.motion = "loop"		
tor_cloud2.htile = 400			
tor_cloud2.frequency = 100
	
--
--Ship in Port Pulls out
--Ship Leaves
CreateSprite("tor_boat1", toronto)
tor_boat1.image = "ports/falklands/fal_ship"--use falklands ship
tor_boat1.layer = 985
tor_boat1.time=45000
tor_boat1.frequency = 100
tor_boat1.motion='oneway'
tor_boat1.scaleNear=1.0
tor_boat1.random = false
tor_boat1.path= {{500,282},{500,282},{1030,282},{1030,282}}
--
--
CreateSprite("tor_smoke", toronto)
tor_smoke.x = 312
tor_smoke.y = 37.5
tor_smoke.layer = 910
--
--
