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
load_boss_scaling(MTU, boss_scaling_config, GetSharedLootTable, SetSharedLootTable, AllPlayers, distsq, AddPrefabPostInit, modimport, KnownModIndex)

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

---------- CUSTOM PATCH FOR BALATRO REWARDS ----------
local BALATRO_UTIL = require("prefabs/balatro_util")

---- setup my config driven tables

local TIER1_DROP_COUNT = GetModConfigData("tier1_drop_count") or 2
local TIER2_DROP_COUNT = GetModConfigData("tier2_drop_count") or 2
local TIER3_DROP_COUNT = GetModConfigData("tier3_drop_count") or 2
local TIER4_DROP_COUNT = GetModConfigData("tier4_drop_count") or 2
local TIER5_DROP_COUNT = GetModConfigData("tier5_drop_count") or 2
local TIER6_DROP_COUNT = TIER5_DROP_COUNT * 2
local TIER7_DROP_COUNT = TIER6_DROP_COUNT + 2

local BOOBY_PRIZE_CONFIG = {
    killerbee = GetModConfigData("killerbee_count"),
    hound = GetModConfigData("hound_count"),
    spider = GetModConfigData("spider_count"),
    worm = GetModConfigData("worm_count")
}
local TIER1_LOOT_CONFIG = {
    cutgrass = GetModConfigData("cutgrass_chance"),
    twigs = GetModConfigData("twigs_chance"),
    rocks = GetModConfigData("rocks_chance"),
    flint = GetModConfigData("flint_chance"),
    log = GetModConfigData("log_chance"),
    cutreeds = GetModConfigData("cutreeds_chance")
}
local TIER2_LOOT_CONFIG = {
    cutstone = GetModConfigData("cutstone_chance"),
    rope = GetModConfigData("rope_chance"),
    boards = GetModConfigData("boards_chance"),
    papyrus = GetModConfigData("papyrus_chance"),
    transistor = GetModConfigData("transistor_chance"),
    livinglog = GetModConfigData("livinglog_chance"),
    beeswax = GetModConfigData("beeswax_chance"),
    marblebean = GetModConfigData("marblebean_chance"),
    nightmarefuel = GetModConfigData("nightmarefuel_chance")
}
local TIER3_LOOT_CONFIG = {
    cave_banana = GetModConfigData("cave_banana_chance"),
    fig = GetModConfigData("fig_chance"),
    pumpkin = GetModConfigData("pumpkin_chance"),
    dragonfruit = GetModConfigData("dragonfruit_chance"),
    cactus_flower = GetModConfigData("cactus_flower_chance"),
    bird_egg = GetModConfigData("bird_egg_chance")
}
local TIER4_LOOT_CONFIG = {
    bananapop = GetModConfigData("bananapop_chance"),
    bananajuice = GetModConfigData("bananajuice_chance"),
    frozenbananadaiquiri = GetModConfigData("frozenbananadaiquiri_chance"),
    cave_banana_cooked = GetModConfigData("cave_banana_cooked_chance"),
    watermelonicle = GetModConfigData("watermelonicle_chance"),
    fruitmedley = GetModConfigData("fruitmedley_chance")
}
-- vanilla uses the same items for Tier 5 and Tier 6
local TIER5_LOOT_CONFIG = {
    goldnugget = GetModConfigData("goldnugget_chance"),
    moonrocknugget = GetModConfigData("moonrocknugget_chance"),
    gears = GetModConfigData("gears_chance"),
    pigskin = GetModConfigData("pigskin_chance"),
    steelwool = GetModConfigData("steelwool_chance"),
    manrabbit_tail = GetModConfigData("manrabbit_tail_chance"),
    slurper_pelt = GetModConfigData("slurper_pelt_chance")
}
-- vanilla includes tier 5 loot, but we're not going to do that here
local TIER7_LOOT_CONFIG = {
    redgem = GetModConfigData("redgem_chance"),
    bluegem = GetModConfigData("bluegem_chance"),
    purplegem = GetModConfigData("purplegem_chance"),
    yellowgem = GetModConfigData("yellowgem_chance"),
    orangegem = GetModConfigData("orangegem_chance"),
    greengem = GetModConfigData("greengem_chance"),
    opalpreciousgem = GetModConfigData("opalpreciousgem_chance"),
    thulecite = GetModConfigData("thulecite_chance")
}

--- prize loot table builders ---
-- booby prize
local function BuildBoobyPrize(lootConfig)
    local booby_prize = {}
    for mobName, count in pairs(lootConfig) do
        if count and count > 0 then
            table.insert(booby_prize, {
                -- the mobName gets capitlized here for chatter translation key
                string = mobName:upper(),
                loot = {
                    {mobName, count}
                }
            })
        end
    end

    -- fallback if no mobs were configured
    if #booby_prize == 0 then
        table.insert(booby_prize, {
            string = "BIRCHNUTDRAKE",
            loot = {
                {"birchnutdrake", 4}
            }
        })
    end

    return booby_prize
end

-- Helper function to pick a random item from a weighted table
local function PickWeightedLoot(lootPool, pickCount)
    local pickedLoot = {}

    local totalWeight = 0
    for _, item in ipairs(lootPool) do
        totalWeight = totalWeight + item.weight
    end

    for _ = 1, pickCount do
        local rand = math.random() * totalWeight
        local cumulative = 0
        for _, item in ipairs(lootPool) do
            cumulative = cumulative + item.weight
            if rand <= cumulative then
                -- to safeguard against duplicate picks in a roll, count = 1
                table.insert(pickedLoot, {item.prefab, 1})
                break
            end
        end
    end

    return pickedLoot
end
-- tier prize tables
local tier1loot = {}
local tier2loot = {}
local tier3loot = {}
local tier4loot = {}
local tier5loot = {}
local tier6loot = {}
local tier7loot = {}

-- tier prize table builder function
local function BuildTierLootSet(target, configTable)
    for prefab, weight in pairs(configTable) do
        if weight and weight > 0 then
            table.insert(target, {prefab = prefab, weight = weight})
        end
    end

    -- fallback if no weighted entries were added
    if #target == 0 then
        table.insert(target, {prefab = "birchnutdrake", weight = 1})
    end
end

-- builder calls for tier loot tables
BuildTierLootSet(tier1loot, TIER1_LOOT_CONFIG)
BuildTierLootSet(tier2loot, TIER2_LOOT_CONFIG)
BuildTierLootSet(tier3loot, TIER3_LOOT_CONFIG)
BuildTierLootSet(tier4loot, TIER4_LOOT_CONFIG)
BuildTierLootSet(tier5loot, TIER5_LOOT_CONFIG)
-- tier 6 uses tier 5 config for now
BuildTierLootSet(tier6loot, TIER5_LOOT_CONFIG)
BuildTierLootSet(tier7loot, TIER7_LOOT_CONFIG)
-- uses the booby prize config since vanilla uses the same mobs for both
local function BuildRunawayPrize(config)
    local runaway_prize = {}
    for mobName, count in pairs(config) do
        if count and count > 0 then
            table.insert(runaway_prize, {
                -- the mobName gets capitlized here for chatter translation key
                string = mobName:upper(),
                loot = {
                    -- for running away, because sometimes you have to, the count is set to 1
                    {mobName, 1}
                }
            })
        end
    end

    -- fallback if no mobs were configured
    if #runaway_prize == 0 then
        table.insert(runaway_prize, {
            string = "BIRCHNUTDRAKE",
            loot = {
                {"birchnutdrake", 4}
            }
        })
    end

    return runaway_prize
end

-- build the new REWARDS table
local function BuildRewards(rewards)
    -- clear ALL pre-existing reward tables
    for i = #rewards, 1, -1 do
        table.remove(rewards, i)
    end

    --- booby prize
    local booby_prize = BuildBoobyPrize(BOOBY_PRIZE_CONFIG)
    table.insert(rewards, booby_prize)
    --- Tier 1 Loot Set (basic crafting materials)
    local tier1 = {
        string = "RESOURCES",
        loot = PickWeightedLoot(tier1loot, TIER1_DROP_COUNT)
    }
    table.insert(rewards, tier1)
    --- Tier 2 Loot Set (refined crafting materials)
    local tier2 = {
        string = "REFINEDRESOURCES",
        loot = PickWeightedLoot(tier2loot, TIER2_DROP_COUNT)
    }
    table.insert(rewards, tier2)
    --- Tier 3 Loot Set (edible ingredients)
    local tier3 = {
        string = "SNACKS",
        loot = PickWeightedLoot(tier3loot, TIER3_DROP_COUNT)
    }
    table.insert(rewards, tier3)
    --- Tier 4 Loot Set (crockpot dishes)
    local tier4 = {
        string = "TREATS",
        loot = PickWeightedLoot(tier4loot, TIER4_DROP_COUNT)
    }
    table.insert(rewards, tier4)
    --- Tier 5 Loot Set (rare crafting materials?)
    local tier5 = {
        string = "RARITIES",
        loot = PickWeightedLoot(tier5loot, TIER5_DROP_COUNT)
    }
    table.insert(rewards, tier5)
    --- Tier 6 Loot Set (rare crafting materials? but x4 count)
    local tier6 = {
        string = "RARITIES",
        loot = PickWeightedLoot(tier6loot, TIER6_DROP_COUNT)
    }
    table.insert(rewards, tier6)
    --- Tier 7 Loot Set (rare crafting materials? but x6 count, plus gems)
    local tier7 = {
        string = "TREASURE",
        loot = PickWeightedLoot(tier7loot, TIER7_DROP_COUNT)
    }
    table.insert(rewards, tier7)
    ---- Run away prizes, keep at the bottom.
    local runaway_prize = BuildRunawayPrize(BOOBY_PRIZE_CONFIG)
    table.insert(rewards, runaway_prize)
end

local function getval(fn, path)
    if fn == nil or type(fn) ~= "function" then
        return
    end
    local val = fn
    local i
    for entry in path:gmatch("[^%.]+") do
        i = 1
        while true do
            local name, value = debug.getupvalue(val, i)
            if name == entry then
                val = value
                break
            elseif name == nil then
                return
            end
            i = i + 1
        end
    end
    return val, i
end
local function setval(fn, name, newfn)
    if fn == nil or type(fn) ~= "function" then
        return
    end
    local i = 1
    while true do
        local k, _ = debug.getupvalue(fn, i)
        if k == name then
            break
        elseif k == nil then
            return
        end
        i = i + 1
    end
    debug.setupvalue(fn, i, newfn)
end

-- card and record configs
local DROP_CARDS = GetModConfigData("drop_cards")
local DROP_RECORD = GetModConfigData("drop_record")

-- override card and record drops conditionally
local function SpawnCardRewards(inst, _, score, target)
    -- if both drops are set to false
    if not DROP_CARDS and not DROP_RECORD then
        -- inform the player
        inst.sg:GoToState("talk")
        inst.components.talker:Chatter("JIMBO_NO_EXTRAS")

        -- reset the machine
        BALATRO_UTIL.SetLightMode_Idle(inst)
        inst.components.activatable.inactive = true
        inst.rewarding = false

        -- cancel the rest
        return
    end

    -- vanilla spawns 3 cards
    if DROP_CARDS then
        for _ = 1, score do
            local range = 2 + math.random() * 0.5
            local offset = FindWalkableOffset(target, math.random() * 360, range, 16)
            local posX, posY, posZ = (target + offset):Get()

            local reward = TheWorld.components.playingcardsmanager:MakePlayingCard(nil, true)
            reward.Transform:SetPosition(posX, posY, posZ)

            local fx = SpawnPrefab("die_fx")
            fx.Transform:SetPosition(posX, posY, posZ)
            fx.Transform:SetScale(0.5, 0.5, 0.5)
        end
    else
        -- inform the player of false setting
        inst.sg:GoToState("talk")
        inst.components.talker:Chatter("JIMBO_NO_CARDS")
    end

    -- vanilla spawns 1 card and 1 record
    if DROP_RECORD then
        if score > 5 then
            local range = 2 + math.random() * 0.5
            local offset = FindWalkableOffset(target, math.random() * 360, range, 16)
            local posX, posY, posZ = (target + offset):Get()

            if DROP_CARDS then
                local reward = TheWorld.components.playingcardsmanager:MakePlayingCard(nil, true)
                reward.Transform:SetPosition(posX, posY, posZ)
            end

            local range = 2 + math.random() * 0.5
            local offset = FindWalkableOffset(target, math.random() * 360, range, 16)
            local posX, posY, posZ = (target + offset):Get()

            local record = SpawnPrefab("record")
            record:SetRecord("balatro")
            record.Transform:SetPosition(posX, posY, posZ)

            local fx = SpawnPrefab("die_fx")
            fx.Transform:SetPosition(posX, posY, posZ)
            fx.Transform:SetScale(0.5, 0.5, 0.5)
        end
    else
        -- inform the player of false setting
        inst.sg:GoToState("talk")
        inst.components.talker:Chatter("JIMBO_NO_RECORD")
    end

    -- vanilla resets the machine
    BALATRO_UTIL.SetLightMode_Idle(inst)
    inst.components.activatable.inactive = true
    inst.rewarding = false
end

AddPrefabPostInit("balatro_machine", function(inst)
    if not TheNet or not TheNet:GetIsServer() then
        return
    end

    local REWARDS = getval(inst.ondoerremoved, "EndInteraction.REWARDS")
    BuildRewards(REWARDS)

    local SpawnCardRewardSequence = getval(inst.ondoerremoved, "EndInteraction.StartRewardsSequence.DoDelayedRewards.SpawnCardRewardSequence")
    setval(SpawnCardRewardSequence, "SpawnCardRewards", SpawnCardRewards)
end)