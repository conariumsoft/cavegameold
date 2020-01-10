local tree_funcs = require("data.structures.trees.tree_funcs")
local tiles = require("src.tiles")

local spruce_tree_min_height = 10
local spruce_tree_max_height = 24

local function generate(world, x, y)
	local goal_height = math.random(spruce_tree_min_height, spruce_tree_max_height)

	local bushiness = math.random(4, 10)

	if tree_funcs.check_trunk_is_valid(world, x, y, goal_height) == false then return end

	if goal_height > 15 then
		if world:getTile(x-1, y-1) == tiles.AIR.id and world:getTile(x-1, y) ~= tiles.AIR.id then
			world:setTile(x-1, y-1, tiles.PINE_ROOT_LEFT.id)
		end
		if world:getTile(x+1, y-1) == tiles.AIR.id and world:getTile(x+1, y) ~= tiles.AIR.id then
			world:setTile(x+1, y-1, tiles.PINE_ROOT_RIGHT.id)
		end
	end

	world:setTile(x, y-1, tiles.PINE_ROOT.id)

	for inc = 2, goal_height do
		world:setTile(x, y - inc, tiles.PINE_LOG.id)
	end

	world:setTile(x, (y-goal_height)-1, tiles.PINE_LEAVES.id)
	--world:setTile(x, (y-goal_height), tiles.PINE_LEAVES.id)
	--world:setTile(x, (y-goal_height), tiles.PINE_LEAVES.id)

	local canopy_type = math.random(3)

	if canopy_type == 1 then

		for dy = 0, bushiness do
			if dy%2==0 then
				for dx = -(dy), (dy) do
					if world:getTile(x+dx, (y-goal_height)+(dy)) == tiles.AIR.id then
						world:setTile(x+dx, (y-goal_height)+(dy), tiles.PINE_LEAVES.id)
					end
				end
			else
				world:setTile(x+1, (y-goal_height)+(dy), tiles.PINE_LEAVES.id)
				world:setTile(x-1, (y-goal_height)+(dy), tiles.PINE_LEAVES.id)
			end
		end
	else
		for dy = 0, bushiness do
			if dy%2==0 then
				local dtx =  dy
				if (dy > math.floor(bushiness/2)) then
					dtx = bushiness - dy
				end
				
				for dx = -(dtx), (dtx) do

					if world:getTile(x+dx, (y-goal_height)+(dy)) == tiles.AIR.id then
						world:setTile(x+dx, (y-goal_height)+(dy), tiles.PINE_LEAVES.id)
					end
				end
			else
				world:setTile(x+1, (y-goal_height)+(dy), tiles.PINE_LEAVES.id)
				world:setTile(x-1, (y-goal_height)+(dy), tiles.PINE_LEAVES.id)
			end
		end
	end
end

return generate