local projectile = require("src.entities.projectiles.projectile")
local jutils = require("src.jutils")

local bullet = projectile:subclass("Bullet")


local bullet_texture = love.graphics.newImage("assets/items/bullet.png")


function bullet:init(...)

	projectile.init(self, ...)

	self.texture = bullet_texture
	self.color = {1, 1, 1}
	self.scale = jutils.vec2.new(0.5, 0.5)
	self.light = {0.5, 0.5, 0.5}
end

function bullet:collisionCallback(tileid, normal)
	self.dead = true
end

function bullet:entityCollision(otherEntity, separation, normal)
	otherEntity:damage(5)
	otherEntity.velocity.x = otherEntity.velocity.x * 0.5
	otherEntity.velocity.y = -100
	self.dead = true
end

function bullet:draw()
	love.graphics.setColor(jutils.color.multiply(self.light, self.color))

	love.graphics.draw(
		self.texture,
		self.position.x, self.position.y, self.rotation, self.scale.x, self.scale.y,
		self.textureorigin.x, self.textureorigin.y
	)

end

return bullet