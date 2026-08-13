-- custom settings for wall regen

return function(AddPrefabPostInit, TUNING, config)
    local WALL_HEALTH_ENHANCE = config.WALL_HEALTH_ENHANCE
    local WALL_HEALTH_REGEN = config.WALL_HEALTH_REGEN
    local WALL_REGEN_VALUE = config.WALL_REGEN_VALUE

    if WALL_HEALTH_ENHANCE then
        TUNING.HAYWALL_HEALTH = 1000
        TUNING.WOODWALL_HEALTH = 2000
        TUNING.STONEWALL_HEALTH = 4000
        TUNING.RUINSWALL_HEALTH = 8000
        TUNING.MOONROCKWALL_HEALTH = 6000
        TUNING.DREADSTONEWALL_HEALTH = 8000
        TUNING.SCRAPWALL_HEALTH = 6000
    end

    if WALL_HEALTH_REGEN then
        local function regen( inst )
            inst:DoPeriodicTask(5, function( inst )
                if inst and inst.components and inst.components.health then
                    local wall_health = inst.components.health:GetPercent()
                    if wall_health < 1 then
                        inst.components.health:DoDelta(WALL_REGEN_VALUE)
                    end
                end
            end)
        end
        AddPrefabPostInit("wall_hay", regen)
        AddPrefabPostInit("wall_wood", regen)
        AddPrefabPostInit("wall_stone", regen)
        AddPrefabPostInit("wall_ruins", regen)
        AddPrefabPostInit("wall_moonrock",regen)
        AddPrefabPostInit("wall_scrap",regen)
        AddPrefabPostInit("wall_dreadstone",regen)
    end
end