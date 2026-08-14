-- Library functions and defines


local Util = {}

local bpu = KuxCoreLib.BlueprintUtils.internal


Util.get_blueprint = bpu.get_blueprint
Util.copy_record_to_table = bpu.copy_record_to_table
Util.copy_table_to_item_stack = bpu.copy_table_to_item_stack
Util.export_record = bpu.export_record
Util.copy_blueprint = bpu.copy_blueprint

--- @class Updater
--- @field name string
--- @field label string
--- @field icons table
--- @field status any

--- @class PlayerData
--- @field updater Updater
--- @field stored_items { [string]: LuaEntity }
--TODO define

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

--- Fetch an item stack in the Surface of Holding(tm)
---@param player_index int
---@param key string
---@return any stack
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
