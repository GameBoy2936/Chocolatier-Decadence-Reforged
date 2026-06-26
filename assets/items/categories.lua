--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Product Categories)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- This script defines the 6 primary categories of manufactured goods.
-- It also sets the specific layout, timings, and mechanics of the 
-- Factory Minigames associated with each category.

CreateCategory { 
	name = "bar", 
	factory = "chocolate",
	
	-- Economics
	machinecost = 100000,
	markup = 2,
	min_ingredients = 2,
	max_ingredients = 4,
	
	-- Minigame Variables: "traypath" defines the bezier curve coordinates 
	-- that the target receptacle follows as it moves across the screen.
	traycount = 7,
	traytime = 30000,
	traypath = { 
		{515,300}, {515,225}, {515,155}, {515,80}, {375,80}, {230,80}, {80,80}, 
		{80,220}, {80,360}, {80,500}, {230,500}, {375,500}, {515,500}, {515,430}, 
		{515,370}, {515,300} 
	},
	
	colorcount = 1,
	conveyorcount = 5,
	conveyortime = 1200,
	conveyorpath = { {0,570}, {20,570}, {280,570}, {295,570}, {295,550}, {295,320}, {295,300} },
	
	gunspeed = 250,
	producttime = 3000,
	productpath = { {696,300}, {696,320}, {696,500}, {696,544} },
	ringspeed = 500,
	
	-- Recycler Powerup path logic
	recyclertime = 5000,
	recyclerpath = { {75,50}, {75,50}, {50,50}, {50,50}, {50,100}, {50,100}, {50,50}, {50,50}, {75,50}, {75,50} },
}

CreateCategory { 
	name = "beverage", 
	factory = "coffee",
	
	-- Economics
	machinecost = 250000,
	markup = 1.44,
	min_ingredients = 3,
	max_ingredients = 4,
	
	-- Coffee Match-3 Minigame Variables
	gridspeed = 5000,
	speedup = 1.2,
	maxspeed = 8,
	
	productpath = { {696,300}, {696,320}, {696,500}, {696,544} },
	producttime = 3000,
	productspacing = 1000,
	conveyorpath = { {0,596}, {115,455}, {250,597}, {283,540} },
	conveyorcount = 5,
	conveyortime = 1200,
	
	-- Match Bonus Array: Grants extra cases for large chains in the Match-3 grid.
	-- Array Indices:[1-ingredient match, 2-ing match, 3, 4, 5, 6, 7, 8, 9, 10+]
	-- (e.g., A 5-ingredient match yields 2 bonus cases)
	matchBonus = { 0, 0, 0, 1, 2, 2, 3, 3, 4, 5 },
}

CreateCategory { 
	name = "infusion", 
	factory = "chocolate",
	
	machinecost = 300000,
	markup = 1.46,
	min_ingredients = 4,
	max_ingredients = 5,
	price = 49000,
	
	traycount = 7,
	traytime = 30000,
	traypath = { 
		{525,300}, {450,300}, {455,150}, {525,80}, {455,150}, {160,150}, {80,80}, 
		{160,150}, {160,430}, {80,500}, {160,430}, {455,430}, {525,500}, {455,430}, 
		{450,300}, {525,300} 
	},
	
	colorcount = 2,
	conveyorcount = 5,
	conveyortime = 1200,
	conveyorpath = { {0,570}, {20,570}, {280,570}, {300,570}, {300,550}, {300,320}, {300,300} },
	
	gunspeed = 250,
	producttime = 3000,
	productpath = { {696,300}, {696,320}, {696,500}, {696,544} },
	ringspeed = 500,

	recyclertime = 5000,
	recyclerpath = { {75,50}, {75,50}, {50,50}, {50,50}, {50,100}, {50,100}, {50,50}, {50,50}, {75,50}, {75,50} },
}

CreateCategory { 
	name = "truffle", 
	factory = "chocolate",
	
	machinecost = 500000,
	markup = 1.49,
	min_ingredients = 5,
	max_ingredients = 6,
	price = 85000,
	
	traycount = 7,
	traytime = 30000,
	traypath = { 
		{525,300}, {450,300}, {455,150}, {525,80}, {455,150}, {160,150}, {80,80}, 
		{160,150}, {160,430}, {80,500}, {160,430}, {455,430}, {525,500}, {455,430}, 
		{450,300}, {525,300} 
	},
	
	colorcount = 2,
	conveyorcount = 5,
	conveyortime = 1200,
	conveyorpath = { {0,570}, {20,570}, {280,570}, {300,570}, {300,550}, {300,320}, {300,300} },
	
	gunspeed = 250,
	producttime = 3000,
	productpath = { {696,300}, {696,320}, {696,500}, {696,544} },
	ringspeed = 500,

	recyclertime = 5000,
	recyclerpath = { {75,50}, {75,50}, {50,50}, {50,50}, {50,100}, {50,100}, {50,50}, {50,50}, {75,50}, {75,50} },
}

CreateCategory { 
	name = "blend", 
	factory = "coffee",
	
	machinecost = 750000,
	markup = 1.52,
	min_ingredients = 3,
	max_ingredients = 5,
	
	gridspeed = 6000,
	speedup = 1.15,
	maxspeed = 8,
	
	productpath = { {696,300}, {696,320}, {696,500}, {696,544} },
	producttime = 3000,
	productspacing = 1000,
	conveyorpath = { {0,596}, {115,455}, {250,597}, {283,540} },
	conveyorcount = 5,
	conveyortime = 1200,
	
	-- Expanded Grid Size specifically for Blends
	columns = 8,
	
	matchBonus = { 0, 0, 0, 1, 2, 2, 3, 3, 4, 5 },
}

CreateCategory { 
	name = "exotic", 
	factory = "chocolate",
	
	machinecost = 1000000,
	markup = 1.55,
	min_ingredients = 5,
	max_ingredients = 6,
	price = 1350000,
	
	traycount = 7,
	traytime = 30000,
	traypath = { 
		{525,300}, {525,150}, {450,75}, {300,75}, {150,75}, {75,150}, {75,300}, 
		{75,450}, {150,525}, {300,525}, {450,525}, {525,450}, {525,300} 
	},
	
	colorcount = 3,
	conveyorcount = 5,
	conveyortime = 1200,
	conveyorpath = { {0,570}, {20,570}, {280,570}, {300,570}, {300,550}, {300,320}, {300,300} },
	
	gunspeed = 250,
	producttime = 3000,
	productpath = { {696,300}, {696,320}, {696,500}, {696,544} },
	ringspeed = 500,

	recyclertime = 5000,
	recyclerpath = { {75,50}, {75,50}, {50,50}, {50,50}, {50,100}, {50,100}, {50,50}, {50,50}, {75,50}, {75,50} },
}