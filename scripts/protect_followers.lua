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
        }

        SetSharedLootTable("lavae_coccon", {{"lavae_tooth", 1.00}})

        local function ReviveLavaePet(inst)
            if not TheWorld.ismastersim then
                return inst
            end

            MakeSmallBurnable(inst, nil, nil, true)
            MakeMediumPropagator(inst)

            inst:AddComponent("lootdropper")
            inst.components.lootdropper:SetChanceLootTable("lavae_coccon")
        end

        local function BeefaloCanBeAttackedByPlayer(inst, attacker)
            if attacker ~= nil and attacker:HasTag("player") then
                if inst.components.follower ~= nil and inst.components.follower.leader ~= nil then
                    local leader = inst.components.follower.leader
                    if leader:HasTag("bell") or leader:HasTag("shadowbell") then
                        return false
                    end
                end
            end
            return true
        end

        -- make chesters and hutches invincible
        TUNING.CHESTER_HEALTH = 99999
        TUNING.CHESTER_RESPAWN_TIME = .1
        TUNING.CHESTER_HEALTH_REGEN_AMOUNT = 99999
        TUNING.CHESTER_HEALTH_REGEN_PERIOD = .1

        TUNING.HUTCH_HEALTH = 99999
        TUNING.HUTCH_RESPAWN_TIME = .1
        TUNING.HUTCH_HEALTH_REGEN_AMOUNT = 99999
        TUNING.HUTCH_HEALTH_REGEN_PERIOD = .1

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
                -- remove freezing for each mob except the lavae_pet
                if inst.components.freezable and inst.prefab ~= "lavae_pet" then
                    inst:RemoveComponent("freezable")
                end
                -- remove freezing and burning
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
            else
                -- set the beefalo specific protection
                if inst.components.combat then
                    inst.components.combat.CanBeAttacked = function(attacker)
                        return BeefaloCanBeAttackedByPlayer(inst, attacker)
                    end
                end
            end
        end

        for _, prefab_name in ipairs(PROTECTED_MOBS) do
            AddPrefabPostInit(prefab_name, ProtectMob)
            if prefab_name == "lavae_pet" then
                AddPrefabPostInit("lavae_cocoon", ReviveLavaePet)
            end
        end
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