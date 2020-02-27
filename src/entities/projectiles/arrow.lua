local jutils = require("src.jutils")

local tiles = require("src.tiles")

local projectile = require("src.entities.projectiles.projectile")

local arrow = projectile:subclass("Arrow")

local arrowTexture = love.graphics.newImage("assets/entities/arrow.png")



function arrow:init()
	projectile.init(self, jutils.vec2.new(0, 0), jutils.vec2.new(0, 0), 0, 0)

	self.health = 20
	self.maxhealth = 20
	self.mass = 0.4
	self.xfriction = 0.25
	self.texture = arrowTexture
	self.textureorigin = jutils.vec2.new(2, 2)
	self.boundingbox = jutils.vec2.new(2, 2)
	self.cooldown = 0.1
	self.death_timer = 0
end

function arrow:collisionCallback(tileid, tilepos, separation, normal)

	local data = tiles:getByID(tileid)

	if data.solid == true then
		self.stuck = true
		--self.dead = true
	end
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
	if self.stuck then
		self.death_timer = self.death_timer + dt

		if self.death_timer > 1 then
			self.dead = true
		end
		return
	end
	projectile.update(self, dt)

	self.cooldown = self.cooldown - dt
	self.rotation = math.rad(jutils.vec2.angleBetween(self.velocity, jutils.vec2.new(0, 0)))
end

function arrow:draw()
	love.graphics.setColor(self.light)
	love.graphics.draw(self.texture, self.position.x, self.position.y, self.rotation, self.scale.x, self.scale.y, self.textureorigin.x, self.textureorigin.y)
end

return arrow