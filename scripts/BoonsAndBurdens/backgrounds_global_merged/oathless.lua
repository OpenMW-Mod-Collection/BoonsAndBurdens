---@omw-context global
---@diagnostic disable: assign-type-mismatch
---@diagnostic disable: undefined-field
local I = require("openmw.interfaces")

local registeredPlayers = {}
local healthTable = {}

local healthReductionScript = "scripts/BoonsAndBurdens/backgrounds_custom/oathless.lua"

local function followerListUpdated(data)
    if not next(registeredPlayers) then return end
    for _, fState in pairs(data.followers) do
        if fState.followsPlayer
            and fState.leader
            and registeredPlayers[fState.leader.id]
        then
            if I.FollowerDetectionUtil.isSummon(fState.actor.recordId)then
                local health = fState.actor.type.stats.dynamic.health(fState.actor)
                if not healthTable[fState.actor.recordId] or healthTable[fState.actor.recordId] >= health.base then
                    healthTable[fState.actor.recordId] = health.base
                    fState.actor:addScript(healthReductionScript)
                end
            end
        end
    end
end

local function onLoad(data)
    if not data then return end
    healthTable = data.healthTable or healthTable
end

local function onSave()
    return {
        healthTable = healthTable
    }
end

return {
    engineHandlers = {
        onLoad = onLoad,
        onSave = onSave,
    },
    eventHandlers = {
        BoonsAndBurdens_registerHedgeConjurer = function(player)
            registeredPlayers[player.id] = player
        end,
        FDU_FollowerListUpdated = followerListUpdated,
    }
}
