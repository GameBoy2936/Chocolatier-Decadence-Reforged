--[[---------------------------------------------------------------------------
    Chocolatier Three: Catalogue Detail View
    Copyright (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-- Global toggle for developer reveal mode.
-- If true, all locked/unmet items will be rendered as if they are unlocked.
gDevForceReveal = gDevForceReveal or false

local contents = {}
local selection = gCatalogueSelection

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function ToggleDevView()
    gDevForceReveal = not gDevForceReveal
    DebugOut("DEV", "Catalogue reveal toggled: " .. tostring(gDevForceReveal))
    FillWindow("catalogue_detail", "ui/catalogue_detail.lua")
end

-- HELPER FUNCTION FOR DYNAMIC FONT SIZING (CHARACTERS)
-- Adjusts the font size based on the length of the bio text to ensure it fits.
local function SetDynamicCharacterText(textKey)
    local text = GetReplacedString(textKey)
    if text == "#####" then text = "" end

    local function Ceil(x) return Floor(x + 0.99999) end

    -- Define font sizes and thresholds for dynamic resizing
    local font_sizes_to_check = {14, 13, 12}
    local chars_per_line_map = {
        [14] = 45, [13] = 50, [12] = 55,
    }
    local line_thresholds = {
        [14] = 11, [13] = 12, [12] = 999,
    }
    
    -- Split text by <br> tags to count lines accurately
    local segments = {}
    local current_pos = 1
    if text then
        local start_pos, end_pos = string.find(text, "<br>", current_pos, true)
        while start_pos do
            table.insert(segments, string.sub(text, current_pos, start_pos - 1))
            current_pos = end_pos + 1
            start_pos, end_pos = string.find(text, "<br>", current_pos, true)
        end
        table.insert(segments, string.sub(text, current_pos))
    end
    if table.getn(segments) == 0 then segments = { text or "" } end

    -- Find the largest font that fits
    local final_font_size = 12
    for _, current_font_size in ipairs(font_sizes_to_check) do
        local chars_per_line = chars_per_line_map[current_font_size]
        local line_threshold = line_thresholds[current_font_size]
        
        local total_lines = table.getn(segments) - 1
        for _, segment in ipairs(segments) do
            total_lines = total_lines + Ceil(string.len(segment) / chars_per_line)
        end

        if total_lines <= line_threshold then
            final_font_size = current_font_size
            break 
        end
    end
    
    local formatted_text = string.format("<font size='%d'>%s</font>", final_font_size, text)
    SetLabel("catalogue_description_text", formatted_text)
end

-- HELPER FUNCTION FOR DYNAMIC FONT SIZING (INGREDIENTS)
local function SetDynamicIngredientText(textKey)
    local text = GetReplacedString(textKey)
    if text == "#####" then text = "" end

    local function Ceil(x) return Floor(x + 0.99999) end

    local font_sizes_to_check = {16, 15, 14, 13}
    local chars_per_line_map = {
        [16] = 48, [15] = 52, [14] = 56, [13] = 60
    }
    local line_thresholds = {
        [16] = 14, [15] = 15, [14] = 16, [13] = 17
    }
    
    local segments = {}
    local current_pos = 1
    if text then
        local start_pos, end_pos = string.find(text, "<br>", current_pos, true)
        while start_pos do
            table.insert(segments, string.sub(text, current_pos, start_pos - 1))
            current_pos = end_pos + 1
            start_pos, end_pos = string.find(text, "<br>", current_pos, true)
        end
        table.insert(segments, string.sub(text, current_pos))
    end
    if table.getn(segments) == 0 then segments = { text or "" } end

    local final_font_size = 12
    for _, current_font_size in ipairs(font_sizes_to_check) do
        local chars_per_line = chars_per_line_map[current_font_size]
        local line_threshold = line_thresholds[current_font_size]
        
        local total_lines = table.getn(segments) - 1
        for _, segment in ipairs(segments) do
            total_lines = total_lines + Ceil(string.len(segment) / chars_per_line)
        end

        if total_lines <= line_threshold then
            final_font_size = current_font_size
            break 
        end
    end
    
    local formatted_text = string.format("<font size='%d'>%s</font>", final_font_size, text)
    SetLabel("catalogue_description_text", formatted_text)
end

-- HELPER FUNCTION FOR DYNAMIC FONT SIZING (PORTS)
local function SetDynamicPortText(textKey)
    local text = GetReplacedString(textKey)
    if text == "#####" then text = "" end

    local function Ceil(x) return Floor(x + 0.99999) end

    local font_sizes_to_check = {16, 14, 12}
    local chars_per_line_map = {
        [16] = 50, [14] = 58, [12] = 68,
    }
    local line_thresholds = {
        [16] = 3, [14] = 4, [12] = 999,
    }
    
    local segments = {}
    local current_pos = 1
    if text then
        local start_pos, end_pos = string.find(text, "<br>", current_pos, true)
        while start_pos do
            table.insert(segments, string.sub(text, current_pos, start_pos - 1))
            current_pos = end_pos + 1
            start_pos, end_pos = string.find(text, "<br>", current_pos, true)
        end
        table.insert(segments, string.sub(text, current_pos))
    end
    if table.getn(segments) == 0 then segments = { text or "" } end

    local final_font_size = 12
    for _, current_font_size in ipairs(font_sizes_to_check) do
        local chars_per_line = chars_per_line_map[current_font_size]
        local line_threshold = line_thresholds[current_font_size]
        
        local total_lines = table.getn(segments) - 1
        for _, segment in ipairs(segments) do
            total_lines = total_lines + Ceil(string.len(segment) / chars_per_line)
        end

        if total_lines <= line_threshold then
            final_font_size = current_font_size
            break 
        end
    end
    
    local formatted_text = string.format("<font size='%d'>%s</font>", final_font_size, text)
    SetLabel("catalogue_description_text", formatted_text)
end

-- HELPER: Converts a week number (1-52) into a descriptive date string.
local function ConvertWeekToDateString(week)
    local month_index = Floor((week - 1) / 4.33) + 1
    if month_index > 12 then month_index = 12 end
    local month_name = GetString("month_" .. month_index)

    local week_in_month_approx = Mod(week, 4)
    if week_in_month_approx == 0 then week_in_month_approx = 4 end

    if week_in_month_approx == 1 then
        return GetString("catalogue_date_early", month_name)
    elseif week_in_month_approx == 4 then
        return GetString("catalogue_date_late", month_name)
    else
        return GetString("catalogue_date_middle", month_name)
    end
end

-------------------------------------------------------------------------------
-- UI Construction Logic
-------------------------------------------------------------------------------

if gCatalogueCategory == "characters" and selection then
    local char = selection
    local charData = Player.catalogue.unlockedCharacters[char.name]
    local isMet = charData and charData.met
    local isUnlocked = charData and charData.unlocked
    local assetInfo = CharacterAssetManifest[char.name]
    
    -- UPDATED LOGIC: If gDevForceReveal is true, we force showUnlockedView to TRUE.
    local showUnlockedView = isUnlocked or gDevForceReveal
    local showMetView = (isMet and not showUnlockedView)
    
    local portrait_x = assetInfo.x_detail or assetInfo.x or 10
    local portrait_y = assetInfo.y_detail or assetInfo.y or 100
    local portrait_w = assetInfo.w_detail or assetInfo.w or 178
    local portrait_h = assetInfo.h_detail or assetInfo.h or 254
    local portrait_scale = assetInfo.scale_detail or assetInfo.scale or 1.0

    -- Define the fonts we'll use for consistency
    local sub_font = { uiFontName, 12, BlackColor }
    local sub_header_font = { labelFontName, 14, BlackColor }

    if showUnlockedView then
        -- STATE 3: FULLY UNLOCKED (or Dev Revealed)
        
        table.insert(contents, CharWindow { x = portrait_x, y = portrait_y, w = portrait_w, h = portrait_h, name = char.name, scale = portrait_scale })
        
        local nameLabel = GetString(char.name)
        
        table.insert(contents, Text { x = 24, y = 19, w = 406, h = 44, label = "#" .. nameLabel, font = { labelFontName, 22, BlackColor }, flags = kVAlignCenter + kHAlignCenter })
        table.insert(contents, Text { x = 192, y = 69, w = 248, h = 200, name = "catalogue_description_text", flags=kVAlignTop+kHAlignLeft })
        
        local function buildPreferenceString(masterList, discoveredList)
            -- If Dev Reveal is active, show everything
            if gDevForceReveal then discoveredList = masterList end
            
            if not masterList or table.getn(masterList) == 0 then return GetString("catalogue_none_discovered") end
            local displayItems = {}
            for _, key in ipairs(masterList) do
                local found = false
                if discoveredList then
                    for _, discoveredKey in ipairs(discoveredList) do
                        if discoveredKey == key then found = true; break; end
                    end
                end
                if found then table.insert(displayItems, GetString(key)) else table.insert(displayItems, GetString("catalogue_unknown_preference")) end
            end
            return table.concat(displayItems, ", ")
        end
        
        local master_likes_list = {}
        if char.likes then
            if char.likes.categories then for k,_ in pairs(char.likes.categories) do table.insert(master_likes_list, k) end end
            if char.likes.products then for k,_ in pairs(char.likes.products) do table.insert(master_likes_list, k) end end
            if char.likes.ingredients then for k,_ in pairs(char.likes.ingredients) do table.insert(master_likes_list, k) end end
        end
        table.sort(master_likes_list)
        
        local master_dislikes_list = {}
        if char.dislikes then
            if char.dislikes.categories then for k,_ in pairs(char.dislikes.categories) do table.insert(master_dislikes_list, k) end end
            if char.dislikes.products then for k,_ in pairs(char.dislikes.products) do table.insert(master_dislikes_list, k) end end
            if char.dislikes.ingredients then for k,_ in pairs(char.dislikes.ingredients) do table.insert(master_dislikes_list, k) end end
        end
        table.sort(master_dislikes_list)
        
        local likes_string = buildPreferenceString(master_likes_list, charData and charData.discovered_likes or {})
        local dislikes_string = buildPreferenceString(master_dislikes_list, charData and charData.discovered_dislikes or {})

        -- Likes Header
        table.insert(contents, Text { x = 192, y = 250, w = 238, h = 20, label = "#<b>"..GetString("catalogue_likes").."</b>", font = sub_header_font, flags = kVAlignTop + kHAlignLeft })
        -- Likes Content
        table.insert(contents, Text { x = 192, y = 250 + 14, w = 238, h = 50, label = "#" .. likes_string, font = sub_font, flags = kVAlignTop + kHAlignLeft })

        -- Dislikes Header
        table.insert(contents, Text { x = 192, y = 300, w = 238, h = 20, label = "#<b>"..GetString("catalogue_dislikes").."</b>", font = sub_header_font, flags = kVAlignTop + kHAlignLeft })
        -- Dislikes Content
        table.insert(contents, Text { x = 192, y = 300 + 14, w = 238, h = 50, label = "#" .. dislikes_string, font = sub_font, flags = kVAlignTop + kHAlignLeft })

    elseif showMetView then
        -- STATE 2: MET BUT NOT UNLOCKED
        table.insert(contents, CharWindow { x = portrait_x, y = portrait_y, w = portrait_w, h = portrait_h, name = char.name, scale = portrait_scale })
        
        table.insert(contents, Text { x = 24, y = 19, w = 406, h = 44, label = "#" .. GetString(char.name), font = { labelFontName, 22, BlackColor }, flags = kVAlignCenter + kHAlignCenter })
        table.insert(contents, Text { x = 192, y = 69, w = 238, h = 200, name = "catalogue_description_text", flags=kVAlignTop+kHAlignLeft })

        -- Likes Header
        table.insert(contents, Text { x = 192, y = 250, w = 238, h = 20, label = "#<b>"..GetString("catalogue_likes").."</b>", font = sub_header_font, flags = kVAlignTop + kHAlignLeft })
        -- Likes Content
        table.insert(contents, Text { x = 192, y = 250 + 14, w = 238, h = 50, label = "#" .. GetString("catalogue_unknown_preference"), font = sub_font, flags = kVAlignTop + kHAlignLeft })

        -- Dislikes Header
        table.insert(contents, Text { x = 192, y = 300, w = 238, h = 20, label = "#<b>"..GetString("catalogue_dislikes").."</b>", font = sub_header_font, flags = kVAlignTop + kHAlignLeft })
        -- Dislikes Content
        table.insert(contents, Text { x = 192, y = 300 + 14, w = 238, h = 50, label = "#" .. GetString("catalogue_unknown_preference"), font = sub_font, flags = kVAlignTop + kHAlignLeft })

    else
        -- STATE 1: LOCKED / UNMET
        local silhouette_container_x = assetInfo.silhouette_x or portrait_x
        local silhouette_container_y = assetInfo.silhouette_y or portrait_y
        local silhouette_container_w = assetInfo.silhouette_w or portrait_w
        local silhouette_container_h = assetInfo.silhouette_h or portrait_h
        local silhouetteDisplay
        
        if assetInfo and assetInfo.silhouette then
            silhouetteDisplay = CharWindow { name = char.name .. ".silhouette" }
        elseif assetInfo and assetInfo.mask then
            silhouetteDisplay = BitmapTint { image = "characters/" .. char.name .. ".jpg", mask = "characters/" .. char.name .. ".mask.png", tint = Color(0, 0, 0, 255) }
        elseif assetInfo and assetInfo.png then
            silhouetteDisplay = BitmapTint { image = "characters/" .. char.name .. ".png", tint = Color(0, 0, 0, 255) }
        end
        
        if silhouetteDisplay then
            table.insert(contents, Window { x = silhouette_container_x, y = silhouette_container_y, w = silhouette_container_w, h = silhouette_container_h, scale = portrait_scale, silhouetteDisplay, Bitmap { x = 0, y = 0, image = "image/catalogue_portrait_mask.png" } })
        end
        
        table.insert(contents, Text { x = 24, y = 19, w = 406, h = 44, label ="#"..GetString"catalogue_locked_title", font = { labelFontName, 22, BlackColor }, flags = kVAlignCenter + kHAlignCenter })
        table.insert(contents, Text { x = 192, y = 69, w = 238, h = 200, name = "catalogue_description_text", flags=kVAlignTop+kHAlignLeft })
    end

elseif gCatalogueCategory == "ingredients" and selection then
    local ing = selection

    if Player.catalogue.unlockedIngredients[ing.name] or gDevForceReveal then
        -- STATE 2: UNLOCKED INGREDIENT VIEW
        table.insert(contents, ing:GetAppearanceBig(35, 25))
        
        -- Localized Name
        local nameLabel = GetString(ing.name)
        
        table.insert(contents, Text { x = 105, y = 15, w = 306, h = 54, label = "#"..nameLabel, font = { labelFontName, 22, BlackColor }, flags = kVAlignCenter + kHAlignCenter })
        
        -- Column 1: Description
        table.insert(contents, Text { x = 192, y = 69, w = 238, h = 280, name = "catalogue_description_text", flags=kVAlignTop+kHAlignLeft })

        -- Column 2: Structured Data
        local data_y = 110
        local data_x = 24
        local data_w = 160
        local data_h = 18
        local data_font = { uiFontName, 14, BlackColor }
        local header_font = { labelFontName, 16, BlackColor }

        -- Category
        table.insert(contents, Text { x = data_x, y = data_y, w = data_w, h = data_h, label = "#<b>"..GetString("catalogue_category_label").."</b>", font = header_font, flags=kVAlignTop+kHAlignLeft })
        data_y = data_y + data_h
        table.insert(contents, Text { x = data_x, y = data_y, w = data_w, h = data_h, label = "#" .. GetString(ing.category), font = data_font, flags=kVAlignTop+kHAlignLeft })
        data_y = data_y + data_h * 1.5

        -- Seasonality
        local season_text
        if ing.season_start == 1 and ing.season_end == 52 then
            season_text = GetString("catalogue_season_year_round")
        else
            -- If Dev Reveal is on, show the real dates even if not discovered
            local seasonData = Player.catalogue.discoveredIngredientSeasons[ing.name] or {}
            if gDevForceReveal then seasonData = { start=true, end_=true } end
            
            local start_text = seasonData.start and ConvertWeekToDateString(ing.season_start) or GetString("catalogue_undiscovered_location")
            local end_text = seasonData.end_ and ConvertWeekToDateString(ing.season_end) or GetString("catalogue_undiscovered_location")
            season_text = GetString("catalogue_season_format", start_text, end_text)
        end
        table.insert(contents, Text { x = data_x, y = data_y, w = data_w, h = data_h, label = "#<b>" .. GetString("catalogue_season_label") .. "</b>", font = header_font, flags=kVAlignTop+kHAlignLeft })
        data_y = data_y + data_h
        table.insert(contents, Text { x = data_x, y = data_y, w = data_w, h = data_h+20, label = "#" .. season_text, font = data_font, flags=kVAlignTop+kHAlignLeft })
        data_y = data_y + data_h * 1.5

        -- Price Range
        local low = ing.price_low
        local high = ing.price_high
        local low_ns = ing.price_low_notinseason
        local high_ns = ing.price_high_notinseason
        local cost_multiplier = 1.0
        if Player.difficulty == 2 then cost_multiplier = 1.25
        elseif Player.difficulty == 3 then cost_multiplier = 1.50
        end
        if cost_multiplier > 1.0 then
            low = Floor(low * cost_multiplier)
            high = Floor(high * cost_multiplier)
            if low_ns then low_ns = Floor(low_ns * cost_multiplier) end
            if high_ns then high_ns = Floor(high_ns * cost_multiplier) end
        end
        local price_text = GetString("catalogue_price_format", Dollars(low), Dollars(high))
        if low_ns and (ing.season_start ~= 1 or ing.season_end ~= 52) then
            local out_of_season_price = GetString("catalogue_price_format", Dollars(low_ns), Dollars(high_ns))
            price_text = GetString("catalogue_price_format_seasonal", price_text, out_of_season_price)
        end
        table.insert(contents, Text { x = data_x, y = data_y, w = data_w, h = data_h, label = "#<b>" .. GetString("catalogue_price_label") .. "</b>", font = header_font, flags=kVAlignTop+kHAlignLeft })
        data_y = data_y + data_h
        table.insert(contents, Text { x = data_x, y = data_y, w = data_w, h = data_h+20, label = "#" .. price_text, font = data_font, flags=kVAlignTop+kHAlignLeft })
        data_y = data_y + data_h * 1.5
		
        -- Where to Find
        table.insert(contents, Text { x = data_x, y = data_y, w = data_w, h = data_h, label = "#<b>" .. GetString("catalogue_locations_label") .. "</b>", font = header_font, flags=kVAlignTop+kHAlignLeft })
        data_y = data_y + data_h
        
        local locations = {}
        local discoveredLocations = Player.catalogue.discoveredIngredientLocations[ing.name] or {}
        for _, port in pairs(_AllPorts) do
            if port.buildings then
                for _, building in ipairs(port.buildings) do
                    if building.inventory then
                        for _, market_ing in ipairs(building.inventory) do
                            if market_ing.name == ing.name then
                                if discoveredLocations[port.name] or gDevForceReveal then
                                    table.insert(locations, GetString(port.name))
                                else
                                    table.insert(locations, GetString("catalogue_undiscovered_location"))
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
        table.insert(contents, Text { x = data_x, y = data_y, w = data_w, h = data_h+80, label = "#" .. table.concat(locations, ", "), font = data_font, flags=kVAlignTop+kHAlignLeft })

    else
        -- STATE 1: LOCKED INGREDIENT VIEW
        table.insert(contents, BitmapTint { x=35, y=25, image="items/"..ing.name.."_big", tint=Color(0,0,0,255) })
        table.insert(contents, Text { x = 55, y = 25, w = 406, h = 44, label ="#"..GetString"catalogue_locked_title", font = { labelFontName, 22, BlackColor }, flags = kVAlignCenter + kHAlignCenter })
        table.insert(contents, Text { x = 192, y = 69, w = 238, h = 157, name = "catalogue_description_text", flags=kVAlignTop+kHAlignLeft })
    end
	
elseif gCatalogueCategory == "ports" and selection then
    local port = selection

    -- Define the offset values to perfectly align the overlay.
    local overlay_x_offset = -462
    local overlay_y_offset = -392

    -- Layer 1: Your new custom overlay
    table.insert(contents, Bitmap { 
        x = overlay_x_offset, y = overlay_y_offset, 
        w = 457, h = 384, -- The container size remains the same
        image = "image/catalogue_overlay_ports_" .. port.name .. ".png" 
    })
    
    -- Layer 2: All the text and UI elements
    
    -- Header with the Port Name
    table.insert(contents, Text { x = 24, y = 10, w = 406, h = 44, label = "#" .. GetString(port.name), font = { labelFontName, 28, BlackColor }, flags = kVAlignCenter + kHAlignCenter })
    
    -- The main description text box
    table.insert(contents, Text { x = 24, y = 60, w = 410, h = 80, name = "catalogue_description_text", flags=kVAlignTop+kHAlignLeft })

    -- --- Sub-Lists ---
    local sub_y = 150
    local sub_x = 24
    local sub_w = 195
    local sub_h = 220
    local sub_font = { uiFontName, 12, BlackColor }
    local sub_header_font = { labelFontName, 14, BlackColor }

    -- Column 1: Notable Locations & Residents
    table.insert(contents, Text { x = sub_x, y = sub_y, w = sub_w, h = 20, label = "#<b>Locations</b>", font = sub_header_font })
    local locations_text = {}
    if port.buildings then
        for _, building in ipairs(port.buildings) do
            if building.type ~= "special" then
                if Player.catalogue.discoveredBuildings[building.name] or gDevForceReveal then
                    table.insert(locations_text, GetString(building.name))
                else
                    table.insert(locations_text, GetString("catalogue_undiscovered_location"))
                end
            end
        end
    end
    table.insert(contents, Text { x = sub_x, y = sub_y + 20, w = sub_w, h = 90, label = "#" .. table.concat(locations_text, "<br>"), font = sub_font, flags=kVAlignTop+kHAlignLeft })
    
    table.insert(contents, Text { x = sub_x, y = sub_y + 120, w = sub_w, h = 20, label = "#<b>Residents</b>", font = sub_header_font })
    local residents_text = {}
    if port.buildings then
        for _, building in ipairs(port.buildings) do
            if building.type ~= "special" and building.characters and building.characters[1] and table.getn(building.characters[1]) > 0 then
                local charName = building.characters[1][1]
                if (Player.catalogue.unlockedCharacters[charName] and Player.catalogue.unlockedCharacters[charName].met) or gDevForceReveal then
                    table.insert(residents_text, GetString(charName))
                else
                    table.insert(residents_text, GetString("catalogue_undiscovered_location"))
                end
            end
        end
    end
    table.insert(contents, Text { x = sub_x, y = sub_y + 140, w = sub_w, h = 90, label = "#" .. table.concat(residents_text, "<br>"), font = sub_font, flags=kVAlignTop+kHAlignLeft })

    -- Column 2: Local Ingredients
    sub_x = 238
    table.insert(contents, Text { x = sub_x, y = sub_y, w = sub_w, h = 20, label = "#<b>Ingredients</b>", font = sub_header_font })
    local ingredients_text = {}
    if port.buildings then
        for _, building in ipairs(port.buildings) do
            if building.inventory then
                for _, ing in ipairs(building.inventory) do
                    if Player.catalogue.unlockedIngredients[ing.name] or gDevForceReveal then
                        table.insert(ingredients_text, GetString(ing.name))
                    else
                        table.insert(ingredients_text, GetString("catalogue_undiscovered_location"))
                    end
                end
            end
        end
    end
    table.insert(contents, Text { x = sub_x, y = sub_y + 20, w = sub_w, h = sub_h, label = "#" .. table.concat(ingredients_text, "<br>"), font = sub_font, flags=kVAlignTop+kHAlignLeft })

else
    -- NO SELECTION VIEW
    table.insert(contents, Text { x = 0, y = 0, w = kMax, h = kMax, label ="#"..GetString"catalogue_no_selection", flags = kVAlignCenter + kHAlignCenter })
end

-- Add the developer toggle button if dev mode is active
if CheckConfig("dev") and (gCatalogueCategory == "characters" or gCatalogueCategory == "ingredients" or gCatalogueCategory == "ports") then
    table.insert(contents, Button { 
        x = 320, y = 0, w = 150, h = 20, 
        label = "#LOCK/UNLOCK", 
        command = ToggleDevView 
    })
end

MakeDialog(contents)

QueueCommand(function()
    local description_key = "catalogue_no_selection" -- Default

    if gCatalogueCategory == "characters" and selection then
        local char = selection
        local charData = Player.catalogue.unlockedCharacters[char.name]
        local isMet = charData and charData.met
        local isUnlocked = charData and charData.unlocked
        
        -- Check Dev Reveal override
        local showUnlockedView = isUnlocked or gDevForceReveal
        local showMetView = (isMet and not showUnlockedView)

        if showUnlockedView then
            description_key = "catalogue_character_" .. char.name .. "_text"
        elseif showMetView then
            description_key = "catalogue_character_met_not_unlocked"
        else
            local locked_text_key = "catalogue_character_" .. char.name .. "_locked_text"
            if GetString(locked_text_key) ~= "#####" then
                description_key = locked_text_key
            else
                description_key = "catalogue_locked_default_desc"
            end
        end
        SetDynamicCharacterText(description_key)

    elseif gCatalogueCategory == "ingredients" and selection then
        local ing = selection
        -- Check Dev Reveal override
        if Player.catalogue.unlockedIngredients[ing.name] or gDevForceReveal then
            description_key = "catalogue_ingredient_" .. ing.name .. "_text"
        else
            description_key = "catalogue_ingredient_locked_desc"
        end
        SetDynamicIngredientText(description_key)
		
	elseif gCatalogueCategory == "ports" and selection then
        local port = selection
        -- Check Dev Reveal override
        if Player.catalogue.unlockedPorts[port.name] or gDevForceReveal then
            description_key = "catalogue_port_" .. port.name .. "_text"
        else
            description_key = "catalogue_locked_default_desc" 
        end
        SetDynamicPortText(description_key)
    end
end)