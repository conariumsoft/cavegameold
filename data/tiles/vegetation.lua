
local function saplinggrow(world, x, y)
	
	local maketree = require("data.structures.trees.maketree")

	local state = world:getTileState(x, y)+1

	if state > 8 then
		maketree(world, x, y+1)
		
	else
		world:setTileState(x, y, state)
	end
end

local function plantValidityCheck(world, x, y)
	if tilemanager:tileHasTag(world:getTile(x, y+1), "plantable-on") then
		return true
	end
	return false
end

local function supports_log(tileid)
	if tileid == tilelist.LOG.id then return true end
	if tileid == tilelist.ROOT.id then return true end
end

local function logValidCheck(world, x, y)

	local below = supports_log(world:getTile(x, y+1))

	if not below then
		world:setTile(x, y, tilelist.AIR.id, true)
	end
end

local function supports_pinelog(tileid)
	if tileid == tilelist.PINE_LOG.id then return true end
	if tileid == tilelist.PINE_ROOT.id then return true end
end

local function pineLogValidCheck(world, x, y)
	local below = supports_pinelog(world:getTile(x, y+1))


	if not below then world:setTile(x, y, tilelist.AIR.id, true) end
end

local function leavesRandomUpdate(world, x, y)
	local die = true

	for dx = -4, 4 do
		for dy = -4, 4 do
			if world:getTile(x+dx, y+dy) == tilelist.LOG.id then
				die = false
			end
		end
	end

	if die then
		world:setTile(x, y, tilelist.AIR.id)
	end
end

local function pine_leavesRandomUpdate(world, x, y)
	local die = true

	for dx = -6, 6 do
		for dy = -6, 6 do
			if world:getTile(x+dx, y+dy) == tilelist.PINE_LOG.id then
				die = false
			end
		end
	end

	if die then
		world:setTile(x, y, tilelist.AIR.id)
	end
end

newtile("OVERGROWTH", {
	color = {0.2, 0.8, 0.2},
	randomupdate = function(world, x, y) end,
	tags = {"plant", "fakeempty"},
	drop = false,
	hardness = 0.25,
	absorb = 0,
	solid = false,
	texture = "overgrowth1",
	animation = {
		[1] = "overgrowth1",
		[2] = "overgrowth2",
		[3] = "overgrowth1",
		[3] = "overgrowth3",
	},
	animationspeed = 1,
	collide = false,
	tileupdate = function(world, x, y)
		if world:getTile(x, y+1) ~= tilelist.GRASS.id then
			world:setTile(x, y, tilelist.AIR.id, false)
		end
	end
})

newtile("CRYING_LILY", {
	color = {1,1,1},
	hardness = 1,
	absorb = 0,
	randomupdate = function(world, x, y) end,
	tags = {"plant", "fakeempty"},
	drop = "CRYING_LILY",
	texture = "blue_flower",
	light = {0, 0.2, 0.2},
	solid = false,
	collide = false,
	tileupdate = function(world, x, y)
		if world:getTile(x, y+1) ~= tilelist.GRASS.id then
			world:setTile(x, y, tilelist.AIR.id, false)
		end
	end
})

newtile("VINE", {
	color = {0.2, 0.8, 0.2},
	hardness = 0.25,
	texture = "vine",
	randomupdate = function(world, x, y)
		if world:getTile(x, y+1) == tilelist.AIR.id then
			world:setTile(x, y+1, tilelist.VINE.id)
		end
	end,
	tags = {"plant", "fakeempty"},
	drop = false,
	solid = false,
	collide = false,
	tileupdate = function(world, x, y)
		local above = world:getTile(x, y-1) 
		if above ~= tilelist.VINE.id and above ~= tilelist.GRASS.id then
			world:setTile(x, y, tilelist.AIR.id, false)
		end
	end
})

newtile("LOG", {
	color = {0.6, 0.4, 0.1},
	solid = true,
	collide = false,
	texture = "log",
	absorb = 0,
	tileupdate = logValidCheck,
	drop = "PLANK_TILE",
	hardness = 8,
	tags = {"LOG"}
})

newtile("PINE_LOG", {
	color = {0.45, 0.25, 0.1},
	solid = true,
	collide = false,
	texture = "log",
	absorb = 0,
	tileupdate = pineLogValidCheck,
	drop = "PINE_PLANK_TILE",
	hardness = 8,
	tags = {"LOG"}
})

newtile("LEAVES", {
	color = {0.2, 0.8, 0.2},
	solid = false,
	collide = false,
	absorb = 0,
	texture = "leaves",
	randomupdate = leavesRandomUpdate,
	hardness = 1,
	drop = "SAPLING_TILE"
})

newtile("PINE_LEAVES", {
	color = {0.0, 0.2, 0.0},
	solid = false,
	collide = false,
	absorb = 0,
	texture = "leaves",
	randomupdate = pine_leavesRandomUpdate,
	hardness = 1,
	drop = "SAPLING_TILE"
})

-- ? what is the purpose of this tile
newtile("DEAD_LEAVES", {
	color = {0.6, 0.7, 0.1},
	solid = false,
	collide = false,
	texture = "leaves",
	--randomupdate = leavesRandomUpdate,
})
-- IDEA: dead leaves

newtile("ROOT", {
	color = {0.6, 0.4, 0.1},
	solid = true,
	collide = false,
	texture = "root",
	drop = "PLANK_TILE",
	hardness = 8,
	tags = {"LOG"}
})

newtile("ROOT_LEFT", {
	collide = false,
	texture = "root_left",
	color = {0.6, 0.4, 0.1},
	hardness = 8,
	drop = "PLANK_TILE", 
	tileupdate = function(world, x, y)
		if world:getTile(x+1, y) ~= tilelist.ROOT.id then
			world:setTile(x, y, tilelist.AIR.id, true)
		end
	end,
})

newtile("ROOT_RIGHT", {
	collide = false,
	texture = "root_right",
	color = {0.6, 0.4, 0.1},
	hardness = 8,
	drop = "PLANK_TILE",
	tileupdate = function(world, x, y)
		if world:getTile(x-1, y) ~= tilelist.ROOT.id then
			world:setTile(x, y, tilelist.AIR.id, true)
		end
	end,
})

newtile("SAPLING", {
	texture = "sapling",
	color = {1,1,1},
	solid = false,
	collide = false,
	tileupdate = function(world, x, y)
		if not plantValidityCheck(world, x, y) then
			world:setTile(x, y, tilelist.AIR.id, true)
		end
	end,
	randomupdate = saplinggrow,
	validplacement = plantValidityCheck,
	tags = {"plant"},
	hardness = 1,
})

newtile("PINE_ROOT", {
	color = {0.45, 0.25, 0.1},
	solid = true,
	collide = false,
	texture = "root",
	drop = "PLANK_TILE",
	hardness = 8,
	tags = {"PINE_LOG"}
})

newtile("PINE_ROOT_LEFT", {
	collide = false,
	texture = "root_left",
	color = {0.45, 0.25, 0.1},
	hardness = 8,
	drop = "PLANK_TILE", 
	tileupdate = function(world, x, y)
		if world:getTile(x+1, y) ~= tilelist.ROOT.id then
			world:setTile(x, y, tilelist.AIR.id, true)
		end
	end,
})

newtile("PINE_ROOT_RIGHT", {
	collide = false,
	texture = "root_right",
	color = {0.45, 0.25, 0.1},
	hardness = 8,
	drop = "PLANK_TILE",
	tileupdate = function(world, x, y)
		if world:getTile(x-1, y) ~= tilelist.ROOT.id then
			world:setTile(x, y, tilelist.AIR.id, true)
		end
	end,
})

newtile("MUSHROOM_PSILOCYN", {
	texture = "purple_mushroom",
	light = {0.1, 0.6, 1},
	absorb = 0,
	solid = false,
	collide = false,
	tags = {"plant", "fakeempty"},
	tileupdate = function(world, x, y)
		if not plantValidityCheck(world, x, y) then
			world:setTile(x, y, tilelist.AIR.id, true)
		end
	end,
})

newtile("RED_MUSHROOM", {
	texture = "red_mushroom",
	absorb = 0,
	solid = false,
	collide = false,
	tags = {"plant", "fakeempty"},
	tileupdate = function(world,x, y)

	end
})

newtile("CACTUS", {
	absorb = 0,
	texture = "cactus",
	randomupdate = function(world, x, y)
		if math.random() > 1 then return end

		local above = world:getTile(x, y-1)
		
		if above == tilelist.AIR.id then
			local rand = math.random()
			if rand > 0.3 then
				world:setTile(x, y-1, tilelist.CACTUS.id)
			else
				world:setTile(x, y-1, tilelist.FLOWERING_CACTUS.id)
			end
		end
	end,
	tileupdate = function(world, x, y)
		-- if tile below isn't sand or cactus, then break
		local below = world:getTile(x, y+1)

		if below ~= tilelist.SAND.id and below ~= tilelist.CACTUS.id then
			world:setTile(x, y, tilelist.AIR.id, true)
		end
	end
})

newtile("FLOWERING_CACTUS", {
	absorb = 0,
	texture = "cactus_flowering",
	light = {0, 0, 0.5},
	tileupdate = function(world, x, y)
		-- if tile below isn't sand or cactus, then break
		local below = world:getTile(x, y+1)

		if below ~= tilelist.SAND.id and below ~= tilelist.CACTUS.id then
			world:setTile(x, y, tilelist.AIR.id, true)
		end
	end
})