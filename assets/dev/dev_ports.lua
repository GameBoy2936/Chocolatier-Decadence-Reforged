--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Ports
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

local function TogglePort(port)
	if port:IsAvailable() then
		port:Lock()
		SetLabel("dev_"..port.name, "+ ".. GetString(port.name))
	else
		port:Unlock()
		SetLabel("dev_"..port.name, "- ".. GetString(port.name))
	end
end

local function UnlockAll()
	for name,port in pairs(_AllPorts) do
		port:Unlock()
		SetLabel("dev_"..port.name, "- ".. GetString(port.name))
	end
end

-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local w = 140
local x = 0
local y = 3*h

local items = {}

local function AddItem(i)
	table.insert(items, i)
	y = y + h
	if y > 400 then
		x = x + w
		y = 3*h
	end
end

-------------------------------------------------------------------------------

for _,p in pairs(_AllPorts) do
	local name = "dev_" .. p.name
	local label
	if p:IsAvailable() then label = "#- "
	else label = "#+ "
	end
	label = label .. GetString(p.name)
	local temp = p
	AddItem (Button { x=x,y=y,w=w,h=h, name=name, label=label, command=function() TogglePort(temp) end })
end

-------------------------------------------------------------------------------

MakeDialog
{
	name="dev_ports",
	BSGWindow { x=gDialogTable.x,y=gDialogTable.y, w=w,h=h, fit=true, color={1,1,1,.8}, SetStyle(devMenuStyle),
		Button { x=0,y=0,w=w,h=h, label="#<b>CLOSE</b>", default=true, cancel=true, close=true },
		TightText { x=0,y=h,w=2*w,h=h, label="#<b>Click a port with a - to lock. Click a port with a + to unlock.</b>" },
		TightText { x=0,y=h,w=3*w,h=h },
		Button { x=x,y=2*h,w=w,h=h, label="#<b>Unlock All</b>", command=UnlockAll },
		Group(items),
	},
}