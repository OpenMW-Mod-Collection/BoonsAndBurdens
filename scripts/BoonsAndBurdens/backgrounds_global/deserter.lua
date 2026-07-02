---@omw-context global
local world = require("openmw.world")
local types = require("openmw.types")

local registeredPlayers = {}
local anyoneRegistered = false
local modifiedNPCs = {} -- modifiedNPCs[player.id] = { [npc.id] = true, ... }

local function modifyNPC(npc, player)
    if not types.NPC.objectIsInstance(npc) then
        return
    end

    if modifiedNPCs[player.id][npc.id] then
        return
    end

    if npc.type.getFactionRank(npc, "imperial cult") ~= 0 then
        npc.type.modifyBaseDisposition(npc, player, -20)
    elseif npc.type.getFactionRank(npc, "fighters guild") ~= 0 then
        npc.type.modifyBaseDisposition(npc, player, -20)
    end

    modifiedNPCs[player.id][npc.id] = true
end

local function registerPlayer(player)
    registeredPlayers[player.id] = player
    modifiedNPCs[player.id] = {}
    anyoneRegistered = true
    for _, actor in ipairs(world.activeActors) do
        modifyNPC(actor, player)
    end
end

local function onActorActive(actor)
    if not anyoneRegistered then return end
    for _, player in pairs(registeredPlayers) do
        modifyNPC(actor, player)
    end
end

local function onSave()
    return {
        modifiedNPCs = modifiedNPCs
    }
end

local function onLoad(data)
    if not data then return end
    modifiedNPCs = data.modifiedNPCs or modifiedNPCs
end

return {
    engineHandlers = {
        onSave = onSave,
        onLoad = onLoad,
        onActorActive = onActorActive,
    },
    eventHandlers = {
        BoonsAndBurdens_registerDeserter = registerPlayer,
    }
}
