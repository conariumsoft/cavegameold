local tiles = require("src.tiles")

local treeMinimumHeight = 15
local treeMaximumHeight = 35

return function(world, tilex, tiley)
	local goalHeight = math.random(treeMinimumHeight, treeMaximumHeight)
	local function checkTrunkValid()
		for inc = 1, goalHeight + 1 do
			if not world:getTile(tilex, tiley - inc) == tiles.AIR.id then
				return false
			end
			if not world:getTile(tilex-1, tiley - inc) == tiles.AIR.id then
				return false
			end
			if not world:getTile(tilex+1, tiley - inc) == tiles.AIR.id then
				return false
			end
			return true
		end
	end
	local result = checkTrunkValid()

	if result == true then

		-- downward checking to make sure the entirety of the tree lines up
		
		for dx = -1, 1, 1 do
			local stop = false

			for dy = 0, 10 do
				if stop == false then
					if world:getTile(tilex+dx, tiley+dy) == tiles.AIR.id then
						if world:getTile(tilex+dx, tiley+dy+1) ~= tiles.AIR.id then
							stop = true
							world:setTile(tilex+dx, tiley+dy, tiles.ROOT.id)
						else
							world:setTile(tilex+dx, tiley+dy, tiles.LOG.id)
						end
					end
				end
			end
		end
		
		
		for inc = 1, goalHeight do
			
			world:setTile(tilex, tiley - inc, tiles.LOG.id)
			world:setTile(tilex-1, tiley - inc, tiles.LOG.id)
			world:setTile(tilex+1, tiley - inc, tiles.LOG.id)
				
		end

		local canopysize = 5
		for deltax = -canopysize, canopysize do
			for deltay = -canopysize, canopysize do
				if world:getTile(tilex + deltax, (tiley - goalHeight) + deltay) == tiles.AIR.id then
					world:setTile(tilex + deltax, (tiley - goalHeight) + deltay, tiles.LEAVES.id)
				end
			end
		end
	end
end