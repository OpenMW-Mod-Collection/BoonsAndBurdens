---@omw-context local
local I = require("openmw.interfaces")
local self = require("openmw.self")
local core = require("openmw.core")

local script
local leader
local halt = false

I.Combat.addOnHitHandler(function(attack)
    if halt
        or not attack.successful
        or attack.damage.health == 0
        or attack.ngarde_perfectParry
    then
        return
    end

    local initDamage = attack.damage.health
    attack.damage.health = initDamage * 0.25
    leader:sendEvent("Hit", attack)

    attack.damage.health = initDamage * 0.5
end)

local function stopScript()
    halt = true
    core.sendGlobalEvent("BoonsAndBurdens_detachScript", {
        obj = self,
        script = script
    })
end

local function followerListUpdated(data)
    if not data.followers[self.id]
        or not data.followers[self.id].leader
        or data.followers[self.id].leader.id ~= leader.id
    then
        stopScript()
    end
end

local function onInit(data)
    script = data.script
    leader = data.leader
end

local function onSave()
    return {
        script = script,
        leader = leader
    }
end

local function onLoad(data)
    if not data then return end
    script = data.script or script
    leader = data.leader or leader
end

return {
    engineHandlers = {
        onInit = onInit,
        onSave = onSave,
        onLoad = onLoad,
    },
    eventHandlers = {
        Died = stopScript,
        FDU_UpdateFollowerList = followerListUpdated,
    }
}
