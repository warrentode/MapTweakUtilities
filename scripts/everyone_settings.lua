-- special settings that apply to all characters
return function(AddClassPostConstruct, AddPlayerPostInit, AddPrefabPostInit, config)
    if config.HOWLITZER_STACKSIZE then
        AddPrefabPostInit("houndstooth_blowpipe", function(inst)
            if inst.components.container then
                inst.components.container:EnableInfiniteStackSize(true)
            end
        end)
    end

    AddPlayerPostInit(function(inst)
        if config.SLINGSHOT_EVERYONE then
            inst:AddTag("slingshot_sharpshooter")
        end
        if config.PORTABLECAMPFIRE_EVERYONE then
            inst:AddTag("portable_campfire_user")
        end
        if config.NO_SWIPING then
            inst:AddTag("stronggrip")
        end
    end)

    ---------- PORTALABLE COOKPOT ----------
    -- we need this for gating warly's cooking recipes
    local cooking = require("cooking")

    -- opens the placed pot, must run on clients too since componentactions gates on the tag as well
    local function UnlockStation(inst)
        inst:RemoveTag("mastercookware")
    end

    -- opens placing the item down
    local function UnlockItem(inst)
        inst:RemoveTag("mastercookware")

        if not TheWorld.ismastersim then
            return
        end

        if inst.components.deployable then
            inst.components.deployable.restrictedtag = "player"
        end
    end

    -- keeps the exclusive dishes warly only
    local function LockRecipes(inst)
        if not TheWorld.ismastersim then
            return
        end

        if not inst.components.stewer then
            return
        end

        local StartCooking = inst.components.stewer.StartCooking

        inst.components.stewer.StartCooking = function(self, doer, ...)
            -- skip any characters with this tag, like Warly, so it behaves like normal
            if doer and doer:HasTag("masterchef") then
                return StartCooking(self, doer, ...)
            end

            -- cooking.recipes is the same table CalculateRecipe reads from so we set this for those locked out of masterchef
            local portable_recipes = cooking.recipes.portablecookpot
            cooking.recipes.portablecookpot = cooking.recipes.cookpot

            local success, err = pcall(StartCooking, self, doer, ...)

            cooking.recipes.portablecookpot = portable_recipes

            if not success then
                error(err)
            end
        end
    end

    if config.WARLY_COOKPOT_EVERYONE then
        AddPrefabPostInit("portablecookpot", UnlockStation)
        AddPrefabPostInit("portablecookpot_item", UnlockItem)

        if config.WARLY_RECIPES_LOCKED then
            AddPrefabPostInit("portablecookpot", LockRecipes)
        end
    end

    -- add compat with the client side cookpot mod's cooking predictions
    if config.WARLY_COOKPOT_EVERYONE and config.WARLY_RECIPES_LOCKED then
        local cooking = require("cooking")

        AddClassPostConstruct("widgets/controls", function(self)
            local foodcrafting = self.foodcrafting

            if not foodcrafting or not foodcrafting.SortFoods then
                return
            end

            local _UpdateFoodStats = foodcrafting._UpdateFoodStats

            foodcrafting._UpdateFoodStats = function(self, ...)
                local player = self.owner

                -- only mask at the portable pot, and only for players who cannot cook the exclusive dishes
                if self._cookerName ~= "portablecookpot" or not player or player:HasTag("masterchef") then
                    return _UpdateFoodStats(self, ...)
                end

                -- same set the server gate blocks: in the portable table, absent from the regular one
                local portable_recipes = cooking.recipes.portablecookpot or {}
                local regular_recipes = cooking.recipes.cookpot or {}

                local allfoods = self.allfoods
                local visible = {}
                local masked = {}

                for _, fooditem in ipairs(allfoods) do
                    local recipe = fooditem.recipe

                    if recipe.name and portable_recipes[recipe.name] and not regular_recipes[recipe.name] then
                        table.insert(masked, recipe)
                    else
                        table.insert(visible, fooditem)
                    end
                end

                -- the exclusive dishes are out of the running entirely, so they cannot win on priority
                self.allfoods = visible
                _UpdateFoodStats(self, ...)
                self.allfoods = allfoods

                for _, recipe in ipairs(masked) do
                    recipe.readytocook = false
                    recipe.hide = true
                end
            end
        end)
    end
end