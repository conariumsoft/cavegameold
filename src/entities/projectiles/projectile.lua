local jutils = require("src.jutils")
local config = require("config")
local collision = require("src.collision")
local physicalentity = require("src.entities.physicalentity")

local projectile = physicalentity:subclass("Projectile")

function projectile:init(start, goal, prop, mass)
	physicalentity.init(self)
	self.nextposition = start
	self.position = start
	self.direction = (goal-start):unitvec()
	self.propulsion = prop
	self.mass = mass
	self.xfriction = 0.2
	self.velocity = self.direction*self.propulsion

end

function projectile:update(dt)

	physicalentity.update(self, dt)

	-- TODO: entity collision checks controlled by the world script
	-- i've got similar loops in about 3 other entitties already :(
	for _, entity in pairs(self.world.entities) do
		if entity:isA("PhysicalEntity") and entity:isA("Player") == false and entity ~= self then
			self.goaldirection = (self.position-entity.position):unitvec()
			local mypos = self.nextposition
			local entpos = entity.nextposition

			local sx, sy = collision.test(
				mypos.x, mypos.y, self.boundingbox.x, self.boundingbox.y, 
				entpos.x, entpos.y, entity.boundingbox.x, entity.boundingbox.y
			)
			if sx~=nil and sy~=nil then
				local nx, ny = collision.solve(sx, sy, self.velocity.x-entity.velocity.x, self.velocity.y-entity.velocity.y)
				
				--entity.nextposition = entity.nextposition - jutils.vec2.new(sx/2, sy/2)
				if nx~=nil and ny~= nil then
					self:entityCollision(entity, jutils.vec2.new(sx, sy), jutils.vec2.new(nx, ny))
					
				end
			end
		end
	end
end

function projectile:draw()
	love.graphics.setColor(1, 0, 0)
	love.graphics.circle("fill",self.position.x, self.position.y, 2)
end

return projectile