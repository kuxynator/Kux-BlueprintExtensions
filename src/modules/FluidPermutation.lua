FluidPermutation = {}

FluidPermutation.isAvailable = false --TODO script.active_mods["fluid_permutations"] ~= nil

FluidPermutation.mirror = function(recipeName)
	local v = nil
	local success, ex = pcall(function ()
		v = remote.call("fluid_permutations","mirror",recipeName)
	end)
	if not success then
		global.player.print("Kux-BlueprintExtension: Fluid Permutations communication error! see logfile.", Colors.lightred)
		log(ex)
	end
	return iif(success, v, nil )

end