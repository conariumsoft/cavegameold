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

local treeGroveDensity = 0.3 -- 0 - 1, how dense groves of trees are populated


local houses = {
	"data.structures.underhouse.house1",
	"data.structures.underhouse.house2",
}

local oak_tree_max_height = 15
local oak_tree_min_height = 5

local function check_trunk_is_valid(world, x, y, goal_height)
	for inc = 1, goal_height + 1 do
		if not world:getTile(x, y - inc) == tiles.AIR.id then
			return false
		end

	end
	return true
end

local function gen_oak_tree(world, x, y)
	local goal_height = math.random(oak_tree_min_height, oak_tree_max_height)


	if check_trunk_is_valid(world, x, y, goal_height) == false then return end

	if world:getTile(x-1, y-1) == tiles.AIR.id and world:getTile(x-1, y) ~= tiles.AIR.id then
		world:setTile(x-1, y-1, tiles.ROOT_LEFT.id)
	end
	if world:getTile(x+1, y-1) == tiles.AIR.id and world:getTile(x+1, y) ~= tiles.AIR.id then
		world:setTile(x+1, y-1, tiles.ROOT_RIGHT.id)
	end

	world:setTile(x, y-1, tiles.ROOT.id)

	for inc = 2, goal_height do
		world:setTile(x, y - inc, tiles.LOG.id)
	end
	local canopysize = 2
	for deltax = -canopysize, canopysize do
		for deltay = -canopysize, canopysize do
			if world:getTile(x + deltax, (y - goal_height) + deltay) == tiles.AIR.id then
				world:setTile(x + deltax, (y - goal_height) + deltay, tiles.LEAVES.id)
			end
		end
	end
end

local spruce_tree_max_height = 25
local spruce_tree_min_height = 15

local function gen_spruce_tree(world, x, y)
	local goal_height = math.random(spruce_tree_max_height, spruce_tree_max_height)


	if check_trunk_is_valid(world, x, y, goal_height) == false then return end


	world:setTile(x, y-1, tiles.PINE_ROOT.id)

	for inc = 2, goal_height do
		world:setTile(x, y - inc, tiles.PINE_LOG.id)
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


local function treeGenerate(structure, world, tx, ty)
	for key, name in pairs(structure.tiles) do

		
		local x, y = grid.keyToCoordinates(key)
		local current = world:getTile(tx+x, ty+y)

		if current == tiles.AIR.id or current == tiles.LEAVES.id or current == tiles.PINE_LEAVES.id then
			world:rawset(tx+x, ty+y, "tiles", tiles[name].id, true)
		end
	end
end


local pine_tree = require("data.structures.trees.pine_tree")
local pine_tree_1 = require("data.structures.trees.pine_tree1")

return function(world, tilex, tiley)

	local surface_noise = terrainMath.getSurfaceNoise(tilex, tiley)

	if surface_noise < -200 then
		local tree3Noise = noise.noise(tilex+128, tiley, 18, 18)
		local doTree = math.random()
		if treeGroveDensity > doTree then

			if world:getTile(tilex, tiley) == tiles.DIRT.id and world:getTile(tilex, tiley-1) == tiles.AIR.id then
				if tree3Noise > 0.95 then
					treeGenerate(pine_tree, world, tilex, tiley)
				else
					treeGenerate(pine_tree_1, world, tilex, tiley)
				end
			end
		end
	end

	if surface_noise > -10 and surface_noise < 10 then
		local chosen_biome = terrainMath.getBiomeAt(tilex)

		if terrainMath.getSurfaceNoise(tilex, tiley) < 1 then
			local watchtowerNoise = noise.noise(tilex, tiley, 64, 64)


			if watchtowerNoise > 0 and watchtowerNoise < 0.01 and math.random() > 0.98 then
				generateFromFile(require("data.structures.hendrix"), world, tilex, tiley)
			end
		end


		if chosen_biome == "alpine" then
			local tree3Noise = noise.noise(tilex+128, tiley, 18, 18)
			local doTree = math.random()
			if treeGroveDensity > doTree and tilex%4 == 0 then

				if world:getTile(tilex, tiley) == tiles.DIRT.id then
					--treeGenerate(pine_tree_1, world, tilex, tiley)
					gen_spruce_tree(world, tilex, tiley)
				end
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
						gen_oak_tree(world, tilex, tiley)
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
					generateFromFile(require(houses[math.random(#houses)]), world, tilex, tiley)
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