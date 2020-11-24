require "__Kux-CoreLib__/lib/lua"
Modules = require("__Kux-CoreLib__/lib/Modules")
Log     = require("__Kux-CoreLib__/lib/Log")

local Util = require('util')
local mod_gui = require('mod-gui')
local GUI = require('gui')

if script.active_mods["gvv"] then require("__gvv__.gvv")() end

require "__Kux-CoreLib__/lib/Colors"
require "modules/Blueprint"
require "modules.FluidPermutation"
require "modules/Events"

Modules.Snap = require('modules/snap')
Modules.Updater = require('modules/updater')
Modules.Flip = require('modules/flip')
Modules.Wireswap = require('modules/wireswap')
Modules.Rotate = require('modules/rotate')
Modules.Tempprint = require('modules/tempprint')
Modules.Landfill = require('modules/landfill')

Events.initModules()

local function init_globals()
    global.playerdata = global.playerdata or {}
end

--#region bootstrap

script.on_init(function()
    -- FIXME: Update all gui and shortcut bars.
    init_globals()
	Modules.on_init()
end)

script.on_load(function()
	Modules.on_load()
end)

script.on_configuration_changed(function(e)
    -- FIXME: Update all gui and shortcut bars.
    init_globals()
	Modules.on_configuration_changed(e)
end)

--#end region

Events.add(defines.events.on_gui_click,	function(event)
	return Events.dispatch_action(event, event.element.name)
end)

Events.add(defines.events.on_lua_shortcut, function(event)
	return Events.dispatch_action(event, event.prototype_name)
end)

Events.add(defines.events.on_player_removed, function(e)
    --call_module_methods('on_player_removed', event)
    Util.clear_all_items(e.player_index)
    global.playerdata[e.player_index] = nil
end)

Events.add(defines.events.on_player_cursor_stack_changed, function(e)
	GUI.update_visibility(game.players[e.player_index])
end)

Events.add(defines.events.on_runtime_mod_setting_changed, function(e)
	Modules.call('on_runtime_mod_setting_changed', e)
    if not (
            e.setting_type == 'runtime-per-user'
            and string.find(e.setting, "Kux-BlueprintExtensions_show-", 1, true) == 1
    ) then
        return
    end
    GUI.setup(game.players[e.player_index])
end)


Events.add(defines.events.on_player_created, function(event)
    GUI.setup(game.players[event.player_index])
end)

Events.setup()
