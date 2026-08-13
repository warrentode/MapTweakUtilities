-- placement patches to the coffee in the fumaroles mod
return function(AddPrefabPostInit, DEPLOYSPACING_RADIUS, DEPLOYSPACING)
    AddPrefabPostInit("dug_coffeebush", function(inst)
        if not TheWorld.ismastersim then
            return
        end

        -- Override the deployable check function
        if inst.components.deployable then
            inst.components.deployable._custom_candeploy_fn = function(inst, pt, _, _)
                local x, y, z = pt:Get()
                local tile = TheWorld.Map:GetTileAtPoint(x, y, z)

                -- Table of valid tiles (matching vanilla sproutrock)
                local valid_tiles = {
                    WORLD_TILES.VENT,
                    WORLD_TILES.FUMAROLE,
                    WORLD_TILES.VOLCANO
                }

                for _, valid_tile in ipairs(valid_tiles) do
                    if tile == valid_tile then
                        local spacing_radius = DEPLOYSPACING_RADIUS[DEPLOYSPACING.MEDIUM]
                        if inst.replica.inventoryitem then
                            spacing_radius = inst.replica.inventoryitem:DeploySpacingRadius()
                        end
                        return TheWorld.Map:IsDeployPointClear(pt, inst, spacing_radius)
                    end
                end

                return false
            end
        end
    end)
end