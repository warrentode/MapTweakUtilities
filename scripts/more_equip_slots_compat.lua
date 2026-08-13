-- mod compat file for more equip slots+ mod
return function(AddPrefabPostInit, MESMODDED, EQUIPSLOTS)
    ---------- CUSTOM PATCH FOR WEBBER BACKPACK ----------
    AddPrefabPostInit("webber_backpack", function(inst)
        if not TheWorld.ismastersim then
            return
        end

        if EQUIPSLOTS and EQUIPSLOTS.BACKPACK then
            inst.components.equippable.equipslot = EQUIPSLOTS.BACKPACK
        end
        if MESMODDED and MESMODDED.BACKPACKS then
            table.insert(MESMODDED.BACKPACKS, "webber_backpack")
        end
    end)
    ---------- WINTER COAT PATCH FOR PEARL ----------
    -- keep this patch here until the author of More Equip Slots+ adds it to their modmain
    AddPrefabPostInit("hermitcrab", function(inst)
        if not TheWorld.ismastersim then
            return
        end

        -- TASKS.GIVE_PUFFY_VEST is a file-local enum in hermitcrab.lua and Klei's
        -- own comment there says the ordering can't change, so the literal is safe
        local GIVE_PUFFY_VEST = 11

        local function iscoat(item)
            return item.components.insulator and
                    item.components.insulator:GetInsulation() >= TUNING.INSULATION_SMALL and
                    item.components.insulator:GetType() == SEASONS.WINTER and
                    item.components.equippable and
                    (item.components.equippable.equipslot == EQUIPSLOTS.BODY or
                            item.components.equippable.equipslot == EQUIPSLOTS.SHIRT)
        end

        local old_accepttest = inst.components.trader.test
        inst.components.trader:SetAcceptTest(function(inst, item)
            if TheWorld.state.issnowing and iscoat(item) then
                local bodyequipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
                local shirtequipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIRT)
                if inst.components.inventory:FindItem(iscoat) == nil and
                        not (bodyequipped and iscoat(bodyequipped)) and
                        not (shirtequipped and iscoat(shirtequipped)) then
                    return true
                end
                return false
            end
            return old_accepttest(inst, item)
        end)

        local old_onrefuse = inst.components.trader.onrefuse
        inst.components.trader.onrefuse = function(inst, giver, item)
            if iscoat(item) then
                local bodyequipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
                local shirtequipped = EQUIPSLOTS.SHIRT and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIRT)
                local coat = inst.components.inventory:FindItem(iscoat) or
                        (bodyequipped and iscoat(bodyequipped) and bodyequipped) or
                        (shirtequipped and iscoat(shirtequipped) and shirtequipped)
                if coat then
                    inst.components.npc_talker:Chatter("HERMITCRAB_REFUSE_COAT_HASONE", 1)
                elseif not TheWorld.state.issnowing then
                    inst.components.npc_talker:Chatter("HERMITCRAB_REFUSE_COAT", 1)
                end
                inst.sg:GoToState("refuse")
                return
            end
            old_onrefuse(inst, giver, item)
        end

        local old_onaccept = inst.components.trader.onaccept
        inst.components.trader.onaccept = function(inst, giver, item, count)
            -- vanilla's OnAcceptItem only equips BODY-slot coats, so a SHIRT-slot
            -- coat falls through its entire elseif chain and is never worn
            if TheWorld.state.issnowing and iscoat(item)
                    and not (inst.iscoat and inst.iscoat(item)) then
                inst.components.inventory:Equip(item)
                if inst.components.friendlevels then
                    inst.components.friendlevels:CompleteTask(GIVE_PUFFY_VEST)
                end
                return
            end
            return old_onaccept(inst, giver, item, count)
        end

        -- recover a coat she accepted but never equipped
        inst:DoTaskInTime(0, function()
            local bodyequipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
            local shirtequipped = EQUIPSLOTS.SHIRT and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIRT)
            if (bodyequipped and iscoat(bodyequipped)) or (shirtequipped and iscoat(shirtequipped)) then
                return
            end
            local coat = inst.components.inventory:FindItem(iscoat)
            if coat then
                inst.components.inventory:Equip(coat)
            end
        end)
    end)
end