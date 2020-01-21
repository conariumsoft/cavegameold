--- Chunk encoding and decoding.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software

local jutils = require("src.jutils")
local json = require("src.json")
local config = require("config")
local tiles = require("src.tiles")
local backgrounds = require("src.backgrounds")


local chunking = {}

local construct = jutils.table.constructArray

local function newChunkStruct(cx, cy)
	return {
		position = jutils.vec2.new(cx, cy),
		tiles = construct(construct(0, config.CHUNK_SIZE), config.CHUNK_SIZE), -- 2D array with default 0
		backgrounds = construct(construct(0, config.CHUNK_SIZE), config.CHUNK_SIZE),
		states = construct(construct(0, config.CHUNK_SIZE), config.CHUNK_SIZE),
		damage = construct(construct(0, config.CHUNK_SIZE), config.CHUNK_SIZE),
		tileupdate = construct(construct(false, config.CHUNK_SIZE), config.CHUNK_SIZE), -- 2D array with default false
		light = {
			[1] = construct(construct(0, config.CHUNK_SIZE), config.CHUNK_SIZE),
			[2] = construct(construct(0, config.CHUNK_SIZE), config.CHUNK_SIZE),
			[3] = construct(construct(0, config.CHUNK_SIZE), config.CHUNK_SIZE)
		},
		requested = false, -- if the chunk has been requested by the world
		requestedFully = false,
		beingThreaded = false,
		loaded = false, -- fully loaded
		terrainPass = false,
		structurePass = false,
		visible = false, -- to be rendered
	}
end
---
function chunking:newstruct(cx, cy)
	return newChunkStruct(cx, cy)
end
---
function chunking:encode(chunk)
	
	local savedata = {
		x = chunk.position.x,
		y = chunk.position.y,
		tiles = {

		},
		states = {

		},
		backgrounds = {

		},
		terrainPass = false,
		structurePass = false,
		loaded = false,
		chunksize = config.CHUNK_SIZE,
	}

	savedata.loaded = chunk.loaded
	savedata.terrainPass = chunk.terrainPass
	savedata.structurePass = chunk.structurePass
	savedata.lastVersion = config.DATA_VERSION

	local index = 1
	for x = 1, config.CHUNK_SIZE do
		savedata.tiles[x] = {}
		savedata.states[x] = {}
		savedata.backgrounds[x] = {}
		for y = 1, config.CHUNK_SIZE do
			savedata.tiles[x][y] = chunk.tiles[x][y]
			savedata.states[x][y] = chunk.states[x][y]
			savedata.backgrounds[x][y] = chunk.backgrounds[x][y]
			index = index + 1
		end
	end


	-- here is a test

	

	-- TODO: use compression
	return json.encode(savedata)
	--return love.data.compress("string", "lz4", json.encode(savedata))
end

---
function chunking:decode(chunkstring)
	if #chunkstring == 0 then return false end
	--local savedata = json.decode(love.data.decompress("string", "lz4", chunkstring))
	local savedata = json.decode(chunkstring)

	local chunk = newChunkStruct(savedata.x, savedata.y)

	chunk.loaded = savedata.loaded
	chunk.terrainPass = savedata.terrainPass
	chunk.structurePass = savedata.structurePass

	local lastVersion = savedata.lastVersion

	if lastVersion == config.DATA_VERSION then
		local index = 1
		for x = 1, config.CHUNK_SIZE do
			for y = 1, config.CHUNK_SIZE do
				chunk.tiles[x][y] = savedata.tiles[x][y]
				chunk.states[x][y] = savedata.states[x][y]
				chunk.backgrounds[x][y] = savedata.backgrounds[x][y]
				index = index + 1
			end
		end
	else

		local info = love.filesystem.getInfo("conversionmaps/"..lastVersion)

		if info then
			local data = love.filesystem.read("conversionmaps/"..lastVersion)
			local map = json.decode(data)

			local index = 1
			for x = 1, config.CHUNK_SIZE do
				for y = 1, config.CHUNK_SIZE do

					local loadedTileID = savedata.tiles[x][y]

					local name
					for key, id in pairs(map.tiles) do
						if id == loadedTileID then
							name = key
						end
					end
					
					local properTile = tiles[name].id
					chunk.tiles[x][y] = properTile
					local loadedBackgroundID = savedata.backgrounds[x][y]

					local bgname
					for key, id in pairs(map.backgrounds) do
						if id == loadedBackgroundID then
							bgname = key
						end
					end

					local properBG = backgrounds[bgname]
					chunk.backgrounds[x][y] = properBG.id

					chunk.states[x][y] = savedata.states[x][y]
					index = index + 1
				end
			end

		else
			return newChunkStruct(savedata.x, savedata.y)
		end

	end

	return chunk
end

return chunking