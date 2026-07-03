---@diagnostic disable: assign-type-mismatch, undefined-field, missing-parameter
---@omw-context player
local I = require("openmw.interfaces")
local self = require("openmw.self")
local core = require("openmw.core")
local storage = require("openmw.storage")
local ambient = require("openmw.ambient")
local types   = require("openmw.types")

local messages = require("scripts.BoonsAndBurdens.utils.messages")

local l10n = core.l10n("BoonsAndBurdens")
local settings = storage.globalSection("SettingsBoonsAndBurdens_hollowBlooded")

I.CharacterTraits.addTrait {
    id = "BaB_hollowBlooded",
    type = "background",
    name = "Hollow-Blooded",
    description = (
        "You were born weak. Not sickly, not cursed - simply lacking the vigor that comes naturally to most." ..
        " Muscle sits on your frame but answers sluggishly; your body tires long before your will does. " ..
        "For years you had no name for it, only the frustration of falling short no matter how you trained.\n" ..
        "\n" ..
        "It was a sage, met by chance or fate, who first looked at you and knew. " ..
        "They spoke of an old affliction, rare enough that most healers mistake it for simple frailty - " ..
        "and rarer still, a way to counter it. Not all Daedra, they said, but the exceptional among them: " ..
        "beings whose power sets them apart from the common rabble of Oblivion. " ..
        "Something in their nature, spent at the moment of death, could answer what your own body lacks. " ..
        "Whether the sage spoke truth or superstition, you no longer have the luxury of doubt.\n" ..
        "\n" ..
        "-15 Strength and Endurance\n" ..
        "> Killing a unique named Daedra grants you +" .. tostring(settings:get("statBonus")) .. " Strength and Endurance"
    ),
    doOnce = function()
        local strength = self.type.stats.attributes.strength(self)
        strength.base = strength.base - 15
        local endurance = self.type.stats.attributes.endurance(self)
        endurance.base = endurance.base - 15
    end,
    onLoad = function()
        core.sendGlobalEvent("BoonsAndBurdens_registerHollowBlooded", self)
    end
}

return {
    eventHandlers = {
        BoonsAndBurdens_uniqueDaedraSlain = function(daedra)
            local strength = self.type.stats.attributes.strength(self)
            strength.base = strength.base + settings:get("statBonus")
            local endurance = self.type.stats.attributes.endurance(self)
            endurance.base = endurance.base + settings:get("statBonus")

            -- regen HP for vibes
            local health = self.type.stats.dynamic.health(self)
            health.current = math.max(health.current, health.base)

            ambient.playSound("restoration hit")
            local resotreHealth = core.magic.effects.records["restorehealth"]
            self:sendEvent("AddVfx", {
                model = types.Static.records[resotreHealth.hitStatic].model
            })
            local daedraName = daedra.type.records[daedra.recordId].name
            messages.show(l10n, self, "msg_uniqueDaedraDead", { daedraName = daedraName })
        end,
    }
}
