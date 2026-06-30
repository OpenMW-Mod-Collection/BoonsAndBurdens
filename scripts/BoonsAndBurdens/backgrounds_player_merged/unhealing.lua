---@diagnostic disable: need-check-nil, undefined-field
---@omw-context player
local I = require("openmw.interfaces")
local self = require("openmw.self")
local types = require("openmw.types")
local core = require("openmw.core")

local healthRegen = 15
local fatigueRegen = 15
local selfHealth = types.Actor.stats.dynamic.health(self)
local selfFatigue = types.Actor.stats.dynamic.fatigue(self)

I.CharacterTraits.addTrait {
    id = "BaB_unhealing",
    type = "background",
    name = "Unhealing",
    description = (
        "There is no polite way to say it: your body no longer recovers the way a body should. " ..
        "Injuries that should seal themselves simply don't, and the spells that work on everyone else " ..
        "slide off you like water off stone. Whatever happenned - " ..
        "and you are not certain you remember it clearly anymore - it changed the rules.\n" ..
        "\n" ..
        "What works is violence. The moment a fight ends in your favour, your wounds close.\n" ..
        "\n" ..
        "+10 to all weapon skills\n" ..
        "-20 Restoration\n" ..
        "> You cannot receive Restore Health effects from any sources\n" ..
        ("> You restore %d%% of max health and %d%% of max fatigue by killing enemies with physical weapons"):format(
            healthRegen, fatigueRegen
        )
    ),
    doOnce = function()
        local skills = types.NPC.stats.skills
        local weaponSkills = {
            skills.axe(self),
            skills.bluntweapon(self),
            skills.longblade(self),
            skills.marksman(self),
            skills.shortblade(self),
            skills.spear(self)
        }
        for _, skill in ipairs(weaponSkills) do
            skill.base = skill.base + 10
        end

        local restoration = skills.restoration(self)
        restoration.base = restoration.base - 20
    end,
    onLoad = function()
        core.sendGlobalEvent("BoonsAndBurdens_registerUnhealing", self)
    end
}

return {
    eventHandlers = {
        BoonsAndBurdens_unhealingRegen = function()
            selfHealth.current = math.min(
                selfHealth.base,
                selfHealth.current + selfHealth.base / 100 * healthRegen
            )
            selfFatigue.current = math.min(
                selfFatigue.base,
                selfFatigue.current + selfFatigue.base / 100 * fatigueRegen
            )
        end,
    },
}
