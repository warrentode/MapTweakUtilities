-- custom alt trades for wandering trader

return function(AddRecipe2, Ingredient, TECH, AddPrefabPostInit, config)
    local prefabs = {
        "globalmapicon",
    }

    local SLINGSHOT_EVERYONE = config.SLINGSHOT_EVERYONE
    local PORTABLECAMPFIRE_EVERYONE = config.PORTABLECAMPFIRE_EVERYONE
    local TRADER_ICON = config.TRADER_ICON
    local WALTER_TRADES = config.WALTER_TRADES
    local WARLY_COOKPOT_EVERYONE = config.WARLY_COOKPOT_EVERYONE
    local WARLY_TRADES = config.WARLY_TRADES
    local WILLOW_TRADES = config.WILLOW_TRADES
    local WOODIE_TRADES = config.WOODIE_TRADES
    local WILSON_TRADES = config.WILSON_TRADES
    local MAXWELL_TRADES = config.MAXWELL_TRADES

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
    local function AddTrades2(tradeName, itemsWanted, itemOffered, itemOfferedAmount)
        AddRecipe2(tradeName,
        -- format: {Ingredient(itemWanted, itemWantedAmount)},
                   itemsWanted,
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

    -- MARBLES trade recipes
    AddTrades2("wanderingtradershop_slingshot",
               {
                   Ingredient("twigs", 1),
                   Ingredient("mosquitosack", 2)
               },
               "slingshot", 1)
    AddTrades("wanderingtradershop_slingshotammo_marble", "marble", 1, "slingshotammo_marble", 20)
    AddTrades("wanderingtradershop_slingshotammo_gold", "goldnugget", 1, "slingshotammo_gold", 20)

    -- CAMPING trade recipes
    AddTrades2("wanderingtradershop_portablefirepit",
               {
                   Ingredient("log", 3),
                   Ingredient("rope", 1),
                   Ingredient("rocks", 4)
               },
               "portablefirepit_item", 1)
    AddRecipe2("wanderingtradershop_portablecoldfirepit",
               {
                   Ingredient("nitre", 3),
                   Ingredient("rope", 1),
                   Ingredient("rocks", 4)
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
    AddTrades2("wanderingtradershop_portabletent",
               {
                   Ingredient("bedroll_straw", 1),
                   Ingredient("twigs", 4),
                   Ingredient("rope", 2)
               },
               "portabletent_item", 1)

    -- WARLY trade recipes
    AddTrades2("wanderingtradershop_portablecookpot",
               {
                   Ingredient("gold_nugget", 2),
                   Ingredient("charcoal", 6),
                   Ingredient("twigs", 2)
               },
               "portablecookpot_item", 1)

    -- WILLOW trade recipes
    AddTrades2("wanderingtradershop_bernie_inactive",
               {
                   Ingredient("beardhair", 2),
                   Ingredient("beefalowool", 2),
                   Ingredient("silk", 2)
               },
               "bernie_inactive", 1)

    -- WOODIE trade recipes
    AddTrades2("wanderingtradershop_leif_idol",
               {
                   Ingredient("cutgrass", 3),
                   Ingredient("livinglog", 2),
                   Ingredient("nightmarefuel", 5)
               },
               "leif_idol", 1)

    -- WILSON trade recipes
    AddTrades2("wanderingtradershop_opalpreciousgem",
               {
                   Ingredient("yellowgem", 1),
                   Ingredient("orangegem", 1),
                   Ingredient("greengem", 1),
                   Ingredient("purplegem", 1),
                   Ingredient("redgem", 1),
                   Ingredient("bluegem", 1),
                   Ingredient("livinglog", 2),
                   Ingredient("nightmarefuel", 4)
               },
               "opalpreciousgem", 1)

    -- MAXWELL trade recipes
    AddRecipe2("wanderingtradershop_magician_chest",
               {
                   Ingredient("silk", 1),
                   Ingredient("boards", 4),
                   Ingredient("nightmarefuel", 9)
               },
               TECH.LOST,
               {
                   limitedamount = true,
                   nounlock = true,
                   actionstr = "WANDERINGTRADERSHOP",
                   sg_state = "give",
                   image = "magician_chest.tex",
                   numtogive = 1,
                   description = "wanderingtradershop_magician_chest",
                   product = "magician_chest",
                   placer = "magician_chest_placer",
                   always_allow_buffered_placer = true,
                   min_spacing = 1.5
               },
               {"CRAFTING_STATION"}
    )

    -- EXTRA trade recipes
    AddTrades2("wanderingtradershop_bedroll_straw",
               {
                   Ingredient("cutgrass", 9)
               },
               "bedroll_straw", 1)
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

        if WARLY_COOKPOT_EVERYONE and WARLY_TRADES then
            inst:AddWares(inst.WARES.WARLY[math.random(#inst.WARES.WARLY)])
        end

        if WILLOW_TRADES then
            inst:AddWares(inst.WARES.WILLOW[math.random(#inst.WARES.WILLOW)])
        end

        if WOODIE_TRADES then
            inst:AddWares(inst.WARES.WOODIE[math.random(#inst.WARES.WOODIE)])
        end

        if WILSON_TRADES and TheWorld.state.moonphase == "full" then
            inst:AddWares(inst.WARES.WILSON[math.random(#inst.WARES.WILSON)])
        end

        if MAXWELL_TRADES then
            inst:AddWares(inst.WARES.MAXWELL[math.random(#inst.WARES.MAXWELL)])
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
                    ["slingshot"] = {recipe = "wanderingtradershop_slingshot", min = 1, max = 1},
                },
                {
                    ["slingshotammo_gold"] = {recipe = "wanderingtradershop_slingshotammo_gold", min = 1, max = 6},
                },
                {
                    ["slingshotammo_marble"] = {recipe = "wanderingtradershop_slingshotammo_marble", min = 1, max = 6},
                }
            }
            inst.WARES.CAMPING = {
                {
                    ["portablefirepit_item"] = {recipe = "wanderingtradershop_portablefirepit", min = 1, max = 1},
                },
                {
                    ["portablecoldfirepit_item"] = {recipe = "wanderingtradershop_portablecoldfirepit", min = 1, max = 1},
                },
                {
                    ["portabletent_item"] = {recipe = "wanderingtradershop_portabletent", min = 1, max = 1},
                }
            }
            inst.WARES.WARLY = {
                {
                    ["portablecookpot"] = {recipe = "wanderingtradershop_portablecookpot", min = 1, max = 1},
                }
            }
            inst.WARES.WILLOW = {
                {
                    ["bernie_inactive"] = {recipe = "wanderingtradershop_bernie_inactive", min = 1, max = 1},
                }
            }
            inst.WARES.WOODIE = {
                {
                    ["leif_idol"] = {recipe = "wanderingtradershop_leif_idol", min = 1, max = 10},
                }
            }
            inst.WARES.WILSON = {
                {
                    ["opalpreciousgem"] = {recipe = "wanderingtradershop_opalpreciousgem", min = 1, max = 1},
                }
            }
            inst.WARES.MAXWELL = {
                {
                    ["magician_chest_placer"] = {recipe = "wanderingtradershop_magician_chest", min = 1, max = 1},
                }
            }
            inst.WARES.EXTRA = {
                {
                    ["acorn"] = {recipe = "wanderingtradershop_acorn", min = 1, max = 3, limit = 10},
                },
                {
                    ["pinecone"] = {recipe = "wanderingtradershop_pinecone", min = 1, max = 3, limit = 10},
                },
                {
                    ["dug_grass"] = {recipe = "wanderingtradershop_dug_grass", min = 1, max = 3, limit = 10},
                },
                {
                    ["dug_sapling"] = {recipe = "wanderingtradershop_dug_sapling", min = 1, max = 3, limit = 10},
                },
                {
                    ["dug_berrybush"] = {recipe = "wanderingtradershop_dug_berrybush", min = 1, max = 3, limit = 10},
                },
                {
                    ["trailmix"] = {recipe = "wanderingtradershop_trailmix", min = 1, max = 10, limit = 10},
                },
                {
                    ["bedroll_straw"] = {recipe = "wanderingtradershop_bedroll_straw", min = 1, max = 1},
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