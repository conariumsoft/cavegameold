--- Light source propagation, does number crunching on a separate thread.
-- placeholder
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software

local grid        = require("src.grid")
local jutils      = require("src.jutils")
local config      = require("config")
local tiles       = require("src.tiles")
local backgrounds = require("src.backgrounds")


-- what the fuck:
-- https://luajit.org/ext_ffi.html
-- why the fuck:
-- make lighting faster LAWL

local ffi = require("ffi")

ffi.cdef[[
	typedef double grid[33][33]; // why the actual SHIT is this 33?
]]

require("love.timer")

local mirroredchunks = {}
local lights = {}


local ambientLight = 0.5

local function getChunk(cx, cy)
	return mirroredchunks[grid.coordinatesToKey(cx, cy)]
end

local getLocalCoordinates = grid.getLocalCoordinates
local coordinatesToKey = grid.coordinatesToKey

local function getLightRGB(x, y)
	local cx, cy, lx, ly = getLocalCoordinates(x, y)
	local key = coordinatesToKey(cx, cy)
	local chunk = lights[key]
	if chunk then

		return chunk[1][lx][ly], chunk[2][lx][ly], chunk[3][lx][ly]
	end
	return -1, -1, -1
end

local function setLightRGB(x, y, r, g, b)
	local cx, cy, lx, ly = getLocalCoordinates(x, y)
	local key = coordinatesToKey(cx, cy)
	local chunk = lights[key]
	if chunk then

		chunk[1][lx][ly] = r
		chunk[2][lx][ly] = g
		chunk[3][lx][ly] = b
	end
end

local function getTile(x, y)
	local cx, cy, lx, ly = grid.getLocalCoordinates(x, y)
	local key = coordinatesToKey(cx, cy)
	local chunk = mirroredchunks[key]
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

--[[
	this is the BIGBOY workhorse of the lighting system...
	fairly self explainatory though
]]
local function solve(y, tileat, bgat, current, input)
	local rlight = math.max(tileat, bgat)

	if rlight == -1 then
		rlight = ambientLight
		if y > 250 then rlight = 0 end
	end

	local result = math.max(rlight, input, current)
	return result
end

local function recursiveFloodFillRGB(x, y, inputr, inputg, inputb, recursions)
	recursions = recursions or 0
	if recursions > 500 then return end

	local tileid = getTile(x, y)
	local bgid = getBackground(x, y)
	-- out of bounds
	if tileid == -1 then return end

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

	local cr, cg, cb = getLightRGB(x, y)

	local absorb = math.max(tiledata.absorb, bgdata.absorb)

	local red   = solve(y, tlight[1], bglight[1], cr, inputr)
	local green = solve(y, tlight[2], bglight[2], cg, inputg)
	local blue  = solve(y, tlight[3], bglight[3], cb, inputb)

	absorb = absorb + minabsorb

	if red < 0 then red = 0 end
	if green < 0 then green = 0 end
	if blue < 0 then blue = 0 end

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

			lights[key] = nil

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
			local possibleChunk = lights[key]

			if possibleChunk then
				for i = 1, 3 do
					for x = 1, 32 do
						for y = 1, 32 do
							possibleChunk[i][x][y] = 0.0
						end
					end
				end
			else
				lights[key] = {
					[1] = ffi.new("grid", {{0.0}}),
					[2] = ffi.new("grid", {{0.0}}),
					[3] = ffi.new("grid", {{0.0}}),
				}
			end
		end

		numberCrunch()

		local num = channels.setlight:getCount()
		for i = 1, num do
			local package = channels.setlight:pop()
			if i >= (num-10) then
				local tx = package[1]
				local ty = package[2]
				local r = package[3]
				local g = package[4]
				local b = package[5]
	
				recursiveFloodFillRGB(tx, ty, r, g, b)
			end
		end

		for key, chunk in pairs(lights) do

			local sendchunk = {}

			for i = 1, 3 do
				sendchunk[i] = {}
				for x = 1, 32 do
					sendchunk[i][x] = {}
					for y = 1, 32 do
						sendchunk[i][x][y] = chunk[i][x][y]
					end
				end
			end

			channels.newlights:push({key, sendchunk})
		end
		love.timer.sleep(1/5)
		
	else
		--love.timer.sleep(1/30)
	end
end
print("lighting thread finished")