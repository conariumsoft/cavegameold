baseitem:new("EQUIP", {
	helmet = true,

	onEquip = function(self, player)
		print("cucc")
	end,
	onUnequip = function(self, player)
		print("zucc")
	end,

	-- TODO: implemement this functionality in the game engine
	equippedTick = function(self) end,
})