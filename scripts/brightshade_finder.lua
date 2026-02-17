-- custom map icon revealer for brightshades and lureplants

return function(AddPrefabPostInit)
    local prefabs = {
        "globalmapicon",
    }

    local function UpdateIcon(inst)
        if inst.icon == nil then
            inst.icon = SpawnPrefab("globalmapicon")
            inst.icon:TrackEntity(inst)
        end
    end

    AddPrefabPostInit("lunarthrall_plant", function(inst)
        inst.entity:AddTransform()
        inst.entity:AddMiniMapEntity()
        inst.MiniMapEntity:SetIcon("lunarplant_husk.tex")
        inst.MiniMapEntity:SetCanUseCache(false)
        inst.MiniMapEntity:SetDrawOverFogOfWar(true)

        if not TheWorld.ismastersim then
            return inst
        end

        -- set icon tracking
        inst.icon = nil
        inst:DoTaskInTime(0, UpdateIcon)
    end)

    AddPrefabPostInit("lureplant", function(inst)
        inst.entity:AddTransform()
        inst.entity:AddMiniMapEntity()
        inst.MiniMapEntity:SetIcon("eyeplant.tex")
        inst.MiniMapEntity:SetCanUseCache(false)
        inst.MiniMapEntity:SetDrawOverFogOfWar(true)

        if not TheWorld.ismastersim then
            return inst
        end

        -- set icon tracking
        inst.icon = nil
        inst:DoTaskInTime(0, UpdateIcon)
    end)
end