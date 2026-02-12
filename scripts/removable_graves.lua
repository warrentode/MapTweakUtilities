---------- GRAVE CONTROLS ----------

return function(AddSimPostInit, AddPrefabPostInit, ACTIONS, TUNING)
    -- weighted loot table: cutstone twice as likely as marble
    local HEADSTONE_LOOT = {
        {item = "cutstone", weight = 2},
        {item = "marble", weight = 1},
    }

    -- helper to pick a weighted random item
    local function PickWeighted(loot_table)
        local total = 0
        for _, entry in ipairs(loot_table) do
            total = total + entry.weight
        end

        local r = math.random() * total
        for _, entry in ipairs(loot_table) do
            r = r - entry.weight
            if r <= 0 then
                return entry.item
            end
        end
    end

    local function OnSmashedHeadstone(inst, worker)
        local x, y, z = inst.Transform:GetWorldPosition()

        if inst.mound and inst.mound.components.workable then
            -- Gravestone smashed before mound dug
            local new_mound = SpawnPrefab("mound")
            new_mound.Transform:SetPosition(x, y, z)

            inst:Remove() -- remove the gravestone
            return
        end

        -- Normal headstone smash (after mound dug)
        if worker and worker.components.sanity then
            worker.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
        end

        local item = PickWeighted(HEADSTONE_LOOT)
        if item then
            local quantity = math.random(1, 2)
            for _ = 1, quantity do
                inst.components.lootdropper:SpawnLootPrefab(item)
            end
        end

        inst:Remove()
    end

    local function OnRemoveGrave(inst, worker)
        if worker and worker.components.sanity then
            worker.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
        end
        inst:Remove()
    end

    AddSimPostInit(function()
        if not TheWorld.ismastersim then
            return
        end

        for _, inst in pairs(Ents) do
            if inst
                    and inst.prefab == "mound"
                    and inst.AnimState ~= nil
                    and inst.AnimState:IsCurrentAnimation("dug")
            then
                if inst.components.workable == nil then
                    inst:AddComponent("workable")
                end

                inst.components.workable:SetWorkAction(ACTIONS.DIG)
                inst.components.workable:SetWorkLeft(1)
                inst.components.workable:SetOnFinishCallback(OnRemoveGrave)
            end
        end
    end)

    AddPrefabPostInit("mound", function(inst)
        if not TheWorld.ismastersim then
            return
        end

        local old_onfinish = inst.components.workable and inst.components.workable.onfinish or nil

        if inst.components.workable then
            inst.components.workable:SetOnFinishCallback(function(inst2, worker)
                -- call vanilla loot and sanity logic
                if old_onfinish then
                    old_onfinish(inst2, worker)
                end

                -- handle second dig removal
                if not inst2._dug_once then
                    -- mark as dug once, keep workable for second dig
                    inst2._dug_once = true
                    -- re-add workable if removed
                    if inst2.components.workable == nil then
                        inst2:AddComponent("workable")
                        inst2.components.workable:SetWorkAction(ACTIONS.DIG)
                        inst2.components.workable:SetWorkLeft(1)
                        inst2.components.workable:SetOnFinishCallback(inst2._original_onfinish)
                    end
                else
                    -- second dig: remove mound completely
                    inst2:Remove()
                end
            end)

            -- store reference for re-adding workable
            inst._original_onfinish = inst.components.workable.onfinish
        end
    end)

    AddPrefabPostInit("gravestone", function(inst)
        if not TheWorld.ismastersim then
            return
        end

        inst:AddComponent("workable")
        inst:AddComponent("lootdropper")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(2)
        inst.components.workable:SetOnFinishCallback(OnSmashedHeadstone)
    end)
end