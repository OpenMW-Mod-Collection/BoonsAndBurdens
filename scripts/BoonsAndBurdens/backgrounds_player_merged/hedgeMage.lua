---@omw-context player
---@diagnostic disable: assign-type-mismatch
---@diagnostic disable: undefined-field
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
        "You were born with the magical talents fit of a high court wizard, " ..
        "but unfortunately you were born far away from any court. " ..
        "You had to learn how to survive by whatever means were available. " ..
        "Stealth and sorcery became tools no different from a dagger or a lockpick." ..
        "\n" ..
        "The more the law hunts you, the more you rely on the skills that kept you alive. " ..
        "But years spent looking over your shoulder takes its toll, " ..
        "feeding a paranoia that slowly erodes both your confidence and composture.\n" ..
        "\n" ..
        "> For every 100 bounty (up to 1000) you get:\n" ..
        "+0.1x Fortify Magicka\n" ..
        "+1 Illusion, Conjuration, Short Blade and Sneak\n" ..
        "-2 Willpower and Agility"
    ),
    doOnce = function()
        initted = false
    end,
    onLoad = function()
        local threshold = 100
        local maxBounty = 1000
        local selfSkills = self.type.stats.skills
        local selfAttrs = self.type.stats.attributes
        local selfSpells = self.type.spells(self)
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
        if not initted and lastBountyLevel ~= 0 then
            applyBountyModifiers(lastBountyLevel)
        end

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
                applyBountyModifiers(-lastBountyLevel)
                applyBountyModifiers(currBountyLevel)

                if lastBountyLevel ~= 0 then
                    selfSpells:remove(("bab_hedgemage_%d"):format(lastBountyLevel))
                end
                if currBountyLevel ~= 0 then
                    selfSpells:add(("bab_hedgemage_%d"):format(currBountyLevel))
                end

                lastBountyLevel = currBountyLevel
            end
        end, 1)

        -- thechnically doesn't matter, but just in case
        initted = true
    end
}
