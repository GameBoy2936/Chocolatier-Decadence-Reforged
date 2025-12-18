--[[---------------------------------------------------------------------------
	Chocolatier Three: Enter Name dialog
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-- local kPlayerNameIllegalChars = "!@#$%^&*()><\\\"\'[]{}|?/+=~`"

-- Initialize variables from the dialog table passed by the caller
local text = gDialogTable.text
local name = gDialogTable.name
local clearinitial = false

if not name or name == "" then
	-- This is for a new player. Set the flag to clear the default text on first keypress.
	clearinitial = true
	name = GetString("default_name")
end

if gDialogTable.name then
    DebugOut("UI", "Enter Name dialog opened in RENAME mode for: " .. gDialogTable.name)
else
    DebugOut("UI", "Enter Name dialog opened in NEW PLAYER mode.")
end

-------------------------------------------------------------------------------

local function okFunction()
	local newname = GetLabel("entry")

	local trimmedName = string.gsub(newname, "^%s*(.-)%s*$", "%1")
	
	if string.len(trimmedName) == 0 then
        DebugOut("UI", "Name validation failed: Name is empty or only contains spaces.")
		DisplayDialog { "ui/ui_generic.lua", text="badname" }
		SetFocus("entry")
	elseif trimmedName ~= name and IsNameInUse(trimmedName) then
        DebugOut("UI", "Name validation failed: Name '" .. trimmedName .. "' is already in use.")
		DisplayDialog { "ui/ui_generic.lua", text="nameinuse" }
		SetFocus("entry")
	else
        DebugOut("UI", "Name validation successful. Closing dialog and returning name: " .. trimmedName)
		FadeCloseWindow("entername", trimmedName)
	end
end

local function cancelFunction()
    DebugOut("UI", "Enter Name dialog cancelled by user.")
    FadeCloseWindow("entername", nil)
end

-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name="entername",
		x=1000,y=kCenter,image="image/popup_back_generic_1",
		
		SetStyle(C3DialogBodyStyle),
		Text { x=20,y=42,w=459,h=100, label="#"..GetString"enternameprompt", flags=kVAlignCenter+kHAlignCenter },
		
		Bitmap { x=kCenter,y=142, image="image/entername",
			TextEdit { 
                typename = "TextEdit",
                utf8 = true, 
                x=0,y=0,w=kMax,h=kMax, name="entry", label=name,
				flags=kVAlignCenter+kHAlignCenter,
				clearinitial=clearinitial, enablewindow="ok",
				length=30,
            },
		},

		SetStyle(C3ButtonStyle),
		Button { x=113,y=237, name="ok", label="ok", command=okFunction, default=true, },
		Button { x=256,y=237, name="cancel", label="cancel", command=cancelFunction, cancel=true },
	}
}

-- Set initial focus and UI state
SetFocus("entry")
if clearinitial then EnableWindow("ok", false) end
CenterFadeIn("entername")