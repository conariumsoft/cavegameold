local projectile = require("src.entities.projectiles.projectile")
local physicalentity = require("src.entities.physicalentity")
local tiles = require("src.tiles")
local jutils = require("src.jutils")

local glowstick = projectile:subclass("Glowstick")

function glowstick:init(...)
	projectile.init(self, ...)

	self.lightemitter = {0.25, 1, 0.25}

	self.mass = 0.5
	self.xfriction = 0.2
	self.save = false
	self.boundingbox = jutils.vec2.new(3, 3)
end

function glowstick:entityCollision(otherEntity, separation, normal)
	
end

function glowstick:collisionCallback(tileid, tilepos, separation, normal)

	local tiledata = tiles:getByID(tileid)

	if tiledata.solid == true then
		if normal.y and normal.y ~= 0 then
			self.velocity.y = self.velocity.y * -0.75
		end
		if normal.x and normal.x ~= 0 then
			self.velocity.x = self.velocity.x * -0.75
		end
	end
end

return glowstick