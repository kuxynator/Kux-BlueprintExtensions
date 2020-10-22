Modules = require("__Kux-CoreLib__/lib/Modules")
Log     = require ("__Kux-CoreLib__/lib/Log")

local Util = require('util')
local actions = require('actions')
local mod_gui = require('mod-gui')
local GUI = require('gui')

if script.active_mods["gvv"] then require("__gvv__.gvv")() end

require "__Kux-CoreLib__/lib/lua"
require "__Kux-CoreLib__/lib/Colors"
require "modules/Blueprint"
Modules.Snap = require('modules/snap')
Modules.Updater = require('modules/updater')
Modules.Flip = require('modules/flip')
Modules.Wireswap = require('modules/wireswap')
Modules.Rotate = require('modules/rotate')
Modules.Tempprint = require('modules/tempprint')
Modules.Landfill = require('modules/landfill')

local event_handlers = {}
local function add_event_handler(event, fn)
    local t = defines.events[event]
    event = t or event

    t = event_handlers[event]
    if not t then
        t = {}
        event_handlers[event] = t
    end
    t[#t+1] = fn
end


local function setup_event_handlers(event, handlers)
    if not handlers or #handlers == 0 then
        return
    end
    if #handlers == 1 then
        script.on_event(event, handlers[1])
    else
        script.on_event(event, function(event)
            for i = 1, #handlers do
                handlers[i](event)
            end
        end)
    end
end


-- Build list of required event handlers.
for modname, module in pairs(Modules) do
	if type(module) ~= "table" then goto next end
    if module.events then
        for event, fn in pairs(module.events) do
            add_event_handler(event, fn)
        end
	end
	::next::
end

local function dispatch_action(event, action)
    if not action or not action.handler then return end
    local player = game.players[event.player_index]
    return action.handler(player, event, action)
end


local function on_input_event(event)
    return dispatch_action(event, actions[event.input_name])
end


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

add_event_handler(defines.events.on_gui_click, function(event)
	return dispatch_action(event, actions[event.element.name])
end)

add_event_handler(defines.events.on_lua_shortcut,function(event)
	return dispatch_action(event, actions[event.prototype_name])
end)

add_event_handler(defines.events.on_player_removed, function(event)
    --call_module_methods('on_player_removed', event)
    Util.clear_all_items(event.player_index)
    global.playerdata[event.player_index] = nil
end)


add_event_handler(defines.events.on_player_cursor_stack_changed, function(event)
	GUI.update_visibility(game.players[event.player_index])
end)


add_event_handler(defines.events.on_runtime_mod_setting_changed, function(e)
	Modules.call('on_runtime_mod_setting_changed', e)

    if not (
            e.setting_type == 'runtime-per-user'
            and string.find(e.setting, "Kux-BlueprintExtensions_show-", 1, true) == 1
    ) then
        return
    end
    GUI.setup(game.players[e.player_index])
end)


add_event_handler(defines.events.on_player_created, function(event)
    GUI.setup(game.players[event.player_index])
end)


for name, action in pairs(actions) do
    if action.handler then
        script.on_event(name, on_input_event)
    else
        log("Warning: No action handler defined for " .. name)
    end
end


for event, handlers in pairs(event_handlers) do
    setup_event_handlers(event, handlers)
end
