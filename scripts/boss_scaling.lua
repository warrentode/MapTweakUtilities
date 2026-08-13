-- custom boss loot scaling logic

return function(MTU, modEnabled, config, AllPlayers, distsq, AddPrefabPostInit, modimport)
    -- Import boss loot table
    modimport "scripts/boss_loot.lua"

    -- set config based constants
    local BOSS_SCALING_MODE = config.BOSS_SCALING_MODE
    local BOSS_SCALING_RANGE = config.BOSS_SCALING_RANGE
    local BOSS_SCALE_SOLO_BONUS = config.BOSS_SCALE_SOLO_BONUS
    local BOSS_SCALING_WORM_MOUTH = config.BOSS_SCALING_WORM_MOUTH
    local CRAFTABLE_WORM_BOSS_MOUTH = config.CRAFTABLE_WORM_BOSS_MOUTH

    local AllPlayers = AllPlayers or {}

    -- check for worm boss mouth mod loaded
    local WORM_BOSS_MOUTH_MOD = modEnabled("workshop-3474047377")

    -- Determine eligible players for scaling
    local function GetEligiblePlayers(boss)
        local eligible = 0

        -- check if scaling mode is even turned on
        if BOSS_SCALING_MODE > 0 then
            -- if on, check which scaling mode
            if BOSS_SCALING_MODE == 2 then
                -- scaling based on players in range
                local boss_pos = boss:GetPosition()
                for _, player in ipairs(AllPlayers) do
                    if player and player:IsValid() and distsq(player:GetPosition(), boss_pos) <= BOSS_SCALING_RANGE ^ 2 then
                        eligible = eligible + 1
                        print("GetEligiblePlayers: eligible count in range: ", tostring(eligible))
                    end
                end
            else
                -- scaling based on total number of players loaded
                eligible = MTU.players_loaded
                print("GetEligiblePlayers: eligible count: ", tostring(eligible))
            end
        end

        return eligible
    end

    -- special handling bosses
    local shadow_chess_pieces = {
        shadow_bishop = true,
        shadow_knight = true,
        shadow_rook = true,
    }
    local twin_pairs = {
        twinofterror1 = "twinofterror2",
        twinofterror2 = "twinofterror1",
    }
    -- live twin tracking so the bonus only drops once both are dead
    local live_twins = {}

    -- Attach scaling and attacker tracking to bosses
    for boss, _ in pairs(mtu_scaled_loot) do
        AddPrefabPostInit(boss, function(inst)
            if not TheWorld.ismastersim then
                return
            end

            if twin_pairs[boss] then
                live_twins[boss] = inst
                inst:ListenForEvent("onremove", function()
                    if live_twins[boss] == inst then
                        live_twins[boss] = nil
                    end
                end)
            end

            inst:ListenForEvent("death", function()
                -- special handling bosses
                if boss == "stalker_atrium" and inst:IsAtriumDecay() then return end
                if shadow_chess_pieces[boss] and inst.level < 3 then return end
                if twin_pairs[boss] then
                    local other = live_twins[twin_pairs[boss]]
                    if other and other:IsValid() and other.components.health and not other.components.health:IsDead() then
                        return
                    end
                end

                -- grab the eligible count
                local eligible_players = GetEligiblePlayers(inst)
                -- set scaling count to eligible
                local player_scaling_count = eligible_players
                -- adjust the scaling count for solo bonus
                if BOSS_SCALE_SOLO_BONUS then
                    -- bonus applied, first player counted
                    player_scaling_count = eligible_players
                else
                    -- first player removed since the bonus tables is based on the defaults
                    player_scaling_count = eligible_players - 1
                end

                -- if solo without bonus on, the bonus drops are skipped
                if player_scaling_count <= 0 then return end

                local lootdropper = inst.components.lootdropper
                if not lootdropper then return end

                local maximum_drop = player_scaling_count
                local minimum_drop = math.max(1, math.floor(player_scaling_count / 2))

                -- Main scaling function
                local scale_items = mtu_scaled_loot[inst.prefab] or {}

                for _, item in ipairs(scale_items) do
                    if item.count == "scale" then
                        for i = 1, maximum_drop do
                            local chance = (i <= minimum_drop) and 1.0 or 0.40
                            if math.random() <= chance then
                                lootdropper:SpawnLootPrefab(item.name)
                            end
                        end
                    else
                        local chance = item.chance or 1.0
                        for _ = 1, item.count do
                            if math.random() <= chance then
                                lootdropper:SpawnLootPrefab(item.name)
                            end
                        end
                    end
                end
            end)
        end)
    end

    -- Dragonfly scaling
    local COFFEE_MOD = modEnabled("workshop-2334209327") or modEnabled("workshop-1467214795") or modEnabled("workshop-3573989143") or modEnabled("workshop-3628284418") or Prefabs["dug_coffeebush"] ~= nil
    if COFFEE_MOD then
        AddPrefabPostInit("dragonfly", function(inst)
            if not TheWorld.ismastersim then
                return
            end

            inst:ListenForEvent("death", function()
                local lootdropper = inst.components.lootdropper
                if not lootdropper then
                    return
                end

                -- grab the eligible count
                local eligible_players = GetEligiblePlayers(inst)
                -- set scaling count to eligible
                local player_scaling_count = eligible_players

                -- for the bushes not added to the default drop table we emulate that here with the default 4 at the start
                local base_drop = 4 + player_scaling_count
                -- heap of foods adds 4 bushes to the default loot so we just add the bonus bushes to the drop
                -- we will also use this same count for the default drop catching any unknown mods adding the coffee bush using the shipwrecked prefab name
                local extra_drop = player_scaling_count

                -- adjust the scaling count for solo bonus
                if BOSS_SCALE_SOLO_BONUS then
                    -- bonus applied, we keep the first player
                    base_drop = base_drop
                    extra_drop = extra_drop
                else
                    -- first player counted, we remove the first player
                    base_drop = base_drop - 1
                    extra_drop = extra_drop - 1
                end

                -- this will always be at least 4
                for _ = 1, base_drop do
                    -- these mods don't add the bush and/or don't retrofit the bush into the world, so we add the base 4 drop plus the bonus extras
                    if modEnabled("workshop-1467214795") or modEnabled("workshop-3573989143") then
                        lootdropper:SpawnLootPrefab("dug_coffeebush")
                    elseif modEnabled("workshop-3628284418") then
                        lootdropper:SpawnLootPrefab("mod_dug_coffeebush")
                    end
                end

                -- this might be 0 so we check first
                if extra_drop > 0 then
                    for _ = 1, extra_drop do
                        if modEnabled("workshop-2334209327") then
                            lootdropper:SpawnLootPrefab("dug_kyno_coffeebush")
                        elseif Prefabs["dug_coffeebush"] ~= nil and not (modEnabled("workshop-1467214795") or modEnabled("workshop-3573989143")) then
                            -- unknown mod using the shipwrecked prefab name
                            lootdropper:SpawnLootPrefab("dug_coffeebush")
                        end
                    end
                end
            end)
        end)
    end

    -- Worm mouth scaling
    if WORM_BOSS_MOUTH_MOD then
        AddPrefabPostInit("worm_boss", function(inst)
            if not TheWorld.ismastersim then return end
            if not BOSS_SCALING_WORM_MOUTH then return end

            local lootdropper = inst.components.lootdropper
            if not inst.components.lootdropper then return end

            if CRAFTABLE_WORM_BOSS_MOUTH then
                lootdropper:AddChanceLoot("boss_worm_mouth_recipe_blueprint", 1)
            end

            -- Spawn extra worm mouths when the boss dies
            inst:ListenForEvent("death_ended", function()
                -- grab the eligible count
                local eligible_players = GetEligiblePlayers(inst)
                -- set scaling count to eligible
                local player_scaling_count = eligible_players
                -- adjust the scaling count for solo bonus
                if BOSS_SCALE_SOLO_BONUS then
                    -- bonus applied, extra player added since we are not using default loot here
                    player_scaling_count = eligible_players + 1
                else
                    -- first player counted
                    player_scaling_count = eligible_players
                end

                -- this should never be less than 1 but we check in case
                if player_scaling_count > 0 then
                    -- Count existing worm mouths in the loot table
                    local existing_mouths = 0
                    local loot = lootdropper.loot or {}
                    for i = 1, #loot do
                        if loot[i] == "boss_worm_mouth" then
                            existing_mouths = existing_mouths + 1
                        end
                    end

                    -- Spawn only the difference to reach player_count * 2
                    local mouths_to_spawn = math.max(0, (player_scaling_count * 2) - existing_mouths)
                    for _ = 1, mouths_to_spawn do
                        lootdropper:SpawnLootPrefab("boss_worm_mouth")
                    end
                end
            end)
        end)
    end
end