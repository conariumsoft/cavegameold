local tiles = require("src.tiles")

local treeMinimumHeight = 5
local treeMaximumHeight = 15

return function(world, tilex, tiley)
	local goalHeight = math.random(treeMinimumHeight, treeMaximumHeight)
	local function checkTrunkValid()
		for inc = 1, goalHeight + 1 do
			if not world:getTile(tilex, tiley - inc) == tiles.AIR.id then
				return false
			end
			return true
		end
	end
	local result = checkTrunkValid()

	if result == true then
		if world:getTile(tilex-1, tiley-1) == tiles.AIR.id and world:getTile(tilex-1, tiley) ~= tiles.AIR.id then
			world:setTile(tilex-1, tiley-1, tiles.ROOT_LEFT.id)
		end
		if world:getTile(tilex+1, tiley-1) == tiles.AIR.id and world:getTile(tilex+1, tiley) ~= tiles.AIR.id then
			world:setTile(tilex+1, tiley-1, tiles.ROOT_RIGHT.id)
		end

		world:setTile(tilex, tiley-1, tiles.ROOT.id)

		for inc = 2, goalHeight do
			world:setTile(tilex, tiley - inc, tiles.LOG.id)
		end
		local canopysize = 2
		for deltax = -canopysize, canopysize do
			for deltay = -canopysize, canopysize do
				if world:getTile(tilex + deltax, (tiley - goalHeight) + deltay) == tiles.AIR.id then
					world:setTile(tilex + deltax, (tiley - goalHeight) + deltay, tiles.LEAVES.id)
				end
			end
		end
	end
end
