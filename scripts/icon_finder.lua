-- custom map icon revealer

return function(AddPrefabPostInit, modEnabled, config)
    local prefabs = {
        "globalmapicon",
    }

    local function UpdateIcon(inst)
        if inst.icon == nil then
            inst.icon = SpawnPrefab("globalmapicon")
            inst.icon:TrackEntity(inst)
        end
    end

    if config.BRIGHTSHADE_FINDER then
        AddPrefabPostInit("lunarthrall_plant", function(inst)
            inst.entity:AddTransform()
            inst.entity:AddMiniMapEntity()
            inst.MiniMapEntity:SetIcon("lunarplant_husk.tex")
            inst.MiniMapEntity:SetCanUseCache(false)

            if not TheWorld.ismastersim then
                return inst
            end

            -- set icon tracking
            inst.icon = nil
            inst:DoTaskInTime(0, UpdateIcon)
        end)
    end

    if config.LUREPLANT_FINDER then
        AddPrefabPostInit("lureplant", function(inst)
            inst.entity:AddTransform()
            inst.entity:AddMiniMapEntity()
            inst.MiniMapEntity:SetIcon("eyeplant.tex")
            inst.MiniMapEntity:SetCanUseCache(false)

            if not TheWorld.ismastersim then
                return inst
            end

            -- set icon tracking
            inst.icon = nil
            inst:DoTaskInTime(0, UpdateIcon)
        end)
    end

    if config.WALL_FINDER then
        local walls = {
            "wall_hay",
            "wall_wood",
            "wall_stone",
            "wall_ruins",
            "wall_moonrock",
            "wall_scrap",
            "wall_dreadstone",
            -- shipwrecked
            "wall_limestone",
            "wall_enforcedlimestone",
            -- hamlet
            "wall_pig_ruins",
        }

        local function GetMapIcon(inst)
            if inst.prefab == "wall_hay" then
                return "wall_hay.tex"
            elseif inst.prefab == "wall_wood" then
                return "wall_wood.tex"
            elseif inst.prefab == "wall_stone" then
                return "wall_stone.tex"
            elseif inst.prefab == "wall_ruins" then
                return "wall_ruins.tex"
            elseif inst.prefab == "wall_moonrock" then
                return "wall_moonrock.tex"
            elseif inst.prefab == "wall_scrap" then
                -- placeholder image for now
                return "wall_wood.tex"
            elseif inst.prefab == "wall_dreadstone" then
                -- placeholder image for now
                return "wall_ruins.tex"
            elseif inst.prefab == "wall_limestone" then
                return "wall_limestone.tex"
            elseif inst.prefab == "wall_enforcedlimestone" then
                return "wall_enforcedlimestone.tex"
            elseif inst.prefab == "wall_pig_ruins" then
                return "wall_pig_ruins.tex"
            end
        end

        local function SetMapIcon(inst)
            inst.entity:AddTransform()
            inst.entity:AddMiniMapEntity()
            inst.MiniMapEntity:SetIcon(GetMapIcon(inst))
            inst.MiniMapEntity:SetPriority(5)
        end

        for _, prefab_name in ipairs(walls) do
            AddPrefabPostInit(prefab_name, SetMapIcon)
        end
    end

    if config.MARBLE_FINDER then
        local marble_pieces = {
            "sculpture_rooknose",
            "sculpture_knighthead",
            "sculpture_bishophead",
        }

        local function GetMapIcon(inst)
            if inst.prefab == "sculpture_rooknose" then
                return "sculpture_rooknose.tex"
            elseif inst.prefab == "sculpture_knighthead" then
                return "sculpture_knighthead.tex"
            elseif inst.prefab == "sculpture_bishophead" then
                return "sculpture_bishophead.tex"
            end
        end

        local function SetMapIcon(inst)
            inst.entity:AddTransform()
            inst.entity:AddMiniMapEntity()
            inst.MiniMapEntity:SetIcon(GetMapIcon(inst))
            inst.MiniMapEntity:SetPriority(5)
        end

        for _, prefab_name in ipairs(marble_pieces) do
            AddPrefabPostInit(prefab_name, SetMapIcon)
        end
    end

    if config.DEER_FINDER then
        AddPrefabPostInit("deer", function(inst)
            inst.entity:AddTransform()
            inst.entity:AddMiniMapEntity()
            inst.MiniMapEntity:SetIcon("deer.tex")
            inst.MiniMapEntity:SetCanUseCache(false)

            if not TheWorld.ismastersim then
                return inst
            end

            -- set icon tracking
            inst.icon = nil
            inst:DoTaskInTime(0, UpdateIcon)
        end)
    end

    if config.MANDRAKE_FINDER then
        AddPrefabPostInit("mandrake_planted", function(inst)
            inst.entity:AddTransform()
            inst.entity:AddMiniMapEntity()
            inst.MiniMapEntity:SetIcon("mandrake_planted.tex")
            inst.MiniMapEntity:SetPriority(5)

            if not TheWorld.ismastersim then
                return inst
            end

            if modEnabled("workshop-959771965") then
                -- set icon tracking
                inst.icon = nil
                inst:DoTaskInTime(0, UpdateIcon)
            end
        end)
    end

    if config.PIPSPOOK_FINDER then
        AddPrefabPostInit("smallghost", function(inst)
            inst.entity:AddTransform()
            inst.entity:AddMiniMapEntity()
            inst.MiniMapEntity:SetIcon("smallghost.tex")
            inst.MiniMapEntity:SetPriority(5)

            if not TheWorld.ismastersim then
                return inst
            end

            -- set icon tracking
            inst.icon = nil
            inst:DoTaskInTime(0, UpdateIcon)
        end)
    end
end