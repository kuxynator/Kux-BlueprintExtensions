_G.mod = require("mod") --[[@as mod]]

require("modules/bootstrap")

local Util = require('modules/util')
local GUI = require('modules/gui')

local actions = require("modules/actions")

--init actions
require('actions/snap')
require('actions/updater')
require('actions/flip')
require('actions/wireswap')
require('actions/rotate')
require('actions/tempprint')
require('actions/landfill')

local function dispatch_action(event, action)
    if not action or not action.handler then return end
	local player = game.players[event.player_index]
	global.player = player
    return action.handler(player, event, action)
end

local function on_input_event(event)
    return dispatch_action(event, actions[event.input_name])
end

for name, action in pairs(actions) do
	if action.handler then
		script.on_event(name, on_input_event)
	else
		log("Warning: No action handler defined for " .. name)
	end
end

EventDistributor.register(defines.events.on_gui_click,function(event)
	return dispatch_action(event, actions[event.element.name])
end)

EventDistributor.register(defines.events.on_lua_shortcut, function(event)
	return dispatch_action(event, actions[event.prototype_name])
end)

EventDistributor.register(defines.events.on_player_removed, function(e)
    --call_module_methods('on_player_removed', event)
    Util.clear_all_items(e.player_index)
    global.playerdata[e.player_index] = nil
end)

EventDistributor.register(defines.events.on_player_cursor_stack_changed, function(e)
	GUI.update_visibility(game.players[e.player_index])
end)

EventDistributor.register(defines.events.on_runtime_mod_setting_changed, function(e)
    if not (
            e.setting_type == 'runtime-per-user'
            and string.find(e.setting, mod.prefix.."show-", 1, true) == 1
    ) then
        return
    end
    GUI.setup(game.players[e.player_index])
end)


EventDistributor.register(defines.events.on_player_created, function(event)
    GUI.setup(game.players[event.player_index])
end)


