-- custom perish settings
return function(AddPrefabPostInit, TUNING, config)
    -- dried food perish settings
    if config.INCREASE_DRIED_PERISH then
        local dried_foods = {
            "meat_dried",
            "smallmeat_dried",
            "monstermeat_dried",
            "humanmeat_dried",
            "fishmeat_small_dried",
            "fishmeat_dried",
            "plantmeat_dried",
            "kelp_dried"
        }

        for _, v in ipairs(dried_foods) do
            AddPrefabPostInit(v, function(inst)
                if inst.components.perishable then
                    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW * 2)
                end
            end)
        end
    end

    -- disguises perish settings
    if config.DISGUISE_NONPERISH then
        local disguises = {
            "ghostflowerhat",
            "mermhat",
            "disguisehat",
            "beefalohat",
            "spiderhat"
        }

        for _, v in ipairs(disguises) do
            AddPrefabPostInit(v, function(inst)
                if not TheWorld.ismastersim then
                    return
                end

                if inst.components.perishable then
                    if inst:HasTag("show_spoilage") then
                        inst:RemoveTag("show_spoilage")
                        inst:AddTag("hide_percentage")
                    end
                    inst.components.perishable:StopPerishing()
                end
                if inst.components.fueled then
                    inst:RemoveComponent("fueled")
                end
            end)
        end
    end

    -- spiderhat specific patch so it doesn't steal from webber's followers
    AddPrefabPostInit("spiderhat", function(inst)
        if not TheWorld.ismastersim then
            return
        end

        local function safe_spider_update(inst)
            local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
            if owner and owner.components.leader then
                owner.components.leader:RemoveFollowersByTag("pig")
                local x, y, z = owner.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(x, y, z, TUNING.SPIDERHAT_RANGE, "spider")
                for _, v in pairs(ents) do
                    local leader = v.components.follower and v.components.follower:GetLeader()
                    if v.components.follower
                            and not owner.components.leader:IsFollower(v)
                            and owner.components.leader.numfollowers < 10
                            and (not leader or not leader:HasTag("spiderwhisperer"))
                    then
                        owner.components.leader:AddFollower(v)
                    end
                end
            end
        end

        inst._spider_update = safe_spider_update
        if inst.updatetask then
            inst.updatetask:Cancel()
            inst.updatetask = inst:DoPeriodicTask(0.5, safe_spider_update, 1)
        end
    end)
end