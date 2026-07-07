-- custom follower protections

return function(TUNING, SetSharedLootTable, AddPrefabPostInit, config)
    local prefabs = {
        "globalmapicon",
    }

    local PROTECT_FOLLOWERS = config.PROTECT_FOLLOWERS
    local REVEAL_FOLLOWERS = config.REVEAL_FOLLOWERS

    -- protection settings
    if PROTECT_FOLLOWERS then
        local PROTECTED_MOBS = {
            "glommer",
            "chester",
            "hutch",
            "friendlyfruitfly",
            "lavae_pet",
            "beefalo",
            "cfe_chester",
            "hermitcrab",
        }

        SetSharedLootTable("lavae_coccon", {{"lavae_tooth", 1}})

        local function ReviveLavaePet(inst)
            if not TheWorld.ismastersim then
                return inst
            end

            MakeSmallBurnable(inst, nil, nil, true)
            MakeMediumPropagator(inst)

            inst:AddComponent("lootdropper")
            inst.components.lootdropper:SetChanceLootTable("lavae_coccon")
        end

        -- make chesters and hutches invincible
        TUNING.CHESTER_HEALTH = 99999
        TUNING.CHESTER_RESPAWN_TIME = 0.1
        TUNING.CHESTER_HEALTH_REGEN_AMOUNT = 99999
        TUNING.CHESTER_HEALTH_REGEN_PERIOD = 0.1

        TUNING.HUTCH_HEALTH = 99999
        TUNING.HUTCH_RESPAWN_TIME = 0.1
        TUNING.HUTCH_HEALTH_REGEN_AMOUNT = 99999
        TUNING.HUTCH_HEALTH_REGEN_PERIOD = 0.1

        local function ProtectMob(inst)
            if not TheWorld.ismastersim then
                return inst
            end

            -- these protections only apply to non-beefalo
            if inst.prefab ~= "beefalo" then
                -- no longer pushable or blocking
                inst.Physics:ClearCollisionMask()
                inst.Physics:CollidesWith(COLLISION.GROUND)
                inst:AddTag("NOBLOCK")
                -- remove freezing
                if inst.components.freezable then
                    inst:RemoveComponent("freezable")
                end
                -- remove burning
                if inst.components.burnable then
                    inst:RemoveComponent("burnable")
                end
                -- remove comabt targeting for each mob except chester and hutch since they have combat related purpose
                if inst.components.combat and not inst.prefab ~= "chester" and not inst.prefab ~= "cfe_chester" and not inst.prefab ~= "hutch" then
                    inst:RemoveComponent("combat")
                end
                -- remove catcoon targeting
                if inst:HasTag("cattoyairborne") then
                    inst:RemoveTag("cattoyairborne")
                end
                -- make non chesters and non hutches invincible, because we set that earlier with tuning
                if inst.components.health and not inst.prefab ~= "chester" and not inst.prefab ~= "cfe_chester" and not inst.prefab ~= "hutch" then
                    inst.components.health:SetMaxHealth(99999)
                    inst.components.health:StartRegen(99999, 1)
                end
                -- set no aura damage
                if not inst:HasTag("noauradamage") then
                    inst:AddTag("noauradamage")
                end
            end
        end

        for _, prefab_name in ipairs(PROTECTED_MOBS) do
            if prefab_name ~= "beefalo" then
                AddPrefabPostInit(prefab_name, ProtectMob)
            end
            if prefab_name == "lavae_pet" then
                AddPrefabPostInit("lavae_cocoon", ReviveLavaePet)
            end
            if prefab_name == "beefalo" then
                -- Patch beefalo to add/remove "noplayertarget" when a bell owner is assigned or removed
                AddPrefabPostInit("beefalo", function(inst)
                    if not TheWorld.ismastersim then
                        return
                    end

                    local function UpdateNoPlayerTarget()
                        local leader = inst.components.follower and inst.components.follower.leader
                        if leader and (leader:HasTag("bell") or leader:HasTag("shadowbell")) then
                            if not inst:HasTag("noplayertarget") then
                                inst:AddTag("noplayertarget")
                            end
                        else
                            if inst:HasTag("noplayertarget") then
                                inst:RemoveTag("noplayertarget")
                            end
                        end
                    end

                    -- Hook SetBeefBellOwner
                    local old_SetBeefBellOwner = inst.SetBeefBellOwner
                    inst.SetBeefBellOwner = function(self, bell, bell_user)
                        local success, err = old_SetBeefBellOwner(self, bell, bell_user)
                        if success then
                            UpdateNoPlayerTarget()
                        end
                        return success, err
                    end

                    -- Hook removal callback
                    inst:ListenForEvent("stopfollowing", function()
                        if inst:HasTag("noplayertarget") then
                            inst:RemoveTag("noplayertarget")
                        end
                    end)

                    -- Ensure initial state
                    UpdateNoPlayerTarget()
                end)
            end
        end

        -- protect Pearl and lavae_pet from Ice Flingomatic
        AddPrefabPostInit("firesuppressor", function(inst)
            if not TheWorld.ismastersim then
                return
            end

            if inst.components.wateryprotection then
                inst:DoTaskInTime(0, function()
                    inst.components.wateryprotection:AddIgnoreTag("hermitcrab")
                    inst.components.wateryprotection:AddIgnoreTag("lavae_pet")
                end)
            end
        end)
    end

    -- follower item map icon settings
    if REVEAL_FOLLOWERS then
        local PROTECTED_MOB_ITEMS = {
            "glommerflower",
            "fruitflyfruit",
            "chester_eyebone",
            "cfe_eyebone",
            "hutch_fishbowl",
            "lavae_tooth",
            "beef_bell",
            "shadow_beef_bell",
        }

        local function UpdateIcon(inst)
            if inst.icon == nil then
                inst.icon = SpawnPrefab("globalmapicon")
                inst.icon:TrackEntity(inst)
            end
        end

        local function GetMapIcon(inst)
            if inst.prefab == "glommerflower" then
                return "glommerflower.tex"
            elseif inst.prefab == "fruitflyfruit" then
                return "fruitflyfruit.tex"
            elseif inst.prefab == "chester_eyebone" then
                return "chester_eyebone.tex"
            elseif inst.prefab == "cfe_eyebone" then
                return "cfe_eyebone.tex"
            elseif inst.prefab == "hutch_fishbowl" then
                return "hutch_fishbowl.tex"
            elseif inst.prefab == "lavae_tooth" then
                return "lavae_tooth.tex"
            elseif inst.prefab == "beef_bell" then
                return "beef_bell.tex"
            elseif inst.prefab == "shadow_beef_bell" then
                return "shadow_beef_bell.tex"
            end
        end

        local function SetMapIcon(inst)
            inst.entity:AddTransform()
            inst.entity:AddMiniMapEntity()
            inst.MiniMapEntity:SetIcon(GetMapIcon(inst))
            inst.MiniMapEntity:SetCanUseCache(false)
            inst.MiniMapEntity:SetDrawOverFogOfWar(true)

            if not TheWorld.ismastersim then
                return inst
            end

            -- set icon tracking
            inst.icon = nil
            inst:DoTaskInTime(0, UpdateIcon)
        end

        for _, prefab_name in ipairs(PROTECTED_MOB_ITEMS) do
            AddPrefabPostInit(prefab_name, SetMapIcon)
        end
    end
end