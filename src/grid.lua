--- Grid space utilities.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software
local config = require("config")
local jutils = require("src.jutils")

local grid = {}

---
function grid.keyToCoordinates(key)
	local coords = jutils.string.explode(key, config.CHUNK_COORDINATE_DIVIDER)
	return coords[1], coords[2]
end

---
function grid.coordinatesToKey(x, y)
	local key = x .. config.CHUNK_COORDINATE_DIVIDER .. y
	return key
end

---
function grid.pixelToTileXY(pixelx, pixely)
	local x = math.floor(pixelx / config.TILE_SIZE)
	local y = math.floor(pixely / config.TILE_SIZE)
	return x, y
end

---
function grid.tileToChunkXY(tilex, tiley)
	local x = math.floor(tilex / config.CHUNK_SIZE)
	local y = math.floor(tiley / config.CHUNK_SIZE)

	return x, y
end

---
function grid.getLocalCoordinates(worldx, worldy)
	local chunkx = math.floor(worldx / config.CHUNK_SIZE)
	local chunky = math.floor(worldy / config.CHUNK_SIZE)
	local localx = (worldx % (config.CHUNK_SIZE)) + 1
	local localy = (worldy % (config.CHUNK_SIZE)) + 1
	return chunkx, chunky, localx, localy
end

return grid