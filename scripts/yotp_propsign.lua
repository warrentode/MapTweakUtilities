-- patches propsign behavior for the new year shrine recipe added for it
return function(AddPrefabPostInit, TUNING)
    AddPrefabPostInit("propsign", function(inst)
        -- change the vanilla override here to enable custom name and inspection strings
        inst:SetPrefabNameOverride("propsign")

        if not TheWorld.ismastersim then
            return
        end

        -- set to allow in inventory
        inst.components.inventoryitem.cangoincontainer = true

        -- these are craftable now, so no longer irreplaceable
        inst:RemoveTag("irreplaceable")
        -- make them stackable
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM

        -- cancel break propsign call
        inst.OnCancelMinigame = function()
            --- doing nothing here to prevent the sign from breaking when a minigame isn't active
        end
    end)
end