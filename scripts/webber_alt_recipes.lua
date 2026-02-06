-- custom alt recipes for webber

return function(AddRecipe2, Ingredient, TECH, AddRecipeToFilter, CRAFTING_FILTERS, AddPrefabPostInit)
    local function SortRecipe(tab, altRecipeName, originalRecipeName)
        local FILTERS = CRAFTING_FILTERS[tab]
        if originalRecipeName == nil then
            AddRecipeToFilter(altRecipeName, tab)
        else
            table.insert(FILTERS.recipes, FILTERS.default_sort_values[originalRecipeName] + 1, altRecipeName)
            FILTERS.default_sort_values = table.invert(FILTERS.recipes)
        end
    end

    AddRecipe2("webber_giftwrap",
               {
                   Ingredient("petals", 1),
                   Ingredient("silk", 3)
               },
               TECH.NONE,
               {
                   product = "giftwrap",
                   numtogive = 1,
                   builder_tag = "spiderwhisperer"
               }
    )
    SortRecipe("CHARACTER", "webber_giftwrap", "spider_repellent")

    local function AddBulkMutatorRecipe(originalRecipeName, altRecipeName, mutator, mutatorCount, bulkMultiplier)
        AddRecipe2(altRecipeName,
                   {
                       Ingredient("monstermeat", 2 * bulkMultiplier),
                       Ingredient("silk", 1 * bulkMultiplier),
                       Ingredient(mutator, mutatorCount * bulkMultiplier)
                   },
                   TECH.SPIDERCRAFT_ONE,
                   {
                       product = originalRecipeName,
                       numtogive = bulkMultiplier,
                       builder_tag = "spiderwhisperer"
                   }
        )
        SortRecipe("CHARACTER", altRecipeName, originalRecipeName)
    end

    local bulkMultiplier = GetModConfigData("webber_bulk_count", "Map Tweak Utilities") or 10

    -- AddBulkMutatorRecipe(originalRecipeName, altRecipeName, mutator, mutatorCount, bulkMultiplier)
    AddBulkMutatorRecipe("mutator_warrior", "mutator_warrior_bulk", "pigskin", 1, bulkMultiplier)
    AddBulkMutatorRecipe("mutator_dropper", "mutator_dropper_bulk", "manrabbit_tail", 1, bulkMultiplier)
    AddBulkMutatorRecipe("mutator_hider", "mutator_hider_bulk", "cutstone", 2, bulkMultiplier)
    AddBulkMutatorRecipe("mutator_spitter", "mutator_spitter_bulk", "nitre", 4, bulkMultiplier)
    AddBulkMutatorRecipe("mutator_moon", "mutator_moon_bulk", "moonglass", 2, bulkMultiplier)
    AddBulkMutatorRecipe("mutator_healer", "mutator_healer_bulk", "honey", 2, bulkMultiplier)
    AddBulkMutatorRecipe("mutator_water", "mutator_water_bulk", "fig", 2, bulkMultiplier)

    AddPrefabPostInit("webber", function(inst)
        local original_to_bulk = {
            mutator_warrior   = "mutator_warrior_bulk",
            mutator_dropper   = "mutator_dropper_bulk",
            mutator_hider     = "mutator_hider_bulk",
            mutator_spitter   = "mutator_spitter_bulk",
            mutator_moon      = "mutator_moon_bulk",
            mutator_healer    = "mutator_healer_bulk",
            mutator_water     = "mutator_water_bulk",
        }

        -- Listener for future recipe unlocks
        local function OnLearnRecipe(inst, data)
            if data and data.recipe then
                local bulk_recipe = original_to_bulk[data.recipe]
                inst:DoTaskInTime(0, function()
                    if inst.components.builder then
                        inst.components.builder:UnlockRecipe(bulk_recipe)
                    end
                end)
            end
        end

        inst:ListenForEvent("unlockrecipe", OnLearnRecipe)

        -- Retrofit: once builder has loaded its known recipes
        inst:DoTaskInTime(0, function()
            if inst.components.builder then
                for orig, bulk in pairs(original_to_bulk) do
                    if inst.components.builder:KnowsRecipe(orig) then
                        inst.components.builder:UnlockRecipe(bulk)
                    end
                end
            end
        end)
    end)
end