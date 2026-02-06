-- custom settings for trees

return function(AddPrefabPostInit, config)
    local BLOSSOM_CAP = config.BLOSSOM_CAP
    local BLOSSOM_CHANCE = config.BLOSSOM_CHANCE

    local PINE_LOOP = config.PINE_LOOP
    local LUMPY_LOOP = config.LUMPY_LOOP
    local STONE_FRUIT_LOOP = config.STONE_FRUIT_LOOP
    local TWIGGY_LOOP = config.TWIGGY_LOOP
    local BIRCH_LOOP = config.BIRCH_LOOP
    local MOON_LOOP = config.MOON_LOOP
    local MARBLE_LOOP = config.MARBLE_LOOP
    local PALM_LOOP = config.PALM_LOOP
    local MUSH_LOOP = config.MUSH_LOOP

    ---------- LUNE TREE BLOSSOM CONTROLS ----------

    -- Moon Tree PostInit patch
    local function DoMoonBlossomRebirth(inst)
        local rebirth_loot = {loot = "moon_tree_blossom", max = BLOSSOM_CAP}
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 8)
        local numloot = 0

        for _, ent in ipairs(ents) do
            if ent.prefab == rebirth_loot.loot then
                if ent.components.stackable then
                    numloot = numloot + ent.components.stackable:StackSize()
                else
                    numloot = numloot + 1
                end
            end
        end

        -- skip drop roll if no chance for it
        if BLOSSOM_CHANCE > 0 then
            if numloot < BLOSSOM_CAP and inst.components.lootdropper then
                if math.random() * 100 <= BLOSSOM_CHANCE then
                    inst.components.lootdropper:SpawnLootPrefab(rebirth_loot.loot)
                end
            end
        end

        inst._lastrebirth = GetTime()
    end

    local function PatchMoonTreeGrowth(inst)
        if not TheWorld.ismastersim then
            return
        end

        if inst.components.growable and inst.components.growable.stages then
            for _, stage in ipairs(inst.components.growable.stages) do
                local old_growfn = stage.growfn
                stage.growfn = function(inst2, ...)
                    if old_growfn then
                        old_growfn(inst2, ...)
                    end
                    DoMoonBlossomRebirth(inst2)
                end
            end
        end
    end

    AddPrefabPostInit("moon_tree", PatchMoonTreeGrowth)

    ---------- TWIGGY TREE TWIG DROP CONTROLS PATCH ----------
    -- to actually count the number of twigs in a nearby stack rather than counting the entire stack as 1 item
    AddPrefabPostInit("twiggytree", function(inst)
        if not TheWorld.ismastersim or not inst.components.growable or not inst.components.growable.stages then
            return
        end

        local function DoTwiggyLoot(inst)
            local rebirth_loot = {loot = "twigs", max = 2} -- ground-presence cap
            local x, y, z = inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, 8)
            local numloot = 0

            for _, ent in ipairs(ents) do
                if ent.prefab == rebirth_loot.loot then
                    if ent.components.stackable then
                        numloot = numloot + ent.components.stackable:StackSize()
                    else
                        numloot = numloot + 1
                    end
                end
            end

            local prob = 1 - (numloot / rebirth_loot.max)
            if numloot < 2 and inst.components.lootdropper then
                if math.random() < prob then
                    if inst.components.lootdropper then
                        inst.components.lootdropper:SpawnLootPrefab(rebirth_loot.loot)
                    end
                end
            end

            inst._lastrebirth = GetTime()
        end

        -- Wrap each grow stage's growfn
        for _, stage in ipairs(inst.components.growable.stages) do
            local old_growfn = stage.growfn
            stage.growfn = function(inst2, ...)
                if old_growfn then
                    old_growfn(inst2, ...)
                end
                DoTwiggyLoot(inst2)
            end
        end
    end)

    ---------- TREE CYCLE CONTROLS ----------

    -- List of 5 stage trees
    local plantregrowth_5_stage_list = {}
    plantregrowth_5_stage_list["evergreen"] = PINE_LOOP
    plantregrowth_5_stage_list["evergreen_sparse"] = LUMPY_LOOP
    plantregrowth_5_stage_list["twiggytree"] = TWIGGY_LOOP
    plantregrowth_5_stage_list["rock_avocado_bush"] = STONE_FRUIT_LOOP

    -- 5 stage trees: Remove the looping process (looping is prohibited; if the tree is deadwood before the process starts, it will be converted to a level three state).
    for k, v in pairs(plantregrowth_5_stage_list) do
        if v then
            AddPrefabPostInit(k, function(inst)
                inst:DoTaskInTime(0.1, function(inst)
                    if not TheWorld.ismastersim then
                        return
                    end

                    if inst.components and inst.components.growable then
                        -- Required final stage
                        local need_final_stage = #inst.components.growable.stages - 1
                        local real_final_stage = #inst.components.growable.stages
                        inst.components.growable.stages[real_final_stage] = inst.components.growable.stages[need_final_stage]
                        -- Cyclic growth is prohibited.
                        inst.components.growable.loopstages = false
                        -- Existing dead trees in the world will automatically be converted to level three.
                        if inst.components.growable.stage > need_final_stage then
                            inst.components.growable:SetStage(need_final_stage)
                        end
                        if inst.components.growable.stage >= need_final_stage then
                            inst.components.growable:StopGrowing()
                        end
                    end
                    if inst.components and inst.components.plantregrowth then
                        inst:RemoveComponent("plantregrowth")
                    end

                end)
            end)
        end
    end

    -- List of 4 stage trees
    local plantregrowth_list = {}
    plantregrowth_list["deciduoustree"] = BIRCH_LOOP
    plantregrowth_list["moon_tree"] = MOON_LOOP
    plantregrowth_list["marbleshrub"] = MARBLE_LOOP
    plantregrowth_list["palmconetree"] = PALM_LOOP
    plantregrowth_list["mushtree_tall"] = MUSH_LOOP
    plantregrowth_list["mushtree_medium"] = MUSH_LOOP
    plantregrowth_list["mushtree_small"] = MUSH_LOOP
    for k, v in pairs(plantregrowth_list) do
        if v then
            AddPrefabPostInit(k, function(inst)
                inst:DoTaskInTime(0.1, function(inst)
                    if TheWorld.ismastersim then
                        if inst.components and inst.components.growable then
                            inst.components.growable.loopstages = false
                        end
                    end
                end)
            end)
        end
    end
end