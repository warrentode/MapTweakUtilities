---------- CUSTOM PATCH FOR BALATRO REWARDS ----------

return function(AddPrefabPostInit, TUNING, config)
    local BALATRO_UTIL = require("prefabs/balatro_util")

    ---- setup configs constants
    local BURN_CARDS = config.BURN_CARDS
    local DROP_CARDS = config.DROP_CARDS
    local DROP_RECORD = config.DROP_RECORD
    local TIER1_DROP_COUNT = config.TIER1_DROP_COUNT
    local TIER2_DROP_COUNT = config.TIER2_DROP_COUNT
    local TIER3_DROP_COUNT = config.TIER3_DROP_COUNT
    local TIER4_DROP_COUNT = config.TIER4_DROP_COUNT
    local TIER5_DROP_COUNT = config.TIER5_DROP_COUNT
    local TIER6_DROP_COUNT = TIER5_DROP_COUNT * 2
    local TIER7_DROP_COUNT = TIER6_DROP_COUNT + 2

    -- prefab name, count
    local BOOBY_PRIZE_CONFIG = {
        killerbee = config.killerbee,
        hound = config.hound,
        spider = config.spider,
        worm = config.worm
    }
    -- prefab name, weight
    local TIER1_LOOT_CONFIG = {
        cutgrass = config.cutgrass,
        twigs = config.twigs,
        rocks = config.rocks,
        flint = config.flint,
        log = config.log,
        cutreeds = config.cutreeds
    }
    local TIER2_LOOT_CONFIG = {
        cutstone = config.cutstone,
        rope = config.rope,
        boards = config.boards,
        papyrus = config.papyrus,
        transistor = config.transistor,
        livinglog = config.livinglog,
        beeswax = config.beeswax,
        marblebean = config.marblebean,
        nightmarefuel = config.nightmarefuel
    }
    local TIER3_LOOT_CONFIG = {
        cave_banana = config.cave_banana,
        fig = config.fig,
        pumpkin = config.pumpkin,
        dragonfruit = config.dragonfruit,
        cactus_flower = config.cactus_flower,
        bird_egg = config.bird_egg
    }
    local TIER4_LOOT_CONFIG = {
        bananapop = config.bananapop,
        bananajuice = config.bananajuice,
        frozenbananadaiquiri = config.frozenbananadaiquiri,
        cave_banana_cooked = config.cave_banana_cooked,
        watermelonicle = config.watermelonicle,
        fruitmedley = config.fruitmedley
    }
    local TIER5_LOOT_CONFIG = {
        goldnugget = config.goldnugget,
        moonrocknugget = config.moonrocknugget,
        gears = config.gears,
        pigskin = config.pigskin,
        steelwool = config.steelwool,
        manrabbit_tail = config.manrabbit_tail,
        slurper_pelt = config.slurper_pelt
    }
    -- vanilla uses the same items for Tier 5 and Tier 6
    local TIER6_LOOT_CONFIG = {
        goldnugget = config.goldnugget,
        moonrocknugget = config.moonrocknugget,
        gears = config.gears,
        pigskin = config.pigskin,
        steelwool = config.steelwool,
        manrabbit_tail = config.manrabbit_tail,
        slurper_pelt = config.slurper_pelt
    }
    -- vanilla includes tier 5 loot, but we're not going to do that here
    local TIER7_LOOT_CONFIG = {
        redgem = config.redgem,
        bluegem = config.bluegem,
        purplegem = config.purplegem,
        yellowgem = config.yellowgem,
        orangegem = config.orangegem,
        greengem = config.greengem,
        opalpreciousgem = config.opalpreciousgem,
        thulecite = config.thulecite
    }

    --- prize loot table building logic ---

    -- helper functions
    local function getValue(fn, path)
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
    local function setValue(fn, name, newfn)
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

    -- define the tier prize tables
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
    BuildTierLootSet(tier6loot, TIER6_LOOT_CONFIG)
    BuildTierLootSet(tier7loot, TIER7_LOOT_CONFIG)

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

    -- patch the machine prefab with the changes
    AddPrefabPostInit("balatro_machine", function(inst)
        if not TheNet or not TheNet:GetIsServer() then
            return
        end

        local REWARDS = getValue(inst.ondoerremoved, "EndInteraction.REWARDS")
        -- initial build of reward tables so they don't start empty
        BuildRewards(REWARDS)

        -- reroll tables each time a game is played
        local oldOnActivated = inst.components.activatable.OnActivate
        inst.components.activatable.OnActivate = function(self, doer)
            BuildRewards(REWARDS)
            oldOnActivated(self, doer)
        end

        local SpawnCardRewardSequence = getValue(inst.ondoerremoved, "EndInteraction.StartRewardsSequence.DoDelayedRewards.SpawnCardRewardSequence")
        setValue(SpawnCardRewardSequence, "SpawnCardRewards", SpawnCardRewards)
    end)

    -- patch cards and deck of cards to be burnable
    if BURN_CARDS then
        AddPrefabPostInit("playing_card", function(inst)
            inst:AddComponent("fuel")
            inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

            inst:AddComponent("burnable")
            MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
            MakeSmallPropagator(inst)

            inst.components.burnable:SetOnBurntFn(function(inst)
                local stacksize = inst.components.stackable and inst.components.stackable:StackSize() or 1
                local ash = SpawnPrefab("ash")
                if ash and ash.components.stackable then
                    ash.components.stackable:SetStackSize(stacksize)
                    ash.Transform:SetPosition(inst.Transform:GetWorldPosition())
                end
                inst:Remove()
            end)
        end)
        -- a deck of cards are not set as fuel since I don't want to bother with calculating per card inside
        AddPrefabPostInit("deck_of_cards", function(inst)
            inst:AddComponent("burnable")
            MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
            MakeSmallPropagator(inst)
            inst.components.burnable:SetOnBurntFn(function(inst)
                local num_cards = inst.components.deckcontainer:Count()
                for _ = 1, math.floor(num_cards / 1) do
                    SpawnPrefab("ash").Transform:SetPosition(inst.Transform:GetWorldPosition())
                end
                inst:Remove()
            end)
        end)
    end
end