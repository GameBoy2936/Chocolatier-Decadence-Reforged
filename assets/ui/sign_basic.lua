--[[---------------------------------------------------------------------------
	Chocolatier Three: "Basic" sign designer
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

local dialogName = "sign_basic"
local text = gDialogTable.text or "#BASIC SIGN DESIGNER: NOT YET IMPLEMENTED"

-------------------------------------------------------------------------------

local function okFunction()
	FadeCloseWindow(dialogName, "ok")
end

-------------------------------------------------------------------------------

-- TODO: Get logo graphics at runtime

local backgrounds = { "bg1", "bg2", "bg3", "bg4", "bg5", "bg6", "bg7", "bg8" }
local bgSelect = 1
for num,name in ipairs(backgrounds) do
	if name == Player.sign.background then bgSelect = num; break; end
end

local logos = { "logo1", "logo2", "logo3", "logo4", "logo5", "logo6", "logo7", "logo8", "logo9", "logo10", "logo11", "logo12" }
local logoSelect = 1
for num,name in ipairs(logos) do
	if name == Player.sign.logo then logoSelect = num; break; end
end

local fonts = { "arial.mvec" }
local fontSelect = 1
for num,name in ipairs(fonts) do
	if name == Player.sign.font then fontSelect = num; break; end
end

-------------------------------------------------------------------------------

local function bgNext()
	bgSelect = bgSelect + 1
	if bgSelect > table.getn(backgrounds) then bgSelect = 1 end
	SetBackground(backgrounds[bgSelect])
end

local function bgPrev()
	bgSelect = bgSelect - 1
	if bgSelect < 1 then bgSelect = table.getn(backgrounds) end
	SetBackground(backgrounds[bgSelect])
end

local function logoNext()
	logoSelect = logoSelect + 1
	if logoSelect > table.getn(logos) then logoSelect = 1 end
	SetLogo(logos[logoSelect])
end

local function logoPrev()
	logoSelect = logoSelect - 1
	if logoSelect < 1 then logoSelect = table.getn(logos) end
	SetLogo(logos[logoSelect])
end

local function fontNext()
	fontSelect = fontSelect + 1
	if fontSelect > table.getn(fonts) then fontSelect = 1 end
	SetFont(fonts[fontSelect])
end

local function fontPrev()
	fontSelect = fontSelect - 1
	if fontSelect < 1 then fontSelect = table.getn(fonts) end
	SetFont(fonts[fontSelect])
end

-------------------------------------------------------------------------------

local text = Player.sign.text or ""

MakeDialog
{
	Bitmap
	{
		name=dialogName,
		x=1000,y=25,image="image/dialog_large_generic",
		SetStyle(controlStyle),
		
		SignEditor { x=0,y=0,w=kMax,h=kMax, signx=175,signy=100, sign=Player.sign,

			Button { x=375,y=0, name="bgPrev", command=bgPrev, label="#BG <<", },
			Button { x=375,y=35, name="bgNext", command=bgNext, label="#BG >>", },
			Button { x=375,y=70, name="logoPrev", command=logoPrev, label="#LOGO <<", },
			Button { x=375,y=105, name="logoNext", command=logoNext, label="#LOGO >>", },
			Button { x=375,y=140, name="fontPrev", command=fontPrev, label="#FONT <<", },
			Button { x=375,y=175, name="fontNext", command=fontNext, label="#FONT >>", },

			TextEdit { x=0,y=210,w=600,h=20, name="text", label="#"..text, length=30 },
			Button { x=600,y=210, name="settext", default=true, command=function() SetText(GetLabel("text")) end },
			
	--		Text { x=0,y=0,w=kMax,h=kMax, label=text, flags=kVAlignCenter+kHAlignCenter },
			
			Button { x=kCenter,y=415, name="ok", command=okFunction, label="ok" },

			SetStyle(SliderStyle),
			Slider { x=0,y=230,w=250,name="textH" },
			Slider { x=0,y=260,w=250,name="textS" },
			Slider { x=0,y=290,w=250,name="textV" },
			Slider { x=0,y=320,w=250,name="textA" },
			Slider { x=0,y=350,w=250,name="textSize" },
			
			Slider { x=260,y=230,w=250,name="logoA" },
			Slider { x=260,y=260,w=250,name="logoR" },
			Slider { x=260,y=290,w=250,name="logoScale" },
		},
	}
}

SetFocus("settext")
CenterFadeIn(dialogName)
