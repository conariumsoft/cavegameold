local jutils = require("src.jutils")
local config = require("config")

--[[


tile("AND_GATE", {
	texture = "default",
	tags = {"mechanism"},
})

tile("DIAGONAL_WIRE", {
	texture = "default",
	tags = {"mechanism"},
})

tile("HORIZONTAL_WIRE", {
	texture = "default",
	tags = {"mechanism"},
})

tile("WIRE_JUNCTION", {
	texture = "default",
	tags = {"mechanism"},
})

tile("BATTERY", {
	texture = "default",
	tags = {"mechanism"},
	tileupdate = function(world, x, y)
		local function doThing(x, y)
			local id = world:getTile(x, y)
			if id == 0 then return end
			local data = tilecollector:getByID(id)
		end
	end,
})
--]]

--[[
]]

local function propagatePower(world, x, y)
	
	local t = world:getTile(x, y)

	if t == tilelist.WIRE.id and world:getTileState(x, y) == 0 then
		world:setTileState(x, y, 1)
		propagatePower(world, x+1, y)
		propagatePower(world, x-1, y)
		propagatePower(world, x, y+1)
		propagatePower(world, x, y-1)
	end

	if t == tilelist.TNT.id then
		world:setTileState(x, y, 1)
	end

	if t == tilelist.TOGGLE_BRICK.id or t == tilelist.SOLID_TOGGLE_BRICK.id then
		world:setTileState(x, y, 1)
	end
end

local function dePower(world, x, y)
	local t = world:getTile(x, y)

	if t == tilelist.WIRE.id and world:getTileState(x, y) == 1 then
		world:setTileState(x, y, 0)
		dePower(world, x+1, y)
		dePower(world, x-1, y)
		dePower(world, x, y+1)
		dePower(world, x, y-1)
	end
end

newtile("TOGGLE_BRICK", {
	texture = "brick",
	color = {0.3, 0.3, 0.3},
	hardness = 3,
	solid = false,
	collide = false,
	tileupdate = function(world, x, y)
		if world:getTileState(x, y) == 1 then
			world:setTile(x, y, tilelist.SOLID_TOGGLE_BRICK.id)
		end
	end
})

newtile("SOLID_TOGGLE_BRICK", {
	texture = "brick",
	color = {0.8, 0.8, 0.8},
	hardness = 3,
	tileupdate = function(world, x, y)
		if world:getTileState(x, y) == 1 then
			world:setTile(x, y, tilelist.TOGGLE_BRICK.id)
		end
	end
})

newtile("WIRE", {
	texture = "wire",
	tags = {"mechanism", "transmitter"},
	tileupdate = function(world, x, y)
		--propagatePower(world, x, y)
	end,
	customRenderLogic = function(tx, ty, state, damage)
		if state == 1 then
			return "wire", {1, 1, 1}, 0
		else
			return "wire", {0.5, 0.5, 0.5}, 0
		end
	end,
})

newtile("SWITCH", {
	texture = "switch",
	tags = {"mechanism"},
	tileupdate = function(world, x, y)
		
		if world:getTileState(x, y) == 1 then
			for dx = -1, 1 do
				for dy = -1, 1 do
					local t = world:getTile(x+dx, y+dy)

					if t == tilelist.WIRE.id then
						propagatePower(world, x+dx, y+dy)
					end
				end
			end
		else
			for dx = -1, 1 do
				for dy = -1, 1 do
					local t = world:getTile(x+dx, y+dy)

					if t == tilelist.WIRE.id then
						dePower(world, x+dx, y+dy)
					end
				end
			end
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
			return "switch", {1, 1, 1}, 0
		else
			return "switch", {1,1,1}, 180
		end
	end,
})

newtile("BATTERY", {
	tags = {"mechanism", "transmitter"},
	tileupdate = function(world, x, y)
		for dx = -1, 1 do
			for dy = -1, 1 do
				local t = world:getTile(x+dx, y+dy)

				if tilemanager:tileHasTag(t, "mechanism") then
					world:setTileState(x+dx, y+dy, 1)
				end
			end
		end
	end
})

local function explodeTNT(world, x, y)

	local state = world:getTileState(x, y)

	if state == 1 then
		local tntradius = 8

		local pos = jutils.vec2.new(x*config.TILE_SIZE, y*config.TILE_SIZE)
		local exp = world:addEntity("explosion", pos, tntradius, tntradius+2, true)
	end
end

local function activationcheck(world, x, y)
	for dx = -1, 1 do
		if world:getTile(x+dx, y) == tilelist.TNT.id then
			world:setTileState(x+dx, y, 1)
			world:setTile(x, y, tilelist.AIR.id, false)
			--explodeTNT(world, x+dx, y)
			return
		end
	end
	for dy = -1, 1 do
		if world:getTile(x, y+dy) == tilelist.TNT.id then
			world:setTileState(x, y+dy, 1)
			world:setTile(x, y, tilelist.AIR.id, false)
			--explodeTNT(world, x, y+dy)
			return
		end
	end
	
end


newtile("ACTIVATOR", {
	tileupdate = activationcheck
})

newtile("TNT", {
	tags = {"mechanism", "transmitter"},
	texture = "tnt",
	color = {1, 1, 1},
	hardness = 1,
	tileupdate = explodeTNT,
})