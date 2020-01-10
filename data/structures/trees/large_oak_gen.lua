local tiles = require("src.tiles")

local large_oak_max_height = 35
local large_oak_min_height = 15

local tree_funcs = require("data.structures.trees.tree_funcs")

local function generate(world, x, y)
	local goal_height = math.random(large_oak_min_height, large_oak_max_height)

	if tree_funcs.check_trunk_is_valid(world, x, y, goal_height) == false then return end

	for dx = -1, 1, 1 do
		local stop = false
		for dy = 0, 10 do
			if stop == false then
				if world:getTile(x+dx, y+dy) == tiles.AIR.id then
					if world:getTile(x+dx, y+dy+1) ~= tiles.AIR.id then

						stop = true
						world:setTile(x+dx, y+dy, tiles.ROOT.id)
					else
						world:setTile(x+dx, y+dy, tiles.LOG.id)
					end
				end
			end
		end
	end

	for inc = 1, goal_height do
		world:setTile(x, y-inc, tiles.LOG.id)
		world:setTile(x-1, y-inc, tiles.LOG.id)
		world:setTile(x+1, y-inc, tiles.LOG.id)
	end

	local canopysize = 5

	for deltax = -canopysize, canopysize do
		for deltay = -canopysize, canopysize do
			if world:getTile(x + deltax, (y - goal_height) + deltay) == tiles.AIR.id then
				world:setTile(x + deltax, (y - goal_height) + deltay, tiles.LEAVES.id)
			end
		end
	end
end

return generate