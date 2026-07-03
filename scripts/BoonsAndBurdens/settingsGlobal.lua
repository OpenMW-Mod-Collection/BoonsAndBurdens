---@omw-context global
---@diagnostic disable: missing-fields
local I = require('openmw.interfaces')

I.Settings.registerGroup {
    key = 'SettingsBoonsAndBurdens_insecureConjurer',
    page = 'BoonsAndBurdens',
    l10n = 'BoonsAndBurdens',
    name = 'insecureConjurer_groupName',
    permanentStorage = true,
    order = 1,
    settings = {
        {
            key = 'disobeyChance',
            name = 'disobeyChance_name',
            renderer = 'number',
            integer = false,
            default = 20,
        },
    }
}

I.Settings.registerGroup {
    key = 'SettingsBoonsAndBurdens_hollowBlooded',
    page = 'BoonsAndBurdens',
    l10n = 'BoonsAndBurdens',
    name = 'hollowBlooded_groupName',
    permanentStorage = true,
    order = 1,
    settings = {
        {
            key = 'statBonus',
            name = 'statBonus_name',
            description = 'statBonus_desc',
            renderer = 'number',
            default = 2,
        },
    }
}
