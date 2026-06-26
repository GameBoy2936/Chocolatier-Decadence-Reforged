--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Coffee Minigame Config)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- This script serves as the configuration bridge between the Lua UI logic
-- and the hardcoded C++ 'CoffeeFactory' object that runs the Match-3 
-- ingredient sorting minigame.

local recipe
local productCode
local appearance
local product = gDialogTable.product
local category

-- Fallback for direct testing
if not product then product = _AllProducts["c01"] end

if product then
	recipe = product.recipe
	productCode = product.code
	appearance = product.appearance
	category = product:GetMachinery()
end

-- Ensures appearance is structured correctly for the C++ parser
if not appearance then
	appearance = { code = product.code }
end

local factory = gDialogTable.factory or zur_factory
local port = factory.port.name
local windowX = factory.windowX or 66
local windowY = factory.windowY or 71
local timeColor = Color(255, 173, 43)

------------------------------------------------------------------------------
-- Grid Physics Configuration
------------------------------------------------------------------------------
-- Determines if the Match-3 grid is standard (6 columns) or wide (8 columns)

local columns = product.columns or category.columns or 6
local gridx = 146
local griddx = 45

if columns == 8 then
	gridx = 103
	conveyorBelt = Bitmap { name = "belt", x = 97, y = 58, image = "image/conveyor_belt_wide" }
else
	conveyorBelt = Bitmap { name = "belt", x = 135, y = 58, image = "image/conveyor_belt_narrow" }
end

------------------------------------------------------------------------------
-- UI Construction & Engine Hook
------------------------------------------------------------------------------

MakeDialog
{
	name = "factory",
	Bitmap
	{
		image = "image/factory_background", x = 0, y = 0,
		
		-- Background Environment Map Assets
		Bitmap { image = "image/factory_windows_" .. port, x = windowX, y = windowY },
		
		-- Target Receptacle Divots (Visual only, coffee doesn't use the gun mechanics)
		Bitmap { image = "image/missed_ingredient_divot", x = 593, y = 111 },
		Bitmap { image = "image/missed_ingredient_divot", x = 599, y = 75 },
		Bitmap { image = "image/missed_ingredient_divot", x = 617, y = 48 },
		Bitmap { image = "image/missed_ingredient_divot", x = 645, y = 29 },
		Bitmap { image = "image/missed_ingredient_divot", x = 718, y = 29 },
		Bitmap { image = "image/missed_ingredient_divot", x = 747, y = 48 },
		Bitmap { image = "image/missed_ingredient_divot", x = 765, y = 75 },
		Bitmap { image = "image/missed_ingredient_divot", x = 771, y = 111 },
	
		Bitmap { name = "bg", x = 78, y = 0, image = "image/conveyor_base" },
		Bitmap { name = "stack", x = 591, y = 47, image = "image/machine_stack_base" },
		
		-- Controls
		Button { 
			name = "go", x = 670, y = 0, 
			graphics = { "image/machine_button_go_up", "image/machine_button_go_down", "image/machine_button_go_over" },
			label = "#Go", font = { uiFontName, 14, WhiteColor }, 
			command = function() ResumeGame() end 
		},
		Button { 
			name = "pause", x = 670, y = 0, 
			graphics = { "image/machine_button_stop_up", "image/machine_button_stop_down", "image/machine_button_stop_over" },
			label = "#Pause", font = { uiFontName, 14, WhiteColor }, 
			command = function() PauseGame() end 
		},
		
		conveyorBelt,
		
		-- --------------------------------------------------------------------
		-- C++ MINIGAME ENGINE COMPONENT BINDING
		-- --------------------------------------------------------------------
		CoffeeFactory
		{
			name = "FactoryGame", x = 0, y = 0, w = 800, h = 600,
			
			-- Core Data
			productName = product:GetName(),
			productCode = product.code,
			recipe = recipe, 
			appearance = appearance,
			categoryName = category.name,
			
			-- Timers (ms)
			countdowntime = 3000,
			gametime = 60000,
			warntime = 8000,
			
			-- Movement physics
			gunspeed = 250,
			gridspeed = product.gridspeed or category.gridspeed,
			
			-- Tutorial warning triggers
			warnOnMiss = (Player.rank <= 2 and product.code == "c01"),
			
			-- Grid Metrics
			gridx = gridx, gridy = 15,
			griddx = griddx, griddy = 45,
			columns = columns,
			rows = 9,
			top_hood = { 283, 29 },
			bottom_hood = { 281, 448 },
			
			matchBonus = category.matchBonus,
			
			conveyorpath = product.conveyorpath or category.conveyorpath,
			conveyorcount = product.conveyorcount or category.conveyorcount,
			conveyortime = product.conveyortime or category.conveyortime,

			productpath = product.productpath or category.productpath,
			producttime = product.producttime or category.producttime,
			productspacing = product.productspacing or category.productspacing,

			-- Refill injection parameters
			autoFillGunPos = { 300, -50 },
			autoFillRate = 50,
			autoFillCount = 20,
			
			missed = { 
				{593+13, 111+13}, {599+13, 75+13}, {617+13, 48+13}, {645+13, 29+13}, 
				{718+13, 29+13}, {747+13, 48+13}, {765+13, 75+13}, {771+13, 111+13} 
			},

			-- Status Text Overlays
			Text { x = 621, y = 91, w = 148, h = 64, flags = kVAlignTop + kHAlignCenter, label = "cases", font = { uiFontName, 20, Color(255, 1, 17) } },
			Text { name = "score", x = 621, y = 50, w = 148, h = 148, label = "0", flags = kVAlignCenter + kHAlignCenter, font = { uiFontName, 50, Color(255, 41, 77) } },
			Text { name = "countdown", x = 150, y = 90, w = 300, h = 300, label = "#3", font = { uiFontName, 200, RedColor }, flags = kVAlignCenter + kHAlignCenter },
		},

		-- Pre-Game Instruction Overlay
		Bitmap
		{
			x = kCenter, y = kCenter, image = "image/popup_back_generic_1", name = "information",
			
			SetStyle(C3DialogBodyStyle),
			Text { x = 20, y = 42, w = 459, h = 177, label = "coffee_start", flags = kVAlignCenter + kHAlignCenter },
			
			SetStyle(C3ButtonStyle),
			Button { x = 113, y = 237, name = "ok", label = "ok", command = function() SoundEvent("coffee_making_game"); StartGame() end, default = true },
			Button { x = 256, y = 237, name = "cancel", label = "cancel", command = function() CloseWindow(nil) end, cancel = true },
			
			AppendStyle(C3RoundButtonStyle),
			Button { x = 393, y = 232, name = "help", label = "#?", command = function() HelpDialog("help_coffee") end },
		},
	}
}