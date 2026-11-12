---@omw-context global
---@diagnostic disable: missing-fields
local I = require('openmw.interfaces')
local time = require('openmw_aux.time')

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

I.Settings.registerGroup {
    key = 'SettingsBoonsAndBurdens_methodPlayer',
    page = 'BoonsAndBurdens',
    l10n = 'BoonsAndBurdens',
    name = 'methodPlayer_groupName',
    permanentStorage = true,
    order = 3,
    settings = {
        {
            key = 'rolePeriod',
            name = 'rolePeriod_name',
            description = 'rolePeriod_desc',
            renderer = 'time_V1',
            default = 3 * time.day,
            argument = {
                days = true,
            },
        },
    }
}
