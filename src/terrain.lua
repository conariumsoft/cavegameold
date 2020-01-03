--- Terrain generation utilities and math.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software
local BIOME_X_STRETCH = 600

local noise = require("src.noise")
local jutils = require("src.jutils")

local terrain_math = {}

terrain_math.biomes = {
	[1] = "plains", 
	[2] = "forest",
	[3] = "plains",
	[4] = "alpine",
	[5] = "desert",
	[6] = "wetlands",
	[7] = "forest",
	[8] = "wetlands",
	
	
}

function terrain_math.getBiomeAt(x)
    local biome_noise = terrain_math.getBiomeNoise(x)
    local scaled = math.floor(biome_noise * #terrain_math.biomes)+1
    return terrain_math.biomes[scaled]
end


function terrain_math.getBiomeNoise(x)

	--! ghetto quick-added octaves
	return love.math.noise(x / BIOME_X_STRETCH )
end

---
function terrain_math.getSurfaceNoise(x, y)
	local SURFACE_HEIGHT = 20
	local SURFACE_OCTAVES = 5
	local SURFACE_FREQUENCY = 150
	local SURFACE_Y_STRETCH = 40

	local surface = noise.epicnoise(x, y, SURFACE_FREQUENCY, SURFACE_OCTAVES)

	local raised = surface*(SURFACE_Y_STRETCH)
	local raised_surface = raised + SURFACE_HEIGHT


	return y-raised_surface
end

---
function terrain_math.getSurfaceLevel(x)
	for i = -200, 200 do
		local res = terrain_math.getSurfaceNoise(x, i)

		if res > -1 and res < 1 then
			--print("surface level:", res, i)
			return i
		end
	end
end

return terrain_math