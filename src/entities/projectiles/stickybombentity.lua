local tiles = require("src.tiles")
local bombentity = require("src.entities.projectiles.bombentity")

local stickybomb = bombentity:subclass("StickyBomb")

local stickytexture = love.graphics.newImage("assets/items/stickybomb.png")

function stickybomb:init(...)
	bombentity:init(...)

	self.texture = stickytexture
end

function stickybomb:collisionCallback(tileid, tilepos, separation, normal)
	local data = tiles:getByID(tileid)

	if data.solid then
		self.frozen = true
		self.velocity.x = 0
		self.velocity.y = 0
	end
end

return stickybomb