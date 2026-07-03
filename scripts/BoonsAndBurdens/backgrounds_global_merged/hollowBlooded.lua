---@omw-context global
local world = require("openmw.world")

local yamlLoader = require("scripts.BoonsAndBurdens.utils.yamlFolderLoader")

local customScript = "scripts/BoonsAndBurdens/backgrounds_custom/hollowBlooded.lua"
local yamlPath = "scripts/BoonsAndBurdens/data/uniqueDaedra/"
local uniqueDaedra = yamlLoader.loadLookup(yamlPath, {
    logPrefix = "[Hollow-Blooded]",
    silent = false,
    transform = function (data, filePath)
        for i = 1, #data do
            data[i] = data[i]:lower()
        end
        return data
    end
})
local registeredPlayers = {}
local anyoneRegistered = false

local function registerPlayer(player)
    registeredPlayers[player.id] = player
    anyoneRegistered = true
    for _, actor in ipairs(world.activeActors) do
        if uniqueDaedra[actor.recordId]
            and not actor.type.isDead(actor)
        then
            if not actor:hasScript(customScript) then
                actor:addScript(customScript, registeredPlayers)
            else
                actor:sendEvent("BoonsAndBurdens_updatePlayers", registeredPlayers)
            end
        end
    end
end

local function onActorActive(actor)
    if not anyoneRegistered then return end
    if uniqueDaedra[actor.recordId]
        and not actor:hasScript(customScript)
        and not actor.type.isDead(actor)
    then
        actor:addScript(customScript, registeredPlayers)
    end
end

return {
    engineHandlers = {
        onActorActive = onActorActive,
    },
    eventHandlers = {
        BoonsAndBurdens_registerHollowBlooded = registerPlayer,
    }
}
