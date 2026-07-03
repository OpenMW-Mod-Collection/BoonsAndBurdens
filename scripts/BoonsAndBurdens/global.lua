---@omw-context global
local M = require("scripts.BoonsAndBurdens.utils.scriptMerger")

local folderPath = "scripts/BoonsAndBurdens/backgrounds_global_merged/"

return M.mergeAllHandlers(folderPath)
