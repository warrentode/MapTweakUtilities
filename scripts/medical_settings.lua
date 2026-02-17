-- custom medical settings

return function(AddPrefabPostInit, ACTIONS, config)
    local MEDKIT_MOD = config.MEDKIT_MOD
    local MEDICAL_HAUNTING = config.MEDICAL_HAUNTING

    ---------- CUSTOM PATCH FOR MEDKIT MOD ----------

    if MEDKIT_MOD then
        local meditems = {
            -- vanilla DST items
            "reviver",
            "amulet",
            "lifeinjector",
            "halloweenpotion_sanity_large",
            "halloweenpotion_sanity_small",
            "halloweenpotion_health_large",
            "halloweenpotion_health_small",
            "healingsalve",
            "healingsalve_acid",
            "bandage",
            "tillweedsalve",
            "spider_healer_item",
            "sweettea",
            "taffy",
            "jellybean",
            "hermitcrabtea_petals",
            "hermitcrabtea_foliage",
            "hermitcrabtea_succulent_picked",
            "hermitcrabtea_moon_tree_blossom",
            "hermitcrabtea_tillweed",
            "hermitcrabtea_forgetmelots",
            "pocketwatch_revive",
            -- shipwrecked and hamlet items
            "antivenom",
            "poisonbalm"
        }

        for _, v in ipairs(meditems) do
            AddPrefabPostInit(v, function(inst)
                if not inst:HasTag("medic_item") then
                    inst:AddTag("medic_item")
                end
            end)
        end

        AddPrefabPostInit("medkit_l", function(inst)
            if not TheWorld.ismastersim then
                return
            end

            inst:AddTag("waterproofer")
            inst:AddComponent("waterproofer")
            inst.components.waterproofer:SetEffectiveness(0)

            inst:AddTag("fridge")
            inst:AddComponent("preserver")
            inst.components.preserver:SetPerishRateMultiplier(0)

            inst.components.container.droponopen = false

            if inst and inst.components.burnable then
                inst:RemoveComponent('burnable')
                inst:RemoveComponent('propagator')
            end
        end)
    end

    ---------- MEDICAL HAUNTING PATCH ----------

    if MEDICAL_HAUNTING then
        local oldHauntfn = ACTIONS.HAUNT.fn
        ACTIONS.HAUNT.fn = function(act)
            if act.doer ~= nil and act.target ~= nil then
                local inst = act.target
                if inst.components.container then
                    if act.doer.prefab == "wanda" then
                        for k = 1, inst.components.container.numslots do
                            local v = inst.components.container.slots[k]
                            if v and v.prefab == "pocketwatch_revive" then
                                inst.components.container:DropItem(v)
                                return oldHauntfn(act)
                            end
                        end
                    end
                    for k = 1, inst.components.container.numslots do
                        local v = inst.components.container.slots[k]
                        if v and v.prefab == "amulet" then
                            inst.components.container:DropItem(v)
                            return oldHauntfn(act)
                        end
                    end
                    for k = 1, inst.components.container.numslots do
                        local v = inst.components.container.slots[k]
                        if v and v.prefab == "reviver" then
                            inst.components.container:DropItem(v)
                            return oldHauntfn(act)
                        end
                    end
                    for k = 1, inst.components.container.numslots do
                        local v = inst.components.container.slots[k]
                        if v and v.prefab == "medkit_l" then
                            inst.components.container:DropItem(v)
                            return oldHauntfn(act)
                        end
                    end
                end
            end
            return oldHauntfn(act)
        end
    end

end