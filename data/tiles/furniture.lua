local grid = require("src.grid")
local jutils = require("src.jutils")

local function multitile(name, x, y, data)
	for tx = 1, x do
		for ty = 1, y do
			local dataTable = jutils.table.copy(data)
			dataTable.texture = data.texture.."_"..tx.."_"..ty
			dataTable.multitile = {
					name = name,
					ax = tx,
					ay = ty,
					w = x,
					h = y,
			}
			dataTable.makeItem = false
			dataTable.tileupdate = function(world, x, y)

				local self = world:getTile(x, y)
				local tiledata = tilemanager:getByID(self)

				if data.validplacement then
					if data.validplacement(world, x, y) == false then
						world:setTile(x, y, tilelist.AIR.id, false)
						return
					end
				end
					
				local multitile = tiledata.multitile

				local offsetx, offsety = multitile.w-(multitile.ax), multitile.h-(multitile.ay)

				for dx = 1, multitile.w do
					for dy = 1, multitile.h do
						local realx, realy = (x-multitile.ax)+dx, (y-multitile.ay)+dy

						local tile = world:getTile(realx, realy)
						local data = tilemanager:getByID(tile)

						if data.name ~= multitile.name.."_"..dx.."_"..dy then
							world:setTile(x, y, tilelist.AIR.id, false)
							return
							end
						end
					end

				end
			
			newtile(name.."_"..tx.."_"..ty, dataTable)
		end
	end
end

multitile("WORKBENCH", 2, 1, {
	texture = "workbench",
	color = {0.8, 0.6, 0.3},
	hardness = 3,
	solid = false,
	absorb = 0,
	collide = true,
	tags = {"platformtile", station="workbench", "crafting"},
	drop = "WORKBENCH",
})

multitile("FURNACE", 2, 2, {
	texture = "furnace",
	color = {1,1,1},
	hardness = 4,
	light = {1.5, 1, 1},
	solid = false,
	absorb = 0,
	collide = false,
	tags = {station="furnace", "crafting"},
	drop = "FURNACE"
})

multitile("CHEST", 2, 2, {
	texture = "chest",
	color = {0.8, 0.66, 0.3},
	solid = false,
	collide = false,
	absorb = 0,
	drop = "CHEST",
	playerInteract = function(player, x, y, button)
		if button == 2 then
			local world = player.world

			for _, e in pairs(world.entities) do
				if e:isA("Chest") then
					if e:isAtTile(x, y) then
						
						if player.openContainer == nil then
							player.gui.openContainer = e.inventory
							player.gui.open = true
						else

							player.gui.openContainer = nil
							player.gui.open = false
						end
					end
				end
			end
		end
	end,
})

tilelist.CHEST_1_1.onplace = function(world, x, y)
	local chest = world:addEntity("chest", {{x, y}, {x+1, y}, {x, y+1}, {x+1, y+1}})
end

multitile("REFINERY", 3, 2, {
	texture = "refinery",
	hardness = 5,
	light = {1, 1, 0},
	solid = false,
	collide = false,
	tags = {station="refinery", "crafting"},
	drop = "REFINERY",
})

multitile("ANVIL", 2, 1, {
	texture = "anvil",
	hardness = 5,
	solid = false,
	collide = false,
	absorb = 0,
	drop = "ANVIL",
	tags = {station="anvil", "crafting"}
})

multitile("MECHANARIUM", 3, 2, {
	tags = {station="mechanarium", "crafting"},
	texture = "mechanarium",
	light = {0.5, 0.5, 0},
	solid = false,
	collide = false,
	drop = "MECHANARIUM"
})

multitile("ALCHEMY_LAB", 3, 2, {
	tags = {station="alchemylab", "crafting"},
	texture = "alchemy_lab",
	light = {0.5, 0, 0.5},
	solid = false,
	collide = false,
	drop = "ALCHEMY_LAB"
})

multitile("CAMPFIRE", 2, 1, {
	texture = "campfire",
	color = {1,1,1},
	light = {1.3, 1, 0.8},
	hardness = 3,
	solid = false,
	collide = false,
	drop = "CAMPFIRE",
})

tilelist.CAMPFIRE_1_1.animation =  {
	[1] = "campfire_1_1",
	[2] = "campfire_1_2",
}

tilelist.CAMPFIRE_2_1.animation = {
	[1] = "campfire_2_1",
	[2] = "campfire_2_2",
}

-- ?
multitile("DOOR", 1, 3, {
	texture = "door",
	color = {0.8, 0.55, 0.3},
	hardness = 6,
	solid = true,
	absorb = 0.3,
	collide = true,
	drop = "DOOR",
	-- fix how collisionboxes are read?
	collisionBox = {0, 0, 4, 0},
	playerInteract = function(player, x, y, button)
		if button == 2 then
			
			local self = player.world:getTile(x, y)

			local tiledata = tilemanager:getByID(self)

			local ypos = tiledata.multitile.ay
			local playerDir = player.direction

			for dy = 1, 3 do
				local boob =  y + ((dy) - ypos)
				if player.world:getTile(x+playerDir, boob) ~= 0 and tilemanager:tileHasTag(player.world:getTile(x+playerDir, boob), "fakeempty") == false then return end
			end

			for dy = 1, 3 do
				local boob =  y + ((dy) - ypos)
				local tileat = player.world:getTile(x, boob)
				local tiledata = tilemanager:getByID(tileat)

				local close = 2
				local far = 1

				if playerDir == 1 then
					close = 1
					far = 2
				end

				local id = tilelist["OPEN_DOOR_"..close.."_"..tiledata.multitile.ay].id
				player.world:setTile(x, boob, id, false)
				player.world:setTileState(x, boob, 1)

				local id2 = tilelist["OPEN_DOOR_"..far.."_"..tiledata.multitile.ay].id
				player.world:setTile(x+playerDir, boob, id2, false)
			end

		end
	end
})

local function door_bottom_valid(world, x, y)
	local below = world:getTile(x, y+1)

	if below < 1 then return false end

	local tiledata = tilemanager:getByID(below)

	if tiledata.solid == false then
		return false
	end
	return true
end

tilelist.DOOR_1_3.validplacement = door_bottom_valid

tilelist.DOOR_1_3.tileupdate = function(world, x, y)
	if door_bottom_valid(world, x, y) == false then
		world:setTile(x, y, tilelist.AIR.id, true)
	end
end

multitile("OPEN_DOOR", 2, 3, {
	color = {0.8, 0.55, 0.3},
	hardness = 6,
	texture = "open_door",
	solid = false,
	absorb = 0,
	collide = false,
	drop = "DOOR",
	playerInteract = function(player, x, y, button)
		if button == 2 then
			
			local playerx, playery = grid.pixelToTileXY(player.position.x, player.position.y)

			if playerx == x and playery == y then return end

			-- figure out which part of the door we are
			local self = player.world:getTile(x, y)

			local tiledata = tilemanager:getByID(self)

			local xpos = tiledata.multitile.ax
			local ypos = tiledata.multitile.ay
			
			for dx = 1, 2 do
				for dy = 1, 3 do
					local diffx = x + (dx-xpos)
					local diffy = y + (dy-ypos)
					
					local tileat = player.world:getTile(diffx, diffy)
					local tiledata = tilemanager:getByID(tileat)

					if player.world:getTileState(diffx, diffy) == 1 then
						player.world:setTile(diffx, diffy, tilelist["DOOR_1_"..dy].id, false)
					else
						player.world:setTile(diffx, diffy, tilelist.AIR.id, false)
					end
				end
			end
		end
	end
})

--[[multitile("BOOKSHELF", 2, 3, {

})]]