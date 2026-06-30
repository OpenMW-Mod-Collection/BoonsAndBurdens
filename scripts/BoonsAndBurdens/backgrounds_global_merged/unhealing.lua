---@omw-context global
local world = require("openmw.world")
local types = require("openmw.types")

local customScript = "scripts/BoonsAndBurdens/backgrounds_custom/unhealing.lua"
local registeredPlayers = {}
local anyoneRegistered = false

local function isSummon(id)
    return string.find(id, "_summon$")
        or id == "bonewalker_greater_summ"
end

local function register(player)
    anyoneRegistered = true
    registeredPlayers[player.id] = player
    for _, actor in ipairs(world.activeActors) do
        if not types.Actor.isDead(actor) and not isSummon(actor.recordId) then
            if not actor:hasScript(customScript) then
                actor:addScript(customScript, registeredPlayers)
            else
                actor:sendEvent("BoonsAndBurdens_updateUnhealingPlayers", registeredPlayers)
            end
        end
    end
end

local function onActorActive(actor)
    if not anyoneRegistered
        or types.Actor.isDead(actor)
        or isSummon(actor.recordId)
    then
        return
    end

    if not actor:hasScript(customScript) then
        actor:addScript(customScript, registeredPlayers)
    end
end

return {
    engineHandlers = {
        onActorActive = onActorActive,
    },
    eventHandlers = {
        BoonsAndBurdens_registerUnhealing = register,
    }
}
