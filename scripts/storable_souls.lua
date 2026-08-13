return function(AddPrefabPostInit)
    AddPrefabPostInit("wortox_soul", function(inst)
        if not TheWorld.ismastersim then
            return
        end

        if inst.components.inventoryitem then
            inst.components.inventoryitem.canonlygoinpocketorpocketcontainers = false
        end
    end)

    -- AddPrefabPostInit to modify the 'willow_ember' prefab and disable the vanilla function
    AddPrefabPostInit("willow_ember", function(inst)
        if not TheWorld.ismastersim then
            return
        end

        -- Ensure the original updatespells function is removed/overwritten globally
        _G.updatespells = function(inst, owner)
            -- Custom version of updatespells to handle the crash-causing issue
            local spells = shallowcopy(BASESPELLS)  -- Deep copy of base spells
            if owner then
                for _, v in ipairs(SKILLTREE_SPELL_ORDER) do
                    -- Custom check to prevent crash (check if skilltreeupdater exists)
                    if owner.components.skilltreeupdater and owner.components.skilltreeupdater:IsActivated(v) then
                        table.insert(spells, SKILLTREE_SPELL_DEFS[v]) -- Add the activated spell
                    end
                end
            end
            inst.components.spellbook:SetItems(spells)  -- Apply the modified spell list
        end

        -- Set the ember to be allowed in all containers, not just pockets
        if inst.components.inventoryitem then
            inst.components.inventoryitem.canonlygoinpocket = false
            inst.components.inventoryitem.cangoincontainer = true
        end
    end)
end