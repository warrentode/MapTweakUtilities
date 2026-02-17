GLOBAL.setmetatable(env, {
    __index = function(_, k)
        return GLOBAL.rawget(GLOBAL, k)
    end,
})

local load_lang_keys = require("mtu_strings")
load_lang_keys(STRINGS)

-- LOG PRINTING WRAPPER
local function modprint(s)
    return print("[MTU] " .. s)
end

---------- CUSTOM PREFABS ADDED ----------

PrefabFiles = {
    "portablecoldfirepit",
    "willow_ember"
}

---------- CUSTOM PREFAB RECIPES ----------

AddRecipe2("portablecoldfirepit_item", {Ingredient("nitre", 3), Ingredient("rope", 1), Ingredient("rocks", 4)}, TECH.NONE, {product = "portablecoldfirepit_item", image = "portablefirepit_item.tex", builder_skill = "walter_camp_fire"}, {"CHARACTER"})

---------- GLOBAL CONSTANTS ----------

MTU = MTU or {}
MTU.players_loaded = 0
MTU.modprint = modprint

local function UpdatePlayersLoaded()
    local clients = TheNet:GetClientTable()
    -- only grabbing the count of players logged in
    MTU.players_loaded = clients ~= nil and #clients or 0
end

AddSimPostInit(function()
    if not TheWorld.ismastersim then
        return
    end

    -- Initial population
    UpdatePlayersLoaded()

    -- Periodic correction in case of shard transfers / reconnects
    TheWorld:DoPeriodicTask(5, UpdatePlayersLoaded)
end)

---------- CONFIG BASED CONSTANTS ----------

local tree_config = {
    BLOSSOM_CAP = GetModConfigData("blossom_drop_cap") or 2,
    BLOSSOM_CHANCE = GetModConfigData("blossom_drop_chance") or 0,

    PINE_LOOP = GetModConfigData("pine_loop") or false,
    LUMPY_LOOP = GetModConfigData("lumpy_loop") or false,
    STONE_FRUIT_LOOP = GetModConfigData("stone_fruit_loop") or false,
    TWIGGY_LOOP = GetModConfigData("twiggy_loop") or false,
    BIRCH_LOOP = GetModConfigData("birch_loop") or false,
    MOON_LOOP = GetModConfigData("moon_loop") or false,
    MARBLE_LOOP = GetModConfigData("marble_loop") or false,
    PALM_LOOP = GetModConfigData("palm_loop") or false,
    MUSH_LOOP = GetModConfigData("mush_loop") or false,
}
local stack_config = {
    AUTO_STACK_ENABLED = GetModConfigData("auto_stack_enabled") or false,
    STACK_RADIUS = GetModConfigData('stack_radius') or 10,
    seeds = GetModConfigData("exclude_seeds"),
    crumbs = GetModConfigData("exclude_crumbs"),
    pigskin = GetModConfigData("exclude_pigskin"),
    winter_food4 = GetModConfigData("exclude_winter_food4"),
    powcake = GetModConfigData("exclude_powcake"),
}
local batch_config = {
    BATCH_TRADES_ENABLED = GetModConfigData("batch_trades_enabled") or false
}
local dock_bridge_config = {
    DOCK_KIT_PLACEMENT_OVERRIDE = GetModConfigData("dock_kit_placement_override") or false,
    ROPEBRIDGE_MAX_LENGTH = GetModConfigData("rope_bridge_max_length") or 6
}
local starvation_config = {
    NO_STARVE_MERM_KING = GetModConfigData("no_starve_mermking") or false,
    NO_STARVE_BIRD_CAGE = GetModConfigData("no_starve_bird_cage") or false
}
local boss_scaling_config = {
    BOSS_SCALING_MODE = GetModConfigData("scale_boss_loot") or 0,
    BOSS_SCALING_RANGE = GetModConfigData("boss_scale_range") or 30,
    BOSS_SCALING_BLUEPRINTS = GetModConfigData("boss_scale_blueprints") or false,
    BOSS_SCALING_WORM_MOUTH = GetModConfigData("scale_boss_worm_mouth") or false
}
local no_swiping_config = {
    ALLOW_SLURTLE_EATING = GetModConfigData("allow_slurtles") or false,
    ALLOW_WORM_BOSS_EATING = GetModConfigData("allow_worm_boss") or false
}
local trader_config = {
    SLINGSHOT_EVERYONE = GetModConfigData("slingshot_everyone") or false,
    PORTABLECAMPFIRE_EVERYONE = GetModConfigData("portablecampfire_everyone") or false,
    TRADER_ICON = GetModConfigData("wanderingtrader_icon") or false,
    WALTER_TRADES = GetModConfigData("wanderingtrader_walter_trades") or false
}
local follower_config = {
    PROTECT_FOLLOWERS = GetModConfigData("protect_followers") or false,
    REVEAL_FOLLOWERS = GetModConfigData("reveal_follower_item") or false
}
local balatro_config = {
    BURN_CARDS = GetModConfigData("burn_cards"),
    DROP_CARDS = GetModConfigData("drop_cards"),
    DROP_RECORD = GetModConfigData("drop_record"),
    TIER1_DROP_COUNT = GetModConfigData("tier1_drop_count") or 2,
    TIER2_DROP_COUNT = GetModConfigData("tier2_drop_count") or 2,
    TIER3_DROP_COUNT = GetModConfigData("tier3_drop_count") or 2,
    TIER4_DROP_COUNT = GetModConfigData("tier4_drop_count") or 2,
    TIER5_DROP_COUNT = GetModConfigData("tier5_drop_count") or 2,
    killerbee = GetModConfigData("killerbee_count"),
    hound = GetModConfigData("hound_count"),
    spider = GetModConfigData("spider_count"),
    worm = GetModConfigData("worm_count"),
    cutgrass = GetModConfigData("cutgrass_chance"),
    twigs = GetModConfigData("twigs_chance"),
    rocks = GetModConfigData("rocks_chance"),
    flint = GetModConfigData("flint_chance"),
    log = GetModConfigData("log_chance"),
    cutreeds = GetModConfigData("cutreeds_chance"),
    cutstone = GetModConfigData("cutstone_chance"),
    rope = GetModConfigData("rope_chance"),
    boards = GetModConfigData("boards_chance"),
    papyrus = GetModConfigData("papyrus_chance"),
    transistor = GetModConfigData("transistor_chance"),
    livinglog = GetModConfigData("livinglog_chance"),
    beeswax = GetModConfigData("beeswax_chance"),
    marblebean = GetModConfigData("marblebean_chance"),
    nightmarefuel = GetModConfigData("nightmarefuel_chance"),
    cave_banana = GetModConfigData("cave_banana_chance"),
    fig = GetModConfigData("fig_chance"),
    pumpkin = GetModConfigData("pumpkin_chance"),
    dragonfruit = GetModConfigData("dragonfruit_chance"),
    cactus_flower = GetModConfigData("cactus_flower_chance"),
    bird_egg = GetModConfigData("bird_egg_chance"),
    bananapop = GetModConfigData("bananapop_chance"),
    bananajuice = GetModConfigData("bananajuice_chance"),
    frozenbananadaiquiri = GetModConfigData("frozenbananadaiquiri_chance"),
    cave_banana_cooked = GetModConfigData("cave_banana_cooked_chance"),
    watermelonicle = GetModConfigData("watermelonicle_chance"),
    fruitmedley = GetModConfigData("fruitmedley_chance"),
    goldnugget = GetModConfigData("goldnugget_chance"),
    moonrocknugget = GetModConfigData("moonrocknugget_chance"),
    gears = GetModConfigData("gears_chance"),
    pigskin = GetModConfigData("pigskin_chance"),
    steelwool = GetModConfigData("steelwool_chance"),
    manrabbit_tail = GetModConfigData("manrabbit_tail_chance"),
    slurper_pelt = GetModConfigData("slurper_pelt_chance"),
    redgem = GetModConfigData("redgem_chance"),
    bluegem = GetModConfigData("bluegem_chance"),
    purplegem = GetModConfigData("purplegem_chance"),
    yellowgem = GetModConfigData("yellowgem_chance"),
    orangegem = GetModConfigData("orangegem_chance"),
    greengem = GetModConfigData("greengem_chance"),
    opalpreciousgem = GetModConfigData("opalpreciousgem_chance"),
    thulecite = GetModConfigData("thulecite_chance")
}
local medical_config = {
    MEDICAL_HAUNTING = GetModConfigData("medical_haunt") or false,
    MEDKIT_MOD = KnownModIndex:IsModEnabled("workshop-2812739628")
}
local spicepack_config = {
    SPICEPACK_WATERPROOF = GetModConfigData("spicepack_waterproof") or false,
    SPICEPACK_INVENTORY = GetModConfigData("spicepack_inventory") or false,
    SPICEPACK_BURNABLE = GetModConfigData("spicepack_burnable") or true,
    SPICEPACK_PERISH_MULT = GetModConfigData("spicepack_perish_mult") or 1
}
local wendy_basket_config = {
    ALT_RECIPES_ALLOWED = GetModConfigData("allow_alt_recipes") or false
}

local HOWLITZER_STACKSIZE = GetModConfigData("howlitzer_stacksize") or false
local SLINGSHOT_EVERYONE = GetModConfigData("slingshot_everyone") or false
local PORTABLECAMPFIRE_EVERYONE = GetModConfigData("portablecampfire_everyone") or false
local NO_SWIPING = GetModConfigData("no_swiping") or false
local EXTRA_BASKET_ITEMS = GetModConfigData("extra_basket_items") or false

local LOOPING_WEEDS = GetModConfigData("looping_weeds") or false
local REMOVABLE_GRAVE = GetModConfigData("remove_grave") or false
local ALT_RECIPES_ALLOWED = GetModConfigData("allow_alt_recipes") or false
local WEBBER_RECIPES_ALLOWED = GetModConfigData("allow_webber_bulk") or false
local WANDERINGTRADER_ALT_TRADES = GetModConfigData("wanderingtrader_alt_trades") or false
local BRIGHTSHADE_FINDER = GetModConfigData("brightshade_finder") or false
local STORABLE_SOULS = GetModConfigData("storable_souls") or false
local INCREASE_DRIED_PERISH = GetModConfigData("dried_food_perish_time") or false

local WORM_BOSS_MOUTH_MOD = KnownModIndex:IsModEnabled("workshop-3474047377")
local PERISH_SETTINGS_MOD = KnownModIndex:IsModEnabled("workshop-1242907291")

---------- FEATURE FILES ----------

local load_stacking = require("stack_settings")
load_stacking(AddComponentPostInit, AddPrefabPostInitAny, stack_config, MTU)

local load_trees = require("tree_settings")
load_trees(AddPrefabPostInit, tree_config)

local load_batch = require("batch_trade_controls")
load_batch(AddPrefabPostInit, ACTIONS, KnownModIndex, batch_config)

local load_dock = require("dock_bridge_settings")
load_dock(Vector3, IsLandTile, TileGroupManager, AddPrefabPostInit, WORLD_TILES, TUNING, dock_bridge_config)

local load_starvation = require("starvation_settings")
load_starvation(AddPrefabPostInit, TUNING, starvation_config)

local load_boss_scaling = require("boss_scaling")
load_boss_scaling(MTU, boss_scaling_config, GetSharedLootTable, SetSharedLootTable, AllPlayers, distsq, AddPrefabPostInit, modimport, KnownModIndex)

local load_follower_protections = require("protect_followers")
load_follower_protections(TUNING, SetSharedLootTable, AddPrefabPostInit, follower_config)

local load_balatro_settings = require("balatro_settings")
load_balatro_settings(AddPrefabPostInit, TUNING, balatro_config)

local load_medical_settings = require("medical_settings")
load_medical_settings(AddPrefabPostInit, ACTIONS, medical_config)

if ALT_RECIPES_ALLOWED then
    local load_alt_recipes = require("alt_recipes")
    load_alt_recipes(AllRecipes, AddRecipe2, Ingredient, TECH, AddRecipeToFilter, CRAFTING_FILTERS, CHARACTER_INGREDIENT)
end
if WEBBER_RECIPES_ALLOWED then
    local load_webber_alt_recipes = require("webber_alt_recipes")
    load_webber_alt_recipes(AddRecipe2, Ingredient, TECH, AddRecipeToFilter, CRAFTING_FILTERS, AddPrefabPostInit)
end
if WANDERINGTRADER_ALT_TRADES then
    local load_trades = require("wanderingtradershop")
    load_trades(AddRecipe2, Ingredient, TECH, AddPrefabPostInit, trader_config)
end
if REMOVABLE_GRAVE then
    local load_graves = require("removable_graves")
    load_graves(AddSimPostInit, AddPrefabPostInit, ACTIONS, TUNING)
end
if LOOPING_WEEDS then
    local load_weeds = require("weed_settings")
    load_weeds(AddPrefabPostInitAny)
end
if NO_SWIPING then
    local load_no_swiping = require("no_swiping")
    load_no_swiping(Prefabs, AddPrefabPostInit, AddStategraphPostInit, AddSimPostInit, ACTIONS, EQUIPSLOTS, FRAMES, debug, no_swiping_config, modprint)
end
if BRIGHTSHADE_FINDER then
    local load_brightshade_finder = require("brightshade_finder")
    load_brightshade_finder(AddPrefabPostInit)
end
if EXTRA_BASKET_ITEMS then
    local load_basket_settings = require("wendy_basket_settings")
    load_basket_settings(AddPrefabPostInit, TUNING, wendy_basket_config)
end

---------- EVERYONE SETTINGS ----------

if HOWLITZER_STACKSIZE then
    AddPrefabPostInit("houndstooth_blowpipe", function(inst)
        if inst.components.container then
            inst.components.container:EnableInfiniteStackSize(true)
        end
    end)
end

AddPlayerPostInit(function(inst)
    if SLINGSHOT_EVERYONE then
        inst:AddTag("slingshot_sharpshooter")
    end
    if PORTABLECAMPFIRE_EVERYONE then
        inst:AddTag("portable_campfire_user")
    end
    if NO_SWIPING then
        inst:AddTag("stronggrip")
    end
end)

---------- CUSTOM PATCH FOR WORM BOSS MOUTH MOD ----------

if WORM_BOSS_MOUTH_MOD then
    AddSimPostInit(function()
        if ACTIONS.REMOVEHOLEBYMOUTH then
            local old_fn = ACTIONS.REMOVEHOLEBYMOUTH.fn
            ACTIONS.REMOVEHOLEBYMOUTH.fn = function(act)
                local result = old_fn(act)

                -- give back the worm mouth to the player if removed
                if act.invobject and act.invobject.prefab == "boss_worm_mouth" and act.doer and act.doer.components.inventory then
                    act.doer.components.inventory:GiveItem(act.invobject)
                end

                return result
            end
        end
    end)
end

---------- CUSTOM PATCH FOR PROPSIGN ----------

AddPrefabPostInit("propsign", function(inst)
    -- change the vanilla override here to enable custom name and inspection strings
    inst:SetPrefabNameOverride("propsign")

    if not TheWorld.ismastersim then
        return
    end

    -- set to allow in inventory
    inst.components.inventoryitem.cangoincontainer = true

    -- these are craftable now, so no longer irreplaceable
    inst:RemoveTag("irreplaceable")
    -- make them stackable
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM

    -- cancel break propsign call
    inst.OnCancelMinigame = function()
        --- doing nothing here to prevent the sign from breaking when a minigame isn't active
    end
end)

---------- STORABLE SOULS AND EMBERS ----------

-- this needs to stay inside the modmain file to prevent crashing until i figure out the proper way to migrate it
if STORABLE_SOULS then
    AddPrefabPostInit("wortox_soul", function(inst)
        if not TheWorld.ismastersim then
            return
        end

        if inst.components.inventoryitem then
            inst.components.inventoryitem.canonlygoinpocketorpocketcontainers = false
        end
    end)

    -- Ensure the original updatespells function is removed/overwritten globally
    _G.updatespells = function(inst, owner)
        -- Custom version of updatespells to handle the crash-causing issue
        local spells = shallowcopy(BASESPELLS)  -- Deep copy of base spells
        if owner then
            for _, v in ipairs(SKILLTREE_SPELL_ORDER) do
                -- Custom check to prevent crash (check if skilltreeupdater exists)
                if owner.components.skilltreeupdater and owner.components.skilltreeupdater:IsActivated(v) then
                    table.insert(spells, SKILLTREE_SPELL_DEFS[v]) -- Add the activated spell
                end
            end
        end
        inst.components.spellbook:SetItems(spells)  -- Apply the modified spell list
    end

    -- AddPrefabPostInit to modify the 'willow_ember' prefab and disable the vanilla function
    AddPrefabPostInit("willow_ember", function(inst)
        if not TheWorld.ismastersim then
            return
        end

        -- Disable the vanilla global function
        _G.updatespells = function()
        end  -- Disable the original function from being called

        -- Set the ember to be allowed in all containers, not just pockets
        if inst.components.inventoryitem then
            inst.components.inventoryitem.canonlygoinpocket = false
            inst.components.inventoryitem.cangoincontainer = true
        end
    end)
end

---------- CUSTOM PATCH FOR CHEF POUCH ----------

AddPrefabPostInit("spicepack", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    if spicepack_config.SPICEPACK_INVENTORY then
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.cangoincontainer = true
    end

    if spicepack_config.SPICEPACK_WATERPROOF then
        inst:AddTag("waterproofer")
        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(0)
    end

    if spicepack_config.SPICEPACK_PERISH_MULT ~= 1 then
        inst:AddComponent("preserver")
        inst.components.preserver:SetPerishRateMultiplier(spicepack_config.SPICEPACK_PERISH_MULT)
    end

    if not spicepack_config.SPICEPACK_BURNABLE then
        if inst and inst.components.burnable then
            inst:RemoveComponent('burnable')
            inst:RemoveComponent('propagator')
        end
    end
end)

---------- CUSTOM PATCH FOR ULTIMATE PERISH SETTINGS MOD ----------

if PERISH_SETTINGS_MOD then
    local function IceboxStoreCreaturesActive()
        local prefab = Prefabs["mole"]
        return prefab and prefab.tags and table.contains(prefab.tags, "icebox_valid")
    end

    local insects = {
        "butterfly",
        "moonbutterfly",
        "bee",
        "killerbee"
    }

    if IceboxStoreCreaturesActive then
        for _, v in ipairs(insects) do
            AddPrefabPostInit(v, function(inst)
                if not inst:HasTag("icebox_valid") then
                    inst:AddTag("icebox_valid")
                end
            end)
        end
    end
end

---------- CUSTOM PATCH FOR JERKY PERISH SETTINGS ----------

if INCREASE_DRIED_PERISH then
    local dried_foods = {
        "meat_dried",
        "smallmeat_dried",
        "monstermeat_dried",
        "humanmeat_dried",
        "fishmeat_small_dried",
        "fishmeat_dried",
        "plantmeat_dried",
        "kelp_dried"
    }

    for _, v in ipairs(dried_foods) do
        AddPrefabPostInit(v, function(inst)
            inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW * 2)
        end)
    end
end