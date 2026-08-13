GLOBAL.setmetatable(env, {
    __index = function(_, k)
        return GLOBAL.rawget(GLOBAL, k)
    end,
})

rawset(_G, "updatespells", rawget(_G, "updatespells") or function() end)

local load_lang_keys = require("mtu_strings")
load_lang_keys(STRINGS)

-- LOG PRINTING WRAPPER
local function modprint(s)
    return print("[MTU] " .. s)
end

---------- CUSTOM PREFABS ADDED ----------

PrefabFiles = {
    "portablecoldfirepit",
    "willow_ember",
    "charcoal_pit",
}

Assets = {
    Asset("ATLAS", "images/inventoryimages/charcoal_pit.xml"),
    Asset("ATLAS", "minimap/charcoal_pit.xml"),
    Asset("ATLAS", "images/icons.xml"),
    Asset("IMAGE", "images/icons.tex"),
}

AddMinimapAtlas("images/inventoryimages/charcoal_pit.xml")
AddMinimapAtlas("images/icons.xml")
AddMinimapAtlas("images/inventoryimages.xml")
AddMinimapAtlas("images/inventoryimages1.xml")
AddMinimapAtlas("images/inventoryimages2.xml")
AddMinimapAtlas("images/inventoryimages3.xml")

AddRecipe2("portablecoldfirepit_item", {Ingredient("nitre", 3), Ingredient("rope", 1), Ingredient("rocks", 4)}, TECH.NONE, {product = "portablecoldfirepit_item", image = "portablefirepit_item.tex", builder_skill = "walter_camp_fire"}, {"CHARACTER"})
AddRecipe2("charcoal_pit", {Ingredient("cutstone", 2), Ingredient("charcoal", 8), Ingredient("rocks", 12)}, TECH.SCIENCE_ONE, {placer = "charcoal_pit_placer", atlas = "images/inventoryimages/charcoal_pit.xml", image = "charcoal_pit.tex"}, {"REFINE"})

---------- GLOBAL CONSTANTS ----------

MTU = MTU or {}
MTU.players_loaded = 0
MTU.modprint = modprint

local function UpdatePlayersLoaded()
    local clients = TheNet:GetClientTable()
    -- only grabbing the count of players logged in
    MTU.players_loaded = clients ~= nil and #clients or 0
end

AddPrefabPostInit("world", function(world)
    if not TheWorld.ismastersim then
        return
    end

    world:ListenForEvent("ms_playerspawn", UpdatePlayersLoaded)
    world:ListenForEvent("ms_playerleft", UpdatePlayersLoaded)
end)

-- globabl boolean check for other mods
function modEnabled(modID)
    return KnownModIndex:IsModEnabled(modID)
end

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
    BOSS_SCALE_SOLO_BONUS = GetModConfigData("boss_scale_solo_bonus") or false,
    BOSS_SCALING_WORM_MOUTH = GetModConfigData("scale_boss_worm_mouth") or false,
    CRAFTABLE_WORM_BOSS_MOUTH = GetModConfigData("allow_craftable_boss_worm_mouth") or false
}
local no_swiping_config = {
    ALLOW_SLURTLE_EATING = GetModConfigData("allow_slurtles") or false,
    ALLOW_SPIDER_EATING = GetModConfigData("allow_spiders") or false,
    ALLOW_PIG_EATING = GetModConfigData("allow_pigs") or false,
    ALLOW_HOUND_EATING = GetModConfigData("allow_hounds") or false,
    ALLOW_WORM_BOSS_EATING = GetModConfigData("allow_worm_boss") or false
}
local trader_config = {
    SLINGSHOT_EVERYONE = GetModConfigData("slingshot_everyone") or false,
    PORTABLECAMPFIRE_EVERYONE = GetModConfigData("portablecampfire_everyone") or false,
    TRADER_ICON = GetModConfigData("wanderingtrader_icon") or false,
    WALTER_TRADES = GetModConfigData("wanderingtrader_walter_trades") or false,
    WARLY_TRADES = GetModConfigData("wanderingtrader_warly_trades") or false,
    WILLOW_TRADES = GetModConfigData("wanderingtrader_willow_trades") or false,
    WOODIE_TRADES = GetModConfigData("wanderingtrader_woodie_trades") or false,
    WILSON_TRADES = GetModConfigData("wanderingtrader_wilson_trades") or false,
    MAXWELL_TRADES = GetModConfigData("wanderingtrader_maxwell_trades") or false
}
local follower_config = {
    PROTECT_FOLLOWERS = GetModConfigData("protect_followers") or false,
    REVEAL_FOLLOWERS = GetModConfigData("reveal_follower_item") or false,
    NO_TAMED_DOMESTICATION_DECAY = GetModConfigData("no_tamed_domestication_decay") or false
}
local balatro_config = {
    WORM_BOSS_MOUTH_MOD = modEnabled("workshop-3474047377"),
    ALLOW_LUCK = GetModConfigData("allow_luck"),
    BURN_CARDS = GetModConfigData("burn_cards"),
    DROP_CARDS = GetModConfigData("drop_cards"),
    DROP_RECORD = GetModConfigData("drop_record"),
    DROP_HORSESHOE = GetModConfigData("drop_horseshoe"),
    TIER1_DROP_COUNT = GetModConfigData("tier1_drop_count") or 2,
    TIER2_DROP_COUNT = GetModConfigData("tier2_drop_count") or 2,
    TIER3_DROP_COUNT = GetModConfigData("tier3_drop_count") or 2,
    TIER4_DROP_COUNT = GetModConfigData("tier4_drop_count") or 2,
    TIER5_DROP_COUNT = GetModConfigData("tier5_drop_count") or 2,
    TIER6_DROP_COUNT = GetModConfigData("tier6_drop_count") or 4,
    TIER7_DROP_COUNT = GetModConfigData("tier7_drop_count") or 8,
    INCLUDE_KRAMPUS = GetModConfigData("include_krampus") or false,
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
    thulecite = GetModConfigData("thulecite_chance"),
    plants = GetModConfigData("plant_chance"),
    horrorfuel = GetModConfigData("horrorfuel_chance"),
    dreadstone = GetModConfigData("dreadstone_chance"),
    alterguardianhatshard = GetModConfigData("alterguardianhatshard_chance"),
    purebrilliance = GetModConfigData("purebrilliance_chance"),
    lunarplant_husk = GetModConfigData("lunarplant_husk_chance"),
    coolant = GetModConfigData("coolant_chance"),
    minotaurhorn = GetModConfigData("minotaurhorn_chance"),
    boss_worm_mouth = GetModConfigData("worm_boss_mouth_chance")
}
local medical_config = {
    MEDICAL_HAUNTING = GetModConfigData("medical_haunt") or false,
    MEDKIT_MOD = modEnabled("workshop-2812739628")
}
local extra_storage_items_config = {
    ALT_RECIPES_ALLOWED = GetModConfigData("allow_alt_recipes") or false,
    WEBBER_BIN = GetModConfigData("allow_spiders_bin") or false
}
local icon_finder_config = {
    BRIGHTSHADE_FINDER = GetModConfigData("brightshade_finder") or false,
    LUREPLANT_FINDER = GetModConfigData("lureplant_finder") or false,
    WALL_FINDER = GetModConfigData("wall_finder") or false,
    MARBLE_FINDER = GetModConfigData("marble_finder") or false,
    DEER_FINDER = GetModConfigData("deer_finder") or false,
    PIPSPOOK_FINDER = GetModConfigData("pipspook_finder") or false,
    MANDRAKE_FINDER = GetModConfigData("mandrake_finder") or false
}
local recipe_config = {
    CRAFTABLE_WORM_BOSS_MOUTH = GetModConfigData("allow_craftable_boss_worm_mouth") or false,
    WORM_BOSS_MOUTH_INGREDIENT_SET = GetModConfigData("boss_worm_mouth_recipe") or 1
}
local wall_regen_config = {
    WALL_HEALTH_ENHANCE = GetModConfigData("wall_health_enhance") or false,
    WALL_HEALTH_REGEN = GetModConfigData("wall_health_regen") or false,
    WALL_REGEN_VALUE = GetModConfigData("wall_regen_value") or 50
}
local asc_compat_config = {
    STORAGE_WARDROBE_MOD = modEnabled("workshop-2794741028"),
    STORAGE_COMPOSTINGBIN_MOD = modEnabled("workshop-3714039113")
}
local ubs_compat_config = {
    SPICEPACK_WATERPROOF = GetModConfigData("spicepack_waterproof") or false,
    SPICEPACK_INVENTORY = GetModConfigData("spicepack_inventory") or false,
    SPICEPACK_BURNABLE = GetModConfigData("spicepack_burnable") or true,
    SPICEPACK_PERISH_MULT = GetModConfigData("spicepack_perish_mult") or 1,
    WEBBER_BACKPACK_WATERPROOF = GetModConfigData("webber_backpack_waterproof") or false,
    WEBBER_BACKPACK_INVENTORY = GetModConfigData("webber_backpack_inventory") or false,
    WEBBER_BACKPACK_BURNABLE = GetModConfigData("webber_backpack_burnable") or true,
    WEBBER_BACKPACK_PERISH_MULT = GetModConfigData("webber_backpack_perish_mult") or 1
}
local everyone_settings_config = {
    HOWLITZER_STACKSIZE = GetModConfigData("howlitzer_stacksize") or false,
    SLINGSHOT_EVERYONE = GetModConfigData("slingshot_everyone") or false,
    PORTABLECAMPFIRE_EVERYONE = GetModConfigData("portablecampfire_everyone") or false,
    NO_SWIPING = GetModConfigData("no_swiping") or false,
    WARLY_COOKPOT_EVERYONE = GetModConfigData("warly_cookpot_everyone") or false,
    WARLY_RECIPES_LOCKED = GetModConfigData("warly_recipes_locked") or false,
    COOKPOT_CLIENT_MOD = modEnabled("workshop-727774324")
}
local perish_settings_config = {
    INCREASE_DRIED_PERISH = GetModConfigData("dried_food_perish_time") or false,
    DISGUISE_NONPERISH = GetModConfigData("disguise_perish") or false
}

local NO_SWIPING = GetModConfigData("no_swiping") or false
local EXTRA_STORAGE_ITEMS = GetModConfigData("extra_storage_items") or false
local AUTO_STUMP_REMOVAL = GetModConfigData("auto_stump_removal") or false

local LOOPING_WEEDS = GetModConfigData("looping_weeds") or false
local REMOVABLE_GRAVE = GetModConfigData("remove_grave") or false
local ALT_RECIPES_ALLOWED = GetModConfigData("allow_alt_recipes") or false
local WEBBER_RECIPES_ALLOWED = GetModConfigData("allow_webber_bulk") or false
local WANDERINGTRADER_ALT_TRADES = GetModConfigData("wanderingtrader_alt_trades") or false
local STORABLE_SOULS = GetModConfigData("storable_souls") or false
local FROG_RAIN_PERCENT = GetModConfigData("frog_rain_percent") or 1
local CRITTER_TRAIT_EFFECTS = GetModConfigData("critter_trait_effects") or false
local OCEANTREE_FIREFLIES = GetModConfigData("oceantree_fireflies") or false

local WORM_BOSS_MOUTH_MOD = modEnabled("workshop-3474047377")
local ULTIMATE_PERISH_SETTINGS_MOD = modEnabled("workshop-1242907291")
local MORE_EQUIP_SLOTS_MOD = modEnabled("workshop-3372256873")
local AUTO_SORT_CHEST_MOD = modEnabled("workshop-3232213331") or modEnabled("workshop-1932983865")
local ULTIMATE_BACKPACK_SETTINGS_MOD = modEnabled("workshop-1242915898")
-- this mod seems to be gone from steam so we will keep it here as legacy for anyone like me that has it still
local COFFEE_IN_FUMAROLES_MOD = modEnabled("workshop-3573989143")
local STRONGER_DRYING_RACK_MOD = modEnabled("workshop-3546208045")

---------- FEATURE FILES ----------

require("mtu_commands")

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
load_boss_scaling(MTU, modEnabled, boss_scaling_config, AllPlayers, distsq, AddPrefabPostInit, modimport)

local load_follower_protections = require("protect_followers")
load_follower_protections(TUNING, SetSharedLootTable, AddPrefabPostInit, follower_config)

local load_balatro_settings = require("balatro_settings")
load_balatro_settings(AddPrefabPostInit, TUNING, modEnabled, balatro_config)

local load_medical_settings = require("medical_settings")
load_medical_settings(AddPrefabPostInit, ACTIONS, medical_config)

local load_icon_finder = require("icon_finder")
load_icon_finder(AddPrefabPostInit, modEnabled, icon_finder_config)

local load_wall_regen_settings = require("wall_regen_settings")
load_wall_regen_settings(AddPrefabPostInit, TUNING, wall_regen_config)

local load_everyone_settings = require("everyone_settings")
load_everyone_settings(AddClassPostConstruct, AddPlayerPostInit, AddPrefabPostInit, everyone_settings_config)

local load_yotp_propsign = require("yotp_propsign")
load_yotp_propsign(AddPrefabPostInit, TUNING)

local load_perish_settings = require("perish_settings")
load_perish_settings(AddPrefabPostInit, TUNING, perish_settings_config)

if ALT_RECIPES_ALLOWED then
    local load_alt_recipes = require("alt_recipes")
    load_alt_recipes(modEnabled, recipe_config, AllRecipes, AddRecipe2, Ingredient, TECH, AddRecipeToFilter, CRAFTING_FILTERS, CHARACTER_INGREDIENT, AddIngredientValues, AddPrefabPostInit)
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
if EXTRA_STORAGE_ITEMS then
    local load_extra_storage_settings = require("extra_storage_settings")
    load_extra_storage_settings(AddPrefabPostInit, TUNING, extra_storage_items_config)
end
if AUTO_STUMP_REMOVAL then
    local load_auto_stump_removal = require("auto_stump_removal")
    load_auto_stump_removal(AddPrefabPostInit, AddPrefabPostInitAny, AddSimPostInit, modprint)
end
if CRITTER_TRAIT_EFFECTS then
    local load_critter_trait_effects = require("critter_trait_effects")
    load_critter_trait_effects(AddPrefabPostInit, AddSimPostInit, CRAFTING_FILTERS, TUNING, ACTIONS, modprint)
end
if AUTO_SORT_CHEST_MOD then
    local load_asc_compat = require("asc_compat")
    load_asc_compat(AddPrefabPostInit, asc_compat_config)
end
if MORE_EQUIP_SLOTS_MOD then
    local load_more_equip_slots_compat = require("more_equip_slots_compat")
    load_more_equip_slots_compat(AddPrefabPostInit, MESMODDED, EQUIPSLOTS)
end
if ULTIMATE_BACKPACK_SETTINGS_MOD then
    local load_ubs_compat = require("ubs_compat")
    load_ubs_compat(AddPrefabPostInit, ubs_compat_config)
end
if ULTIMATE_PERISH_SETTINGS_MOD then
    local load_ups_compat = require("ups_compat")
    load_ups_compat(AddPrefabPostInit)
end
if WORM_BOSS_MOUTH_MOD then
    local load_ups_compat = require("worm_boss_mouth_patch")
    load_ups_compat(AddSimPostInit, ACTIONS)
end
if COFFEE_IN_FUMAROLES_MOD then
    local load_ups_compat = require("ctf_patch")
    load_ups_compat(AddPrefabPostInit, DEPLOYSPACING_RADIUS, DEPLOYSPACING)
end
if STRONGER_DRYING_RACK_MOD then
    local load_ups_compat = require("sdr_patch")
    load_ups_compat(AddComponentPostInit)
end
if OCEANTREE_FIREFLIES then
    local load_oceantree_fireflies = require("oceantree_fireflies")
    load_oceantree_fireflies(AddPrefabPostInit, TWOPI, TUNING)
end
if STORABLE_SOULS then
    local load_storable_souls = require("storable_souls")
    load_storable_souls(AddPrefabPostInit)
end
if FROG_RAIN_PERCENT ~= 1 then
    local load_storable_souls = require("frog_rain_settings")
    load_storable_souls(TUNING)
end