local I = require("openmw.interfaces")
local self = require("openmw.self")

local bgPicked = false

I.CharacterTraits.addTrait {
    id = "BaB_jyggalagBlessing",
    type = "background",
    name = "Blessed by Jyggalag",
    description = (
        "A forgotten god of Order heard your prayer and brought perfect symmetry to your being. " ..
        "Every strength tempered, every weakness lifted. Equality in all things. " ..
        "Whether this is a blessing or a curse depends entirely on your tolerance for mediocrity.\n" ..
        "\n" ..
        "> All your skills and attributes are evened out"
    ),
    doOnce = function()
        bgPicked = true
    end,
}

return {
    eventHandlers = {
        CharacterTraits_allTraitsPicked = function()
            if bgPicked then
                local function shuffle(list)
                    for i = #list, 2, -1 do
                        local j = math.random(i)
                        list[i], list[j] = list[j], list[i]
                    end
                end

                local accessors = {}

                for _, getter in pairs(self.type.stats.skills) do
                    accessors[#accessors + 1] = {
                        get = function() return getter(self).base end,
                        set = function(v) getter(self).base = v end,
                    }
                end
                for _, getter in pairs(self.type.stats.attributes) do
                    accessors[#accessors + 1] = {
                        get = function() return getter(self).base end,
                        set = function(v) getter(self).base = v end,
                    }
                end
                if I.SkillFramework and I.SkillFramework.getSkillRecords then
                    for id in pairs(I.SkillFramework.getSkillRecords()) do
                        accessors[#accessors + 1] = {
                            get = function() return I.SkillFramework.getSkillStat(id).base end,
                            set = function(v) I.SkillFramework.getSkillStat(id).base = v end,
                        }
                    end
                end

                local values = {}
                for i, a in ipairs(accessors) do values[i] = a.get() end

                local total = 0
                for _, v in ipairs(values) do total = total + v end

                local base      = math.floor(total / #accessors)
                local remainder = total - base * #accessors

                shuffle(accessors) -- randomise who gets the leftover points
                for i, a in ipairs(accessors) do
                    a.set(base + (i <= remainder and 1 or 0))
                end
            end
        end,
    }
}
