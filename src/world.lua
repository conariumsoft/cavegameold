--- Gameworld main loop, controls rendering, input, and physics of terrain and entities.
-- <u>This script really needs to be split up</u>
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software


local config = require("config")
local tiles = require("src.tiles")
local jutils = require("src.jutils")
local rendering = require("src.rendering")
local items = require("src.items")
local json = require("src.json")
local noise = require("src.noise")
local input = require("src.input")
local chunking = require("src.chunking")
local grid = require("src.grid")
local backgrounds = require("src.backgrounds")

local terrainMath = require("src.terrain")

-- list of all entities that the world "can" spawn under varying conditions
-- NOTE: this is the list that the "summon" command uses.
-- NOTE: this is also what world:addEntity(...) uses.

local entitylist = {
	player    = require("src.entities.player"),
	-- hostile enemy entities
	bee       		= require("src.entities.hostile.bee"),
	zombie    		= require("src.entities.hostile.zombie"),
	bat       		= require("src.entities.hostile.bat"),
	slime     		= require("src.entities.hostile.slime"),
	flower 	 		= require("src.entities.hostile.flower"),
	skull 			= require("src.entities.hostile.skull"),
	-- misc game objects
	itemstack		= require("src.entities.itemstack"),
	explosion 		= require("src.entities.explosion"),
	chest 			= require("src.entities.chestentity"),
	floatingtext    = require("src.entities.floatingtext"),
	-- projectiles
	bullet 			= require("src.entities.projectiles.bullet"),
	bombentity 		= require("src.entities.projectiles.bombentity"),
	stickybomb 		= require("src.entities.projectiles.stickybombentity"),
	glowstick 		= require("src.entities.projectiles.glowstick"),
	magicball 		= require("src.entities.projectiles.magicball"),
	-- 

	
}

-- these get LERP'd between for sky colors
local sky_color_table = {
	[0] = {0, 0, 0},
	[3] = {0.01, 0, 0},
	[6] = {0, 0.05, 0.15},
	[9] = {0.05, 0.2, 0.6},
	[12] = {0.05, 0.3, 0.7},
	[15] = {0.05, 0.2, 0.55},
	[18] = {0.1, 0, 0.4},
	[21] = {0.025, 0, 0.01},
}

--[[
	NOTE:
	world file format:

	worldname/
		chunks/
		idmaps/

		metadata.json
			worldname
			seed
		entities.json
]]

local world = {} -- TODO: make world a class object instead of ghetto-rigged metatable

world.__index = world

-- NOTE: does world really need to be an instance?
-- probably not, making it a monolith
-- would likely clean up a lot of
-- annoying shit actually
function world.__init()
	local self = setmetatable({}, world)

	return self
end

--- Generates a new world instance. 
-- Worldname is the name of the folder where it will read and save data to.
-- If the folder exists, then it will load chunks when it find them, otherwise,
-- it will just generate new chunks.
-- @param worldname folder to store world in
-- @param seed doesn't work
-- @return World Instance
function world.new(worldname, seed)

	-- world constructor
	local self = world.__init()

	-- make sure world directories exist
	love.filesystem.createDirectory("worlds/"..worldname)
	love.filesystem.createDirectory("conversionmaps")
	love.filesystem.createDirectory("worlds/"..worldname.."/chunks")

	-- generate game threads
	self.lightthread = love.thread.newThread("src/lighting.lua")
	self.lightthread:start()

	self.chunkthread = love.thread.newThread("src/worldloading.lua")
	self.chunkthread:start(worldname)
	love.thread.getChannel("setambient"):push(self.ambientlight)

	self.worldname = worldname
	self.seed = seed

	self.camera = {
		position = jutils.vec2.new(0, 0),
		zoom = 2.5
	}

	-- ambience
	self.ambientlight = 0
	self.worldtime = 6*60
	self.dayspassed = 0

	self.player = nil
	self.spawnPointY = (terrainMath.getSurfaceLevel(0)*config.TILE_SIZE)
	self.focuspoint = jutils.vec2.new(0, 0)
	
	self.entities = {}
	self.tileentitymap = {}
	self.waitinglist = {}
	
	self.terrainGenerator = require("src.terraingenerator")
	self.structureGenerator = require("src.structuregenerator")

	self.chunks = {}
	self.finishedTerrain = false

	-- if the world is trying to kill
	self.tryingToEnd = false
	
	self.update_tick = 0
	self.random_tick_speed = 1
	self.debug_fullbright = false
	self.no_save = false

	-- generate ID mappings for this version of the game if they don't yet exists
	local info = love.filesystem.getInfo("conversionmaps/"..config.DATA_VERSION)

	if info == nil then

		local map = { tiles = {}, backgrounds = {}}
		for name, data in pairs(tiles:getList()) do
			map.tiles[name] = data.id
		end
		for name, data in pairs(backgrounds:getList()) do
			map.backgrounds[name] = data.id
		end

		local data = json.encode(map)
		love.filesystem.write("conversionmaps/"..config.DATA_VERSION, data)
	end


	-- world metadata
	local info = love.filesystem.getInfo("worlds/"..self.worldname.."/metadata.json", "file")
	if info then
		local contents = love.filesystem.read("string", "worlds/"..self.worldname.."/metadata.json")
		if contents then
			local data = json.decode(contents)

			self.worldtime = data.worldtime
			self.dayspassed = data.dayspassed
			self.seed = data.seed
		end
	end	

	local madeplayer = false

	-- read entity save file
	local info = love.filesystem.getInfo("worlds/"..self.worldname.."/entities.json", "file")
	if info ~= nil then
		--print("existing worldfile found... lastmodified: "..info.modtime)
		local contents = love.filesystem.read("string", "worlds/"..self.worldname.."/entities.json")
		if contents then
			local data = json.decode(contents)

			for idx, edata in pairs(data) do

				--print(idx, edata.type)
				if edata.type then
					print(edata.type)
					local entity = self:addEntity(edata.type)
					entity:deserialize(edata)

					if edata.type == "player" then madeplayer = true end
				end

			end
		end
	end

	if madeplayer == false then
		local player = self:addEntity("player")
		player:teleport(jutils.vec2.new(0, self.spawnPointY))
		player.gui.inventory:addItem(items.HANDMADE_PICKAXE.id, 1)
		player.gui.inventory:addItem(items.RUSTY_SWORD.id, 1)
		player.gui.inventory:addItem(items.ROPE_TILE.id, 999)
		player.gui.inventory:addItem(items.HEALING_POTION.id, 30)
		player.gui.inventory:addItem(items.BOMB.id, 99)
		player.gui.inventory:addItem(items.RED_TORCH_TILE.id, 99)
		player.gui.inventory:addItem(items.GREEN_TORCH_TILE.id, 99)
		player.gui.inventory:addItem(items.BLUE_TORCH_TILE.id, 99)
	end

	noise.setSeed(self.seed)

	return self
end

local channels = {
	addchunk = love.thread.getChannel("addchunk"),
	dropchunk = love.thread.getChannel("dropchunk"),
	tilechange = love.thread.getChannel("tilechange"),
	bgchange = love.thread.getChannel("bgchange"),
	newlights = love.thread.getChannel("newlights"),
	setambient = love.thread.getChannel("setambient"),
	setlight = love.thread.getChannel("setlight"),
	light_kill = love.thread.getChannel("light_kill"),
	-- worldloading
	loadchunk = love.thread.getChannel("loadchunk"),
	savechunk = love.thread.getChannel("savechunk"),
	returnchunk = love.thread.getChannel("returnchunk"),
	finished = love.thread.getChannel("finished"),
	io_kill = love.thread.getChannel("io_kill"),
}

---
function world:savedata()
	if self.no_save == true then return end
	local numsaved = 0
	for key, chunk in pairs(self.chunks) do
		numsaved = numsaved + 1
		channels.savechunk:push({key, chunk})
	end

	local metadata = json.encode({
		worldtime = self.worldtime,
		dayspassed = self.dayspassed,
		seed = self.seed
	})

	love.filesystem.write("worlds/"..self.worldname.."/metadata.json", metadata)

	local entityTable = {}
	for _, entity in pairs(self.entities) do
		
		if entity.save == true then
			local data = entity:serialize()
			--print(index, data)
			table.insert(entityTable, data)
		end
	end


	local jsondata = json.encode(entityTable)

	love.filesystem.write("worlds/"..self.worldname.."/entities.json", jsondata)


	love.timer.sleep(1/10)
	channels.light_kill:push(true)
	channels.io_kill:push(true)
	
	channels.finished:demand(5)

	self.lightthread:release()
	self.chunkthread:release()
	
	self.chunks = nil
	print("Finished saving...")
end

---
function world:playerExitRequest()
	self.tryingToEnd = true
end

---
function world:getPlayer()
	if self.player then return self.player end
	for index, entity in pairs(self.entities) do
		if entity:isA("Player") then
			self.player = entity
			return entity
		end
	end
end

---
function world:addEntity(entityname, ...)
	if not entityname then return end
	if not entitylist[entityname] then return end
	local entity = entitylist[entityname]:new(...)
	entity.world = self
	table.insert(self.entities, entity)
	return entity
end

local function lineIntersectsLine(l1p1, l1p2, l2p1, l2p2)
	local q = (l1p1.y - l2p1.y) * (l2p2.x - l2p1.x) - (l1p1.x - l2p1.x) * (l2p2.x - l2p1.y)
	local d = (l1p2.x - l1p1.x) * (l2p2.y - l2p1.y) - (l1p2.y - l1p1.y) * (l2p2.x - l2p1.x)


	if d == 0 then return false end

	local r = q / d

	q = (l1p1.y - l2p1.y) * (l1p2.x - l1p1.x) - (l1p1.x - l2p1.x) * (l1p2.y - l1p1.y)
	local s = q / d

	if (r < 0 or r > 1 or s < 0 or s > 1) then return false end

	return true
end


--[[
	rectangle object:
	{
		x,
		y,
		width,
		height
	}
]]

local function rectangleContainsPoint(r, p)
	return (p.x > r.x) and (p.x < r.x+r.width) and (p.y > r.y) and (p.y < r.y+r.height)
end

local function lineIntersectsRect(p1, p2, r)
	return lineIntersectsLine(p1, p2, jutils.vec2.new(r.x, r.y), jutils.vec2.new(r.x+r.width, r.y)) or
		   lineIntersectsLine(p1, p2, jutils.vec2.new(r.x+r.width, r.y), jutils.vec2.new(r.x+r.width, r.y+r.height)) or
		   lineIntersectsLine(p1, p2, jutils.vec2.new(r.x + r.width, r.y + r.height), jutils.vec2.new(r.x, r.y+r.height)) or
		   lineIntersectsLine(p1, p2, jutils.vec2.new(r.x, r.y + r.height), jutils.vec2.new(r.x, r.y)) or
		   (rectangleContainsPoint(r, p1) and rectangleContainsPoint(r, p2))
end

function world:castRay(origin, direction, raydistance, rayaccuracy)
	local max_ray_search_distance = raydistance

	for i = 1, max_ray_search_distance, rayaccuracy do
		local current_point = origin + (direction*i)
			
		local raytx, rayty = grid.pixelToTileXY(current_point.x, current_point.y)		
		local tileat = self:getTile(raytx, rayty)

		if tileat ~= 0 then

			local tiledata = tiles:getByID(tileat)
			if tiledata.collide == true then
				print(tiledata.name)
				self:setTile(raytx, rayty, 0)
				local tx, ty, tw, th = (raytx*config.TILE_SIZE), (raytx*config.TILE_SIZE), config.TILE_SIZE, config.TILE_SIZE

				local result = lineIntersectsRect(origin, current_point, {x=tx, y=ty, width=tw, height=th})
				print("result", result)
				if result == true then return true end
			end
		end
	end
	return false
end


---------------------------------------
-- World's map functionality

---
function world:rawget(tilex, tiley, field, unsafe)

	assert(type(tilex) == "number")
	assert(type(tiley) == "number")
	local cx, cy, lx, ly = grid.getLocalCoordinates(tilex, tiley)
	local chunk = self:getchunk(cx, cy)

	if chunk then

		if chunk.loaded == false then
			if not (unsafe) then return -1 end
		end

		local exists = chunk[field]

		if exists then
			return chunk[field][lx][ly]
		end
	end
	return -1
end

---
function world:getTile(tilex, tiley)
	return self:rawget(tilex, tiley, "tiles", true)
end

---
function world:getTileState(tilex, tiley)
	return self:rawget(tilex, tiley, "states")
end

---
function world:getTileDamage(tilex, tiley)
	return self:rawget(tilex, tiley, "damage")
end

---
function world:getLight(tilex, tiley)
	assert(type(tilex) == "number")
	assert(type(tiley) == "number")
	local cx, cy, lx, ly = grid.getLocalCoordinates(tilex, tiley)
	local chunk = self:getchunk(cx, cy)

	if chunk then

		if chunk.loaded == false then
			return {-1, -1, -1}
		end

		local exists = chunk["light"]

		if exists then
			return {chunk["light"][1][lx][ly], chunk["light"][2][lx][ly], chunk["light"][3][lx][ly]}
		end
	end
	return {-1, -1, -1}
end

---
function world:getBackground(tilex, tiley)
	return self:rawget(tilex, tiley, "backgrounds")
end

---
function world:damageTile(tilex, tiley, additionaldamage)
	local tile = self:rawget(tilex, tiley, "tiles")
	local maxdamage = tiles:getByID(tile).hardness
	local damage = self:rawget(tilex, tiley, "damage")

	local newdamage = damage + additionaldamage

	if tile == tiles.WATER.id or tile == tiles.LAVA.id or tile == tiles.AIR.id then return end

	if newdamage >= maxdamage then
		
		self:setTile(tilex, tiley, 0, true)
		
	else
		self:rawset(tilex, tiley, "damage", newdamage)
	end
end

--- Directly sets a field without triggering updates.
-- @param field "tiles" | "damage" | "states" | "light"
function world:rawset(tilex, tiley, field, value, unsafe)
	local cx, cy, lx, ly = grid.getLocalCoordinates(tilex, tiley)
	local chunk = self:getchunk(cx, cy)

	if chunk then
		if chunk.loaded == false then
			if not (unsafe) then return -1 end
		end

		local exists = chunk[field]

		if exists then
			chunk[field][lx][ly] = value
			return
		else
			print("field doesn't exist")
		end
	end
	return -1
end

--- Sets the damage value of the tile. if damage exceeds the tile's hardness, it will break and drop an item.
function world:setTileDamage(tilex, tiley, damage)
	self:rawset(tilex, tiley, "damage", damage)
end

--- Sets the state of the tile and triggers tileupdates.
function world:setTileState(tilex, tiley, state)
	self:rawset(tilex, tiley, "states", state)

	self:tileUpdate(tilex, tiley - 1)
	self:tileUpdate(tilex, tiley + 1)
	self:tileUpdate(tilex + 1, tiley)
	self:tileUpdate(tilex - 1, tiley)
	self:tileUpdate(tilex, tiley)

end

--- Sets the background and fills the tileupdate flag for that tile.
function world:setBackground(tilex, tiley, id)
	self:rawset(tilex, tiley, "backgrounds", id)
	self:tileUpdate(tilex, tiley)
	channels.bgchange:push({tilex, tiley, id})
end

--- Sets the tile and fills the tileupdate flags of adjacent tiles.
-- @param tilex
-- @param tiley
-- @param tile
-- @param drop drop the previous tile.
-- @param ignorecallback should the onPlace callback be called for this tile
function world:setTile(tilex, tiley, tile, drop, ignorecallback)
	assert(type(tilex) == "number")
	assert(type(tiley) == "number")
	assert(type(tile) == "number")

	local current = self:getTile(tilex, tiley)
	if current ~= tile then
		self:setTileState(tilex, tiley, 0)
		self:setTileDamage(tilex, tiley, 0)
			
		if drop then
			local tiledata = tiles:getByID(current)
			if tiledata.drop ~= false then
				local item = items[tiledata.drop]
				print("dropping entity")
				local e = self:addEntity("itemstack", item.id, 1)
				e:teleport(jutils.vec2.new(tilex*config.TILE_SIZE, tiley*config.TILE_SIZE))
			end
		end
			
		self:rawset(tilex, tiley, "tiles", tile, true)

		local tiledata = tiles:getByID(tile)

		if not ignorecallback then
			if tiledata.onplace then
				tiledata.onplace(self, tilex, tiley)
			end
		end
		
		self:tileUpdate(tilex, tiley)
		self:tileUpdate(tilex, tiley - 1)
		self:tileUpdate(tilex, tiley + 1)
		self:tileUpdate(tilex + 1, tiley)
		self:tileUpdate(tilex - 1, tiley)
		channels.tilechange:push({tilex, tiley, tile})	
	end
end

--- Get chunk at chunk region (cx, cy)
-- @param cx
-- @param cy
-- @return chunk
function world:getchunk(cx, cy)
	return self.chunks[grid.coordinatesToKey(cx, cy)]
end

---
function world:setchunkloaded(cx, cy)
	self.loaded[grid.coordinatesToKey(cx, cy)] = true
end

---
function world:tileUpdate(tilex, tiley)
	
	self:rawset(tilex, tiley, "tileupdate", true)
end

---
function world:randomTick(wx, wy)
	local tileid = self:getTile(wx, wy)
	local data = tiles:getByID(tileid)

	if data.randomupdate then
		data.randomupdate(self, wx, wy)
	end
end

---
function world:chunkRandomTileUpdates(chunk)
	local wx, wy = chunk.position.x, chunk.position.y
	for i = 1, self.random_tick_speed do
		local randx = math.random(1, config.CHUNK_SIZE)
		local randy = math.random(1, config.CHUNK_SIZE)
		self:randomTick((wx * config.CHUNK_SIZE) + randx, (wy * config.CHUNK_SIZE) + randy)
	end
end

---
function world:chunkTileUpdates(chunk)
	local count = 0
	local lightcount = 0
	local wx, wy = chunk.position.x, chunk.position.y
	
	for dx = 1, config.CHUNK_SIZE do
		for dy = 1, config.CHUNK_SIZE do
			-- the tile update
			if count > config.MAX_TILE_UPDATES_PER_FRAME then
				return
			end

			if chunk.tileupdate[dx][dy] == true then
				chunk.tileupdate[dx][dy] = false
				local tile = chunk.tiles[dx][dy]
				if tile > 0 then
					local data = tiles:getByID(tile)

					if data.tileupdate then
						data.tileupdate(self, (wx * config.CHUNK_SIZE) + dx - 1, (wy * config.CHUNK_SIZE) + dy - 1)
						if tile ~= tiles.WATER.id and tile ~= tiles.LAVA.id then
							count = count + 1
						else
							count = count + 0.25
						end
					end
				end
			end
		end
	end
end

---
function world:map_clearChunkFields()
	for key, chunk in pairs(self.chunks) do
		
		chunk.requested = false
		chunk.visible = false
		chunk.requestedFully = false
	end
end

---
function world:map_pullLoadedChunks()
	local newChunk = channels.returnchunk:pop()

	if newChunk then
			
		local key = newChunk[1]
		local chunk = newChunk[2]
		
		if self.waitinglist[key] == true then
			self.waitinglist[key] = nil
		else
			print("was not expecting???", key, chunk)
		end
		chunk.requested = true
		chunk.visible = true
		self.chunks[key] = chunk
	end
end

---
function world:map_fillChunkFields()
	local fx, fy = self.focuspoint.x, self.focuspoint.y
	
	local genradius = config.CHUNK_DRAW_RADIUS + config.CHUNK_SIMULATION_RADIUS + config.CHUNK_BUFFER_RADIUS

	for cx = -genradius, genradius do
		for cy = -genradius, genradius do
			local chunk = self:getchunk(fx+cx, fy+cy)

			if not chunk then
				local key = grid.coordinatesToKey(fx+cx, fy+cy)

				if self.waitinglist[key] ~= true then
					--self.chunks[key] = chunking:newstruct(fx+cx, fy+cy)
					--chunk = self.chunks[key]
					channels.loadchunk:push({key})
					self.waitinglist[key] = true
				end
			else
				chunk.requested = true
			end
			--
		end
	end

	local simradius = config.CHUNK_DRAW_RADIUS + config.CHUNK_SIMULATION_RADIUS
	for cx = -simradius, simradius do
		for cy = -simradius, simradius do
			local chunk = self:getchunk(fx+cx, fy+cy)
			if chunk then
				chunk.requestedFully = true
			end
		end
	end

	local drawradius = config.CHUNK_DRAW_RADIUS
	for cx = -drawradius, drawradius do
		for cy = -drawradius, drawradius do
			local chunk = self:getchunk(fx+cx, fy+cy)
			if chunk then
				if chunk.structurePass == true and chunk.beingThreaded == false then
					chunk.beingThreaded = true
					channels.addchunk:push({grid.coordinatesToKey(fx+cx, fy+cy), 
						{
							tiles =	chunk.tiles,
							backgrounds = chunk.backgrounds
						}})
				end
				chunk.visible = true
			end
		end
	end
end

---
function world:map_unloadOldChunks()
	-- cull chunks that are no longer "loaded"
	for key, chunk in pairs(self.chunks) do
		if chunk then
			if chunk.visible == false and chunk.requested == false then
				if chunk.beingThreaded == true then
					chunk.beingThreaded = false
					
					channels.dropchunk:push({key})
				end
				if self.no_save == false then
					channels.savechunk:push({key, chunk})
				end
				self.chunks[key] = nil
			end
		end
	end
end

---
function world:map_loadNewChunks()
	self.finishedTerrain = true
	for key, chunk in pairs(self.chunks) do
		if chunk.requested == true and chunk.terrainPass == false then
			self.finishedTerrain = false
		end
	end

	for key, chunk in pairs(self.chunks) do
		-- run terrainPass on chunks with no terrain
		local wx, wy = chunk.position.x, chunk.position.y
		if chunk.requested == true and chunk.terrainPass == false then
			self.terrainGenerator(chunk, self.seed)
			chunk.terrainPass = true
			return
		end

		if self.finishedTerrain then
			if chunk.requestedFully == true and chunk.terrainPass == true and chunk.structurePass == false then
				
				for x = 1, config.CHUNK_SIZE do
					for y = 1, config.CHUNK_SIZE do
						self.structureGenerator(self, ((wx) * config.CHUNK_SIZE) + x - 1, ((wy) * config.CHUNK_SIZE) + y - 1)
					end
				end
				chunk.structurePass = true
				chunk.loaded = true

				for i = 1, 5 do
					self:chunkTileUpdates(chunk)
				end
				for i = 1, 32 do
					self:chunkRandomTileUpdates(chunk)
				end
				return
			end
		end
	end
end

------------------------------------------------------

local function is_solid(world, tx, ty)
	local t = world:getTile(tx, ty)

	if t == tiles.AIR.id or t == tiles.OVERGROWTH.id or t == tiles.VINE.id then
		return false
	end

	return true
end

local function try_zombie_spawn(gameworld, tx, ty)

	-- NOTE: zombie spawn mechanics only check if there is a 1x3 region availible for spawning
	-- must be night time
	if not (gameworld.worldtime > (60*18) or gameworld.worldtime < (60*6)) then return end

	local light = gameworld:getLight(tx, ty)

	-- must be fairly dark in this spot
	if (light[1]+light[2]+light[3]) > 0.5 then return end

	-- selected tile must be solid, and there must be 3 pockets of air above
	if is_solid(gameworld, tx, ty) == false then return end

	if is_solid(gameworld, tx, ty-1) then return end
	if is_solid(gameworld, tx, ty-2) then return end
	if is_solid(gameworld, tx, ty-3) then return end


	local mob = gameworld:addEntity("zombie")
	local rx, ry = tx*config.TILE_SIZE, ty*config.TILE_SIZE

	-- make sure zombie doesn't spawn halfway in the ground
	ry = ry - mob.boundingbox.y
					
	mob:teleport(jutils.vec2.new(rx, ry))
end


local function try_flower_spawn(gameworld, tx, ty)

	-- must be daytime
	if not (gameworld.worldtime > (7*60) and gameworld.worldtime < (60*17)) then return end

	-- needs to be on grass
	if gameworld:getTile(tx, ty) ~= tiles.GRASS.id then return end
	if gameworld:getTile(tx+1, ty) ~= tiles.GRASS.id then return end

	-- needs a 2x2 of free space above
	if is_solid(gameworld, tx, ty-1) then return end
	if is_solid(gameworld, tx, ty-2) then return end
	if is_solid(gameworld, tx+1, ty-1) then return end
	if is_solid(gameworld, tx+1, ty-2) then return end

	local mob = gameworld:addEntity("flower")
	local rx, ry = tx*config.TILE_SIZE, ty*config.TILE_SIZE	
	mob:teleport(jutils.vec2.new(rx, ry))
end

local mob_weights = {
	[1] = {
		weight = 0.25,
		func = try_zombie_spawn,
	},
	[2] = {
		weight = 0.15,
		func = try_flower_spawn,
	}
}

local function mob_spawn_pass(gameworld, tx, ty)

	local selected_mob = math.random(#mob_weights)

	local mob_roll = math.random()

	local weight = mob_weights[selected_mob].weight

	if mob_roll < weight then

		local spawn_func = mob_weights[selected_mob].func

		spawn_func(gameworld, tx, ty)
	end	
end

---
function world:map_updateCurrentChunks()
	
	for key, chunk in pairs(self.chunks) do
		if chunk.visible == true and chunk.loaded == true then
			self:chunkTileUpdates(chunk)
			self:chunkRandomTileUpdates(chunk)
		end

		-- entity spawning
		-- chunk must be off screen and fully generated
		if chunk.visible == false and chunk.requestedFully == true then
			-- max 50 entities
			-- random roll chance to spawn
			if math.random() > 0.95 and #self.entities < 50 then
				--print("entity spawn attempt")
				-- pick random point in chunk
				local randx, randy = math.random(1, config.CHUNK_SIZE), math.random(1, config.CHUNK_SIZE)
				-- get chunk's world position
				local wx, wy = chunk.position.x*config.CHUNK_SIZE, chunk.position.y*config.CHUNK_SIZE
				-- add the two together to get the world position of the chosen spawnpoint
				local tx, ty = wx+randx, wy+randy

				mob_spawn_pass(self, tx, ty)
			end
		end
	end
end
----------------------------------------------------------------------------------
-- ENTITY AND COLLISION HANDLING

local lightthing = 0
local emitlighttimer = 0

---
function world:updateEntities(dt)
	lightthing = lightthing + dt
	emitlighttimer = emitlighttimer + dt
	for idx, entity in pairs(self.entities) do
		entity:update(dt)

		-- update camera position to player
		if entity:isA("Player") then
			local player = entity -- (cast)
			local camera_pos = self.camera.position

			-- if camera is falling behind the player
			-- we should lerp much faster
			if camera_pos:distance(player.position) > 2000 then
				self.camera.position = player.position
			else
				self.camera.position = camera_pos:lerp(player.position, (dt*4))
			end
		end

		if emitlighttimer > (1/20) then
			if entity.lightemitter then
				local tx, ty = grid.pixelToTileXY(entity.position.x, entity.position.y)
				channels.setlight:push({tx, ty, entity.lightemitter[1], entity.lightemitter[2], entity.lightemitter[3]})
			end
		end

		-- remove entity references if they are dead (allow garbage collection)
		-- determine if entity is outside of loaded chunks (so we can kill it)
		local x, y = self.focuspoint.x*config.CHUNK_SIZE*config.TILE_SIZE, self.focuspoint.y*config.CHUNK_SIZE*config.TILE_SIZE
		local radius = config.CHUNK_DRAW_RADIUS+config.CHUNK_SIMULATION_RADIUS+config.CHUNK_BUFFER_RADIUS

		radius = (radius * config.CHUNK_SIZE) * config.TILE_SIZE

		if entity:isA("PhysicalEntity") and (entity:isA("Player")==false) then
			if entity.position:distance(jutils.vec2.new(x, y)) > radius then
				entity.unloadtimer = entity.unloadtimer + dt
			else
				entity.unloadtimer = 0
			end

			if entity.unloadtimer > 1 then
				entity.dead = true
			end
		end

		local tx, ty = grid.pixelToTileXY(entity.position.x, entity.position.y)

		if lightthing > (1/10) then
			entity.light = self:getLight(tx, ty)
		end

		if entity.dead then
			entity:dies()
			if entity:isA("Player") == false then
				entity.world = nil
				self.entities[idx] = nil
				entity = nil
			end
		end
	end
	if lightthing > (1/10) then
		lightthing = 0
	end
	if emitlighttimer > (1/20) then
		emitlighttimer = 0
	end
end

---
function world:drawchunks()
	for _, chunk in pairs(self.chunks) do
		if chunk.visible == true then 
			local wx, wy = chunk.position.x, chunk.position.y

			local c_tiles = chunk.tiles
			local c_backgrounds = chunk.backgrounds
			local c_states = chunk.states
			local c_damages = chunk.damage
			local c_lights = chunk.light

			for x = 1, config.CHUNK_SIZE do
				for y = 1, config.CHUNK_SIZE do
					local tileid = c_tiles[x][y]
					local bgid = c_backgrounds[x][y]
					local r = c_lights[1][x][y]
					local g = c_lights[2][x][y]
					local b = c_lights[3][x][y]

					-- cheat mode used to look at the entire world
					if self.debug_fullbright then
						r = 1 g = 1 b = 1
					end

					if bgid > 0 then
						rendering.queuebackground(bgid, r, g, b, ((wx) * config.CHUNK_SIZE) + x - 1, ((wy) * config.CHUNK_SIZE) + y - 1)
					end
					--if type(tileid) ~= "number" then error(tileid) end
					if tileid > 0 then
						rendering.queuetile(tileid, c_states[x][y], c_damages[x][y], r, g, b, ((wx) * config.CHUNK_SIZE) + x - 1, ((wy) * config.CHUNK_SIZE) + y - 1)
					end
				end
			end
		end
	end
end

local tileUpdateDelta = 0
local redrawTick = 0

local push = 0

---
function world:getDaylight()
	local light = 0.15
	local timeDial = self.worldtime

	if timeDial > (5.5*60) and timeDial < (20*60) then
		light = light + 0.15
	end
	if timeDial > (5.75*60) and timeDial < (19.75*60) then
		light = light + 0.1
	end
	if timeDial > (6*60) and timeDial < (19.5*60) then
		light = light + 0.1
	end
	if timeDial > (6.25*60) and timeDial < (19.25*60) then
		light = light + 0.1
	end
	if timeDial > (6.5*60) and timeDial < (18.75*60) then
		light = light + 0.1
	end
	if timeDial > (6.75*60) and timeDial < (18.5*60) then
		light = light + 0.1
	end
	if timeDial > (7.25*60) and timeDial < (18.25*60) then
		light = light + 0.1
	end
	if timeDial > (7.5*60) and timeDial < (18*60) then
		light = light + 0.1
	end
	return light
end

---
function world:update(dt)
	local err = self.lightthread:getError()
	assert( not err, err )

	local err = self.chunkthread:getError()
	assert( not err, err )
	
	local num = channels.newlights:getCount()

	for i = 1, num do
		local newlight = channels.newlights:pop()
		if i < (num-100) then return end
		if newlight then
			
			local key = newlight[1]
			local data = newlight[2]
			if self.chunks[key] then
				self.chunks[key].light = data
			end
		end
	end

	push = push + (dt/5)
	self.worldtime = self.worldtime + (dt)

	if self.worldtime > 1440 then
		self.worldtime = 0
		self.dayspassed = self.dayspassed + 1
		print("days passed", self.dayspassed)
	end

	self:map_clearChunkFields()
	self:map_pullLoadedChunks()
	self:map_fillChunkFields()
	self:map_loadNewChunks()
	self:map_unloadOldChunks()

	tileUpdateDelta = tileUpdateDelta + dt
	if tileUpdateDelta > 1/60 then
		self:map_updateCurrentChunks()
		tileUpdateDelta = 0
	end

	redrawTick = redrawTick + dt
	if redrawTick > (1/config.TILE_REDRAWS_PER_SECOND) then
		if self.ambientlight ~= self:getDaylight() then
			self.ambientlight = self:getDaylight()
			channels.setambient:push(self.ambientlight)
		end
		
		redrawTick = 0
		rendering.clearqueue()
		self:drawchunks()
	end

	self:updateEntities(dt)

	-- need to set world focus point
	-- for chunk loading origin
	local px, py = grid.pixelToTileXY(self.camera.position.x, self.camera.position.y)
	local camx, camy = grid.tileToChunkXY(px, py)
	local fp = jutils.vec2.new(camx, camy)

	self.focuspoint = fp
end

function world:drawEntities()
	for _, entity in pairs(self.entities) do
		entity:draw()
	end
end

-- a color is assigned for each 3-hour segment of the day
-- and the colors are lerped between


local function get_sky_color(time)
	time = time % 24

	return sky_color_table[time]
end

local SHOW_ENTITY_LIST = false


local cloud_bg_texture = love.graphics.newImage("assets/clouds.png")
local star_bg_texture = love.graphics.newImage("assets/stars.png")
local cave_bg_texture = love.graphics.newImage("assets/cavebg.png")

function world:draw()

	-- store graphics coordinate info to reset later
	love.graphics.push()

	-- override any background crap

	-- holy shit
	local world_time_hour = math.floor(self.worldtime/60)
	local world_time_mult = math.floor(world_time_hour/3)*3
	local start_sky_color = get_sky_color(world_time_mult)
	local finish_sky_color = get_sky_color(world_time_mult+3)
	local current_3hour_step = (self.worldtime % 180)

	local alpha = current_3hour_step / 180
	local sky_color = jutils.color.lerp(start_sky_color, finish_sky_color, alpha)

	love.graphics.setColor(sky_color)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

	-- make screen center the origin of screen coordinates
	love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
	-- zoom in coordinates
	love.graphics.scale(self.camera.zoom, self.camera.zoom)

	-- rounding the camera position is nessecary
	-- to eliminate line flickering between
	-- grid objects (tiles and backgrounds)
	local camx = jutils.math.round(self.camera.position.x, 1)
	local camy = jutils.math.round(self.camera.position.y, 1)	
	
	-- move to camera position (make camx and camy center of screen)
	love.graphics.translate(-camx, -camy)

	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
	input.setTransformedMouse(math.floor(mx), math.floor(my))

	local camera_pos = self.camera.position


	-- draw cloud background
	local bgscroll = 2
	local texsize = 512
	
	local x = (camera_pos.x) / bgscroll 
	local y = camera_pos.y / bgscroll

	local posx = math.floor(x/texsize) 
	local posy = math.floor(y/texsize)
	
	for dx = -3, 3 do
		for dy = -3, 3 do
				
			local shiftx = x + ( (posx+dx)*texsize)
			local shifty = y + ( (posy+dy)*texsize)

			if self.camera.position.y/8 > config.UNDERGROUND_DEPTH then

				if self:getPlayer() ~= nil then
					local tx, ty = grid.pixelToTileXY(shiftx, shifty)

					local color = self:getPlayer().light

					-- TODO: make the bgcolor darker for the farther out tiles
					love.graphics.setColor(color)
					love.graphics.draw(cave_bg_texture, shiftx, shifty, 0, 2, 2)
				end
			else
				love.graphics.setColor(self.ambientlight, self.ambientlight, self.ambientlight, self.ambientlight)
				love.graphics.draw(cloud_bg_texture, shiftx, shifty, 0, 2, 2)
				love.graphics.setColor(1-self.ambientlight, 1-self.ambientlight, 1-self.ambientlight, 1-self.ambientlight)
				love.graphics.draw(star_bg_texture, shiftx, shifty, 0, 2, 2)
			end

			--love.graphics.setColor(self.ambientlight, self.ambientlight, self.ambientlight, self.ambientlight)
			--love.graphics.draw(bgtexture, dayquad, shiftx, shifty, 0, 2, 2)
			--love.graphics.setColor(1-self.ambientlight, 1-self.ambientlight, 1-self.ambientlight, 1-self.ambientlight)
			--love.graphics.draw(bgtexture, nightquad, shiftx, shifty, 0, 2, 2)
		end
	end

	love.graphics.setColor(1,1,1)
	-- draw foreground and background tiles
	rendering.drawqueue()
	-- draw entities
	self:drawEntities()
	
	love.graphics.pop()

	if SHOW_ENTITY_LIST then
		love.graphics.setColor(0,0,0)
		local inc = 0
		for _, entity in pairs(self.entities) do
			love.graphics.print(entity.classname..", ".. tostring(entity), 800, inc*12)
			inc = inc + 1
		end
	end
end

return world
