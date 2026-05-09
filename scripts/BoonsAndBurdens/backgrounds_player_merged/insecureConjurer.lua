local I = require("openmw.interfaces")
local self = require("openmw.self")
local core = require("openmw.core")

I.CharacterTraits.addTrait {
    id = "BaB_insecureConjurer",
    type = "background",
    name = "Insecure Conjurer",
    description = (
        "You have a gift for pulling things from the other side. " ..
        "Holding them there is another matter entirely. " ..
        "The theory is sound, the practice less so - your summons arrive willingly enough, " ..
        "but bound creatures sense weakness in their master. And yours sense plenty of it.\n" ..
        "\n" ..
        "+20 Conjuration\n" ..
        "-15 Willpower\n" ..
        "-5 Luck\n" ..
        "> Your summons have a chance to turn against you"
    ),
    doOnce = function()
        local conj = self.type.stats.skills.conjuration(self)
        conj.base = conj.base + 20
        local will = self.type.stats.attributes.willpower(self)
        will.base = will.base - 15
        local luck = self.type.stats.attributes.luck(self)
        luck.base = luck.base - 5
    end,
    onLoad = function()
        core.sendGlobalEvent("BoonsAndBurdens_registerInsecureConjurer", self)
    end
}
