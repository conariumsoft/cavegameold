--- Terrain generation utilities and math.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software
local BIOME_X_STRETCH = 500

local noise = require("src.noise")
local jutils = require("src.jutils")

local terrain_math = {}


function terrain_math.getBiomeNoise(x)

	--! ghetto quick-added octaves
	return love.math.noise(x / BIOME_X_STRETCH ) --+ (noise.noise1D(x /(BIOME_X_STRETCH/2)) /2) + (noise.noise1D(x /(BIOME_X_STRETCH/4)) /4)
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
			print("surface level:", res, i)
			return i
		end
	end
end

return terrain_math