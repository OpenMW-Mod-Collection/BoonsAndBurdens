---@diagnostic disable: need-check-nil, undefined-field
---@omw-context player
local I = require("openmw.interfaces")
local self = require("openmw.self")
local async = require("openmw.async")
local core = require("openmw.core")
local storage = require("openmw.storage")
local types = require("openmw.types")

local settingsCache = require("scripts.BoonsAndBurdens.utils.settingsCache")

local l10n = core.l10n("BoonsAndBurdens")
local settings = settingsCache.new(
    storage.globalSection("SettingsBoonsAndBurdens_methodPlayer"),
    async
)

local function shuffle(list)
    for i = #list, 2, -1 do
        local j = math.random(i)
        list[i], list[j] = list[j], list[i]
    end
end

local function chooseSkills(skills, count)
    local choices = {}
    for _, skill in ipairs(skills) do
        choices[#choices + 1] = skill
    end
    shuffle(choices)

    local selected = {}
    for i = 1, count do
        selected[i] = choices[i]
    end
    return selected
end

local function getRoleModifiers()
    local classId = types.NPC.record(self).class
    local class = types.NPC.classes.record(classId)
    local majorSkills = class.majorSkills
    local minorSkills = class.minorSkills
    local classSkills = {}
    for _, skill in ipairs(majorSkills) do
        classSkills[skill] = true
    end
    for _, skill in ipairs(minorSkills) do
        classSkills[skill] = true
    end

    local miscSkills = {}
    for skill in pairs(self.type.stats.skills) do
        if not classSkills[skill] then
            miscSkills[#miscSkills + 1] = skill
        end
    end

    local selectedMajor = chooseSkills(majorSkills, 2)
    local selectedMinor = chooseSkills(minorSkills, 4)
    local selectedMisc = chooseSkills(miscSkills, 3)

    return {
        { skill = selectedMajor[1], amount = 20 },
        { skill = selectedMajor[2], amount = -20 },
        { skill = selectedMinor[1], amount = 20 },
        { skill = selectedMinor[2], amount = 20 },
        { skill = selectedMinor[3], amount = -20 },
        { skill = selectedMinor[4], amount = -20 },
        { skill = selectedMisc[1],  amount = 30 },
        { skill = selectedMisc[2],  amount = 30 },
        { skill = selectedMisc[3],  amount = 30 },
    }, selectedMajor[1]
end

local function applyRoleModifiers(modifiers, direction)
    for _, entry in ipairs(modifiers or {}) do
        local skill = self.type.stats.skills[entry.skill](self)
        skill.modifier = skill.modifier + entry.amount * direction
    end
end

local roleChanged
roleChanged = async:registerTimerCallback("BaB_methodPlayer_changeRole", function(previousModifiers)
    applyRoleModifiers(previousModifiers, -1)

    local modifiers, leadingRole = getRoleModifiers()
    applyRoleModifiers(modifiers, 1)

    self:sendEvent("ShowMessage", {
        message = l10n("msg_methodActor_" .. leadingRole)
    })

    async:newGameTimer(settings.rolePeriod, roleChanged, modifiers)
end)

I.CharacterTraits.addTrait {
    id = "BaB_methodPlayer",
    type = "background",
    name = "Method Player",
    description = (
        "You were never trained in anything. You were hired to be whoever the play needed that week: " ..
        "the duelist, the physician, the thief, the king. You learned your lines, studied your part " ..
        "and became it, because audiences can tell when you're faking. When the week ended you shed " ..
        "the role, and the skills went with it. Now there are no plays, and you still haven't stopped. " ..
        "Every few days you wake up as someone else, with their hands and their habits, and without " ..
        "whatever the last one knew.\n" ..
        "\n" ..
        "+5 Intelligence and Personality\n" ..
        "> Every 3 game days, the role changes:\n" ..
        "   > Two random major skills: one +20 and one -20\n" ..
        "   > Four random minor skills: two +20 and two -20\n" ..
        "   > Three random miscellaneous skills: +30"
    ),
    doOnce = function()
        local intelligence = self.type.stats.attributes.intelligence(self)
        intelligence.base = intelligence.base + 5

        local personality = self.type.stats.attributes.personality(self)
        personality.base = personality.base + 5

        async:newGameTimer(settings.rolePeriod, roleChanged)
    end,
}
