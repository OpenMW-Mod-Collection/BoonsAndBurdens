---@omw-context local
local self = require("openmw.self")

local registeredPlayers = {}

return {
    engineHandlers = {
        onInit = function(players)
            registeredPlayers = players
        end
    },
    eventHandlers = {
        BoonsAndBurdens_updatePlayers = function(players)
            registeredPlayers = players
        end,
        Died = function()
            for _, player in pairs(registeredPlayers) do
                player:sendEvent("BoonsAndBurdens_uniqueDaedraSlain", self)
            end
        end
    }
}