--- Perlin Noise utilities.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software
local config = require("config")
local jutils = require("src.jutils")

local noise = {}

local seed = -(4444)

function noise.octave_1d(x, octaves, persistence)

	local total = 0
	local frequency = 1
	local amplitude = 1
	local max_value = 0

	for i = 1, octaves do
		total = total + love.math.noise(x*frequency) * amplitude

		max_value = max_value + amplitude
		amplitude = amplitude * persistence
		frequency = frequency * 2
	end

	return total/max_value

end

function noise.octave_2d(x, y, octaves, persistence)

	local total = 0
	local frequency = 1
	local amplitude = 1
	local max_value = 0

	for i = 1, octaves do
		total = total + love.math.noise(x*frequency, y*frequency) * amplitude

		max_value = max_value + amplitude
		amplitude = amplitude * persistence
		frequency = frequency * 2
	end

	return total/max_value
end


function noise.setSeed(x)
	--seed = x
end

---
function noise.noise1D(x)
	return love.math.noise(x+seed)
end

---
function noise.noise(worldx, worldy, xscale, yscale)
	return love.math.noise((worldx/xscale)+seed, (worldy/yscale))
end

---
function noise.epicnoise(worldx, worldy, frequency, octaves)

	local start = 0

	for i = 1, octaves do
		start = start + (1/i) * noise.noise(worldx, worldy, 1/i*frequency, 1/i*frequency) 
	end

	return start
end

---
function noise.surfacenoise(x, y)

	local variation = 20
	local minvar = 0.1
	local maxvar = 0.9
	local scalenoise = jutils.math.round(love.math.noise((x+seed)/6000), 1)*variation
	local sn = noise.epicnoise((x+1), y, config.generator.SURFACE_FREQUENCY, config.generator.SURFACE_OCTAVES)
	sn = sn * config.generator.SURFACE_GAIN
	
	local surface = math.floor((sn*(config.generator.SURFACE_VARIATION)))+scalenoise


	surface = surface + config.generator.SURFACE_HEIGHT

	return y-surface
end

return noise