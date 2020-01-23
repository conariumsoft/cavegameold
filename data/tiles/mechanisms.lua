local jutils = require("src.jutils")
local config = require("config")
local bit 	 = require("bit")

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

local function obit(num, bitindex)
	return bit.band(bit.rshift(num, bitindex), 1) == 1 and true or false
end

local function is_wireable(world, x, y)
	local t = world:getTile(x, y)

	if t == tilelist.WIRE.id 				then return true end
	if t == tilelist.PRESSURE_PLATE.id 		then return true end
	if t == tilelist.TNT.id 				then return true end
	if t == tilelist.TOGGLE_BRICK.id 		then return true end
	if t == tilelist.SOLID_TOGGLE_BRICK.id 	then return true end
	if t == tilelist.LAMP.id 				then return true end
	if t == tilelist.POWERED_LAMP.id 		then return true end
	if t == tilelist.AND_GATE.id 			then return true end
	if t == tilelist.SWITCH.id 		 		then return true end
	if t == tilelist.OR_GATE.id 			then return true end
	if t == tilelist.INVERTER.id 			then return true end
	if t == tilelist.XOR_GATE.id 			then return true end
	if t == tilelist.BUFFER.id 				then return true end
	if t == tilelist.XAND_GATE.id 			then return true end
	if t == tilelist.NOR_GATE.id 			then return true end

	return false
end

local function is_wire(world, x, y)
	return world:getTile(x, y) == tilelist.WIRE.id
end

local function is_wire_powered(world, x, y)
	local state = world:getTileState(x, y)

	if state == -1 then return false end
	if state == -2 then return true end
	return obit(state, 4)
end

local function is_tile_powered(world, x, y)
	if is_wire_powered(world, x, y) == true then return true end



	return false
end

local function propagatePower(world, x, y)
	if is_wire(world, x, y) == true and is_wire_powered(world, x, y) == false then
		world:setTileState(x, y, -2)
		propagatePower(world, x+1, y)
		propagatePower(world, x-1, y)
		propagatePower(world, x, y+1)
		propagatePower(world, x, y-1)
		return
	end

	local t = world:getTile(x, y)

	if t == tilelist.TNT.id then
		world:setTileState(x, y, 1)
	end

	if t == tilelist.SOLID_TOGGLE_BRICK.id then
		world:setTile(x, y, tilelist.TOGGLE_BRICK.id)
	end

	if t == tilelist.LAMP.id then
		world:setTile(x, y, tilelist.POWERED_LAMP.id)
	end

	if t == tilelist.BUFFER.id then
		world:setTileState(x, y, 100)
	end
end

local function dePower(world, x, y)
	local t = world:getTile(x, y)

	if t == tilelist.WIRE.id and is_wire_powered(world, x, y) == true then
		world:setTileState(x, y, -1)
		dePower(world, x+1, y)
		dePower(world, x-1, y)
		dePower(world, x, y+1)
		dePower(world, x, y-1)
	end

	if t == tilelist.POWERED_LAMP.id then
		world:setTile(x, y, tilelist.LAMP.id)
	end

	if t == tilelist.TOGGLE_BRICK.id then
		world:setTile(x, y, tilelist.SOLID_TOGGLE_BRICK.id)
	end
end

newtile("LAMP", {
	texture = "weird",
	color = {0.5, 0.2, 0.2},
	hardness = 3,
	solid = true,
})

newtile("POWERED_LAMP", {
	texture = "weird",
	color = {1, 1, 0.6},
	hardness = 3,
	solid = true,
	light = {1.5, 1.5, 1.5},

})

newtile("TOGGLE_BRICK", {
	texture = "brick",
	color = {0.3, 0.3, 0.3},
	hardness = 3,
	solid = false,
	collide = false,

})

newtile("SOLID_TOGGLE_BRICK", {
	texture = "brick",
	color = {0.8, 0.8, 0.8},
	hardness = 3,

})

newtile("PRESSURE_PLATE", {
	solid = false,
	collide = true,
	texture = "pressure_plate",
	color = {0.85, 0.85, 0.85},
	absorb = 0,
	customCollision = function(entity, separation, normal, pos, state)
		local world = entity.world

		world:setTileState(pos.x, pos.y, 20)
	end,
	customRenderLogic = function(tx, ty, state, damage)
		if state > 0 then
			return "pressure_plate", {0.5, 0.5, 0.5}, 0
		else
			return "pressure_plate", {0.85, 0.85, 0.85}, 0
		end
	end,
	onbreak = function(world, x, y)
		for dx = -1, 1 do
			for dy = -1, 1 do
				local t = world:getTile(x+dx, y+dy)

				if t == tilelist.WIRE.id then
					dePower(world, x+dx, y+dy)
				end
			end
		end
	end,
	tileupdate = function(world, x, y)
		if world:getTileState(x, y) > 0 then
			
			propagatePower(world, x+1, y)
			propagatePower(world, x-1, y)
			propagatePower(world, x, y+1)
			propagatePower(world, x, y-1)

			world:setTileState(x, y, world:getTileState(x, y)-1)
		else
			dePower(world, x, y+1)
			dePower(world, x+1, y)
			dePower(world, x-1, y)
			dePower(world, x, y-1)
		end
	end,
})

local wirestatelisting = {}

newtile("WIRE", {
	texture = "wire",
	tags = {"mechanism", "power_source"},
	solid = false,
	collide = false,
	absorb = 0,
	tileupdate = function(world, x, y)
		--propagatePower(world, x, y)

		local state = world:getTileState(x, y)
		local powered = false
		if state == -1 then

		elseif state == -2 then
			powered = true
		else
			powered = is_wire_powered(world, x, y)
		end

		local function is_wire(tx, ty)
			return is_wireable(world, tx, ty)
		end

		local wire_left = is_wire(x-1, y)
		local wire_right = is_wire(x+1, y)
		local wire_above = is_wire(x, y-1)
		local wire_below = is_wire(x, y+1)
		
		local bitmask = jbit{wire_above, wire_left, wire_below, wire_right, powered}
		
		
		if world:getTileState(x, y) ~= bitmask then
			world:setTileState(x, y, bitmask)
		end
	end,

	layeredRender = function(tx, ty, state, damage)
		if wirestatelisting[state] ~= nil then
			return wirestatelisting[state]
		else
			local wiretop = obit(state, 0)
			local wireleft = obit(state, 1)
			local wirebottom = obit(state, 2)
			local wireright = obit(state, 3)
			local powered = obit(state, 4)

			local textable = {}

			local color = (powered == true) and {1, 1, 1} or {0.25, 0.25, 0.25}

			textable[1] = {"wire_base", 0, color}

			if wiretop then table.insert(textable, {"wire", 0, color}) end
			if wireleft then table.insert(textable, {"wire", 270, color}) end
			if wirebottom then table.insert(textable, {"wire", 180, color}) end
			if wireright then table.insert(textable, {"wire", 90, color}) end

			wirestatelisting[state] = textable

			return textable

		end
	end,
})

newtile("SWITCH", {
	texture = "switch",
	tags = {"mechanism"},
	onbreak = function(world, x, y)
		for dx = -1, 1 do
			for dy = -1, 1 do
				local t = world:getTile(x+dx, y+dy)

				if t == tilelist.WIRE.id then
					dePower(world, x+dx, y+dy)
				end
			end
		end
	end,
	tileupdate = function(world, x, y)
		
		if world:getTileState(x, y) == 1 then
			propagatePower(world, x+1, y)
			propagatePower(world, x-1, y)
			propagatePower(world, x, y+1)
			propagatePower(world, x, y-1)

		else
			dePower(world, x, y+1)
			dePower(world, x+1, y)
			dePower(world, x-1, y)
			dePower(world, x, y-1)
		end
	end,
	playerInteract = function(player, x, y, button)
		if button == 2 then
			local state = player.world:getTileState(x, y)

			player.world:setTileState(x, y, (state == 0) and 1 or 0) -- boolean inverter for all u brainlets out there
		end
	end,

	customRenderLogic = function(tx, ty, state, damage)
		if state == 1 then
			return "switch", {1, 1, 1}, 180
		else
			return "switch", {1,1,1}, 0
		end
	end,
})


local function explodeTNT(world, x, y)
	if world:getTileState(x, y) == 1 then
		local tntradius = 8
		local pos = jutils.vec2.new(x*config.TILE_SIZE, y*config.TILE_SIZE)
		local exp = world:addEntity("explosion", pos, tntradius, tntradius+2, true)
	end
end


newtile("TNT", {
	tags = {"mechanism", "transmitter"},
	texture = "tnt",
	color = {1, 1, 1},
	hardness = 1,
	tileupdate = explodeTNT,
})

newtile("AND_GATE", {
	tags = {"mechanism"},
	texture = "and_gate",
	color = {1,1,1},
	tileupdate = function(world, x, y)
		-- left is input 1
		-- right is input 2
		-- top and bottom are output
		local is_wire_left = is_wire(world, x-1, y) and is_wire_powered(world, x-1, y)

		local is_wire_right = is_wire(world, x+1, y) and is_wire_powered(world, x+1, y)

		if (is_wire_left and is_wire_right) then
			world:setTileState(x, y, 3)
		elseif is_wire_left then
			world:setTileState(x, y, 2)
		elseif is_wire_right then
			world:setTileState(x, y, 1)
		else
			world:setTileState(x, y, 0)
		end
		
		-- both are enabled
		if is_wire_left and is_wire_right then

			propagatePower(world, x, y+1)
			propagatePower(world, x, y-1)
		else
			dePower(world, x, y+1)
			dePower(world, x, y-1)
		end
	end,
	onbreak = function(world, x, y)
		dePower(world, x, y+1)
		dePower(world, x, y-1)
	end,
	layeredRender = function(tx, ty, state, damage)

		if state == 3 then
			return {
				[1] = {"wire", 0, {1, 1, 1}},
				[2] = {"wire", 90, {1, 1, 1}},
				[3] = {"wire", 180, {1, 1, 1}},
				[4] = {"wire", 270, {1, 1, 1}},
				[5] = {"and_gate", 0, {1,1,1}},
			}
		elseif state == 2 then
			return {
				[1] = {"wire", 0, {0.25, 0.25, 0.25}},
				[2] = {"wire", 90, {0.25, 0.25, 0.25}},
				[3] = {"wire", 180, {0.25, 0.25, 0.25}},
				[4] = {"wire", 270, {1, 1, 1}},
				[5] = {"and_gate", 0, {1,1,1}},
			}
		elseif state == 1 then
			return {
				[1] = {"wire", 0, {0.25, 0.25, 0.25}},
				[2] = {"wire", 90, {1, 1, 1}},
				[3] = {"wire", 180, {0.25, 0.25, 0.25}},
				[4] = {"wire", 270, {0.25, 0.25, 0.25}},
				[5] = {"and_gate", 0, {1,1,1}},
			}
		else
			return {
				[1] = {"wire", 0, {0.25, 0.25, 0.25}},
				[2] = {"wire", 90, {0.25, 0.25, 0.25}},
				[3] = {"wire", 180, {0.25, 0.25, 0.25}},
				[4] = {"wire", 270, {0.25, 0.25, 0.25}},
				[5] = {"and_gate", 0, {1,1,1}},
			}
		end
	end,
})

newtile("INVERTER", {
	tags = {"mechanism"},
	texture = "inverter",
	color = {1, 1, 1},
	layeredRender = function(tx, ty, state, damage)
		if state == 1 then
			return {
				[1] = {"wire", 90, {0.5,0.5,0.5}},
				[2] = {"wire", 270, {0.5,0.5,0.5}},
				[3] = {"inverter", 0, {1,1,1}}
			}
		else
			return {
				[1] = {"wire", 90, {1,1,1}},
				[2] = {"wire", 270, {1,1,1}},
				[3] = {"inverter", 0, {1,1,1}}
			}
		end
	end,
	tileupdate = function(world, x, y)

		local is_wire_left = is_wire(world, x-1, y) and is_wire_powered(world, x-1, y)

		if is_wire_left then
			dePower(world, x+1, y)
			world:setTileState(x, y, 1)
		else
			propagatePower(world, x+1, y)
			world:setTileState(x, y, 0)
		end
	end,
	onbreak = function(world, x, y)
		dePower(world, x, y+1)
	end
})


newtile("OR_GATE", {
	tags = {"mechanism"},
	texture = "or_gate",
	color = {1, 1, 1},
	layeredRender = function(tx, ty, state, damage)
		if state == 3 then
			return {
				[1] = {"wire", 0, {1, 1, 1}},
				[2] = {"wire", 90, {1, 1, 1}},
				[3] = {"wire", 180, {1, 1, 1}},
				[4] = {"wire", 270, {1, 1, 1}},
				[5] = {"or_gate", 0, {1,1,1}},
			}
		elseif state == 2 then
			return {
				[1] = {"wire", 0, {0.25, 0.25, 0.25}},
				[2] = {"wire", 90, {0.25, 0.25, 0.25}},
				[3] = {"wire", 180, {0.25, 0.25, 0.25}},
				[4] = {"wire", 270, {1, 1, 1}},
				[5] = {"or_gate", 0, {1,1,1}},
			}
		elseif state == 1 then
			return {
				[1] = {"wire", 0, {0.25, 0.25, 0.25}},
				[2] = {"wire", 90, {1, 1, 1}},
				[3] = {"wire", 180, {0.25, 0.25, 0.25}},
				[4] = {"wire", 270, {0.25, 0.25, 0.25}},
				[5] = {"or_gate", 0, {1,1,1}},
			}
		else
			return {
				[1] = {"wire", 0, {0.25, 0.25, 0.25}},
				[2] = {"wire", 90, {0.25, 0.25, 0.25}},
				[3] = {"wire", 180, {0.25, 0.25, 0.25}},
				[4] = {"wire", 270, {0.25, 0.25, 0.25}},
				[5] = {"or_gate", 0, {1,1,1}},
			}
		end

	end,
	tileupdate = function(world, x, y)
		-- left is input 1
		-- right is input 2
		-- top and bottom are output
		local is_wire_left = is_wire(world, x-1, y) and is_wire_powered(world, x-1, y)

		local is_wire_right = is_wire(world, x+1, y) and is_wire_powered(world, x+1, y)

		if (is_wire_left and is_wire_right) then
			world:setTileState(x, y, 3)
		elseif is_wire_left then
			world:setTileState(x, y, 2)
		elseif is_wire_right then
			world:setTileState(x, y, 1)
		else
			world:setTileState(x, y, 0)
		end
		
		-- both are enabled
		if is_wire_left or is_wire_right then

			propagatePower(world, x, y+1)
			propagatePower(world, x, y-1)
		else
			dePower(world, x, y+1)
			dePower(world, x, y-1)
		end
	end,
	onbreak = function(world, x, y)
		dePower(world, x, y+1)
		dePower(world, x, y-1)
	end,
})


newtile("NOR_GATE", {
	tags = {"mechanism"},
	texture = "xor_gate",
	color = {1, 1, 1},
	layeredRender = function(tx, ty, state, damage)
		if state == 3 then
			return {
				[1] = {"wire", 0, {1, 1, 1}},
				[2] = {"wire", 90, {1, 1, 1}},
				[3] = {"wire", 180, {1, 1, 1}},
				[4] = {"wire", 270, {1, 1, 1}},
				[5] = {"xor_gate", 0, {1,1,1}},
			}
		elseif state == 2 then
			return {
				[1] = {"wire", 0, {0.25, 0.25, 0.25}},
				[2] = {"wire", 90, {0.25, 0.25, 0.25}},
				[3] = {"wire", 180, {0.25, 0.25, 0.25}},
				[4] = {"wire", 270, {1, 1, 1}},
				[5] = {"xor_gate", 0, {1,1,1}},
			}
		elseif state == 1 then
			return {
				[1] = {"wire", 0, {0.25, 0.25, 0.25}},
				[2] = {"wire", 90, {1, 1, 1}},
				[3] = {"wire", 180, {0.25, 0.25, 0.25}},
				[4] = {"wire", 270, {0.25, 0.25, 0.25}},
				[5] = {"xor_gate", 0, {1,1,1}},
			}
		else
			return {
				[1] = {"wire", 0, {0.25, 0.25, 0.25}},
				[2] = {"wire", 90, {0.25, 0.25, 0.25}},
				[3] = {"wire", 180, {0.25, 0.25, 0.25}},
				[4] = {"wire", 270, {0.25, 0.25, 0.25}},
				[5] = {"xor_gate", 0, {1,1,1}},
			}
		end

	end,
	tileupdate = function(world, x, y)
		-- left is input 1
		-- right is input 2
		-- top and bottom are output
		local is_wire_left = is_wire(world, x-1, y) and is_wire_powered(world, x-1, y)

		local is_wire_right = is_wire(world, x+1, y) and is_wire_powered(world, x+1, y)

		if (is_wire_left and is_wire_right) then
			world:setTileState(x, y, 3)
		elseif is_wire_left then
			world:setTileState(x, y, 2)
		elseif is_wire_right then
			world:setTileState(x, y, 1)
		else
			world:setTileState(x, y, 0)
		end
		
		-- both are enabled
		if is_wire_left and is_wire_right then
			dePower(world, x, y+1)
			dePower(world, x, y-1)
		elseif is_wire_left or is_wire_right then
			dePower(world, x, y+1)
			dePower(world, x, y-1)
		else
			propagatePower(world, x, y+1)
			propagatePower(world, x, y-1)
			
		end
	end,
	onbreak = function(world, x, y)
		dePower(world, x, y+1)
		dePower(world, x, y-1)
	end,
})

newtile("XOR_GATE", {
	tags = {"mechanism"},
	texture = "xor_gate",
	color = {1, 1, 1},
	layeredRender = function(tx, ty, state, damage)
		if state == 3 then
			return {
				[1] = {"wire", 0, {1, 1, 1}},
				[2] = {"wire", 90, {1, 1, 1}},
				[3] = {"wire", 180, {1, 1, 1}},
				[4] = {"wire", 270, {1, 1, 1}},
				[5] = {"xor_gate", 0, {1,1,1}},
			}
		elseif state == 2 then
			return {
				[1] = {"wire", 0, {0.25, 0.25, 0.25}},
				[2] = {"wire", 90, {0.25, 0.25, 0.25}},
				[3] = {"wire", 180, {0.25, 0.25, 0.25}},
				[4] = {"wire", 270, {1, 1, 1}},
				[5] = {"xor_gate", 0, {1,1,1}},
			}
		elseif state == 1 then
			return {
				[1] = {"wire", 0, {0.25, 0.25, 0.25}},
				[2] = {"wire", 90, {1, 1, 1}},
				[3] = {"wire", 180, {0.25, 0.25, 0.25}},
				[4] = {"wire", 270, {0.25, 0.25, 0.25}},
				[5] = {"xor_gate", 0, {1,1,1}},
			}
		else
			return {
				[1] = {"wire", 0, {0.25, 0.25, 0.25}},
				[2] = {"wire", 90, {0.25, 0.25, 0.25}},
				[3] = {"wire", 180, {0.25, 0.25, 0.25}},
				[4] = {"wire", 270, {0.25, 0.25, 0.25}},
				[5] = {"xor_gate", 0, {1,1,1}},
			}
		end

	end,
	tileupdate = function(world, x, y)
		-- left is input 1
		-- right is input 2
		-- top and bottom are output
		local is_wire_left = is_wire(world, x-1, y) and is_wire_powered(world, x-1, y)

		local is_wire_right = is_wire(world, x+1, y) and is_wire_powered(world, x+1, y)

		if (is_wire_left and is_wire_right) then
			world:setTileState(x, y, 3)
		elseif is_wire_left then
			world:setTileState(x, y, 2)
		elseif is_wire_right then
			world:setTileState(x, y, 1)
		else
			world:setTileState(x, y, 0)
		end
		
		-- both are enabled
		if is_wire_left and is_wire_right then
			dePower(world, x, y+1)
			dePower(world, x, y-1)
		elseif is_wire_left or is_wire_right then

			propagatePower(world, x, y+1)
			propagatePower(world, x, y-1)
		else
			dePower(world, x, y+1)
			dePower(world, x, y-1)
		end
	end,
	onbreak = function(world, x, y)
		dePower(world, x, y+1)
		dePower(world, x, y-1)
	end,
})

newtile("XAND_GATE", {
	texure = "xand_gate",
	color = {0.75, 1, 1},
	tags = {"mechanism"},
	layeredRender = function(tx, ty, state, damage)
		if state == 3 then
			return {
				[1] = {"wire", 0, {1, 1, 1}},
				[2] = {"wire", 90, {1, 1, 1}},
				[3] = {"wire", 180, {1, 1, 1}},
				[4] = {"wire", 270, {1, 1, 1}},
				[5] = {"xand_gate", 0, {1,1,1}},
			}
		elseif state == 2 then
			return {
				[1] = {"wire", 0, {0.25, 0.25, 0.25}},
				[2] = {"wire", 90, {0.25, 0.25, 0.25}},
				[3] = {"wire", 180, {0.25, 0.25, 0.25}},
				[4] = {"wire", 270, {1, 1, 1}},
				[5] = {"xand_gate", 0, {1,1,1}},
			}
		elseif state == 1 then
			return {
				[1] = {"wire", 0, {0.25, 0.25, 0.25}},
				[2] = {"wire", 90, {1, 1, 1}},
				[3] = {"wire", 180, {0.25, 0.25, 0.25}},
				[4] = {"wire", 270, {0.25, 0.25, 0.25}},
				[5] = {"xand_gate", 0, {1,1,1}},
			}
		else
			return {
				[1] = {"wire", 0, {0.25, 0.25, 0.25}},
				[2] = {"wire", 90, {0.25, 0.25, 0.25}},
				[3] = {"wire", 180, {0.25, 0.25, 0.25}},
				[4] = {"wire", 270, {0.25, 0.25, 0.25}},
				[5] = {"xand_gate", 0, {1,1,1}},
			}
		end

	end,
	tileupdate = function(world, x, y)
		-- left is input 1
		-- right is input 2
		-- top and bottom are output
		local is_wire_left = is_wire(world, x-1, y) and is_wire_powered(world, x-1, y)

		local is_wire_right = is_wire(world, x+1, y) and is_wire_powered(world, x+1, y)

		if (is_wire_left and is_wire_right) then
			world:setTileState(x, y, 3)
		elseif is_wire_left then
			world:setTileState(x, y, 2)
		elseif is_wire_right then
			world:setTileState(x, y, 1)
		else
			world:setTileState(x, y, 0)
		end
		
		-- both are enabled
		if is_wire_left and is_wire_right then
			dePower(world, x, y+1)
			dePower(world, x, y-1)
		elseif is_wire_left or is_wire_right then
			dePower(world, x, y+1)
			dePower(world, x, y-1)
		else
			propagatePower(world, x, y+1)
			propagatePower(world, x, y-1)
			
		end
	end,
	onbreak = function(world, x, y)
		dePower(world, x, y+1)
		dePower(world, x, y-1)
	end,
})

newtile("BUFFER", {
	texture = "inverter",
	tags = {"mechanism"},
	color = {0.75, 0.75, 0.75},
	tileupdate = function(world, x, y)
		local is_wire_left = is_wire(world, x-1, y) and is_tile_powered(world, x-1, y)

		if world:getTileState(x, y) == 100 then
			is_wire_left = true
			world:setTileState(x, y, 0)
		end

		local state = world:getTileState(x, y)
		if is_wire_left then
			if state == 0 then
				
				world:setTileState(x, y, 10)
				--propagatePower(world, x+1, y)
			end
		else
			if state == 0 then
				world:setTileState(x, y, -10)
				--dePower(world, x+1, y)
			end
		end

		state = world:getTileState(x, y)

		if state > 1 then
			world:setTileState(x, y, state-1)
		end

		if state < -1 then
			world:setTileState(x, y, state+1)
		end

		if state == 1 then
			propagatePower(world, x+1, y)
			world:setTileState(x, y, 0)
		end

		if state == -1 then
			dePower(world, x+1, y)
			world:setTileState(x, y, 0)
		end
	end,

})