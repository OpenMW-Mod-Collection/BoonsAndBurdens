---@diagnostic disable: assign-type-mismatch, undefined-field, missing-parameter
---@omw-context player
local I = require("openmw.interfaces")
local self = require("openmw.self")
local core = require("openmw.core")

I.CharacterTraits.addTrait {
    id = "BaB_looseLips",
    type = "background",
    name = "Loose Lips",
    description = (
        "You were three drinks in, maybe four, and the name just came out. " ..
        "Not loudly. Not carelessly. Just - out, into the wrong air, at the wrong table, " ..
        "in a tavern you'd been told a dozen times to avoid. " ..
        "By morning the Tong knew. By the end of the week, so did you. " ..
        "You were expelled rather than sanctioned, which you have since decided to interpret generously.\n" ..
        "\n" ..
        "+5 to all Morag Tong faction skills\n" ..
        "+5 Personality\n" ..
        "-15 Speechcraft\n" ..
        "-20 disposition with Great House Hlaalu members\n" ..
        "All Morag Tong members are hostile on sight"
    ),
    doOnce = function()
        local moragTong = core.factions.records["morag tong"]
        for _, skill in ipairs(moragTong.skills) do
            local selfAttr = self.type.stats.skills[skill](self)
            selfAttr.base = selfAttr.base + 5
        end

        local personality = self.type.stats.attributes.personality(self)
        personality.base = personality.base + 5

        local speechcraft = self.type.stats.skills.speechcraft(self)
        speechcraft.base = speechcraft.base - 15

        self.type.joinFaction(self, "morag tong")
        self.type.expel(self, "morag tong")
    end,
    onLoad = function()
        core.sendGlobalEvent("BoonsAndBurdens_registerLooseLips", self)
    end
}
