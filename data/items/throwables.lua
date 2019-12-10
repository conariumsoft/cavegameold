local grid = require("src.grid")
local input = require("src.input")
local jutils = require("src.jutils")

local function getPlayerTile(playerentity)
	local pos = playerentity.position

	return grid.pixelToTileXY(pos.x, pos.y)
end

consumable:new("GLOWSTICK", {
	stack = 99,
	consume = function(self, player)
		local mx, my = input.getTransformedMouse()

		local tx, ty = grid.pixelToTileXY(mx, my)
		local px, py = getPlayerTile(player)


		local world = player.world

		-- ! gay hack
		local new = jutils.vec2.new(player.position.x, player.position.y)
		local stickentity = world:addEntity("glowstick", new, jutils.vec2.new(input.getTransformedMouse()), 300, 0.1, player)
		--stickentity:teleport(player.position)

	    return true
	end
})