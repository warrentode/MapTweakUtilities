-- custom auto stump removal feature

return function(AddPrefabPostInit, AddPrefabPostInitAny, AddSimPostInit, modprint)
    -- sets preset stump checklist for tagging as added stumps
    local stumpCheckList = {
        "evergreen",
        "evergreen_sparse",
        "twiggytree",
        "deciduoustree",
        "deciduoustree_stump",
        "moon_tree",
        "palmconetree",
        "mushtree_tall",
        "mushtree_medium",
        "mushtree_small",
        "mushtree_tall_webbed",
        "cave_banana_tree",
        "mushtree_moon",
        "livingtree",
        "marsh_tree"
    }

    -- add the added stumps tag to prefabs inside preset checklist
    for _, v in ipairs(stumpCheckList) do
        AddPrefabPostInit(v, function(inst)
            if not inst:HasTag("mtu_added_stumps") then
                inst:AddTag("mtu_added_stumps")
            end
        end)
    end

    -- sets preset excluded stump list
    --- the ancient trees here are excluded because their stumps use a loot table instead of the lootdropper and I don't want to juggle that
    local mtu_excluded_stumps = {
        "ancienttree_gem",
        "ancienttree_nightvision"
    }

    -- add exclude stump tag to prefabs inside preset excluded stump list
    for _, v in ipairs(mtu_excluded_stumps) do
        AddPrefabPostInit(v, function(inst)
            if not inst:HasTag("mtu_excluded_stumps") then
                inst:AddTag("mtu_excluded_stumps")
            end
        end)
    end

    local function dropStumpLoot(inst)
        -- handle stump loot if component exists
        --- prints for the drops are here for debugging for now
        if inst.components.lootdropper then
            modprint("Calling custom stump loot dropper")
            if inst.prefab == "livingtree" then
                modprint("Detected  " .. tostring(inst) .. " dropping 1 livinglog")
                inst.components.lootdropper:SpawnLootPrefab("livinglog")
            elseif inst.prefab == "deciduoustree" or inst.prefab == "deciduoustree_stump" then
                if inst.monster then
                    modprint("Detected  " .. tostring(inst) .. " dropping 1 livinglog")
                else
                    modprint("Detected  " .. tostring(inst) .. " dropping 1 log")
                end
                inst.components.lootdropper:SpawnLootPrefab(inst.monster and "livinglog" or "log")
            elseif inst.prefab == "palmconetree" or inst.prefab == "moon_tree" then
                if inst.stage == 1 then
                    modprint("Detected  " .. tostring(inst.stage) .. tostring(inst) .. " dropping 1 log")
                    inst.components.lootdropper:SpawnLootPrefab("log")
                else
                    modprint("Detected  " .. tostring(inst) .. " dropping 2 logs")
                    inst.components.lootdropper:SpawnLootPrefab("log")
                    inst.components.lootdropper:SpawnLootPrefab("log")
                end
            else
                -- default drop
                modprint("Detected  " .. tostring(inst) .. " dropping 1 log")
                inst.components.lootdropper:SpawnLootPrefab("log")
            end
        else
            -- skip if component doesn't exist on the prefab
            modprint(tostring(inst) .. " does not have the lootdropper component")
        end
    end

    -- handle the auto removal of pre-existing stumps
    AddSimPostInit(function()
        if not TheWorld.ismastersim then
            return
        end

        -- delay this task until after world load so auto stacking will work on the dropped stump loot
        TheWorld:DoTaskInTime(1, function()
            --- keeping prints here for now for later testing before public release
            for _, v in pairs(Ents) do
                if v:IsValid() and v:HasTag("stump") and (not string.find(v.prefab, "^ancienttree_") and not v:HasTag("mtu_excluded_stumps")) then
                    modprint("Calling custom stump loot dropper for pre-feature existing " .. tostring(v))
                    -- call custom stump loot dropper
                    dropStumpLoot(v)

                    -- set tree/stump untouchable at this point
                    v:AddTag("NOCLICK")
                    -- remove the stump itself with a delayed task
                    modprint("Setting task to remove pre-feature existing stump for " .. tostring(v))
                    v:DoTaskInTime(4, v.Remove)
                end
            end
        end)
    end)

    -- handler for the auto removal of newly made stumps by checklist table and tag to allow other modders to add prefabs to the filters
    AddPrefabPostInitAny(function(inst)
        if not TheWorld.ismastersim then
            return
        end

        -- cancel out if the prefab has both tags with a special log print
        if inst:HasTag("mtu_excluded_stumps") and inst:HasTag("mtu_added_stumps") then
            --- this print log is the only one to actually keep after testing to help users troubleshoot why a tree is excluded despite having the added tag
            modprint("WARNING: " .. tostring(inst) .. " HAS BOTH mtu_added_stumps and mtu_excluded_stumps TAGS, WILL BE EXCLUDED FROM AUTO STUMP REMOVAL AS A RESULT!")
            return
            -- cancel out silently if prefab has neither tag since we are assuming here it's not a tree otherwise a print would spam the log file
        elseif not inst:HasTag("mtu_excluded_stumps") and not inst:HasTag("mtu_added_stumps") then
            return
            -- cancel out silently if prefab has just the exclude tag
        elseif inst:HasTag("mtu_excluded_stumps") then
            return
            -- set up workable callback for prefabs that have just the added stump tag
        elseif inst:HasTag("mtu_added_stumps") then
            -- check if component exists
            if inst.components.workable then
                -- grab the old finish function
                local old_onfinish = inst.components.workable.onfinish or nil

                local function new_onfinish(inst, chopper)
                    -- call the logic of the old finish function
                    if old_onfinish then
                        old_onfinish(inst,chopper)
                    end

                    -- call custom stump loot dropper
                    dropStumpLoot(inst)

                    -- set tree/stump untouchable at this point
                    inst:AddTag("NOCLICK")
                    -- remove the stump itself with a delayed task
                    inst:DoTaskInTime(4, inst.Remove)
                end

                -- set the new function as the prefab finish callback
                inst.components.workable:SetOnFinishCallback(new_onfinish)
            end
        end
    end)
end