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

local function grassTileUpdate(grasstype, world, x, y)
	local function isGrass(tx, ty)
		return (world:getTile(tx, ty) == grasstype)
	end
	local function isAir(tx, ty)
		local tile = world:getTile(tx, ty)
		if tile == tilelist.AIR.id then return true end
		if tilemanager:tileHasTag(tile, "fakeemtpy") then return true end
		local data = tilemanager:getByID(tile)
		if data.solid == false then return true end
		return false
	end

	local planetop = isAir(x, y-1)
	local planebottom = isAir(x, y+1)
	local planeleft = isAir(x-1, y)
	local planeright = isAir(x+1, y)

	local airtl = isAir(x-1, y-1)
	local airbl = isAir(x-1, y+1)
	local airtr = isAir(x+1, y-1)
	local airbr = isAir(x+1, y+1)

	local gabove = isGrass(x, y-1)
	local gbelow = isGrass(x, y+1)
	local gleft = isGrass(x-1, y)
	local gright = isGrass(x+1, y)

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

local function grassTileLayeredRender(grasstype, grasscolor, x, y, state, dmg)
	if type(state) == "string" then
		state = 0
	end

	local function obit(num, bitindex)
		return bit.band(bit.rshift(num, bitindex), 1) == 1 and true or false
	end

	if not statelistings[grasstype] then statelistings[grasstype] = {} end
	if statelistings[grasstype][state] ~= nil then
		return statelistings[grasstype][state]
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

		texturetable[1] = {"soil", 0, {0.45, 0.25, 0.1}}

		if planetop    then table.insert(texturetable, {"gas_patch", 0, grasscolor}) end
		if planeright  then table.insert(texturetable, {"gas_patch", 90, grasscolor}) end
		if planebottom then table.insert(texturetable, {"gas_patch", 180, grasscolor}) end
		if planeleft   then table.insert(texturetable, {"gas_patch", 270, grasscolor}) end

		if cornera then table.insert(texturetable, {"gas_corner", 0, grasscolor}) end
		if cornerb then table.insert(texturetable, {"gas_corner", 90, grasscolor}) end
		if cornerc then table.insert(texturetable, {"gas_corner", 180, grasscolor}) end
		if cornerd then table.insert(texturetable, {"gas_corner", 270, grasscolor}) end

		statelistings[grasstype][state] = texturetable


		return texturetable
	end
end

newtile("GRASS", {
	color = {1, 1, 1},
	randomupdate = grassCheck,
	tileupdate = function(world, x, y)
		grassTileUpdate(tilelist.GRASS.id, world, x, y)
	end,
	layeredRender = function(x, y, state, dmg)
		return grassTileLayeredRender(tilelist.GRASS.id, {0.2, 0.95, 0.2}, x, y, state, dmg)
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
		grassTileUpdate(tilelist.BLUE_GRASS.id, world, x, y)
	end,
	layeredRender = function(x, y, state, dmg)
		return grassTileLayeredRender(tilelist.BLUE_GRASS.id, {0, 0, 1}, x, y, state, dmg)
	end,
	tags = {"plantable-on"},
	drop = "DIRT_TILE",
})
