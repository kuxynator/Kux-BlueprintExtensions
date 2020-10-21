-- Temporary blueprint support
local Tempprint = {}


function Tempprint.set_temporary(player)
    -- Makes a note of the item the player is currently holding.  If the cursor stack is cleaned, the item is removed.
    local stack = player.cursor_stack

    if not (stack.valid and stack.valid_for_read and stack.type == 'blueprint' and stack.item_number ~= 0) then return end

    local pdata = global.playerdata[player.index]
    if not pdata then
        pdata = {}
        global.playerdata[player.index] = pdata
    end

    pdata.temporary_item = {name=stack.name, item_number=stack.item_number}

    return true
end


function Tempprint.clear_temporary(player)
    local pdata = global.playerdata[player.index]
    if not (pdata and pdata.temporary_item) then return end  -- No temporary item to clear
    pdata.temporary_item = nil
    return
end


function Tempprint.nuke_temporary(player)
    local pdata = global.playerdata[player.index]
    if not (pdata and pdata.temporary_item) then return end  -- No temporary item to clear
    local tempitem = pdata.temporary_item

    local stack = player.cursor_stack
    if not (stack.valid and stack.valid_for_read and stack.type == 'blueprint' and stack.item_number ~= 0) then return end

    if stack.name == tempitem.name and stack.item_number == tempitem.item_number then
        stack.clear()
    end

    pdata.temporary_item = nil
    return true
end


script.on_event(
        "BlueprintExtensions_cleared_cursor_proxy",
        function(event) return Tempprint.nuke_temporary(game.players[event.player_index]) end
)


local function clear_temporary_event(event)
    return Tempprint.clear_temporary(game.players[event.player_index])
end


Tempprint.events = {
    [defines.events.on_player_configured_blueprint] = clear_temporary_event,
    [defines.events.on_player_cursor_stack_changed] = clear_temporary_event
}


return Tempprint