local tiles = require("src.tiles")
local bombentity = require("src.entities.projectiles.bombentity")

local dynamite = bombentity:subclass("Dynamite")

local dynamite_texture = love.graphics.newImage("assets/items/dynamite.png")

function dynamite:init(...)
	bombentity:init(...)

	self.texture = dynamite_texture
	self.power = 16
	self.scale.x = 1
	self.scale.y = 1
end

return dynamite