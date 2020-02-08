local jutils = require("src.jutils")
local tiles = require("src.tiles")
local backgrounds = require("src.backgrounds")
local input = require("src.input")
local grid = require("src.grid")

local function getPlayerTile(playerentity)
	local pos = playerentity.position

	return grid.pixelToTileXY(pos.x, pos.y)
end

local function magnitude(x1, y1, x2, y2)
	return math.sqrt( (x2 - x1)^2 + (y2-y1)^2 )
end

baseitem:new("IRON_INGOT",
{displayname = "IRON INGOT", texture = "ingot.png", color = {1, 0.8, 0.8}, stack = 999}
)
baseitem:new("COPPER_INGOT",
{displayname = "COPPER INGOT", texture = "ingot.png", color = {1, 0.45, 0.0}, stack = 999}
)
baseitem:new("LEAD_INGOT",
{displayname = "LEAD INGOT", texture = "ingot.png", color = {0.35, 0.35, 0.45}, stack = 999}
)
baseitem:new("SILVER_INGOT",
{displayname = "SILVER INGOT", texture = "ingot.png", color = {1,1,1}, stack = 999}
)
baseitem:new("PALLADIUM_INGOT",
{displayname = "PALLADIUM INGOT", texture = "ingot.png", color = {0.9, 0.5, 0.9}, stack = 999}
)
baseitem:new("CHROMIUM_INGOT",
{displayname = "CHROMIUM INGOT", texture = "ingot.png", color = {0.5, 1, 1}, stack = 999}
)
baseitem:new("TIN_INGOT",
{displayname = "TIN INGOT", texture = "ingot.png", color = {0.6, 0.4, 0.4}, stack = 999}
)
baseitem:new("GOLD_INGOT",
{displayname = "GOLD INGOT", texture = "ingot.png", color = {1,1,0.5}, stack = 999}
)
baseitem:new("ALUMINIUM_INGOT",
{displayname = "ALUMINIUM INGOT", texture = "ingot.png", color = {0.9, 0.9, 0.9}, stack = 999}
)
baseitem:new("NICKEL_INGOT",
{displayname = "NICKEL INGOT", texture = "ingot.png", color = {1, 0.5, 0.5}, stack = 999}
)
baseitem:new("VANADIUM_INGOT",
{displayname = "VANADIUM INGOT", texture = "ingot.png", color = {0.5, 1, 0.8}, stack = 999}
)
baseitem:new("COBALT_INGOT",
{displayname = "COBALT INGOT", texture = "ingot.png", color = {0.3, 0.3, 1}, stack = 999}
)
baseitem:new("TITANIUM_INGOT",
{displayname = "TITANIUM INGOT", texture = "ingot.png", color = {0.6, 0.6, 0.6}, stack = 999}
)
baseitem:new("ENRICHED_URANIUM",
{displayname = "ENRICHED URANIUM", texture = "ingot.png", color = {0.6, 1, 0.6}, stack = 999}
)

baseitem:new("PAPER", {
	texture = "scroll.png",
	stack = 99,
})

baseitem:new("SILK", {

})

baseitem:new("GOO", {
	texture = "goo.png",
	stack = 999,
})

baseitem:new("BOOK", {
	
})

baseitem:new("MUSHROOM", {
	texture = "mushroom.png"
})
baseitem:new("MUSHROOM_POISONOUS", {
	texture = "mushroom_poison.png"
})
baseitem:new("MUSHROOM_PSILOCYN", {
	texture = "mushroom_psilocyn.png"
})
baseitem:new("EMPTY_SCROLL", {
	displayname = "EMPTY SCROLL",
	texture = "scroll.png",
	color = {0.9, 0.9, 0.9},
	stack = 99,
})

baseitem:new("PURE_SOUL_FRAGMENT", {
	texture = "soul.png",
	displayname = "SOUL FRAGMENT",
	color = {1,1,1},
	stack = 999,
	rarity = 2,
})

baseitem:new("HATEFUL_SOUL_FRAGMENT", {
	texture = "soul.png",
	displayname = "SOUL FRAGMENT",
	color = {0.5, 0.5, 0.5},
	stack = 999,
	rarity = 2,
})

baseitem:new("BOTTLE", {
	stack = 99,
	texture = "bottle1.png",
	color = {1,1,1},
})

baseitem:new("ETHER", {
	tooltip = "Has a funny smell...",
	texture = "fullbottle1.png",
	color = {0.5, 0.5, 0.8},
	rarity = 2,
})

baseitem:new("CRYING_LILY", {
	texture = "bottle2.png",
	tooltip = "A peculiar flower that drips nectar as if it were weeping.",
	rarity = 2,
	color = {1,1,1},
})

baseitem:new("STEAM_ENGINE", {
	texture = "engine.png",
	tooltip = "Asdasdadas",
	rarity = 3,
	color = {0.7, 0.5, 0.5},
	stack = 1,
})

baseitem:new("ELECTRIC_ENGINE", {
	texture = "engine.png",
	tooltip = "Asdasdadas",
	rarity = 4,
	color = {0.9, 0.8, 0.8},
	stack = 1,
})

baseitem:new("ATOMIC_ENGINE", {
	texture = "engine.png",
	tooltip = "Asdasdadas",
	rarity = 5,
	color = {0.8, 1, 0.8},
	stack = 1,
})

baseitem:new("DRILL_CHASSIS", {
	texture = "chassis.png",
	tooltip = "asdadassd",
	rarity = 2,
	color = {0.8,0.7,0.7},
	stack = 1,
})

baseitem:new("REINFORCED_DRILL_CHASSIS", {
	texture = "chassis.png",
	tooltip = "dasdasd",
	rarity = 2,
	color = {0.9,0.9,0.9},
	stack = 1,
})


baseitem:new("ELECTRON_SCROLL", {
	displayname = "ELECTRON SCROLL",
	texture = "scroll.png",
	color = {1, 1, 0.5},
	speed = 2,
	repeating = false,
	rarity = 3,
})


baseitem:new("JETPACK", {
	displayname = "JETPACK",
	speed = 1/30,
	texture = "jetpack.png",
	repeating = false,
	use = function(self, player) return true end,
	useend = function(self, player) end,
	usestep = function(self, player, dt)
		
		local yThrust = -1000
		local xThrust = 0

		if player.moveLeft or player.moveRight then
			yThrust = -800
			xThrust = 1000*player.direction
		end
		player.velocity = player.velocity + (jutils.vec2.new(xThrust, yThrust)*dt)

		if player.mouse.down == false then return true end
		
	end
})

baseitem:new("FERTILIZER", {
	displayname = "FERTILIZER",
	texture = "fertilizer.png",
	speed = 1/10,
	repeating = true,
	specialdata = {usedistance=10},
	holdbegin = function(self, player)
		player.showMouseTileDistance = 10
	end,
	holdend = function(self, player)
		player.showMouseTileDistance = -1
	end,
	use = function(self, player)
		local mx, my = input.getTransformedMouse()

		local tx, ty = grid.pixelToTileXY(mx, my)

	end,
})

baseitem:new("BUCKET", {
	displayname = "EMPTY BUCKET",
	texture = "bucket.png",
	speed = 1/5,
	stack = 99,
	repeating = false,
	holdbegin = function(self, player) end,
	holdend = function(self, player) end,
	use = function(self, player)
		local mx, my = input.getTransformedMouse()

		local tx, ty = grid.pixelToTileXY(mx, my)
		local stack = player.itemHoldingStack
		local world = player.world

		local tileAt = world:getTile(tx, ty)

		if tileAt == 0 then return false end

		local tiledata = tiles:getByID(tileAt)

		if tileAt == tiles.WATER.id and world:getTileState(tx, ty) == 8 then
			player.world:setTile(tx, ty, tiles.AIR.id)
			player.gui.inventory:addItem(itemlist.WATER_BUCKET.id, 1)
			stack[2] = stack[2] - 1
			return true
		end	
		if tileAt == tiles.LAVA.id and world:getTileState(tx, ty) == 8 then
			player.world:setTile(tx, ty, tiles.AIR.id)
			player.gui.inventory:addItem(itemlist.LAVA_BUCKET.id, 1)
			stack[2] = stack[2] - 1
			return true
		end

		return false
	end,
})

baseitem:new("WATER_BUCKET", {
	displayname = "WATER BUCKET",
	texture = "bucket.png",
	speed = 1/5,
	stack = 99,
	repeating = false,
	holdbegin = function(self, player) end,
	holdend = function(self, player) end,
	use = function(self, player)
		local mx, my = input.getTransformedMouse()

		local tx, ty = grid.pixelToTileXY(mx, my)
		local stack = player.itemHoldingStack
		local world = player.world

		local tileAt = world:getTile(tx, ty)

		local tiledata = tiles:getByID(tileAt)

		if tileAt == tiles.AIR.id then
			player.world:setTile(tx, ty, tiles.WATER.id)
			player.gui.inventory:addItem(itemlist.BUCKET.id, 1)
			stack[2] = stack[2] - 1
			return true
		end	


		return false
	end,
})

baseitem:new("LAVA_BUCKET", {
	displayname = "LAVA BUCKET",
	texture = "bucket.png",
	speed = 1/5,
	stack = 99,
	repeating = false,
	holdbegin = function(self, player) end,
	holdend = function(self, player) end,
	use = function(self, player)
		local mx, my = input.getTransformedMouse()

		local tx, ty = grid.pixelToTileXY(mx, my)
		local stack = player.itemHoldingStack
		local world = player.world

		local tileAt = world:getTile(tx, ty)

		if tileAt == tiles.AIR.id then
			player.world:setTile(tx, ty, tiles.LAVA.id)
			player.gui.inventory:addItem(itemlist.BUCKET.id, 1)
			stack[2] = stack[2] - 1
			return true
		end
		return false
	end,
})

--|| TILES SECTION
-- Add all tiles to the items list
local tileitem = consumable:subclass("TileItem") do
	tileitem.texture = "tiletexture"
	tileitem.usedistance = 8
	tileitem.inWorldScale = 1
	tileitem.playerHoldPosition = jutils.vec2.new(4, 4)	
	tileitem.defaultRotation = 0
	tileitem.stack = 999
	tileitem.speed = 1/6
	
end
do
	local smash_sfx = love.audio.newSource("assets/audio/wood03.ogg", "static")

	for name, data in pairs(tiles:getList()) do
		if data.makeItem ~= false then
			tileitem:new(data.name.."_TILE", {
				displayname = string.gsub(data.name, "_", " "),
				quad = data.texture,
				color = data.color,
				tags = data.tags,
				tileid = data.id,
				animation = data.animation,
				animationspeed = data.animationspeed,
				holdbegin = function(self, player)
					if data.light and type(data.light) == "table" then
						player.lightemitter = data.light
					end
					player.showMouseTileDistance = self.usedistance
				end,
				holdend = function(self, player)
					if data.light then
						player.lightemitter = nil
					end
					player.showMouseTileDistance = -1
				end,
				
				consume = function(self, player)
					local itemdata = player.itemEquipped
					local tiledata = tiles:getByID(self.tileid)

					local mx, my = input.getTransformedMouse()

					local tx, ty = grid.pixelToTileXY(mx, my)
					local px, py = getPlayerTile(player)
					local canPlace = true
					if magnitude(px, py, tx, ty) > self.usedistance then
						canPlace = false
					end

					local id = player.world:getTile(tx, ty)
					if id ~= 0 and tiles:tileHasTag(id, "fakeempty") == false then
						canPlace = false
					end

					if tiledata.validplacement then
						if not tiledata.validplacement(player.world, tx, ty) then
							canPlace = false
						end
					end

					local ptx, pty = grid.pixelToTileXY(player.position.x, player.position.y)

					if (ptx == tx and pty == ty) or (ptx-1 == tx and pty == ty) or (ptx == tx and pty+1 == ty) or 
					   (ptx == tx and pty-1 == ty) or (ptx-1 == tx and pty+1 == ty) or (ptx-1 == tx and pty-1 == ty) then
						canPlace = false
					end

					if canPlace then
						player.world:setTile(tx, ty, self.tileid)
						smash_sfx:stop()
						smash_sfx:setPitch(1)
						smash_sfx:play()
						return true
					end
					return false
				end,
			})
		end
	end

	itemlist.ROPE_TILE.speed = 1/10
	itemlist.ROPE_TILE.consume = function(self, player)
		local itemdata = player.itemEquipped
		local tiledata = tiles:getByID(self.tileid)


		local stack = player.itemHoldingStack
		local mx, my = input.getTransformedMouse()

		local tx, ty = grid.pixelToTileXY(mx, my)
		local px, py = getPlayerTile(player)
		local canPlace = true
		if magnitude(px, py, tx, ty) > self.usedistance then
			canPlace = false
		end

		if player.world:getTile(tx, ty) ~= 0 then
			canPlace = false
		end

		if tiledata.validplacement then
			if not tiledata.validplacement(player.world, tx, ty) then
				canPlace = false
			end
		end

		if canPlace then
			player.world:setTile(tx, ty, self.tileid)
			--stack[2] = stack[2] - 1
			return true
		end

		if player.world:getTile(tx, ty) == tiles.ROPE.id then
			local keepGoing = true
			local valid = true
			local iter = 1
			while keepGoing do
				if player.world:getTile(tx, ty+iter) == tiles.ROPE.id then
					iter = iter + 1
				elseif player.world:getTile(tx, ty+iter) == tiles.AIR.id then
					keepGoing = false
				else
					valid = false
					keepGoing = false
				end
			end

			if valid then
				player.world:setTile(tx, ty+iter, tiles.ROPE.id)
				--stack[2] = stack[2] - 1
				return true
			end
		end


		return false
	end
end


--|| BACKGROUNDS SECTION
-- Add all backgrounds to the items list
do

	local wallitem = tileitem:subclass("WallItem")

	local num = backgrounds:getNumberOfTiles()
	for i = 1, num-1 do
		local data = backgrounds:getByID(i)
		if data.makeItem ~= false then
			wallitem:new(data.name.."_WALL", {
				displayname = string.gsub(data.name.."_WALL", "_", " "),
				quad = data.texture,
				color = jutils.color.multiply(data.color, {0.5, 0.5, 0.5}),
				animation = data.animation,
				tags = data.tags,
				animationspeed = data.animationspeed,
				tileid = data.id,
				consume = function(self, player)
					local mx, my = input.getTransformedMouse()

					local tx, ty = grid.pixelToTileXY(mx, my)
					local px, py = getPlayerTile(player)
					local canPlace = true
					if magnitude(px, py, tx, ty) > self.usedistance then
						canPlace = false
					end

					local id = player.world:getBackground(tx, ty)
					if id ~= 0 then
						canPlace = false
					end

					if canPlace then
						player.world:setBackground(tx, ty, self.tileid)
						return true
					end
					return false
				end,
			})
		end
	end
end
