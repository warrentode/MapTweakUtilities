-- custom starvation settings

return function(AddPrefabPostInit, TUNING, config)
    AddPrefabPostInit("mermking", function(inst)
        if inst.components.hunger and config.NO_STARVE_MERM_KING then
            inst.components.hunger:SetKillRate(0) -- prevents starvation damage
        end
    end)

    if config.NO_STARVE_BIRD_CAGE then
        TUNING.PERISH_CAGE_MULT = 0
    end
end