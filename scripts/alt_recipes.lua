-- custom alt recipes for using dried leaves in place of the fresh counterparts

return function(AllRecipes, AddRecipe2, Ingredient, TECH, AddRecipeToFilter, CRAFTING_FILTERS, CHARACTER_INGREDIENT)
    local function GetRecipeFilters(originalRecipeName)
        if not originalRecipeName or not AllRecipes[originalRecipeName] then
            return {"MODS"}  -- fallback if original recipe missing
        end

        local filters = {}

        for filterName, filterData in pairs(CRAFTING_FILTERS) do
            local recipeList = filterData.recipes
            if recipeList and type(recipeList) == "table" then
                for _, recipeInFilter in ipairs(recipeList) do
                    if recipeInFilter == originalRecipeName then
                        table.insert(filters, filterName)
                        break
                    end
                end
            end
        end

        if #filters == 0 then
            return {"MODS"} -- fallback if no filter found
        end

        return filters
    end

    local function SortRecipe(tab, altRecipeName, originalRecipeName)
        local FILTERS = CRAFTING_FILTERS[tab]
        if originalRecipeName == nil then
            AddRecipeToFilter(altRecipeName, tab)
        else
            table.insert(FILTERS.recipes, FILTERS.default_sort_values[originalRecipeName] + 1, altRecipeName)
            FILTERS.default_sort_values = table.invert(FILTERS.recipes)
        end
    end

    local function AddAltRecipe(originalRecipeName, altRecipeName, ingredients)
        -- build ingredient table from input passed
        local ingTable = {}
        for _, v in ipairs(ingredients) do
            table.insert(ingTable, Ingredient(v[1], v[2]))
        end

        -- grab tech dynamically from original recipe
        local tech = TECH.NONE
        if originalRecipeName and AllRecipes[originalRecipeName] then
            tech = AllRecipes[originalRecipeName].tech or TECH.NONE
        end

        -- build productData dynamically from original recipe
        local recipeData

        -- SPECIAL HANDLING for character filter recipes
        if originalRecipeName == "wendy_gravestone" or originalRecipeName == "ghostlyelixir_revive" or
                originalRecipeName == "lighter" or originalRecipeName == "wx78module_maxsanity1" then
            local original = AllRecipes[originalRecipeName]
            recipeData = {}

            for k, v in pairs(original) do
                if k ~= "name" and k ~= "ingredients" and k ~= "tech" then
                    recipeData[k] = v
                end
            end
            -- DEFAULT HANDLING for regular filter recipes
        else
            local originalRecipe = AllRecipes[originalRecipeName]
            recipeData = {
                product = originalRecipeName,
                image = originalRecipe.image or nil,
                numtogive = originalRecipe.numtogive or 1,
                hint_msg = originalRecipe.hint_msg or nil,
                actionstr = originalRecipe.actionstr or nil,
                station_tag = originalRecipe.station_tag or nil,
                nounlock = originalRecipe.nounlock or nil
            }
        end

        for k, v in pairs(recipeData) do
            if v == nil then
                recipeData[k] = nil
            end
        end

        -- grab filter dynamically from original recipe
        local tabs = GetRecipeFilters(originalRecipeName)

        AddRecipe2(altRecipeName, ingTable, tech, recipeData)
        if tabs and originalRecipeName then
            for _, tab in ipairs(tabs) do
                SortRecipe(tab, altRecipeName, originalRecipeName)
            end
        end
    end

    local function AddAltTillweedSalveRecipe(altRecipeName, tillweedIngredient, petalIngredient)
        AddAltRecipe("tillweedsalve", altRecipeName, {{tillweedIngredient, 4}, {petalIngredient, 4}, {"charcoal", 1}})
    end

    -- tillweed salve alt recipe set
    AddAltTillweedSalveRecipe("tillweedsalve_alt1", "tillweed_dried", "petals")
    AddAltTillweedSalveRecipe("tillweedsalve_alt2", "tillweed", "petals_dried")
    AddAltTillweedSalveRecipe("tillweedsalve_alt3", "tillweed_dried", "petals_dried")

    -- single alt recipes for petals
    AddAltRecipe("flowerhat", "flowerhat_alt1", {{"petals_dried", 12}})
    AddAltRecipe("grass_umbrella", "grass_umbrella_alt1", {{"twigs", 4}, {"cutgrass", 4}, {"petals_dried", 6}})
    AddAltRecipe("minifan", "minifan_alt1", {{"twigs", 3}, {"petals_dried", 1}})
    AddAltRecipe("reskin_tool", "reskin_tool_alt1", {{"twigs", 1}, {"petals_dried", 4}})
    AddAltRecipe("turf_grass", "turf_grass_alt1", {{"cutgrass", 1}, {"petals_dried", 1}})
    AddAltRecipe("lighter", "lighter_alt1", {{"rope", 1}, {"goldnugget", 1}, {"petals_dried", 3}})
    AddAltRecipe("wx78module_maxsanity1", "wx78module_maxsanity1_alt1", {{"rope", 1}, {"goldnugget", 1}, {"petals_dried", 3}})
    AddAltRecipe("giftwrap", "giftwrap_alt1", {{"papyrus", 1}, {"petals_dried", 1}})

    -- single alt recipes for dark petals
    AddAltRecipe("nightmarefuel", "nightmarefuel_alt1", {{"petals_evil_dried", 4}})
    AddAltRecipe("wendy_gravestone", "wendy_gravestone_alt1", {{"cutstone", 1}, {"petals_evil_dried", 4}})

    -- single alt recipes for foliage
    AddAltRecipe("pottedfern", "pottedfern_alt1", {{"foliage_dried", 2}, {"slurtle_shellpieces", 1}})
    AddAltRecipe("turf_sinkhole", "turf_sinkhole_alt1", {{"cutgrass", 1}, {"foliage_dried", 1}})

    -- single alt recipes for succulent
    AddAltRecipe("succulent_potted", "succulent_potted_alt1", {{"succulent_picked_dried", 2}, {"cutstone", 1}})

    -- single alt recipes for forget-me-lots
    AddAltRecipe("ghostlyelixir_revive", "ghostlyelixir_revive_alt1", {{"forgetmelots_dried", 1}, {"ghostflower", 3}})

    -- single alt recipes for kelp fronds
    AddAltRecipe("kelphat", "kelphat_alt1", {{"kelp_dried", 6}})
    AddAltRecipe("trident", "trident_alt1", {{"gnarwail_horn", 3}, {"kelp_dried", 4}, {"twigs", 2}})
    AddAltRecipe("soil_amender", "soil_amender_alt1", {{"messagebottleempty", 1}, {"kelp_dried", 1}, {"ash", 1}})
    AddAltRecipe("boat_bumper_kelp_kit", "boat_bumper_kelp_kit_alt1", {{"kelp_dried", 3}, {"cutgrass", 3}})
    AddAltRecipe("boatpatch_kelp", "boatpatch_kelp_alt1", {{"kelp_dried", 3}})

    ----- SPECIAL CASE STATION SPECIFIC RECIPE HANDLING -----

    -- sorting for alt recipes that should stay strictly in CRAFTING_STATION
    local function SortAltRecipeSpecial(altRecipeName, originalRecipeName)
        local FILTER = CRAFTING_FILTERS.CRAFTING_STATION

        if originalRecipeName == nil then
            -- Do nothing if original not found; vanilla fallback already happened
            return
        end

        -- Remove vanilla-added entry first
        for i = #FILTER.recipes, 1, -1 do
            if FILTER.recipes[i] == altRecipeName then
                table.remove(FILTER.recipes, i)
            end
        end

        -- Insert ONLY if original exists
        for i, recipe in ipairs(FILTER.recipes) do
            if recipe == originalRecipeName then
                table.insert(FILTER.recipes, i + 1, altRecipeName)
                return
            end
        end
    end

    AddRecipe2("bathbomb_alt1",
               {
                   Ingredient("moon_tree_blossom_dried", 1),
                   Ingredient("nitre", 1)
               },
               TECH.CELESTIAL_ONE,
               {
                   product = "bathbomb",
                   nounlock = true
               }
    )
    SortAltRecipeSpecial("bathbomb_alt1", "bathbomb")
    AddRecipe2("halloween_experiment_sanity_alt1",
               {
                   Ingredient("crow", 1),
                   Ingredient("petals_evil_dried", 1),
                   Ingredient(CHARACTER_INGREDIENT.SANITY, 10)
               },
               TECH.MADSCIENCE_ONE,
               {
                   product = "halloween_experiment_sanity",
                   nounlock = true,
                   manufactured = true,
                   actionstr = "MADSCIENCE",
                   image = "halloweenpotion_sanity_small.tex"
               }
    )
    SortAltRecipeSpecial("halloween_experiment_sanity_alt1", "halloween_experiment_sanity")
    AddRecipe2("halloween_experiment_moon_alt1",
               {
                   Ingredient("moonbutterflywings", 1),
                   Ingredient("moon_tree_blossom_dried", 1),
                   Ingredient(CHARACTER_INGREDIENT.SANITY, 10)
               },
               TECH.MADSCIENCE_ONE,
               {
                   product = "halloween_experiment_moon",
                   nounlock = true,
                   manufactured = true,
                   actionstr = "MADSCIENCE",
                   image = "halloweenpotion_moon.tex"
               }
    )
    SortAltRecipeSpecial("halloween_experiment_moon_alt1", "halloween_experiment_moon")

end