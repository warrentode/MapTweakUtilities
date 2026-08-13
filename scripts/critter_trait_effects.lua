-- custom critter trait effects feature

return function(AddPrefabPostInit, AddSimPostInit, CRAFTING_FILTERS, TUNING, ACTIONS, modprint)
    -- dynamically set the table of critters, this way we grab even the modded ones added to the rock den
    local critters = {}
    for _, recipe_name in ipairs(CRAFTING_FILTERS.CRAFTING_STATION.recipes or {}) do
        if recipe_name:match("^critter_.*_builder$") then
            table.insert(critters, (recipe_name:gsub("_builder$", "")))
        end
    end
    -- add woby to the critter table
    table.insert(critters, "wobysmall")
    table.insert(critters, "wobybig")

    for _, prefab in ipairs(critters) do
        AddPrefabPostInit(prefab, function(inst)
            modprint("AddPrefabPostInit fired for Critter Effect Parsing")
            if not TheWorld.ismastersim then
                return
            end

            local CRITTER_TRAIT_EFFECT_DURATION = TUNING.CRITTER_HUNGERTIME / 2

            --- special handling for wobysmall ---
            if inst.prefab == "wobysmall" then
                -- track the current dominant trait so it can be locked in when she grows
                inst:ListenForEvent("crittertraitchanged", function(inst, data)
                    local owner = inst._playerlink
                    if owner then
                        owner.mtu_woby_trait = data and data.trait
                    end
                end)

                -- LinkToPlayer runs on the new form after every transformation,
                -- so arriving as small means she just shrank: clear the lock
                local old_link = inst.LinkToPlayer
                inst.LinkToPlayer = function(inst, player, ...)
                    player.mtu_woby_trait = nil
                    return old_link(inst, player, ...)
                end
            end

            -- critter trait effects set up
            inst:ListenForEvent("oneat", function(inst)
                modprint("oneat event fired for Critter Effects")
                local owner = inst._playerlink or (inst.components.follower and inst.components.follower:GetLeader())
                if owner == nil or not owner:HasTag("player") then
                    return -- skipping critters that belong to Pearl
                end

                --- special handling for wobybig ---
                local trait = (inst.components.crittertraits and inst.components.crittertraits.dominanttrait) or owner.mtu_woby_trait
                modprint("Critter Trait Found", tostring(trait))

                if trait == nil then
                    return -- abort if there is no dominant trait present
                end

                --- special handling for multi pets, including woby ---
                -- this means the first pet fed that applies an effect becomes the active source
                if owner:HasTag("mtu_pet_effect") and owner.mtu_pet_effect_source ~= inst then
                    return -- another pet already has an active effect on the player, so we cancel out here
                end
                owner:AddTag("mtu_pet_effect")
                owner.mtu_pet_effect_source = inst

                -- placed after all other gating checks have passed since the timer is only needed for the pet that applies the effect
                local timer = inst.components.timer
                if timer:TimerExists("critter_trait_effect") then
                    timer:SetTimeLeft("critter_trait_effect", CRITTER_TRAIT_EFFECT_DURATION)
                else
                    timer:StartTimer("critter_trait_effect", CRITTER_TRAIT_EFFECT_DURATION)
                end

                -- apply effect based on trait here
                if trait == "WELLFED" then
                    if inst.components.sanityaura == nil then
                        inst:AddComponent("sanityaura")
                    end
                    inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY

                    modprint("Critter Trait Effect Applied for WELLFED")
                end

                if trait == "CRAFTY" then
                    if not owner:HasTag("mtu_fastbuilder") and not owner:HasTag("mtu_hungrybuilder")
                            and owner:HasTag("fastbuilder") and not owner:HasTag("hungrybuilder") then
                        owner:RemoveTag("mtu_pet_effect")
                        owner.mtu_pet_effect_source = nil
                        return -- modded characters with this designed effect already builtin, so nothing to apply
                    end
                    if not owner:HasTag("mtu_fastbuilder") and not owner:HasTag("mtu_hungrybuilder")
                            and owner:HasTag("fastbuilder") and owner:HasTag("hungrybuilder") then
                        -- this would be winona or a winona style character
                        owner:AddTag("mtu_hungrybuilder")
                        owner:RemoveTag("hungrybuilder")

                        modprint("Critter Trait Effect Applied for CRAFTY")
                    end
                    if not owner:HasTag("mtu_fastbuilder") and not owner:HasTag("mtu_hungrybuilder")
                            and not owner:HasTag("fastbuilder") and owner:HasTag("hungrybuilder") then
                        -- edge case modded character
                        -- not sure why someone would apply hungrybuilder to their character without fastbuilder, but it's covered
                        owner:AddTag("mtu_fastbuilder")
                        owner:AddTag("fastbuilder")
                        owner:AddTag("mtu_hungrybuilder")
                        owner:RemoveTag("hungrybuilder")

                        modprint("Critter Trait Effect Applied for CRAFTY")
                    end
                    if not owner:HasTag("mtu_fastbuilder") and not owner:HasTag("mtu_hungrybuilder")
                            and not owner:HasTag("fastbuilder") and not owner:HasTag("hungrybuilder") then
                        -- all other characters
                        owner:AddTag("mtu_fastbuilder")
                        owner:AddTag("fastbuilder")

                        modprint("Critter Trait Effect Applied for CRAFTY")
                    end
                end

                if trait == "COMBAT" then
                    owner.components.playerspeedmult:SetSpeedMult(inst, TUNING.RUINS_BAT_SPEED_MULT)

                    modprint("Critter Trait Effect Applied for COMBAT")
                end

                if trait == "PLAYFUL" then
                    local leader = owner and owner.components.leader
                    if leader and leader.loyaltyeffectiveness ~= nil then
                        -- if some other mod is setting this value, then we want to add onto it rather than overwrite it
                        leader.loyaltyeffectiveness = leader.loyaltyeffectiveness + 0.5

                        modprint("Critter Trait Effect Applied for PLAYFUL")
                    elseif leader and leader.loyaltyeffectiveness == nil then
                        -- if no other mods are setting this value, then we set it here
                        leader.loyaltyeffectiveness = 1.5

                        modprint("Critter Trait Effect Applied for PLAYFUL")
                    end
                end
            end)

            inst:ListenForEvent("timerdone", function(inst, data)
                if data ~= nil and data.name == "critter_trait_effect" then
                    local owner = inst._playerlink or (inst.components.follower and inst.components.follower:GetLeader())

                    if owner == nil or owner.mtu_pet_effect_source ~= inst then
                        return -- not this pet's effect to clear
                    end

                    modprint("Critter Trait Effects Removed")

                    -- clear trait effects here, and yes, since it should only ever be one pet applying an effect, we clear everything on in case something got missed somehow
                    if inst.components.sanityaura ~= nil then
                        inst:RemoveComponent('sanityaura')
                    end

                    if owner ~= nil and owner:HasTag("mtu_hungrybuilder") then
                        owner:RemoveTag("mtu_hungrybuilder")
                        owner:AddTag("hungrybuilder")
                    end
                    if owner ~= nil and owner:HasTag("mtu_fastbuilder") then
                        owner:RemoveTag("mtu_fastbuilder")
                        owner:RemoveTag("fastbuilder")
                    end

                    local leader = owner and owner.components.leader
                    if leader and leader.loyaltyeffectiveness then
                        leader.loyaltyeffectiveness = leader.loyaltyeffectiveness - 0.5
                        if leader.loyaltyeffectiveness == 1 then
                            leader.loyaltyeffectiveness = nil
                        end
                    end

                    if owner ~= nil and owner.components.playerspeedmult then
                        owner.components.playerspeedmult:RemoveSpeedMult(inst)
                    end

                    owner:RemoveTag("mtu_pet_effect")
                    owner.mtu_pet_effect_source = nil
                end
            end)
        end)
    end

    AddSimPostInit(function()
        --- only applies to non-woby critters since this action is removed from her
        if ACTIONS.TRANSFER_CRITTER then
            local old_fn = ACTIONS.TRANSFER_CRITTER.fn
            ACTIONS.TRANSFER_CRITTER.fn = function(act)
                local result = old_fn(act)

                if result then
                    local owner = act.doer
                    local pet = act.target
                    local leader = owner and owner.components.leader

                    -- apply critter effect timerdone
                    if owner.components.petleash ~= nil and pet.components.crittertraits ~= nil then
                        if owner == nil or owner.mtu_pet_effect_source ~= pet then
                            return -- not this pet's effect to clear here either
                        end
                        if pet.components.sanityaura ~= nil then
                            pet:RemoveComponent('sanityaura')
                        end

                        if owner ~= nil and owner:HasTag("mtu_hungrybuilder") then
                            owner:RemoveTag("mtu_hungrybuilder")
                            owner:AddTag("hungrybuilder")
                        end
                        if owner ~= nil and owner:HasTag("mtu_fastbuilder") then
                            owner:RemoveTag("mtu_fastbuilder")
                            owner:RemoveTag("fastbuilder")
                        end

                        if leader and leader.loyaltyeffectiveness then
                            leader.loyaltyeffectiveness = leader.loyaltyeffectiveness - 0.5
                            if leader.loyaltyeffectiveness == 1 then
                                leader.loyaltyeffectiveness = nil
                            end
                        end

                        if owner ~= nil and owner.components.playerspeedmult then
                            owner.components.playerspeedmult:RemoveSpeedMult(pet)
                        end

                        if owner:HasTag("mtu_pet_effect") then
                            owner:RemoveTag("mtu_pet_effect")
                        end

                        if owner.mtu_pet_effect_source ~= nil then
                            owner.mtu_pet_effect_source = nil
                        end
                    end
                end

                return result
            end
        end
    end)
end