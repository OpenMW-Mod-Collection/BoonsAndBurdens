---@omw-context player
---@diagnostic disable: assign-type-mismatch
---@diagnostic disable: undefined-field
local I = require("openmw.interfaces")
local self = require("openmw.self")
local core = require("openmw.core")

I.CharacterTraits.addTrait {
    id = "BaB_bulwark",
    type = "background",
    name = "Bulwark",
    description = (
        "Somewhere along the way you stopped thinking of yourself as " ..
        "someone who fights and started thinking of yourself as someone who stands. " ..
        "You never had much taste for the killing blow - " ..
        "your hands were always better suited to the shield, " ..
        "the ward, the steadying hand on a wounded shoulder. " ..
        "Those who travel with you have noticed it too: a blow meant for them seems, " ..
        "more often than not, to find you instead.\n" ..
        "\n" ..
        "+15 Block, Conjuration, Restoration and Endurance\n" ..
        "+20 Max Health\n" ..
        "-10 to all offensive skills\n" ..
        "> Offensive skills gain only half as much experience\n" ..
        "> Your followers redirect part of the physical damage to you and take less damage in general " ..
        "(50% hits the follower, 25% hits you, 25% is negated)"
    ),
    doOnce = function()
        local block = self.type.stats.skills.block(self)
        block.base = block.base + 15
        local conjuration = self.type.stats.skills.conjuration(self)
        conjuration.base = conjuration.base + 15
        local restoration = self.type.stats.skills.restoration(self)
        restoration.base = restoration.base + 15
        local endurance = self.type.stats.attributes.endurance(self)
        endurance.base = endurance.base + 15

        local health = self.type.stats.dynamic.health(self)
        health.base = health.base + 20
        health.current = health.current + 20

        local offensiveSkills = {
            self.type.stats.skills.axe(self),
            self.type.stats.skills.bluntweapon(self),
            self.type.stats.skills.destruction(self),
            self.type.stats.skills.handtohand(self),
            self.type.stats.skills.longblade(self),
            self.type.stats.skills.marksman(self),
            self.type.stats.skills.shortblade(self),
            self.type.stats.skills.spear(self),
        }
        for _, skill in ipairs(offensiveSkills) do
            skill.base = skill.base - 10
        end
    end,
    onLoad = function()
        local offensiveSkills = {
            axe = true,
            bluntweapon = true,
            destruction = true,
            handtohand = true,
            longblade = true,
            marksman = true,
            shortblade = true,
            spear = true,
        }

        I.SkillProgression.addSkillUsedHandler(function(skillId, params)
            if not offensiveSkills[skillId] then return end
            params.skillGain = params.skillGain * 0.5
        end)

        core.sendGlobalEvent("BoonsAndBurdens_registerBulwark", self)
    end
}
