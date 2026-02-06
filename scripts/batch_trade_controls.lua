-- custom settings for batch trading

return function(AddPrefabPostInit, ACTIONS, config)
    local BATCH_TRADES_ENABLED = config.BATCH_TRADES_ENABLED

    -- Rewrite the given action.
    local old_give_fn = ACTIONS.GIVE.fn
    ACTIONS.GIVE.fn = function(act)
        if not BATCH_TRADES_ENABLED then
            return old_give_fn(act)
        end
        -- Batch assignment to recipients
        if act.target and (act.target.prefab == "birdcage" or act.target.prefab == "pigking"
                or act.target.prefab == "mermking" or act.target.prefab == "antlion") then
            -- Can it be given, and why?
            local able, reason = act.target.components.trader:AbleToAccept(act.invobject, act.doer)
            -- If it cannot be provided
            if not able then
                return false, reason
            end
            -- Quantity of items given
            local count = (act.invobject and act.invobject.components and act.invobject.components.stackable) and act.invobject.components.stackable:StackSize() or 1
            -- Special items can only be given out one at a time, such as the golden belt; you can't give out 10 of them in a single event.
            if act.invobject.prefab == "pig_token" or act.invobject.prefab == "moonglass_charged" then
                count = 1
            end
            act.target.components.trader:AcceptGift(act.doer, act.invobject, count)
            return true
        end
        return old_give_fn(act)
    end

    AddPrefabPostInit("mermking", function(inst)
        -- Batch trading
        local old_TradeItem = inst.TradeItem
        inst.TradeItem = function(inst)
            local giver = inst.tradegiver
            local item = inst.itemtotrade
            local count = (item.components and item.components.stackable) and item.components.stackable:StackSize() or 1
            for _ = 1, count do
                inst.tradegiver = giver
                inst.itemtotrade = item
                old_TradeItem(inst)
            end
        end
        -- Batch Feeding
        if inst.components.trader and inst.components.trader.onaccept then
            local old_onaccept = inst.components.trader.onaccept
            inst.components.trader.onaccept = function(inst, giver, item)
                local count = (item.components and item.components.stackable) and item.components.stackable:StackSize() or 1
                for _ = 1, count do
                    old_onaccept(inst, giver, item)
                end
            end
        end
    end)

    AddPrefabPostInit("pigking", function(inst)
        if inst.components.trader and inst.components.trader.onaccept then
            local old_onaccept = inst.components.trader.onaccept
            inst.components.trader.onaccept = function(inst, giver, item)
                local count = (item.components and item.components.stackable) and item.components.stackable:StackSize() or 1
                for _ = 1, count do
                    old_onaccept(inst, giver, item)
                end
            end
        end
    end)

    AddPrefabPostInit("birdcage", function(inst)
        if inst.components.trader and inst.components.trader.onaccept then
            local old_onaccept = inst.components.trader.onaccept
            inst.components.trader.onaccept = function(inst, giver, item)
                local count = (item.components and item.components.stackable) and item.components.stackable:StackSize() or 1
                for _ = 1, count do
                    old_onaccept(inst, giver, item)
                end
            end
        end
    end)

    AddPrefabPostInit("antlion", function(inst)
        if inst.components.trader and inst.components.trader.onaccept then
            local old_onaccept = inst.components.trader.onaccept
            inst.components.trader.onaccept = function(inst, giver, item)
                local count = (item.components and item.components.stackable) and item.components.stackable:StackSize() or 1
                for _ = 1, count do
                    old_onaccept(inst, giver, item)
                    inst:GiveReward()
                end
            end
        end
    end)
end