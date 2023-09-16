require("__Kux-CoreLib__/lib/init")

---@class mod : KuxCoreLib.ModInfo
local mod = setmetatable(
	{
		__base = KuxCoreLib.ModInfo
	},
	{
		__index = KuxCoreLib.ModInfo,
		__metatable = "Metatable is protected!"
	}
)
if(mod.current_stage:match("^settings") or mod.current_stage:match("^data")) then
	--require("__Kux-CoreLib__/lib/data/@")
end
if(mod.current_stage=="control") then
	if script.active_mods["gvv"] then require("__gvv__.gvv")() end
	require("__Kux-CoreLib__/lib/@")
end

_G.mod = mod
return mod