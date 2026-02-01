GLOBAL.setmetatable(env, {
    __index = function(t, k)
        return GLOBAL.rawget(GLOBAL, k)
    end,
})

---------- FEATURE FILES ----------

local load_alt_recipes = require("alt_recipes")
load_alt_recipes(AllRecipes, AddRecipe2, Ingredient, TECH, AddRecipeToFilter, CRAFTING_FILTERS, CHARACTER_INGREDIENT)

---------- LUNE TREE BLOSSOM CONTROLS ----------

local BLOSSOM_CAP = GetModConfigData("blossom_drop_cap") or 2
local BLOSSOM_CHANCE = GetModConfigData("blossom_drop_chance") or 0

-- Moon Tree PostInit patch
local function DoMoonBlossomRebirth(inst)
    local rebirth_loot = {loot = "moon_tree_blossom", max = BLOSSOM_CAP} -- ground-presence cap
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 8)
    local numloot = 0

    for i, ent in ipairs(ents) do
        if ent.prefab == rebirth_loot.loot then
            if ent.components.stackable then
                numloot = numloot + ent.components.stackable:StackSize()
            else
                numloot = numloot + 1
            end
        end
    end

    -- Spawn exactly one if under cap
    if numloot < BLOSSOM_CAP and inst.components.lootdropper then
        if math.random() * 100 <= BLOSSOM_CHANCE then
            inst.components.lootdropper:SpawnLootPrefab(rebirth_loot.loot)
        end
    end

    inst._lastrebirth = GetTime()
end

local function PatchMoonTreeGrowth(inst)
    if not TheWorld.ismastersim then
        return
    end

    if inst.components.growable and inst.components.growable.stages then
        for _, stage in ipairs(inst.components.growable.stages) do
            local old_growfn = stage.growfn
            stage.growfn = function(inst2, ...)
                if old_growfn then
                    old_growfn(inst2, ...)
                end
                DoMoonBlossomRebirth(inst2)
            end
        end
    end
end

AddPrefabPostInit("moon_tree", PatchMoonTreeGrowth)

---------- TWIGGY TREE TWIG DROP CONTROLS PATCH ----------
-- to actually count the number of twigs in a nearby stack rather than counting the entire stack as 1 item
AddPrefabPostInit("twiggytree", function(inst)
    if not TheWorld.ismastersim or not inst.components.growable or not inst.components.growable.stages then
        return
    end

    local function DoTwiggyLoot(inst)
        local rebirth_loot = {loot = "twigs", max = 2} -- ground-presence cap
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 8)
        local numloot = 0

        for i, ent in ipairs(ents) do
            if ent.prefab == rebirth_loot.loot then
                if ent.components.stackable then
                    numloot = numloot + ent.components.stackable:StackSize()
                else
                    numloot = numloot + 1
                end
            end
        end

        local prob = 1 - (numloot / rebirth_loot.max)
        if numloot < 2 and inst.components.lootdropper then
            if math.random() < prob then
                if inst.components.lootdropper then
                    inst.components.lootdropper:SpawnLootPrefab(rebirth_loot.loot)
                end
            end
        end

        inst._lastrebirth = GetTime()
    end

    -- Wrap each grow stage's growfn
    for _, stage in ipairs(inst.components.growable.stages) do
        local old_growfn = stage.growfn
        stage.growfn = function(inst2, ...)
            if old_growfn then
                old_growfn(inst2, ...)
            end
            DoTwiggyLoot(inst2)
        end
    end
end)

---------- TREE CYCLE CONTROLS ----------

local PINE_LOOP = GetModConfigData("pine_loop") or false
local LUMPY_LOOP = GetModConfigData("lumpy_loop") or false
local STONE_FRUIT_LOOP = GetModConfigData("stone_fruit_loop") or false
local TWIGGY_LOOP = GetModConfigData("twiggy_loop") or false
local BIRCH_LOOP = GetModConfigData("birch_loop") or false
local MOON_LOOP = GetModConfigData("moon_loop") or false
local MARBLE_LOOP = GetModConfigData("marble_loop") or false
local PALM_LOOP = GetModConfigData("palm_loop") or false
local MUSH_LOOP = GetModConfigData("mush_loop") or false

-- List of 5 stage trees
local plantregrowth_5_stage_list = {}
plantregrowth_5_stage_list["evergreen"] = PINE_LOOP
plantregrowth_5_stage_list["evergreen_sparse"] = LUMPY_LOOP
plantregrowth_5_stage_list["twiggytree"] = TWIGGY_LOOP
plantregrowth_5_stage_list["rock_avocado_bush"] = STONE_FRUIT_LOOP

-- 5 stage trees: Remove the looping process (looping is prohibited; if the tree is deadwood before the process starts, it will be converted to a level three state).
for k, v in pairs(plantregrowth_5_stage_list) do
    if v then
        AddPrefabPostInit(k, function(inst)
            inst:DoTaskInTime(0.1, function(inst)
                if not TheWorld.ismastersim then
                    return
                end
                if inst.components and inst.components.growable then
                    -- Required final stage
                    local need_final_stage = #inst.components.growable.stages - 1
                    local real_final_stage = #inst.components.growable.stages
                    inst.components.growable.stages[real_final_stage] = inst.components.growable.stages[need_final_stage]
                    -- Cyclic growth is prohibited.
                    inst.components.growable.loopstages = false
                    -- Existing dead trees in the world will automatically be converted to level three.
                    if inst.components.growable.stage > need_final_stage then
                        inst.components.growable:SetStage(need_final_stage)
                    end
                    if inst.components.growable.stage >= need_final_stage then
                        inst.components.growable:StopGrowing()
                    end
                end
                if inst.components and inst.components.plantregrowth then
                    inst:RemoveComponent("plantregrowth")
                end

            end)
        end)
    end
end

-- List of 4 stage trees
local plantregrowth_list = {}
plantregrowth_list["deciduoustree"] = BIRCH_LOOP
plantregrowth_list["moon_tree"] = MOON_LOOP
plantregrowth_list["marbleshrub"] = MARBLE_LOOP
plantregrowth_list["palmconetree"] = PALM_LOOP
plantregrowth_list["mushtree_tall"] = MUSH_LOOP
plantregrowth_list["mushtree_medium"] = MUSH_LOOP
plantregrowth_list["mushtree_small"] = MUSH_LOOP
for k, v in pairs(plantregrowth_list) do
    if v then
        AddPrefabPostInit(k, function(inst)
            inst:DoTaskInTime(0.1, function(inst)
                if TheWorld.ismastersim then
                    if inst.components and inst.components.growable then
                        inst.components.growable.loopstages = false
                    end
                end
            end)
        end)
    end
end

---------- AUTO STACKING CONTROLS ----------

local players_loaded = 0

-- Listen for player loading completion events.
AddPlayerPostInit(function(inst)
    players_loaded = players_loaded + 1
end)

local AUTO_STACK_ENABLED = GetModConfigData("auto_stack_enabled")
local STACK_RADIUS = GetModConfigData('stack_radius')

local function FindEntities(x, y, z)
    return TheSim:FindEntities(x, y, z, STACK_RADIUS,
                               {
                                   '_stackable',
                               },
                               {
                                   'INLIMBO',
                                   'NOCLICK',
                                   'penguin_egg',
                                   'lootpump_oncatch',
                                   'lootpump_onflight',
                               }
    )
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

local excluded_items = {
    seeds = GetModConfigData("exclude_seeds"),
    crumbs = GetModConfigData("exclude_crumbs"),
    pigskin = GetModConfigData("exclude_pigskin"),
    winter_food4 = GetModConfigData("exclude_winter_food4"),
    powcake = GetModConfigData("exclude_powcake"),
}

AddPrefabPostInitAny(function(inst)
    if players_loaded == 0 then
        return
    end
    if not AUTO_STACK_ENABLED then
        return
    end
    if inst:HasTag('smallcreature') or inst:HasTag('heavy') or inst:HasTag('trap') or inst:HasTag('NET_workable') or excluded_items[inst.prefab] then
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

---------- BATCH TRADE CONTROLS ----------

local BATCH_TRADES_ENABLED = GetModConfigData("batch_trades_enabled")

-- Rewrite the given action.
local old_give_fn = ACTIONS.GIVE.fn
ACTIONS.GIVE.fn = function(act)
    if not BATCH_TRADES_ENABLED then
        return old_give_fn(act)
    end
    -- Batch assignment to recipients
    if act.target and (act.target.prefab == "birdcage" or act.target.prefab == "pigking"
            or act.target.prefab == "mermking" or act.target.prefab == "antlion") then
        -- Can it be given, and why?
        local able, reason = act.target.components.trader:AbleToAccept(act.invobject, act.doer)
        -- If it cannot be provided
        if not able then
            return false, reason
        end
        -- Quantity of items given
        local count = (act.invobject and act.invobject.components and act.invobject.components.stackable) and act.invobject.components.stackable:StackSize() or 1
        -- Special items can only be given out one at a time, such as the golden belt; you can't give out 10 of them in a single event.
        if act.invobject.prefab == "pig_token" or act.invobject.prefab == "moonglass_charged" then
            count = 1
        end
        act.target.components.trader:AcceptGift(act.doer, act.invobject, count)
        return true
    end
    return old_give_fn(act)
end

AddPrefabPostInit("mermking", function(inst)
    -- Batch trading
    local old_TradeItem = inst.TradeItem
    inst.TradeItem = function(inst)
        local giver = inst.tradegiver
        local item = inst.itemtotrade
        local count = (item.components and item.components.stackable) and item.components.stackable:StackSize() or 1
        for i = 1, count do
            inst.tradegiver = giver
            inst.itemtotrade = item
            old_TradeItem(inst)
        end
    end
    -- Batch Feeding
    if inst.components.trader and inst.components.trader.onaccept then
        local old_onaccept = inst.components.trader.onaccept
        inst.components.trader.onaccept = function(inst, giver, item)
            local count = (item.components and item.components.stackable) and item.components.stackable:StackSize() or 1
            for i = 1, count do
                old_onaccept(inst, giver, item)
            end
        end
    end
end)

AddPrefabPostInit("pigking", function(inst)
    if inst.components.trader and inst.components.trader.onaccept then
        local old_onaccept = inst.components.trader.onaccept
        inst.components.trader.onaccept = function(inst, giver, item)
            local count = (item.components and item.components.stackable) and item.components.stackable:StackSize() or 1
            for i = 1, count do
                old_onaccept(inst, giver, item)
            end
        end
    end
end)

AddPrefabPostInit("birdcage", function(inst)
    if inst.components.trader and inst.components.trader.onaccept then
        local old_onaccept = inst.components.trader.onaccept
        inst.components.trader.onaccept = function(inst, giver, item)
            local count = (item.components and item.components.stackable) and item.components.stackable:StackSize() or 1
            for i = 1, count do
                old_onaccept(inst, giver, item)
            end
        end
    end
end)

AddPrefabPostInit("antlion", function(inst)
    if inst.components.trader and inst.components.trader.onaccept then
        local old_onaccept = inst.components.trader.onaccept
        inst.components.trader.onaccept = function(inst, giver, item)
            local count = (item.components and item.components.stackable) and item.components.stackable:StackSize() or 1
            for i = 1, count do
                old_onaccept(inst, giver, item)
                inst:GiveReward()
            end
        end
    end
end)

---------- MERM KING STARVATION CONTROLS ----------

local NO_STARVE_MERM_KING = GetModConfigData("no_starve_mermking") -- boolean from mod config

AddPrefabPostInit("mermking", function(inst)
    if inst.components.hunger and NO_STARVE_MERM_KING then
        inst.components.hunger:SetKillRate(0) -- prevents starvation damage
    end
end)

---------- DOCK KIT PLACEMENT CONTROLS ----------

local DOCK_KIT_PLACEMENT_OVERRIDE = GetModConfigData("dock_kit_placement_override") or false

local function IsPermanentOrDockFilterFn(tileid)
    return IsLandTile(tileid) and not (TileGroupManager:IsTemporaryTile(tileid) and tileid ~= WORLD_TILES.FARMING_SOIL and tileid ~= WORLD_TILES.MONKEY_DOCK)
end

local function CLIENT_CanDeployDockKit(inst, pt, mouseover, deployer, rotation)
    local x, y, z = pt:Get()
    local tile = TheWorld.Map:GetTileAtPoint(x, 0, z)

    if tile == WORLD_TILES.OCEAN_COASTAL or
            tile == WORLD_TILES.OCEAN_SWELL or
            tile == WORLD_TILES.OCEAN_ROUGH or
            tile == WORLD_TILES.OCEAN_HAZARDOUS or
            tile == WORLD_TILES.OCEAN_BRINEPOOL then
        return true
    end

    local tx, ty = TheWorld.Map:GetTileCoordsAtPoint(x, 0, z)
    if not TheWorld.Map:HasAdjacentTileFiltered(tx, ty, IsPermanentOrDockFilterFn) then
        return false
    end

    local center_pt = Vector3(TheWorld.Map:GetTileCenterPoint(tx, ty))
    return TheWorld.Map:CanDeployDockAtPoint(center_pt, inst, mouseover)
end

if DOCK_KIT_PLACEMENT_OVERRIDE then
    AddPrefabPostInit("dock_kit", function(inst)
        inst._custom_candeploy_fn = CLIENT_CanDeployDockKit -- for DEPLOYMODE.CUSTOM
    end)
end

---------- ROPE BRIDGE CONTROLS ----------

TUNING.ROPEBRIDGE_LENGTH_TILES = GetModConfigData("rope_bridge_max_length") or 6

---------- GRAVE CONTROLS ----------

local REMOVABLE_DUG_GRAVE = GetModConfigData("remove_dug_grave") or false
local SMASHABLE_HEADSTONE = GetModConfigData("smashable_headstone") or false

-- weighted loot table: cutstone twice as likely as marble
local HEADSTONE_LOOT = {
    {item = "cutstone", weight = 2},
    {item = "marble", weight = 1},
}

-- helper to pick a weighted random item
local function PickWeighted(loot_table)
    local total = 0
    for _, entry in ipairs(loot_table) do
        total = total + entry.weight
    end

    local r = math.random() * total
    for _, entry in ipairs(loot_table) do
        r = r - entry.weight
        if r <= 0 then
            return entry.item
        end
    end
end

local function OnSmashedHeadstone(inst, worker)
    if worker and worker.components.sanity then
        worker.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
    end

    local item = PickWeighted(HEADSTONE_LOOT)
    if item then
        local quantity = math.random(1, 2)
        for i = 1, quantity do
            inst.components.lootdropper:SpawnLootPrefab(item)
        end
    end

    inst:Remove()
end

local function OnRemoveGrave(inst, worker)
    if worker and worker.components.sanity then
        worker.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
    end
    inst:Remove()
end

if REMOVABLE_DUG_GRAVE then
    AddSimPostInit(function()
        if not TheWorld.ismastersim then
            return
        end

        for _, inst in pairs(Ents) do
            if inst
                    and inst.prefab == "mound"
                    and inst.AnimState ~= nil
                    and inst.AnimState:IsCurrentAnimation("dug")
            then
                if inst.components.workable == nil then
                    inst:AddComponent("workable")
                end

                inst.components.workable:SetWorkAction(ACTIONS.DIG)
                inst.components.workable:SetWorkLeft(1)
                inst.components.workable:SetOnFinishCallback(OnRemoveGrave)
            end
        end
    end)
end

if SMASHABLE_HEADSTONE then
    AddPrefabPostInit("gravestone", function(inst)
        if not TheWorld.ismastersim then
            return
        end

        inst:AddComponent("workable")
        inst:AddComponent("lootdropper")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(2)
        inst.components.workable:SetOnFinishCallback(OnSmashedHeadstone)
    end)
end

---------- WEED CONTROLS ----------

local LOOPING_WEEDS = GetModConfigData("looping_weeds") or false

if LOOPING_WEEDS then
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