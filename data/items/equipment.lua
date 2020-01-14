local armour_item = baseitem:subclass("ArmourItem")

armour_item.onEquip = function(self, player)
	player.defense = player.defense + self.protection
end

armour_item.onUnequip = function(self, player)
	player.defense = player.defense - self.protection
end
	-- TODO: implemement this functionality in the game engine
armour_item.equippedTick = function(self) end


armour_item:new("WOODEN_HELMET", {
	texture = "helmet.png",
	color = {0.75, 0.5, 0.3},
	helmet = true,
	protection = 2

})

armour_item:new("WOODEN_CHESTPLATE", {
	chestplate = true,
	texture = "chestplate.png",
	color = {0.75, 0.5, 0.3},
	protection = 2
})

armour_item:new("WOODEN_LEGGINGS", {
	leggings = true,
	texture = "leggings.png",
	color = {0.75, 0.5, 0.3},
	protection = 2
})