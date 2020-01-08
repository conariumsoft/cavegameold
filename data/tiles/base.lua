local function stoneTile(variantname, color)
	newtile(variantname, {
		color = color,
		texture = "stone",
		hardness = 3,
	})
end

local function brickTile(variantname, color)
	newtile(variantname, {
		color = color,
		texture = "brick",
		hardness = 4,
	})
end

newtile("VOID", {color = {0, 0, 0, 1}, id = -1, solid = false, collide = false})
newtile("AIR", {color = {0.8, 0.8, 0.8}, texture = "blank", id = 0, light = -1, absorb = 0, solid = false, collide = false})

newtile("DIRT", {
	absorb = 0.15,
	color = {0.45, 0.25, 0.1},
	texture = "soil",
	tags = {"plantable-on"},
	hardness = 1,
})

newtile("GLASS", {
	texture = "glass",
	color = {1, 1, 1},
	hardness = 3,
	light = -1,
	absorb = 0,
})

newtile("SOFT_CLAY", {
	color = {0.5, 0.25, 0.2},
	texture = "soil",
	hardness = 1,
})

newtile("MUD", {
	absorb = 0.15,
	color = {0.35, 0.15, 0.05},
	texture = "soil",
	tags = {"plantable-on"},
	hardness = 1,
})

newtile("SAND", {
	texture = "soil",
	color = {0.7, 0.7, 0.3},
	hardness = 1,
	tileupdate = function(world, x, y)
		if world:getTile(x, y+1) == 0 then
			world:setTile(x, y, 0)
			world:setTile(x, y+1, tilelist.SAND.id)
		end
	end,
})

local function torchValid(world, x, y)
	if isSolid(world:getTile(x, y+1)) then
		return true
	end
	if world:getBackground(x, y) ~= 0 then
		return true
	end
	return false
end

newtile("TORCH", {
	color = {0.9, 0.9, 0.2},
	solid = false,
	collide = false,
	animation = {
		[1] = "torch_a",
		[2] = "torch_b",
		[3] = "torch_c",
		[4] = "torch_d",
	},
	light = {1.5, 1.5, 1.25},
	tags = {"fakeempty"},
	tileupdate = function(world, x, y)
		if not torchValid(world, x, y) then
			world:setTile(x, y, tilelist.AIR.id, true)
		end
	end,
	validplacement = torchValid,
	hardness = 1,
})

newtile("RED_TORCH", {
	color = {0.9, 0.2, 0.2},
	solid = false,
	collide = false,
	animation = {
		[1] = "torch_a",
		[2] = "torch_b",
		[3] = "torch_c",
		[4] = "torch_d",
	},
	light = {1.5, 0, 0},
	tags = {"fakeempty"},
	tileupdate = function(world, x, y)
		if not torchValid(world, x, y) then
			world:setTile(x, y, tilelist.AIR.id, true)
		end
	end,
	validplacement = torchValid,
	hardness = 1,
})

newtile("BLUE_TORCH", {
	color = {0.2, 0.2, 0.9},
	solid = false,
	collide = false,
	animation = {
		[1] = "torch_a",
		[2] = "torch_b",
		[3] = "torch_c",
		[4] = "torch_d",
	},
	light = {0, 0, 1.5},
	tags = {"fakeempty"},
	tileupdate = function(world, x, y)
		if not torchValid(world, x, y) then
			world:setTile(x, y, tilelist.AIR.id, true)
		end
	end,
	validplacement = torchValid,
	hardness = 1,
})

newtile("GREEN_TORCH", {
	color = {0.2, 0.9, 0.2},
	solid = false,
	collide = false,
	animation = {
		[1] = "torch_a",
		[2] = "torch_b",
		[3] = "torch_c",
		[4] = "torch_d",
	},
	tags = {"fakeempty"},
	light = {0, 1.5, 0},
	tileupdate = function(world, x, y)
		if not torchValid(world, x, y) then
			world:setTile(x, y, tilelist.AIR.id, true)
		end
	end,
	validplacement = torchValid,
	hardness = 1,
})

local function ropeValid(world, x, y)
	if not (isSolid(world:getTile(x, y-1)) or world:getTile(x, y-1)==tilelist.ROPE.id) then
		return false
	end
	return true
end

newtile("ROPE", {
	solid = false,
	collide = true,
	tags = {"rope"},
	texture = "rope",
	absorb = 0,
	tileupdate = function(world, x, y)
		if not ropeValid(world, x, y) then
			world:setTile(x, y, tilelist.AIR.id, true)
		end
	end,
	customCollision = function(entity, separation, normal)
		if entity:isA("Player") then

			entity.touchingrope = true

		end
	end,
	validplacement = ropeValid,
	hardness = 1,
})

newtile("PLANK", {
	texture = "plank",
	color = {0.7, 0.5, 0.2},
	hardness = 3,
	tags = {"plank"}
})

newtile("PINE_PLANK", {
	texture = "plank",
	color = {0.7, 0.4, 0.1},
	hardness = 2,
	tags = {"plank"}
})

newtile("PLATFORM", {
	texture = "platform",
	color = {0.7, 0.5, 0.2},
	solid = false,
	collide = true,
	absorb = 0,
	tags = {"platformtile"}
})

newtile("STONE_PLATFORM", {
	texture = "supported_platform",
	color = {0.6, 0.6, 0.6},
	solid = false,
	collide = true,
	absorb = 0,
	tags = {"platformtile"}
})

stoneTile("STONE", {  1,   1,    1})
stoneTile("HARD_CLAY", {0.9, 0.7, 0.7})

newtile("SANDSTONE", {
	color = {0.8, 0.6, 0.3},
	texture = "sandstone",
	hardness = 2.5,

})

newtile("OBSIDIAN", {
	texture = "stone",
	color = {0.2, 0.2, 0.3},
	hardness = 10,
})

newtile("HELLROCK", {
	texture = "hellrock",
	color = {1,1,1},
	hardness = 5,
	absorb = 0.1,
})

newtile("TIMELESS_BRICK", {
	texture = "brick",
	color = {1, 1, 1},
	hardness = math.huge

})

local grid = require("src.grid")


--[[local pot_drops = {
	itemlist.TORCH.id,
	itemlist.GLOWSTICK.id,
	itemlist.BULLET.id,
	itemlist.ROPE_TILE.id,
	itemlist.IRON_ORE_TILE.id,
	itemlist.COPPER_ORE_TILE.id,

}]]

-- TODO: make pot drop various items from a set

newtile("POT", {
	texture = "pot",
	color = {1,1,1},
	hardness = 1,
	solid = false,
	collide = true,
	customCollision = function(entity, separation, normal)
		if not entity:isA("Player") then return end

		if not separation then return end
		if not normal then return end
            
		if separation.x and separation.y and normal.x and normal.y then
			local tx, ty = grid.pixelToTileXY(entity.position.x, entity.position.y)

			for dx = -1, 1 do
				for dy = -1, 1 do
					if entity.world:getTile(tx+dx, ty+dy) == tilelist.POT.id then
						entity.world:setTile(tx+dx, ty+dy, tilelist.AIR.id, false)
						-- TODO: this
						--local fag = entity.world:addEntity("itemstack")
						--fag:teleport(entity.position)
						--fag.id = pot_drops[math.random(#pot_drops)]
						--fag.amount = math.random(1, 10)
					end
				end
			end
        end
    end,
})

brickTile("GRAY_BRICK",   {0.6, 0.6, 0.6}) -- STONE
brickTile("YELLOW_BRICK", {0.8, 0.7, 0.35}) -- SANDSTONE
brickTile("RED_BRICK",    {0.9, 0.5, 0.5}) -- CLAY
brickTile("DARK_BRICK",   {0.2, 0.2, 0.2})
brickTile("WHITE_BRICK",  {  1,   1,   1})
brickTile("MUD_BRICK", {0.4, 0.2, 0.1})
newtile("MOSSY_GRAY_BRICK", {
	texture = "mossybrick",
	hardness = 3,
	color = {0.6, 0.6, 0.6},
})

newtile("CHISELED_STONE", {
	texture = "chiseled_stone",
	hardness = 3,
	color = {0.6, 0.6, 0.6},
})

local function oretile(name, color, hardness)
	newtile(name, {
		texture = "ore",
		color = color,
		hardness = hardness,
	})
end


oretile("IRON_ORE", {1, 0.8, 0.8}, 5)
oretile("COPPER_ORE", {1, 0.45, 0}, 3)
oretile("LEAD_ORE", {0.35, 0.35, 0.45}, 3)
oretile("SILVER_ORE", {1,1,1}, 4)
oretile("PALLADIUM_ORE", {0.9, 0.5, 0.9}, 6)
oretile("CHROMIUM_ORE", {0.5, 1, 1}, 6)
oretile("GOLD_ORE", {1,1,0.5}, 3)
oretile("TIN_ORE", {0.6, 0.4, 0.4}, 4)
oretile("ALUMINIUM_ORE", {0.9, 0.9, 0.9}, 5)
oretile("NICKEL_ORE", {1, 0.5, 0.5}, 6)
oretile("VANADIUM_ORE", {0.5, 1, 0.8}, 6)
oretile("COBALT_ORE", {0.3, 0.3, 1}, 8)
oretile("TITANIUM_ORE", {0.6, 0.6, 0.6}, 8)
oretile("URANIUM_ORE", {0.6, 1, 0.6}, 12)
tilelist.URANIUM_ORE.light = {0, 0.2, 0}