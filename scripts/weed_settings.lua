-- custom growth loop controls for weeds

return function(AddPrefabPostInitAny)
    AddPrefabPostInitAny(function(inst)
        if inst:HasTag("weed") and inst.components.growable and inst.components.growable.stages then
            for _, stage in ipairs(inst.components.growable.stages) do
                if stage.name == "bolting" and stage.fn then
                    local original_fn = stage.fn
                    stage.fn = function(inst, stage_num, stage_data)
                        -- Call the original function first
                        original_fn(inst, stage_num, stage_data)

                        -- Force the plant to keep growing after bolting
                        if inst.components.growable then
                            inst.components.growable:SetStage(1)
                            inst.components.growable:StartGrowing()
                            inst.components.growable.magicgrowable = true
                        end
                    end
                end
            end
        end
    end)
end