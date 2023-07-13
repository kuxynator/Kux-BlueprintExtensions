_G.mod = require("mod") --[[@as mod]]
--require 'prototypes/inputs'
require 'prototypes/items'
--require 'prototypes/style'
--require 'prototypes/shortcuts'

local actions = require('modules/actions')

local function icon(s, x, y)
    return {
        filename = "__Kux-BlueprintExtensions__/graphics/shortcut-bar-buttons-" .. s .. ".png",
        priority = "extra-high-no-scale",
        flags = { "icon" },
        size = s,
        x = s*(x or 0),
        y = s*(y or 0),
        scale = 1
    }
end

for name, action in pairs(actions) do
    if action.key_sequence then
        data:extend{ {
            type = "custom-input",
            name = name,
            key_sequence = action.key_sequence,
            order = action.order
        }}
    end

    if action.icon ~= nil then
        local sprite = icon(32, action.icon, 1)
        sprite.type = "sprite"
        sprite.name = name

        data:extend {
            sprite,
            {
                name = name,
                type = "shortcut",
                localised_name = { "controls." .. name },
                associated_control_input = (action.key_sequence and name or nil),
                action = "lua",
                toggleable = action.toggleable or false,
                icon = icon(32, action.icon, 1),
                disabled_icon = icon(32, action.icon, 0),
                small_icon = icon(24, action.icon, 1),
                disabled_small_icon = icon(24, action.icon, 0),
                style = action.shortcut_style,
                order = "b[blueprints]-x[bpex]-" .. action.order
            }
        }
    end
end

--COMPATIBILITY 1.1.0 renamed "clean-cursor" to "clear-cursor"
local clearedCursorProxy_linkedGameControl = "clear-cursor"
if string.find(mods["base"],"^1%.0%.") then clearedCursorProxy_linkedGameControl = "clean-cursor" end

print(mods["base"], clearedCursorProxy_linkedGameControl)

data:extend({
    {
        type = "custom-input",
        name = "Kux-BlueprintExtensions_cleared_cursor_proxy",
        key_sequence = "",
        linked_game_control = clearedCursorProxy_linkedGameControl
    }
})