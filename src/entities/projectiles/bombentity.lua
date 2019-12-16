local projectile = require("src.entities.projectiles.projectile")
local physicalentity = require("src.entities.physicalentity")
local jutils = require("src.jutils")
local tiles = require("src.tiles")

local bombentity = projectile:subclass("BombEntity")

local bombtexture = love.graphics.newImage("assets/items/bomb.png")

function bombentity:init(timer, creator)
	physicalentity.init(self)

	self.timer = timer
	self.creator = creator
	self.texture = bombtexture
	self.textureorigin = jutils.vec2.new(8,8)
	self.boundingbox = jutils.vec2.new(4, 4)
	self.mass = 0.8
	-- bombs can destroy other bombs, so im setting their health to be massive as an ez fix
	self.health = 10000
	self.maxhealth = 10000
	self.scale = jutils.vec2.new(0.5, 0.5)
	self.save = false
	self.lightemitter = {0.8, 0.5, 0.3}


end
function bombentity:collisionCallback(tileid, tilepos, separation, normal)

	local tiledata = tiles:getByID(tileid)

	if tiledata.solid == true then
		if normal.y and normal.y ~= 0 then
			self.velocity.y = self.velocity.y * -0.8
		end
		if normal.x and normal.x ~= 0 then
			self.velocity.x = self.velocity.x * -0.8
		end
	end
end

function bombentity:entityCollision(otherEntity, separation, normal)
	--otherEntity.velocity.x = otherEntity.velocity.x + (normal.x * self.velocity.x/2)
	--otherEntity.velocity.y = otherEntity.velocity.y + (normal.y * self.velocity.y/2)

	if otherEntity.hostile == true then
		otherEntity:damage(50)
		self.timer = 0
	end
end

function bombentity:update(dt)
	projectile.update(self, dt)

	self.timer = self.timer - dt

	-- time's up, let's explode
	if self.timer < 0 then
		local world = self.world

		

		local exp = world:addEntity("explosion", self.position, 8, 8, true)

		self.dead = true
	end
end

function bombentity:draw()
	love.graphics.setColor(self.light)
	love.graphics.draw(
		self.texture,
		self.position.x, self.position.y, self.rotation, self.scale.x, self.scale.y,
		self.textureorigin.x, self.textureorigin.y
	)
end

return bombentity