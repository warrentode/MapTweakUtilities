-- custom settings for stacking

return function(AddComponentPostInit, AddPrefabPostInitAny, config, MTU)
    local AUTO_STACK_ENABLED = config.AUTO_STACK_ENABLED
    local STACK_RADIUS = config.STACK_RADIUS

    local excluded_stack_items = {
        seeds = config.seeds,
        crumbs = config.crumbs,
        pigskin = config.pigskin,
        winter_food4 = config.winter_food4,
        powcake = config.powcake,
    }

    local function FindEntities(x, y, z)
        return TheSim:FindEntities(x, y, z, STACK_RADIUS, {'_stackable', }, {'INLIMBO', 'NOCLICK', 'penguin_egg', 'lootpump_oncatch', 'lootpump_onflight', })
    end

    local function Put(inst, item)
        if item == inst or item.prefab ~= inst.prefab or item.skinname ~= inst.skinname then
            return
        end

        SpawnPrefab('sand_puff').Transform:SetPosition(item.Transform:GetWorldPosition())
        inst.components.stackable:Put(item)
    end

    AddComponentPostInit('stackable', function(Stackable)
        local Get = Stackable.Get
        function Stackable:Get(...)
            local instance = Get(self, ...)
            if instance.xt_stack_task then
                instance.xt_stack_task:Cancel()
                instance.xt_stack_task = nil
            end
            return instance
        end
    end)


    AddPrefabPostInitAny(function(inst)
        if MTU.players_loaded == 0 then
            return
        end
        if not AUTO_STACK_ENABLED then
            return
        end
        if inst:HasTag('smallcreature') or inst:HasTag('heavy') or inst:HasTag('trap') or inst:HasTag('NET_workable') or excluded_stack_items[inst.prefab] then
            return
        end
        if inst.components.stackable == nil or inst:IsInLimbo() or inst:HasTag('NOCLICK') then
            return
        end
        inst.xt_stack_task = inst:DoTaskInTime(.5, function()
            if inst:HasTag('penguin_egg') then
                return
            end
            if inst.components.stackable == nil or inst:IsInLimbo() or inst:HasTag('NOCLICK') then
                return
            end
            if inst:IsValid() and not inst.components.stackable:IsFull() then
                for _, item in ipairs(FindEntities(inst.Transform:GetWorldPosition())) do
                    if item:IsValid() and not item.components.stackable:IsFull() then
                        Put(inst, item)
                    end
                end
            end
        end)
    end)

end