-- mod compat file for ultimate backpack settings mod
return function(AddPrefabPostInit, config)
    ---------- CUSTOM PATCH FOR CHEF POUCH ----------
    AddPrefabPostInit("spicepack", function(inst)
        if not TheWorld.ismastersim then
            return
        end

        if config.SPICEPACK_INVENTORY then
            inst:AddComponent("inventoryitem")
            inst.components.inventoryitem.cangoincontainer = true
        end

        if config.SPICEPACK_WATERPROOF then
            inst:AddTag("waterproofer")
            inst:AddComponent("waterproofer")
            inst.components.waterproofer:SetEffectiveness(0)
        end

        if config.SPICEPACK_PERISH_MULT ~= 1 then
            inst:AddComponent("preserver")
            inst.components.preserver:SetPerishRateMultiplier(config.SPICEPACK_PERISH_MULT)
        end

        if not config.SPICEPACK_BURNABLE then
            if inst and inst.components.burnable then
                inst:RemoveComponent('burnable')
                inst:RemoveComponent('propagator')
            end
        end
    end)

    ---------- CUSTOM PATCH FOR WEBBER BACKPACK ----------
    AddPrefabPostInit("webber_backpack", function(inst)
        if not TheWorld.ismastersim then
            return
        end

        if config.WEBBER_BACKPACK_INVENTORY then
            if inst and not inst.components.inventoryitem then
                inst:AddComponent("inventoryitem")
            end
            inst.components.inventoryitem.cangoincontainer = true
        end

        if config.WEBBER_BACKPACK_WATERPROOF then
            if inst and not inst.components.waterproofer then
                inst:AddComponent("waterproofer")
            end
            inst:AddTag("waterproofer")
            inst:AddComponent("waterproofer")
            inst.components.waterproofer:SetEffectiveness(0)
        end

        if config.WEBBER_BACKPACK_PERISH_MULT ~= 1 then
            if inst and not inst.components.preserver then
                inst:AddComponent("preserver")
            end
            inst.components.preserver:SetPerishRateMultiplier(config.WEBBER_BACKPACK_PERISH_MULT)
        end

        if not config.WEBBER_BACKPACK_BURNABLE then
            if inst and inst.components.burnable then
                inst:RemoveComponent('burnable')
                inst:RemoveComponent('propagator')
            end
        end
    end)
end