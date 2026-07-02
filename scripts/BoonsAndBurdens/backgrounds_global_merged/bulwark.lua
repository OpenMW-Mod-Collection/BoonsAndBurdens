---@diagnostic disable: undefined-field
---@omw-context global
local I = require("openmw.interfaces")

local customScript = "scripts/BoonsAndBurdens/backgrounds_custom/bulwark.lua"
local registeredPlayers = {}

local function registerPlayer(player)
    registeredPlayers[player.id] = player
    for _, fState in pairs(I.FollowerDetectionUtil.getFollowerList()) do
        local has = fState.actor:hasScript(customScript)
        local want = fState.leader.id == player.id
        if want and not has then
            fState.actor:addScript(customScript, {
                leader = player,
                script = customScript
            })
        end
    end
end

local function updateFollowers(data)
    if not next(registeredPlayers) then
        return
    end

    for _, fState in pairs(data.followers) do
        local has = fState.actor:hasScript(customScript)

        local follows = false
        if fState.leader then
            for _, player in pairs(registeredPlayers) do
                if fState.leader.id == player.id then
                    follows = true
                    break
                end
            end
        end

        if not has and follows then
            fState.actor:addScript(customScript, {
                leader = fState.leader,
                script = customScript
            })
        end
    end
end

return {
    eventHandlers = {
        BoonsAndBurdens_registerBulwark = registerPlayer,
        FDU_FollowerListUpdated = updateFollowers,
    }
}
