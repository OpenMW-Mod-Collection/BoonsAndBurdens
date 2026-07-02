---@diagnostic disable: assign-type-mismatch, undefined-field
---@omw-context player
local I = require("openmw.interfaces")
local self = require("openmw.self")
local time = require("openmw_aux.time")
local storage = require("openmw.storage")

local bgSection = storage.playerSection("BaB_hedgeMage")

local threshold = 100
local maxBounty = 1000
local initted = true

local function getBountyLevel()
    return math.floor(
        math.min(self.type.getCrimeLevel(self), maxBounty) / threshold
    )
end

local function applyBaseStats()
    local selfSkills = self.type.stats.skills
    local selfAttrs = self.type.stats.attributes

    selfSkills.destruction(self).modifier = selfSkills.destruction(self).modifier + 10
    selfSkills.illusion(self).modifier = selfSkills.illusion(self).modifier + 10
    selfAttrs.intelligence(self).modifier = selfAttrs.intelligence(self).modifier + 10

    selfSkills.shortblade(self).modifier = selfSkills.shortblade(self).modifier - 15
    selfSkills.sneak(self).modifier = selfSkills.sneak(self).modifier - 15
end

local function migrateToV2()
    local selfSkills = self.type.stats.skills
    local selfAttrs = self.type.stats.attributes
    local selfSpells = self.type.spells(self)
    local bountyLevel = getBountyLevel()
    local oldPositive = {
        selfSkills.illusion(self),
        selfSkills.conjuration(self),
        selfSkills.shortblade(self),
        selfSkills.sneak(self),
    }
    local oldNegative = {
        selfAttrs.agility(self),
        selfAttrs.willpower(self),
    }

    for _, stat in ipairs(oldPositive) do
        stat.modifier = stat.modifier - 1 * bountyLevel
    end
    for _, stat in ipairs(oldNegative) do
        stat.damage = stat.damage - 2 * bountyLevel
    end
    for level = 1, 10 do
        selfSpells:remove(("bab_hedgemage_%d"):format(level))
    end

    -- existing characters never got the new flat base stats applied via doOnce
    applyBaseStats()
end

local function migrate()
    if not bgSection:get("migratedToV2") then
        migrateToV2()
        bgSection:set("migratedToV2", true)
    end
end

I.CharacterTraits.addTrait {
    id = "BaB_hedgeMage",
    type = "background",
    name = "Hedge Mage",
    description = (
        "You were born with the magical talents " ..
        "fit of a high court wizard, but talent meant little in the slums. " ..
        "You once dreamed that your gift would one day lift you from poverty. " ..
        "Instead it drew you to a criminal life, where every spell became another tool to survive.\n" ..
        "\n" ..
        "A life of wanted posters with your face weakens your magical gift, " ..
        "but hones the skills needed to disappear into the shadows.\n" ..
        "\n" ..
        "+10 Destruction, Illusion and Intelligence\n" ..
        "-15 Short Blade and Sneak\n" ..
        "\n" ..
        "> For every 100 bounty you posess up to a 1000 you get:\n" ..
        "-2 Destruction, Illusion and Intelligence\n" ..
        "+3 Short Blade and Sneak"
    ),
    doOnce = function()
        initted = false
        applyBaseStats()
    end,
    onLoad = function()
        -- in case you're using an older character
        migrate()

        local selfSkills = self.type.stats.skills
        local selfAttrs = self.type.stats.attributes

        local statModifiers = {
            { stat = selfSkills.shortblade(self),  multiplier = 3 },
            { stat = selfSkills.sneak(self),       multiplier = 3 },
            { stat = selfSkills.destruction(self), multiplier = -2 },
            { stat = selfSkills.illusion(self),    multiplier = -2 },
            { stat = selfAttrs.intelligence(self), multiplier = -2 },
        }

        local targetDamage = {}
        for _, entry in ipairs(statModifiers) do
            if entry.multiplier < 0 then
                targetDamage[entry.stat] = 0
            end
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
                lastBountyLevel = currBountyLevel
            end
        end, 1)

        -- thechnically doesn't matter, but just in case
        initted = true
    end
}
