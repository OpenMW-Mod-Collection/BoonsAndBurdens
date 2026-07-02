---@omw-context player
---@diagnostic disable: assign-type-mismatch
---@diagnostic disable: undefined-field
local I = require("openmw.interfaces")
local self = require("openmw.self")
local core = require("openmw.core")

local bgPicked = true

I.CharacterTraits.addTrait {
    id = "BaB_deserter",
    type = "background",
    name = "Deserter",
    description = (
        "You wore the uniform once. The Legion trained you, hardened you, " ..
        "made you into exactly the soldier they needed - discipline in your spine, " ..
        "strength in your frame, the bearing of someone built for war. " ..
        "And then, for reasons only you carry the weight of, you ran. But desertion isn't easily forgiven. " ..
        "Worse still, the Empire hasn't forgotten your face.\n" ..
        "\n" ..
        "+10 to all skills and attributes favored by the Legion\n" ..
        "+10 Sneak\n" ..
        "-20 disposition with Imperial Cult and Fighters Guild members\n" ..
        "+900 bounty\n" ..
        "> Walking close to the Legion members blows your cover, granting instant arrest warrant with additional 900 bounty"
    ),
    doOnce = function()
        local legion = core.factions.records["imperial legion"]
        for _, attr in ipairs(legion.attributes) do
            local selfAttr = self.type.stats.attributes[attr](self)
            selfAttr.base = selfAttr.base + 10
        end
        for _, skill in ipairs(legion.skills) do
            local selfSkill = self.type.stats.skills[skill](self)
            selfSkill.base = selfSkill.base + 10
        end

        local sneak = self.type.stats.skills.sneak(self)
        sneak.base = sneak.base + 10

        core.sendGlobalEvent("BoonsAndBurdens_modBounty", {
            player = self,
            amount = 900
        })

        self.type.joinFaction(self, "imperial legion")
        self.type.expel(self, "imperial legion")
    end,
    onLoad = function()
        bgPicked = true
        core.sendGlobalEvent("BoonsAndBurdens_registerDeserter", self)
    end
}

local function dialogueResponse(res)
    if not bgPicked or res.actor.type.getFactionRank(res.actor, "imperial legion") == 0 then
        return
    end

    res.actor:sendEvent("Hit", {
        attacker = self,
        successful = false,
    })
    core.sendGlobalEvent("BoonsAndBurdens_modBounty", {
        player = self,
        amount = 900
    })
end

return {
    eventHandlers = {
        DialogueResponse = dialogueResponse,
    }
}
