--- Definitions for status effects on the player.
-- @author Joshua O'Leary
-- @copyright 2019 Conarium Software

local jutils         = require("src.jutils")
local particlesystem = require("src.particlesystem")

local effects = {
	GLOWING = {
		comeup = function(e) end,
		tick = function(entity, dt),
			entity.lightemitter = {0.5, 0.5, 1}
		end,
		comedown = function(e) end,
	},
	MANLET = {
		comeup = function(entity)
			entity.boundingbox = jutils.vec2.new(entity.boundingbox.x/2, entity.boundingbox.y/2)
			entity.scale.x = entity.scale.x * (3/4)
			entity.scale.y = entity.scale.y/2
			entity.mass = entity.mass / 3
			entity.jump_power = entity.jump_power * 3
		end,

		tick = function(entity, dt)

		end,
		comedown = function(entity)
			entity.boundingbox = jutils.vec2.new(entity.boundingbox.x*2, entity.boundingbox.y*2)
			entity.scale.x = entity.scale.x * (4/3)
			entity.scale.y = entity.scale.y * 2
			entity.mass = entity.mass * 3
			entity.jump_power = entity.jump_power / 3
		end,
	},
	ACCELLERATION = {
		comeup = function(entity)
			entity.walkspeed = 120
			entity.acceleration = 1800
		end,

		tick = function(entity, dt)

		end,
		comedown = function(entity)
			entity.walkspeed = 70
			entity.acceleration = 900
		end,
	},
	LOWMASS = {
		comeup = function(entity)
			entity.scale.x = 0.6
		end,

		tick = function(entity, dt)
			entity.velocity.y = math.min(entity.velocity.y, 30)
		end,
		comedown = function(entity)
			entity.scale.x = 1
		end,
	},
	EXPLOSION = {
		comeup = function(entity)
			
		end,

		tick = function(entity, dt)

		end,
		comedown = function(entity)
			local exp = entity.world:addEntity("explosion", entity.nextposition, 30, 32, true)
		end,
	},
	HEAL = {
		comeup = function(entity)
			
		end,

		tick = function(entity, dt)
			entity.health = entity.health + (dt*5)
		end,
		comedown = function(entity)
			
		end,
	},
	INFECTION = {
		comeup = function(entity)
		
		end,
		tick = function(entity, dt)

		end,
		comedown = function(entity)

		end,
	},
	BURNING = {
		comeup = function(entity)
			entity.fireSystem = particlesystem.newFire(jutils.vec2.new(entity.position.x, entity.position.y+entity.boundingbox.y))
		end,
		tick = function(entity, dt)
			if entity.fireSystem then
				entity.fireSystem:moveTo(entity.position.x, entity.position.y+entity.boundingbox.y)
			end
			entity.health = entity.health - (dt*2)
		end,
		comedown = function(entity)
			entity.fireSystem:release()
		end,
	}
}

return effects
