-- entry point for all lua code of the pack
-- more info on the lua API: https://github.com/black-sliver/PopTracker/blob/master/doc/PACKS.md#lua-interface
ENABLE_DEBUG_LOG = true
-- get current variant
local variant = Tracker.ActiveVariantUID
-- check variant info
IS_ITEMS_ONLY = variant:find("itemsonly")

print("-- SMZ3 Archipelago --")
print("Loaded variant: ", variant)
if ENABLE_DEBUG_LOG then
    print("Debug logging is enabled!")
end

-- Utility Script for helper functions etc.
ScriptHost:LoadScript("scripts/utils.lua")

-- Logic
ScriptHost:LoadScript("scripts/logic/logic.lua")

-- Custom Items
ScriptHost:LoadScript("scripts/custom_items/class.lua")
ScriptHost:LoadScript("scripts/custom_items/progressiveTogglePlus.lua")
ScriptHost:LoadScript("scripts/custom_items/progressiveTogglePlusWrapper.lua")

-- Items
Tracker:AddItems("items/sm/boss_tokens.jsonc")
Tracker:AddItems("items/sm/equipment.jsonc")
Tracker:AddItems("items/sm/keys.jsonc")
Tracker:AddItems("items/z3/dungeon_info.jsonc")
Tracker:AddItems("items/z3/equipment.jsonc")
Tracker:AddItems("items/z3/keys.jsonc")
Tracker:AddItems("items/settings.jsonc")
Tracker:AddItems("items/labels.jsonc")

-- Locations (load SM cards first for portal logic)
if not IS_ITEMS_ONLY then -- <--- use variant info to optimize loading
    -- Maps
    Tracker:AddMaps("maps/maps.jsonc")
    -- Locations
    Tracker:AddLocations("locations/sm/cards.jsonc")
    Tracker:AddLocations("locations/logic.jsonc")
    Tracker:AddLocations("locations/z3/lightworld.jsonc")
    Tracker:AddLocations("locations/z3/darkworld.jsonc")
    Tracker:AddLocations("locations/z3/bothworlds.jsonc")
    Tracker:AddLocations("locations/z3/hyrulecastle.jsonc")
    Tracker:AddLocations("locations/z3/castletower.jsonc")
    Tracker:AddLocations("locations/z3/easternpalace.jsonc")
    Tracker:AddLocations("locations/z3/desertpalace.jsonc")
    Tracker:AddLocations("locations/z3/towerofhera.jsonc")
    Tracker:AddLocations("locations/z3/palaceofdarkness.jsonc")
    Tracker:AddLocations("locations/z3/swamppalace.jsonc")
    Tracker:AddLocations("locations/z3/skullwoods.jsonc")
    Tracker:AddLocations("locations/z3/thievestown.jsonc")
    Tracker:AddLocations("locations/z3/icepalace.jsonc")
    Tracker:AddLocations("locations/z3/miserymire.jsonc")
    Tracker:AddLocations("locations/z3/turtlerock.jsonc")
    Tracker:AddLocations("locations/z3/ganonstower.jsonc")
    Tracker:AddLocations("locations/sm/doors.jsonc")
    Tracker:AddLocations("locations/sm/wreckedship.jsonc")
    Tracker:AddLocations("locations/sm/crateria.jsonc")
    Tracker:AddLocations("locations/sm/brinstar.jsonc")
    Tracker:AddLocations("locations/sm/norfairupper.jsonc")
    Tracker:AddLocations("locations/sm/norfairlower.jsonc")
    Tracker:AddLocations("locations/sm/maridia.jsonc")
end

-- Layout
Tracker:AddLayouts("layouts/alttp_item_grid.jsonc")
Tracker:AddLayouts("layouts/boss_tokens_grid.jsonc")
Tracker:AddLayouts("layouts/sm_item_grid.jsonc")
Tracker:AddLayouts("layouts/maps.jsonc")
Tracker:AddLayouts("layouts/tracker.jsonc")
Tracker:AddLayouts("layouts/broadcast.jsonc")
Tracker:AddLayouts("layouts/settings.jsonc")
Tracker:AddLayouts("layouts/bottom_bar.jsonc")

-- AutoTracking for Poptracker
if PopVersion and PopVersion >= "0.18.0" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
end
