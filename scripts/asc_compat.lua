-- mod compat file for auto sorting chest mod and its cloned mods
return function(AddPrefabPostInit, config)
    local STORAGE_WARDROBE_MOD = config.STORAGE_WARDROBE_MOD
    local STORAGE_COMPOSTINGBIN_MOD = config.STORAGE_COMPOSTINGBIN_MOD

    local asc_fridges = {
        "deep_freezer",
    }

    for _, v in ipairs(asc_fridges) do
        AddPrefabPostInit(v, function(inst)
            if not inst:HasTag("asc_fridge") then
                inst:AddTag("asc_fridge")
            end
        end)
    end

    local asc_chests = {
        "terrariumchest",
        "greenbed"
    }

    for _, v in ipairs(asc_chests) do
        AddPrefabPostInit(v, function(inst)
            if not inst:HasTag("asc_chest") then
                inst:AddTag("asc_chest")
            end
        end)
    end

    -- check if "Storage wardrobe" mod is enabled since it mods a vanilla structure
    if STORAGE_WARDROBE_MOD then
        AddPrefabPostInit("wardrobe", function(inst)
            if not inst:HasTag("asc_chest") then
                inst:AddTag("asc_chest")
            end
        end)
    end

    -- check if "Composting Bin Storage" mod is enabled since it mods a vanilla structure
    if STORAGE_COMPOSTINGBIN_MOD then
        AddPrefabPostInit("compostingbin", function(inst)
            if not inst:HasTag("asc_chest") then
                inst:AddTag("asc_chest")
            end
        end)
    end
end