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

---------- GLOBAL CONSTANTS ----------

MTU = MTU or {}
MTU.players_loaded = 0
MTU.modprint = modprint

-- listener for players loaded
AddPlayerPostInit(function(_)
    MTU.players_loaded = MTU.players_loaded + 1
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

local HOWLITZER_STACKSIZE = GetModConfigData("howlitzer_stacksize") or false
local SLINGSHOT_EVERYONE = GetModConfigData("slingshot_everyone") or false
local PORTABLECAMPFIRE_EVERYONE = GetModConfigData("portablecampfire_everyone") or false
local NO_SWIPING = GetModConfigData("no_swiping") or false

local LOOPING_WEEDS = GetModConfigData("looping_weeds") or false
local REMOVABLE_GRAVE = GetModConfigData("remove_grave") or false
local ALT_RECIPES_ALLOWED = GetModConfigData("allow_alt_recipes") or false
local WEBBER_RECIPES_ALLOWED = GetModConfigData("allow_webber_bulk") or false
local WANDERINGTRADER_ALT_TRADES = GetModConfigData("wanderingtrader_alt_trades") or false

local WORM_BOSS_MOUTH_MOD = KnownModIndex:IsModEnabled("workshop-3474047377")

---------- FEATURE FILES ----------

local load_stacking = require("stack_settings")
load_stacking(AddComponentPostInit, AddPrefabPostInitAny, stack_config, MTU)

local load_trees = require("tree_settings")
load_trees(AddPrefabPostInit, tree_config)

local load_batch = require("batch_trade_controls")
load_batch(AddPrefabPostInit, ACTIONS, batch_config)

local load_dock = require("dock_bridge_settings")
load_dock(Vector3, IsLandTile, TileGroupManager, AddPrefabPostInit, WORLD_TILES, TUNING, dock_bridge_config)

local load_starvation = require("starvation_settings")
load_starvation(AddPrefabPostInit, TUNING, starvation_config)

local load_boss_scaling = require("boss_scaling")
load_boss_scaling(MTU, boss_scaling_config, SetSharedLootTable, AllPlayers, distsq, AddPrefabPostInit, modimport, KnownModIndex)

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
    load_trades(AddRecipe2, Ingredient, TECH, AddPrefabPostInit)
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

---------- CUSTOM PREFABS ADDED ----------

PrefabFiles = {
    "portablecoldfirepit"
}

---------- CUSTOM PREFAB RECIPES ----------

AddRecipe2("portablecoldfirepit_item", {Ingredient("nitre", 3), Ingredient("rope", 1), Ingredient("rocks", 4)}, TECH.NONE, {product = "portablecoldfirepit_item", image = "portablefirepit_item.tex", builder_skill = "walter_camp_fire"}, {"CHARACTER"})

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