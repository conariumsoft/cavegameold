local projectile = require("src.entities.projectiles.projectile")

local bullet = projectile:subclass("Bullet")

function bullet:collisionCallback(tileid, normal)
	self.dead = true
end

function bullet:entityCollision(otherEntity, separation, normal)
	otherEntity:damage(5)
	otherEntity.velocity.x = otherEntity.velocity.x - otherEntity*200
	otherEntity.velocity.y = -100
	self.dead = true
end

return bullet