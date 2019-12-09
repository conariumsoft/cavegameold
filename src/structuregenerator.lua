--- Per-Tile world generation (second pass) used for structures.
-- Much slower than terraingenerator.lua, so use this with more thought.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software

local noise = require("src.noise")
local config = require("config")
local jutils = require("src.jutils")
local tiles = require("src.tiles")
local backgrounds = require("src.backgrounds")
local grid = require("src.grid")
local maketree = require("data.structures.trees.maketree")
local bigtree = require("data.structures.trees.bigtree")
local terrainMath = require("src.terrain")
local biomes = require("src.biomes")

local treeGroveDensity = 0.3 -- 0 - 1, how dense groves of trees are populated


local houses = {
	"data.structures.underhouse.house1",
	"data.structures.underhouse.house2",
}

local function generateFromFile(structure, world, tx, ty)
	for key, name in pairs(structure.tiles) do
		local x, y = grid.keyToCoordinates(key)
		world:rawset(tx+x, ty+y, "tiles", tiles[name].id, true)

		if name == "WATER" or name == "LAVA" then
			world:rawset(tx+x, ty+y, "states", 8, true)
		end

		if name == "CHEST_GENERATOR" then
			world:rawset(tx+x, ty+y, "states", 2, true)
			world:rawset(tx+x, ty+y, "tileupdate", true, true)
		end
	end

	for key, name in pairs(structure.backgrounds) do
		local x, y = grid.keyToCoordinates(key)
		world:rawset(tx+x, ty+y, "backgrounds", backgrounds[name].id, true)
	end
end

return function(world, tilex, tiley)

	local surface_noise = terrainMath.getSurfaceNoise(tilex, tiley)

	if surface_noise > -200 then
		-- TODO: sky structures
	end

	if surface_noise > -10 and surface_noise < 10 then
		local chosen_biome = biomes.getBiome(tilex)

		if terrainMath.getSurfaceNoise(tilex, tiley) < 1 then
			local watchtowerNoise = noise.noise(tilex, tiley, 64, 64)


			if watchtowerNoise > 0 and watchtowerNoise < 0.02 and math.random() > 0.95 then
				generateFromFile(require("data.structures.hendrix"), world, tilex, tiley)
			end
		end


		if chosen_biome == "desert" then
			-- TODO: pyramid generation

			if world:getTile(tilex, tiley) == tiles.SAND.id then
				local roll = math.random()
	
				if roll > 0.9 then
					if terrainMath.getSurfaceNoise(tilex, tiley) < 1 then
						if world:getTile(tilex, tiley-1) == tiles.AIR.id then
							world:setTile(tilex, tiley-1, tiles.CACTUS.id)
						end
					end
				end
			end

			if math.floor(surface_noise) == 1 then
				if tilex % 64 == 0 then
					if math.random() > 0.95 then
						
						generateFromFile(require("data.structures.pyramid"), world, tilex, tiley)
					end
				end
			end
		end

		if chosen_biome == "forest" then
			-- TODO: tree generation
			local tree3Noise = noise.noise(tilex+128, tiley, 18, 18)
			local doTree = math.random()
			if treeGroveDensity > doTree then

				if world:getTile(tilex, tiley) == tiles.GRASS.id then
					if tree3Noise > 0.95 then
						bigtree(world, tilex, tiley-1)
					else
						maketree(world, tilex, tiley)
					end
				end
			end
		end

		if chosen_biome == "plains" then			
			if math.floor(surface_noise) == 1 then
				local mineshaftNoise = noise.noise(tilex, tiley, 64, 64)
				if mineshaftNoise > 0.95 then
					local rand = math.random()

					if rand > 0.9 then
						print("bruj")
						generateFromFile(require("data.structures.mineshaft"), world, tilex, tiley-2)
					end
				end
			end
		end
	end

	if surface_noise > 300 then
		-- TODO: small structures not very deep underground
		local undergroundHouseNoise = noise.noise(tilex, tiley, 128, 128)
		if undergroundHouseNoise > 0.99 then

			if world:getTile(tilex, tiley) == tiles.AIR.id then
				local chance = math.random()
				if chance > 0.99 then
					generateFromFile(require(houses), world, tilex, tiley)
				end
			end
		end
	end

	if surface_noise > 1000 then
		-- TODO: larger dungeons
		local castleNoise = noise.noise(tilex, tiley, 128, 128)
		if castleNoise > 0.99 and math.random() > 0.9 then 
			local chance = math.random()
			if chance > 0.99 then
				generateFromFile(require("data.structures.castle"), world, tilex, tiley)
			end
		end
	end
end