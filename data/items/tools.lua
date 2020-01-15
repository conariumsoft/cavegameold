local jutils = require("src.jutils")
local tiles = require("src.tiles")
local backgrounds = require("src.backgrounds")
local input = require("src.input")
local grid = require("src.grid")
local collision = require("src.collision")

local function getPlayerTile(playerentity)
	local pos = playerentity.position

	return grid.pixelToTileXY(pos.x, pos.y)
end

local function magnitude(x1, y1, x2, y2)
	return math.sqrt( (x2 - x1)^2 + (y2-y1)^2 )
end

local PICKAXE_TOOLTIP = "{speed} Speed\n{usedistance} Range\n{strength} Pickaxe Power"
--|| PICKAXES SECTION
do
	local pickaxeAudio = love.audio.newSource("assets/audio/smash.ogg", "static")
	local pickaxeSwingAudio = love.audio.newSource("assets/audio/swing.ogg", "static")
	local drillEngineAudio = love.audio.newSource("assets/audio/drill.ogg", "static")

	local function pickaxeEquip(pickaxe, player)
		player.showMouseTileDistance = pickaxe.usedistance
	end

	local function pickaxeUnequip(pickaxe, player)
		player.showMouseTileDistance = -1
	end

	local function pickaxeUse(pickaxe, player)
		local mx, my = input.getTransformedMouse()

		pickaxeSwingAudio:stop()
		pickaxeSwingAudio:play()

		local tx, ty = grid.pixelToTileXY(mx, my)
		local px, py = getPlayerTile(player)

		if magnitude(px, py, tx, ty) < pickaxe.usedistance then

			local tileid = player.world:getTile(tx, ty)
			if tileid > 0 then
				pickaxeAudio:stop()
				player.world:damageTile(tx, ty, pickaxe.strength)
				pickaxeAudio:play()
			end
		end
		return true
	end

	local function drillUse(drill, player)
		local mx, my = input.getTransformedMouse()

		drillEngineAudio:stop()
		--drillEngineAudio:setPitch(math.random(9, 11)/10)
		drillEngineAudio:play()

		local tx, ty = grid.pixelToTileXY(mx, my)
		local px, py = getPlayerTile(player)

		if magnitude(px, py, tx, ty) < drill.usedistance then

			local tileid = player.world:getTile(tx, ty)
			if tileid > 0 then
				pickaxeAudio:stop()
				player.world:damageTile(tx, ty, drill.strength)
				pickaxeAudio:play()
			end
		end
		return true
	end

	local pickaxe = baseitem:subclass("Pickaxe") do
		pickaxe.use = pickaxeUse
		pickaxe.holdbegin = pickaxeEquip
		pickaxe.holdend = pickaxeUnequip
		pickaxe.stack = 1
		pickaxe.texture = love.graphics.newImage("assets/items/pickaxenew.png")
		pickaxe.inWorldScale = 2
		pickaxe.playeranim = swinganim(-90, 130)
		pickaxe.playerHoldPosition = jutils.vec2.new(0, 8)
		pickaxe.defaultRotation = -45
		pickaxe.tooltip = PICKAXE_TOOLTIP
	end


	local drill = pickaxe:subclass("Drill") do
		drill.texture = love.graphics.newImage("assets/items/drill.png")
		drill.playerHoldPosition = jutils.vec2.new(10, 4)
		drill.playeranim = pointanim(false)
		drill.use = drillUse
	end

	--[[
		Pickaxe progression:

		Level 1
		Handmade - 4 speed, 6 range, 1 strength (base)
		Iron - 5 speed, 8 range, 2 strength (slightly stronger but average)
		Copper - 7 speed, 10 range, 1 strength (very fast)
		Lead - 2 speed, 12 range, 4 strength (very strong)

		Level 2
		Aluminium - 6 speed, 10 range, 4 strength (average)
		Tin - 12 speed, 12 range, 2 strength (speed)
		Palladium - 4 speed, 14 range, 6 strength (strength)

		Level 3
		Chromium + Nickel (Steam Drill) - 
		Vanadium + Cobalt (Power Drill) - 
		Titanium + Uranium (Nuclear Drill) - 
	]]
	pickaxe:new("HANDMADE_PICKAXE", {
		displayname = "HANDMADE PICKAXE",
		tooltip = "A rock and a stick binded with rope.\n"..PICKAXE_TOOLTIP,
		color = {0.8, 0.6, 0.5},
		speed = 1/4,
		usedistance = 6,
		strength = 1,
	})

	pickaxe:new("IRON_PICKAXE", {
		color = {0.9, 0.75, 0.75},
		displayname = "IRON PICKAXE",
		speed = 1/4,
		rarity = 2,
		usedistance = 8,
		strength = 2,
	})

	pickaxe:new("COPPER_PICKAXE", {
		color = {0.9, 0.45, 0.1},
		speed = 1/6,
		rarity = 2,
		usedistance = 10,
		strength = 1,
	})

	pickaxe:new("LEAD_PICKAXE", {
		color = {0.35, 0.35, 0.45},
		speed = 1/2,
		usedistance = 12,
		strength = 4,
		rarity = 2,

	})
	
	pickaxe:new("TIN_PICKAXE",{
		displayname = "TIN PICKAXE",
		color = {0.6, 0.4, 0.4},
		speed = 1/5,
		usedistance = 10,
		strength = 4,
		rarity = 2,
	})

	pickaxe:new("ALUMINIUM_PICKAXE", {
		displayname = "ALUMINIUM PICKAXE",
		color = {1, 1, 1},
		speed = 1/8,
		usedistance = 12,
		strength = 3,
		rarity = 2,
	})

	pickaxe:new("PALLADIUM_PICKAXE", {
		displayname = "PALLADIUM PICKAXE",
		texture = "bigpickaxe.png",
		color = {1, 1, 1},
		speed = 1/3,
		tooltip = PICKAXE_TOOLTIP,
		usedistance = 14,
		strength = 6,
		rarity = 2,
	})

	pickaxe:new("COBALT_PICKAXE", {
		displayname = "COBALT PICKAXE",
		texture = "bigpickaxe.png",
		color = {1,1,1},
		speed = 1/5,
		tooltip = PICKAXE_TOOLTIP,
		usedistance = 15,
		strength = 5,
		rarity = 2,
	})

	drill:new("STEAM_DRILL", {
		displayname = "STEAM DRILL",
		color = {0.9,0.6,0.6},
		speed = (1/5),
		strength = 5,
		usedistance = 16,
		rarity = 4,
	})

	drill:new("POWER_DRILL", {
		displayname = "POWER DRILL",
		color = {1,0.8,0.2},
		speed = (1/10),
		strength = 5,
		usedistance = 20,
		rarity = 4,
	})


	drill:new("ATOMIC_DRILL", {
		displayname = "ATOMIC DRILL",
		color = {0.8,1,0.8},
		speed = (1/20),
		strength = 5,
		usedistance = 24,
		rarity = 5,

	})

	baseitem:new("WALL_SCRAPER", {
		texture = "wallscraper.png",
		displayname = "WALL SCRAPER",
		color = {0.8, 0.8, 0.8},
		speed = (1/5),
		stack = 1,
		repeating = true,
		usedistance = 12,
		inWorldScale = 2,
		playeranim = swinganim(-90, 130),
		playerHoldPosition = jutils.vec2.new(0, 8),
		defaultRotation = -45,
		holdbegin = pickaxeEquip,
		holdend = pickaxeUnequip,
		use = function (scraper, player)
			local mx, my = input.getTransformedMouse()
	
			local tx, ty = grid.pixelToTileXY(mx, my)
			local px, py = getPlayerTile(player)
	
			if magnitude(px, py, tx, ty) < scraper.usedistance then
	
				local bgid = player.world:getBackground(tx, ty)
				if bgid > 0 then

					player.world:setBackground(tx, ty, 0)
					-- NOTE: Haven't decided if backgrounds should be recoverable once placed.
					-- just uncomment this section if you want backgrounds to be dropped when
					-- using the wall scraper

					--[[local bgdata = backgrounds:getByID(bgid)
					if bgdata.drop ~= false then
						local item = bgdata.drop
						
						
						local e = player.world:addEntity("itemstack", item.id, 1)
						e:teleport(jutils.vec2.new(tx*config.TILE_SIZE, ty*config.TILE_SIZE))
					end]]
					return true
				end
			end
		end,
	})
end