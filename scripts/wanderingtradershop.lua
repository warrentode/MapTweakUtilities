-- custom alt trades for wandering trader

return function(AddRecipe2, Ingredient, TECH, AddPrefabPostInit, config)
    local prefabs = {
        "globalmapicon",
    }

    local SLINGSHOT_EVERYONE = config.SLINGSHOT_EVERYONE
    local PORTABLECAMPFIRE_EVERYONE = config.PORTABLECAMPFIRE_EVERYONE
    local TRADER_ICON = config.TRADER_ICON
    local WALTER_TRADES = config.WALTER_TRADES

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

    AddRecipe2("wanderingtradershop_portablecoldfirepit",
               {
                   Ingredient("goldnugget", 4)
               },
               TECH.LOST,
               {
                   limitedamount = true,
                   nounlock = true,
                   actionstr = "WANDERINGTRADERSHOP",
                   sg_state = "give",
                   product = "portablecoldfirepit_item",
                   image = "portablefirepit_item.tex",
                   numtogive = 1,
                   description = "wanderingtradershop_portablecoldfirepit",
               },
               {"CRAFTING_STATION"}
    )

    AddTrades("wanderingtradershop_slingshot", "goldnugget", 4, "slingshot", 1)
    AddTrades("wanderingtradershop_portablefirepit", "goldnugget", 4, "portablefirepit_item", 1)
    AddTrades("wanderingtradershop_portabletent", "goldnugget", 4, "portabletent_item", 1)
    AddTrades("wanderingtradershop_slingshotammo_marble", "goldnugget", 4, "slingshotammo_marble", 120)

    AddTrades("wanderingtradershop_marbles", "goldnugget", 4, "trinket_1", 1)
    AddTrades("wanderingtradershop_bedroll_straw", "ash", 2, "bedroll_straw", 1)
    AddTrades("wanderingtradershop_dug_sapling", "ash", 4, "dug_sapling", 1)
    AddTrades("wanderingtradershop_dug_grass", "ash", 4, "dug_grass", 1)
    AddTrades("wanderingtradershop_dug_berrybush", "ash", 4, "dug_berrybush", 1)
    AddTrades("wanderingtradershop_pinecone", "ash", 4, "pinecone", 1)
    AddTrades("wanderingtradershop_acorn", "ash", 4, "acorn", 1)
    AddTrades("wanderingtradershop_trailmix", "ash", 2, "trailmix", 1)

    -- Add the new trade tables
    local OldRerollWares
    local function RerollWares(inst, ...)
        if SLINGSHOT_EVERYONE and WALTER_TRADES then
            inst:AddWares(inst.WARES.MARBLES[math.random(#inst.WARES.MARBLES)])
        end

        if PORTABLECAMPFIRE_EVERYONE and WALTER_TRADES then
            inst:AddWares(inst.WARES.CAMPING[math.random(#inst.WARES.CAMPING)])
        end

        inst:AddWares(inst.WARES.EXTRA[math.random(#inst.WARES.EXTRA)])

        return OldRerollWares(inst, ...)
    end

    local function UpdateIcon(inst)
        if inst.icon == nil then
            inst.icon = SpawnPrefab("globalmapicon")
            inst.icon:TrackEntity(inst)
        end
    end

    AddPrefabPostInit("wanderingtrader", function(inst)
        if TRADER_ICON then
            inst.entity:AddTransform()
            inst.entity:AddMiniMapEntity()

            inst.MiniMapEntity:SetIcon("wanderingtrader.tex")
            inst.MiniMapEntity:SetCanUseCache(false)
            inst.MiniMapEntity:SetDrawOverFogOfWar(true)
        end

        if not TheWorld.ismastersim then
            return
        end

        if inst.WARES then
            inst.WARES.MARBLES = {
                {
                    ["slingshot"] = {recipe = "wanderingtradershop_slingshot", min = 1, max = 1, limit = 255},
                },
                {
                    ["marbles"] = {recipe = "wanderingtradershop_marbles", min = 1, max = 40, limit = 255},
                },
                {
                    ["slingshotammo_marble"] = {recipe = "wanderingtradershop_slingshotammo_marble", min = 1, max = 1, limit = 255},
                }
            }
            inst.WARES.CAMPING = {
                {
                    ["portablefirepit_item"] = {recipe = "wanderingtradershop_portablefirepit", min = 1, max = 1, limit = 255},
                },
                {
                    ["portablecoldfirepit_item"] = {recipe = "wanderingtradershop_portablecoldfirepit", min = 1, max = 1, limit = 255},
                },
                {
                    ["portabletent_item"] = {recipe = "wanderingtradershop_portabletent", min = 1, max = 1, limit = 255},
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
                },
                {
                    ["bedroll_straw"] = {recipe = "wanderingtradershop_bedroll_straw", min = 1, max = 1, limit = 255},
                }
            }
        end

        if inst.RerollWares then
            if OldRerollWares == nil then
                OldRerollWares = inst.RerollWares
            end

            inst.RerollWares = RerollWares
        end

        if TRADER_ICON then
            inst.icon = nil
            inst:DoTaskInTime(0, UpdateIcon)
        end
    end)
end