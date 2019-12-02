--- Light source propagation, does number crunching on a separate thread.
-- placeholder
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software
local grid = require("src.grid")
local jutils = require("src.jutils")
local config = require("config")
require("love.timer")
local mirroredchunks = {}
local lights = {}

local tiles = require("src.tiles")
local backgrounds = require("src.backgrounds")

local ambientLight = 0.5

local function getChunk(cx, cy)
	return mirroredchunks[grid.coordinatesToKey(cx, cy)]
end

local function getLight(x, y)
	local cx, cy, lx, ly = grid.getLocalCoordinates(x, y)
	local key = grid.coordinatesToKey(cx, cy)
	local chunk = lights[key]
	if chunk then
		return chunk[lx][ly]
	end
	return -1
end

local function setLight(x, y, level)
	local cx, cy, lx, ly = grid.getLocalCoordinates(x, y)
	local key = grid.coordinatesToKey(cx, cy)
	local chunk = lights[key]
	if chunk then
		chunk[lx][ly] = level
	end
end

local function getLightRGB(x, y)
	local cx, cy, lx, ly = grid.getLocalCoordinates(x, y)
	local key = grid.coordinatesToKey(cx, cy)
	local chunk = lights[key]
	if chunk then
		return chunk[1][lx][ly], chunk[2][lx][ly], chunk[3][lx][ly]
	end
	return -1, -1, -1
end

local function setLightRGB(x, y, r, g, b)
	local cx, cy, lx, ly = grid.getLocalCoordinates(x, y)
	local key = grid.coordinatesToKey(cx, cy)
	local chunk = lights[key]
	if chunk then
		chunk[1][lx][ly] = r
		chunk[2][lx][ly] = g
		chunk[3][lx][ly] = b
	end
end

local function getTile(x, y)
	local cx, cy, lx, ly = grid.getLocalCoordinates(x, y)
	local chunk = getChunk(cx, cy)
	if chunk then
		return chunk.tiles[lx][ly]
	end
	return -1
end

local function setTile(x, y, tileid)
	local cx, cy, lx, ly = grid.getLocalCoordinates(x, y)
	local chunk = getChunk(cx, cy)
	if chunk then
		chunk.tiles[lx][ly] = tileid
	end
end
local function getBackground(x, y)
	local cx, cy, lx, ly = grid.getLocalCoordinates(x, y)
	local chunk = getChunk(cx, cy)
	if chunk then
		return chunk.backgrounds[lx][ly]
	end
	return -1
end
local function setBackground(x, y, tileid)
	local cx, cy, lx, ly = grid.getLocalCoordinates(x, y)
	local chunk = getChunk(cx, cy)
	if chunk then
		chunk.backgrounds[lx][ly] = tileid
	end
end

print("lighting thread started")
local channels = {
	addchunk = love.thread.getChannel("addchunk"),
	dropchunk = love.thread.getChannel("dropchunk"),
	tilechange = love.thread.getChannel("tilechange"),
	bgchange = love.thread.getChannel("bgchange"),
	newlights = love.thread.getChannel("newlights"),
	setambient = love.thread.getChannel("setambient"),
	setlight = love.thread.getChannel("setlight"),
	light_kill = love.thread.getChannel("light_kill")
}

local function recursiveFloodFill(x, y, inputAmount, recursions)
	recursions = recursions or 0
	if recursions > 200 then return end

	local tileid = getTile(x, y)
	local bgid = getBackground(x, y)
	-- out of bounds
	if tileid == -1 then return end

	local bgdata = backgrounds:getByID(bgid)
	local tiledata = tiles:getByID(tileid)


	local light = math.max(tiledata.light, bgdata.light)
	local absorb = math.max(tiledata.absorb, bgdata.absorb)

	if light == -1 then light = ambientLight if y > 250 then light = 0 end end
	local minabsorb = 0.005
	
	local current = getLight(x, y)

	local result = math.max(light, inputAmount, current)
	
	absorb = absorb + minabsorb
	
	--if result == current then return end
	if result <= 0 then return end

	setLight(x, y, result)

	recursiveFloodFill(x+1, y, result-absorb, recursions+1)
	recursiveFloodFill(x-1, y, result-absorb, recursions+1)
	recursiveFloodFill(x, y+1, result-absorb, recursions+1)
	recursiveFloodFill(x, y-1, result-absorb, recursions+1)
end


local function recursiveFloodFillRGB(x, y, inputr, inputg, inputb, recursions)
	recursions = recursions or 0
	if recursions > 500 then return end

	local tileid = getTile(x, y)
	local bgid = getBackground(x, y)
	-- out of bounds
	if tileid == -1 then return end

	local function solve(tileat, bgat, current, input)
		local rlight = math.max(tileat, bgat)

		if rlight == -1 then 
			rlight = ambientLight
			if y > 250 then rlight = 0 end
		end

		local result = math.max(rlight, input, current)

		return result
	end

	local bgdata = backgrounds:getByID(bgid)
	local tiledata = tiles:getByID(tileid)

	local tlight = tiledata.light
	local bglight = bgdata.light

	if type(tlight) == "number" then
		local l = tlight
		tlight = {l, l, l}
	end

	if type(bglight) == "number" then
		local l = bglight
		bglight = {l, l, l}
	end

	local minabsorb = 0.05
	local absorb = math.max(tiledata.absorb, bgdata.absorb)

	local cr, cg, cb = getLightRGB(x, y)

	-- solve for red
	local red = solve(tlight[1], bglight[1], cr, inputr)
	local green = solve(tlight[2], bglight[2], cg, inputg)
	local blue = solve(tlight[3], bglight[3], cb, inputb)

	absorb = absorb + minabsorb
	

	

	if red < 0 then 
		red = 0
	end
	if green < 0 then 
		green = 0
	end
	if blue < 0 then 
		blue = 0
	end


	if red == cr and green == cg and blue == cb then return end
	if red <= 0 and blue <= 0 and green <= 0 then return end

	setLightRGB(x, y, red, green, blue)


	red = red - absorb
	green = green - absorb
	blue = blue - absorb
	
	recursiveFloodFillRGB(x+1, y, red, green, blue, recursions+1)
	recursiveFloodFillRGB(x-1, y, red, green, blue, recursions+1)
	recursiveFloodFillRGB(x, y+1, red, green, blue, recursions+1)
	recursiveFloodFillRGB(x, y-1, red, green, blue, recursions+1)
end

local function numberCrunch()
	--print("running light calc")


	for key, chunk in pairs(lights) do
		local cx, cy = grid.keyToCoordinates(key)
		local wx, wy = cx*config.CHUNK_SIZE, cy*config.CHUNK_SIZE
		for x = 1, config.CHUNK_SIZE do
			for y = 1, config.CHUNK_SIZE do
				recursiveFloodFillRGB(wx+x, wy+y, 0, 0, 0)
			end
		end
	end

	
end

local running = true

local construct = jutils.table.constructArray

while running do
	local readyToCrunch = true
	local num = channels.addchunk:getCount()
	for i = 1, num do
		local package = channels.addchunk:pop()
		if package then
			local key = package[1]
			local chunk = package[2]
			mirroredchunks[key] = chunk
			
			readyToCrunch = false
		end
	end
	local num = channels.dropchunk:getCount()
	for i = 1, num do
		local package = channels.dropchunk:pop()
		if package then
			local key = package[1]
			mirroredchunks[key] =  nil

			readyToCrunch = false
		end
	end
	local num = channels.tilechange:getCount()
	for i = 1, num do
		local package = channels.tilechange:pop()
		if package then
			local x = package[1]
			local y = package[2]
			local tileid = package[3]
			

			setTile(x, y, tileid)

			readyToCrunch = false
		end
	end
	local num = channels.bgchange:getCount()
	for i = 1, num do
		local package = channels.bgchange:pop()
		if package then
			local x = package[1]
			local y = package[2]
			local tileid = package[3]
			
			setBackground(x, y, tileid)

			readyToCrunch = false
		end
	end
	local package = channels.setambient:pop()
	if package then
		ambientLight = package
		readyToCrunch = false
	end

	local package = channels.light_kill:pop()

	if package then running = false end


	----------------------------- 
	-- light calculation gets done here
	if readyToCrunch == false then
		lights = {}

		-- ! is this bad?
		for key, chunk in pairs(mirroredchunks) do
			--[[for i = 1, 3 do
				lights[key][i] = {}
				for x = 1, config.CHUNK_SIZE do
					lights[key][i][x] = {}
					for y = 1, config.CHUNK_SIZE do


					end
				end
			end]]
			lights[key] = {
				[1] = construct(construct(0, config.CHUNK_SIZE), config.CHUNK_SIZE),
				[2] = construct(construct(0, config.CHUNK_SIZE), config.CHUNK_SIZE),
				[3] = construct(construct(0, config.CHUNK_SIZE), config.CHUNK_SIZE)
			}
		end
		numberCrunch()

		local num = channels.setlight:getCount()
		for i = 1, num do

			local package = channels.setlight:pop()
	
			if i > (num-25) then
				local tx = package[1]
				local ty = package[2]
				local r = package[3]
				local g = package[4]
				local b = package[5]

			
				recursiveFloodFillRGB(tx, ty, r, g, b)
			end
	
		end

		for key, chunk in pairs(lights) do
			channels.newlights:push({key, chunk})
		end
		--love.timer.sleep(1/20)
		
	else
		love.timer.sleep(1/20)
	end
end
print("lighting thread finished")