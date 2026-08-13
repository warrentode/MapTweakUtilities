-- patch to make removing a wormhole with the worm boss mouth give you the boss mouth item
return function(AddSimPostInit, ACTIONS)
    AddSimPostInit(function()
        if ACTIONS.REMOVEHOLEBYMOUTH then
            local old_fn = ACTIONS.REMOVEHOLEBYMOUTH.fn
            ACTIONS.REMOVEHOLEBYMOUTH.fn = function(act)
                local result = old_fn(act)

                -- give back the worm mouth to the player if removed
                if act.invobject and act.invobject.prefab == "boss_worm_mouth" and act.doer and act.doer.components.inventory then
                    act.doer.components.inventory:GiveItem(act.invobject)
                end

                return result
            end
        end
    end)
end