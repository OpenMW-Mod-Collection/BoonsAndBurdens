---@omw-context player
---@diagnostic disable: undefined-field
local I = require("openmw.interfaces")
local self = require("openmw.self")

I.CharacterTraits.addTrait {
    id = "BaB_voidscarredCopyist",
    type = "background",
    name = "Voidscarred Copyist",
    description = (
        "As a young apprentice-clerk, you were paid to transcribe " ..
        "a restricted magical text for a private collector - a document on Atronach " ..
        "theory and the manipulation of the Void. The work left a permanent mark. " ..
        "Your Atronach nature is now deeper than birthright: " ..
        "your soul drinks magic almost greedily, but the Void exacts its cost.\n" ..
        "\n" ..
        "Requirements: Stunted Magicka ability.\n" ..
        "\n" ..
        "+15% Spell Absorption\n" ..
        "+5 Intelligence\n" ..
        "+5 Mercantile\n" ..
        "-10 Endurance\n" ..
        "-20 Luck\n" ..
        "> You start with an Absorb Magicka power which backfires and also damages Intelligence"
    ),
    doOnce = function()
        local merc = self.type.stats.skills.mercantile(self)
        merc.base = merc.base + 5

        local attrs = self.type.stats.attributes
        attrs.intelligence(self).base = attrs.intelligence(self).base + 5
        attrs.endurance(self).base = attrs.endurance(self).base - 10
        attrs.luck(self).base = attrs.luck(self).base - 20

        local selfSpells = self.type.spells(self)
        selfSpells:add("BaB_voidscarredCopyist_ability")
        selfSpells:add("BaB_voidscarredCopyist_power")
    end,
}
