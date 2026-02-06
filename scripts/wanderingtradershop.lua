-- custom alt trades for wandering trader

return function(AddRecipe2, Ingredient, TECH, AddPrefabPostInit)
    local function AddTrades(tradeName, itemWanted, itemWantedAmount, itemOffered, itemOfferedAmount)
        AddRecipe2(tradeName,
                   {
                       Ingredient(itemWanted, 1 * itemWantedAmount)
                   },
                   TECH.LOST,
                   {
                       limitedamount = true,
                       nounlock = true,
                       actionstr = "WANDERINGTRADERSHOP",
                       sg_state = "give",
                       product = itemOffered,
                       numtogive = itemOfferedAmount,
                       description = tradeName,
                   },
                   {"CRAFTING_STATION"}
        )
    end

    AddTrades("wanderingtradershop_marbles", "goldnugget", 4, "trinket_1", 1)
    AddTrades("wanderingtradershop_bedroll_straw", "ash", 2, "bedroll_straw", 1)
    AddTrades("wanderingtradershop_dug_sapling", "ash", 4, "dug_sapling", 1)
    AddTrades("wanderingtradershop_dug_grass", "ash", 4, "dug_grass", 1)
    AddTrades("wanderingtradershop_dug_berrybush", "ash", 4, "dug_berrybush", 1)
    AddTrades("wanderingtradershop_pinecone", "ash", 4, "pinecone", 1)
    AddTrades("wanderingtradershop_acorn", "ash", 4, "acorn", 1)
    AddTrades("wanderingtradershop_trailmix", "ash", 2, "trailmix", 1)

    -- Add melty marbles to the wandering trader's ALWAYS table
    local OldRerollWares
    local function RerollWares(inst, ...)
        if math.random() < 0.25 then
            inst:AddWares(inst.WARES.MARBLES[1])
        end

        if math.random() < 0.5 then
            inst:AddWares(inst.WARES.CAMPING[1])
        end

        inst:AddWares(inst.WARES.EXTRA[1])

        return OldRerollWares(inst, ...)
    end

    AddPrefabPostInit("wanderingtrader", function(inst)
        if not TheWorld.ismastersim then
            return
        end

        if inst.WARES then
            inst.WARES.MARBLES = {
                {
                    ["marbles"] = {recipe = "wanderingtradershop_marbles", min = 1, max = 40, limit = 255},
                }
            }
            inst.WARES.CAMPING = {
                {
                    ["bedroll_straw"] = {recipe = "wanderingtradershop_bedroll_straw", min = 1, max = 1, limit = 255},
                }
            }
            inst.WARES.EXTRA = {
                {
                    ["acorn"] = {recipe = "wanderingtradershop_acorn", min = 1, max = 9, limit = 255},
                },
                {
                    ["pinecone"] = {recipe = "wanderingtradershop_pinecone", min = 1, max = 9, limit = 255},
                },
                {
                    ["dug_grass"] = {recipe = "wanderingtradershop_dug_grass", min = 1, max = 9, limit = 255},
                },
                {
                    ["dug_sapling"] = {recipe = "wanderingtradershop_dug_sapling", min = 1, max = 9, limit = 255},
                },
                {
                    ["dug_berrybush"] = {recipe = "wanderingtradershop_dug_berrybush", min = 1, max = 9, limit = 255},
                },
                {
                    ["trailmix"] = {recipe = "wanderingtradershop_trailmix", min = 1, max = 40, limit = 255},
                }
            }
        end

        if inst.RerollWares then
            if OldRerollWares == nil then
                OldRerollWares = inst.RerollWares
            end

            inst.RerollWares = RerollWares
        end
    end)
end