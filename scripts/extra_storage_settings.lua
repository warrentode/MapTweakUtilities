-- extra storage items allowed settings
return function(AddPrefabPostInit, TUNING, config)
    ---------- CUSTOM WENDY BASKET PATCH ----------
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

    if config.ALT_RECIPES_ALLOWED then
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

    ---------- CUSTOM PATCH FOR TACKLEBOXES ----------
    local fishing_rods = {
        "fishingrod",
        "oceanfishingrod"
    }

    for _, v in ipairs(fishing_rods) do
        AddPrefabPostInit(v, function(inst)
            if not inst:HasTag("tacklecontainer_valid") then
                inst:AddTag("tacklecontainer_valid")
            end
        end)
    end

    local containers = require("containers")
    local params = containers.params

    local OriginalTackleContainerItemTestFn = params.tacklecontainer.itemtestfn

    function params.tacklecontainer.itemtestfn(container, item, slot)
        return OriginalTackleContainerItemTestFn(container, item, slot) or item:HasTag("tacklecontainer_valid")
    end

    -- this copies the custom testfn for the basic tackle box onto the super tackle box
    params.supertacklecontainer.itemtestfn = params.tacklecontainer.itemtestfn

    ---------- CUSTOM PATCH FOR SPIDER BIN STORAGE ----------
    -- special config since this could be seen as game breaking depending on other mods enabled
    if config.WEBBER_BIN then
        local spider_list = {
            "spider",
            "spider_warrior",
            "spider_hider",
            "spider_spitter",
            "spider_dropper",
            "spider_moon",
            "spider_healer",
            "spider_water"
        }

        for _, v in ipairs(spider_list) do
            AddPrefabPostInit(v, function(inst)
                if not inst:HasTag("beargerfur_sack_valid") then
                    inst:AddTag("beargerfur_sack_valid")
                end
            end)
        end
    end
end