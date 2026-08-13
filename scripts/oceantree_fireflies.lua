-- oceantree_pillar fireflies feature
return function(AddPrefabPostInit, TWOPI, TUNING)
    -- the ocean tree pillar is the player planted version of the water tree pillar, so we are copying the firefly code from that
    local FIREFLY_MUST = {"firefly"}
    local FIREFLY_CANT = {"FX", "NOBLOCK", "NOCLICK", "DECOR", "flying", "boat", "walkingplank", "_inventoryitem", "structure"}
    local function OnPhaseChanged(inst, phase)
        if phase == "day" then

            local x, y, z = inst.Transform:GetWorldPosition()

            if TheSim:CountEntities(x,y,z, TUNING.SHADE_CANOPY_RANGE, FIREFLY_MUST) < 10 then
                if math.random()<0.7 then
                    local pos
                    local offset = nil
                    local count = 0
                    while offset == nil and count < 10 do
                        local angle = TWOPI*math.random()
                        local radius = math.random() * (TUNING.SHADE_CANOPY_RANGE -4)
                        offset = {x= math.cos(angle) * radius, y=0, z=math.sin(angle) * radius}
                        count = count + 1

                        pos = {x=x+offset.x,y=0,z=z+offset.z}

                        if TheSim:CountEntities(pos.x, pos.y, pos.z, 5, nil, FIREFLY_CANT) > 0 then
                            offset = nil
                        end
                    end

                    if offset then
                        local firefly = SpawnPrefab("fireflies")
                        firefly.Transform:SetPosition(x+offset.x,0,z+offset.z)
                    end
                end
            end
        end
    end

    -- now we add this function to the player version via postinit
    AddPrefabPostInit("oceantree_pillar", function(inst)
        inst:ListenForEvent("phasechanged", function(src, phase) OnPhaseChanged(inst,phase) end, TheWorld)
    end)
end