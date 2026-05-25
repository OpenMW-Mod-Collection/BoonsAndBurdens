local I = require("openmw.interfaces")
local self = require("openmw.self")
local time = require("openmw_aux.time")
local core = require("openmw.core")

local initted = true

I.CharacterTraits.addTrait {
    id = "BaB_hedgeMage",
    type = "background",
    name = "Hedge Mage",
    description = (
        "You were born with the magical talents fit of a high court wizard. " ..
        "Unfortunately for you, you were born far from any court and deprived of a life of privilege. " ..
        "In the streets, you learned to use your magic to survive, " ..
        "first through petty theft, then far darker crimes. " ..
        "As your power grew, so did your ambition, and the line between survival and greed slowly disappeared.\n" ..
        "\n" ..
        "When the law is hunting you, old instincts awaken, and the streets once again become your greatest ally. " ..
        "But a life spent hunted like an animal leaves scars on the mind. " ..
        "Constant paranoia and the need to always watch your back slowly wear away your resolve.\n" ..
        "\n" ..
        "> For every 100 bounty you posess up to a 1000 you get:\n" ..
        "+0.1x Fortify Magicka\n" ..
        "+1 Illusion\n" ..
        "+1 Conjuration\n" ..
        "+1 Short Blade\n" ..
        "+1 Sneak\n" ..
        "-2 Agility\n" ..
        "-2 Willpower"
    ),
    doOnce = function()
        initted = false
    end,
    onLoad = function()
        local threshold = 100
        local maxBounty = 1000
        local selfSkills = self.type.stats.skills
        local selfAttrs = self.type.stats.attributes
        local selfEffects = self.type.activeEffects(self)
        local FORTIFY_MAGICKA = core.magic.EFFECT_TYPE.FortifyMagicka
        local statModifiers = {
            { stat = selfSkills.illusion(self),    multiplier = 1 },
            { stat = selfSkills.conjuration(self), multiplier = 1 },
            { stat = selfSkills.shortblade(self),  multiplier = 1 },
            { stat = selfSkills.sneak(self),       multiplier = 1 },
            { stat = selfAttrs.agility(self),      multiplier = -2 },
            { stat = selfAttrs.willpower(self),    multiplier = -2 },
        }
        local fortMagickaMult = 1

        local targetDamage = {}
        for _, entry in ipairs(statModifiers) do
            if entry.multiplier < 0 then
                targetDamage[entry.stat] = 0
            end
        end

        local function getBountyLevel()
            return math.floor(
                math.min(self.type.getCrimeLevel(self), maxBounty) / threshold
            )
        end

        local function applyBountyModifiers(direction)
            for _, entry in ipairs(statModifiers) do
                if entry.multiplier > 0 then
                    entry.stat.modifier = entry.stat.modifier + entry.multiplier * direction
                else
                    local delta = (-entry.multiplier) * direction
                    local newTarget = math.max(0, targetDamage[entry.stat] + delta)
                    local actual = newTarget - targetDamage[entry.stat]
                    targetDamage[entry.stat] = newTarget
                    entry.stat.damage = entry.stat.damage + actual
                end
            end
        end

        local lastBountyLevel = initted and getBountyLevel() or 0
        local currBountyLevel = 0

        time.runRepeatedly(function()
            for _, entry in ipairs(statModifiers) do
                if entry.multiplier < 0 then
                    local stat = entry.stat
                    if stat.damage < targetDamage[stat] then
                        stat.damage = targetDamage[stat]
                    end
                end
            end

            currBountyLevel = getBountyLevel()
            if lastBountyLevel ~= currBountyLevel then
                applyBountyModifiers(-1)
                ---@diagnostic disable-next-line: missing-parameter
                selfEffects:modify(
                    (currBountyLevel - lastBountyLevel) * fortMagickaMult,
                    FORTIFY_MAGICKA
                )
                lastBountyLevel = currBountyLevel
                applyBountyModifiers(1)
            end
        end, 1)
    end
}
