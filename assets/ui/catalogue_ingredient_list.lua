--[[---------------------------------------------------------------------------
    Chocolatier Three: Decadence by Design Reforged (Ingredient List Panel)
    Copyright (c) 2025-2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- Simple Lua 5.0 compatible integer Modulo helper for grid math
local function Mod(a, n)
    if n == 0 then return a end
    return a - (n * Floor(a / n))
end

local function SelectIngredient(ing)
    if gCatalogueSelection ~= ing then
        gCatalogueSelection = ing
        DebugOut("UI", string.format("Catalogue selection changed to Ingredient: %s", ing.name))
        
        FillWindow("catalogue_list", "ui/catalogue_ingredient_list.lua")
        FillWindow("catalogue_detail", "ui/catalogue_detail.lua")
    end
end

-------------------------------------------------------------------------------
-- Data Configuration & Layout Map
-------------------------------------------------------------------------------

-- Because _IngredientOrder is sorted alphabetically on boot, we bind it natively.
local ingredientList = _IngredientOrder

local contents = {}

-- Dense 6-column grid structure to fit 48 items per page
local layout = {
    x_start = 1, y_start = 7,
    x_spacing = 44, y_spacing = 50,
    items_per_row = 6,
    rows_per_page = 8,
}
layout.items_per_page = layout.items_per_row * layout.rows_per_page
gCatalogueLayout = layout

-------------------------------------------------------------------------------
-- UI Construction & Grid Generation
-------------------------------------------------------------------------------

local x, y = layout.x_start, layout.y_start
local items_drawn_this_page = 0

for i = gCatalogueTopIndex, gCatalogueTopIndex + layout.items_per_page - 1 do
    local ing = ingredientList[i]
    if ing then
        local tempIng = ing
        local ingredientDisplay
        
        -- Check if the player has successfully purchased/discovered this raw item
        if Player.catalogue.unlockedIngredients[ing.name] then
            ingredientDisplay = Bitmap { x = 9, y = 9, image = "items/" .. ing.name .. ".png" }
        else
            ingredientDisplay = BitmapTint { x = 9, y = 9, image = "items/" .. ing.name .. ".png", tint = Color(0, 0, 0, 255) }
        end

        table.insert(contents,
            Button { 
                x = x, y = y, w = 60, h = 66, graphics = {},
                command = function() SoundEvent("cadi/ui_click.ogg"); SelectIngredient(tempIng) end,
                
                -- Dynamic highlight layer backing
                Bitmap { x = 0, y = 0, scale = 0.66666, image = (gCatalogueSelection == tempIng) and "image/button_recipes_selected" or "image/button_recipes_up" },
                Window { x = 8, y = 8, w = 60, h = 60, ingredientDisplay },
            }
        )

        -- Advance cursor bounds
        items_drawn_this_page = items_drawn_this_page + 1
        x = x + layout.x_spacing
        if Mod(items_drawn_this_page, layout.items_per_row) == 0 then
            x = layout.x_start
            y = y + layout.y_spacing
        end
    end
end

MakeDialog(contents)

local canScrollUp = gCatalogueTopIndex > 1
local canScrollDown = (gCatalogueTopIndex + layout.items_per_page) <= table.getn(ingredientList)
UpdateCatalogueScrollButtons(canScrollUp, canScrollDown)