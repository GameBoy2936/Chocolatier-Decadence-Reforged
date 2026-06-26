--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Dev Port Controller)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- Track the active port selection across window refresh operations
gDevSelectedPort = gDevSelectedPort or nil

-------------------------------------------------------------------------------
-- Logic Handlers
-------------------------------------------------------------------------------

local function RefreshPanel()
	CloseWindow()
	QueueCommand(function() DisplayDialog { "dev/dev_ports.lua", x = gDialogTable.x, y = gDialogTable.y } end)
end

local function SelectPort(port)
	if gDevSelectedPort == port then
		gDevSelectedPort = nil
		DebugOut("DEV", string.format("Port de-selected: %s", port.name))
	else
		gDevSelectedPort = port
		DebugOut("DEV", string.format("Port selected: %s", port.name))
	end
	RefreshPanel()
end

local function ToggleLock()
	if not gDevSelectedPort then return end
	local port = gDevSelectedPort
	
	if port:IsAvailable() then
		port:Lock()
		DebugOut("DEV", string.format("Admin Action: Locked access to port '%s'.", port.name))
	else
		port:Unlock()
		DebugOut("DEV", string.format("Admin Action: Unlocked access to port '%s'.", port.name))
	end
	RefreshPanel()
end

local function ToggleHidden()
	if not gDevSelectedPort then return end
	local port = gDevSelectedPort
	
	-- Manipulate the literal state string to force Map View concealment logic
	local status = Player.portsAvailable[port.name]
	
	if status == "hidden" then
		-- If currently hidden, upgrade it to "locked" (Visible silhouette on map, but inaccessible)
		Player.portsAvailable[port.name] = "locked"
		DebugOut("DEV", string.format("Admin Action: Revealed port on map (Set to Locked): %s", port.name))
	else
		-- Hide it entirely
		Player.portsAvailable[port.name] = "hidden"
		DebugOut("DEV", string.format("Admin Action: Hidden port from map: %s", port.name))
	end
	RefreshPanel()
end

-- Automatically forces a load transition to the selected port.
local function TeleportToPort()
	if not gDevSelectedPort then return end
	local port = gDevSelectedPort
	
	DebugOut("DEV", string.format("Admin Action: Initiating instant teleportation to '%s'.", port.name))
	
	-- Force unlock the port first, otherwise the interior logic hooks might crash
	if not port:IsAvailable() then
		port:Unlock()
	end
	
	Player:SetPort(port.name)
	
	-- -----------------------------------------------------
	-- SAFE TELEPORT SEQUENCE:
	-- 1. Close this dialog overlay
	CloseWindow()
	
	-- 2. Queue the rest of the transition for the next logical frame
	QueueCommand(function() 
		-- 3. Force close the global Dev Menu toolbar. 
		-- We must do this because dev_menu is a modal sitting on top of the game view.
		-- If we don't pop it, SwapToModal will swap the toolbar instead of the actual game view.
		PopModal("dev_menu")
		
		-- 4. Release the ledger to prevent UI conflicts
		ReleaseLedger()
		
		-- 5. Trigger the environmental swap and transition
		SwapToModal("ui/portview.lua")
		
		-- 6. Trigger the ambient sound for the new destination
		SoundEvent(port.cadikey)
	end)
end

local function UnlockAll()
	DebugOut("DEV", "Admin Action: Force unlocked ALL ports universally.")
	for name, port in pairs(_AllPorts) do
		port:Unlock()
	end
	RefreshPanel()
end

-------------------------------------------------------------------------------
-- UI Construction & Grid Generation
-------------------------------------------------------------------------------

local h = devMenuStyle.font[2]
local w = 150	-- Action Sidebar width
local col_w = 140 -- Grid Item width
local x_start = w + 10 
local y_start = h + 10
local y_max = 550

local items = {}

-- 1. Build Action Toolbar (Left-Hand Column)
local actions = {}
local actionY = y_start

table.insert(actions, Button { x = 0, y = actionY, w = w, h = h, label = "#<b>Teleport Here</b>", command = TeleportToPort })
actionY = actionY + h + 5

table.insert(actions, Button { x = 0, y = actionY, w = w, h = h, label = "#<b>Toggle Lock</b>", command = ToggleLock })
actionY = actionY + h + 5

table.insert(actions, Button { x = 0, y = actionY, w = w, h = h, label = "#<b>Toggle Hidden</b>", command = ToggleHidden })
actionY = actionY + h + 20

table.insert(actions, Button { x = 0, y = actionY, w = w, h = h, label = "#Unlock ALL", command = UnlockAll })

-- 2. Build Port Grid (Sort Alphabetically)
local sortedPorts = {}
for _, p in pairs(_AllPorts) do table.insert(sortedPorts, p) end
table.sort(sortedPorts, function(a, b) return a.name < b.name end)

local x = x_start
local y = y_start

for _, p in ipairs(sortedPorts) do
	if y > y_max then
		x = x + col_w
		y = y_start
	end
	
	local temp = p
	local labelColor = "000000" -- Black (Default Locked)
	local statusText = ""
	
	-- Render UI tag based on internal progression state
	local status = Player.portsAvailable[p.name]
	
	if status == "hidden" then
		labelColor = "999999" -- Gray
		statusText = " (HIDDEN)"
	elseif status == "locked" then
		labelColor = "D82C2C" -- Red
		statusText = " (LOCKED)"
	elseif status == "new" or status == "open" then
		labelColor = "3A8E1D" -- Green
		statusText = " (OPEN)"
	elseif status == "factory" or status == "factory_stall" then
		labelColor = "C96C3E" -- Orange
		statusText = " (OWNED)"
	end
	
	-- Render explicit blue highlight target if this is the active selection
	if gDevSelectedPort == p then
		labelColor = "0000FF" 
		statusText = " <"
	end
	
	local label = string.format("#<font color='%s'>%s<font size='10'>%s</font></font>", labelColor, GetString(p.name), statusText)
	
	table.insert(items, Button { x = x, y = y, w = col_w, h = h, label = label, command = function() SelectPort(temp) end })
	y = y + h
end

MakeDialog
{
	name = "dev_ports",
	BSGWindow { 
		x = gDialogTable.x, y = gDialogTable.y, w = 800, h = 600, fit = true, color = { 1, 1, 1, 0.8 }, SetStyle(devMenuStyle),
		
		Button { x = 0, y = 0, w = w, h = h, label = "#<b>CLOSE</b>", default = true, cancel = true, close = true },
		TightText { x = x_start, y = 0, w = 400, h = h, label = "#<b>Select a port to manage:</b>" },
		
		Group(items),
		
		-- Container for the conditional action sidebar
		Window { 
			x = 0, y = 0, w = kMax, h = kMax, 
			Group(actions)
		},
	},
}

-- Disable target-specific actions if no port is selected yet
if not gDevSelectedPort then
	EnableWindow("Teleport Here", false)
	EnableWindow("Toggle Lock", false)
	EnableWindow("Toggle Hidden", false)
end