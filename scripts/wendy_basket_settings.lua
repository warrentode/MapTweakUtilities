---------- CUSTOM WENDY BASKET PATCH ----------
return function(AddPrefabPostInit, TUNING, config)
    local ALT_RECIPES_ALLOWED = config.ALT_RECIPES_ALLOWED

    local basket_items = {
        -- flower garden related (mostly sisturn supplies)
        "butterfly",
        "butterflywings",
        "moonbutterfly",
        "moonbutterflywings",
        "bee",
        "killerbee",
        "petals",
        "petals_evil",
        "moon_tree_blossom",
        "honeycomb",
        -- wendy specific crafted item
        "ghostflowerhat",
        -- fave food cuz why not, it's a picnic basket after all
        "bananapop",
        -- and of course this means adding the flower tea from Pearl
        "hermitcrabtea_petals",
        "hermitcrabtea_petals_evil",
        "hermitcrabtea_forgetmelots",
        "hermitcrabtea_moon_tree_blossom",
        -- elixir ingredients
        "spidergland",
        "reviver",
        "log",
        "livinglog",
        "stinger",
        "honey",
        "forgetmelots",
        "horrorfuel",
        "purebrilliance"
    }

    for _, v in ipairs(basket_items) do
        AddPrefabPostInit(v, function(inst)
            if not inst:HasTag("elixir_container_valid") then
                inst:AddTag("elixir_container_valid")
            end
        end)
    end

    if ALT_RECIPES_ALLOWED then
        local dried_basket_items = {
            "petals_dried",
            "petals_evil_dried",
            "forgetmelots_dried",
            "moon_tree_blossom_dried"
        }

        for _, v in ipairs(dried_basket_items) do
            AddPrefabPostInit(v, function(inst)
                if not inst:HasTag("elixir_container_valid") then
                    inst:AddTag("elixir_container_valid")
                end
            end)
        end
    end

    local containers = require("containers")
    local params = containers.params
    -- we grab this first to not overwrite it, hopefully also preserving whatever else other mods might have added to the itemtestfn
    local OriginalElixirContainerItemTestFn = params.elixir_container.itemtestfn

    function params.elixir_container.itemtestfn(container, item, slot)
        -- then we still run the original function with the new check
        return OriginalElixirContainerItemTestFn(container, item, slot) or item:HasTag("elixir_container_valid")
    end

    AddPrefabPostInit("elixir_container", function(inst)
        inst:AddComponent("preserver")
        --- believe this is the preservation rate of the spicepack's vanilla setting
        -- using this tuning value makes sure the basket isn't better than other preserver containers
        inst.components.preserver:SetPerishRateMultiplier(TUNING.PERISH_FOOD_PRESERVER_MULT)
    end)
end