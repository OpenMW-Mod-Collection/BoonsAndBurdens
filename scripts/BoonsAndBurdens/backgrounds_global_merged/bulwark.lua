---@omw-context global

local registeredPlayers = {}

local function register(player)
    registeredPlayers[player.id] = player
end

return {
    eventHandlers = {
        BoonsAndBurdens_registerBulwark = register,
    }
}