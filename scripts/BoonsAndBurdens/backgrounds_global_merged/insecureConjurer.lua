---@omw-context global
---@diagnostic disable: assign-type-mismatch
---@diagnostic disable: undefined-field
local storage = require("openmw.storage")
local time = require("openmw_aux.time")
local async = require("openmw.async")
local core = require("openmw.core")
local I = require("openmw.interfaces")

local messages = require("scripts.BoonsAndBurdens.utils.messages")

local l10n = core.l10n("BoonsAndBurdens")
local settings = storage.globalSection("SettingsBoonsAndBurdens_insecureConjurer")
local registeredPlayers = {}
local ignoredSummons = {}

local delayedAttack = async:registerTimerCallback(
    "delayedAttack",
    function(data)
        messages.show(l10n, data.leader, "msg_summonTurned",
            { summon_name = data.actor.type.records[data.actor.recordId].name }
        )
        data.actor:sendEvent(
            "StartAIPackage",
            { type = 'Combat', target = data.leader }
        )
    end
)

local function followerListUpdated(data)
    if not next(registeredPlayers) then return end
    for _, fState in pairs(data.followers) do
        if fState.followsPlayer
            and fState.leader
            and registeredPlayers[fState.leader.id]
            and not ignoredSummons[fState.actor.id]
        then
            if I.FollowerDetectionUtil.isSummon(fState.actor.recordId) then
                if math.random(100) < settings:get("disobeyChance") then
                    fState.actor:sendEvent("RemoveAIPackages", "Follow")
                    time.newSimulationTimer(1, delayedAttack,
                        { actor = fState.actor, leader = fState.leader }
                    )
                else
                    ignoredSummons[fState.actor.id] = true
                end
            end
        end
    end
end

return {
    eventHandlers = {
        BoonsAndBurdens_registerInsecureConjurer = function(player)
            registeredPlayers[player.id] = player
        end,
        FDU_FollowerListUpdated = followerListUpdated,
    }
}
