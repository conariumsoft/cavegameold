--- Terrain generation utilities and math.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software
local BIOME_X_STRETCH = 1600

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

local biome_noise_functions = {
	plains = function(x, y)
		return noise.epicnoise(x, y, 400, 2) * 0.5
	end,
	forest = function(x, y)
		return (noise.epicnoise(x, y, 150, 3))
	end,
	desert = function(x, y)
		return noise.epicnoise(x, y, 50, 2) * 0.5
	end,
	alpine = function(x, y)
		return (noise.epicnoise(x, y, 100, 3) - (love.math.noise(x/10)*0.25)) * 2
	end,
	wetlands = function(x, y)
		return (love.math.noise(x/100)*0.1) - 0.25
	end,
}

function terrain_math.test_noise(x)
	local biome_noise = terrain_math.getBiomeNoise(x)
	local scaled = biome_noise * #terrain_math.biomes
	local rounded = math.floor(scaled)
	-- biome boundaries
	if (scaled - rounded) < 0.1 or (scaled-rounded) > 0.9 then
		return true, scaled-rounded
	end
	return false
end

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
	local SURFACE_OCTAVES = 2
	local SURFACE_FREQUENCY = 150
	local SURFACE_Y_STRETCH = 40

	local surface = noise.epicnoise(x, y, SURFACE_FREQUENCY, SURFACE_OCTAVES)

	local biome1 = terrain_math.getBiomeAt(x)

	local border, side = terrain_math.test_noise(x)

	if biome1 then
		local add_to_base_noise = 0
		
		local b1_noise = biome_noise_functions[biome1](x, y) - 0.5
		add_to_base_noise = b1_noise
		if border then

			if side > 0.9 then
				local lerp = (1-side) * 10
				--
				add_to_base_noise = (b1_noise*lerp)
			end
			if side < 0.1 then
				local lerp = (side*10)
				add_to_base_noise = (b1_noise*lerp)	
			end
		end

		surface = surface - add_to_base_noise
	end

	local raised = surface*(SURFACE_Y_STRETCH)
	local raised_surface = raised + SURFACE_HEIGHT

	return y-raised_surface
end

---
function terrain_math.getSurfaceLevel(x)
	for i = -300, 300 do
		local res = terrain_math.getSurfaceNoise(x, i)

		if res > -3 and res < 3 then
			--print("surface level:", res, i)
			return i
		end
	end
	return 0
end

return terrain_math