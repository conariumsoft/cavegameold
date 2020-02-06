local grid = require("src.grid")
local input = require("src.input")
local jutils = require("src.jutils")

local function getPlayerTile(playerentity)
	local pos = playerentity.position

	return grid.pixelToTileXY(pos.x, pos.y)
end

local swish_sfx_2 = love.audio.newSource("assets/audio/swish2.ogg", "static")

consumable:new("GLOWSTICK", {
	texture = "glowstick.png",
	stack = 99,
	consume = function(self, player)
		local mx, my = input.getTransformedMouse()

		local tx, ty = grid.pixelToTileXY(mx, my)
		local px, py = getPlayerTile(player)


		local world = player.world

		-- ! gay hack
		local new = jutils.vec2.new(player.position.x, player.position.y)
		local stickentity = world:addEntity("glowstick", new, jutils.vec2.new(input.getTransformedMouse()), 400, 0.1, player)
		--stickentity:teleport(player.position)

		swish_sfx_2:stop()
		swish_sfx_2:play()

	    return true
	end
})