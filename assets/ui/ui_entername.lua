--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Text Entry Dialog)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- Read context variables passed from the parent function
local text = gDialogTable.text
local name = gDialogTable.name
local clearinitial = false

if not name or name == "" then
	-- Creating a new player profile. 
	-- We inject a placeholder and set a flag telling the UI
	-- engine to instantly clear the text box the moment the player begins typing.
	clearinitial = true
	name = GetString("default_name")
	DebugOut("UI", "Text Entry Dialog opened in NEW PROFILE mode.")
else
	DebugOut("UI", string.format("Text Entry Dialog opened in RENAME mode for: %s", name))
end

-------------------------------------------------------------------------------
-- Validation & Exit Actions
-------------------------------------------------------------------------------

local function okFunction()
	local rawName = GetLabel("entry")

	-- Regular Expression Trimming: 
	-- ^%s* matches leading whitespace. (.-) captures the core string. %s*$ matches trailing whitespace.
	-- This strips accidental leading/trailing spaces without removing spaces between words.
	local trimmedName = string.gsub(rawName, "^%s*(.-)%s*$", "%1")
	
	if string.len(trimmedName) == 0 then
		DebugOut("UI", "Text validation failed: String is empty or contains only whitespace.")
		DisplayDialog { "ui/ui_generic.lua", text = "badname" }
		SetFocus("entry")
		
	elseif trimmedName ~= name and IsNameInUse(trimmedName) then
		DebugOut("UI", string.format("Text validation failed: The profile name '%s' is already in use.", trimmedName))
		DisplayDialog { "ui/ui_generic.lua", text = "nameinuse" }
		SetFocus("entry")
		
	else
		DebugOut("UI", string.format("Text validation successful. Returning valid string: '%s'", trimmedName))
		FadeCloseWindow("entername", trimmedName)
	end
end

local function cancelFunction()
	DebugOut("UI", "Text Entry Dialog cancelled by user.")
	FadeCloseWindow("entername", nil)
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "entername",
		x = 1000, y = kCenter, image = "image/popup_back_generic_1",
		
		SetStyle(C3DialogBodyStyle),
		Text { x = 20, y = 42, w = 459, h = 100, label = "#" .. GetString("enternameprompt"), flags = kVAlignCenter + kHAlignCenter },
		
		-- Native OS Keyboard Hook Element
		Bitmap { 
			x = kCenter, y = 142, image = "image/entername",
			TextEdit { 
				typename = "TextEdit",
				utf8 = true, 
				x = 0, y = 0, w = kMax, h = kMax, 
				name = "entry", 
				label = name,
				flags = kVAlignCenter + kHAlignCenter,
				clearinitial = clearinitial, 
				enablewindow = "ok",
				length = 30, -- Hard character limit
			},
		},

		SetStyle(C3ButtonStyle),
		Button { x = 113, y = 237, name = "ok", label = "ok", command = okFunction, default = true },
		Button { x = 256, y = 237, name = "cancel", label = "cancel", command = cancelFunction, cancel = true },
	}
}

-- Force the OS to put the typing cursor into the text box automatically
SetFocus("entry")

-- If we are in "New Player" mode using a placeholder string, disable the OK button 
-- until the user has actually typed something.
if clearinitial then 
	EnableWindow("ok", false) 
end

CenterFadeIn("entername")