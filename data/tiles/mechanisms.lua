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

newtile("WIRE", {
	tags = {"mechanism", "transmitter"},
	tileupdate = function(world, x, y)
		for dx = -1, 1 do
			for dy = -1, 1 do
				local t = world:getTile(x+dx, y+dy)

				if tilemanager:tileHasTag(t, "mechanism") and tilemanager:tileHasTag(t, "transmitter") then
					local s = world:getTileState(x+dx, y+dy)

					if s == 1 then
						world:setTileState(x, y, 1)
					end
				end
			end
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
		
		
		for dx = -tntradius, tntradius do
			for dy = -tntradius, tntradius do
				if world:getTile(x+dx, y+dy) == tilelist.TNT.id then
					world:setTileState(x+dx, y+dy, 1)
				end
			end
		end
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
	tags = {"mechanism"},
	texture = "tnt",
	color = {1, 1, 1},
	hardness = 1,
	tileupdate = explodeTNT,
})