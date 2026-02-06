name = "Map Tweak Utilities"
description = [[
Adds a collection of tweaks that I have found helpful while playing on shared maps with my sons.
Meaning we tend to build one shared mega base and work together on everything.
So everything tweaked inside this mod is with this style of co-op in mind.

Each tweak is optional, so if you're already using a mod that covers it you can just keep it disabled in this mod.

See CHANGELOG for full details inside the mod's folder or visit:
https://github.com/warrentode/MapTweakUtilities/blob/master/CHANGELOG.txt
]]
author = "ToadieOdie"
version = "2.1.1"

api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
all_clients_require_mod = true
client_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

forumthread = ""
priority = 0

local Empty = {{description = "", data = 0}}

local function Title(title)
    return {name = title, options = Empty, default = 0, }
end

configuration_options = {
    Title("=============================="),
    Title("Auto Stacking Settings"),
    Title("=============================="),
    {
        name = "auto_stack_enabled",
        label = "Enable Auto Stacking",
        hover = "if set to OFF, no items will auto-stack regardless of other settings.",
        options = {
            {description = "OFF", data = false},
            {description = "ON", data = true},
        },
        default = false,
    },
    {
        name = "stack_radius",
        label = "Auto Stack Radius",
        hover = "How far dropped items will search for matching stacks.",
        options = {
            {description = "10", data = 10},
            {description = "20", data = 20},
            {description = "30", data = 30},
            {description = "40", data = 40},
            {description = "50", data = 50},
        },
        default = 10,
    },
    {
        name = "exclude_seeds",
        label = "Exclude Generic Seeds",
        hover = "When set to TRUE, this item will not be auto stacked.",
        options = {
            {description = "FALSE", data = false},
            {description = "TRUE", data = true},
        },
        default = false,
    },
    {
        name = "exclude_crumbs",
        label = "Exclude Cookie Crumbs",
        hover = "When set to TRUE, this item will not be auto stacked.",
        options = {
            {description = "FALSE", data = false},
            {description = "TRUE", data = true},
        },
        default = false,
    },
    {
        name = "exclude_pigskin",
        label = "Exclude Pig Skin",
        hover = "When set to TRUE, this item will not be auto stacked.",
        options = {
            {description = "FALSE", data = false},
            {description = "TRUE", data = true},
        },
        default = false,
    },
    {
        name = "exclude_winter_food4",
        label = "Exclude Eternal Fruitcake",
        hover = "When set to TRUE, this item will not be auto stacked.",
        options = {
            {description = "FALSE", data = false},
            {description = "TRUE", data = true},
        },
        default = false,
    },
    {
        name = "exclude_powcake",
        label = "Exclude Powdercake",
        hover = "When set to TRUE, this item will not be auto stacked.",
        options = {
            {description = "FALSE", data = false},
            {description = "TRUE", data = true},
        },
        default = false,
    },
    Title("=============================="),
    Title("Blossom Drop Settings"),
    Title("=============================="),
    {
        name = "blossom_drop_chance",
        label = "Blossom Drop Chance",
        hover = "Percentage chance that a Lune Tree Blossom will drop per growth stage. 0 = never, 100 = always.",
        options = {
            {description = "0%", data = 0},
            {description = "25%", data = 25},
            {description = "50%", data = 50},
            {description = "75%", data = 75},
            {description = "100%", data = 100},
        },
        default = 0,
    },
    {
        name = "blossom_drop_cap",
        label = "Max Blossoms",
        hover = "Maximum number of nearby Lune Tree Blossoms checked before dropping more on the ground.",
        options = {
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
        },
        default = 2,
    },
    Title("=============================="),
    Title("Tree Growth Loop Settings"),
    Title("=============================="),
    {
        name = "pine_loop",
        label = "Evergreen Cycle",
        hover = "Enable or Disable Growth Stage Looping",
        options = {
            {description = "No Looping", data = true},
            {description = "Looping", data = false},
        },
        default = false,
    },
    {
        name = "lumpy_loop",
        label = "Lumpy Evergreen Cycle",
        hover = "Enable or Disable Growth Stage Looping",
        options = {
            {description = "No Looping", data = true},
            {description = "Looping", data = false},
        },
        default = false,
    },
    {
        name = "stone_fruit_loop",
        label = "Stone Fruit Bush Cycle",
        hover = "Enable or Disable Growth Stage Looping",
        options = {
            {description = "No Looping", data = true},
            {description = "Looping", data = false},
        },
        default = false,
    },
    {
        name = "twiggy_loop",
        label = "Twiggy Tree Cycle",
        hover = "Enable or Disable Growth Stage Looping",
        options = {
            {description = "No Looping", data = true},
            {description = "Looping", data = false},
        },
        default = false,
    },
    {
        name = "birch_loop",
        label = "Birch Cycle",
        hover = "Enable or Disable Growth Stage Looping",
        options = {
            {description = "No Looping", data = true},
            {description = "Looping", data = false},
        },
        default = false,
    },
    {
        name = "moon_loop",
        label = "Lune Tree Cycle",
        hover = "Enable or Disable Growth Stage Looping",
        options = {
            {description = "No Looping", data = true},
            {description = "Looping", data = false},
        },
        default = false,
    },
    {
        name = "marble_loop",
        label = "Marble Shrub Cycle",
        hover = "Enable or Disable Growth Stage Looping",
        options = {
            {description = "No Looping", data = true},
            {description = "Looping", data = false},
        },
        default = false,
    },
    {
        name = "palm_loop",
        label = "Palmcone Tree Cycle",
        hover = "Enable or Disable Growth Stage Looping",
        options = {
            {description = "No Looping", data = true},
            {description = "Looping", data = false},
        },
        default = false,
    },
    {
        name = "mush_loop",
        label = "Mushroom Tree Cycle",
        hover = "Enable or Disable Growth Stage Looping",
        options = {
            {description = "No Looping", data = true},
            {description = "Looping", data = false},
        },
        default = false,
    },
    Title("=============================="),
    Title("Batch Trade Settings"),
    Title("=============================="),
    {
        name = "batch_trades_enabled",
        label = "Enable Batch Trades",
        hover = "If ON, players can trade batches of items to the Bird Cage, Pig King, Merm King, and Antlion",
        options = {
            {description = "OFF", data = false},
            {description = "ON", data = true},
        },
        default = false,
    },
    Title("=============================="),
    Title("Block Starvation"),
    Title("Death Settings"),
    Title("=============================="),
    {
        name = "no_starve_mermking",
        label = "Merm King",
        hover = "If set to YES, he will still get hungry and complain about it but not die from it",
        options = {
            {description = "YES", data = true},
            {description = "NO",  data = false},
        },
        default = false,
    },
    {
        name = "no_starve_bird_cage",
        label = "Bird Cage",
        hover = "If set to YES, birds in bird cages will not starve.",
        options = {
            {description = "YES", data = true},
            {description = "NO",  data = false},
        },
        default = false,
    },
    Title("=============================="),
    Title("Dock Kit Settings"),
    Title("=============================="),
    {
        name = "dock_kit_placement_override",
        label = "Dock Kit Placement",
        hover = "If set to YES, dock kits can be placed on any type of ocean tile. Dock kits retain the requirement of interconnection to land. This means if a dock kit is placed over the center of a whirlpool, teleportation is blocked until the dock tile is destroyed.",
        options = {
            {description = "YES", data = true},
            {description = "NO",  data = false},
        },
        default = false,
    },
    Title("=============================="),
    Title("Rope Bridge Settings"),
    Title("=============================="),
    {
        name = "rope_bridge_max_length",
        label = "Rope Bridge Max Length",
        hover = "Sets the maximum length of a rope bridge in tiles. Longer bridges require more bridge kits to build. Remaining rules for rope bridge placement are unchanged.",
        options = {
            {description = "Default (6)",  data = 6},
            {description = "Medium (12)", data = 12},
            {description = "Long (18)",   data = 18},
            {description = "Extra Long (24)",  data = 24},
        },
        default = 6,
    },
    Title("=============================="),
    Title("Grave Settings"),
    Title("=============================="),
    {
        name = "remove_grave",
        label = "Removable Graves",
        hover = "If set to Yes, headstones can be smashed and empty graves can be removed by digging.",
        options = {
            {description = "YES", data = true},
            {description = "NO",  data = false},
        },
        default = false,
    },
    Title("=============================="),
    Title("Weed Settings"),
    Title("=============================="),
    {
        name = "looping_weeds",
        label = "Weeds Growth Loop",
        hover = "If set to Yes, a weed cycles back into its growth loop after bolting.",
        options = {
            {description = "YES", data = true},
            {description = "NO",  data = false},
        },
        default = false,
    },
    Title("=============================="),
    Title("Alt Recipe Settings"),
    Title("=============================="),
    {
        name = "allow_alt_recipes",
        label = "Allow Alt Recipes",
        hover = "If set to Yes, alternate recipes using dried ingredients instead of fresh ones are added.",
        options = {
            {description = "YES", data = true},
            {description = "NO",  data = false},
        },
        default = false,
    },
    Title("=============================="),
    Title("Webber Recipe Settings"),
    Title("=============================="),
    {
        name = "allow_webber_bulk",
        label = "Allow Alt Webber Recipes",
        hover = "If set to Yes, alternate recipes for Webber are added.",
        options = {
            {description = "YES", data = true},
            {description = "NO",  data = false},
        },
        default = false,
    },
    {
        name = "webber_bulk_count",
        label = "Webber Bulk Product Count",
        hover = "Set the product count multiplier for Webber's bulk recipes if his alt recipes are enabled.",
        options = {
            {description = "5",  data = 5},
            {description = "10 (Default)",  data = 10},
            {description = "15",  data = 15},
            {description = "20",  data = 20},
        },
        default = 10,
    },
    Title("=============================="),
    Title("Ranged Weapon Settings"),
    Title("=============================="),
    {
        name = "howlitzer_stacksize",
        label = "Howlitzer Stack Size",
        hover = "If set to Yes, ammo slot stack size is infinite.",
        options = {
            {description = "YES", data = true},
            {description = "NO",  data = false},
        },
        default = false,
    },
    {
        name = "slingshot_everyone",
        label = "Everyone Equip Slingshot",
        hover = "If set to Yes, the slingshot can be equipped by everyone. Recipes remain Walter only.",
        options = {
            {description = "YES", data = true},
            {description = "NO",  data = false},
        },
        default = false,
    },
    Title("=============================="),
    Title("Portable Campfire Settings"),
    Title("=============================="),
    {
        name = "portablecampfire_everyone",
        label = "Everyone Use Portable Campfire",
        hover = "If set to Yes, the portable campfire can be placed and picked up by everyone. Recipe remains Walter only.",
        options = {
            {description = "YES", data = true},
            {description = "NO",  data = false},
        },
        default = false,
    },
    Title("=============================="),
    Title("Wandering Trader Settings"),
    Title("=============================="),
    {
        name = "wanderingtrader_alt_trades",
        label = "Extra Trades Added",
        hover = "If set to Yes, the Wandering Trader will have extra trades added to his list of offerings.",
        options = {
            {description = "YES", data = true},
            {description = "NO",  data = false},
        },
        default = false,
    },
    Title("=============================="),
    Title("Boss Loot Scaling"),
    Title("=============================="),
    {
        name = "scale_boss_loot",
        label = "Scaling Mode",
        hover = "Set which boss loot scaling mode you want used.",
        options = {
            {description = "No Scaling", data = 0},
            {description = "By Players Logged In", data = 1},
            {description = "By Players in Range", data = 2},
        },
        default = 0,
    },
    {
        name = "boss_scale_range",
        label = "Player Boss Range",
        hover = "Radius around boss to count players for loot scaling if set to this scaling mode.",
        options =
        {
            {description = "10", data = 10},
            {description = "20", data = 20},
            {description = "30", data = 30},
            {description = "40", data = 40},
            {description = "50", data = 50},
        },
        default = 30,
    },
    {
        name = "boss_scale_blueprints",
        label = "Scale Blueprint Drops",
        hover = "Toggle scaling for boss blueprint drops.",
        options =
        {
            {description = "Disabled", data = false},
            {description = "Enabled", data = true},
        },
        default = false,
    },
    {
        name = "scale_boss_worm_mouth",
        label = "Scale Boss Worm Mouth",
        hover = "Include Boss Worm Mouth in scaling (requires the Giant Worm Can Dig Wormhole mod) - gives 2 mouths per player",
        options =
        {
            {description = "Disabled", data = false},
            {description = "Enabled", data = true},
        },
        default = false,
    },
    Title("=============================="),
    Title("Item Protections"),
    Title("=============================="),
    {
        name = "no_swiping",
        label = "Protect Items From Being Swiped",
        hover = "If Enabled, items cannot be stolen, rumaged, harvested, or eaten by other mobs.",
        options =
        {
            {description = "Disabled", data = false},
            {description = "Enabled", data = true},
        },
        default = false,
    },
    {
        name = "allow_slurtles",
        label = "Allow Slurtle Eating",
        hover = "If Enabled, slurtles and snurtles will be allowed to eat items on the ground when swiping protections are enabled.",
        options =
        {
            {description = "Disabled", data = false},
            {description = "Enabled", data = true},
        },
        default = false,
    },
    {
        name = "allow_worm_boss",
        label = "Allow Worm Boss Eating",
        hover = "If Enabled, the great depths worm will eat things normally when swiping protections are enabled.",
        options =
        {
            {description = "Disabled", data = false},
            {description = "Enabled", data = true},
        },
        default = false,
    },
}