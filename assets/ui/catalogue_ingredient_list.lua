--[[---------------------------------------------------------------------------
    Chocolatier Three: Catalogue Ingredient List Panel
    Copyright (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- Helper function for Lua 5.0 compatible modulo
local function Mod(a, n)
    if n == 0 then return a end
    return a - (n * Floor(a / n))
end

local function SelectIngredient(ing)
    if gCatalogueSelection ~= ing then
        gCatalogueSelection = ing
        DebugOut("UI", "Catalogue selection changed to: " .. ing.name)
        
        -- Redraw both panels to update the selection highlight and the detail view
        FillWindow("catalogue_list", "ui/catalogue_ingredient_list.lua")
        FillWindow("catalogue_detail", "ui/catalogue_detail.lua")
    end
end

-------------------------------------------------------------------------------
-- Data Gathering and Sorting

-- _IngredientOrder is already sorted alphabetically, so we can use it directly.
local ingredientList = _IngredientOrder

-------------------------------------------------------------------------------
-- UI Construction

local contents = {}
local layout = {
    x_start = 1, y_start = 7,
    x_spacing = 44, y_spacing = 50,
    items_per_row = 6,
    rows_per_page = 8,
}
layout.items_per_page = layout.items_per_row * layout.rows_per_page

-- Make the layout accessible to the parent container
gCatalogueLayout = layout

local x, y = layout.x_start, layout.y_start
local items_drawn_this_page = 0

-- Build the UI for the visible page of ingredients
for i = gCatalogueTopIndex, gCatalogueTopIndex + layout.items_per_page - 1 do
    local ing = ingredientList[i]
    if ing then
        local tempIng = ing
        
        local ingredientDisplay
        -- Check the new flag to see if the catalogue page is unlocked.
        if Player.catalogue.unlockedIngredients[ing.name] then
            -- UNLOCKED: Display the full-color ingredient icon.
            ingredientDisplay = Bitmap { x = 9, y = 9, image = "items/" .. ing.name .. ".png" }
        else
            -- LOCKED: Display the icon tinted black as a silhouette.
            ingredientDisplay = BitmapTint { x = 9, y = 9, image = "items/" .. ing.name .. ".png", tint = Color(0, 0, 0, 255) }
        end

        -- Create the button with a background and the display object inside
        table.insert(contents,
            Button { x = x, y = y, w = 60, h = 66, graphics = {},
                command = function() SoundEvent("cadi/ui_click.ogg"); SelectIngredient(tempIng) end,
                
                Bitmap { x=0, y=0, image = (gCatalogueSelection == tempIng) and "image/button_recipes_selected" or "image/button_recipes_up", scale = 0.66666 },
                
                Window { x = 8, y = 8, w = 60, h = 60,
                    ingredientDisplay,
                },
            }
        )

        -- Update grid position
        items_drawn_this_page = items_drawn_this_page + 1
        x = x + layout.x_spacing
        if Mod(items_drawn_this_page, layout.items_per_row) == 0 then
            x = layout.x_start
            y = y + layout.y_spacing
        end
    end
end

-------------------------------------------------------------------------------

MakeDialog(contents)

-- Tell the parent container whether the scroll buttons should be enabled
local canScrollUp = gCatalogueTopIndex > 1
local canScrollDown = (gCatalogueTopIndex + layout.items_per_page) <= table.getn(ingredientList)
UpdateCatalogueScrollButtons(canScrollUp, canScrollDown)