---@diagnostic disable: undefined-field
---@omw-context player
local I = require("openmw.interfaces")

local M = require("scripts.BoonsAndBurdens.utils.scriptMerger")
local deps = require("scripts.BoonsAndBurdens.utils.dependencyChecker")

deps.checkAll("Boons and Burdens", "Boons and Burdens", nil, {
    {
        plugin = "CharacterTraitsFramework.omwscripts",
        interface = I.CharacterTraits,
    },
    {
        plugin = "FollowerDetectionUtil.omwscripts",
        interface = I.FollowerDetectionUtil,
        minVersion = 6,
        curVersion = I.FollowerDetectionUtil.version,
    }
})

local folderPath = "scripts/BoonsAndBurdens/backgrounds_player_merged/"

return M.mergeAllHandlers(folderPath)
