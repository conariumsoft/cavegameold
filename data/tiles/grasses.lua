local statelistings = {}

local bit = require("bit")

local function grassCheck(world, x, y)

	local stayalive = adjacentToNonSolidTile(world, x, y)

	if not stayalive then world:setTile(x, y, tilelist.DIRT.id) return end

	if world:getTile(x, y-1) == tilelist.AIR.id then
		local poss = math.random()
		if poss > 0.95 then	
			world:setTile(x, y-1, tilelist.CRYING_LILY.id)
		elseif poss > 0.5 then
			world:setTile(x, y-1, tilelist.OVERGROWTH.id)
		end
	end

	if world:getTile(x, y+1) == tilelist.AIR.id then
		local poss = math.random()
		if poss > 0.90 then	
			world:setTile(x, y+1, tilelist.VINE.id)
		end
	end

	-- spreading onto dirt
	for dx = -1, 1 do
		for dy = -1, 1 do
			if world:getTile(x+dx, y+dy) == tilelist.DIRT.id and adjacentToNonSolidTile(world, x+dx, y+dy) then
				world:setTile(x+dx, y+dy, tilelist.GRASS.id)
			end
		end
	end
end

local function bluegrassCheck(world, x, y)
	local stayalive = adjacentToNonSolidTile(world, x, y)

	if not stayalive then world:setTile(x, y, tilelist.MUD.id) return end

	-- spreading onto dirt
	for dx = -1, 1 do
		for dy = -1, 1 do
			if world:getTile(x+dx, y+dy) == tilelist.MUD.id and adjacentToNonSolidTile(world, x+dx, y+dy) then
				world:setTile(x+dx, y+dy, tilelist.BLUE_GRASS.id)
			end
		end
	end

	-- grow psilocyn mushrooms on top
	if world:getTile(x, y-1) == tilelist.AIR.id then
		if math.random() > 0.75 then
			world:setTile(x, y-1, tilelist.MUSHROOM_PSILOCYN.id)
		end
	end
end

local function mossy_stone_check(stonetype, world, x, y)
	local stayalive = adjacentToNonSolidTile(world, x, y)

	if not stayalive then world:setTile(x, y, tilelist.STONE.id) return end

	for dx = -1, 1 do
		for dy = -1, 1 do
			if world:getTile(x+dx, y+dy) == tilelist.STONE.id and adjacentToNonSolidTile(world, x+dx, y+dy) then
				world:setTile(x+dx, y+dy, stonetype)
			end
		end

	end

	if world:getTile(x, y+1) == tilelist.AIR.id then
		if math.random() > 0.99 then
			world:setTile(x, y+1, tilelist.VINE.id)
		end
	end
end

local function jbit(t)
	local ret = 0
	local bitfieldlen = #t

	for i  = bitfieldlen, 1, -1 do
		local exponent = 2^(i-1)
		local bitval = (t[i] == true) and 1 or 0
		ret = ret + (bitval*exponent)
	end
	return ret
end

local function bitmask_tile_update(tiletype, world, x, y)

	local function is_tile(tile, tx, ty)
		return world:getTile(tx, ty) == tile
	end

	local function is_empty(tx, ty)
		local tile = world:getTile(tx, ty)
		if tile == tilelist.AIR.id then return true end
		if tilemanager:tileHasTag(tile, "fakeempty") then return true end
		local data = tilemanager:getByID(tile)
		if data.solid == false then return true end
		return false
	end


	local planetop = is_empty(x, y-1)
	local planebottom = is_empty(x, y+1)
	local planeleft = is_empty(x-1, y)
	local planeright = is_empty(x+1, y)

	local airtl = is_empty(x-1, y-1)
	local airbl = is_empty(x-1, y+1)
	local airtr = is_empty(x+1, y-1)
	local airbr = is_empty(x+1, y+1)

	local gabove = is_tile(tiletype, x, y-1)
	local gbelow = is_tile(tiletype, x, y+1)
	local gleft = is_tile(tiletype, x-1, y)
	local gright = is_tile(tiletype, x+1, y)

	local cornera = (gleft == true and gabove == true and airtl == true)
	local cornerb = (gright == true and gabove == true and airtr == true)
	local cornerc = (gright == true and gbelow == true and airbr == true)
	local cornerd = (gleft == true and gbelow == true and airbl == true)

	local bitmask = jbit({planetop, planeleft, planebottom, planeright, cornera, cornerb, cornerc, cornerd })
	
	-- for testing

	if world:getTileState(x, y) ~= bitmask then
		world:setTileState(x, y, bitmask)
	end
end

local function obit(num, bitindex)
	return bit.band(bit.rshift(num, bitindex), 1) == 1 and true or false
end

local function tile_layered_render(tiletype, basetexture, basecolor, grasscolor, x, y, state, dmg)
	if type(state) == "string" then
		state = 0
	end

	if not statelistings[tiletype] then statelistings[tiletype] = {} end
	if statelistings[tiletype][state] ~= nil then
		return statelistings[tiletype][state]
	else
		local planetop 	  = obit(state, 0)
		local planeleft   = obit(state, 1)
		local planebottom = obit(state, 2)
		local planeright  = obit(state, 3)
		local cornera 	  = obit(state, 4)
		local cornerb 	  = obit(state, 5)
		local cornerc 	  = obit(state, 6)
		local cornerd 	  = obit(state, 7)

		local texturetable = {}

		texturetable[1] = {basetexture, 0, basecolor}


		if planetop    then table.insert(texturetable, {"gas_patch", 0, grasscolor}) end
		if planeright  then table.insert(texturetable, {"gas_patch", 90, grasscolor}) end
		if planebottom then table.insert(texturetable, {"gas_patch", 180, grasscolor}) end
		if planeleft   then table.insert(texturetable, {"gas_patch", 270, grasscolor}) end

		if cornera then table.insert(texturetable, {"gas_corner", 0, grasscolor}) end
		if cornerb then table.insert(texturetable, {"gas_corner", 90, grasscolor}) end
		if cornerc then table.insert(texturetable, {"gas_corner", 180, grasscolor}) end
		if cornerd then table.insert(texturetable, {"gas_corner", 270, grasscolor}) end

		statelistings[tiletype][state] = texturetable

		return texturetable
	end
end

newtile("GRASS", {
	color = {1, 1, 1},
	randomupdate = grassCheck,
	tileupdate = function(world, x, y)
		bitmask_tile_update(tilelist.GRASS.id, world, x, y)
	end,
	layeredRender = function(x, y, state, dmg)
		return tile_layered_render(tilelist.GRASS.id, "soil", {0.45, 0.25, 0.1}, {0.2, 0.95, 0.2}, x, y, state, dmg)
	end,
	tags = {"plantable-on", "grass"},
	drop = "DIRT_TILE",
	texture = "soil",
})

newtile("BLUE_GRASS", {
	color = {0.2, 0.25, 0.9},
	texture = "soil",
	light = {0.2, 0.4, 0.6},
	absorb = 0.1,
	randomupdate = bluegrassCheck,
	tileupdate = function(world, x, y)
		bitmask_tile_update(tilelist.BLUE_GRASS.id, world, x, y)
	end,
	layeredRender = function(x, y, state, dmg)
		return tile_layered_render(tilelist.BLUE_GRASS.id, "soil", {0.45, 0.25, 0.1}, {0, 0, 1}, x, y, state, dmg)
	end,
	tags = {"plantable-on"},
	drop = "DIRT_TILE",
})

newtile("MOSSY_STONE", {
	color = {0.6, 0.6, 0.6},
	texture = "stone",
	drop = "STONE_TILE",
	randomupdate = function(world, x, y)
		mossy_stone_check(tilelist.MOSSY_STONE.id, world, x, y)
	end,
	tileupdate = function(world, x, y)
		bitmask_tile_update(tilelist.MOSSY_STONE.id, world, x, y)
	end,
	layeredRender = function(x, y, state, dmg)
		return tile_layered_render(tilelist.MOSSY_STONE.id, "stone", {0.6, 0.6, 0.6}, {0.05, 0.5, 0.05}, x, y, state, dmg)
	end,

})

newtile("YELLOW_MOSS_STONE", {
	color = {0.6, 0.6, 0.6},
	texture = "stone",
	drop = "STONE_TILE",
	randomupdate = function(world, x, y)
		mossy_stone_check(tilelist.YELLOW_MOSS_STONE.id, world, x, y)
	end,
	tileupdate = function(world, x, y)
		bitmask_tile_update(tilelist.YELLOW_MOSS_STONE.id, world, x, y)
	end,
	layeredRender = function(x, y, state, dmg)
		return tile_layered_render(tilelist.YELLOW_MOSS_STONE.id, "stone", {0.6, 0.6, 0.6}, {0.35, 0.4, 0}, x, y, state, dmg)
	end,

})
