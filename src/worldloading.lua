--- Chunk file I/O thread. Only handles reading and writing of bulk chunk data.
-- See <a href = "chunking.html">chunking.lua</a> for information about the actual data.
-- Each chunk is saved in a separate file.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software


--[[
	World file format:
	worldname/
		chunks/
			1_1
			
		entities.json
		metadata.json
]]

require("love.filesystem")
require("love.timer")
local chunking = require("src.chunking")
local grid = require("src.grid")
print("chunk handling thread started")

local channels = {
	loadchunk = love.thread.getChannel("loadchunk"),
	savechunk = love.thread.getChannel("savechunk"),
	returnchunk = love.thread.getChannel("returnchunk"),
	finished = love.thread.getChannel("finished"),
	io_kill = love.thread.getChannel("io_kill")
}

local args = {...}

local worldname = args[1]

---
local function loadChunkFromFile(key)
	local info = love.filesystem.getInfo("worlds/"..worldname.."/chunks/"..key)

	-- chunk exists
	if info then
		local jsondata, sizeorerr = love.filesystem.read("worlds/"..worldname.."/chunks/"..key)
	
		if jsondata then
			local reconstructedChunk = chunking:decode(jsondata)
			if reconstructedChunk then
				channels.returnchunk:push({key, reconstructedChunk})
				return
			end
		end
		
	end
	channels.returnchunk:push({key, chunking:newstruct(grid.keyToCoordinates(key))})
	return
end

---
local function saveChunkToFile(key, chunk)
	local serialized = chunking:encode(chunk)
	if #serialized > 0 then 
		local success, err = love.filesystem.write("worlds/"..worldname.."/chunks/"..key, serialized)


		if not success then
			print("error saving chunk:", err)
			error("error saving chunk")
		end
	end
end

local running = true


while running do
	love.timer.sleep(1/60)
	local package = channels.io_kill:pop()

	if package then running = false end

	local numRequests = channels.loadchunk:getCount()
	for i = 1, numRequests do
		local giveRequest = channels.loadchunk:pop()
		if giveRequest then
			local key = giveRequest[1]

			loadChunkFromFile(key)
		end
	end

	local numRequests = channels.savechunk:getCount()
	for i = 1, numRequests do
		local saveRequest = channels.savechunk:pop()
		if saveRequest then
			local key = saveRequest[1]
			local chunk = saveRequest[2]

			saveChunkToFile(key, chunk)
		end
	end
end

channels.finished:push(true)
print("chunk handling thread finished")