local projectile = require("src.entities.projectiles.projectile")
local physicalentity = require("src.entities.physicalentity")
local jutils = require("src.jutils")

local bullet = projectile:subclass("Bullet")


local bullet_texture = love.graphics.newImage("assets/items/bullet.png")


function bullet:init(start, direction, power, damage)

	physicalentity.init(self)

	self.nextposition = start
	self.position = start
	self.direction = direction
	self.propulsion = 400+(power*10)
	self.xfriction = 0.2
	self.mass = 0.1
	self.texture = bullet_texture
	self.color = {1, 0.25, 0.25}
	self.scale = jutils.vec2.new(0.5, 0.5)
	self.light = {0.5, 0.5, 0.5}
	self.basedamage = 3
	self.gundamage = damage


	self.velocity = self.direction*self.propulsion
end

function bullet:collisionCallback(tileid, normal)
	self.dead = true
end

function bullet:entityCollision(otherEntity, separation, normal)
	if not otherEntity:isA("Bullet") then
		otherEntity:damage(self.basedamage+self.gundamage)
		otherEntity.velocity.x = otherEntity.velocity.x * 0.5
		otherEntity.velocity.y = -100
		self.dead = true
	end
end

function bullet:draw()
	love.graphics.setColor(self.color)


	love.graphics.setLineWidth(0.5)

	local unit = self.velocity:unitvec()

	love.graphics.line(self.position.x+(unit.x*10), self.position.y+(unit.y*10), self.position.x, self.position.y)


	--[[love.graphics.draw(
		self.texture,
		self.position.x, self.position.y, self.rotation, self.scale.x, self.scale.y,
		self.textureorigin.x, self.textureorigin.y
	)]]

end

return bullet