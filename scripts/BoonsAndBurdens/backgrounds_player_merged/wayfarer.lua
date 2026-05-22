local I = require("openmw.interfaces")
local self = require("openmw.self")

I.CharacterTraits.addTrait({
    id = "BaB_wayfarer",
    type = "background",
    name = "Wayfarer",
    description = (
        "No master, no forge, no proper tools. "
        .. "You learned to maintain your gear the hard way - "
        .. "on the road, with whatever you had. "
        .. "It is never pretty work, but it holds.\n"
        .. "\n"
        .. "+10 Armorer and Athletics\n"
        .. "+5 Spear and Marksman\n"
        .. "-15 Mercantile and Speechcraft"
    ),
    doOnce = function()
        local skills = self.type.stats.skills

        skills.armorer(self).base = skills.armorer(self).base + 10
        skills.athletics(self).base = skills.athletics(self).base + 10
        skills.spear(self).base = skills.spear(self).base + 5
        skills.marksman(self).base = skills.marksman(self).base + 5

        skills.mercantile(self).base = skills.mercantile(self).base - 15
        skills.speechcraft(self).base = skills.speechcraft(self).base - 15
    end,
})
