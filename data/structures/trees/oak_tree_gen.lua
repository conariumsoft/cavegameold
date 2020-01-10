local tiles = require("src.tiles")

local oak_tree_max_height = 15
local oak_tree_min_height = 5

local tree_funcs = require("data.structures.trees.tree_funcs")

local function generate(world, x, y)
	local goal_height = math.random(oak_tree_min_height, oak_tree_max_height)


	if tree_funcs.check_trunk_is_valid(world, x, y, goal_height) == false then return end

	if world:getTile(x-1, y-1) == tiles.AIR.id and world:getTile(x-1, y) ~= tiles.AIR.id then
		world:setTile(x-1, y-1, tiles.ROOT_LEFT.id)
	end
	if world:getTile(x+1, y-1) == tiles.AIR.id and world:getTile(x+1, y) ~= tiles.AIR.id then
		world:setTile(x+1, y-1, tiles.ROOT_RIGHT.id)
	end

	world:setTile(x, y-1, tiles.ROOT.id)

	for inc = 2, goal_height do
		world:setTile(x, y - inc, tiles.LOG.id)
	end
	local canopysize = 2
	for deltax = -canopysize, canopysize do
		for deltay = -canopysize, canopysize do
			if world:getTile(x + deltax, (y - goal_height) + deltay) == tiles.AIR.id then
				world:setTile(x + deltax, (y - goal_height) + deltay, tiles.LEAVES.id)
			end
		end
	end
end

return generate