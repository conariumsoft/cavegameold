--- Per-Chunk (first pass) world generation script.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software

local generator = {}

local config = require("config")
local tiles = require("src.tiles")
local backgrounds = require("src.backgrounds")

local basefreq = 15
local sys = 30

local DEEPWORLD_DEPTH = 300

local jutils = require("src.jutils")
local noise = require("src.noise")

local terrainMath = require("src.terrain")

local getSurfaceNoise = terrainMath.getSurfaceNoise
local getBiomeNoise = terrainMath.getBiomeNoise -- these are just surface biomes

local surface_biome_depth = 250

local function chunkSurfacePass(chunk)
	local worldx = chunk.position.x*config.CHUNK_SIZE
	local worldy = chunk.position.y*config.CHUNK_SIZE
	for x = 1, config.CHUNK_SIZE do
		for y = 1, config.CHUNK_SIZE do

			local level = getSurfaceNoise(worldx+x, worldy+y)
			
			
			if level > 10000 then
				chunk.tiles[x][y] = tiles.HELLROCK.id
			elseif level > (surface_biome_depth) then
				chunk.tiles[x][y] = tiles.STONE.id
			
				-- TODO: blend the biome into stone
			elseif level > 0 then
				
				if chunk.tiles[x][y] == tiles.AIR.id then
					chunk.tiles[x][y] = tiles.STONE.id

					
		
					local chosen_biome = terrainMath.getBiomeAt(worldx+x)

					if chosen_biome == "desert" then

						if getSurfaceNoise(worldx+x, worldy+y-10) <= 0 then
							chunk.tiles[x][y] = tiles.SAND.id
						elseif getSurfaceNoise(worldx+x, worldy+y-30) <= 0 then
							chunk.tiles[x][y] = tiles.SAND.id
							chunk.backgrounds[x][y] = backgrounds.SANDSTONE.id
						else
							chunk.backgrounds[x][y] = backgrounds.SANDSTONE.id
							
							local yee = (worldy+y-200)/20
							local chance = noise.noise(worldx+x, worldy+y, 2, 2)-yee


							if chance > 0.5 then
								chunk.tiles[x][y] = tiles.SANDSTONE.id
							end
						end
					elseif chosen_biome == "plains" or chosen_biome == "forest" then
						-- will be grass above..
						if getSurfaceNoise(worldx+x, worldy+y-1) <= 0 then
							chunk.tiles[x][y] = tiles.GRASS.id

						elseif getSurfaceNoise(worldx+x, worldy+y-20) <= 0 then

							chunk.tiles[x][y] = tiles.DIRT.id
							chunk.backgrounds[x][y] = backgrounds.DIRT.id
						else
							chunk.backgrounds[x][y] = backgrounds.DIRT.id
							local yee = (worldy+y-200)/20
							local chance = noise.noise(worldx+x, worldy+y, 2, 2)-yee


							if chance > 0.5 then
								chunk.tiles[x][y] = tiles.DIRT.id
							end
							
						end
					elseif chosen_biome == "wetlands" then
						local cycle = noise.noise1D((worldx+x)/4)*2
						if getSurfaceNoise(worldx+x, worldy+y-cycle) <= 0 then
							chunk.tiles[x][y] = tiles.WATER.id
							chunk.states[x][y] = 8
							chunk.tileupdate[x][y] = true
						elseif getSurfaceNoise(worldx+x, worldy+y-cycle - 1) <= 0 then
							chunk.tiles[x][y] = tiles.GRASS.id
							-- TODO: some kind of mud grass
						elseif getSurfaceNoise(worldx+x, worldy+y-200) <= 0 then
							chunk.tiles[x][y] = tiles.MUD.id
							chunk.backgrounds[x][y] = backgrounds.MUD.id
						end
					elseif chosen_biome == "alpine" then

							
						if getSurfaceNoise(worldx+x, worldy+y-1) <= 0 then
							chunk.tiles[x][y] = tiles.DIRT.id

						elseif getSurfaceNoise(worldx+x, worldy+y-20) <= 0 then

							chunk.tiles[x][y] = tiles.DIRT.id
							chunk.backgrounds[x][y] = backgrounds.DIRT.id
						else
							chunk.backgrounds[x][y] = backgrounds.DIRT.id
							local yee = (worldy+y-200)/20
							local chance = noise.noise(worldx+x, worldy+y, 2, 2)-yee


							if chance > 0.5 then
								chunk.tiles[x][y] = tiles.DIRT.id
							end
							
						end

						local rockformations = noise.noise(worldx+x, worldy+y, 40, 30)

						if rockformations > 0.75 then
							chunk.tiles[x][y] = tiles.MOSSY_STONE.id
						end
					end
							
				end
			-- floating islands
			elseif level < -200 then
				local yes = level % 64
				local floatingislandnoise = noise.noise(worldx+x, worldy+y, 70, 70)
				local nos = floatingislandnoise - (yes/64)
				local nos2 = floatingislandnoise - (yes/80)

				if nos2 > 0.45 then
					chunk.tiles[x][y] = tiles.CLOUD.id
				end
				if nos > 0.55 then
					chunk.tiles[x][y] = tiles.DIRT.id
					if jutils.math.round(nos, 1) == 0.6 then
						chunk.tiles[x][y] = tiles.SKY_GRASS.id
					end
				end
			end

			-- TODO: move this out of surface pass
			local floodNoise = noise.noise(worldx+x-443, worldy+y+22, 64, 64)
			if floodNoise > 0.96 and chunk.tiles[x][y] ~= tiles.AIR.id then
				chunk.tiles[x][y] = tiles.WATER.id
				chunk.states[x][y] = 8
				chunk.backgrounds[x][y] = backgrounds.MUD.id
				chunk.tileupdate[x][y] = true
			end
		end
	end
end

local function chunkDetailPass(chunk)
	local worldx = chunk.position.x*config.CHUNK_SIZE
	local worldy = chunk.position.y*config.CHUNK_SIZE
	for x = 1, config.CHUNK_SIZE do
		for y = 1, config.CHUNK_SIZE do

			if getSurfaceNoise(worldx+x, worldy+y) > 10000 then

			else
				local dirtpile = noise.noise(worldx+x, worldy+y, 64, 64)

				if dirtpile > 0.85 and chunk.tiles[x][y] == tiles.STONE.id then
					chunk.tiles[x][y] = tiles.DIRT.id
				end

				local rockpile = noise.noise(worldx+x, worldy+y, 30, 30)

				if rockpile > 0.85 and (chunk.tiles[x][y] == tiles.GRASS.id or chunk.tiles[x][y] == tiles.DIRT.id) then
					chunk.tiles[x][y] = tiles.STONE.id
				end

				local claypile = noise.noise(worldx+x, worldy+y, 45, 45)

				if claypile > 0.9 and (chunk.tiles[x][y] == tiles.DIRT.id or chunk.tiles[x][y] == tiles.STONE.id) then
					chunk.tiles[x][y] = tiles.SOFT_CLAY.id
				end
			end
		end
	end
end

local function chunkCavernPass(chunk, seed)
	local worldx = chunk.position.x*config.CHUNK_SIZE
	local worldy = chunk.position.y*config.CHUNK_SIZE

	for x = 1, config.CHUNK_SIZE do
		for y = 1, config.CHUNK_SIZE do

			local surface = getSurfaceNoise(worldx+x, worldy+y)

			-- hell
			if surface > 10000 then
				local caveSeeder = noise.noise(worldx+x, worldy+y, 96, 96)
				local caveAutism = noise.noise(worldx+x, worldy+y, 16, 24)
				local caveBubble = noise.epicnoise(worldx+x, worldy+y, 345, 8) - (caveSeeder*0.3) - (caveAutism*0.3)

				if caveBubble > 0.7 and caveBubble < 0.9 then
					
					if x % 3 == 0 and y % 3 == 0 then
						chunk.tiles[x][y] = tiles.AIR.id
					else
						chunk.tiles[x][y] = tiles.LAVA.id
						chunk.states[x][y] = 8
						chunk.tileupdate[x][y] = true
					end

					chunk.backgrounds[x][y] = backgrounds.STONE.id
				end


			-- super deep caves
			elseif surface > 2000 then

				local caveSeeder = noise.noise(worldx+x, worldy+y, 128, 128)
				local caveAutism = noise.noise(worldx+x, worldy+y, 16, 16)
				local caveBubble = noise.epicnoise(worldx+x, worldy+y, 600, 6) - (caveSeeder*0.5) - (caveAutism*0.25)

				if caveBubble > 0.6 and caveBubble < 0.85 then

					local liquidNoise = noise.noise(worldx+x, worldy+y, 200, 200)

					if liquidNoise > 0.9 then
						chunk.tiles[x][y] = tiles.LAVA.id
						chunk.states[x][y] = 8
					elseif liquidNoise > 0.05 then
						chunk.tiles[x][y] = tiles.AIR.id
					else
						chunk.tiles[x][y] = tiles.WATER.id
						chunk.states[x][y] = 8
					end

					chunk.backgrounds[x][y] = backgrounds.STONE.id
				end

			-- deep caves
			elseif surface > 300 then
				local caveSeeder = noise.noise(worldx+x, worldy+y, 96, 96)
				local caveAutism = noise.noise(worldx+x, worldy+y, 16, 16)
				local caveBubble = noise.epicnoise(worldx+x, worldy+y, 400, 8) - (caveSeeder*0.5) - (caveAutism*0.25)

				if caveBubble > 0.7 and caveBubble < 0.95 then

					local liquidNoise = noise.noise(worldx+x, worldy+y, 100, 100)

					if liquidNoise > 0.95 then
						chunk.tiles[x][y] = tiles.LAVA.id
						chunk.states[x][y] = 8
					elseif liquidNoise > 0.1 then
						chunk.tiles[x][y] = tiles.AIR.id
					else
						chunk.tiles[x][y] = tiles.WATER.id
						chunk.states[x][y] = 8
					end

					chunk.backgrounds[x][y] = backgrounds.STONE.id
				end
			
			-- shallow caves
			elseif surface > 0 then
				local caveCircle = noise.epicnoise(worldx+x, worldy+y, 333, 3)

				local caveSeeder = noise.noise(worldx+x, worldy+y, 24, 24)
				local caveBubble = noise.epicnoise(worldx+x, worldy+y, 300, 3) - (caveSeeder*0.5)
					
				
				if caveCircle > 0.4 and caveCircle < 0.55 then
					if caveCircle < 0.41 or caveCircle > 0.54 then
						if chunk.tiles[x][y] == tiles.SAND.id then
							chunk.tiles[x][y] = tiles.SANDSTONE.id
						else
							chunk.tiles[x][y] = tiles.GRASS.id
						end
						
					else
						chunk.tiles[x][y] = tiles.AIR.id
					end

					if surface > 5 then
						chunk.backgrounds[x][y] = backgrounds.DIRT.id
					end
				end

				if caveBubble > 0.8 and caveBubble < 1 and surface > 5 then
					if caveBubble < 0.81 or caveBubble > 0.99 then
						chunk.tiles[x][y] = tiles.GRASS.id
						if chunk.tiles[x][y] == tiles.SAND.id then
							chunk.tiles[x][y] = tiles.SANDSTONE.id
						end
					else
						chunk.tiles[x][y] = tiles.AIR.id
					end
					chunk.tiles[x][y] = tiles.AIR.id
					chunk.backgrounds[x][y] = backgrounds.DIRT.id
				end
			end
		end
	end
end

local function chunkOrePass(chunk, seed)
	local worldx = chunk.position.x*config.CHUNK_SIZE
	local worldy = chunk.position.y*config.CHUNK_SIZE

	--[[
	noisescale - affects the size of ore chunks
	threshold - affects the rarity of ore chunks
]]
	local function oretest(tile, x, y, offset, noisescale, threshold)
		local noise = noise.noise(worldx+x+offset, worldy+y+offset, noisescale, noisescale)
		if noise > (threshold+0.5) then
			chunk.tiles[x][y] = tile
		end
	end

	for x = 1, config.CHUNK_SIZE do
		for y = 1, config.CHUNK_SIZE do

			local surface = getSurfaceNoise(worldx+x, worldy+y)

			local bluegrassBiome = noise.noise(worldx+x, worldy+y, 512, 512)

			local bluegrassTerrain = noise.epicnoise(worldx+x, worldy+y, 50, 4) - (noise.noise(worldx+x, worldy+y, 16, 16)*0.5)

			bluegrassTerrain = jutils.math.round(bluegrassTerrain, 1)

			if worldy+y > 1000 and bluegrassBiome > 0.90 then


				if bluegrassTerrain > 0.6 then
					chunk.tiles[x][y] = tiles.MUD.id
				elseif bluegrassTerrain == 0.6 then
					chunk.tiles[x][y] = tiles.BLUE_GRASS.id
				elseif bluegrassTerrain < 0.6 then
					chunk.tiles[x][y] = tiles.AIR.id
				end

				chunk.backgrounds[x][y] = backgrounds.PSILOCYN.id

			end

			if worldy+y < -100 and chunk.tiles[x][y] == tiles.AIR.id then
				oretest(tiles.CLOUD.id, x, y, 66, 48, 0.45)
			end

			if chunk.tiles[x][y] ~= tiles.AIR.id then
				

				


				if worldy+y > 0 then
					-- iron, copper, and tin generation
					oretest(tiles.IRON_ORE.id, x, y, 420, 16, 0.47)

					oretest(tiles.COPPER_ORE.id, x, y, 69, 20, 0.45)

					oretest(tiles.TIN_ORE.id, x, y, -666, 24, 0.46)
				end

				-- gold, lead, aluminium

				if worldy+y > 400 then
					oretest(tiles.GOLD_ORE.id, x, y, 123, 8, 0.47)
					oretest(tiles.LEAD_ORE.id, x, y, -144, 20, 0.48)
					oretest(tiles.ALUMINIUM_ORE.id, x, y, 357, 26, 0.49)
					oretest(tiles.SILVER_ORE.id, x, y, 1, 16, 0.48)
					oretest(tiles.PALLADIUM_ORE.id, x, y, 41, 20, 0.47)
				end

				if worldy+y > 800 then
					oretest(tiles.CHROMIUM_ORE.id, x, y, 555, 24, 0.48)
					oretest(tiles.NICKEL_ORE.id, x, y, 666, 16, 0.48)
					oretest(tiles.VANADIUM_ORE.id, x, y, 44, 16, 0.48)
				end

				-- cobalt, titanium
				if worldy+y > 1200 then
					oretest(tiles.COBALT_ORE.id, x, y, -404, 24, 0.495)
					oretest(tiles.TITANIUM_ORE.id, x, y, -222, 16, 0.49)
				end
				-- titanium, uranium, cobalt and 
				if worldy+y > 2400 then
					oretest(tiles.URANIUM_ORE.id, x, y, 237, 8, 0.495)
				end
			end
		end
	end
end

---
return function(chunk)
	chunkSurfacePass(chunk)
	chunkDetailPass(chunk)
	chunkCavernPass(chunk)
	chunkOrePass(chunk)
	--skyIslandPass(chunk)
end