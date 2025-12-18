--[[--------------------------------------------------------------------------
	Chocolatier Three
	Chocolate Minigame
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

local factory = gDialogTable.factory or zur_factory
local port = factory.port.name
local product = gDialogTable.product
local category
local recipe
local productCode
local appearance

-- For testing only
if not product then product = _AllProducts["t01"] end

if product then
	recipe = product.recipe
	productCode = product.code
	appearance = product.appearance
	category = product:GetMachinery()
end

local machine = "image/machine_1"
if category.name == "infusion" then machine = "image/machine_3"
elseif category.name == "truffle" then machine = "image/machine_4"
elseif category.name == "exotic" then machine = "image/machine_6"
end

local windowX = factory.windowX or 66
local windowY = factory.windowY or 71

------------------------------------------------------------------------------
-- Turn appearance into a table containing full paths to images

if not appearance then
	appearance = { code=product.code }
end

------------------------------------------------------------------------------
-- Gather powerup settings for this factory and this category

local recycler = factory:HasPowerup(category, "recycler")
local rainbow = factory:HasPowerup(category, "rainbow")

------------------------------------------------------------------------------

local timeColor = Color(255,173,43)

MakeDialog
{
	name="factory",
	Bitmap
	{
		image="image/factory_background", x=0,y=0,
		Bitmap { image="image/factory_windows_"..port, x=windowX,y=windowY },
		Bitmap { image="image/missed_ingredient_divot", x=593,y=111, },
		Bitmap { image="image/missed_ingredient_divot", x=599,y=75, },
		Bitmap { image="image/missed_ingredient_divot", x=617,y=48, },
		Bitmap { image="image/missed_ingredient_divot", x=645,y=29, },
--		Bitmap { image="image/missed_ingredient_divot", x=682,y=22, },
		Bitmap { image="image/missed_ingredient_divot", x=718,y=29, },
		Bitmap { image="image/missed_ingredient_divot", x=747,y=48, },
		Bitmap { image="image/missed_ingredient_divot", x=765,y=75, },
		Bitmap { image="image/missed_ingredient_divot", x=771,y=111, },

		Bitmap { name="stack", x=591,y=47, image="image/machine_stack_base", },
--		Bitmap { name="machine", x=544,y=151, image="image/machine_1", },
		Button { name="go", x=670,y=0, graphics={"image/machine_button_go_up","image/machine_button_go_down","image/machine_button_go_over"},
			label="#"..GetString"go", font={uiFontName,14,WhiteColor}, command=function() ResumeGame() end },
		Button { name="pause", x=670,y=0, graphics={"image/machine_button_stop_up","image/machine_button_stop_down","image/machine_button_stop_over"},
			label="#"..GetString"pause", font={uiFontName,14,WhiteColor}, command=function() PauseGame() end },
		ChocolateFactory
		{
			name="FactoryGame", x=kCenter,y=kCenter,w=800,h=600,
			productName=product:GetName(),
			productCode=product.code,
			machine=machine, recipe=recipe, appearance=appearance,
			countdowntime = 3000,
			gametime = 60000,
			warntime = 10000,
			
			warnOnMiss = (Player.rank <= 1 and product.code == "b01"),
			
			traytime = product.traytime or category.traytime,
			traypath = product.traypath or category.traypath,
			colorcount = product.colorcount or category.colorcount,
			conveyorcount = product.conveyorcount or category.conveyorcount,
			conveyortime = product.conveyortime or category.conveyortime,
			conveyorpath = product.conveyorpath or category.conveyorpath,
			gunspeed = product.gunspeed or category.gunspeed,
			producttime = product.producttime or category.producttime,
			productpath = product.productpath or category.productpath,
			ringspeed = product.ringspeed or category.ringspeed,
			
			-- Powerups
			recycler = recycler,
			recyclertime = product.recyclertime or category.recyclertime,
			recyclerpath = product.recyclerpath or category.recyclerpath,
			
			-- Rainbow
			rainbow = rainbow,
			
			missed = { {593+13,111+13},{599+13,75+13},{617+13,48+13},{645+13,29+13},{718+13,29+13},{747+13,48+13},{765+13,75+13},{771+13,111+13},},

			Text { x=621,y=91,w=148,h=64,flags=kVAlignTop+kHAlignCenter,label="#"..GetString"cases",font={uiFontName,20,Color(255,1,17)} },
			Text { name="score", x=621,y=50,w=148,h=148, label="0", flags=kVAlignCenter+kHAlignCenter, font={uiFontName,50,Color(255,41,77)} },
			Text { name="countdown", x=150,y=150,w=300,h=300, label="#3", font={ uiFontName, 200, RedColor }, flags=kVAlignCenter+kHAlignCenter },
		},

		Bitmap
		{
			x=kCenter,y=kCenter, image="image/popup_back_generic_1", name = "information",
			SetStyle(C3DialogBodyStyle),
			Text { x=20,y=42,w=459,h=177, label="#"..GetString"chocolate_start", flags=kVAlignCenter+kHAlignCenter },
			SetStyle(C3ButtonStyle),
			Button { x=113,y=237, name="ok", label="go", command=function() StartGame() end, default=true },
			Button { x=256,y=237, name="cancel", label="cancel", command=function() CloseWindow(nil) end, cancel=true },

			AppendStyle(C3RoundButtonStyle),
			Button { x=393,y=232, name="help", label="#?", command=function() HelpDialog("help_chocolate") end },
		},
	}
}

--SoundEvent("Stop_Music")
--SoundEvent("chocolate_making_game_intro")
EnableWindow("go", false)
EnableWindow("pause", false)
