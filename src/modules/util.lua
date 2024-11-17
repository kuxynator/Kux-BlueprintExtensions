-- Library functions and defines

local Util = {}

--- @class Updater
--- @field name string
--- @field label string
--- @field icons table
--- @field status any

--- @class PlayerData
--- @field updater Updater
--TODO define

---Wrapper for LuaItemStack or LuaRecord
---@class BlueprintItem : LuaItemStack, LuaRecord
---@field record LuaRecord? The LuaRecord if that is one, else nil
---@field itemStack LuaItemStack? The LuaItemStack if that is one, else nil
---@field valid_for_write boolean
---@field item LuaItem?

---@Class BlueprintItemClass
---@overload fun(obj: LuaItemStack|LuaRecord):BlueprintItem
local BlueprintItem = {
	__class="BlueprintItemClass"
}

---@diagnostic disable-next-line: param-type-mismatch
setmetatable(BlueprintItem, {
	---Returns a new instance of BlueprintItem
	---@param self any
	---@param obj LuaItemStack|LuaRecord
	---@return BlueprintItem
	__call = function(self, obj)
		local newObj = {}
		newObj.__base = obj
		newObj.record = obj.object_name=="LuaRecord" and obj or false
		newObj.itemStack  = obj.object_name=="LuaItemStack" and obj or false
		newObj.valid_for_write = (newObj.itemStack and true) or (newObj.record and newObj.record.valid_for_write) or false
		newObj.item = (newObj.itemStack and newObj.item and newObj.item) or false
		setmetatable(newObj,{
			__index = obj,
			__newindex = obj
		})
		return setmetatable({}, {
			__index = function (self, key)
				if key=="record"    then return self.record and self.record or nil end
				if key=="itemStack" then return self.itemStack and self.itemStack or nil end
				if key=="item"      then return self.item and self.item or nil end
				return newObj[key] or obj[key]
			end,
			__newindex=function () error("Invalid oparation") end,
		})
	end,
	__index=function () error("Invalid oparation") end,
	__newindex=function () error("Invalid oparation") end,
	__metatable = false
}
)

--[[
--- Returns the item if it is a blueprint, the selected blueprint in the book if it is a blueprint book, or nil.
--- @param bp LuaItemStack?
--- @return LuaItemStack?
function Util.get_blueprint(bp)
    if not (bp and bp.valid and bp.valid_for_read) then return nil end
    if bp.is_blueprint_book and bp.active_index then
        local inventory = bp.get_inventory(defines.inventory.item_main)
		if not inventory then return nil end
        if inventory.get_item_count() == 0 then return nil end
        return Util.get_blueprint(inventory[bp.active_index])
    end
    if not bp.is_blueprint then return nil end
    return bp
end
]]

--- Returns the item if it is a blueprint, the selected blueprint in the book if it is a blueprint book, or nil.
--- @param obj LuaItemStack|LuaRecord|LuaPlayer
--- @return BlueprintItem?
function Util.get_blueprint(obj)
	if not obj then return nil end
	if obj.object_name=="LuaPlayer" then
		return Util.get_blueprint(obj.cursor_record) or Util.get_blueprint(obj.cursor_stack) or nil
	elseif obj.object_name=="LuaRecord" then local record = obj --[[@as LuaRecord]]
		if record.type=="blueprint-book" then
			if not record.contents then return nil end
			if #record.contents == 0 then return nil end
			if not pcall(function() return record["active_index"] end) then return nil end
			return Util.get_blueprint(record.contents[record.active_index]) --TODO missing API LuaRecord.active_index
		elseif record.type=="blueprint" then
			return BlueprintItem(record)
		else return nil --"deconstruction-planner" "upgrade-planner"
		end
	elseif obj.object_name=="LuaItemStack" then local itemStack = obj --[[@as LuaItemStack]]
		if not (itemStack and itemStack.valid and itemStack.valid_for_read) then return nil end
		if itemStack.is_blueprint_book and itemStack.active_index then
			local inventory = itemStack.get_inventory(defines.inventory.item_main)
			if not inventory then return nil end
			if inventory.get_item_count() == 0 then return nil end
			return Util.get_blueprint(inventory[itemStack.active_index])
		end
		if not itemStack.is_blueprint then return nil end
		return BlueprintItem(itemStack)
	else return nil
	end
end

--- will replace Util.get_blueprint
--- @param player LuaPlayer
function Util.tryGetBlueprint(player)
	local bp = Util.get_blueprint(player.cursor_stack)
	if bp and not bp.is_blueprint_setup() then return nil end

	-- COMBATIBILIY 1.1.0
	if player.is_cursor_blueprint and player.is_cursor_blueprint() then -- Returns whether the player is holding a blueprint, it takes into account a blueprint as an item as well as blueprint from the blueprint record from the blueprint library.
		-- player.get_blueprint_entities() -- array of blueprint entity	Returns the same type of data as LuaItemStack::readBlueprintEntities, but works for the currently selected blueprint, regardless of it being in a blueprint book or picked from the blueprint library.
		-- TODO no tiles are returned, we have to wait for a better version
		return player
	end
end

--- Create or return a dummy storage surface
function Util.get_dummy_surface()
    if game.surfaces.surface_of_holding then
        return game.surfaces.surface_of_holding
    end

    local none = { frequency = "none" }
    local autoplace_controls = {}
    for k,_ in pairs(prototypes.autoplace_control) do
        autoplace_controls[k] = none
    end
    return game.create_surface(
        'surface_of_holding',
        { width=1, height=1, autoplace_controls = autoplace_controls }
    )
end

-- Store an item stack in the Surface of Holding(tm)
function Util.store_item(player_index, key, item)
    local pdata = Util.get_pdata(player_index)
    if not pdata.stored_items then
        pdata.stored_items = {}
    end

    if not (pdata.stored_items[key] and pdata.stored_items[key].valid) then
        pdata.stored_items[key] = Util.get_dummy_surface().create_entity{name='item-on-ground', position={x=0,y=0}, stack={name='blueprint'}}
    end
    pdata.stored_items[key].stack.set_stack(item)
    return pdata.stored_items[key].stack
end

-- Clear an item stack in the Surface of Holding(tm)
function Util.clear_item(player_index, key)
    local pdata = storage.playerdata[player_index]
    if not pdata or not pdata.stored_items or not pdata.stored_items[key] then
        return
    end
    if pdata.stored_items[key].valid then
        pdata.stored_items[key].destroy()
    end
    pdata.stored_items[key] = nil
end

-- Clear ALL item stacks in the Surface of Holding
function Util.clear_all_items(player_index)
    local pdata = storage.playerdata[player_index]
    if not pdata or not pdata.stored_items then
        return
    end
    for _,ent in pairs(pdata.stored_items) do
        if ent and ent.valid then
            ent.destroy()
        end
    end
    pdata.stored_items = {}
end

-- Fetch an item stack in the Surface of Holding(tm)
function Util.fetch_item(player_index, key)
    local pdata = storage.playerdata[player_index]
    if not pdata or not pdata.stored_items or not pdata.stored_items[key] then
        return nil
    end
    if pdata.stored_items[key].valid then
        return pdata.stored_items[key].stack
    end
    pdata.stored_items[key] = nil
    return
end



--- Get or initialize player data.
--- @param player_index integer
--- @return PlayerData
function Util.get_pdata(player_index)
    local pdata = storage.playerdata[player_index]
    if not pdata then
        pdata = {

		}
        storage.playerdata[player_index] = pdata
    end
    return pdata
end


return Util
