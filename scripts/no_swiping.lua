-- custom item protections logic

return function(Prefabs, AddPrefabPostInit, AddStategraphPostInit, AddSimPostInit, ACTIONS, EQUIPSLOTS, FRAMES, debug, config, modprint)
    local ALLOW_SLURTLE_EATING = config.ALLOW_SLURTLE_EATING
    local ALLOW_WORM_BOSS_EATING = config.ALLOW_WORM_BOSS_EATING

    local THIEF_PREFABS = {
        "monkey",
        "powder_monkey",
        "prime_mate",
        "frog",
        "lunarfrog",
        "otter",
        "mossling",
        "krampus",
        "bearger",
        "slurtle",
        "snurtle",
        "perd",
        "mole",
    }

    -- Tag mobs as thieves
    for _, prefab in ipairs(THIEF_PREFABS) do
        AddPrefabPostInit(prefab, function(inst)
            if not TheWorld.ismastersim then
                return
            end

            -- Tag as thief if not already
            if not inst:HasTag("thief") then
                inst:AddTag("thief")
            end
        end)
    end

    -- Override eat actions for tagged mobs
    local oldEatValid = ACTIONS.EAT.validfn
    ACTIONS.EAT.validfn = function(action)
        local doer = action.doer
        if doer then
            if ALLOW_SLURTLE_EATING and doer:HasTag("slurtle") then
                return oldEatValid and oldEatValid(action) or true
            end
            if doer:HasTag("thief") then
                return false
            end
        end
        return oldEatValid and oldEatValid(action) or true
    end

    -- Override steal mole bait action for tagged mobs
    local oldMoleBaitValid = ACTIONS.STEALMOLEBAIT.validfn
    ACTIONS.STEALMOLEBAIT.validfn = function(action)
        local doer = action.doer
        if doer and doer:HasTag("thief") then
            return false
        end
        return oldMoleBaitValid and oldMoleBaitValid(action) or true
    end

    -- Override tinker actions for tagged mobs
    local oldAnchorValid = ACTIONS.LOWER_ANCHOR.validfn
    local oldSailValid = ACTIONS.RAISE_SAIL.validfn
    local oldHammerValid = ACTIONS.HAMMER.validfn

    ACTIONS.LOWER_ANCHOR.validfn = function(action)
        local doer = action.doer
        if doer and doer:HasTag("thief") then
            return false
        end
        return oldAnchorValid and oldAnchorValid(action) or true
    end
    ACTIONS.RAISE_SAIL.validfn = function(action)
        local doer = action.doer
        if doer and doer:HasTag("thief") then
            return false
        end
        return oldSailValid and oldSailValid(action) or true
    end
    ACTIONS.HAMMER.validfn = function(action)
        local doer = action.doer
        if doer and doer:HasTag("thief") then
            return false
        end
        return oldHammerValid and oldHammerValid(action) or true
    end

    -- Override pickup action for tagged mobs
    local oldActionValid = ACTIONS.PICKUP.validfn
    ACTIONS.PICKUP.validfn = function(action)
        local doer = action.doer
        if doer and doer:HasTag("thief") then
            return false
        end
        return oldActionValid and oldActionValid(action) or true
    end

    -- Override pick action for tagged mobs
    local oldPickValid = ACTIONS.PICK.validfn
    ACTIONS.PICK.validfn = function(action)
        local doer = action.doer
        if doer and doer:HasTag("thief") then
            return false
        end
        return oldPickValid and oldPickValid(action) or true
    end

    -- Override harvest action for tagged mobs
    local oldHarvestValid = ACTIONS.HARVEST.validfn
    ACTIONS.HARVEST.validfn = function(action)
        local doer = action.doer
        if doer and doer:HasTag("thief") then
            return false
        end
        return oldHarvestValid and oldHarvestValid(action) or true
    end

    -- Override steal action for tagged mobs
    local old_validfn = ACTIONS.STEAL.validfn
    ACTIONS.STEAL.validfn = function(action)
        local doer = action.doer
        if doer and doer:HasTag("thief") then
            -- Thieves can't steal anything
            return false
        end

        -- Preserve normal behavior for everyone else
        if old_validfn then
            return old_validfn(action)
        end

        return true
    end

    -- Override the thief component's StealItem globally
    local Thief = require("components/thief")
    local oldStealItem = Thief.StealItem
    Thief.StealItem = function(self, victim, itemtosteal, attack)
        -- Block all theft for mobs tagged "thief"
        if self.inst and self.inst:HasTag("thief") then
            return false
        end

        -- Otherwise call the original function
        return oldStealItem(self, victim, itemtosteal, attack)
    end

    -- Override for Catcoon ground pickup
    local oldValid = ACTIONS.CATPLAYGROUND.validfn
    ACTIONS.CATPLAYGROUND.validfn = function(action)
        local doer = action.doer
        -- Block ground pickup only for Catcoons
        if doer and doer.prefab == "catcoon" then
            return false
        end
        -- Otherwise preserve original behavior
        return oldValid and oldValid(action) or true
    end

    -- Override cutlass theft function
    AddPrefabPostInit("cutless", function(inst)
        if not TheWorld.ismastersim then
            return
        end

        local old_onattack = inst.components.weapon.onattack
        inst.components.weapon:SetOnAttack(function(inst, attacker, target)
            if attacker and attacker:HasTag("player") and (target and not target:HasTag("player")) then
                -- allow the player to steal from mobs but not other players
                if old_onattack then
                    old_onattack(inst, attacker, target)
                end
            else
                -- skip cutlass stealing from target
                return
            end
        end)
    end)

    -- Override for Slurper
    local function equip_fn(inst)
        local target = inst.components.combat.target
        if target and target:IsValid() and inst:IsNear(target, 2) and
                inst.HatTest and inst:HatTest(target) then

            local oldhat = target.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
            if oldhat then
                if target:HasTag("player") then
                    target.components.inventory:GiveItem(oldhat) --give or drop
                else
                    --don't get stuck in follower inventory
                    target.components.inventory:DropItem(oldhat)
                end
            end
            target.components.inventory:Equip(inst)
        end
    end
    local function no_drop_hat(self)
        for _, v in ipairs(self.states.headslurp.timeline) do
            if v.time == 24 * FRAMES then
                --equip fn located here
                v.fn = equip_fn
                return
            end
        end
    end
    AddStategraphPostInit("slurper", function(self)
        no_drop_hat(self)
    end)
    local function CanHatTarget(inst, target)
        --fail if existing hat
        if target and target.components.inventory and
                (target.components.inventory.isopen or
                        target:HasTag("pig") or target:HasTag("manrabbit") or target:HasTag("equipmentmodel") or
                        (inst._loading and target:HasTag("player"))) then

            return not target.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        end
        return false
    end
    AddPrefabPostInit("slurper", function(inst)
        inst.HatTest = CanHatTarget
    end)

    -- Upvalue helpers

    ---Based on Rezecib's UpvalueHacker (but won't crash the game):
    ---https://github.com/rezecib/Rezecib-s-Rebalance/blob/d4a41b0c28a117c1a4efadf220347a6db7164bb3/scripts/tools/upvaluehacker.lua
    ---If returns nil, second return is error message. Just concat it after the name of your starting fn and print.
    local function GetUpvalue(fn, ...)
        if type(fn) ~= "function" then
            return nil, " wasn't function (" .. type(fn) .. ")!"
        end
        local scope_fn = fn
        local cur_name, cur_fn
        for k, v in ipairs({...}) do
            local i = 0
            repeat
                i = i + 1
                cur_name, cur_fn = debug.getupvalue(scope_fn, i)
                if not cur_name then
                    return nil, " -> " .. table.concat({...}, " -> ", 1, k) .. " not found!"
                end
            until cur_name == v
            scope_fn = cur_fn
        end
        return scope_fn
    end

    ---Find scope_fn with GetUpvalue first before calling.
    ---If a fn with fn_name is found in scope_fn, will replace the fn with new_fn and return true.
    local function SetUpvalue(scope_fn, new_fn, fn_name)
        if type(scope_fn) ~= "function" or type(new_fn) ~= "function" then
            return false
        end
        local i, cur_name = 0
        repeat
            i = i + 1
            cur_name = debug.getupvalue(scope_fn, i)
            if not cur_name then
                return false
            end
        until cur_name == fn_name
        debug.setupvalue(scope_fn, i, new_fn)
        return true
    end

    -- Override for Icker
    local function OnCollectEquip(item, inst, ret)
        local gear = item.components.equippable
        if not gear then
            return
        end

        if gear.equipslot == EQUIPSLOTS.HANDS then
            return -- can't fumble weapons/tools
        else
            return -- protected armor/backpack
        end

        if gear:ShouldPreventUnequipping() or gear:IsRestricted(inst) or item:HasTag("nosteal") then
            return -- special item
        end

        table.insert(ret, item)
    end
    AddPrefabPostInit("gelblob", function(_)
        local scope_fn, err_msg = GetUpvalue(Prefabs.gelblob.fn, "OnSuspendedPlayerDied", "StealSuspendedEquip")
        if not scope_fn then
            modprint("Prefabs.gelblob.fn" .. err_msg)
            return
        end

        if not SetUpvalue(scope_fn, OnCollectEquip, "CollectEquip") then
            modprint("Prefabs.gelblob.fn -> OnSuspendedPlayerDied -> StealSuspendedEquip -> CollectEquip not found!")
        end
    end)

    -- Override for Great Depths Worm if this is set to true
    if ALLOW_WORM_BOSS_EATING then
        -- do nothing if the worm boss is allowed to eat things
    else
        local WORMBOSS_UTILS = require("prefabs/worm_boss_util")
        local function OnCollectThingsToEat(_, _)
            return false  -- Don't allow the worm to eat anything
        end
        local function DevourOverride()
            -- Get the original function and upvalue we want to patch
            local old_fn, err_msg = GetUpvalue(WORMBOSS_UTILS.EmergeHead, "CollectThingsToEat")
            if not old_fn then
                modprint("WORMBOSS_UTILS.EmergeHead -> CollectThingsToEat not found! " .. tostring(err_msg))
                return
            end
            -- Now, patch the function we need to modify (CollectThingsToEat)
            if not SetUpvalue(WORMBOSS_UTILS.EmergeHead, OnCollectThingsToEat, "CollectThingsToEat") then
                modprint("Failed to patch CollectThingsToEat!")
            else
                modprint("Successfully patched CollectThingsToEat!")
            end
        end
        AddSimPostInit(DevourOverride) -- Modify worm_boss_util
    end

end