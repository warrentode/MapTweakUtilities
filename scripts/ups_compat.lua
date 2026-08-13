-- mod compat file for the ultimate perish settings mod
return function(AddPrefabPostInit)
    local spiders = {
        "spider",
        "spider_warrior",
        "spider_hider",
        "spider_spitter",
        "spider_dropper",
        "spider_moon",
        "spider_healer",
        "spider_water"
    }
    local insects = {
        "butterfly",
        "moonbutterfly",
        "bee",
        "killerbee"
    }
    local dried = {
        "plantmeat_dried",
        "kelp_dried",
        "humanmeat_dried"
    }

    -- checking for the mod's settings by checking the tag on the representative prefabs
    local function IceboxStoreCreaturesActive()
        local prefab = Prefabs["mole"]
        return prefab and prefab.tags and table.contains(prefab.tags, "icebox_valid")
    end
    local function SaltboxStoreJerkyActive()
        local prefab = Prefabs["meat_dried"]
        return prefab and prefab.tags and table.contains(prefab.tags, "saltbox_valid")
    end

    if IceboxStoreCreaturesActive then
        for _, v in ipairs(spiders) do
            AddPrefabPostInit(v, function(inst)
                if not inst:HasTag("icebox_valid") then
                    inst:AddTag("icebox_valid")
                end
            end)
        end

        for _, v in ipairs(insects) do
            AddPrefabPostInit(v, function(inst)
                if not inst:HasTag("icebox_valid") then
                    inst:AddTag("icebox_valid")
                end
            end)
        end
    end

    if SaltboxStoreJerkyActive then
        for _, v in ipairs(dried) do
            AddPrefabPostInit(v, function(inst)
                if not inst:HasTag("saltbox_valid") then
                    inst:AddTag("saltbox_valid")
                end
            end)
        end
    end

end