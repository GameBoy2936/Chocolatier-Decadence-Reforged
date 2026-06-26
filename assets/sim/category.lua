--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Category Class)
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
	Modified (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- A "Category" defines a group of products (e.g., "bar", "truffle", "infusion").
-- It also acts as the master template for the factory machinery required to
-- manufacture products of this type, containing minigame parameters.

Category =
{
	-- ==========================================
	-- Identity & Economics
	-- ==========================================
	name = nil,				-- Full system name (e.g., "bar")
	code = nil,				-- A unique 3-letter identifier (Legacy from Choco 2)
	
	markup = 1,				-- Base profit markup multiplier applied over raw ingredient costs
	min_ingredients = 2,	-- Minimum ingredients allowed for custom User Generated Recipes (UGRs)
	max_ingredients = 6,	-- Maximum ingredients allowed for custom UGRs
	
	-- ==========================================
	-- Factory Minigame Configuration Defaults
	-- ==========================================
	-- These govern the speed, layout, and difficulty of the factory minigame UI
	traytime = 30000,
	traypath = { {525,300},{525,225},{525,155},{525,80}, {375,80},{230,80},{80,80}, {80,220},{80,360},{80,500}, {230,500},{375,500},{525,500}, {525,430},{525,370},{525,300} },
	
	colorcount = 1,
	conveyorcount = 5,
	conveyortime = 1200,
	conveyorpath = { {0,570},{20,570},{280,570},{300,570},{300,550},{300,320},{300,300} },
	
	gunspeed = 250,
	producttime = 3000,
	productpath = { {689,300},{689,320},{689,500},{689,555} },
	
	ringspeed = 500,
	recyclertime = 20000,
	recyclerpath = { {12,153},{8,8},{567,9},{608,94},{729,338},{656,393},{525,291},{222,52},{335,382},{200,364},{73,341},{10,373},{11,153} },
	
	-- ==========================================
	-- Cross-References
	-- ==========================================
	products = nil,			-- A populated array of all Product objects belonging to this category
}

-- Metamethod for debug logging
Category.__tostring = function(t) return "{Category:" .. tostring(t.name) .. "}" end

-- Global Registries
_AllCategories = {}				-- Key-value lookup by category name
_CategoryOrder = {}				-- Sequentially ordered categories array

------------------------------------------------------------------------------
-- Creation & Instantiation
------------------------------------------------------------------------------

-- Factory method: Creates and registers a new product category
function Category:Create(t)
	if not t then
		DebugOut("ERROR", "Attempted to create a Category with a nil definition table.")
		return nil
	elseif not t.name then
		DebugOut("ERROR", "Attempted to create a Category with no name. The object will be ignored.")
		return nil
	elseif _AllCategories[t.name] then
		DebugOut("ERROR", string.format("Duplicate Category name detected: '%s'. The second instance will be ignored.", t.name))
		return nil
	else
		DebugOut("LOAD", string.format("Created product category definition: %s", t.name))
		
		-- Bind the Category class metatable
		setmetatable(t, self) 
		self.__index = self
		
		-- Register globally
		_AllCategories[t.name] = t
		table.insert(_CategoryOrder, t)
		
		t.products = {}
		
		-- By default, flag all shops globally to purchase goods from this new category
		Shop.buys[t.name] = true
	end
	
	return t
end

-- Global wrapper
function CreateCategory(t) 
	return Category:Create(t) 
end

------------------------------------------------------------------------------
-- Player Data & Recipe Trackers
------------------------------------------------------------------------------

-- Returns how many recipes of this category the player has successfully discovered/invented
function Category:KnownProductCount()
	return Player.categoryCount[self.name] or 0
end

------------------------------------------------------------------------------
-- Product Management
------------------------------------------------------------------------------

-- Wipes the product list for this category (Used mostly during profile loading/resetting for User recipes)
function Category:Clear()
	self.products = {}
end

-- Binds a finalized Product object to this category's reference list
function Category:AddProduct(t)
	table.insert(self.products, t)
end