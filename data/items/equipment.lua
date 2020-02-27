local armour_item = baseitem:subclass("ArmourItem")
armour_item.set = "base"
armour_item.protection = 0

armour_item.onEquip = function(self, player)
	player.defense = player.defense + self.protection
end

armour_item.onUnequip = function(self, player)
	player.defense = player.defense - self.protection
end
	-- TODO: implemement this functionality in the game engine
armour_item.equippedTick = function(self) end

-- wooden armour
armour_item:new("WOODEN_HELMET", {
	displayname = "WOODEN HELMET",
	texture = "helmet.png",
	set = "base",
	color = {0.65, 0.4, 0.2},
	helmet = true,
	protection = 1,
})

armour_item:new("WOODEN_CHESTPLATE", {
	displayname = "WOODEN CHESTPLATE",
	chestplate = true,
	texture = "chestplate.png",
	color = {0.65, 0.4, 0.2},
	protection = 2
})

armour_item:new("WOODEN_LEGGINGS", {
	displayname = "WOODEN LEGGINGS",
	leggings = true,
	texture = "leggings.png",
	color = {0.65, 0.4, 0.2},
	protection = 1
})

-- copper armour
armour_item:new("COPPER_HELMET", {
	displayname = "COPPER HELMET",
	texture = "helmet.png",
	helmet = true,
	color = {1, 0.45, 0.0},
	protection = 2,
})

armour_item:new("COPPER_CHESTPLATE", {
	displayname = "COPPER CHESTPLATE",
	texture = "chestplate.png",
	chestplate = true,
	color = {1, 0.45, 0.0},
	protection = 3,
})

armour_item:new("COPPER_LEGGINGS", {
	displayname = "COPPER LEGGINGS",
	texture = "leggings.png",
	leggings = true,
	color = {1, 0.45, 0.0},
	protection = 2,
})

-- iron armour
armour_item:new("IRON_HELMET", {
	displayname = "IRON HELMET",
	texture = "helmet.png",
	helmet = true,
	color = {0.8, 0.8, 0.8},
	protection = 2,
})

armour_item:new("IRON_CHESTPLATE", {
	displayname = "IRON CHESTPLATE",
	texture = "chestplate.png",
	chestplate = true,
	color = {0.8, 0.8, 0.8},
	protection = 4,
})

armour_item:new("IRON_LEGGINGS", {
	displayname = "IRON LEGGINGS",
	texture = "leggings.png",
	leggings = true,
	color = {0.8, 0.8, 0.8},
	protection = 3,
})
-- lead armour
armour_item:new("LEAD_HELMET", {
	displayname = "LEAD HELMET",
	texture = "helmet.png",
	helmet = true,
	color = {0.6, 0.6, 0.6},
	protection = 3,
})

armour_item:new("LEAD_CHESTPLATE", {
	displayname = "LEAD CHESTPLATE",
	texture = "chestplate.png",
	chestplate = true,
	color = {0.6, 0.6, 0.6},
	protection = 4,
})

armour_item:new("LEAD_LEGGINGS", {
	displayname = "LEAD LEGGINGS",
	texture = "leggings.png",
	leggings = true,
	color = {0.6, 0.6, 0.6},
	protection = 3,
})

-- silver armour
armour_item:new("SILVER_HELMET", {
	displayname = "SILVER HELMET",
	texture = "helmet.png",
	helmet = true,
	color = {1, 1, 1},
	protection = 4,
})

armour_item:new("SILVER_CHESTPLATE", {
	displayname = "SILVER CHESTPLATE",
	texture = "chestplate.png",
	chestplate = true,
	color = {1, 1, 1},
	protection = 4,
})

armour_item:new("SILVER_LEGGINGS", {
	displayname = "SILVER LEGGINGS",
	texture = "leggings.png",
	leggings = true,
	color = {1, 1, 1},
	protection = 4,
})

-- TODO: palladium has special armour bonus
-- palladium armour
armour_item:new("PALLADIUM_HELMET", {
	displayname = "PALLADIUM HELMET",
	texture = "helmet.png",
	helmet = true,
	color = {1, 1, 1},
	protection = 5,
})

armour_item:new("PALLADIUM_CHESTPLATE", {
	displayname = "PALLADIUM CHESTPLATE",
	texture = "chestplate.png",
	chestplate = true,
	color = {1, 1, 1},
	protection = 6,
})

armour_item:new("PALLADIUM_LEGGINGS", {
	displayname = "PALLADIUM LEGGINGS",
	texture = "leggings.png",
	leggings = true,
	color = {1, 1, 1},
	protection = 5,
})

-- TODO: cobalt has special armour bonus effect
-- cobalt armour
armour_item:new("COBALT_HELMET", {
	displayname = "COBALT HELMET",
	texture = "helmet.png",
	helmet = true,
	color = {0.25, 0.25, 0.75},
	protection = 5,
})

armour_item:new("COBALT_CHESTPLATE", {
	displayname = "COBALT CHESTPLATE",
	texture = "chestplate.png",
	chestplate = true,
	color = {0.25, 0.25, 0.75},
	protection = 6,
})

armour_item:new("COBALT_LEGGINGS", {
	displayname = "COBALT LEGGINGS",
	texture = "leggings.png",
	leggings = true,
	color = {0.25, 0.25, 0.75},
	protection = 6,
})

armour_item:new("VIKING_HELMET", {
	displayname = "NORDIC STEEL HELM",
	helmet = true,

})

armour_item:new("VIKING_CHAIN", {
	displayname = "NORDIC STEEL CHAINMAIL",
	chestplate = true,
})

armour_item:new("VIKING_LEGGINGS", {
	displayname = "NORDIC STEEL LEGGINGS",
	leggings = true,
})

armour_item:new("WITCH_HAT", {
	set = "witch",
	texture = "helmet.png",
	helmet = true,
	color = {1,1,1}
})

armour_item:new("WITCH_DRESS_TOP", {
	set = "witch",
	texture = "chestplate.png",
	chestplate = true,
})

armour_item:new("WITCH_DRESS_BOTTOM", {
	set = "witch",
	texture = "leggings.png",
	leggings = true,
})

baseitem:new("BART", {
	accessory = true,
})

--[[
Walking side-by-side with death
The devil mocks their every step, ooh
The snow drives back the foot that's slow
The dogs of doom are howling more
]]

baseitem:new("SHOE_SPIKES", {
	accessory = true,
	stack = 1,
	displayname = "SHOE SPIKES",
	tooltip = "Allows climbing on walls",
	onEquip = function(self, player)
		print("bruh")
	end,
	onUnequip = function(self, player)
		print("poop")
	end,
	onDamage = function(self, player, damage)
		print("fucc")
	end,
	tick = function(self, player, dt)
		
		if player.falling then
			if player.moveLeft then
				player.lock_left = true
				print("DDD")
			else
				player.lock_left = false
				player.grab_wall_left = false
			end
			if player.moveRight then
				player.lock_right = true
			else
				player.lock_right = false
				player.grab_wall_right = false
			end
		end

		if player.jumping then
			if player.grab_wall_left then
				player.grab_wall_left = false
				player.lock_left = false
				player.velocity.x = 350
				player.velocity.y = -250
			end
			if player.grab_wall_right then
				player.grab_wall_right = false
				player.lock_right = false
				player.velocity.x = -350
				player.velocity.y = -250
			end
		end
	end,
	onCollide = function(self, player, tid, tpos, svec, nvec, dd)
		if nvec.y == 0 then
			if nvec.x == 1 then
				if player.lock_left then
					player.grab_wall_left = true
					player.velocity.y = 0
				end
			end

			if nvec.x == -1 then
				if player.lock_right then
					player.grab_wall_right = true
					player.velocity.y = 0
				end
			end
		end
	end,
})

--[[
	TODO: a jump debounce like in terraria. to make this shit feel much nicer and fun to use.
	getting kinda tired. think i'll stop for now.
]]
baseitem:new("JETPACK", {
	displayname = "JETPACK",
	texture = "jetpack.png",
	accessory = true,
	stack = 1,
	tick = function(self, player, dt)
		
		if player.jumping then
			player.jetpack_power = player.jetpack_power - dt
			if player.velocity.y > -150 and player.jetpack_power > 0 then
				player.velocity.y = player.velocity.y - (900*dt)
			end
		elseif player.falling == false then
			player.jetpack_power = 2
		end
	end,
	keyPress = function(self, player, key)
		if key == "space" then
			if player.falling then
				player.jetpack_enabled = true
			end
		end
	end,
	
})