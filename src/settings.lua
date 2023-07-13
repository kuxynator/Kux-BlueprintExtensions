_G.mod = require("mod") --[[@as mod]]

data:extend{
	{
        type = "bool-setting",
        name = mod.prefix.."EnableLog",
        setting_type = "runtime-global",
        order = 0,
        default_value = false,
    },
    {
        type = "string-setting",
        name = mod.prefix.."version-increment",
        setting_type = "runtime-per-user",
        order = 100,
        default_value = 'auto',
        allowed_values = {'off', 'auto', 'on'}
    },
    {
        type = "string-setting",
        name = mod.prefix.."alt-version-increment",
        setting_type = "runtime-per-user",
        order = 101,
        default_value = 'on',
        allowed_values = {'off', 'auto', 'on'}
    },
    {
        type = "bool-setting",
        name = mod.prefix.."cardinal-center",
        setting_type = "runtime-per-user",
        order = 150,
        default_value = true,
    },
    {
        type = "bool-setting",
        name = mod.prefix.."horizontal-invert",
        setting_type = "runtime-per-user",
        order = 200,
        default_value = false,
    },
    {
        type = "bool-setting",
        name = mod.prefix.."vertical-invert",
        setting_type = "runtime-per-user",
        order = 201,
        default_value = false,
	},
	{
        type = "bool-setting",
        name = mod.prefix.."support-fluid_permutations",
        setting_type = "runtime-per-user",
        order = 301,
        default_value = true,
    },
    {
        type = "bool-setting",
        name = mod.prefix.."support-gdiw",
        setting_type = "runtime-per-user",
        order = 302,
        default_value = true,
	},
    {
        type = "string-setting",
        name = mod.prefix.."landfill-mode",
        setting_type = "runtime-per-user",
        order = 401,
        default_value = 'tempcopy',
        allowed_values = {'update', 'copy', 'tempcopy'}
    },
    {
        type = "bool-setting",
        name = mod.prefix.."show-mirror",
        setting_type = "runtime-per-user",
        order = 500,
        default_value = true,
    },
    {
        type = "bool-setting",
        name = mod.prefix.."show-rotate",
        setting_type = "runtime-per-user",
        order = 501,
        default_value = true,
    },
    {
        type = "bool-setting",
        name = mod.prefix.."show-clone",
        setting_type = "runtime-per-user",
        order = 502,
        default_value = true,
    },
    {
        type = "bool-setting",
        name = mod.prefix.."show-wireswap",
        setting_type = "runtime-per-user",
        order = 503,
        default_value = true,
    },
    {
        type = "bool-setting",
        name = mod.prefix.."show-landfill",
        setting_type = "runtime-per-user",
        order = 504,
        default_value = true,
    },
}


