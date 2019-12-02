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

local dungeonlist = {
	"data.structures.dungeons.a",
	"data.structures.castle"
}

local treeGroveDensity = 0.15 -- 0 - 1, how dense groves of trees are populated
local treeGroveRarity = 0.3 -- 0 - 1, how common tree groves are
local treeGroveSize = 256 -- the size of groves of trees


local function treeGeneration(world, tilex, tiley)

	if terrainMath.getSurfaceNoise(tilex, tiley) < 1 then
		if terrainMath.getBiomeNoise(tilex) > 0.4 then

			local treeNoise = noise.noise(tilex, tiley, treeGroveSize, treeGroveSize)
			local tree3Noise = noise.noise(tilex+128, tiley, 18, 18)

			local doTree = math.random()
			if treeNoise > (treeGroveRarity) and treeGroveDensity > doTree then

				if world:getTile(tilex, tiley) == tiles.GRASS.id then
					if tree3Noise > 0.8 then
						bigtree(world, tilex, tiley+1)
					else
						maketree(world, tilex, tiley)
					end
				end
			end
		end

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
	end
end

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

-- a modified form of generateFromFile, used for tree generation
-- only air and leaves tiles can be overwritten.
local function generate_tree_file(structure, world, tx, ty)
	for key, name in pairs(structure.tiles) do

		local x, y = grid.keyToCoordinates(key)


	end
end

local lastDungeonPos = jutils.vec2.new(0, 0)

local function brickDungeonGeneration(world, tilex, tiley)

	local current = jutils.vec2.new(tilex, tiley)

	local generatorRoll = math.random(1, 20)

	if world:getTile(tilex, tiley) == tiles.STONE.id and world:getTile(tilex, tiley-20) == tiles.AIR.id then
		if lastDungeonPos:distance(current) > 80 then
			
			lastDungeonPos = current
			if generatorRoll ~= 1 then return end

			local dungeonToGenerate = dungeonlist[math.random(1, #dungeonlist)]

			local struct = require(dungeonToGenerate)

			generateFromFile(struct, world, tilex, tiley)
			
		end
	end
end


local structures = {}

return function(world, tilex, tiley)

	local surface_noise = terrainMath.getSurfaceNoise(tilex, tiley)

	if surface_noise > -200 then
		-- TODO: sky structures
	end

	if surface_noise > -10 and surface_noise < 10 then
		local chosen_biome = biomes.getBiome(tilex)


		if chosen_biome == "desert" then
			-- TODO: pyramid generation
			if math.floor(surface_noise) == 1 then
				if tilex % 64 == 0 then
					if math.random() > 0.95 then
						print("bruj")
						generateFromFile(require("data.structures.pyramid"), world, tilex, tiley)
					end
				end
			end
		end

		if chosen_biome == "forest" then
			-- TODO: tree generation
			if math.floor(surface_noise) == 0 then
				local treeNoise = noise.noise(tilex, tiley, treeGroveSize, treeGroveSize)

				local doTree = math.random()
				if treeNoise > (treeGroveRarity) and treeGroveDensity > doTree then
					-- TODO: special handling for generating trees
					generateFromFile(require("data.structures.uglytree"), world, tilex, tiley)
					
				end
			end
		end
	end

	if surface_noise > 300 then
		-- TODO: small structures not very deep underground

	end

	if surface_noise > 1000 then
		-- TODO: larger dungeons

		if tilex % 512 == 0 and tiley % 512 == 0 then
			local chance = math.random()

			if chance > 0.99 then
				generateFromFile(require("data.structures.castle"), world, tilex, tiley)
			end
		end
	end

	treeGeneration(world, tilex, tiley)
	brickDungeonGeneration(world, tilex, tiley)

end