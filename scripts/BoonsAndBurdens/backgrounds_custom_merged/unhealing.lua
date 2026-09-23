---@omw-context local
local I = require("openmw.interfaces")

local registeredPlayers = {}
local hitBy = {}

I.Combat.addOnHitHandler(function (attack)
    if not attack.successful
        or not registeredPlayers[attack.attacker.id]
    then
        return
    end

    hitBy[attack.attacker.id] = attack.attacker
end)

return {
    engineHandlers = {
        onInit = function (players)
            registeredPlayers = players
        end,
    },
    eventHandlers = {
        Died = function()
            for _, player in pairs(hitBy) do
                player:sendEvent("BoonsAndBurdens_unhealingRegen")
            end
        end,
        BoonsAndBurdens_updateUnhealingPlayers = function (players)
            registeredPlayers = players
        end
    }
}