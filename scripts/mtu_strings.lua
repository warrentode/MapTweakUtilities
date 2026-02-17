return function(STRINGS)
    STRINGS.NAMES.PORTABLECOLDFIREPIT_ITEM = "Endothermic Portable Firepit"
    STRINGS.RECIPE_DESC.PORTABLECOLDFIREPIT_ITEM = "A campfire made for adventure, but still backwards -- even on the go!"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.PORTABLECOLDFIREPIT_ITEM = "Walter makes the coolest things!"
    STRINGS.CHARACTERS.WALTER.DESCRIBE.PORTABLECOLDFIREPIT_ITEM = "Hey Woby, isn't this the coolest thing?"
    -- added these for when the config option for basic slingshot for everyone is set to true
    STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.MODSLINGSHOT.NOSLINGSHOT = "I don't know how to mod a slingshot, even if I had one!"
    STRINGS.CHARACTERS.GENERIC.ANNOUNCE_AMMO_SLOT_OVERSTACKED = "Too much ammo in there to swap it seems"
    STRINGS.CHARACTERS.GENERIC.ANNOUNCE_SLINGHSOT_NO_AMMO_SKILL = "What's the deal with this ammo?"
    STRINGS.CHARACTERS.GENERIC.ANNOUNCE_SLINGHSOT_NO_PARTS_SKILL = "Wait, I can't use this thing!"
    STRINGS.CHARACTERS.GENERIC.ANNOUNCE_SLINGHSOT_OUT_OF_AMMO = "Out of ammo, better run!"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.SLINGSHOT.NOT_MINE = "Oh, this isn't mine. I should leave it alone."
    -- added these for when the config option for extra wandering trader trades is set to true
    STRINGS.RECIPE_DESC.WANDERINGTRADERSHOP_MARBLES = "Careful not to shoot your eye out with this..."
    STRINGS.RECIPE_DESC.WANDERINGTRADERSHOP_SLINGSHOTAMMO_MARBLE = "Careful not to shoot your eye out with this..."
    STRINGS.RECIPE_DESC.WANDERINGTRADERSHOP_DUG_GRASS = "For your replanting needs."
    STRINGS.RECIPE_DESC.WANDERINGTRADERSHOP_DUG_SAPLING = "For your replanting needs."
    STRINGS.RECIPE_DESC.WANDERINGTRADERSHOP_DUG_BERRYBUSH = "For your replanting needs."
    STRINGS.RECIPE_DESC.WANDERINGTRADERSHOP_PINECONE = "For your replanting needs."
    STRINGS.RECIPE_DESC.WANDERINGTRADERSHOP_ACORN = "For your replanting needs."
    STRINGS.RECIPE_DESC.WANDERINGTRADERSHOP_BEDROLL_STRAW = "Sleep on the go, where ever you need to."
    STRINGS.RECIPE_DESC.WANDERINGTRADERSHOP_SLINGSHOT = "For your on the go hunting needs."
    STRINGS.RECIPE_DESC.WANDERINGTRADERSHOP_PORTABLEFIREPIT = "For all your lighting and heating needs while on the go."
    STRINGS.RECIPE_DESC.WANDERINGTRADERSHOP_PORTABLECOLDFIREPIT = "For all your lighting and cooling needs while on the go."
    STRINGS.RECIPE_DESC.WANDERINGTRADERSHOP_PORTABLETENT = "Sleep in comfort and style while on the go."
    -- added these for the festive light recipes
    local ornamentString = STRINGS.NAMES.WINTER_ORNAMENTLIGHT
    local ornamentDesc = "Craft a tiny light of good cheer!"
    STRINGS.NAMES.WINTER_ORNAMENT_LIGHT1 = ornamentString
    STRINGS.NAMES.WINTER_ORNAMENT_LIGHT2 = ornamentString
    STRINGS.NAMES.WINTER_ORNAMENT_LIGHT3 = ornamentString
    STRINGS.NAMES.WINTER_ORNAMENT_LIGHT4 = ornamentString
    STRINGS.NAMES.WINTER_ORNAMENT_LIGHT5 = ornamentString
    STRINGS.NAMES.WINTER_ORNAMENT_LIGHT6 = ornamentString
    STRINGS.NAMES.WINTER_ORNAMENT_LIGHT7 = ornamentString
    STRINGS.NAMES.WINTER_ORNAMENT_LIGHT8 = ornamentString
    STRINGS.RECIPE_DESC.WINTER_ORNAMENT_LIGHT1 = ornamentDesc
    STRINGS.RECIPE_DESC.WINTER_ORNAMENT_LIGHT2 = ornamentDesc
    STRINGS.RECIPE_DESC.WINTER_ORNAMENT_LIGHT3 = ornamentDesc
    STRINGS.RECIPE_DESC.WINTER_ORNAMENT_LIGHT4 = ornamentDesc
    STRINGS.RECIPE_DESC.WINTER_ORNAMENT_LIGHT5 = ornamentDesc
    STRINGS.RECIPE_DESC.WINTER_ORNAMENT_LIGHT6 = ornamentDesc
    STRINGS.RECIPE_DESC.WINTER_ORNAMENT_LIGHT7 = ornamentDesc
    STRINGS.RECIPE_DESC.WINTER_ORNAMENT_LIGHT8 = ornamentDesc
    -- balatro related strings
    local NEW_REWARD_STRINGS = {
        KILLERBEE = "KILLER BEES",
        SPIDER = "SPIDERS",
        HOUND = "HOUNDS",
        WORM = "WORMS",
        BIRCHNUTDRAKE = "NOTHING",
        REFINEDRESOURCES = "REFINED RESOURCES",
        SNACKS = "SNACKS",
        TREATS = "TREATS",
        RARITIES = "RARITIES"
    }
    for k,v in pairs(NEW_REWARD_STRINGS) do
        STRINGS.BALATRO.JIMBO_REWARD_TYPES[k] = v
    end
    STRINGS.BALATRO.JIMBO_NO_EXTRAS = "Oh, the boss says no extras for you. Too bad!"
    STRINGS.BALATRO.JIMBO_NO_CARDS = "Oh, the boss says no cards for you. Too bad!"
    STRINGS.BALATRO.JIMBO_NO_RECORD = "Oh, the boss says no record for you. Too bad!"
    -- propsign strings
    STRINGS.NAMES.PROPSIGN = "Prop Sign"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.PROPSIGN = "I shall use this in the name of violence!"
    STRINGS.NAMES.PROPSIGN_ALT = "Prop Sign" -- recipe name
    STRINGS.RECIPE_DESC.PROPSIGN_ALT = "Craft in the name of violence!"
    STRINGS.NAMES.PROPSIGNBUNCH_ALT = "Bunch of Prop Signs"
    STRINGS.RECIPE_DESC.PROPSIGNBUNCH_ALT = "Even more crafting in the name the violence!"
end