--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Port Animation Curve Editor
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- This script serves as a visual wrapper for the C++ CurveEditor hook, allowing 
-- developers to physically map out spline paths for background port animations 
-- (like cars driving, or airplanes flying overhead) and export the coordinate math.

-- The registered animation graphics found in assets\ports\animations
local anims = { "travel_temp", "car1", "car2", "car3", "car4" }

local animIndex = table.getn(anims)
local function NextSprite()
	animIndex = Mod(animIndex, table.getn(anims)) + 1
	SetAnimSprite(anims[animIndex])
	SetLabel("file", anims[animIndex])
	DebugOut("DEV", string.format("Curve Editor: Sprite swapped to '%s'.", anims[animIndex]))
end

-------------------------------------------------------------------------------

local portName = Player.portName or "zurich"
local port = _AllPorts[portName]

local scale = 0.5
local imageX = (kScreenWidth - kGameWidth * scale) / 2
local imageY = (kScreenHeight - kGameHeight * scale) / 2

local white18 = { uiFontName, 18, WhiteColor }

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

DebugOut("DEV", string.format("Curve Editor initializing overlay on port: %s", portName))

MakeDialog
{
	BSGWindow {
		x = 0, y = 0, w = kScreenWidth, h = kScreenHeight, color = { 0.25, 0.25, 0.25, 1 },
		
		-- Master C++ Engine Hook
		CurveEditor { 
			x = 0, y = 0, w = kScreenWidth, h = kScreenHeight,
			xOffset = imageX, yOffset = imageY, scale = scale,
			
			background = "ports/" .. portName .. "/" .. portName,
			portName = portName,
			port = port,
			
			SetStyle(SliderStyle),
			Slider { x = 0, y = 1, w = 200, name = "scaleslider", scale = 0.5 },
			Slider { x = 0, y = 21, w = 200, name = "farslider", scale = 0.5 },
			Slider { x = 0, y = 41, w = 200, name = "nearslider", scale = 0.5 },
		},
		
		-- Label Text
		Text { x = 203, y = 1, w = 200, h = 20, flags = kVAlignCenter + kHAlignLeft, font = white18, label = "#display scale" },
		Text { x = 203, y = 21, w = 200, h = 20, flags = kVAlignCenter + kHAlignLeft, font = white18, label = "#far scale" },
		Text { x = 203, y = 41, w = 200, h = 20, flags = kVAlignCenter + kHAlignLeft, font = white18, label = "#near scale" },

		-- Instruction Block
		Text { x = 600, y = 0, w = kMax, h = kMax, font = white18, flags = kVAlignTop + kHAlignLeft,
			label = "#Hold A and click to add a control point.<br>Click and drag control points.<br>"
				.. "Use the sliders to zoom and set the near and far scales.<br>"
				.. "Click, enter time, and press the button to change speed.<br>"
				.. "Click the second button to select an image.<br>"
				.. "The third text field is the layer. Click, enter new layer, and press the button.<br>"
				.. "Press C to copy the sprite definition to your OS clipboard."
		},

		-- Data Fields
		TextEdit { x = 65, y = 78, w = 100, h = 20, name = "time", label = "5000", length = 6, ignore = kNumbersOnly, font = white18, flags = kVAlignCenter + kHAlignLeft },
		Text { x = 65, y = 122, w = 200, h = 20, name = "file", label = "", font = white18, flags = kVAlignCenter + kHAlignLeft },
		TextEdit { x = 65, y = 166, w = 100, h = 20, name = "layer", label = "0", length = 4, ignore = kNumbersOnly, font = white18, flags = kVAlignCenter + kHAlignLeft },
		
		AppendStyle(C3SmallRoundButtonStyle),
		Button { x = 0, y = 54, command = function() UpdateAnimTime() end },
		Button { x = 0, y = 98, command = function() NextSprite() end },
		Button { x = 0, y = 142, command = function() UpdateAnimLayer() end },
		
		Button { x = 1000, y = 1000, command = function() CloseWindow() end, cancel = true },
	},
}

NextSprite()
UpdateAnimTime()