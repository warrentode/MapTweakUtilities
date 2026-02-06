-- custom boss loot scaling logic

return function(MTU, config, SetSharedLootTable, AllPlayers, distsq, AddPrefabPostInit, modimport, KnownModIndex)
    -- Import boss loot table
    modimport "scripts/boss_loot.lua"

    -- set config based constants
    local BOSS_SCALING_MODE = config.BOSS_SCALING_MODE
    local BOSS_SCALING_RANGE = config.BOSS_SCALING_RANGE
    local BOSS_SCALING_BLUEPRINTS = config.BOSS_SCALING_BLUEPRINTS
    local BOSS_SCALING_WORM_MOUTH = config.BOSS_SCALING_WORM_MOUTH

    local SetSharedLootTable = SetSharedLootTable
    local AllPlayers = AllPlayers or {}

    -- check for worm boss mouth mod loaded
    local WORM_BOSS_MOUTH_MOD = KnownModIndex:IsModEnabled("workshop-3474047377")

    -- Update eligible players list on join/leave
    local function UpdatePlayers(_, _)
        AllPlayers = AllPlayers or {}
    end

    AddPrefabPostInit("world", function(world)
        world:ListenForEvent("ms_playerspawn", UpdatePlayers)
        world:ListenForEvent("ms_playerleft", UpdatePlayers)
    end)

    -- Determine eligible players for scaling
    local function GetEligiblePlayers(boss)
        local eligible = {}

        -- check if scaling mode is even turned on
        if BOSS_SCALING_MODE > 0 then
            -- if on, check which scaling mode
            if BOSS_SCALING_MODE == 2 then
                -- scaling based on players in range
                local boss_pos = boss:GetPosition()
                for _, player in ipairs(AllPlayers) do
                    if player and player:IsValid() and distsq(player:GetPosition(), boss_pos) <= BOSS_SCALING_RANGE^2 then
                        table.insert(eligible, player)
                    end
                end
            else
                -- scaling based on total number of players loaded
                for _ = 1, MTU.players_loaded do
                    table.insert(eligible, true)  -- just a placeholder; only the count matters
                end
            end
        end

        return eligible
    end

    -- Main scaling function
    local function ScaleLootTable(inst)
        local scale_items = mtu_scaled_loot[inst.prefab] or {}
        local eligible_players = GetEligiblePlayers(inst)
        local player_count = #eligible_players
        if player_count <= 0 then return end

        local new_loot = {}
        local maximum_drop = player_count
        local minimum_drop = math.max(1, math.floor(player_count / 2))

        -- Normal scaling for other loot items
        for _, item in ipairs(scale_items) do
            -- Skip blueprint drops if blueprint scaling is off
            if item.name:find("blueprint") and not BOSS_SCALING_BLUEPRINTS then
                -- skip

                -- Normal scaling for contested items
            elseif item.count == "scale" then
                for i = 1, maximum_drop do
                    local chance = (i <= minimum_drop) and 1.0 or 0.40
                    new_loot[#new_loot + 1] = {item.name, chance}
                end

                -- Non-scaled items
            else
                local chance = item.chance or 1.0
                for _ = 1, item.count do
                    new_loot[#new_loot + 1] = {item.name, chance}
                end
            end
        end

        -- Apply loot table for everything else
        SetSharedLootTable(inst, new_loot)
        if inst.components.lootdropper then
            inst.components.lootdropper:SetChanceLootTable(inst)
        end
    end

    -- Attach scaling and attacker tracking to bosses
    for boss,_ in pairs(mtu_scaled_loot) do
        AddPrefabPostInit(boss, function(inst)
            if not TheWorld.ismastersim then return end
            ScaleLootTable(inst)
        end)
    end

    -- Worm mouth scaling
    if WORM_BOSS_MOUTH_MOD then
        AddPrefabPostInit("worm_boss", function(inst)
            if not TheWorld.ismastersim then return end
            if not BOSS_SCALING_WORM_MOUTH then return end
            if not inst.components.lootdropper then return end

            -- Spawn extra worm mouths when the boss dies
            inst:ListenForEvent("death_ended", function()
                local lootdropper = inst.components.lootdropper
                if not lootdropper then return end

                local eligible_players = GetEligiblePlayers(inst)
                local player_count = #eligible_players
                if player_count <= 0 then return end

                -- Count existing worm mouths in the loot table
                local existing_mouths = 0
                local loot = lootdropper.loot or {}
                for i = 1, #loot do
                    if loot[i] == "boss_worm_mouth" then
                        existing_mouths = existing_mouths + 1
                    end
                end

                -- Spawn only the difference to reach player_count * 2
                local mouths_to_spawn = math.max(0, (player_count * 2) - existing_mouths)
                for _ = 1, mouths_to_spawn do
                    lootdropper:SpawnLootPrefab("boss_worm_mouth")
                end
            end)
        end)
    end

end