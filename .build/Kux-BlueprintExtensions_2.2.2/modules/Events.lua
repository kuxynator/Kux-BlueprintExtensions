Events = {}

local actions = require("actions")
local event_handlers = {}

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

local dispatch_action = function(event, action)
    if not action or not action.handler then return end
	local player = game.players[event.player_index]
	global.player = player
    return action.handler(player, event, action)
end

Events.dispatch_action = function (event, name)
	return dispatch_action(event, actions[name])
end

local function on_input_event(event)
    return dispatch_action(event, actions[event.input_name])
end

Events.initModules = function ()
	-- Build list of required event handlers.
	for modname, module in pairs(Modules) do
		if type(module) ~= "table" then goto next end
		if module.events then
			for event, fn in pairs(module.events) do
				Events.add(event, fn)
			end
		end
		::next::
	end
end

Events.add = function(event, fn)
	if fn == nil then error("Argument must not be nil. Name: 'fn'") end

    local t = defines.events[event]
	event = t or event

	t = event_handlers[event]
    if not t then
        t = {}
        event_handlers[event] = t
    end
    t[#t+1] = fn
end

Events.setup = function()
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
end