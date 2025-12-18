--[[--------------------------------------------------------------------------
	Chocolatier Three
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]--------------------------------------------------------------------------

-- A Category is a group of products, a section of the recipe book

Category =
{
	name = nil,				-- Full name
	code = nil,				-- A unique identifier (unique 3-letter code across the Chocolatier universe)  TODO: NECESSARY?
	
	markup = 1,				-- Markup amount over total ingredient cost
	min_ingredients = 2,	-- Minimum ingredients for custom recipes
	max_ingredients = 6,	-- Maximum ingredients for custom recipes
	
	-- Factory setup defaults
	traytime = 30000,
	traypath = { {525,300},{525,225},{525,155},{525,80},  {375,80},{230,80},{80,80},  {80,220},{80,360},{80,500},  {230,500},{375,500},{525,500},  {525,430},{525,370},{525,300},  },
	colorcount = 1,
	conveyorcount = 5,
	conveyortime = 1200,
	conveyorpath = { {0,570},{20,570},{280,570},{300,570},{300,550},{300,320},{300,300}, },
	gunspeed = 250,
	producttime = 3000,
	productpath = { {689,300},{689,320},{689,500},{689,555}, },
	ringspeed = 500,
	recyclertime = 20000,
	recyclerpath = { {12,153},{8,8},{567,9},{608,94},{729,338},{656,393},{525,291},{222,52},{335,382},{200,364},{73,341},{10,373},{11,153}, },
	
	-- Cross-references
	products = nil,			-- A table of products in this category (numeric indices)
}

Category.__tostring = function(t) return "{Category:"..tostring(t.name).."}" end

_AllCategories = {}				-- Match by category name
_CategoryOrder = {}				-- Ordered categories

------------------------------------------------------------------------------
------------------------------------------------------------------------------

function Category:Create(t)
	if not t then
		DebugOut("ERROR", "Attempted to create a Category with a nil definition table.")
		return nil
	elseif not t.name then
		DebugOut("ERROR", "Attempted to create a Category with no name. The object will be ignored.")
		return nil
	elseif _AllCategories[t.name] then
		DebugOut("ERROR", "Duplicate Category name detected: '" .. t.name .. "'. The second instance will be ignored.")
		return nil
	else
        DebugOut("LOAD", "Created product category: " .. t.name)
		setmetatable(t, self) self.__index = self
		_AllCategories[t.name] = t
		table.insert(_CategoryOrder, t)
		
		t.products = {}
		
		-- By default, shops purchase all categories
		Shop.buys[t.name] = true
	end
	return t
end

function CreateCategory(t) return Category:Create(t) end

------------------------------------------------------------------------------

function Category:KnownProductCount()
	return Player.categoryCount[self.name] or 0
end

------------------------------------------------------------------------------

function Category:Clear()
	self.products = {}
end

function Category:AddProduct(t)
	table.insert(self.products, t)
end