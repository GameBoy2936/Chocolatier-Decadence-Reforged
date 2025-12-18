--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Quest Variables
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------

local function ChangeVariable(varName)
    -- MODIFIED: This now calls our new, polished dialog
	DisplayDialog { 
        "dev/dev_enter_amount.lua", 
        prompt = "Enter new value for '"..varName.."':",
        initialValue = tostring(Player.questVariables[varName] or 0),
        onOk = function(value)
            if value == 0 then value = nil end
	        Player.questVariables[varName] = value
        end
    }

    -- This part remains the same, it updates the label after the dialog closes
	local value = Player.questVariables[varName] or 0
	local label = varName..":"..tostring(value)
	SetLabel("dev_"..varName, label)
end

-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local w = 150
local x = 0
local y = 2*h

local items = {}

local function AddItem(i)
	table.insert(items, i)
	y = y + h
	if y > 400 then
		x = x + w
		y = h
	end
end

for _,name in ipairs(_AllVariableNames) do
	local value = Player.questVariables[name] or 0
	local label = "#"..name..": <b>"..tostring(value).."</b>"
	local temp = name
	AddItem (Button { x=x,y=y,w=w,h=h, name="dev_"..name, label=label, command=function() ChangeVariable(temp) end })
end

-------------------------------------------------------------------------------

MakeDialog
{
	name="dev_vars",
	BSGWindow { x=gDialogTable.x,y=gDialogTable.y, w=w,h=h, fit=true, color={1,1,1,.8}, SetStyle(devMenuStyle),
		Button { x=0,y=0,w=w,h=h, label="#<b>CLOSE</b>", default=true, cancel=true, close=true },
		TightText { x=0,y=h,w=2*w,h=h, label="#<b>Click a variable to change its value.</b>" },
		TightText { x=0,y=h,w=3*w,h=h },
		Group(items),
	},
}