local jutils = require("src.jutils")
local projectile = require("src.entities.projectiles.projectile")

local arrow = projectile:subclass("Arrow")

local arrowTexture = love.graphics.newImage("assets/entities/arrow.png")


-- TODO: use arrow health as impact force (decrease health on impact, and slowly over travel time)

function arrow:init()
	projectile.init(self, jutils.vec2.new(0, 0), jutils.vec2.new(0, 0), 0, 0)

	self.health = 20
	self.maxhealth = 20

	self.mass = 0.4
	self.xfriction = 0.25
	self.texture = arrowTexture
	self.textureorigin = jutils.vec2.new(2, 2)
	self.boundingbox = jutils.vec2.new(2, 2)
	self.cooldown = 0
end

function arrow:collisionCallback(tileid, tilepos, separation, normal)
	self.stuck = true
	self.dead = true
end

function arrow:entityCollision(entity, separationVec, normalVec)
	if self.cooldown < 0 then
		local damage = math.random(5, 10)
		self.health = self.health - damage
		entity:damage(damage)
		self.cooldown = 0.04
	end
end

function arrow:update(dt)
	projectile.update(self, dt)

	self.cooldown = self.cooldown - dt
	self.rotation = math.rad(jutils.vec2.angleBetween(self.velocity, jutils.vec2.new(0, 0)))
end

function arrow:draw()
	love.graphics.setColor(self.light)
	love.graphics.draw(self.texture, self.position.x, self.position.y, self.rotation, self.scale.x, self.scale.y, self.textureorigin.x, self.textureorigin.y)
end

return arrow