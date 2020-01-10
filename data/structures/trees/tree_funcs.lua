local tiles = require("src.tiles")

local function check_trunk_is_valid(world, x, y, goal_height)
	for inc = 1, goal_height + 1 do
		if not world:getTile(x, y - inc) == tiles.AIR.id then
			return false
		end

	end
	return true
end

return {
	check_trunk_is_valid = check_trunk_is_valid
}